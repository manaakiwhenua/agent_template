# agent_template – An agent-based model of land use.
## Overview {#overview}
The model describes a square grid of land patches of size 1 ha.
Each patch is owned by a farmer who periodically revises its land use. 
This decision is influenced by the farmer's character, the present land use, other farmers and patches, external government and environmental factors, and some random selection.
Time is progressed in annual intervals.
The economic and environmental consequences of the evolving land use choices are tracked.
The model is configured and run in a Netlogo graphical interface.

## Installation {#installation}

The only file from this repository needed to run the model is `netlogo/ABM4CSL.nlogo`.
The NetLogo interpreter and graphical interface can be [downloaded from here](https://ccl.northwestern.edu/netlogo/).
Version 6.4 was used to develop and test this model.

After installing and starting the NetLogo application, `ABM4CSL.nlogo` can be opened from the "File" menu.

Further example files in the repository, in `netlogo/gis_data` and `netlogo/land_use_parameters`, enable initialising some model data from external data sets.

## User guide {#user-guide}
### Model setup {#model-setup}

The `world-size` slider controls the edge-length of the model grid.
Each grid patch is linked to a unique farmer and has up to 8 neighbours (fewer if adjacent to a boundary).
Farmers and patches are fully defined by a set of static variables and further dynamically-evolving variables are computed from the current and historical land use choices.

The `setup` button completes initialisation of the model and can be used to reinitialise the model anytime. 

To setup and run the model making identical random choices each time set `fixed-seed` to "on" and choose an integer `seed`.

#### Farmer setup {#farmer-setup}

Farmers periodically revise the land use of their patch every `decision-interval` years.
The length of time the current land use has been in place is randomised at model setup, so farmers will not make simultaneous decisions.

At setup, each farmer is randomly assigned an "attitude" that influences [decision rules](#rules):

| Attitude                             | Description                          |
|--------------------------------------|--------------------------------------|
| business-as-usual (BAU)              | Less likely to make a change         |
| industry focused (industry)          | More likely to pursue profit         |
| climate / environment conscious (CC) | More likely to pursue sustainability |

The probability of being assigned to each of these categories are weighted by the  `BAU-weight`, `industry-weight`, and  `CC-weight` controls.

Farmers are randomly assigned to a farmer-network whose collective land use influences their decision making if the [network rule](#network-rule) is active. 
The `number-of-landuse-networks` is controllable in the model interface.

#### Land use categories {#land-use-categories}

The defined land use categories and their internal codes are:

| Code | Name              | Description                            |
|------|-------------------|----------------------------------------|
| 0    | missing           | Neglected from the model               |
| 1    | artificial        | Non-agricultural use                   |
| 2    | water             | Water                                  |
| 3    | crop annual       | Food crops **(?)**                     |
| 4    | crop perennial    | Food crops **(?)**                     |
| 5    | scrub             | Non-commercial natural growth          |
| 6    | intensive pasture | High density stock **(?)**             |
| 7    | extensive pasture | Low density stock **(?)**              |
| 8    | native forest     | Non-commercial native-species forestry |
| 9    | exotic forest     | Commercial forestry                    |

The following parameters define the properties of each land use category.

| Property             | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| weight               | Relative probability of initialising a patch with this land use when random values are in configured |
| crop-yield           | Annual production of plant products (t/ha/a)                    |
| livestock-yield      | Annual production of animal products (t/ha/a)                   |
| emissions            | Annual CO₂-equivalent carbon emissions (t/ha/a)                 |
| carbon-stock-rate    | Annual CO₂-equivalent carbon capture (t/ha/a)                   |
| carbon-stock-maximum | Maximum storable CO₂-equivalent carbon (t/ha)                   |

Their values are fixed for the duration of the model, and have initial values controlled by the `landuse-parameter-source` selector, with options:

| Option       | Description                                                         |
|--------------|---------------------------------------------------------------------|
| manual entry | Use parameters set in the "current land use and manual entry" boxes |
| csv file     | Loads data from a CSV file specified by `landuse-data-csv-filename`        |
| preset:\*    | Select a set of internally coded parameters                         |

The CSV-parsing code is very fragile and the loaded table must match the structure given in the example file: `netlogo/land_use_parameters/test.csv`.

#### Land use setup {#land-use-setup}

Each patch is assigned an initial land use at setup.
The assignment method is set by the `initial-landuse-source` selector, with options:

| Option     | Description                                                                        |
|------------|------------------------------------------------------------------------------------|
| random     | Selects a land use randomly according to the configured land use weights           |
| gis-raster | Load land use from an ESRI ASCII Grid file, with path set by `gis-raster-filename` |
| gis-vector | Load land use from an ESRI shapefile, with path set by `gis-vector-filename`       |

If the value of `landuse-correlated-range` is greater than 1 and a random initialisation selected, then square blocks of patches are assigned the same land use.
If a small number of patches or large correlated range are specified then the land use distribution may not closely match the expected weights, due to under sampling.

If an external raster layer is specified then it must consist of integers matching the range of land use categories.
The `world-size` is automatically adjusted to match the maximum dimensions of the input layer.
Undefined patches of non-square layers are assigned the "missing" land use category.
If an external vector layer is specified then it must contain an integer field called "LANDUSE" ranging over land use category codes.
The configured polygons are mapped to the model grid, and a fine grid may be necessary to accurately reproduce their boundaries.
Patches not within a polygon, or outside a non-square raster layer, are assigned a "missing" land use.

The time since the presently assigned land use was initially chose is tracked for each patch as the model progresses. 
Initially, this is set to a random value between 0 and `decision-interval` so farmers will not simultaneously revise their decisions in any one year.


#### Rule setup {#rule-setup}

The "Agent rules" section of the interface allows for toggling the activity of decision-making rules.
Detailed definitions of the rules and how they are combined into farmer decisions are in the [rules section](#rules).

| Rule             | Description                                                                       |
|------------------|-----------------------------------------------------------------------------------|
| Baseline         | Mostly influenced by a farmers attitude and current land use                      |
| Neighbourhood    | Incentivises conformity with the dominant land use choice of immediate neighbours |
| Network          | Incentivises conformity with the dominant land use within a farmer network        |
| Industry level   | Forces land use choices to increase economic value                                |
| Government level | Forces land use choices to reduce greenhouse-gas emissions                        |
| Economy rule     | Incentivises land use choices to increase economic value                          |
| Emissions rule   | Incentivises land use choices to reduce greenhouse-gas emissions                  |


### Running the model {#running-the-model}

The `go` button runs the model for a number of years controlled by  `years-to-run-before-stopping`, and `go once` will progress the model one year.
The `setup` button resets the model.

#### The world map {#the-world-map}

The world map tracks the current state of the model. 
It shows data corresponding to the `map-color` and `map-label` selectors.
The `replot` button will update this plot if `map-color` or `map-layer` are changed, otherwise the plot is updated every model step.

| Option        | Description                                                    |
|---------------|----------------------------------------------------------------|
| land use      | Current land use (a legend is present in the world statistics) |
| value         | Annual profit                                                  |
| age           | Time since conversion to this land use                         |
| network       | Distribution of farmer networks                                |
| carbon stock  | Stored carbon                                                  |
| emissions     | Annual CO₂-equivalent carbon emissions                         |
| bird suitable | Bird-suitability index                                         |
| pollinated    | Pollination index                                              |

These quantities are described in detail in [computed quantities](#computed-quantities).

#### World statistics {#world-statistics}

The world statistics section displays the time dependence of world-averaged quantities.

| Statistic                                         | Description                                   |
|---------------------------------------------------|-----------------------------------------------|
| Total land use                                    | Frequency of each land use category           |
| Total value                                       | Summed annual profit                          |
| Total livestock yield                             | Summed livestock production                   |
| Total crop yield                                  | Summed crop production                        |
| Total emissions                                   | Summed CO₂-equivalent carbon emissions        |
| Carbon stock                                      | Summed stored CO₂-equivalent carbon           |
| [Contiguity index](#contiguity-index)             | Overall land-use similarity of nearby patches |
| [Diversity index](#diversity-index)               | Shannon index of diversity                    |
| [Pollination index](#pollination-index)           | Fraction of pollination-contributing patches  |
| [Bird suitability index](#bird-suitability-index) | Fraction of bird-suitable patches             |

The definitions of these are given in more detail in [computed quantities](#computed-quantities).

#### Model output {#model-output}
The "Model output" window lists some variables set during the model setup phase and at each iteration. 

### Saving and exporting the model {#saving-and-exporting-the-model}

Saving the model using the "File" menu will preserve all settings and values shown in the user interface.
Model output, graph values, and graphics can be exported to files using the "Export" options in the "File" menu. 
Alternatively, all model output can be exported at once into `export-directory` with the `export everything` button.

## Model reference {#model-reference}
### Rules {#rules}

Only farmers in their "decision-making year" are affected by decision-making rules.
The land use choices incentivised by a rule are recorded by adding weight to a list of land use options specific to each farmer.
The weights of the various land uses are initially zero. 
The incentives in multiple rules are then combined to make one weighted random choice.
If no incentive is generated by any rule or the final choice matches the current land use then no choice is recorded.

#### Baseline rule {#baseline-rule}

| Behaviour | Current land use | Action                                                                                                                    |
|-----------|------------------|---------------------------------------------------------------------------------------------------------------------------|
| BAU       | 1                | Select a neighbour randomly, if their land use is one of 3, 4, 6, or 7 then add a weight of 1 to their land use option 1. |
|           |                  |                                                                                                                           |
| Industry  | 1                | Select a neighbour randomly, if their land use is not 1 then add a weight of 1 to their land use option 1.                |
|           | 3                | Add unit weight to a land use randomly selected from 4 or 6.                                                              |
|           | 6                | Add unit weight to a land use randomly selected from 3, 4, or 6.                                                          |
|           | 7                | Add unit weight to a land use randomly selected from 7 or 9.                                                              |
|           | 9                | Add unit weight to a land use randomly selected from 7 or 9.                                                              |
|           | 9                | Add unit weight to a land use randomly selected from 7 or 9.                                                              |
|           |                  |                                                                                                                           |
| CC        | 3                | Add unit weight to land use 4.                                                                                            |
|           | 4                | Add unit weight to a land use randomly selected from 4 or 8.                                                              |
|           | 6                | Add unit weight to a land use randomly selected from 3 or 4.                                                              |
|           | 7                | Add unit weight to a land use randomly selected from 7, 8, or 9.                                                          |
|           | 9                | Add unit weight to a land use randomly selected from 7, 8, or 9.                                                          |
    
#### Neighbour rule {#neighbour-rule}

The neighbours of a farmer are other farmers within `maximum-neighbour-distance`, in grid units.
If the farmer is near the world edge or some "missing" category patches then fewer  neighbours are present.
The mode is the most common land use among neighbours, and does not consider the farmers own current land use.
The following table describes what will happen for given land use combinations.
For all other combinations, nothing happens.

| Behaviour | Current land use    | Mode | Action                        |
|-----------|---------------------|------|-------------------------------|
| BAU       | 3, 4, 5, 6, 7, or 9 | 1    | Add unit weight to land use 1 |
|           |                     |      |                               |
| Industry  | not 1               | 1    | Add unit weight to land use 1 |
|           | 4, 5, 6, or 7       | 3    | Add unit weight to land use 3 |
|           | 3, 6, or 7          | 4    | Add unit weight to land use 4 |
|           | 3, 4, or 7          | 6    | Add unit weight to land use 6 |
|           | 3, 5, or 9          | 7    | Add unit weight to land use 7 |
|           | 3, 5, or 7          | 9    | Add unit weight to land use 9 |
|           |                     |      |                               |
| CC        | 6 or 7              | 3    | Add unit weight to land use 3 |
|           | 3, 6, or 7          | 4    | Add unit weight to land use 4 |
|           | 3 or 6              | 7    | Add unit weight to land use 7 |
|           | 7                   | 9    | Add unit weight to land use 9 |
|           | Not 8 and not 1     | 8    | Add unit weight to land use 8 |

#### Network rule {#network-rule}

The mode is the most common land use among the network this farmer is a member of.
This ranking does include the farmers own current land use.
The following table describes what will happen for given land use combinations.
For all other combinations, nothing happens.


| Behaviour | Current land use    | Mode | Action                        |
|-----------|---------------------|------|-------------------------------|
| BAU       | 3, 4, 5, 6, 7, or 9 | 1    | Add unit weight to land use 1 |
|           |                     |      |                               |
| Industry  | not 1               | 1    | Add unit weight to land use 1 |
|           | 4, 5, 6, or 7       | 3    | Add unit weight to land use 3 |
|           | 3, 6, or 7          | 4    | Add unit weight to land use 4 |
|           | 3, 4, or 7          | 6    | Add unit weight to land use 6 |
|           | 3, 5, or 9          | 7    | Add unit weight to land use 7 |
|           | 3, 5, or 7          | 9    | Add unit weight to land use 9 |
|           |                     |      |                               |
| CC        | 6 or 7              | 3    | Add unit weight to land use 3 |
|           | 3, 6, or 7          | 4    | Add unit weight to land use 4 |
|           | 3 or 6              | 7    | Add unit weight to land use 7 |
|           | 7                   | 9    | Add unit weight to land use 9 |
|           | Not 8 and not 1     | 8    | Add unit weight to land use 8 |


#### Industry-level rule {#industry-rule}

If total economic value has increased in the last model iteration then perform the following actions.
 - Randomly select 5% of patches with current land use 3 and assign new land uses from a random selection of 4 or 6.
 - Randomly select 5% of patches with current land use 6 and assign a new land use of 4.
 - Randomly select 5% of patches with current land use 7 and assign new land uses from a random selection of 3, 4 or 6.

These assignments are made before the farmer makes a land use choice based on the weighted options generated by other rules. 
This rule may then be overridden by that choice.

#### Government-level rule {#government-rule}

If total emissions have decreased in the last model iteration then perform the following actions.
 - Randomly select 10% of patches with current land use 6 and assign new land uses from a random selection of 3 or 4.
 - Randomly select 10% of patches with current land use 7 and assign a new land use of 9.

These assignments are made before the farmer makes a land use choice based on the weighted options generated by other rules. 
This rule may then be overridden by that choice.

#### Economy rule {#economy-rule}

If total economic value has decreased in the last model iteration then incentivise farmers according to the following table.

| Farmers with land use | Action                                                                            |
|-----------------------|-----------------------------------------------------------------------------------|
| 3                     | Add `economy-rule-weight` to a land use option randomly selected from 4 or 6.     |
| 6                     | Add `economy-rule-weight` to land use option 4.                                   |
| 7                     | Add `economy-rule-weight` to a land use option randomly selected from 3, 4, or 6. |

#### Emissions rule {#emissions-rule}

If total emissions have increased in the last model iteration then incentivise farmers according to the following table.

| Farmers with land use | Action                                                                            |
|----------------------|-----------------------------------------------------------------------------------|
| 6                     | Add `emissions-rule-weight` to a land use option randomly selected from 3 or 4.     |
| 7                     | Add `emissions-rule-weight` to land use option 9.                                   |

### Computed quantities {#computed-quantities}
#### Emissions {#emissions}
The CO₂-equivalent carbon emissions from this patch of the previous year (t/ha).
Taken directly from the land use category's `emissions` parameter.

#### Value {#value}
The economic value of outputs from this patch in the previous year (NZD).

| Land use | Land use name     | Value                     |
|----------|-------------------|---------------------------|
| 1        | artificial        | 300 000 (first year only) |
| 2        | water             | 0                         |
| 3        | crop annual       | 450 × crop-yield          |
| 4        | crop perennial    | 3500 × crop-yield         |
| 5        | scrub             | 10 000 × livestock-yield  |
| 6        | intensive pasture | 5500 × livestock-yield    |
| 7        | extensive pasture | 0                         |
| 8        | native forest     | 0                         |
| 9        | exotic forest     | 45 000                    |


#### Crop yield {#crop-yield}
The crop yield of this patch in the previous year (t/ha).
Taken directly from the land use category's `crop-yield` parameter .

#### Livestock yield {#livestock-yield}
The animal yield of the previous year (t/ha).
Taken directly from the land use category's `livestock-yield` parameter .

#### Carbon stock {#carbon-stock}
The CO₂-equivalent carbon currently stored on this patch (t/ha). 
This is increased by every model iteration according to the land use category parameter `carbon-stock-rate` until it reaches a values of `carbon-stock-maximum`.

#### Pollinated  {#pollinated-}
For each patch, if the current land use is 3 or 4, and there is at least one neighbour within 4 grid spaces with land use 5 then this patch is considered pollinated and has an index value of 1.
Otherwise the index value is 0.

#### Bird suitable {#bird-suitable}
For each patch, if the current land use is 4, 8, or 9, and there are at least 19 neighbours within 4 grid spaces also with land uses 4, 8, or 9 then this patch is considered bird-suitable and has an index value of 1.
Otherwise the index value is 0.

### Computed world quantities {#computed-world-quantities}

#### Total value {#total-value}
Summed economic output of all patches for this year (NZD).

#### Total livestock yield {#total-livestock-yield}
Summed livestock output of all patches for this year (t).

#### Total crop yield {#total-crop-yield}
Summed crop output of all patches for this year (t).

#### Total emissions {#total-emission}
Summed CO₂-equivalent carbon emissions all patches for this year (t).

#### Contiguity index {#contiguity-index}

This measures how similar the land use of immediate neighbours is on average

$$ \textrm{index} = \sum_\textrm{patch} \sum_\textrm{neighbour} \frac{1}{\textrm{distance}(\textrm{patch},\textrm{neighbour})} $$

Where the first sum is over all patches and only neighbours with the same land use are included in the second sum.
The computed distance is in grid units.

#### Diversity index {#diversity-index}

This is the Shannon index.

$$\textrm{index} = \sum_\textrm{LU} -p_\textrm{LU}\ln{p_\textrm{LU}}$$

where $p_\textrm{LU}$ is the fraction of patches with land use $LU$ and the summation is for all land uses with $p_\textrm{LU}>0$.

#### Pollination index {#pollination-index}
The fraction of pollinated patches.

#### Bird-suitability index {#bird-suitability-index}

The fraction of bird suitable patches.

## Development 

### Netlogo version (`netlogo/`) {#netlogo-version-(`netlogo/`)}
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

#### Running a model {#running-a-model}
 
 - On Linux or Windows, respectively run, e.g., `./run.bash test/test_config.yaml` and `run.bat test/test_config.yaml'.
 - Use `run.* -d *.yaml` flag to run within the Python debugger.
 - Set additional trailing arguments overload configuration variables, e.g., `./run.bash test/test_config.yaml plot=png`.

##### Visualisation {#visualisation}

The visualisation of model output is controlled by the `plot` option in the model configuration YAML file. 

 - `pdf`: Save to file in output directory.
 - `window`: Open a graphical window.
 - `jupypterlab`: NOT IMPLEMENTED: Run in Jupyterlab for an interactive visualisation. 
 - `solara`: Opens an interactive visualisation in a web browser. 

#### Test and example configuration {#test-and-example-configuration}
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

    

