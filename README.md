# agent_template
An agent-based model of land use.


## Model reference

The model describes a square grid of land patches.
Each patch is owned by a farmer who periodically revises its land use. 
This decisions is influenced by the farmer's character, the present land use, other farmers and patches, external government and environmental factors, and some random selection.
Time is progressed in annual intervals.

Each grid patch is linked to a unique farmer and has up to 8 neighbours (fewer if adjacent to a boundary).
Farmers and patches are fully defined by a set of static variables, defined at set up, and further dynamically-evolving variables.

### Model variables
#### Global variables

These static variables control the model overall

| Variable name                | Description                                         | Valid values   |
|------------------------------|-----------------------------------------------------|----------------|
| world-size                   | Edge length of grid                                 | Integer ($>0$) |
| steps-to-run-before-stopping | Every "go" button runs this many stpes              | Integer ($>0$) |
| decision-interval            | Number of time steps before farmers revise land use | Integer ($>0$) |
| number-of-landuse-networks   | How many networks farmers are divided into          | Integer ($>0$) |
| gis-raster-filename          | Path to a raster layer file                         | String               |
| gis-vector-filename          | Path to a raster layer file                         | String               |

#### Land use parameters

These variables define everything about possible land uses.
Their values are fixed for the duration of the model.
Their initial values are set to a selection of presets, can be entered manually, or loaded from a CSV file.


| Variable name                | Description                                                     | Valid values     |
|------------------------------|-----------------------------------------------------------------|------------------|
| landuse-code                 | Code                                                            | Integer  ($1-9$) |
| landuse-name                 | Readable name                                                   | String           |
| landuse-color                | Color for plotting                                              | Integer          |
| landuse-crop-yield           | Annual production (t/ha/a)                                      | Real             |
| landuse-livestock-yield      | Annual production (t/ha/a)                                      | Real             |
| landuse-CO2eq                | Annual carbon-equivalent emissions (t/ha/a)                     | Real             |
| landuse-carbon-stock-rate    | Annual carbon (t/ha/a)                                          | Real             |
| landuse-carbon-stock-maximum | Maximum storable carbon (t/ha)                                  | Real             |
| landuse-weight               | Relative probability of initialising a patch with this land use | Real             |

#### Patch variables

These dynamic variables are computed for each land patch and change with time.

| Variable name   | Description                                               | Valid values          |
|-----------------|-----------------------------------------------------------|-----------------------|
| LU              | Land use code                                             | Integer ($1-9$)       |
| CO2eq           | Annual carbon-equivalent emissions (t/ha)                 | Real                  |
| value$          | Annual profit (NZD)                                       | Real                  |
| landuse-age     | Number of ticks since the current land use was initiated  | Integer ($>0$)        |
| crop-yield      | Production yield cropping-based land use (t/ha)           | Real ($>0$)           |
| livestock-yield | Production yield livestock-based land use (t/ha)          | Real ($>0$)           |
| carbon-stock    | Currently stored carbon (t/ha)                            | Real ($>0$)           |
| pollinated      | Whether or pollination is supported                       | Integer (0=no, 1=yes) |
| bird-suitable   | Whether or not bird life is supported                     | Integer (0=no, 1=yes) |

#### Farmer variables


These static variables define each farmer uniquely

| Variable name    | Description                    | Valid values    |
|------------------|--------------------------------|-----------------|
| behaviour        | Farmer behaviour category type | Integer ($1-3$) |


##### Farmer behaviour category

The decisions made by farmers are influence by their behaviour category.

| Category code | Description                            |
|---------------|----------------------------------------|
| 1             | Business-as-usual  (BAU)               |
| 2             | Industry focused (industry)         |
| 3             | Climate and environment conscious (CC) |

### Decision making
Farmers re-evaluate how they use their land every `decision-interval` time steps.


### Interface controls

#### Model

Main buttons
 - `setup`: Set dynamic variables to initial values.
 - `go`: Run the model for `steps-to-run-before-stopping` time steps.
 - `step`: Run the model for `steps-to-run-before-stopping` time steps.
 - `replot`: Update the plot if `map-color` or `map-layer` have been chnaged

To run the model with identical random choices each time set `fixed-seed` to on and choose a `seed`.

#### Farmers
The random attitude waits `BAU-weight`, `industry-weight`, and `CC-weight` can be set here along with how often farmers make land use revisions, and how many networks the farmers are divided into.

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

