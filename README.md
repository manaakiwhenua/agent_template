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

The probability of being assigned to each of these categories are weighted by the  `BAU-weight`, `industry-weight`, and  `CC-weight` controls.

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
| carbon-stock-rate    | Annual CO₂-equivalent carbon capture (t/ha/a)                    |
| carbon-stock-maximum | Maximum storable CO₂-equivalent carbon (t/ha)                   |

Their values are fixed for the duration of the model, and have initial values controlled by the `landuse-parameter-source` selector, with options:

| Option       | Description                                                         |
|--------------|---------------------------------------------------------------------|
| manual entry | Use parameters set in the "current land use and manual entry" boxes |
| csv file     | Loads data from a CSV file specified by `landuse-data-csv-filename`        |
| preset:\*    | Select a set of internally coded parameters                         |

The CSV-parsing code is very fragile and the loaded table must match the structure given in the example file: `netlogo/land_use_parameters/test.csv`.

#### Land use setup

Each patch is assigned an initial land use at setup.
The assignment method is set by the `initial-landuse-source` selector, with options:

| Option     | Description                                                                                |
|------------|--------------------------------------------------------------------------------------------|
| random     | Selects a land use randomly while respecting their configured weights                            |
| gis-raster | Load land use from an ESRI ASCII Grid file, with path set in the `gis-raster-filename` box |
| gis-vector | Load land use from an ESRI shapefile, with path set in the `gis-vector-filename` box       |

If the value of `landuse-correlated-range` is greater than 1 and a random initialisation selected, then square blocks of patches are assigned the same land use.
If a random land use and a small number of patches or large correlated range are specified then the land use distribution may not closely match the expected weights.

External raster and vector data must consist of a single layer with integer values ranging over land use category codes.

The duration of the presently assigned land use is tracked for each patch. 
This is initialised with a random value between 0 and `decision-interval`.
Then, farmers will not simultaneously revise their decisions in any one year.

If an external raster layer is specified then it must be square and consist of integers matching the range of land use categories.
The `world-size` is automatically adjusted to match in the input layer.

If an external vector layer is specified then it must contain an integer field called "LANDUSE" ranging over land use category codes. 
Patches not within a polygon are assigned a "water" land use.

#### Rule setup

The "Agent rules" section of the interface allows for toggling the activity of decision-making rules.

| Rule             | Description                                                                       |
|------------------|-----------------------------------------------------------------------------------|
| Baseline         | Mostly influenced by a farmers attitude and current land use                      |
| Neighbourhood    | Incentivises conformity with the dominant land use choice of immediate neighbours |
| Network          | Incentivises conformity with the dominant land use within a farmer network        |
| Industry level   | Incentivises land use choices to maximise economic prosperity                       |
| Government level | Incentivises land use choices to maximise environmental sustainability            |

