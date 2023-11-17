import mesa
import numpy as np

## define a kind of agent
class Farmer(mesa.Agent):

    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)

        ## define agent properties
        self.profit_focus = np.random.randn()*0.1 + 0.5
        self.sustainability_focus  = 1 - self.profit_focus
        self.neighbour_focus  = np.random.randn()*self.model.neighbour_focus_std + self.model.neighbour_focus_mean
        self.intensity =  np.random.randn()*0.1 + 0.5

    def step(self):

        ## motivate agent
        neighbours = self.model.grid.get_neighbors(self.coords,moore=True,include_center=False  )
        mean_neighbour_intensity = np.mean([t.intensity for t in neighbours])
        self.profit_motivation = (1 - self.intensity) * self.model.profit_margin * self.profit_focus
        self.profit_motivation = min(max(self.profit_motivation, self.model.profit_motivation_range[0]), self.model.profit_motivation_range[1])
        self.sustainability_motivation =  self.intensity * (1 + self.model.climate_effect) * self.sustainability_focus
        self.sustainability_motivation = min(max(self.sustainability_motivation, self.model.sustainability_motivation_range[0]), self.model.sustainability_motivation_range[1])
        self.neighbour_motivation = ( mean_neighbour_intensity - self.intensity ) * self.neighbour_focus
        self.neighbour_motivation = min(max(self.neighbour_motivation, self.model.neighbour_motivation_range[0]), self.model.neighbour_motivation_range[1])

        ## take action
        self.intensity = (
            self.intensity
            + self.profit_motivation
            - self.sustainability_motivation 
            + self.neighbour_motivation
        )
        self.intensity = min(max(self.intensity, self.model.intensity_range[0]), self.model.intensity_range[1])
