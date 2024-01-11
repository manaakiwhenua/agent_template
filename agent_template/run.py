## defines what is imported along with this module

## python standard library
import random
import sys

# ## python external libraries
from mesa.experimental import JupyterViz
import matplotlib.pyplot as plt
import matplotlib as mpl
from omegaconf import OmegaConf

# ## this project
from .farmer import Farmer
from .networks import LandUseNetwork
from .landusemodel import LandUseModel
from . import run

## used below
static_visualisation_filetypes = ('png','pdf','jpg','jpeg','tiff','svg')

def main():
    """Initialise, run, and visualise a model defined by a YAML
    configuration file. Solara visualisation works differently to
    other methods."""

    config_file = get_command_line_config_file()
    config = load_configuration(config_file)

    ## X11 window or pdf output
    if config['visualisation'] in ['window',*static_visualisation_filetypes]:
        model = initialise_model(config)
        step_model(config,model)
        data = collect_data(model)
        make_visualisation(config,model,data)

    ## jupyterlab interactive visualisation
    elif config['visualisation'] == 'jupyterlab':
        raise Exception(f"visualisation {config['visualisation']!r} is not implemented")

    ## solara web page, requires vai `solara run` rather than `python`
    elif config['visualisation'] == 'solara':
        # run_solara(config)
        run_solara_in_subprocess(config_file)
        
    else:
        assert False,'invalid visualisation'

def get_command_line_config_file(position=1):
    ## load config file path from first command line argument
    if len(sys.argv) < position+1:
        raise Exception('usage: python -m agent_template config.yaml')
    config_file =  sys.argv.pop(position)
    return config_file
    
def load_configuration(config_file):

    ## load config file
    config = OmegaConf.load(config_file)
    ## load command line configuration
    command_line_conf = OmegaConf.from_cli()
    ## compose configuration
    for key,val in command_line_conf.items():
        config[key] = val
    return config

def initialise_model(config):
    random.seed(config['random_seed'])
    model = LandUseModel(**config)
    return model

def step_model(config,model):
    for step in range(config['steps_to_run']):
        model.step()

def collect_data(model):
    data = model.get_data()
    return data

def make_visualisation(config,model,data):
    farmers_initial = data['farmer'][data['farmer']['step']==1]

    ## plot initial land use as coloured patches
    if config['visualisation'] == 'window':
        mpl.use('QtAgg')
    else:
        mpl.use('Agg')
    mpl.rcParams |= {'figure.figsize':(5,5),
        'figure.subplot.bottom': 0.2,
        'figure.subplot.top': 0.95,
        'figure.subplot.left': 0.05,
        'figure.subplot.right': 0.95,
        'font.family': 'sans',}
    fig = mpl.pyplot.figure()
    ax = fig.gca()
    for i,agent in farmers_initial.iterrows():
        ax.add_patch(mpl.patches.Rectangle(
            (agent['x_coord'],agent['y_coord']), 1,1,
            color=model.config['land_use'][agent['land_use']]['color'],))
    # ax.set_xlim(0,model.grid_length)
    # ax.set_ylim(0,model.grid_length)
    ax.xaxis.set_ticks([])
    ax.yaxis.set_ticks([])
    for data in model.config['land_use'].values():
        ax.plot([],[],color=data['color'],label=data['label'])
    ax.legend(ncol=3,frameon=False,loc=(0,-0.2),fontsize='small')

    ## output visualisation
    if config['visualisation'] == 'window': 
        plt.show()
    elif config['visualisation'] in static_visualisation_filetypes:
        ## static file
        filename = config["output_directory"]+'/land_use.'+config['visualisation']
        print(f'Saving file: {filename!r}')
        fig.savefig(filename)
    else:
        pass

def run_solara_in_subprocess(config_file):
    """Solara visualisation requires runnign the model with the
    `solara run model.py` system call.  This function creates a
    temporary `model.py` and makes the call. Then exits."""
    import tempfile
    import subprocess
    with tempfile.NamedTemporaryFile(suffix='.py') as tmp:
        tmp.write(bytes(
            '\n'.join(['from agent_template import *',
                       f'config = run.load_configuration({config_file!r})',
                       'page = run.run_solara(config)',]), encoding='utf8'))
        tmp.seek(0)
        status,output = subprocess.getstatusoutput(f'solara run "{tmp.name}"')
        print(output)
        sys.exit(status)

def run_solara(config):
    """Use Solara to generate and run an interactive model."""
    ## define model
    model_params = dict(config)
    model_params |= {
        "grid_length": {
           "type": "SliderInt",
            "value": 10,
            "label": "Grid length:",
            "min": 5,
            "max": 100,
            "step": 5,
        },
        # "width": 10,
        # "height": 10,
    }
    ## define how the agents are drawn
    def agent_portrayal(agent):
        return {
            # "color": "tab:blue",
            "color": config['land_use'][agent.land_use]['color'],
            "size": 200,
        }
    ## start the interactive model
    page = JupyterViz(
        LandUseModel,
        model_params,
        measures=[],
        name="Land use model", 
        agent_portrayal=agent_portrayal,)
    ## page must be returned to top namespace
    return page
