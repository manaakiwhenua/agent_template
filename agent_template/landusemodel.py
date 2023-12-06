## standard library
import itertools

## external modules
import mesa
import numpy as np
from omegaconf import OmegaConf

## this project
from .farmer import Farmer

class LandUseModel(mesa.Model):


    def __init__(self, config):

        ## admin
        self.schedule = mesa.time.RandomActivation(self)
        self.config = config
        self.land_uses = self.config['land_uses']
        self.farmer_behaviours = self.config['farmer_behaviours']
        self.land_use_networks = list(range(self.config['number_of_land_use_networks']))
        self.current_step = 0
 
        ## create a grid of farms
        self.farm_grid = mesa.space.MultiGrid(
            self.config['grid_length'],
            self.config['grid_length'],
            torus=True)

        ## set farmer and land use for each farm
        self.farmers = []
        for n,(i,j) in enumerate(itertools.product(
                range(self.config['grid_length']),
                range(self.config['grid_length']),)):
            farmer = Farmer(n, self)
            self.farmers.append(farmer)
            farmer.coords = (i,j)
            self.farm_grid.place_agent(farmer, farmer.coords)
            self.schedule.add(farmer)
       
        ## find neighbours
        for farmer in self.farmers:
            farmer.neighbours = self.farm_grid.get_neighbors(
                farmer.coords,moore=True,include_center=False  )

        ## find network members. INCLUDE SELF IN OWN NETWORK?
        for network in self.land_use_networks:
            network_members = [farmer for farmer in self.farmers
                                if farmer.land_use_network==network]
            for farmer in network_members:
                farmer.network_members  = network_members
                
        
     
        # ## data collector
        # self.datacollector = mesa.DataCollector(
            # model_reporters={"climate_effect": "climate_effect"}, 
            # agent_reporters={'intensity':'intensity',
                             # 'profit_motivation':'profit_motivation',
                             # 'sustainability_motivation':'sustainability_motivation',
                             # 'neighbour_motivation':'neighbour_motivation',
                             # 'x':lambda a:a.coords[0],
                             # 'y':lambda a:a.coords[1],})


    def step(self):
        ## model changes
        self.current_step += 1
        ## agent changes
        self.schedule.step()
        # ## collect data
        # self.datacollector.collect(self)

    def print_config(self):
        print(OmegaConf.to_yaml(self.config))

        
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
