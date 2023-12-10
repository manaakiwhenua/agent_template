import mesa
import numpy as np
import random


class Farmer(mesa.Agent):
    """Farmer agent"""

    def __init__(self, uid, model):
        super().__init__(uid, model)
        self.model = model
        self.uid = uid

        ## assign behaviour of this farmer
        self.behaviour = random.choices(
            population = list(self.model.farmer_behaviour.keys()),
            weights = [t['initial_distribution'] for t in self.model.farmer_behaviour.values()])[0]

        ## assign to a network of farmers with this land use
        self.land_use_network = random.choice(self.model.land_use_networks)
        self.land_use_network.members.append(self)

        ## assign first step for this farmers land-use change
        self.first_occurrence = random.randint(0,self.model.config['occurrence_max']-1)

        ## assign land use
        self.land_use = random.choices(
            population = list(self.model.land_use.keys()),
            weights = [t['initial_distribution'] for t in self.model.land_use.values()])[0]

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

    def collect_data(self):
        data = {'land_use':self.land_use,
                'x_coord':self.coords[0],
                'y_coord':self.coords[1],}
        return data

    def evaluate_network_rule(self):
        ## choose most common land use among neighbours. HOW TO HANDLE A DRAW?

        most_common_land_use = self.land_use_network.most_common_land_use

        ## select possible change in land use
        if self.behaviour == 'business_as_usual':
            if (self.land_use in ('crop_annual', 'crop_perennial', 'scrub',
                                 'intensive_pasture', 'extensive_pasture', 'exotic_forest',)
                    and most_common_land_use == 'artificial'):
                self.land_use == 'artificial'
        
        elif self.behaviour == 'industry_conscious':

            if self.land_use != 'artificial' and most_common_land_use == 'artificial':
                self.land_use = 'artificial'

            elif (self.land_use in ('crop_annual', 'crop_perennial', 'scrub', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_annual'):
                self.land_use = 'crop_annual'

            elif (self.land_use in ('crop_annual', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_perennial'):
                self.land_use = 'crop_perennial'

            elif (self.land_use in ('crop_annual', 'crop_perennial', 'extensive_pasture',) 
                  and most_common_land_use == 'intensive_pasture'):
                self.land_use = 'intensive_pasture'

            elif (self.land_use in ('crop_annual', 'scrub', 'exotic_forest',) 
                  and most_common_land_use == 'extensive_pasture'):
                self.land_use = 'extensive_pasture'

            elif (self.land_use in ('crop_annual', 'scrub', 'extensive_pasture') 
                  and most_common_land_use == 'exotic_forest'):
                self.land_use = 'exotic_forest'
                
        elif self.behaviour == 'climate_conscious':

            if (self.land_use in ('intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_annual'):
                self.land_use = 'crop_annual' 

            elif (self.land_use in ('crop_annual', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_perennial'):
                self.land_use = 'crop_perennial'

            elif (self.land_use in ('crop_annual', 'intensive_pasture',) 
                  and most_common_land_use == 'extensive_pasture'):
                self.land_use = 'extensive_pasture'

            elif (self.land_use in ('extensive_pasture',) 
                  and most_common_land_use == 'exotic_forest'):
                self.land_use = 'exotic_forest'

            elif (self.land_use != 'native_forest'
                  and self.land_use != 'artificial'
                  and most_common_land_use == 'native_forest'):
                self.land_use = 'native_forest'

        else:
            raise Exception(f'Invalid: {behaviour=}')


    def evaluate_neighbour_rule(self):

        ## choose most common land use among neighbours. HOW TO HANDLE A DRAW?
        neighbour_land_uses = [neighbour.land_use for neighbour in self.neighbours]
        unique,count = np.unique(neighbour_land_uses,return_counts=True)
        most_common_land_use = unique[np.argmax(count)]

        ## select possible change in land use
        if self.behaviour == 'business_as_usual':
            if (self.land_use in ('crop_annual', 'crop_perennial', 'scrub',
                                 'intensive_pasture', 'extensive_pasture', 'exotic_forest',)
                    and most_common_land_use == 'artificial'):
                self.land_use == 'artificial'
        
        elif self.behaviour == 'industry_conscious':

            if self.land_use != 'artificial' and most_common_land_use == 'artificial':
                self.land_use = 'artificial'

            elif (self.land_use in ('crop_annual', 'crop_perennial', 'scrub', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_annual'):
                self.land_use = 'crop_annual'

            elif (self.land_use in ('crop_annual', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_perennial'):
                self.land_use = 'crop_perennial'

            elif (self.land_use in ('crop_annual', 'crop_perennial', 'extensive_pasture',) 
                  and most_common_land_use == 'intensive_pasture'):
                self.land_use = 'intensive_pasture'

            elif (self.land_use in ('crop_annual', 'scrub', 'exotic_forest',) 
                  and most_common_land_use == 'extensive_pasture'):
                self.land_use = 'extensive_pasture'

            elif (self.land_use in ('crop_annual', 'scrub', 'extensive_pasture') 
                  and most_common_land_use == 'exotic_forest'):
                self.land_use = 'exotic_forest'
                
        elif self.behaviour == 'climate_conscious':

            if (self.land_use in ('intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_annual'):
                self.land_use = 'crop_annual' 

            elif (self.land_use in ('crop_annual', 'intensive_pasture', 'extensive_pasture',) 
                  and most_common_land_use == 'crop_perennial'):
                self.land_use = 'crop_perennial'

            elif (self.land_use in ('crop_annual', 'intensive_pasture',) 
                  and most_common_land_use == 'extensive_pasture'):
                self.land_use = 'extensive_pasture'

            elif (self.land_use in ('extensive_pasture',) 
                  and most_common_land_use == 'exotic_forest'):
                self.land_use = 'exotic_forest'

            elif (self.land_use != 'native_forest'
                  and self.land_use != 'artificial'
                  and most_common_land_use == 'native_forest'):
                self.land_use = 'native_forest'

        else:
            raise Exception(f'Invalid: {behaviour=}')

    
    
    def evaluate_basic_rule(self):
    
        if self.behaviour == 'business_as_usual':
            if self.land_use == 'artificial':
                neighbour = random.choice(self.neighbours)
                if neighbour.land_use in ('crop_annual', 'crop_perennial', 
                                          'intensive_pasture', 'extensive_pasture',):
                    ## SHOULD SET NEIGHBOUR OR SELF HERE?
                    neighbour.land_use = 'artificial'

        elif self.behaviour == 'industry_conscious':
            
            if self.land_use == 'artificial':
                neighbour = random.choice(self.neighbours)
                if neighbour.land_use != 'artificial':
                    ## SHOULD SET NEIGHBOUR OR SELF HERE?
                    neighbour.land_use = 'artificial'
            elif self.land_use == 'crop_annual':
                self.land_use = random.choice(['intensive_pasture','crop_perennial',])
            elif self.land_use == 'intensive_pasture':
                self.land_use = random.choice(['intensive_pasture','crop_perennial','crop_annual'])
            elif self.land_use == 'extensive_pasture':
                self.land_use = random.choice(['extensive_pasture','exotic_forest',])
            elif self.land_use == 'exotic_forest':
                self.land_use = random.choice(['exotic_forest','extensive_pasture',])
            else:
                pass

        elif self.behaviour == 'climate_conscious':
            if self.land_use == 'crop_annual':
                self.land_use = random.choice(['crop_perennial'])
            elif self.land_use == 'crop_perennial':
                self.land_use = random.choice(['crop_perennial','native_forest'])
            elif self.land_use == 'intensive_pasture':
                self.land_use = random.choice(['crop_perennial','crop_annual'])
            elif self.land_use == 'extensive_pasture':
                self.land_use = random.choice(['extensive_pasture','native_forest','exotic_forest'])
            elif self.land_use == 'exotic_forest':
                self.land_use = random.choice(['exotic_forest','native_forest','extensive_pasture'])
            else:
                pass

        else:
            raise Exception(f'Invalid: {behaviour=}')
