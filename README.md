# agent_template – An agent-based model of land use.

## Overview

The model describes a square grid of land patches.
Each patch is owned by a farmer who periodically revises its land use. 
This decision is influenced by the farmer's character, the present land use, other farmers and patches, external government and environmental factors, and some random selection.
Time is progressed in annual intervals.
The economic and environmental consequences of the evolving land use choices are computed tracked.,

The model is configured and run in a Netlogo graphical interface.

## Installation
## User guide
### Model setup

The `world-size` slider controls the edge-length of the model grid.
Each grid patch is linked to a unique farmer and has up to 8 neighbours (fewer if adjacent to a boundary).
Farmers and patches are fully defined by a set of static variables and further dynamically-evolving variables are computed from the current and historical land use choices.

The `setup` button complete initialisation of the model and can be used to reinitialise the model anytime. 

To setup and run the model making identical random choices each time set `fixed-seed` to "on" and choose a `seed`.

#### Farmer setup

Farmers periodically revise the land use of their patch every `decision-interval` years.

At setup each farmer is randomly assigned an "attitude" that influence decision rules, either business-as-usual, industry focused, or climate and environment conscious.
The assignment probability of these categories are weighted by values set in the `BAU-weight`, `industry-weight`, and  `CC-weight` controls, respectively.

Farmers are randomly assigned to a farmer-network whose collective land use influences their decision making. 
The `number-of-landuse-networks` is controllable in the model interface.

#### Land use setup

