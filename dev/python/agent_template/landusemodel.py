## standard library
import itertools
import random
from pprint import pprint
import functools
from copy import copy
import os

## external modules
from matplotlib import pyplot as plt
import matplotlib as mpl
import mesa
import numpy as np
from omegaconf import OmegaConf
import pandas as pd
import networkx as nx

## this project

from .farmer import Farmer
from .networks import LandUseNetwork
from . import gis
from . import utils


class LandUseModel(mesa.Model):


    def __init__(self, config,**kwargs):

        # ## process input arguments.  Values in config are overloaded
        # ## by kwargs.  Nested dictionaries in config can be overloaded
        # ## by kwargs separating dictionary keys with '__'.  This is
        # ## necessary to use the interactive parameter adjustment in
        # ## mesa.JupyterViz
        for key,val in kwargs.items():
            utils.set_nested_dict_value(config,key,val)

        ## admin
        self.schedule = mesa.time.BaseScheduler(self)
        self.config = config
        self.land_use = self.config['land_use']
        self.farmer_behaviour = self.config['farmer_behaviour']
        self.current_step = 0
        self._data = {}
        self.running = True

        ## create land use networks
        self.land_use_networks = []
        for i in range(config['number_of_land_use_networks']):
            network = LandUseNetwork(self.schedule.get_agent_count(),self)
            self.schedule.add(network)
            self.land_use_networks.append(network)

        ## create space of farms
        if self.config['space']['type'] == 'grid':
            self._make_grid_space(
                x=self.config['space']['x'],
                y=self.config['space']['y'],
                land_use=None,)
        elif self.config['space']['type'] == 'raster':
            raster_filename = self.config['base_directory']+'/'+self.config['space']['filename']
            land_use = gis.load_raster(raster_filename)
            x,y = land_use.shape
            self._make_grid_space(x,y,land_use)
        elif self.config['space']['type'] == 'vector':
            self._make_vector_space()
        else:
            raise Exception("Invalid space.type: "+repr(self.config['space']['type']))

        ## find farmer neighbours
        for farmer in self.farmers:
            if isinstance(self.space,mesa.space.SingleGrid):
                farmer.neighbours = self.space.get_neighbors(
                    farmer.pos,moore=True,include_center=False)
            elif isinstance(self.space,mesa.space.NetworkGrid):
                farmer.neighbours = self.space.get_neighbors(
                    farmer.pos,include_center=False)
            else:
                assert False

        ## create output directory
        abs_output_directory = config['base_directory']+'/'+config['output_directory']
        if not os.path.exists(abs_output_directory):
            os.mkdir(abs_output_directory)
                
        ## collect initial data
        self._collect_data()

    def step(self):

        ## admin
        self.current_step += 1
        if self.config['verbose']:
            print(f'current_step: {self.current_step}')
        ## model changes
        pass
        ## agent changes
        self.schedule.step()
        ## collect data
        self._collect_data()

    def _collect_data(self):

        """Collect data about this model. The mesa data
        collection methods to be too constricting."""

        for label,agents in (
                ('farmer',self.farmers),
                ('land_use_network',self.land_use_networks),
        ):
            self._data.setdefault(label,{'step':[],'uid':[]})
            for agent in agents:
                self._data[label]['step'].append(self.current_step)
                self._data[label]['uid'].append(agent.uid)
                for key,val in agent._collect_data().items():
                    self._data[label].setdefault(key,[])
                    self._data[label][key].append(val)

    def print_config(self):

        print(OmegaConf.to_yaml(self.config))


    _get_data_previous_current_step = -1
    _get_data_cache = None
    def get_data(self):

        """Return data as a dictionary of dataframes. Uses cached
        value if model has not been stepped."""

        if self.current_step == self._get_data_previous_current_step:
            retval = self._get_data_cache
        else:
            retval = {key:pd.DataFrame(val) for key,val in self._data.items()}
            self._get_data_previous_current_step = self.current_step
            self._get_data_cache = retval
        return retval
        
    def describe(self):

        """Summarise the model."""

        return "LandUseModel:\n    "+"\n    ".join([
            f'number_of_farmers: {len(self.farmers)}',
            # f'farmer_behaviours: {self.parameters['farmer_behaviours']}',
            # f'number_of_land_use_networks: {self.number_of_land_use_networks}',
            # f'occurrence_max: {self.occurrence_max}',
            ])
    
    def __str__(self):
        return self.describe()

    def _make_grid_space(self,x,y,land_use=None):

        """Make a rectangular grid of farms with Farmers and with land
        use supplied as a two dimensional array or randomnly
        generated."""

        ## make the grid space
        self.space = mesa.space.SingleGrid(x,y,torus=False)
        ## create random land use if needed
        if land_use is None:
            land_use = np.random.choice(
                list(self.config['land_use'].keys()),
                (x,y),
                [t['initial_distribution'] for t in self.config['land_use'].values()])
        ## create farmers
        self.farmers = []
        for contents,pos in self.space.coord_iter():
            farmer = Farmer(self.schedule.get_agent_count(),self,land_use[pos])
            self.farmers.append(farmer)
            self.space.place_agent(farmer,pos)
            self.schedule.add(farmer)
        
    def _make_vector_space(self):
 
        """Create a newtork of farms with geometries and land use
        defined in a vector file."""
 
        ## load vector data into geopandas dataarray
        data,geometry,geometry_with_buffer = gis.load_vector(
            filename=self.config['base_directory']+'/'+self.config['space']['filename'],
            buffer=self.config['space']['find_neighbours_buffer'],)
 
        ## initialise land graph and farmers
        graph = nx.Graph()
        self.farmers = []
        # for i,(land_use_i,geometry_i) in enumerate(zip(data['land_use'],geometry)):
        for i in range(len(data)):
            farmer = Farmer(self.schedule.get_agent_count(),self,data['land_use'][i])
            self.farmers.append(farmer)
            self.schedule.add(farmer)
            graph.add_node(i,geometry=geometry.loc[[i]])
 
        ## add edges between intersecting polygons using an
        ## intersection of buffered data
        for i in range(len(data)):
            for j in range(i+1,len(data)):
                if geometry_with_buffer[i].intersection(geometry_with_buffer[j]):
                    graph.add_edge(i,j)
 
        ## create network space
        self.space = mesa.space.NetworkGrid(graph)
 
        ## add farmers to network and node to farmers
        for node_id,farmer in zip(graph.nodes,self.farmers):
            self.space.place_agent(farmer,node_id)
            node = graph.nodes[node_id]
            node["farmer"] = farmer
            farmer.node_id = node_id
            farmer.node = node


    ## output these kinds of plots if requested
    static_visualisation_filetypes = ('png','pdf','jpg','jpeg','tiff','svg')

    def make_visualisation(self):

        """Use maptlotlib to make a static visualisation or interactive window."""

        data = self.get_data()
        config = self.config
        ## style and initialise figure
        if config['plot'] == 'window':
            mpl.use('QtAgg')
        elif config['plot'] in self.static_visualisation_filetypes:
            mpl.use('Agg')
        else:
            raise Exception('Invalid visualisation:', config['plot'])
        mpl.rcParams |= {
            'figure.figsize':(11.7,8.3,), # A4 landscape
            'figure.subplot.bottom': 0.2,
            'figure.subplot.top': 0.95,
            'figure.subplot.left': 0.05,
            'figure.subplot.right': 0.95,
            'font.family': 'sans',}
        fig = mpl.pyplot.figure()
        fig.clf()
        ## plot land use at requested steps
        steps = config['plot_steps']
        ## ensure a list of steps
        if isinstance(steps,int):
            steps = [steps]
        ## translate negative steps as indexed from the end 
        for i,step in enumerate(copy(steps)):
            if step < 0:
                max_steps = data['farmer']['step'].max()
                steps[i] = max_steps + step + 1
        for step in steps:
            self.plot_land_use_map(step=step,fig=fig)
            self.plot_land_use_distribution(step=step,fig=fig)
        ## land use legend
        axes = plt.gca()
        for data in self.config['land_use'].values():
            axes.plot([],[],color=data['color'],label=data['label'])
        leg = axes.legend(
            title="Land use",
            title_fontsize='xx-large',
            ncol=3,
            frameon= True,
            fontsize='large',
            handlelength=0,         # draw no lines
            ## figure coords
            bbox_to_anchor=(0.5,0),
            loc="lower center",
            bbox_transform=fig.transFigure,)
        ## color text
        handles,labels = axes.get_legend_handles_labels()
        for text,handle in zip(leg.get_texts(),handles):
            text.set_color(handle.get_color())
        ## output
        if config['plot'] == 'window': 
            plt.show()
        elif config['plot'] in self.static_visualisation_filetypes:
            ## static file
            filename = '/'.join([
                config['base_directory'],
                config["output_directory"],
                'land_use.'+config['plot']])
            print(f'Saving file: {filename!r}')
            plt.savefig(filename)
        else:
            pass

        return fig

    def plot_land_use_map(self,step=None,fig=None,axes=None):

        """Plot land use at some step (defaults to last) on a new or
        existing set of axes."""

        data = self.get_data()
        data = data['farmer']
        config = self.config
        ## get data for one step, default to last
        if step is None:
            step = data['step'].max()
        data = data[data['step']==step]
        if fig is None:
            fig = plt.figure()
        ## make new axes
        if axes is None:
            axes = utils.subplot(fig=fig)
        ## plot land use
        if isinstance(self.space,mesa.space.SingleGrid):
            ## plot grid points as square patches
            for i,agent in data.iterrows():
                axes.add_patch(mpl.patches.Rectangle(
                    (agent['x_coord'],agent['y_coord']), 1,1,
                    color=self.config['land_use'][agent['land_use']]['color'],))
            axes.xaxis.set_ticks([])
            axes.yaxis.set_ticks([])
            axes.set_xlim(data['x_coord'].min(),data['x_coord'].max())
            axes.set_ylim(data['y_coord'].min(),data['y_coord'].max())
        elif isinstance(self.space,mesa.space.NetworkGrid):
            ## plot vector shapes
            graph = self.space.G
            for node_id in graph.nodes:
                node = graph.nodes[node_id]
                geometry = node['geometry']
                farmer = node['farmer']
                land_use = data['land_use'][data['node_id']==node_id].iloc[0]
                color = self.config['land_use'][land_use]['color']
                geometry.plot(color=color,ax=axes)
        else:
            assert False

        axes.set_title(f'Land use map, step={step}')

        return fig,axes

    def plot_land_use_distribution(self,step=None,fig=None,axes=None):
        if fig is None:
            fig = plt.figure()
        if axes is None:
            axes = utils.subplot(fig=fig)
        ## get data for one step, default to last
        data = self.get_data()
        data = data['farmer']
        if step is None:
            step = data['step'].max()
        data = data[data['step']==step]
        land_uses = list(self.config['land_use'].keys())
        count = [np.sum(data['land_use']==land_use) for land_use in land_uses]
        axes.bar(land_uses,count)
        axes.xaxis.set_ticks(land_uses)
        axes.set_title(f'Land use distribution, step={step}')
        return fig,axes
        
