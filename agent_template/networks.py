import mesa
import numpy as np
import random


class LandUseNetwork(mesa.Agent):
    """Land use network"""

    def __init__(self,uid,model):
        super().__init__(uid, model)
        self.model = model
        self.uid = uid
        self.members = []       # Farmer members of this network
        self.most_common_land_use = None

    def step(self):
        land_uses = [member.land_use for member in self.members]
        unique,count = np.unique(land_uses,return_counts=True)
        self.most_common_land_use = unique[np.argmax(count)]

    def collect_data(self):
        data = {'most_common_land_use':self.most_common_land_use,}
        return data