The following variables define the properties of each [land use category](#land-use-categories).

| Variable name        | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| weight               | Relative probability of initialising a patch with this land use |
| crop-yield           | Annual production (t/ha/a)                                      |
| livestock-yield      | Annual production (t/ha/a)                                      |
| CO2eq                | Annual carbon-equivalent emissions (t/ha/a)                     |
| carbon-stock-rate    | Annual carbon (t/ha/a)                                          |
| carbon-stock-maximum | Maximum storable carbon (t/ha)                                  |

Their values are fixed for the duration of the model.
Their initial values are controlled with `landuse-parameter-source` selector, and chosen from a selection [presets](#land use presets), can be entered manually in the "current land use and manual entry" boxes, or loaded from a [CSV file](#land use csv file format) with path entered in the `landuse-data-csv-filename` box.

Each patch is assigned an initial land use at setup.
The assignment method is set by the `initial-landuse-source` selector.

A "random" land use source selects a land use respecting their weights. If `landuse-correlated-range` is greater than 1, then square blocks of patches are assigned the same land use.

A "gis-vector" or "gis-raster" land use sources the initial land use from external data files (see [External land use layers](#external-land-use-layers))

The time for which the present land use has been in place is tracked for each patch, and assigned a random number value on setup that falls between 0 and the value of `decision-interval`.
Then, farmers will not simultaneously revise their decisions in any one year when the model is run.
    
#### Rule setup

The "Agent rules" section of the interface allows for toggling the activity of decision-making rules, with their definitions documented in [agent rules](#agent-rules).

### Running the model

The `go` button runs the model for a number of years controlled by the `years-to-run-before-stopping` slider, and `go once` will integrate the model one year.
The `setup` button resets the model anytime.

#### The world map

The world map tracks the current state of the model, with displayed data set with the `map-color` and `map-label` selectors.
The `replot` button will update this plot if `map-color` or `map-layer`, otherwise the plot is updated every model step.

The plotting options are defined in [computed quantities](#computed-quantities)

| Selection     | Description                                                    |
|---------------|----------------------------------------------------------------|
| land use      | Current land use (a legend is present in the world statistics) |
| land value    | Annual profit                                                  |
| land use age  | Time since conversion to this land use                         |
| network       | Distribution of farmer networks                                |
| carbon stock  | Stored carbon                                                  |
| emissions     | Annual CO₂-equivalent emissions                                |
| bird suitable | Bird-suitability index                                         |
| pollinated    | Pollination index                                              |


#### World statistics

The world statistics section graphs the time dependence of world-averaged quantities.

| Statistic                                   | Description                                  |
|---------------------------------------------|----------------------------------------------|
| Total land use                              | Frequency of each land use category          |
| Total value                                 | Summed annual profit                         |
| Total livestock yield                       | Summed livestock production (t/ha?)          |
| Total crop yield                            | Summed crop production (t/ha?)               |
| Total emissions                             | Summed CO₂-equivalent emissions              |
| Carbon stock                                | Summed carbon stock (t/ha?)                  |
| [Contiguity index](#contiguity)             | Overall similarity of nearby land use        |
| [Diversity index](#diversity)               | Shannon index of diversity                   |
| [Pollination index](#pollination)           | Fraction of pollination-contributing patches |
| [Bird suitability index](#bird-suitability) | Fraction of bird-suitable patches            |

## Model reference

### Land use categories
### External land use layers
### Agent rules
#### Land use presets
#### Land use CSV file format

| Variable name                | Description                                                     | Valid values     |
|------------------------------|-----------------------------------------------------------------|------------------|
| landuse-code                 | Code                                                            | Integer  (1-9) |
| landuse-name                 | Readable name                                                   | String           |
| landuse-color                | Color for plotting                                              | Integer          |
| landuse-crop-yield           | Annual production (t/ha/a)                                      | Real             |
| landuse-livestock-yield      | Annual production (t/ha/a)                                      | Real             |
| landuse-CO2eq                | Annual carbon-equivalent emissions (t/ha/a)                     | Real             |
| landuse-carbon-stock-rate    | Annual carbon (t/ha/a)                                          | Real             |
| landuse-carbon-stock-maximum | Maximum storable carbon (t/ha)                                  | Real             |
| landuse-weight               | Relative probability of initialising a patch with this land use | Real             |

### Computed quantities
#### Contiguity
#### Diversity
#### Pollination
#### Bird suitability
### Model variables
#### Global variables

These static variables control the model overall

| Variable name                | Description                                         | Valid values   |
|------------------------------|-----------------------------------------------------|----------------|
| world-size                   | Edge-length of grid                                 | Integer (>0) |
| steps-to-run-before-stopping | Every "go" button runs this many stpes              | Integer (>0) |
| decision-interval            | Number of time steps before farmers revise land use | Integer (>0) |
| number-of-landuse-networks   | How many networks farmers are divided into          | Integer (>0) |
| gis-raster-filename          | Path to a raster layer file                         | String               |
| gis-vector-filename          | Path to a raster layer file                         | String               |


#### Patch variables

These dynamic variables are computed for each land patch and change with time.

| Variable name   | Description                                               | Valid values          |
|-----------------|-----------------------------------------------------------|-----------------------|
| LU              | Land use code                                             | Integer (1-9)       |
| CO2eq           | Annual carbon-equivalent emissions (t/ha)                 | Real                  |
| value          | Annual profit (NZD)                                       | Real                  |
| landuse-age     | Number of ticks since the current land use was initiated  | Integer (>0)        |
| crop-yield      | Production yield cropping-based land use (t/ha)           | Real (>0)           |
| livestock-yield | Production yield livestock-based land use (t/ha)          | Real (>0)           |
| carbon-stock    | Currently stored carbon (t/ha)                            | Real (>0)           |
| pollinated      | Whether or pollination is supported                       | Integer (0=no, 1=yes) |
| bird-suitable   | Whether or not bird life is supported                     | Integer (0=no, 1=yes) |

#### Farmer variables


These static variables define each farmer uniquely

| Variable name | Description                    | Valid values  |
|---------------|--------------------------------|---------------|
| behaviour     | Farmer behaviour category type | Integer (1-3) |
|               |                                |               |





### Rules
#### Baseline rule
#### Baseline rule
### Interface controls

### Background documents (`docs/`)
Some background information.

    

## Development
### Netlogo version (`netlogo/`)
The Netlogo land-use model is contained in the file `netlogo/ABM4CSL.nlogo`.
It was built and tested using [NetLogo](https://ccl.northwestern.edu/netlogo/) version 6.4.


### Python version (`python/`)

In development

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


### Experimental (`experiments/`)
#### `netlogo/`
A trial model using Netlogo

#### `julia/`
A trial model using Julia.

#### `jupyterlab/`
Test code to plot on Jupyter lab. Run `jupyter lab` first in an appropriate environment first.

#### `solara/`
Test code to plot in a browser with solara.  Run with e.g., `solara run test.py` in an appropriate environment.

##
### `environment/`
Conda and docker environments.

