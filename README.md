# agent_template
An agent based model of land using implemented in Netlogo and Python Mesa.

## Netlogo version (`netlogo/`)
The Netlogo land-use model is contained in the file `netlogo/ABM4CSL.nlogo`.

## Python version
### Software environment (`environment/`)

The dependencies this project are listed in `requirements.txt` and can be installed into a Python virtual environment with `run.bash` (Linux) or `run.bat` (Windows).  This requires an existing Python >3.10 installation.  The `agent_template` is also installed into the virtual environment in editable mode. To reinstall the virtual environment first delete the `.env` subdirectory.

The same scripts also run model defined by a configuration file, e.g., `./run.bash test/test_config.yaml`.  A `-d` flag runs in the Python debugger.  Additional arguments overload configuration variables, e.g., `./run.bash test/test_config.yaml plot=png`.

### Test and example configuration
The test subdirectory contains an example configuration file with annotated variables and data needed for testing the module.

### The model code (`agent_template/`)
The python code defining the model.  Uses the [mesa](https://mesa.readthedocs.io/) library.

### Visualisation

The visualisation of model output is controlled by the `plot` option in the model configuration YAML file. 

 - `pdf`: Save to file in output directory.
 - `window`: Open a graphical window. Depends on the conda enviroment (for pyqt).
 - `jupypterlab`: Run in Jupyterlab for an interactive visualisation. Not currently implemented.
 - `solara`: Opens a graphical visualisation in a web browser. Run model with e.g., `run_in_conda_environment.bash solara run example.py`

## Experimental stuff (`experiments/`)
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

## Background information (`docs/`)
Some background information.

