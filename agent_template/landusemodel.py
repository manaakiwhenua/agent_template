## standard library
import itertools
import random

## external modules
import mesa
import numpy as np
from omegaconf import OmegaConf
import pandas as pd

## this project
from .farmer import Farmer
from .networks import LandUseNetwork

class LandUseModel(mesa.Model):


    def __init__(self, config):

        ## admin
        self.schedule = mesa.time.BaseScheduler(self)
        config = dict(config)   # OmegaConf objects are slow to access, cast as native dictionary
        self.config = config
        self.grid_length = self.config['grid_length']
        self.land_use = self.config['land_use']
        self.farmer_behaviour = self.config['farmer_behaviour']
        self.current_step = 0
        self.collected_data = {}
 
        ## create a grid of farms
        self.farm_grid = mesa.space.MultiGrid(
            self.grid_length, self.grid_length, torus=True)

        ## land use networks
        self.land_use_networks = []
        for i in range(config['number_of_land_use_networks']):
            network = LandUseNetwork(self.schedule.get_agent_count(),self)
            self.schedule.add(network)
            self.land_use_networks.append(network)

        ## farmers
        self.farmers = []
        for n,(i,j) in enumerate(itertools.product(
                range(self.grid_length), range(self.grid_length),)):
            farmer = Farmer(self.schedule.get_agent_count(), self)
            self.farmers.append(farmer)
            farmer.coords = (i,j)
            self.farm_grid.place_agent(farmer, farmer.coords)
            self.schedule.add(farmer)

        ## find neighbours
        for farmer in self.farmers:
            farmer.neighbours = self.farm_grid.get_neighbors(
                farmer.coords,moore=True,include_center=False  )

    def step(self):
        ## model changes
        self.current_step += 1

        ## agent changes
        self.schedule.step()

        ## collect data
        for label,agents in (
                ('farmer',self.farmers),
                ('land_use_network',self.land_use_networks),
        ):
            self.collected_data.setdefault(label,{'step':[],'uid':[]})
            for agent in agents:
                self.collected_data[label]['step'].append(self.current_step)
                self.collected_data[label]['uid'].append(agent.uid)
                for key,val in agent.collect_data().items():
                    self.collected_data[label].setdefault(key,[])
                    self.collected_data[label][key].append(val)

    def print_config(self):
        print(OmegaConf.to_yaml(self.config))

    def get_data(self):
        retval = {key:pd.DataFrame(val)
                  for key,val in  self.collected_data.items()}
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
