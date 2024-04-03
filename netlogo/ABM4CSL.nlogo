extensions [
  gis                ; GIS extension
  csv                ; access CSV files
]

globals [

  ;; Annual profit (NZD)
  total-value$                  ; summed over patches
  previous-total-value$         ; summed over patches, previous time step

  ;; total model statistics
  total-CO2eq                   ; Annual carbon-equivalent emissions (t/ha) summed over patches
  previous-CO2eq                ; summed over patches, previous time step
  diversity-index                 ; measure of land use diversity
  contiguity-index              ; measure of land use contiguity
  pollination-index             ; measure of land use promotes pollination
  bird-suitability-index             ; measure of land use promotes pollination

  ;; land use data
  landuse-code                  ; a list of all possible landuses
  landuse-name                  ; long form name
  landuse-color                 ; color to plot
  landuse-CO2eq                 ; carbon-equivalent emissions per patch
  landuse-crop-yield            ; t/ha
  landuse-livestock-yield       ; t/ha
  landuse-carbon-stock-rate     ; amount of carbon stored annually
  landuse-carbon-stock-maximum  ; maximum amount of carbon storage
  landuse-weight        ; used to create a random intial landuse
  ;; landuse-data-csv-filename  ; csv file to overwrite landuse data, leave blank to ignore, set in interface

  ;; land use networks
  ;; number-of-landuse-networks     ; how many distinct networks, set in interface

  ;; GIS
  gis-vector-data                      ; data object containg GIS info
  gis-raster-data                      ; data object containg GIS info
  ;; gis-raster-filename               ; spruce of raster data, set in interface
  ;; gis-vector-filename               ; spruce of filename data, set in interface

  ;; farmer attitude distribution, set in interface
  ;; BAU-weight                          ; business-as-usual
  ;; industry-weight                     ; industry-conscious
  ;; CC-weight                           ; climate conscious

  ;; rules to apply, set in interface
  ;; Baseline ;
  ;; Neighbour ;
  ;; Network ;
  ;; Industry-level
  ;; Government-level

  stop-after-year                               ;stop going after this step
]

patches-own [
  ;; each patch is a parcel of land
  LU           ; current land use
  CO2eq        ; Annual carbon-equivalent emissions (t/ha) of a patch
  value$       ; Annual profit (NZD) of a patch
  landuse-age  ; the number of ticks since this land use was initiated
  landuse-options ; new land use options the farmer is somehow motivated to choose from
  crop-yield      ; t/ha
  livestock-yield ; t/ha
  carbon-stock    ; stored carbon, t/ha
  pollinated      ;if this patch contributes is pollinated
  bird-suitable   ;if this patch is suitable for birds

]

breed [farmers farmer]
farmers-own [
  ;; a farmer, in divisible from its land
  behaviour                    ; behaviour type
  LUnetwork                    ; most common land use in large scale network
  LUneighbour                   ; most common land use among neighbours
]

breed [landuse-networks landuse-network]
landuse-networks-own [
  ;; a network associating farmers
  most-common-landuse  ; most common land use in each network
  network-color   s     ; for plotting
]

;; links between farmers and a landuse-network
undirected-link-breed [landuse-network-links landuse-network-link]


;; setup model

to setup
  __clear-all-and-reset-ticks
  ;; set a specific random seed to see whether output is changed in
  ;; detail by code changes, for development and debugging only
  if fixed-seed [random-seed seed]
  ;; control how long model goes for
  set stop-after-year years-to-run-before-stopping
  ;; initialise default land use data (could reimplement using the built-in
  ;; table extension).  Changing the size and ordering of this list is
  ;; now hard because of assumed indexing elsewhere in the code. One
  ;; good reason to use a table?
  set-landuse-parameters
  ;; setup world size
  setup-world
  setup-gis-data
  setup-land
  setup-landuse-networks
  setup-farmers
  ;; update
  update-derived-model-quantities
  update-display
end

