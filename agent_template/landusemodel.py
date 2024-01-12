## standard library
import itertools
import random
from pprint import pprint

## external modules
import functools

import mesa
import numpy as np
from omegaconf import OmegaConf
import pandas as pd
import networkx as nx

## this project

from .farmer import Farmer
from .networks import LandUseNetwork
from . import gis

class LandUseModel(mesa.Model):


    def __init__(self, **config):
        ## admin
        self.schedule = mesa.time.BaseScheduler(self)
        self.config = config
        # self.grid_length = self.config['grid_length']
        self.land_use = self.config['land_use']
        self.farmer_behaviour = self.config['farmer_behaviour']
        self.current_step = 0
        self._data = {}
        self.running = True
        self.verbose = True 

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
            land_use = gis.load_raster(self.config['space']['filename'])
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

        ## collect data
        self._collect_data()

    def step(self):
        ## admin
        self.current_step += 1
        if self.verbose:
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
        """Return data as a dictionary of dataframes."""
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
        """Make a rectangular grid of farms with Farmers and with land use supplied as
        a two dimensional arrayor randomnly generated."""
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
        """Create a newtork of farms with land use defined by
        a vector file."""
        ## load vector data into geopandas dataarray
        data = gis.load_vector(self.config['space']['filename'])
        ## initialise land graph and farmers
        graph = nx.Graph()
        self.farmers = []
        for i,row in data.iterrows():
            geometry = data.loc[[i],'geometry']
            farmer = Farmer(self.schedule.get_agent_count(),self,row['land_use'])
            self.farmers.append(farmer)
            self.schedule.add(farmer)
            graph.add_node(i,geometry=geometry)
        ## add edges between intersecting polygons - or touching?
        geometry = data['geometry']
        for i in range(len(data)):
            for j in range(i,len(data)):
                if geometry[i].intersection(geometry[j]):
                    graph.add_edge(i,j)
        ## create network space
        self.space = mesa.space.NetworkGrid(graph)
        ## add farmers to network
        for node_id,farmer in zip(graph.nodes,self.farmers):
            self.space.place_agent(farmer,node_id)
            graph.nodes[node_id]["farmer"] = farmer
