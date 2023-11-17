## standard library
import itertools

## external modules
import mesa
import numpy as np

## this project
from .farmer import Farmer

class LandUseModel(mesa.Model):

    def __init__(self, N):

        ## admin
        self.schedule = mesa.time.RandomActivation(self)
        self.N = N
 
        ## model world parameters
        self.climate_effect = 0.0
        self.climate_change_rate = 0.01
        self.profit_margin = 0.5
        self.climate_effect_range = (0, 2)
        self.neighbour_focus_std = 0.1
        self.neighbour_focus_mean = 0.5
        self.profit_motivation_range = (-0.5,0.5)
        self.sustainability_motivation_range = (-0.5, 0.5)
        self.neighbour_motivation_range = (-0.5, 0.5)
        self.intensity_range = (0.1, 0.9)

        ## create a grid of agents
        self.grid = mesa.space.MultiGrid(self.N, self.N, torus=True)
        for i,j in itertools.product(range(self.N),range(self.N)):
            a = Farmer(i+N*j, self)
            a.coords = (i,j)
            self.grid.place_agent(a, a.coords)
            self.schedule.add(a)

        ## data collector
        self.datacollector = mesa.DataCollector(
            model_reporters={"climate_effect": "climate_effect"}, 
            agent_reporters={'intensity':'intensity',
                             'profit_motivation':'profit_motivation',
                             'sustainability_motivation':'sustainability_motivation',
                             'neighbour_motivation':'neighbour_motivation',
                             'x':lambda a:a.coords[0],
                             'y':lambda a:a.coords[1],})

    def step(self):
        ## model changes
        self.climate_effect += self.climate_change_rate
        self.climate_effect = min(max(self.climate_effect, self.climate_effect_range[0]), self.climate_effect_range[1])
        ## agent changes
        self.schedule.step()
        ## collect data
        self.datacollector.collect(self)