to set-landuse-parameters-from-csv
  ;; Read land use data from a correctly formatted CSV file. Must be
  ;; of the correct shape, size, and key ordering to match the
  ;; existing landuse data. NO CHECKS ARE MADE!!!
  ;;
  ;; open file, read line by line, trimming whitespace and quotes
  file-open landuse-data-csv-filename
  while [ not file-at-end? ] [
    let elements (map
        [element -> (trim-whitespace-and-quotes element)]
        (csv:from-row file-read-line) )
    ;; if statement to skip commented lines
    if (not ((first (first elements)) = "#")) [
      ;; set landuse data casting strings to numeric data
      ;; automatically and WITHOUT CHECKS!
      let this-landuse-code (read-from-string item 0 elements)
      let index (this-landuse-code - 1)
      let this-column 1
      set landuse-name (replace-item index landuse-name (item this-column elements))
      set this-column (this-column + 1)
      set landuse-color (replace-item index landuse-color (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-crop-yield (replace-item index landuse-crop-yield (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-livestock-yield (replace-item index landuse-livestock-yield (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-CO2eq (replace-item index landuse-CO2eq (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-carbon-stock-rate (replace-item index landuse-carbon-stock-rate (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-carbon-stock-maximum (replace-item index landuse-carbon-stock-maximum (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
      set landuse-weight (replace-item index landuse-weight (read-from-string (item this-column elements)))
      set this-column (this-column + 1)
    ]]
    file-close
end

to set-landuse-parameters-from-preset-default
  ;; Set land use parameters (could reimplement using the built-in
  ;; table extension).  Changing the size and ordering of this list is
  ;; now hard because of assumed indexing elsewhere in the code. One
  ;; good reason to use a table?
  set landuse-code                     [ 1            2       3             4                5       6                   7                   8               9               ]
  set landuse-name                     [ "artificial" "water" "crop annual" "crop perennial" "scrub" "intensive pasture" "extensive pasture" "native forest" "exotic forest" ]
  set landuse-color                    [ 8            87      45            125              26      65                  56                  73              63              ]
  set landuse-crop-yield               [ 0            0       10            20               0       0                   0                   0               0               ]
  set landuse-livestock-yield          [ 0            0       0             0                0       1.1                 0.3                 0               0               ]
  set landuse-CO2eq                    [ 0            0       95            90               0       480                 150                 0               0               ]
  set landuse-carbon-stock-rate        [ 0            0       0             0                3.5     0                   0                   8               25              ]
  set landuse-carbon-stock-maximum     [ 0            0       0             0                100     0                   0                   250             700             ]
  set landuse-weight                   [ 3            5       10            10               6       18                  23                  5               20              ]
end

to set-landuse-parameters-from-preset-forest
  ;; Set land use parameters (could reimplement using the built-in
  ;; table extension).  Changing the size and ordering of this list is
  ;; now hard because of assumed indexing elsewhere in the code. One
  ;; good reason to use a table?
  set landuse-code                     [ 1            2       3             4                5       6                   7                   8               9               ]
  set landuse-name                     [ "artificial" "water" "crop annual" "crop perennial" "scrub" "intensive pasture" "extensive pasture" "native forest" "exotic forest" ]
  set landuse-color                    [ 8            87      45            125              26      65                  56                  73              63              ]
  set landuse-crop-yield               [ 0            0       10            20               0       0                   0                   0               0               ]
  set landuse-livestock-yield          [ 0            0       0             0                0       1.1                 0.3                 0               0               ]
  set landuse-CO2eq                    [ 0            0       95            90               0       480                 150                 0               0               ]
  set landuse-carbon-stock-rate        [ 0            0       0             0                3.5     0                   0                   8               25              ]
  set landuse-carbon-stock-maximum     [ 0            0       0             0                100     0                   0                   250             700             ]
  set landuse-weight                   [ 0            0       0             0                0       0                   0                   50              50              ]
end

to set-landuse-parameters
  ;; Initialise or re-initialise and the landuse parameters from the
  ;; source specified by landuse-parameter-source

  ;; initialise landuse parameters from the default preset value.  Do this
  ;; first so that the lists exist and are of the right size.  This is
  ;; the DEFINING land parameter data structure
  set-landuse-parameters-from-preset-default


  ;; set from a preset
  if (landuse-parameter-source = "preset: default")  [set-landuse-parameters-from-preset-default]
  if (landuse-parameter-source = "preset: forest")  [set-landuse-parameters-from-preset-forest]

  ;; load csv landuse parameters into landuse arrays
  if (landuse-parameter-source = "csv file")  [set-landuse-parameters-from-csv]

  ;; set landuse arrays from whatever is in the manual entry boxes
  if (landuse-parameter-source = "manual entry") [
      set landuse-weight (replace-item 0 landuse-weight artificial-weight)
      set landuse-weight (replace-item 1 landuse-weight water-weight)
      set landuse-weight (replace-item 2 landuse-weight crop-annual-weight)
      set landuse-weight (replace-item 3 landuse-weight crop-perennial-weight)
      set landuse-weight (replace-item 4 landuse-weight scrub-weight)
      set landuse-weight (replace-item 5 landuse-weight intensive-pasture-weight)
      set landuse-weight (replace-item 6 landuse-weight extensive-pasture-weight)
      set landuse-weight (replace-item 7 landuse-weight native-forest-weight)
      set landuse-weight (replace-item 8 landuse-weight exotic-forest-weight)
      set landuse-crop-yield (replace-item 0 landuse-crop-yield artificial-crop-yield)
      set landuse-crop-yield (replace-item 1 landuse-crop-yield water-crop-yield)
      set landuse-crop-yield (replace-item 2 landuse-crop-yield crop-annual-crop-yield)
      set landuse-crop-yield (replace-item 3 landuse-crop-yield crop-perennial-crop-yield)
      set landuse-crop-yield (replace-item 4 landuse-crop-yield scrub-crop-yield)
      set landuse-crop-yield (replace-item 5 landuse-crop-yield intensive-pasture-crop-yield)
      set landuse-crop-yield (replace-item 6 landuse-crop-yield extensive-pasture-crop-yield)
      set landuse-crop-yield (replace-item 7 landuse-crop-yield native-forest-crop-yield)
      set landuse-crop-yield (replace-item 8 landuse-crop-yield exotic-forest-crop-yield)
      set landuse-livestock-yield (replace-item 0 landuse-livestock-yield artificial-livestock-yield)
      set landuse-livestock-yield (replace-item 1 landuse-livestock-yield water-livestock-yield)
      set landuse-livestock-yield (replace-item 2 landuse-livestock-yield crop-annual-livestock-yield)
      set landuse-livestock-yield (replace-item 3 landuse-livestock-yield crop-perennial-livestock-yield)
      set landuse-livestock-yield (replace-item 4 landuse-livestock-yield scrub-livestock-yield)
      set landuse-livestock-yield (replace-item 5 landuse-livestock-yield intensive-pasture-livestock-yield)
      set landuse-livestock-yield (replace-item 6 landuse-livestock-yield extensive-pasture-livestock-yield)
      set landuse-livestock-yield (replace-item 7 landuse-livestock-yield native-forest-livestock-yield)
      set landuse-livestock-yield (replace-item 8 landuse-livestock-yield exotic-forest-livestock-yield)
      set landuse-CO2eq (replace-item 0 landuse-CO2eq artificial-CO2eq)
      set landuse-CO2eq (replace-item 1 landuse-CO2eq water-CO2eq)
      set landuse-CO2eq (replace-item 2 landuse-CO2eq crop-annual-CO2eq)
      set landuse-CO2eq (replace-item 3 landuse-CO2eq crop-perennial-CO2eq)
      set landuse-CO2eq (replace-item 4 landuse-CO2eq scrub-CO2eq)
      set landuse-CO2eq (replace-item 5 landuse-CO2eq intensive-pasture-CO2eq)
      set landuse-CO2eq (replace-item 6 landuse-CO2eq extensive-pasture-CO2eq)
      set landuse-CO2eq (replace-item 7 landuse-CO2eq native-forest-CO2eq)
      set landuse-CO2eq (replace-item 8 landuse-CO2eq exotic-forest-CO2eq)
      set landuse-carbon-stock-rate (replace-item 0 landuse-carbon-stock-rate artificial-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 1 landuse-carbon-stock-rate water-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 2 landuse-carbon-stock-rate crop-annual-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 3 landuse-carbon-stock-rate crop-perennial-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 4 landuse-carbon-stock-rate scrub-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 5 landuse-carbon-stock-rate intensive-pasture-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 6 landuse-carbon-stock-rate extensive-pasture-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 7 landuse-carbon-stock-rate native-forest-carbon-stock-rate)
      set landuse-carbon-stock-rate (replace-item 8 landuse-carbon-stock-rate exotic-forest-carbon-stock-rate)
      set landuse-carbon-stock-maximum (replace-item 0 landuse-carbon-stock-maximum artificial-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 1 landuse-carbon-stock-maximum water-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 2 landuse-carbon-stock-maximum crop-annual-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 3 landuse-carbon-stock-maximum crop-perennial-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 4 landuse-carbon-stock-maximum scrub-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 5 landuse-carbon-stock-maximum intensive-pasture-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 6 landuse-carbon-stock-maximum extensive-pasture-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 7 landuse-carbon-stock-maximum native-forest-carbon-stock-maximum)
      set landuse-carbon-stock-maximum (replace-item 8 landuse-carbon-stock-maximum exotic-forest-carbon-stock-maximum)
    ]

    ;; set manual entry boxes to match whatever is now in the arrays
    set artificial-weight (item 0 landuse-weight)
    set water-weight (item 1 landuse-weight)
    set crop-annual-weight (item 2 landuse-weight)
    set crop-perennial-weight (item 3 landuse-weight)
    set scrub-weight (item 4 landuse-weight)
    set intensive-pasture-weight (item 5 landuse-weight)
    set extensive-pasture-weight (item 6 landuse-weight)
    set native-forest-weight (item 7 landuse-weight)
    set exotic-forest-weight (item 8 landuse-weight)
    set artificial-crop-yield (item 0 landuse-crop-yield)
    set water-crop-yield (item 1 landuse-crop-yield)
    set crop-annual-crop-yield (item 2 landuse-crop-yield)
    set crop-perennial-crop-yield (item 3 landuse-crop-yield)
    set scrub-crop-yield (item 4 landuse-crop-yield)
    set intensive-pasture-crop-yield (item 5 landuse-crop-yield)
    set extensive-pasture-crop-yield (item 6 landuse-crop-yield)
    set native-forest-crop-yield (item 7 landuse-crop-yield)
    set exotic-forest-crop-yield (item 8 landuse-crop-yield)
    set artificial-livestock-yield (item 0 landuse-livestock-yield)
    set water-livestock-yield (item 1 landuse-livestock-yield)
    set crop-annual-livestock-yield (item 2 landuse-livestock-yield)
    set crop-perennial-livestock-yield (item 3 landuse-livestock-yield)
    set scrub-livestock-yield (item 4 landuse-livestock-yield)
    set intensive-pasture-livestock-yield (item 5 landuse-livestock-yield)
    set extensive-pasture-livestock-yield (item 6 landuse-livestock-yield)
    set native-forest-livestock-yield (item 7 landuse-livestock-yield)
    set exotic-forest-livestock-yield (item 8 landuse-livestock-yield)
    set artificial-CO2eq (item 0 landuse-CO2eq)
    set water-CO2eq (item 1 landuse-CO2eq)
    set crop-annual-CO2eq (item 2 landuse-CO2eq)
    set crop-perennial-CO2eq (item 3 landuse-CO2eq)
    set scrub-CO2eq (item 4 landuse-CO2eq)
    set intensive-pasture-CO2eq (item 5 landuse-CO2eq)
    set extensive-pasture-CO2eq (item 6 landuse-CO2eq)
    set native-forest-CO2eq (item 7 landuse-CO2eq)
    set exotic-forest-CO2eq (item 8 landuse-CO2eq)
    set artificial-carbon-stock-rate (item 0 landuse-carbon-stock-rate)
    set water-carbon-stock-rate (item 1 landuse-carbon-stock-rate)
    set crop-annual-carbon-stock-rate (item 2 landuse-carbon-stock-rate)
    set crop-perennial-carbon-stock-rate (item 3 landuse-carbon-stock-rate)
    set scrub-carbon-stock-rate (item 4 landuse-carbon-stock-rate)
    set intensive-pasture-carbon-stock-rate (item 5 landuse-carbon-stock-rate)
    set extensive-pasture-carbon-stock-rate (item 6 landuse-carbon-stock-rate)
    set native-forest-carbon-stock-rate (item 7 landuse-carbon-stock-rate)
    set exotic-forest-carbon-stock-rate (item 8 landuse-carbon-stock-rate)
    set artificial-carbon-stock-maximum (item 0 landuse-carbon-stock-maximum)
    set water-carbon-stock-maximum (item 1 landuse-carbon-stock-maximum)
    set crop-annual-carbon-stock-maximum (item 2 landuse-carbon-stock-maximum)
    set crop-perennial-carbon-stock-maximum (item 3 landuse-carbon-stock-maximum)
    set scrub-carbon-stock-maximum (item 4 landuse-carbon-stock-maximum)
    set intensive-pasture-carbon-stock-maximum (item 5 landuse-carbon-stock-maximum)
    set extensive-pasture-carbon-stock-maximum (item 6 landuse-carbon-stock-maximum)
    set native-forest-carbon-stock-maximum (item 7 landuse-carbon-stock-maximum)
    set exotic-forest-carbon-stock-maximum (item 8 landuse-carbon-stock-maximum)
end

to setup-world
  ;; load raster file if necessary to set world size to match
  if (initial-landuse-source = "gis-raster") [
    set gis-raster-data gis:load-dataset gis-raster-filename
    set world-size gis:width-of  gis-raster-data]
  ;; setup the grid
  resize-world 0 ( world-size - 1 ) 0 ( world-size - 1 )
  set-patch-size 6 * 100 / world-size
end

to setup-gis-data
  ;; load and prepare GIS data if needed
  if (initial-landuse-source = "gis-vector") [
    ;; load vector layer
    set gis-vector-data gis:load-dataset gis-vector-filename
    ;; link to world
    gis:set-world-envelope (gis:envelope-of gis-vector-data)
    ;; print what properties are defined for features
    ;; show gis:property-names gis-vector-data ; DEBUG
]
  if (initial-landuse-source = "gis-raster") [
    ;; load raster layer
    set gis-raster-data gis:load-dataset gis-raster-filename
    ;; link to world
    gis:set-world-envelope (gis:envelope-of gis-raster-data)]
end

to setup-land                                                                            ;; setup the LU within the landscape
  ;; set initial land use
  (ifelse
    (initial-landuse-source = "random") [initialise-landuse-to-random-and-correlated]
    (initial-landuse-source = "gis-vector") [initialise-landuse-to-gis-vector-layer]
    (initial-landuse-source = "gis-raster") [initialise-landuse-to-gis-raster-layer]
    ;; if initialise-landuse-source is an integer, set all land use to this
    [ask patches [set LU initial-landuse-source]])
  ;; create one farmer per patch
  ask patches [sprout-farmers 1 [set shape "person" set size 0.5 set color black]]
end

to initialise-landuse-to-random-and-correlated
  ;; loop through patches assigning landuse, stepping by correlated width
  foreach (range 0 world-width landuse-correlated-range) [ x ->
    foreach (range 0 world-height landuse-correlated-range) [ y ->
      ;; choose a random land use respecting weights
      let this-LU (choose landuse-code landuse-weight)
      ;; set patches in this correlated square
      ask patches with [(pxcor >= x) and (pxcor < x + landuse-correlated-range)
                      and (pycor >= y) and (pycor < y + landuse-correlated-range)]
                [set LU this-LU]]]
end

to initialise-landuse-to-gis-vector-layer
  ;; single value default
  ask patches [ set LU 3 ]
  ;; landuse from gis-vector
  foreach gis:feature-list-of gis-vector-data [ feature ->
    ; gis:set-property-value feature "AREA" (( random  8 ) + 1 )
    ; let this-LU ( random  8 ) + 1 ; CORRECT?!?
    ask patches gis:intersecting feature [
      set LU gis:property-value feature "LANDUSE"]]
end

to initialise-landuse-to-gis-raster-layer
  ask patches [
    ;; single value default
    set LU 3
    ;; set to raster value -- HACKED here because test data is not landuse integers
    ; set LU ( int gis:raster-sample gis-raster-data self )  mod 9 + 1
    ; set LU ( int gis:raster-sample gis-raster-data self )
    set LU ( gis:raster-sample gis-raster-data self )
    ; setup-world
    ; show ( gis:raster-sample gis-raster-data self )
]
end

to setup-farmers
  ask farmers [
    ;; create 3 types of behaviour 1 is BAU, 2 is industry$, 3 is climate and environment concious
    let tiralea random-float 100
    set [behaviour color] (
      ifelse-value
        (tiralea < BAU-weight) [[1 red]]
        (tiralea < ( BAU-weight + industry-weight )) [[2 blue]]
        [[3 white]])
    ;; Set the initial landuse-age to a random value up to
    ;; decision-interval.
    ask patch-here [ set landuse-age ( - (random decision-interval)) ]
    ; ;; create a link between farmers and the underlying patch
    ; set My-plot patch-here
  ]
end

to setup-landuse-networks
  ;; create landuse networks
  ;; create networks
  create-landuse-networks number-of-landuse-networks [hide-turtle]
  ;; create network links to farmers
  ask farmers [
    create-landuse-network-link-with one-of landuse-networks [hide-link]]
  ;; set networks to have incremental colours
  let this-color 5
  ask landuse-networks [
    set network-color this-color
    set this-color (this-color + 10)
  ]
end


;;;;;;;;;;;;;;;;;;;;;
;; integrate model ;;
;;;;;;;;;;;;;;;;;;;;;

to go
  ;; setup if not setup
  if (stop-after-year = 0) [setup]
  ;; run the model until it hits 'stop'
  ;; initialise options to choose from
  ask patches [ set landuse-options [] ]
  ;; execute rules, adding to landuse-options that are chosen from
  ;; below
  if Baseline [basic-LU-rule]
  if Neighbourhood [LU-neighbour-rule]
  if Network [LU-network-rule]
  if Industry-level [economy-rule]
  if Government-level [reduce-emission-rule]
  ;; Randomly choose a new landuse from the identified options.  If it
  ;; is the same as the existing land use do nothing.  If change is
  ;; registered then reset the landuse-age to zero.
  ask patches [
    if length landuse-options > 0 [
      let LU-new one-of landuse-options
      if LU-new != LU [
        set LU LU-new
        set landuse-age 0]]]
  ;;  if Combine = true [basic-LU-rule LU-neighbour-rule LU-network-rule]
  ;; recompute things derived from the landuse
  update-derived-model-quantities
  ;; update the display window in various ways
  update-display
  ;; step time, age land, and stop model
  ask patches [set landuse-age (landuse-age + 1)]
  tick
  if ticks >= stop-after-year [
    set stop-after-year ( stop-after-year + years-to-run-before-stopping )
  stop ]
end

to update-derived-model-quantities
  ;; Compute crop yields
  ask patches [set crop-yield item (LU - 1) landuse-crop-yield]
  ;; compute livestock yields
  ask patches [set livestock-yield item (LU - 1) landuse-livestock-yield]
  ;; compute carbon stock
  ask patches [set carbon-stock (min (list
    (landuse-age * (item (LU - 1) landuse-carbon-stock-rate))
    (item (LU - 1) landuse-carbon-stock-maximum)))]
  ;; compute Shannon index of diversity
  let total-number-of-patches (count patches)
  set diversity-index 0
  foreach landuse-code [ this-LU ->
    let p ( (count patches with [ LU = this-LU ]) / total-number-of-patches )
    if ( p > 0) [
    set diversity-index (diversity-index + (-1 * p * (ln p)))]]
  ;; compute contiguity index
  ;;
  ;; ref URL from Clemence https://www.fragstats.org/index.php/fragstats-metrics/patch-based-metrics/shape-metrics/p5-contiguity-index
  ;;
  ;; example code from Clemence.
  ;;
  ;; let contiguity-index 0
  ;; ask patches [
  ;;   let neighbors-with-same-value neighbors with [my-value = [my-value] of myself]
  ;;   (ifelse any? neighbors-with-same-value
  ;;   [let weighted-contiguity sum [1 / distance myself] of neighbors-with-same-value
  ;;    set contiguity-index contiguity-index + weighted-contiguity]
  ;;    ;; Handle case when there are no neighbors with the same value
  ;;   [set contiguity-index contiguity-index + 0]
  ;; )]
  ;;
  ;; My code. Why distance since finding direct neighbours? How to
  ;; normalise the index?
  set contiguity-index 0
  ask patches [
    ask neighbors with [LU = [LU] of myself] [
        set contiguity-index (contiguity-index + (1 / distance myself))]]
  ;; pollination index: Clemence's explanation: Simplest way consists
  ;; in analysing the presence of scrub cell within the neighbourhood
  ;; (500m = 4cells) of a crop patch (perennial or annual). Report 1
  ;; if yes and 0 if no. Add the number of cells=1 and divide by the
  ;; total number of crop cells (annual and perennial)
  ask patches [set pollinated 0]
  ask patches with [(LU = 3) or (LU = 4)] [
    if (count patches with [((distance myself) <= 4) and (LU = 5)] >= 1) [
        set pollinated 1]]
  set pollination-index (sum [pollinated] of patches)
  if (pollination-index > 0) [
    set pollination-index (pollination-index / count patches with [(LU = 3) or (LU = 4)])]
  ;; bird suitability index: Clemence's explanation Concerns the
  ;; perennial crops and forest (exotic+natural) cells. Value= the
  ;; number of cells where the habitat quality is ok for native birds
  ;; (like Kereru) / total number of cells. Simplest way consists in
  ;; analysing all concerns cells: is this cell surrounding by at
  ;; least 19 patches of LU 4, 8 or 9 ? Report 1 if yes and 0 if
  ;; no. Add the number of cells=1 and divide by the total number of
  ;; cells.
  ask patches [set bird-suitable 0]
  ask patches with [(LU = 4) or (LU = 8) or (LU = 9)] [
  if (count patches with [((distance myself) <= 4) and ((LU = 4) or (LU = 8) or (LU = 9))] >= 19) [
        set bird-suitable 1]]
  set bird-suitability-index ((sum [bird-suitable] of patches) / (world-size ^ 2))
  ;; compute CO2 equivalent emissions
  ask patches [set CO2eq item (LU - 1) landuse-CO2eq]
  set previous-CO2eq total-CO2eq
  set total-CO2eq sum [CO2eq] of patches
  ;; compute gross margin values per LU (ref Herzig et al) for each
  ;; patch, and compute the total
  ask patches [
    set value$ (ifelse-value
    ;; Artificial: 300,000$/ha when agricultural land is converted
    ;; into artificial. It’s a one-off.
    (LU = 1) [ifelse-value (landuse-age = 0) [300000] [0] ]
    ;; Water: 0 yield and 0$
    (LU = 2) [0]
    ;; Annual crops: 10t/ha (yield), 450$/t
    (LU = 3) [450 * crop-yield]
    ;; Perennial crops: 20t/ha (yield), 2500$/t
    (LU = 4) [3500 * crop-yield]
    ;; Intensive pasture: 1.1 t/ha (yield), 10,000$/t
    (LU = 5) [10000 * livestock-yield]
    ;; Extensive pasture: 0.3 t/ha (yield), 5,500$/t
    (LU = 6) [5500 * livestock-yield]
    ;; Scrub 0,0
    (LU = 7) [0]
    ;; Natural forest 0,0
    (LU = 8) [0]
    ;; Exotic forest: 4500$/ha
    (LU = 9) [4500]
    ;; should never occur
    [-99999999])]
  set previous-total-value$ total-value$
  set total-value$ sum [value$] of patches
end

to add-landuse-option [option]
  ;; add a land use to the options to choose from when making a change
  set landuse-options lput option landuse-options
end

to basic-LU-rule
  ;; execute basic rule
  ask farmers [
    ;;will continue to trigger behaviour after 30 iterations.
    if (landuse-age mod decision-interval) = 0
    [(ifelse
      (behaviour = 1) [if LU = 1
          [ask one-of neighbors [
              if LU = 3 or LU = 4 or LU = 6 or LU = 7 [add-landuse-option 1]]]]
      (behaviour = 2) [(ifelse
        (LU = 1) [ask one-of neighbors [if LU != 1 [add-landuse-option 1]]]
        (LU = 3) [add-landuse-option one-of [6 4]]
        (LU = 6) [add-landuse-option one-of [6 4 3]]
        (LU = 7) [add-landuse-option one-of [7 9]]
        (LU = 9) [add-landuse-option one-of [9 7]]
        [do-nothing])]
      (behaviour = 3) [(ifelse
        (LU = 3) [add-landuse-option one-of [4]]
        (LU = 4) [add-landuse-option one-of [4 8]]
        (LU = 6) [add-landuse-option one-of [4 3]]
        (LU = 7) [add-landuse-option one-of [7 8 9]]
        (LU = 9) [add-landuse-option one-of [9 8 7]]
        [do-nothing])]
      [do-nothing])]]
end

to LU-neighbour-rule
  ;; execute neighbourhood
  ask farmers [
    ;; a list counting network members of this farmer with particular land uses
    let count-LU
      map [this-LU -> count neighbors with [LU = this-LU]]
      landuse-code
    ;; landuse of network membesr with the maximum count.  If a tie, then is the first (or random?) LU
    set LUneighbour position max count-LU landuse-code
    if (landuse-age mod decision-interval ) = 0
     [(ifelse
        (behaviour = 1) [
           if LU = 3 or LU = 4 or LU = 6 or LU = 7 or LU = 5 or LU = 9 and LUneighbour = 1 [add-landuse-option 1]]
        (behaviour = 2) [
          add-landuse-option (ifelse-value
            (LU != 1 and LUneighbour = 1) [1]
            (LU = 4 or LU = 5 or LU = 6 or LU = 7 and LUneighbour = 3) [3]
            (LU = 3 or LU = 6 or LU = 7 and LUneighbour = 4) [4]
            (LU = 3 or LU = 4 or LU = 7 and LUneighbour = 6) [6]
            (LU = 3 or LU = 5 or LU = 9 and LUneighbour = 7) [7]
            (LU = 3 or LU = 5 or LU = 7 and LUneighbour = 9) [9]
            [LU])]
        (behaviour = 3) [
            add-landuse-option (ifelse-value
              (LU = 6 or LU = 7 and LUneighbour = 3) [3]
              (LU = 3 or LU = 6 or LU = 7 and LUneighbour = 4) [4]
              (LU = 3 or LU = 6 and LUneighbour = 7) [7]
              (LU = 7 and LUneighbour = 9) [9]
              (LU != 8 and LU != 1 and LUneighbour = 8) [8]
              [LU])]
        [do-nothing]       ;actually should never happen because only 3 behaviours, but require an else clause
      )]]
end

to LU-network-rule
  ;; compute network most common land use
  ask landuse-networks [
    ;; count land uses in this network
    let landuse-counts
        map [this-LU -> count my-landuse-network-links with [[LU] of other-end = this-LU]]
        landuse-code
    ; ;; find the most common land use
    let max-landuse-count-index position (max landuse-counts) landuse-counts
    set most-common-landuse item max-landuse-count-index landuse-code
    let this-most-common-landuse most-common-landuse
    ;; inform famers in the network, gross use of myself due to nested ask statements
    ask my-landuse-network-links [
      ask other-end [set LUnetwork this-most-common-landuse]]]
  ;; farmer decision
  ask farmers [
    if (landuse-age mod decision-interval ) = 0
    [(ifelse
        (behaviour = 1) [
           if LU = 3 or LU = 4 or LU = 6 or LU = 7 or LU = 5 or LU = 9 and LUnetwork = 1 [add-landuse-option 1]]
        (behaviour = 2) [
          add-landuse-option (ifelse-value
            (LU != 1 and LUnetwork = 1) [1]
            (LU = 4 or LU = 5 or LU = 6 or LU = 7 and LUnetwork = 3) [3]
            (LU = 3 or LU = 6 or LU = 7 and LUnetwork = 4) [4]
            (LU = 3 or LU = 4 or LU = 7 and LUnetwork = 6) [6]
            (LU = 3 or LU = 5 or LU = 9 and LUnetwork = 7) [7]
            (LU = 3 or LU = 5 or LU = 7 and LUnetwork = 9) [9]
            [LU])]
        (behaviour = 3) [
            add-landuse-option (ifelse-value
              (LU = 6 or LU = 7 and LUnetwork = 3) [3]
              (LU = 3 or LU = 6 or LU = 7 and LUnetwork = 4) [4]
              (LU = 3 or LU = 6 and LUnetwork = 7) [7]
              (LU = 7 and LUnetwork = 9) [9]
              (LU != 8 and LU != 1 and LUnetwork = 8) [8]
              [LU])]
        [do-nothing]       ;actually should never happen because only 3 behaviours, but require an else clause
      )]]
end

to economy-rule
  if previous-total-value$ < total-value$
  [ask n-of (5 * count patches with [LU = 3 ] / 100) patches [set LU one-of [4 6]]
   ask n-of (5 * count patches with [LU = 6 ] / 100) patches [set LU one-of [4 ]]
   ask n-of (5 * count patches with [LU = 7 ] / 100) patches [set LU one-of [3 4 6]]]
end

to reduce-emission-rule
   if previous-CO2eq > total-CO2eq
  [ask n-of (10 * count patches with [LU = 6 ] / 100) patches [set LU one-of [3 4]]
   ask n-of (10 * count patches with [LU = 7 ] / 100) patches [set LU one-of [9]]]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; user interface functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-display
  ;; any display updates that are not in the display widgets goes here
  ;;
  ;; set labels on map to something
  (ifelse
    (map-label = "land use") [ ask patches [set plabel LU] ]
    (map-label = "value") [ask patches [set plabel value$]]
    (map-label = "emissions") [ask patches [set plabel CO2eq]]
    (map-label = "land use age") [ask patches [set plabel landuse-age]]
    (map-label = "carbon stock") [ask patches [set plabel carbon-stock]]
    (map-label = "bird suitable") [ask patches [set plabel bird-suitable]]
    (map-label = "pollinated") [ask patches [set plabel pollinated]]
  [ask patches [set plabel ""]])
  ;; set color of patches to something
  (ifelse
    (map-color = "land use") [ask patches [set pcolor item (LU - 1) landuse-color]]
    (map-color = "carbon stock") [ask patches [set pcolor
          (brightness-map brown (max landuse-carbon-stock-maximum) carbon-stock)]]
    (map-color = "emissions") [ask patches [set pcolor
          (brightness-map orange (max landuse-CO2eq) CO2eq)]]
    (map-color = "bird suitable") [ask patches [set pcolor
          (brightness-map magenta 1 bird-suitable)]]
    (map-color = "pollinated") [ask patches [set pcolor
          (brightness-map yellow 1 pollinated)]]
    (map-color = "network") [
        ask landuse-networks [
          let this-color network-color
          ask my-landuse-network-links [
      ask other-end [set pcolor this-color]]]]
  [ask patches [set pcolor ""]])
end

;;;;;;;;;;;;;;;;;;;;;;;
;; utility functions ;;
;;;;;;;;;;;;;;;;;;;;;;;


to-report trim-whitespace-and-quotes [string]
  ;; remove all spaces and ' and " from beginning and end of a string
  foreach [" " "\"" "'"] [ char ->
    while [(first string) = char] [set string (remove-item 0 string)]
    while [(last string) = char] [set string (remove-item ((length string) - 1) string)]
  ]
  report string
end

to-report brightness-map [colour max-value value]
  ;; return a brightness variation of colour for values within
  ;; max-value, e.g., [brown 1.2 5].  This could be replaced with the
  ;; built-in function "scale-color". That might perform better, but
  ;; has slightly more complex inputs.
  report (colour + 4 - ((min (list max-value value)) / max-value * 5 ))
end


to-report choose [choices weights]
  ;; Make a single random selection of choices distributed according
  ;; to weights. Thes are two lists of the same length.  If under
  ;; performing the built-in rnd extensions provides the same
  ;; functionality.
  let cumulative-weights (list)
  foreach weights [ weight ->
    (ifelse ((length cumulative-weights) = 0)
        [set cumulative-weights (list weight)]
        [set cumulative-weights
          (lput ((last cumulative-weights) + weight) cumulative-weights)])]
  ;; make the choicex
  let random-value (random-float (last cumulative-weights))
  let index 0
  while [(random-value > (item index cumulative-weights))] [
      set index (index + 1)]
  report item index choices
end

to do-nothing
  ;; a command that does nothing
end

to raise-error [message]
  ;; a command that stops the program and prints a message
  print "error"
  print message
  stop
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; user interface elements ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;
@#$#@#$#@
GRAPHICS-WINDOW
300
88
908
697
-1
-1
24.0
1
12
1
1
1
0
0
0
1
0
24
0
24
1
1
1
ticks
30.0

BUTTON
5
32
68
65
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
7
284
220
317
number-of-landuse-networks
number-of-landuse-networks
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
210
736
417
769
landuse-correlated-range
landuse-correlated-range
1
10
4.0
1
1
NIL
HORIZONTAL

INPUTBOX
27
934
154
994
artificial-weight
10.0
1
0
Number

INPUTBOX
159
934
284
998
water-weight
10.0
1
0
Number

INPUTBOX
422
935
548
995
crop-perennial-weight
10.0
1
0
Number

INPUTBOX
554
934
679
994
scrub-weight
10.0
1
0
Number

INPUTBOX
684
934
811
994
intensive-pasture-weight
10.0
1
0
Number

INPUTBOX
815
932
947
995
extensive-pasture-weight
10.0
1
0
Number

INPUTBOX
962
934
1087
994
native-forest-weight
10.0
1
0
Number

INPUTBOX
1094
935
1224
995
exotic-forest-weight
10.0
1
0
Number

INPUTBOX
27
1014
152
1074
artificial-crop-yield
0.0
1
0
Number

INPUTBOX
162
1014
287
1074
water-crop-yield
0.0
1
0
Number

INPUTBOX
292
1014
420
1074
crop-annual-crop-yield
10.0
1
0
Number

INPUTBOX
289
1014
422
1074
crop-annual-crop-yield
10.0
1
0
Number

INPUTBOX
424
1014
549
1074
crop-perennial-crop-yield
20.0
1
0
Number

INPUTBOX
559
1014
684
1074
scrub-crop-yield
0.0
1
0
Number

INPUTBOX
694
1014
819
1074
intensive-pasture-crop-yield
0.0
1
0
Number

INPUTBOX
829
1014
954
1074
extensive-pasture-crop-yield
0.0
1
0
Number

INPUTBOX
964
1014
1089
1074
native-forest-crop-yield
0.0
1
0
Number

INPUTBOX
1099
1014
1224
1074
exotic-forest-crop-yield
0.0
1
0
Number

INPUTBOX
29
1098
154
1158
artificial-livestock-yield
0.0
1
0
Number

INPUTBOX
162
1098
287
1158
water-livestock-yield
0.0
1
0
Number

INPUTBOX
289
1098
422
1158
crop-annual-livestock-yield
0.0
1
0
Number

INPUTBOX
424
1098
549
1158
crop-perennial-livestock-yield
0.0
1
0
Number

INPUTBOX
559
1098
684
1158
scrub-livestock-yield
0.0
1
0
Number

INPUTBOX
694
1098
819
1158
intensive-pasture-livestock-yield
1.1
1
0
Number

INPUTBOX
829
1098
954
1158
extensive-pasture-livestock-yield
0.3
1
0
Number

INPUTBOX
964
1098
1089
1158
native-forest-livestock-yield
0.0
1
0
Number

INPUTBOX
1099
1098
1224
1158
exotic-forest-livestock-yield
0.0
1
0
Number

INPUTBOX
27
1183
152
1243
artificial-CO2eq
0.0
1
0
Number

INPUTBOX
162
1183
287
1243
water-CO2eq
0.0
1
0
Number

INPUTBOX
289
1184
422
1244
crop-annual-CO2eq
95.0
1
0
Number

INPUTBOX
424
1184
549
1244
crop-perennial-CO2eq
90.0
1
0
Number

INPUTBOX
559
1184
684
1244
scrub-CO2eq
0.0
1
0
Number

INPUTBOX
694
1184
819
1244
intensive-pasture-CO2eq
480.0
1
0
Number

INPUTBOX
829
1184
954
1244
extensive-pasture-CO2eq
150.0
1
0
Number

INPUTBOX
964
1184
1089
1244
native-forest-CO2eq
0.0
1
0
Number

INPUTBOX
1099
1184
1224
1244
exotic-forest-CO2eq
0.0
1
0
Number

INPUTBOX
29
1268
154
1328
artificial-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
164
1268
289
1328
water-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
289
1268
422
1328
crop-annual-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
426
1268
551
1328
crop-perennial-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
559
1268
684
1328
scrub-carbon-stock-rate
3.5
1
0
Number

INPUTBOX
696
1268
821
1328
intensive-pasture-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
829
1268
954
1328
extensive-pasture-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
966
1268
1091
1328
native-forest-carbon-stock-rate
8.0
1
0
Number

INPUTBOX
1102
1268
1227
1328
exotic-forest-carbon-stock-rate
25.0
1
0
Number

INPUTBOX
29
1351
154
1411
artificial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
164
1351
289
1411
water-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
289
1351
422
1411
crop-annual-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
424
1351
549
1411
crop-perennial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
559
1351
684
1411
scrub-carbon-stock-maximum
100.0
1
0
Number

INPUTBOX
694
1351
819
1411
intensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
829
1351
954
1411
extensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
964
1351
1089
1411
native-forest-carbon-stock-maximum
250.0
1
0
Number

INPUTBOX
1099
1351
1224
1411
exotic-forest-carbon-stock-maximum
700.0
1
0
Number

MONITOR
1230
940
1369
985
Total weight
sum landuse-weight
17
1
11

INPUTBOX
290
932
407
996
crop-annual-weight
10.0
1
0
Number

PLOT
1249
33
1888
529
Total land use
Time
%
0.0
10.0
0.0
1.0
true
true
"" "if (ticks > 0 ) [\n  foreach landuse-code [this-LU ->\n    set-current-plot-pen (item (this-LU - 1) landuse-name)\n    plot count patches with [LU = this-LU] / (world-size * world-size) * 100]]\n"
PENS
"artificial" 1.0 0 -7500403 true "" ""
"water" 1.0 0 -6759204 true "" ""
"crop annual" 1.0 0 -1184463 true "" ""
"crop perennial" 1.0 0 -5825686 true "" ""
"scrub" 1.0 0 -817084 true "" ""
"intensive pasture" 1.0 0 -13840069 true "" ""
"extensive pasture" 1.0 0 -8732573 true "" ""
"native forest" 1.0 0 -15302303 true "" ""
"exotic forest" 1.0 0 -13210332 true "" ""

SWITCH
149
515
288
548
Neighbourhood
Neighbourhood
0
1
-1000

SWITCH
5
573
145
606
Network
Network
1
1
-1000

BUTTON
76
32
139
65
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

INPUTBOX
8
340
132
402
BAU-weight
33.0
1
0
Number

INPUTBOX
139
340
263
401
industry-weight
33.0
1
0
Number

INPUTBOX
7
405
131
468
CC-weight
34.0
1
0
Number

SLIDER
9
245
221
278
decision-interval
decision-interval
0
10
6.0
1
1
NIL
HORIZONTAL

SWITCH
4
515
143
548
Baseline
Baseline
0
1
-1000

SWITCH
8
155
122
188
fixed-seed
fixed-seed
0
1
-1000

BUTTON
148
33
224
66
go once
go
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

PLOT
921
529
1244
689
Total emissions
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot sum [CO2eq] of patches]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
923
365
1243
525
Total crop yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot sum [crop-yield] of patches]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
918
32
1242
192
Total value
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0) [plot sum [value$] of patches]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
920
197
1244
359
Total livestock yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot sum [livestock-yield] of patches]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
921
694
1248
853
Total carbon stock
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot sum [carbon-stock] of patches]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1249
531
1575
686
Diversity index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot diversity-index]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1250
693
1574
858
Contiguity index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot contiguity-index]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1577
533
1889
687
Pollination index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot pollination-index]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1580
690
1892
857
Bird suitability index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot bird-suitability-index]"
PENS
"" 1.0 0 -15973838 true "" ""

SWITCH
7
632
145
665
Industry-level
Industry-level
0
1
-1000

SWITCH
149
633
286
666
Government-level
Government-level
0
1
-1000

TEXTBOX
8
222
153
240
Farmers
16
0.0
1

TEXTBOX
29
917
387
947
Weight (initial random distribution)
12
0.0
1

TEXTBOX
7
493
141
511
Fine scale
12
0.0
1

TEXTBOX
5
554
157
573
Intermediate scale
12
0.0
1

TEXTBOX
7
611
147
631
Landscape rules
12
0.0
1

CHOOSER
20
734
200
779
initial-landuse-source
initial-landuse-source
"gis-vector" "gis-raster" "random"
0

CHOOSER
24
829
204
874
landuse-parameter-source
landuse-parameter-source
"preset: default" "preset: forest" "csv file" "manual entry"
2

CHOOSER
442
35
567
80
map-label
map-label
"land use" "value" "emissions" "land use age" "carbon stock" "bird suitable" "pollinated" "none"
0

CHOOSER
299
35
435
80
map-color
map-color
"land use" "network" "carbon stock" "emissions" "bird suitable" "pollinated"
0

INPUTBOX
672
733
897
793
gis-vector-filename
gis_data/example_vector.shp
1
0
String

INPUTBOX
432
732
664
792
gis-raster-filename
gis_data/example_raster.grd
1
0
String

INPUTBOX
217
829
494
889
landuse-data-csv-filename
land_use_parameters/test.csv
1
0
String

SLIDER
6
73
291
106
world-size
world-size
5
100
25.0
5
1
NIL
HORIZONTAL

TEXTBOX
916
10
1171
28
World statistics
16
0.0
1

TEXTBOX
4
10
181
30
Model
16
0.0
1

TEXTBOX
5
474
178
495
Agent rules
16
0.0
1

TEXTBOX
300
10
392
30
World map
16
0.0
1

TEXTBOX
20
710
216
730
Initialise land use
16
0.0
1

BUTTON
232
33
290
66
replot
update-display
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

TEXTBOX
8
324
247
344
Distribution of random attitude
12
0.0
1

TEXTBOX
24
799
230
822
Land use parameters\n
16
0.0
1

TEXTBOX
27
998
177
1016
Crop yield
12
0.0
1

TEXTBOX
29
1079
179
1097
Livestock yield
12
0.0
1

TEXTBOX
29
1164
179
1182
Emissions
12
0.0
1

TEXTBOX
29
1249
179
1267
Carbon stock rate
12
0.0
1

TEXTBOX
29
1338
179
1358
Carbon stock maximum
12
0.0
1

TEXTBOX
28
896
385
914
Current land use values and manual entry
16
0.0
1

INPUTBOX
129
156
216
216
seed
99.0
1
0
Number

SLIDER
8
113
292
146
years-to-run-before-stopping
years-to-run-before-stopping
0
100
51.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
