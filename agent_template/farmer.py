import mesa
import numpy as np
import random


class Farmer(mesa.Agent):
    """Farmer agent"""

    def __init__(self,uid,model,land_use):
        super().__init__(uid, model)
        self.model = model
        self.uid = uid
        self.land_use = land_use
        ## assign behaviour of this farmer
        self.behaviour = random.choices(
            population = list(self.model.farmer_behaviour.keys()),
            weights = [t['initial_distribution'] for t in self.model.farmer_behaviour.values()])[0]
        ## assign to a network of farmers with this land use
        self.land_use_network = random.choice(self.model.land_use_networks)
        self.land_use_network.members.append(self)
        ## assign first step for this farmers land-use change
        self.first_occurrence = random.randint(0,self.model.config['occurrence_max']-1)
        ## initialise the most common land use of this farmers neighbours
        self.land_use_neighbour = None

    def __str__(self):
        return self.describe()

    def describe(self):
        """Print a summary of the farmer."""
        return 'farmer:\n    '+'\n    '.join([
            f'uid: {self.uid!r}',
            f'behaviour: {self.behaviour!r} ',
            f'land_use: {self.land_use!r} ',
            f'land_use_network: {self.land_use_network!r} ',
            f'first_occurrence: {self.first_occurrence!r} ',
        ])

    def step(self):
        ## evaluate rules every occurrence_max steps 
        if (self.model.current_step+self.first_occurrence) % self.model.config['occurrence_max'] == 0:
            if 'basic' in self.model.config['land_use_rules']:
                self.evaluate_basic_rule()
            if 'neighbour' in self.model.config['land_use_rules']:
                self.evaluate_neighbour_rule()
            if 'network' in self.model.config['land_use_rules']:
                self.evaluate_network_rule()

    def _collect_data(self):
        """Collect data about this farmer. The mesa data
        collection methods to be too constricting."""
        data = {'land_use':self.land_use,}
        if isinstance(self.model.space,mesa.space.SingleGrid):
            data |= {'x_coord':self.pos[0], 'y_coord':self.pos[1],}
        elif isinstance(self.model.space,mesa.space.NetworkGrid):
            data |= {'node_id':self.pos,}
        else:
            assert False
        return data

    def evaluate_network_rule(self):
        ## choose most common land use among neighbours. HOW TO HANDLE A DRAW?
        most_common_land_use = self.land_use_network.most_common_land_use

        ## select possible change in land use
        if self.behaviour == 'business_as_usual':
            if (self.land_use in (3, 4, 5, 6, 7, 9,) and most_common_land_use == 1):
                self.land_use == 1
        
        elif self.behaviour == 'industry_conscious':
            if self.land_use != 1 and most_common_land_use == 1:
                self.land_use = 1
            elif (self.land_use in (3, 4, 5, 6, 7,) and most_common_land_use == 3):
                self.land_use = 3
            elif (self.land_use in (3, 6, 7,) and most_common_land_use == 4):
                self.land_use = 4
            elif (self.land_use in (3, 4, 7,) and most_common_land_use == 6):
                self.land_use = 6
            elif (self.land_use in (3, 5, 9,) and most_common_land_use == 7):
                self.land_use = 7
            elif (self.land_use in (3, 5, 7) and most_common_land_use == 9):
                self.land_use = 9
                
        elif self.behaviour == 'climate_conscious':
            if (self.land_use in (6, 7,) and most_common_land_use == 3):
                self.land_use = 3 
            elif (self.land_use in (3, 6, 7,) and most_common_land_use == 4):
                self.land_use = 4
            elif (self.land_use in (3, 6,) and most_common_land_use == 7):
                self.land_use = 7
            elif (self.land_use in (7,) and most_common_land_use == 9):
                self.land_use = 9
            elif (self.land_use != 8 and self.land_use != 1 and most_common_land_use == 8):
                self.land_use = 8

        else:
            raise Exception(f'Invalid: {behaviour=}')


    def evaluate_neighbour_rule(self):

        # print("DEBUG:", len(self.neighbours)) # DEBUG
        if len(self.neighbours) == 0:
            return

        ## choose most common land use among neighbours. HOW TO HANDLE A DRAW?
        neighbour_land_uses = [neighbour.land_use for neighbour in self.neighbours]
        unique,count = np.unique(neighbour_land_uses,return_counts=True)
        most_common_land_use = unique[np.argmax(count)]

        ## select possible change in land use
        if self.behaviour == 'business_as_usual':
            if (self.land_use in (3, 4, 5, 6, 7, 9,) and most_common_land_use == 1):
                self.land_use == 1
        
        elif self.behaviour == 'industry_conscious':
            if self.land_use != 1 and most_common_land_use == 1:
                self.land_use = 1
            elif (self.land_use in (3, 4, 5, 6, 7,) and most_common_land_use == 3):
                self.land_use = 3
            elif (self.land_use in (3, 6, 7,) and most_common_land_use == 4):
                self.land_use = 4
            elif (self.land_use in (3, 4, 7,) and most_common_land_use == 6):
                self.land_use = 6
            elif (self.land_use in (3, 5, 9,) and most_common_land_use == 7):
                self.land_use = 7
            elif (self.land_use in (3, 5, 7) and most_common_land_use == 9):
                self.land_use = 9
                
        elif self.behaviour == 'climate_conscious':
            if (self.land_use in (6, 7,) and most_common_land_use == 3):
                self.land_use = 3 
            elif (self.land_use in (3, 6, 7,) and most_common_land_use == 4):
                self.land_use = 4
            elif (self.land_use in (3, 6,) and most_common_land_use == 7):
                self.land_use = 7
            elif (self.land_use in (7,) and most_common_land_use == 9):
                self.land_use = 9
            elif (self.land_use != 8 and self.land_use != 1 and most_common_land_use == 8):
                self.land_use = 8

        else:
            raise Exception(f'Invalid: {behaviour=}')

    
    
    def evaluate_basic_rule(self):
    
        if self.behaviour == 'business_as_usual':
            if self.land_use == 1:
                neighbour = random.choice(self.neighbours)
                if neighbour.land_use in (3, 4, 6, 7,):
                    ## SHOULD SET NEIGHBOUR OR SELF HERE?
                    neighbour.land_use = 1

        elif self.behaviour == 'industry_conscious':
            if self.land_use == 1:
                neighbour = random.choice(self.neighbours)
                if neighbour.land_use != 1:
                    ## SHOULD SET NEIGHBOUR OR SELF HERE?
                    neighbour.land_use = 1
            elif self.land_use == 3:
                self.land_use = random.choice([6,4,])
            elif self.land_use == 6:
                self.land_use = random.choice([6,4,3])
            elif self.land_use == 7:
                self.land_use = random.choice([7,9,])
            elif self.land_use == 9:
                self.land_use = random.choice([9,7,])
            else:
                pass

        elif self.behaviour == 'climate_conscious':
            if self.land_use == 3:
                self.land_use = random.choice([4])
            elif self.land_use == 4:
                self.land_use = random.choice([4,8])
            elif self.land_use == 6:
                self.land_use = random.choice([4,3])
            elif self.land_use == 7:
                self.land_use = random.choice([7,8,9])
            elif self.land_use == 9:
                self.land_use = random.choice([9,8,7])
            else:
                pass

        else:
            raise Exception(f'Invalid: {behaviour=}')
