# agent_template – An agent-based model of land use.
## Overview

The model describes a square grid of land patches.
Each patch is owned by a farmer who periodically revises its land use. 
This decision is influenced by the farmer's character, the present land use, other farmers and patches, external government and environmental factors, and some random selection.
Time is progressed in annual intervals.
The economic and environmental consequences of the evolving land use choices are tracked.

The model is configured and run in a Netlogo graphical interface.

## Installation

The only file from this repository needed to run the model is `netlogo/ABM4CSL.nlogo`.
The NetLogo interpreter and graphical interface can be [downloaded from here](https://ccl.northwestern.edu/netlogo/).
Version 6.4 was used to develop and test this model.

After installing and starting the NetLogo application, `ABM4CSL.nlogo` can be opened from the "File" menu.

Further example files in the repository, in `netlogo/gis_data` and `netlogo/land_use_parameters`, enable initialising some model data from external data sets.

## User guide

### Model setup

The `world-size` slider controls the edge-length of the model grid.
Each grid patch is linked to a unique farmer and has up to 8 neighbours (fewer if adjacent to a boundary).
Farmers and patches are fully defined by a set of static variables and further dynamically-evolving variables are computed from the current and historical land use choices.

The `setup` button completes initialisation of the model and can be used to reinitialise the model anytime. 

To setup and run the model making identical random choices each time set `fixed-seed` to "on" and choose a `seed`.

#### Farmer setup

Farmers periodically revise the land use of their patch every `decision-interval` years.

At setup, each farmer is randomly assigned an "attitude" that influences [decision rules](#agent-rules):

| Attitude                             | Description                          |
|--------------------------------------|--------------------------------------|
| business-as-usual (BAU)              | Less likely to make a change         |
| industry focused (industry)          | More likely to pursue profit         |
| climate / environment conscious (CC) | More likely to pursue sustainability |

The probability of being assign to each of these categories are weighted by the  `BAU-weight`, `industry-weight`, and  `CC-weight` controls.

Farmers are randomly assigned to a farmer-network whose collective land use influences their decision making if the [network rule](#network-rule) is active. 
The `number-of-landuse-networks` is controllable in the model interface.

#### Land use categories

The defined land use categories and their internal codes are:

| Code | Name              | Description          |
|------|-------------------|----------------------|
| 1    | artificial        | Non-agricultural use |
| 2    | water             | Water                |
| 3    | crop annual       | **???**              |
| 4    | crop perennial    | **???**              |
| 5    | scrub             | **???**              |
| 6    | intensive pasture | **???**              |
| 7    | extensive pasture | **???**              |
| 8    | native forest     | **???***             |
| 9    | exotic forest     | **???**              |

The following parameters define the properties of each land use category.

| Variable name        | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| weight               | Relative probability of initialising a patch with this land use |
| crop-yield           | Annual production of plant products (t/ha/a)                    |
| livestock-yield      | Annual production of animal products (t/ha/a)                   |
| CO2eq                | Annual CO₂-equivalent carbon emissions (t/ha/a)                 |
| carbon-stock-rate    | Annual CO₂-equivalent carboncapture (t/ha/a)                    |
| carbon-stock-maximum | Maximum storable CO₂-equivalent carbon (t/ha)                   |

Their values are fixed for the duration of the model, and have initial values controlled by the `landuse-parameter-source` selector, with options:

| Option       | Description                                                         |
|--------------|---------------------------------------------------------------------|
| manual entry | Use parameters set in the "current land use and manual entry" boxes |
| csv file     | Loads data from the CSV given by `landuse-data-csv-filename`        |
| preset:\*    | Select a set of internally coded parameters                         |

The CSV-parsing code is very fragile and the loaded table must match the structure given in the example file: `netlogo/land_use_parameters/test.csv`.

#### Land use setup

Each patch is assigned an initial land use at setup.
The assignment method is set by the `initial-landuse-source` selector, with options:

| Option     | Description                                                                                |
|------------|--------------------------------------------------------------------------------------------|
| random     | Selects a land randomly use respecting their configured weights                            |
| gis-raster | Load land use from an ESRI ASCII Grid file, with path set in the `gis-raster-filename` box |
| gis-vector | Load land use from an ESRI shapefile, with path set in the `gis-vector-filename` box       |

If a random land use is used and the value of `landuse-correlated-range` is greater than 1 then square blocks of patches are assigned the same land use. 

External raster and vector data must consist of a single layer with integer values from 1 to 9, encoding land use category.

The duration of the presently assigned land is tracked for each patch and assigned an initially-random number value falling between 0 and the value of `decision-interval`.
Then, farmers will not simultaneously revise their decisions in any one year.
    
#### Rule setup

The "Agent rules" section of the interface allows for toggling the activity of decision-making rules.

| Rule             | Description                                                                       |
|------------------|-----------------------------------------------------------------------------------|
| Baseline         | Mostly influenced by a farmers attitude and current land use                      |
| Neighbourhood    | Incentivises conformity with the dominant land use choice of immediate neighbours |
| Network          | Incentivises conformity with the dominant land use within a farmer network        |
| Industry level   | Incentivises land use choices to maximise global prosperity                       |
| Government level | Incentivises land use choices to maximise environmental sustainability            |

Detailed definitions of these rules and how they are combined into farmer decisions are in [Rules](#Rules).

### Running the model

The `go` button runs the model for a number of years controlled by the `years-to-run-before-stopping` slider, and `go once` will integrate the model one year.
The `setup` button resets the model anytime.

#### The world map

The world map tracks the current state of the model. 
It shows data corresponding to the `map-color` and `map-label` selectors.
The `replot` button will update this plot if `map-color` or `map-layer` are changed, otherwise the plot is updated every model step.

| Option        | Description                                                    |
|---------------|----------------------------------------------------------------|
| land use      | Current land use (a legend is present in the world statistics) |
| land value    | Annual profit                                                  |
| land use age  | Time since conversion to this land use                         |
| network       | Distribution of farmer networks                                |
| carbon stock  | Stored carbon                                                  |
| emissions     | Annual CO₂-equivalent carbon emissions                         |
| bird suitable | Bird-suitability index                                         |
| pollinated    | Pollination index                                              |

These quantities are described in detail in [computed quantities](#computed-quantities).

#### World statistics

The world statistics section displays the time dependence of world-averaged quantities.

| Statistic                                   | Description                                  |
|---------------------------------------------|----------------------------------------------|
| Total land use                              | Frequency of each land use category          |
| Total value                                 | Summed annual profit                         |
| Total livestock yield                       | Summed livestock production                  |
| Total crop yield                            | Summed crop production                       |
| Total emissions                             | Summed CO₂-equivalent carbon emissions       |
| Carbon stock                                | Summed stored CO₂-equivalent carbon          |
| [Contiguity index](#contiguity)             | Overall similarity of nearby land use        |
| [Diversity index](#diversity)               | Shannon index of diversity                   |
| [Pollination index](#pollination)           | Fraction of pollination-contributing patches |
| [Bird suitability index](#bird-suitability) | Fraction of bird-suitable patches            |

The definitions of these are given in more detail in [computed quantities](#computed-quantities).

## Model reference
### Rules
#### Combining rules
#### Baseline rule
#### Neighbour rule
#### Network rule
#### Industry rule
#### Government rule
### Computed quantities
#### Carbon emissions (`CO2eq`)
Annual carbon-equivalent emissions (t/ha)
Real
#### Value
Annual profit (NZD)
Real
#### Crop yield
Production yield cropping-based land use (t/ha)
Real (>0)
#### Livestock yield
Production yield livestock-based land use (t/ha)
Real (>0)
#### Stored carbon
Currently stored carbon (t/ha)
Real (>0)
#### Pollination index
Whether or pollination is supported
Integer (0=no, 1=yes)
#### Bird-suitability index

Whether or not bird life is supported
Integer (0=no, 1=yes)

#### Contiguity index
#### Diversity index
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


### Background documents (`docs/`)
Some background information.
### Experimental (`experiments/`)
#### `netlogo/`
A trial model using Netlogo

#### `julia/`
A trial model using Julia.

#### `jupyterlab/`
Test code to plot on Jupyter lab. Run `jupyter lab` first in an appropriate environment first.

#### `solara/`
Test code to plot in a browser with solara.  Run with e.g., `solara run test.py` in an appropriate environment.

#### `environment/`
Conda and docker environments.

    

