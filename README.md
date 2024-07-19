# agent_template – An agent-based model of land use.

## Overview ##

The model describes a square grid of land patches of size 1 ha.
Each patch is owned by a farmer who periodically revises its land use. 
This decision is influenced by the farmer's character, the present land use, other farmers and patches, external government and environmental factors, and some random selection.
Time is progressed in annual intervals.
The economic and environmental consequences of the evolving land use choices are tracked.
The model is configured and run in a Netlogo graphical interface.


### Installation ###

The only file from this repository needed to run the model is `netlogo/ABM4CSL.nlogo`.
The NetLogo interpreter and graphical interface can be [downloaded from here](https://ccl.northwestern.edu/netlogo/).
Version 6.4 was used to develop and test this model.

After installing and starting the NetLogo application, `ABM4CSL.nlogo` can be opened from the "File" menu.

Further example files in the repository, in `netlogo/test/gis/` and `netlogo/test/landuse/` directories, enable initialising some model data from external data sets.

### User guide ###

#### Model setup ####

The `world-size` slider controls the edge-length of the model grid.
Each grid patch is linked to a unique farmer and has up to 8 neighbours (fewer if adjacent to a boundary).
Farmers and patches are fully defined by a set of static variables and further dynamically-evolving variables are computed from the current and historical land use choices.

The `setup` button completes initialisation of the model and can be used to reinitialise the model anytime. 

To setup and run the model making identical random choices each time set `fixed-seed` to "on" and choose an integer `seed`.

If the `performance-mode` option is selected some model output may be disabled (currently, the land-use clustering calculation is disabled).

##### Farmer setup #####

Farmers periodically revise the land use of their patch every `decision-interval` years, or never if this is set to "none".
The value of `decision-interval` is randomly selected form an inclusive range between `decision-interval-minimum` and  `decision-interval-maximum`.
These are properties of the current land use and if set to "none" then `decision-interval` is also "none", meaning these land uses are permanent once established.

The length of time the current land use has been in place is randomised at model setup, so farmers will not make simultaneous decisions.

At setup, each farmer is randomly assigned a behaviour type that influences [decision rules](#rules):

| Code | Behaviour type | Description                                                           |
|------|----------------|-----------------------------------------------------------------------|
| 1    | BAU            | Business as usual, less likely to make a change                       |
| 2    | industry       | Industry focused, more likely to pursue profit                        |
| 3    | CC             | Climate and environment focused, more likely to pursue sustainability |

The probability of being assigned to each of these categories are weighted by the  `BAU-weight`, `industry-weight`, and  `CC-weight` controls.

All farmers are assigned to a farmer-network whose collective land use influences their decision making if the [network rule](#network-rule) has a nonzero weight.
A network is created for unique combinations of farmer behaviour type and initial land use.
No network is created for land uses 1, 2, 5, or 8.
The networks do not change as the model runs.

##### Land use categories #####

The defined land use categories and their internal codes are:

| Code | Name              | Description                                             |
|------|-------------------|---------------------------------------------------------|
| 0    | missing           | Neglected from the model                                |
| 1    | artificial        | Non-agricultural use,  lifestyle blocks                 |
| 2    | water             | Water                                                   |
| 3    | crop annual       | Food crops replanted at least annually (e.g., grain)    |
| 4    | crop perennial    | Food crops replanted infrequently  (e.g., fruit trees)  |
| 5    | scrub             | Non-commercial natural growth                           |
| 6    | intensive pasture | High-intensity managed pasture (e.g., dairy)            |
| 7    | extensive pasture | Low-intensity managed pasture (e.g., beef, sheep, deer) |
| 8    | native forest     | Non-commercial native-species forestry                  |
| 9    | exotic forest     | Commercial forestry                                     |

The configured land use codes must start at zero and not skip any values because they are used as an index into various arrays of land-use related data.

The following parameters define the properties of each land use category.

| Property                  | Description                                                                                                              |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------|
| weight                    | Relative probability of initialising a patch with this land use when random values are in configured                     |
| product-yield             | Annual production of all product types (t/ha/a)                                                                          |
| product-value             | Unit value of products (NZD/t)                                                                                           |
| product-value             | Unit value of products (NZD/t)                                                                                           |
| year-of-first-product     | How many years before land use initiation before product is yielded                                                      |
| year-of-last-product      | How many years after land use initiation product continues to be yielded                                                 |
| product-type              | For separate reporting of different production types, e.g,. crops or livestock                                           |
| emissions                 | Annual CO₂-equivalent carbon emissions (t/ha/a)                                                                          |
| carbon-stock-rate         | Annual CO₂-equivalent carbon capture (t/ha/a)                                                                            |
| carbon-stock-maximum      | Maximum storable CO₂-equivalent carbon (t/ha)                                                                            |
| decision-interval-minimum | The minimum number of years after initiating this land use before a farmer will consider changing it, or never if "none" |
| decision-interval-maximum | The maximum number of years after initiating this land use before a farmer will consider changing it, or never if "none" |

The values of `year-of-first-product`, `year-of-last-product`, `product-type`, `decision-interval-minimum`, and `decision-interval-maximum` are not currently user configurable.

The values of land use properties are fixed for the duration of a model run and have initial values controlled by the `landuse-parameter-source` selector, with options:

| Option       | Description                                                         |
|--------------|---------------------------------------------------------------------|
| manual entry | Use parameters set in the "current land use and manual entry" boxes |
| csv file     | Loads data from a CSV file specified by `landuse-data-csv-filename`        |
| preset:\*    | Select a set of internally coded parameters                         |

The CSV-parsing code is very fragile and the loaded table must match the structure given in the example file: `netlogo/land_use_parameters/test.csv`.

The production of livestock and crops are sometimes reported separately in the model, according to their product-type, according to the encoding


| Code | Description |
|------|-------------|
| 0    | Other       |
| 1    | Crops       |
| 2    | Livestock   |

##### Land use setup #####

Each patch is assigned an initial land use at setup.
The assignment method is set by the `initial-landuse-source` selector, with options:

| Option     | Description                                                                                      |
|------------|--------------------------------------------------------------------------------------------------|
| random     | Selects a land use randomly with the final distribution matching the configured land use weights |
| gis-raster | Load land use from an ESRI ASCII Grid file, with path set by `gis-raster-filename`               |
| gis-vector | Load land use from an ESRI shapefile, with path set by `gis-vector-filename`                     |

If the value of `landuse-correlated-range` is greater than 1 and a random initialisation selected, then square blocks of patches are assigned the same land use.
The land use distribution may not closely match the expected weights if a small number of patches, or large correlated range, is configured.

If an external raster layer is specified then it must consist of integers matching the range of land use categories.
The `world-size` is automatically adjusted to match the maximum dimensions of the input layer.
Undefined patches of non-square layers are assigned the "missing" land use category.
If an external vector layer is specified then it must contain an integer field called "LANDUSE" ranging over land use category codes.
The configured polygons are mapped to the model grid, and a fine grid may be necessary to accurately reproduce their boundaries.
Patches not within a polygon, or outside a non-square raster layer, are assigned a "missing" land use.

The time since the presently assigned land use was initially chose is tracked for each patch as the model progresses. 
Initially, this is set to a random value between 0 and `decision-interval` so farmers will not simultaneously revise their decisions in any one year.


##### Rule setup #####

The "Agent rules" section of the interface allows for toggling the activity of decision-making rules.
Detailed definitions of the rules and how they are combined into farmer decisions are in the [rules](#rules) section.

| Rule            | Description                                                                       |
|-----------------|-----------------------------------------------------------------------------------|
| Baseline        | Mostly influenced by a farmers behaviour type and current land use                      |
| Neighbourhood   | Incentivises conformity with the dominant land use choice of immediate neighbours |
| Network         | Incentivises conformity with the dominant land use within a farmer network        |
| Industry rule   | Forces land use choices to increase economic value                                |
| Government rule | Forces land use choices to reduce greenhouse-gas emissions                        |
| Economy rule    | Incentivises land use choices to increase economic value                          |
| Emissions rule  | Incentivises land use choices to reduce greenhouse-gas emissions                  |


#### Running the model ####

The `go` button runs the model for a number of years controlled by  `years-to-run-before-stopping`, and `go once` will progress the model one year.
The `setup` button resets the model.

##### The world map #####

The world map tracks the current state of the model. 
It shows data corresponding to the `map-color` and `map-label` selectors.
The `replot` button will update this plot if `map-color` or `map-layer` are changed, otherwise the plot is updated every model step.

| Option             | Description                                                    |
|--------------------|----------------------------------------------------------------|
| land use           | Current land use (a legend is present in the world statistics) |
| value              | Annual profit                                                  |
| age                | Time since conversion to this land use                         |
| network            | Distribution of farmer networks                                |
| carbon stock       | Stored carbon                                                  |
| emissions          | Annual CO₂-equivalent carbon emissions                         |
| bird suitable      | Show patches that are suitable for bird life                   |
| pollinated         | Show the degree of patch pollination                           |
| neighbour examples | Visualise the neighbour network of a few farmers               |
| cluster size       | The size of the common-land-use cluster this patch falls in    |
| decision interval  | The frequency which this farmer considers changing land use    |


These quantities are described in detail in the [model reference](#computed-quantities).

##### World statistics #####

The world statistics section displays the time dependence of world-averaged quantities.

| Statistic                                               | Description                                         |
|---------------------------------------------------------|-----------------------------------------------------|
| Total land use                                          | Frequency of each land use category                 |
| Total value                                             | Summed annual product value (NZD)                   |
| Total livestock yield                                   | Summed livestock production (t)                     |
| Total crop yield                                        | Summed crop production (t)                          |
| Total emissions                                         | Summed CO₂-equivalent carbon emissions              |
| Carbon stock                                            | Summed stored CO₂-equivalent carbon                 |
| [Mean patch size](#mean-patch-size)                     | Mean size of common-land-use clusters               |
| [Fragmentation index](#fragmentation-index)             | Mean patch size normalised to the world size        |
| [Diversity index](#diversity-index)                     | Shannon index of diversity                          |
| [Pollination index](#pollinatation-index)               | Mean patch pollination                              |
| [Bird suitability fraction](#bird-suitability-fraction) | Fraction of patches that are suitable for bird life |

The definitions of these are given in more detail in the [model reference](#computed-quantities).

##### Model output #####

The "Model output" window lists some variables set during the model setup phase and at each iteration. 

#### Saving and exporting the model and its output ####

Saving the model using the "File" menu will preserve all settings and values shown in the user interface.
Model output, graph values, and graphics can be exported to files using the "Export" options in the "File" menu. 
Alternatively, all model output can be exported at once into `export-directory` with the `export everything` button.

#### Running BehaviourSpace experiments ####

These can be created, edited, and run using the "Tools/BehaviourSpace" menu option. 
Saving the model will save all experiments into the main `*.nlogo` file.
For collaborative work it might be better to export experiments into a `.experiment` XML-encoded file.  
These can be edited manually and run from the command line, according to

    NetLogo --headless --model ABM4CSL.nlogo --setup-file EXPERIMENT_FILE.xml --experiment NAME_OF_EXPERIMENT --table OUTPUT.csv

### Model reference ###

#### Rules ####

##### Combining rules into a decision #####


The incentives created by a rule (apart from the industry and government rules) are recorded by adding weight to a list of land use options specific to each farmer.
Only farmers in a decision-making year are affected by these rules.
The weights of the various land uses are initially zero, apart from the current land use, which is set to one.
This value is not adjustable and sets the scale of user-configurable rule weights.
After all rules are processed, the land use with greatest combined incentive is selected as the farmers choice. 
If multiple land uses have maximum weight a random selection is made.
If the final choice matches the current land use then no change is recorded.

The industry and government rules operate differently.
These select a subset of farmers and mark them for a hard change to a particular land use.
Farmers in or out of a decision-making year may be selected.
Hard land use changes have precedence over the incentivised changes of selected farmers.

##### Baseline rule #####

For each decision-making farmer, the behaviours and current land use combinations listed in the following table are compared row-by-row and the corresponding action taken when a match is found.
Only the first match has an effect.
If no match is found then no action is taken.

| Behaviour | Current land use | Action                                                                      |
|-----------|------------------|-----------------------------------------------------------------------------|
| Industry  | 3                | Add `baseline-rule-weight` to a land use randomly selected from 3, 4, or 6. |
|           | 6                | Add `baseline-rule-weight` to a land use randomly selected from 3, 4, or 6. |
|           | 7                | Add `baseline-rule-weight` to a land use randomly selected from 7 or 9.     |
|           | 9                | Add `baseline-rule-weight` to a land use randomly selected from 7 or 9.     |
|           |                  |                                                                             |
| CC        | 3                | Add `baseline-rule-weight` to land use 3 or 4.                              |
|           | 4                | Add `baseline-rule-weight` to a land use randomly selected from 4 or 8.     |
|           | 6                | Add `baseline-rule-weight` to a land use randomly selected from 3 or 4.     |
|           | 7                | Add `baseline-rule-weight` to a land use randomly selected from 7, 8, or 9. |
|           | 9                | Add `baseline-rule-weight` to a land use randomly selected from 7, 8, or 9. |
    
##### Neighbour rule #####

The neighbours of a farmer are those other farmers within `maximum-neighbour-distance`, in grid units.
If the farmer is near the world edge or some "missing" category patches then fewer neighbours are present.
The "most common land use" is the most common land use among neighbours, and does not consider the farmers own current land use.

For each decision-making farmer, the behaviours, current land use combinations, and most-common land-uses listed in the following table are compared row-by-row and the corresponding action taken when a match is found.
Only the first match has an effect.
If no match is found then no action is taken.


| Behaviour | Current land use | Most common land use | Action                                    |
|-----------|------------------|----------------------|-------------------------------------------|
| BAU       | 3, 4, 6, 7, or 9 | 1                    | Add `neighbour-rule-weight` to land use 1 |
|           |                  |                      |                                           |
| Industry  | 3, 4, 6, 7, or 9 | 1                    | Add `neighbour-rule-weight` to land use 1 |
|           | 3, 6, or 7       | 3                    | Add `neighbour-rule-weight` to land use 3 |
|           | 3, 4, 6, or 7    | 4                    | Add `neighbour-rule-weight` to land use 4 |
|           | 3, 4, 6, or 7       | 6                    | Add `neighbour-rule-weight` to land use 6 |
|           | 3, 7, or 9       | 7                    | Add `neighbour-rule-weight` to land use 7 |
|           | 3, 7, or 9       | 9                    | Add `neighbour-rule-weight` to land use 9 |
|           |                  |                      |                                           |
| CC        | 3, 6, or 7       | 3                    | Add `neighbour-rule-weight` to land use 3 |
|           | 3, 4, 6, or 7    | 4                    | Add `neighbour-rule-weight` to land use 4 |
|           | 3 or 6           | 7                    | Add `neighbour-rule-weight` to land use 7 |
|           | Not 8 and not 1  | 8                    | Add `neighbour-rule-weight` to land use 8 |
|           | 3 or 7           | 9                    | Add `neighbour-rule-weight` to land use 9 |

##### Network rule #####

The most common land use is the most common land use among the network this farmer is a member of.
This ranking does include the farmers own current land use.

For each decision-making farmer, the behaviours, current land use combinations, and most-common land-uses listed in the following table are compared row-by-row and the corresponding action taken when a match is found.
Only the first match has an effect.
If no match is found then no action is taken.

| Behaviour | Current land use | Most common land use | Action                                  |
|-----------|------------------|----------------------|-----------------------------------------|
| BAU       | 3, 4, 6, 7, or 9 | 1                    | Add `network-rule-weight` to land use 1 |
|           |                  |                      |                                         |
| Industry  | 3, 4, 6, 7, or 9 | 1                    | Add `network-rule-weight` to land use 1 |
|           | 3, 6, or 7       | 3                    | Add `network-rule-weight` to land use 3 |
|           | 3, 4, 6, or 7    | 4                    | Add `network-rule-weight` to land use 4 |
|           | 3, 4, 6, or 7    | 6                    | Add `network-rule-weight` to land use 6 |
|           | 3, 7, or 9       | 7                    | Add `network-rule-weight` to land use 7 |
|           | 3, 7, or 9       | 9                    | Add `network-rule-weight` to land use 9 |
|           |                  |                      |                                         |
| CC        | 3, 6, or 7       | 3                    | Add `network-rule-weight` to land use 3 |
|           | 3, 4, 6, or 7    | 4                    | Add `network-rule-weight` to land use 4 |
|           | 3 or 6           | 7                    | Add `network-rule-weight` to land use 7 |
|           | Not 8 and not 1  | 8                    | Add `network-rule-weight` to land use 8 |
|           | 3 or 7           | 9                    | Add `network-rule-weight` to land use 9 |

##### Industry rule #####

If total economic value has decreased in the last model iteration then perform the following actions.

 - Randomly select `industry-rule-percentage` of farmers with current land use 3 for a hard change to a random selection of land use 4 or 6.
 - Randomly select `industry-rule-percentage` of farmers with current land use 6 for a hard change to land use 4.
 - Randomly select `industry-rule-percentage` of farmers with current land use 7 for a hard change to a random selection of land use 3, 4 or 6.

These assignments are made before the farmer makes a land use choice based on the weighted options generated by other rules. 
This rule may then be overridden by that choice.
This rule applies to all farmers, not just those in a decision-making year.

##### Government rule #####

If total emissions have increased in the last model iteration then perform the following actions.

 - Randomly select `government-rule-percentage` of patches with current land use 6 for a hard change to a random selection of land use 3 or 4.
 - Randomly select `government-rule-percentage` of patches with current land use 7 for a hard change to land use 9.

These assignments are made before the farmer makes a land use choice based on the weighted options generated by other rules. 
This rule may then be overridden by that choice.
This rule applies to all farmers, not just those in a decision-making year.

##### Economy rule #####

If total economic value has decreased in the last model iteration then incentivise farmers according to the following table.

| Farmers with land use | Action                                                                            |
|-----------------------|-----------------------------------------------------------------------------------|
| 3                     | Add `economy-rule-weight` to a land use option randomly selected from 4 or 6.     |
| 6                     | Add `economy-rule-weight` to land use option 4.                                   |
| 7                     | Add `economy-rule-weight` to a land use option randomly selected from 3, 4, or 6. |

##### Emissions rule #####

If total emissions have increased in the last model iteration then incentivise farmers according to the following table.

| Farmers with land use | Action                                                                            |
|----------------------|-----------------------------------------------------------------------------------|
| 6                     | Add `emissions-rule-weight` to a land use option randomly selected from 3 or 4.     |
| 7                     | Add `emissions-rule-weight` to land use option 9.                                   |

#### Computed patch quantities ####

##### Value #####

The economic value of the product output of this patch in the previous year (NZD).
This is calculated according to 

    value = product-value × product-yield

For years before `year-of-first-product` or after `year-of-last-product` the product value is zero.
If `year-of-first-product` is set to "never" then no product is ever yielded.
If `year-of-last-product` is set to "never" then production continues forever.

##### Carbon stock #####

The CO₂-equivalent carbon currently stored on this patch (t/ha). 
This is increased by every model iteration according to the land use category parameter `carbon-stock-rate` until it reaches a values of `carbon-stock-maximum`.

##### Cluster size #####

Patches are divided into clusters of common land use, and each patch then has an associated cluster size.
Diagonal connections are not included.
This calculation is not made in `performance-mode` and is replaced with a dummy value of 0.

##### Pollinated #####

For patches with land use is 3 or 4, if at least one neighbour within 4 grid spaces has land use 5 then this patch is considered pollinated with value 1, otherwise, if at least one neighbour within 4 grid spaces has land use 7, 8, or 9 the pollination value is 0.5, otherwise the pollination value is 0.

##### Bird suitable #####

For each patch, if the current land use is 4, 8, or 9, and there are at least 19 neighbours within 4 grid spaces also with land uses 4, 8, or 9 then this patch is considered bird-suitable and has an index value of 1.
Otherwise the index value is 0.

#### Computed world quantities ####

##### Total value #####

Summed product value of all patches for this year (NZD).

##### Total livestock yield #####

Summed product output of all patches of reporting type "livestock" for this year (t).

##### Total crop yield #####

Summed product output of all patches of reporting type "crops" for this year (t).

##### Total emissions #####

Summed CO₂-equivalent carbon emissions all patches for this year (t).

##### Mean patch size #####

This measures how similar the land use of immediate neighbours is on average.
It is the mean number of patches in all common-land-use clusters.
This calculation is not made in `performance-mode` and is replaced with a dummy value of 0.

##### Fragmentation index #####

This is the same as the mean patch size but is model-size independent.
The mean patch size is divided by the total number of patches, excluding those with `missing` land use.
This calculation is not made in `performance-mode` and is replaced with a dummy value of 0.

##### Diversity index #####

This is the Shannon index.

$$\textrm{index} = \sum_\textrm{LU} -p_\textrm{LU}\ln{p_\textrm{LU}}$$

where $p_\textrm{LU}$ is the fraction of patches with land use $LU$ and the summation is for all land uses with $p_\textrm{LU}>0$.

##### Pollination index #####

The mean pollination value.

##### Bird suitable index #####

The mean bird suitability.

#### Default land use parameters ####

These are the land use parameters set by the "preset: default" option of `landuse-parameter-source`.

| code | name              | color | product-yield | product-value | emissions | carbon-stock-rate | carbon-stock-maximum | weight | product-type | year-of-first-product | year-of-last-product |
|------|-------------------|-------|---------------|---------------|-----------|-------------------|----------------------|--------|--------------|-----------------------|----------------------|
| 0    | missing           | 0     | 0             | 0             | 0         | 0                 | 0                    | 0      | 0            | none                  | none                 |
| 1    | artificial        | 8     | 1             | 300000        | 0         | 0                 | 0                    | 3      | 0            | 1                     | 1                    |
| 2    | water             | 87    | 0             | 0             | 0         | 0                 | 0                    | 5      | 0            | none                  | none                 |
| 3    | crop annual       | 45    | 10            | 450           | 95        | 0                 | 0                    | 10     | 1            | 1                     | none                 |
| 4    | crop perennial    | 125   | 20            | 3500          | 90        | 0                 | 0                    | 10     | 1            | 1                     | none                 |
| 5    | scrub             | 26    | 0             | 0             | 0         | 3.5               | 100                  | 6      | 0            | 1                     | none                 |
| 6    | intensive pasture | 65    | 1.1           | 10000         | 480       | 0                 | 0                    | 18     | 2            | 1                     | none                 |
| 7    | extensive pasture | 56    | 0.3           | 5500          | 150       | 0                 | 0                    | 23     | 2            | 1                     | none                 |
| 8    | native forest     | 73    | 0             | 0             | 0         | 8                 | 250                  | 5      | 0            | 1                     | none                 |
| 9    | exotic forest     | 63    | 1             | 4500          | 0         | 25                | 700                  | 20     | 0            | 1                     | none                 |

