# agent_template #

Agent based model of land using using Python library mesa.

## Subdirectories ##

### agent_template/ ###

The python code defining the model.

### test/ ###

Contains an example python script that build and run a model, and produce some output.

### environment/ ###

Three different ways to create an environment in which the model will run.

#### Conda environment ####

This requires an existing installation of `micromamba`.
There is a script to generate the environment

`./environment/create_conda_environment.bash`

and run the test example

`./environment/run_in_conda_environment.bash test/example.py`

#### Python virtual environment ####

This requires an existing `python` installation.
Scripts:

`./environment/create_python_environment.bash`

`./environment/run_in_python_environment.bash test/example.py`

#### Docker container ####

This requires an existing installation of `docker` or `docker desktop`.
Scripts:

`./environment/create_docker_container.bash`

`./environment/run_in_python_environment.bash test/example.py`
