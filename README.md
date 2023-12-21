# agent_template
An agent based model of land using implemented in Netlogo and Python Mesa.

## `netlogo/`
The netlogo land-use model.

## `example.py`
An example python script that builds and runs a model, and produce some output. Requires conda or python environments according to one of
```
environment/run_in_conda_environment.bash python example.py
environment/run_in_python_environment.bash python example.py
```

For solara visualisation run

```environment/run_in_solara.sh example.py```

This depends on the python environment.

## `example_config.yaml`
Example model configuration file.

## `agent_template/`
The python code defining the model.  Uses the [mesa](https://mesa.readthedocs.io/) library.

## `environment/`

Three possible ways to create an environment in which the model will run.

 - conda environment: Works for all visualisations.
 - python environment: Only dependency is python. Does not work for `window` visualisation.
 - docker environment: Not really implemented
 
Scripts to build environments and run commands inside environments are included, and depend on bash.

## `experiments/`

### `netlogo/`
A trial model using Netlogo

### `julia/`
A trial model using Julia.

### `jupyterlab/`
Test code to plot on Jupyter lab. Run `jupyter lab` first in an appropriate environment first.

### `solara/`
Test code to plot in a browser with solara.  Run with e.g., `solara run test.py` in an appropriate environment.

## `docs/`
Some background information.

