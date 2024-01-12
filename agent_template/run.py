## defines what is imported along with this module

## python standard library
import random
import sys

# ## python external libraries
from mesa.experimental import JupyterViz
from omegaconf import OmegaConf

# ## this project
from .farmer import Farmer
from .networks import LandUseNetwork
from .landusemodel import LandUseModel
from . import run

## used below

def main():
    """Initialise, run, and visualise a model defined by a YAML
    configuration file. Solara visualisation works differently to
    other methods."""

    config_file = get_command_line_config_file()
    config = load_configuration(config_file)

    ## jupyterlab interactive visualisation
    if config['plot'] == 'jupyterlab':
        raise Exception(f"visualisation 'jupyterlab' is not implemented")

    ## solara web page, requires vai `solara run` rather than `python`
    elif config['plot'] == 'solara':
        run_solara_in_subprocess(config_file)

    ## X11 window or pdf output
    else:
        model = initialise_model(config)
        step_model(model)
        data = collect_data(model)
        model.make_visualisation()


def get_command_line_config_file(position=1):
    ## load config file path from first command line argument
    if len(sys.argv) < position+1:
        raise Exception('usage: python -m agent_template config.yaml')
    config_file =  sys.argv.pop(position)
    return config_file
    
def load_configuration(config_file):
    """Load configuration from given file, and then overload with
    command line arguments. Returns a dictionary rather than an omega
    conf object."""
    ## load config file
    config_from_file = OmegaConf.load(config_file)
    ## load command line configuration
    config_from_command_line = OmegaConf.from_cli()
    ## compose configuration
    config = OmegaConf.to_container(config_from_file) | OmegaConf.to_container(config_from_command_line)
    return config

def initialise_model(config):
    random.seed(config['random_seed'])
    model = LandUseModel(**config)
    return model

def step_model(model):
    for step in range(model.config['steps_to_run']):
        model.step()

def collect_data(model):
    data = model.get_data()
    return data

def run_solara_in_subprocess(config_file):
    """Solara visualisation requires running the model with the
    `solara run model.py` system call.  This function creates a
    temporary `model.py` and makes the call. Then exits."""
    import tempfile
    import subprocess
    with tempfile.NamedTemporaryFile(suffix='.py') as tmp:
        tmp.write(bytes(
            '\n'.join(['from agent_template import *',
                       f'config = run.load_configuration({config_file!r})',
                       'page = run._run_solara(config)',]), encoding='utf8'))
        tmp.seek(0)
        status,output = subprocess.getstatusoutput(f'solara run "{tmp.name}"')
        print(output)
        sys.exit(status)

def _run_solara(config):
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
