# agent_template
An agent based model of land using implemented in Netlogo and Python Mesa.

## Netlogo version (`netlogo/`)
The Netlogo land-use model is contained in the file `netlogo/ABM4CSL.nlogo`.

## Python version
### Software environment (`environment/`)

The necessary software to run the model is installed in either a python or conda environment by running one of the scripts `build_conda_environment.bash` or `build_python_environment.bash`.

Then to run the model in a conda or python environment use one of the commands `run_in_conda_environment.bash python example.py` or `run_in_python_environment.bash python example.py`.

The only dependency of the Python environment is a Python itself. The conda environment requires a an installed version of [`micromamba`](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)

### Example model script (`example.py`)
An example python script that builds and runs a model, and produce some output. This describes the how a model is run and visualised, and could be merged into agent_template one day.

### Example model configuration (`example_config.yaml`)
Example model configuration file that is read by example.py. This might contain all configurable parameters the model has.

### The model code (`agent_template/`)
The python code defining the model.  Uses the [mesa](https://mesa.readthedocs.io/) library.

### Visualisation


For solara visualisation run

```environment/run_in_solara.sh example.py```

This depends on the python environment.

To X11 plots it is necessary to use the conda environment



## Experimental stuff (`experiments/`)
### `netlogo/`
A trial model using Netlogo

### `julia/`
A trial model using Julia.

### `jupyterlab/`
Test code to plot on Jupyter lab. Run `jupyter lab` first in an appropriate environment first.

### `solara/`
Test code to plot in a browser with solara.  Run with e.g., `solara run test.py` in an appropriate environment.


## Background information (`docs/`)
Some background information.

