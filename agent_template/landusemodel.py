## standard library
import itertools
import random

## external modules
import functools


import mesa
import numpy as np
from omegaconf import OmegaConf
import pandas as pd

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

        ## create a rectangular grid of farms
        if self.config['space']['type'] == 'grid':
            self.space = mesa.space.SingleGrid(
                self.config['space']['x'],
                self.config['space']['y'],
                torus=False)

        ## create a rectangular grid of farms defined by a raster
        ## layer loaded from a file defining the initial land use 
        elif self.config['space']['type'] == 'raster layer':
            raster_layer_landuse = gis.load_raster_layer(self.config['space']['filename'])
            self.space = mesa.space.SingleGrid(*raster_layer_landuse.shape, torus=False,)
        else:
            assert False

        ## farmers
        self.farmers = []
        for contents,pos in self.space.coord_iter():
            if self.config['space']['type'] == 'raster layer':
                initial_land_use = raster_layer_landuse[pos]
            else:
                initial_land_use = None

            farmer = Farmer(self.schedule.get_agent_count(), self, initial_land_use)
            self.farmers.append(farmer)
            self.space.place_agent(farmer,pos)
            self.schedule.add(farmer)

        ## find farmer neighbours
        for farmer in self.farmers:
            farmer.neighbours = self.space.get_neighbors(
                farmer.pos,moore=True,include_center=False  )

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
