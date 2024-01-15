## defines what is imported along with this module

## python standard library
import random
import sys
import os

# ## python external libraries
from mesa.experimental import JupyterViz
from omegaconf import OmegaConf

# ## this project
from .farmer import Farmer
from .networks import LandUseNetwork
from .landusemodel import LandUseModel
from . import run

## used below

def main(config_file=None):
    """Initialise, run, and visualise a model defined by a YAML
    configuration file. Solara visualisation works differently to
    other methods."""

    ## load configuration
    config,config_file = load_configuration(config_file)

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

def load_configuration(config_file=None):
    """Load configuration from given file, and then overload with
    command line arguments. Returns a dictionary rather than an omega
    conf object."""
    ## load config_file name from first command line argument if not provided as
    ## an argument to main
    if config_file is None:
        arg_position = 1
        if len(sys.argv) < arg_position + 1:
            raise Exception('No config_file provided. usage: python -m agent_template config.yaml')
        config_file =  sys.argv.pop(arg_position)
    ## config base directory, for relative internal paths
    abs_path_config_file = os.path.abspath(config_file)
    config_base_directory = os.path.dirname(abs_path_config_file)
    ## load config_file
    config_from_file = OmegaConf.load(config_file)
    ## load command line configuration
    config_from_command_line = OmegaConf.from_cli()
    ## compose configuration
    config = OmegaConf.to_container(config_from_file) | OmegaConf.to_container(config_from_command_line)
    config['base_directory'] = config_base_directory
    return config,config_file

def initialise_model(config):
    random.seed(config['random_seed'])
    model = LandUseModel(config)
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
    import subprocess
    import tempfile
    with tempfile.NamedTemporaryFile(suffix='.py') as tmp:
        tmp.write(bytes(
            '\n'.join([
                'from agent_template import *',
                f'config,config_file = run.load_configuration({config_file!r})',
                'page = run._run_solara(config)',
            ]), encoding='utf8'))
        tmp.seek(0)
        status,output = subprocess.getstatusoutput(f'solara run "{tmp.name}"')
        print(output)
        sys.exit(status)

    # tempfile = 'temporary_script_solara.py'
    # with open(tempfile,'w') as tmp:
        # tmp.write(
            # '\n'.join(['from agent_template import *',
                       # f'config = run.load_configuration({config_file!r})',
                       # 'page = run._run_solara(config)',]))
        # tmp.close()
    # status,output = subprocess.getstatusoutput(f'solara run "{tmp.name}"')
    # print(output)
    # sys.exit(status)

def _run_solara(config):
    """Use Solara to generate and run an interactive model."""
    ## define model
    model_params = dict(config=config)
    ## set user adjustable parameters, separate keys of nested config
    ## dictionaries with '__'
    if config['space']['type'] == 'grid':
        model_params |= {
            "space__x": {"type": "SliderInt", "label": "x grid length:",
                         "value": config['space']['x'], "min": 5, "max": 100, "step": 5,},
            "space__y": {"type": "SliderInt", "value": config['space']['x'], "label": "y grid length:",
                         "min": 5, "max": 100, "step": 5,},}

    ## define how the agents are drawn
    if config['space']['type'] == 'grid':
        def agent_portrayal(agent):
            return {"color": config['land_use'][agent.land_use]['color'],
                    "size": 200,}
    else:
        def agent_portrayal(agent):
            return {}
 
   ## start the interactive model
    page = JupyterViz(
        LandUseModel,
        model_params,
        measures=[],
        name="Land use model", 
        agent_portrayal=agent_portrayal,)
    ## page must be returned to top namespace
    return page