Detailed definitions of these rules and how they are combined into farmer decisions are in [Rules](#Rules).

### Running the model

The `go` button runs the model for a number of years controlled by  `years-to-run-before-stopping`, and `go once` will progress the model one year.
The `setup` button resets the model.

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
| [Contiguity index](#contiguity)             | Overall land-use similarity of nearby patches        |
| [Diversity index](#diversity)               | Shannon index of diversity                   |
| [Pollination index](#pollination)           | Fraction of pollination-contributing patches |
| [Bird suitability index](#bird-suitability) | Fraction of bird-suitable patches            |

The definitions of these are given in more detail in [computed quantities](#computed-quantities).

## Model reference
### Rules

#### Combining rules

On every model iteration, each farmer generates a list of land use options to select from.
When each activated rule is computed it adds to this list.
The generated list may contain repeats, the current land use, or be empty.
A new land use is randomly selected from this list if it is non-empty.
If the new land use matches the current value then no change is made.

#### Baseline rule

| Behaviour | Current land use | Action                                                                                                           |
|-----------|------------------|------------------------------------------------------------------------------------------------------------------|
| BAU       | 1                | Select a neighbour randomly, if their land use is one of 3, 4, 6, or 7 then append 1 to their land use options.  |
|           |                  |                                                                                                                  |
| Industry  | 1                | Select a neighbour randomly, if their land use is not 1 then append 1 to their land use options.                 |
|           | 3                | Add land use option randomly selected from 4 or 6.                                                               |
|           | 6                | Add land use option randomly selected from 3, 4, or 6.                                                           |
|           | 7                | Add land use option randomly selected from 7 or 9.                                                               |
|           | 9                | Add land use option randomly selected from 7 or 9.                                                               |
|           | 9                | Add land use option randomly selected from 7 or 9.                                                               |
|           |                  |                                                                                                                  |
| CC        | 3                | Add land use option 4.                                                                                           |
|           | 4                | Add land use option randomly selected from 4 or 8.                                                               |
|           | 6                | Add land use option randomly selected from 3 or 4.                                                               |
|           | 7                | Add land use option randomly selected from 7, 8, or 9.                                                           |
|           | 9                | Add land use option randomly selected from 7, 8, or 9.                                                           |

#### Neighbour rule

The modal land use is the most common land use among the 8 patches surrounding a farmer.
This ranking does not include the farmers own current land use.
If the farmer is near a world edge then fewer than 8 neighbours are present.

| Behaviour | Current land use    | Modal land use | Action                 |
|-----------|---------------------|----------------|------------------------|
| BAU       | 3, 4, 5, 6, 7, or 9 | 1              | Add land use option 1. |
|           |                     |                |                        |
| Industry  | not 1               | 1              | Add land use option 1. |
|           | 4, 5, 6, or 7       | 3              | Add land use option 3. |
|           | 3, 6, or 7          | 4              | Add land use option 4. |
|           | 3, 4, or 7          | 6              | Add land use option 6. |
|           | 3, 5, or 9          | 7              | Add land use option 7. |
|           | 3, 5, or 7          | 9              | Add land use option 9. |
|           |                     |                |                        |
| CC        | 6 or 7              | 3              | Add land use option 3. |
|           | 3, 6, or 7          | 4              | Add land use option 4. |
|           | 3 or 6              | 7              | Add land use option 7. |
|           | 7                   | 9              | Add land use option 9. |
|           | Not 8 and not 1     | 8              | Add land use option 8. |

#### Network rule

The modal land use is the most common land use among the network this farmer is a member of.
This ranking does include the farmers own current land use.

| Behaviour | Current land use    | Modal land use | Action                 |
|-----------|---------------------|-----------------------------------|------------------------|
| BAU       | 3, 4, 5, 6, 7, or 9 | 1                                 | Add land use option 1. |
|           |                     |                                   |                        |
| Industry  | not 1               | 1                                 | Add land use option 1. |
|           | 4, 5, 6, or 7       | 3                                 | Add land use option 3. |
|           | 3, 6, or 7          | 4                                 | Add land use option 4. |
|           | 3, 4, or 7          | 6                                 | Add land use option 6. |
|           | 3, 5, or 9          | 7                                 | Add land use option 7. |
|           | 3, 5, or 7          | 9                                 | Add land use option 9. |
|           |                     |                                   |                        |
| CC        | 6 or 7              | 3                                 | Add land use option 3. |
|           | 3, 6, or 7          | 4                                 | Add land use option 4. |
|           | 3 or 6              | 7                                 | Add land use option 7. |
|           | 7                   | 9                                 | Add land use option 9. |
|           | Not 8 and not 1     | 8                                 | Add land use option 8. |


#### Industry rule

If the total economic value has decreased in the last model iteration then perform the following actions.
 - Randomly select 5% of patches with current land use 3 and assign new land uses from a random selection of 4 or 6.
 - Randomly select 5% of patches with current land use 6 and assign a new land use of 4.
 - Randomly select 5% of patches with current land use 7 and assign new land uses from a random selection of 3, 4 or 6.

#### Government rule

If the total CO₂-equivalent carbon emissions has increased in the last model iteration then perform the following actions.
 - Randomly select 10% of patches with current land use 6 and assign new land uses from a random selection of 3 or 4.
 - Randomly select 10% of patches with current land use 7 and assign a new land use of 4.

### Computed patch quantities
#### Emissions
The CO₂-equivalent carbon emissions from this patch of the previous year (t/ha).
Taken directly from the land use parameter `CO2eq`.

#### Value
The economic value of outputs from this patch in the previous year (NZD).

| Land use | Value                     |
|----------|---------------------------|
| 1        | 300 000 (first year only) |
| 2        | 0                         |
| 3        | 450 × crop-yield          |
| 4        | 3500 × crop-yield         |
| 5        | 10 000 × livestock-yield  |
| 6        | 5500 × livestock-yield    |
| 7        | 0                         |
| 8        | 0                         |
| 9        | 45 000                     |


#### Crop yield
The crop yield of this patch in the previous year (t/ha).
Taken directly from the land use category parameter "crop-yield".

#### Livestock yield
The animal yield of the previous year (t/ha).
Taken directly from the land use category parameter "livestock-yield".

#### Carbon stock
The CO₂-equivalent carbon currently stored on this patch (t/ha). 
This is increased by every model iteration according to the land use category parameter `carbon-stock-rate` until it reaches a values of `carbon-stock-maximum`.

#### Pollinated 
For each patch, if the current land use is 3 or 4, and there is at least one neighbour within 4 grid spaces with land use 5 then this patch is considered pollinated and has an index value of 1.
Otherwise the index value is 0.

#### Bird suitable
For each patch, if the current land use is 4, 8, or 9, and there are at least 19 neighbours within 4 grid spaces also with land uses 4, 8, or 9 then this patch is considered bird-suitable and has an index value of 1.
Otherwise the index value is 0.

### Computed world quantities

#### Total value
Summed economic output of all patches for this year (NZD).

#### Total livestock yield
Summed livestock output of all patches for this year (t).

#### Total crop yield
Summed crop output of all patches for this year (t).

#### Total value
Summed CO₂-equivalent carbon emissions all patches for this year (t).

#### Contiguity index

This measures how similar the land use of immediate neighbours is on average

$$ \textrm{index} = \sum_\textrm{patch} \sum_\textrm{neighbours} \frac{1}{\textrm{distance}(\textrm{patch},\textrm{matching neighbour}}} $$

Where the first sum is over all patches and only neighbours with the same land use are included in the second sum.

#### Diversity index

This is the Shannon index.

$$\textrm{index} = \sum_\textrm{LU} -p_\textrm{LU}\ln{p_\textrm{LU}}$$

where $p_\textrm{LU}$ is the fraction of patches with land use $LU$ and the summation is for all land uses with $p_\textrm{LU}>0$.

#### Pollination index
The fraction of pollinated patches.

#### Bird-suitability index

The fraction of bird suitable patches.

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

    

