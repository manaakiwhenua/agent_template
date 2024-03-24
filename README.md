# agent_template
An agent-based model of land use.

## Model reference

2024-03-25: This document is the reference specification of the NetLogo model.

The model describes a grid of land segments with hard external
boundaries.
Each grid point specifies two agents: a Farmer and the Land, fully defined by a set of static variables defined at start up,and evolving dynamic variables.

### Land static variables

----------------------
| *Var. name*       | *Description*                                                         | *Valid values* |
--------------------------------------------
| LU              | current land use                                                    |              |
| CO2eq           | Annual carbon-equivalent emissions (t/ha) of a patch                |              |
| value$          | Annual profit (NZD) of a patch                                      |              |
| landuse-age     | the number of ticks since this land use was initiated               |              |
| landuse-options | new land use options the farmer is somehow motivated to choose from |              |
| crop-yield      | t/ha                                                                |              |
| livestock-yield | t/ha                                                                |              |
| carbon-stock    | stored carbon, t/ha                                                 |              |
| pollinated      | if this patch contributes is pollinated                             |              |
| bird-suitable   | if this patch is suitable for birds                                 |              |
----------------------




### Background documents (`docs/`)
Some background information.


## Netlogo version (`netlogo/`)
The Netlogo land-use model is contained in the file `netlogo/ABM4CSL.nlogo`.
It was built and tested using [NetLogo](https://ccl.northwestern.edu/netlogo/) version 6.4.


## Python version (`python/`)

In development

### Installation

 - The only system dependency is a Python >3.10 installation
 - Download or clone the [Github repository](https://github.com/manaakiwhenua/agent_template).
 - Create the python virtual environment with the command `./run.bash` in a Linux terminal or `run.bat` at a Windows command prompt.
 - To recreate the environment the directory `.env` must first be deleted
 - The Python module `agent_template` is also installed into the virtual environment in editable mode.

### Running a model
 
 - On Linux or Windows, respectively run, e.g., `./run.bash test/test_config.yaml` and `run.bat test/test_config.yaml'.
 - Use `run.* -d *.yaml` flag to run within the Python debugger.
 - Set additional trailing arguments overload configuration variables, e.g., `./run.bash test/test_config.yaml plot=png`.

#### Visualisation

The visualisation of model output is controlled by the `plot` option in the model configuration YAML file. 

 - `pdf`: Save to file in output directory.
 - `window`: Open a graphical window.
 - `jupypterlab`: NOT IMPLEMENTED: Run in Jupyterlab for an interactive visualisation. 
 - `solara`: Opens an interactive visualisation in a web browser. 

### Test and example configuration
The test subdirectory contains an example configuration file with annotated variables and data needed for testing the module.

### The model code (`agent_template/`)
The python code defining the model.  Uses the [mesa](https://mesa.readthedocs.io/) library.


## Experimental (`experiments/`)
### `netlogo/`
A trial model using Netlogo

### `julia/`
A trial model using Julia.

### `jupyterlab/`
Test code to plot on Jupyter lab. Run `jupyter lab` first in an appropriate environment first.

### `solara/`
Test code to plot in a browser with solara.  Run with e.g., `solara run test.py` in an appropriate environment.

### `environment/`
Conda and docker environments.

