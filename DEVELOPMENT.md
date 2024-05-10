# Development 
## Netlogo code and data files (`netlogo/`) 
The Netlogo land-use model is contained in the file `netlogo/ABM4CSL.nlogo` and accompanying `*.nls` files.
It was built and tested using [NetLogo](https://ccl.northwestern.edu/netlogo/) version 6.4.


## Testing (`netlogo/test/`)
The `test/` subdirectory contains test data and experiments.

To run some BehaviourSpace tests execute `experiments/run.bash test_name` where `test_name` is an experiment defined in `experiments/tests.xml`.

## Version labels 
Version labels are tagged v#.#.#.
Which label to increment when changing the model is a bit arbitrary but roughly corresponds to the following.

 - The major-version number will change when the intention or underlying structure of
 the model is altered.

 - The minor-version number will change when a model rule or data structure is modified and affects the structure of the model output.

 - The point-release is updated when a change fixes a bug, alters the user interface, or changes an internal parameter value.
 
In all cases detailed model output may change.

## Branching strategy
In development changes are stored in the `dev` branch, or temporary special-purpose feature branches, and merged into `main` when feature-complete and tested.

Project specific changes should be developed in separate `project-*` branches and be documented internally (perhaps with a `PROJECT.md` file).
When a project is concluded the final commit should be tagged, and the branch deleted.

## Development experiments (`dev/`)
### Background documents (`docs/`)
Some background information.

### `python/` 

Python version in development

#### Installation 

 - The only system dependency is a Python >3.10 installation
 - Download or clone the [Github repository](https://github.com/manaakiwhenua/agent_template).
 - Create the python virtual environment with the command `./run.bash` in a Linux terminal or `run.bat` at a Windows command prompt.
 - To recreate the environment the directory `.env` must first be deleted
 - The Python module `agent_template` is also installed into the virtual environment in editable mode.

#### Running a model 
 
 - On Linux or Windows, respectively run, e.g., `./run.bash test/test_config.yaml` and `run.bat test/test_config.yaml'.
 - Use `run.* -d *.yaml` flag to run within the Python debugger.
 - Set additional trailing arguments overload configuration variables, e.g., `./run.bash test/test_config.yaml plot=png`.

##### Visualisation 

The visualisation of model output is controlled by the `plot` option in the model configuration YAML file. 

 - `pdf`: Save to file in output directory.
 - `window`: Open a graphical window.
 - `jupypterlab`: NOT IMPLEMENTED: Run in Jupyterlab for an interactive visualisation. 
 - `solara`: Opens an interactive visualisation in a web browser. 

#### Test and example configuration 
The test subdirectory contains an example configuration file with annotated variables and data needed for testing the module.

#### The model code (`agent_template/`) 
The python code defining the model.  Uses the [mesa](https://mesa.readthedocs.io/) library.



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

    


