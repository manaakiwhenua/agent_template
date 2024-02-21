extensions [gis]                ; GIS extension

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
  landuse-value                 ; annual profit per patch
  landuse-CO2eq                 ; carbon-equivalent emissions per patch
  landuse-crop-yield            ; t/ha
  landuse-livestock-yield       ; t/ha
  landuse-carbon-stock-annual-rate ; amount of carbon stored annually

  ;; land use networks
  ;; number-of-landuse-networks     ; how many distinct networks, set in interface

  ;; GIS
  gis-vector-data                      ; data object containg GIS info
  gis-raster-data                      ; data object containg GIS info
  ;; gis-raster-filename               ; spruce of raster data, set in interface
  ;; gis-vector-filename               ; spruce of filename data, set in interface

  ;; land use initial distribution, set in interface
  ;; artificial%
  ;; water%
  ;; annual-crops%
  ;; perennial-crops%
  ;; scrub%
  ;; intensive-pasture%
  ;; extensive-pasture%
  ;; natural-forest%
  ;; exotic-forest%

  ;; farmer attitude distribution, set in interface
  ;; BAU%                          ; business-as-usual
  ;; Industry%                     ; industry-conscious
  ;; CC%                           ; climate conscious

  ;; rules to apply, set in interface
  ;; Baseline ;
  ;; Neighbor ;
  ;; Network ;
  ;; Industry-level
  ;; Government-level

  ;; model initialisation
  ;; occurrence-max        ; farmer decisions staggered over this many years
  ;; world-size            ; of square grid
  ;; initial-landuse-source       ; method for setting this
  steps-to-run-before-stopping                  ;how many steps run when go is clicked
  stop-after-step                               ;stop going after this step


]

;; each patch is a parcel of land
patches-own [
  LU           ; current land use
  CO2eq        ; Annual carbon-equivalent emissions (t/ha) of a patch
  value$       ; Annual profit (NZD) of a patch
  landuse-age  ; the number of ticks since this land use was initiated
  landuse-options ; new land use options the farmer is somehow motivated to choose from
  crop-yield      ; t/ha
  livestock-yield      ; t/ha
  carbon-stock  ; stored carbon, t/ha
]

;; a farmer, in divisible from its land
breed [farmers farmer]
farmers-own [
  ; My-plot
  behaviour                    ; behaviour type
  LUnetwork                    ; most common land use in large scale network
  LUneighbor                   ; most common land use among neighbors
  first-occurrence             ; tick offset for decisions
  ; list-neighbor ; not used
  ; list-network  ; not used
]

;; a network associating farmers
breed [landuse-networks landuse-network]
landuse-networks-own [
  most-common-landuse  ; most common land use in each network
  network-color        ; for plotting
]

;; links between farmers and a landusse-network
undirected-link-breed [landuse-network-links landuse-network-link]

;;###################################################################### SETUP #####################################################################################################################
to setup
  __clear-all-and-reset-ticks
  random-seed 99        ; set a specific random seed to see whether output is changed in detail by code changes, for development and debugging only
  ;; control how long model goes for
  set steps-to-run-before-stopping 30
  set stop-after-step steps-to-run-before-stopping
  ;; model paramaters
  set landuse-code                     [ 1            2       3             4                5       6                   7                   8               9               ]
  set landuse-name                     [ "artificial" "water" "crop annual" "crop perennial" "scrub" "intensive pasture" "extensive pasture" "native forest" "exotic forest" ]
  set landuse-color                    [ 8            87      45            125              26      65                  56                  73              63              ]
  set landuse-value                    [ 50000        0       2000          15000            0       4000                1400                0               1150            ]
  set landuse-CO2eq                    [ 0            0       95            90               -100    480                 150                 -250            -700            ]
  set landuse-crop-yield               [ 0            0       10            20               0       0                   0                   0               0               ]
  set landuse-livestock-yield          [ 0            0       0             0                0       1.1                 0.3                 0               0               ]
  set landuse-carbon-stock-annual-rate [ 0            0       0             0                0       0                   0                   8               25              ]
  ;; setup
  setup-world
  setup-gis-data
  setup-land
  setup-landuse-networks
  setup-farmers
  ;; update
  update-products
  update-display
end

to setup-world
  ;; setup the grid
  resize-world 0 ( world-size - 1 ) 0 ( world-size - 1 )
  set-patch-size 6 * 100 / world-size
end

to setup-gis-data
  ;; load and prepare GIS data if needed
  if (initial-landuse-source = "gis-vector") [
    ;; load polygons
    set gis-vector-data gis:load-dataset gis-vector-filename
    ;; link to world
    gis:set-world-envelope (gis:envelope-of gis-vector-data)
    ;; print what properties are defined for features
    ; show gis:property-names gis-data
    ;; HACK for test cast to randomly set landuse of each feature
    foreach gis:feature-list-of gis-vector-data [ feature ->
        gis:set-property-value feature "AREA" (( random  8 ) + 1 )]]
  if (initial-landuse-source = "gis-raster") [
    ;; load faster file
    set gis-raster-data gis:load-dataset gis-raster-filename
    ; show gis:minimum-of  gis-raster-data
    ; show gis:maximum-of  gis-raster-data
    ;; link to world
    gis:set-world-envelope (gis:envelope-of gis-raster-data)]
end

to setup-land                                                                            ;; setup the LU within the landscape
  ;; setup patches
  (ifelse
    ;; random uncorrelated land use
    (initial-landuse-source = "random") [
      ;; assign random land use within the initial distribution
      ask patches [
        let tiralea random-float (artificial% + water% + annual-crops%
                                  + perennial-crops% + intensive-pasture% + extensive-pasture%
                                  + scrub% + natural-forest% + exotic-forest%)                                                         ;; LU types are randomly setup within the landscape following a % given by the user in the interface
        set LU (ifelse-value ;set LU and pcolor according to the tiralea condition
        (tiralea < artificial%) [1]
        (tiralea < ( artificial% + water% )) [2]
        (tiralea < ( artificial% + water% + annual-crops%)) [3]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops%)) [4]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops% + scrub%)) [5]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops% + scrub% + intensive-pasture%)) [6]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops% + scrub% + intensive-pasture% + extensive-pasture%)) [7]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops% + scrub% + intensive-pasture% + extensive-pasture% + natural-forest%)) [8]
        (tiralea < ( artificial% + water% + annual-crops% + perennial-crops% + scrub% + intensive-pasture% + extensive-pasture% + natural-forest% + exotic-forest%)) [9]
    [10])]]
    ;; set to values in a shapfile
    (initial-landuse-source = "gis-vector") [
      ;; single value default
      ask patches [ set LU 3 ]
      ;; landuse from gis-vector
      foreach gis:feature-list-of gis-vector-data [ feature ->
        gis:set-property-value feature "AREA" (( random  8 ) + 1 )
        let this-LU ( random  8 ) + 1 ; CORRECT?!?
        ask patches gis:intersecting feature [
    set LU gis:property-value feature "AREA"]]]
    ;; set to values in a raster file
    (initial-landuse-source = "gis-raster") [
      ask patches [
        ;; single value default
        set LU 3
        ;; set to raster value -- HACKED here because test data is not landuse integers
        set LU ( int gis:raster-sample gis-raster-data self )  mod 9 + 1]]
    ;; set directly to a single value
    [ask patches [set LU initial-landuse-source]])
  ;; correlate land use
  correlate-land-use-into-squares
  ;; create one farmer per patch
  ask patches [sprout-farmers 1 [set shape "person" set size 0.5 set color black]]
end

to correlate-land-use-into-squares
  ;; loop through patches, stepping by correlated width
  foreach (range 0 world-width land-use-correlated-range) [x ->
    foreach (range 0 world-height land-use-correlated-range) [y ->
      ;; loop within correlated square
      foreach (range 0 land-use-correlated-range) [xoffset ->
        foreach (range 0 land-use-correlated-range) [yoffset ->
          ;; set value to top-left corner
          ask (patch (min (list (x + xoffset) (world-width - 1)))
                      (min (list (y + yoffset) (world-height - 1)))) [
            set LU [LU] of patch x y]]]]]
end

to setup-farmers
  ask farmers [
    ;; create 3 types of behaviour 1 is BAU, 2 is industry$, 3 is climate and environment concious
    let tiralea random-float 100
    set [behaviour color] (
      ifelse-value
        (tiralea < BAU%) [[1 red]]
        (tiralea < ( BAU% + Industry% )) [[2 blue]]
        [[3 white]])
    ;; Occurrence is the number of year a LU is setup That gives more
    ;; or less changing dynamic during the timeframe.
    set first-occurrence random occurrence-max
    ;; Set the amount of time the initial land use has been running
    ;; for based on first-occurrence.  This implies the initial land
    ;; use was implemented exactly at the decision time for each
    ;; farmer directly preceding the model start
    ask patch-here [ set landuse-age (occurrence-max - 1 - [first-occurrence] of myself ) ]
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

;;######################################################################## GO ##############################################################


to go
  ;; setup if not setup
  if (stop-after-step = 0) [setup]
  ;; run the model until it hits 'stop'
  ;; initialise options to choose from
  ask patches [ set landuse-options [] ]
  ;; execute rules, adding to landuse-options that are chosen from
  ;; below
  if Baseline [basic-LU-rule]
  if Neighborhood [LU-neighbor-rule]
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
  ;;  if Combine = true [basic-LU-rule LU-neighbor-rule LU-network-rule]
  ;; recompute things derived from the landuse
  update-products
  ;; update the display window in various ways
  update-display
  ;; step time, age land, and stop model
  ask patches [set landuse-age (landuse-age + 1)]
  tick
  if ticks >= stop-after-step [
    set stop-after-step ( stop-after-step + steps-to-run-before-stopping )
  stop ]
end

to update-products
  ;; Compute crop yields
  ask patches [set crop-yield item (LU - 1) landuse-crop-yield]
  ;; compute livestock yields
  ask patches [set livestock-yield item (LU - 1) landuse-livestock-yield]
  ;; compute carbon stock
  ask patches [set carbon-stock (landuse-age * (item (LU - 1) landuse-carbon-stock-annual-rate))]
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
  set pollination-index 0
  ask patches with [LU = 5] [
    ask patches with [((distance myself) <= 4) and ((LU = 3) or (LU = 4))] [
        set pollination-index (pollination-index + 1)]]
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
  set bird-suitability-index 0
  ask patches with [(LU = 4) or (LU = 8) or (LU = 9)] [
    if (count patches with [((distance myself) <= 4) and ((LU = 4) or (LU = 8) or (LU = 9))]
         >= 19) [set bird-suitability-index (bird-suitability-index + 1)]]
  set bird-suitability-index (bird-suitability-index / (world-size ^ 2))
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
    [-99999999]
  )]
  set previous-total-value$ total-value$
  set total-value$ sum [value$] of patches
end

to update-display
  ;; update default display
  ;; set map to landuse
  set-patch-color-to-landuse
  ;; no labels on map
  (ifelse
    (map-label = "landuse code") [ ask patches [set plabel LU] ]
    (map-label = "landuse value") [ask patches [set plabel value$]]
    (map-label = "CO2eq") [ask patches [set plabel CO2eq]]
    (map-label = "landuse age") [ask patches [set plabel landuse-age]]
    (map-label = "carbon stock") [ask patches [set plabel carbon-stock]]
  [ask patches [set plabel ""]])
  ;; update time series
  Map-LU
end

to add-landuse-option [option]
  ;; add a land use to the option to choose from when making a change
  set landuse-options lput option landuse-options
end

to basic-LU-rule
  ;; execute basic rule
  ask farmers [
  ;;will continue to trigger behaviour after 30 iterations.
  if (ticks mod occurrence-max ) =  first-occurrence
    [(ifelse
      (behaviour = 1) [if LU = 1 [ask one-of neighbors
                          [if LU = 3 or LU = 4 or LU = 6 or LU = 7
                              [add-landuse-option 1]]]]
      (behaviour = 2) [(ifelse
        (LU = 1) [ask one-of neighbors [if LU != 1 [add-landuse-option 1]]]
        (LU = 3) [add-landuse-option one-of [6 4]]
        (LU = 6) [add-landuse-option one-of [6 4 3]]
        (LU = 7) [add-landuse-option one-of [7 9]]
        (LU = 9) [add-landuse-option one-of [9 7]]
        [do-nothing])]
      (behaviour = 3) [(ifelse
        (behaviour = 3) [if LU = 3 [add-landuse-option one-of [4]]]
        (behaviour = 3) [if LU = 4 [add-landuse-option one-of [4 8]]]
        (behaviour = 3) [if LU = 6 [add-landuse-option one-of [4 3]]]
        (behaviour = 3) [if LU = 7 [add-landuse-option one-of [7 8 9]]]
        (behaviour = 3) [if LU = 9 [add-landuse-option one-of [9 8 7]]]
        [do-nothing])]
      [do-nothing])]]
end

to LU-neighbor-rule
  ;; execute neighborhood
  ask farmers [
    ;; a list counting network members of this farmer with particular land uses
    let count-LU
      map [this-LU -> count neighbors with [LU = this-LU]]
      landuse-code
    ;; landuse of network membesr with the maximum count.  If a tie, then is the first (or random?) LU
    set LUneighbor position max count-LU landuse-code
    if (ticks mod occurrence-max ) = first-occurrence
     [(ifelse
        (behaviour = 1) [
           if LU = 3 or LU = 4 or LU = 6 or LU = 7 or LU = 5 or LU = 9 and LUneighbor = 1 [add-landuse-option 1]]
        (behaviour = 2) [
          add-landuse-option (ifelse-value
            (LU != 1 and LUneighbor = 1) [1]
            (LU = 4 or LU = 5 or LU = 6 or LU = 7 and LUneighbor = 3) [3]
            (LU = 3 or LU = 6 or LU = 7 and LUneighbor = 4) [4]
            (LU = 3 or LU = 4 or LU = 7 and LUneighbor = 6) [6]
            (LU = 3 or LU = 5 or LU = 9 and LUneighbor = 7) [7]
            (LU = 3 or LU = 5 or LU = 7 and LUneighbor = 9) [9]
            [LU])]
        (behaviour = 3) [
            add-landuse-option (ifelse-value
              (LU = 6 or LU = 7 and LUneighbor = 3) [3]
              (LU = 3 or LU = 6 or LU = 7 and LUneighbor = 4) [4]
              (LU = 3 or LU = 6 and LUneighbor = 7) [7]
              (LU = 7 and LUneighbor = 9) [9]
              (LU != 8 and LU != 1 and LUneighbor = 8) [8]
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
    if (ticks mod occurrence-max ) = first-occurrence
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

to set-patch-color-to-landuse
  ask patches [set pcolor item (LU - 1) landuse-color]
end

to set-patch-color-to-landuse-network
  ;; color patches to show landuse networks
  ask landuse-networks [
    let this-color network-color
    ask my-landuse-network-links [
      ask other-end [set pcolor this-color]
  ]]
end

;;########################################## INDICATORS  ############################################################################################################################################################################
to Map-LU                                                                                                    ;; report
  ;; LU% in the plot plot time-dependence of land use distribution.
  ;; The pen colors are hardcoded in the plot and not taken from
  ;; landuse-colors.  Perhaps a setup plot pen code could be added to address this
  set-current-plot "Map-LU"
  (foreach landuse-code [this-LU ->
    set-current-plot-pen (item (this-LU - 1) landuse-name)
    plot count patches with [LU = this-LU] / (world-size * world-size) * 100])
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
;;
@#$#@#$#@
GRAPHICS-WINDOW
329
125
937
734
-1
-1
30.0
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
19
0
19
1
1
1
ticks
30.0

BUTTON
6
32
69
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
12
237
236
270
number-of-landuse-networks
number-of-landuse-networks
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
8
195
234
228
land-use-correlated-range
land-use-correlated-range
1
10
3.0
1
1
NIL
HORIZONTAL

INPUTBOX
13
299
140
359
artificial%
3.0
1
0
Number

INPUTBOX
13
360
140
420
water%
5.0
1
0
Number

INPUTBOX
14
487
140
547
perennial-crops%
10.0
1
0
Number

INPUTBOX
147
360
292
420
scrub%
6.0
1
0
Number

INPUTBOX
13
549
140
609
intensive-pasture%
18.0
1
0
Number

INPUTBOX
147
299
291
359
extensive-pasture%
23.0
1
0
Number

INPUTBOX
147
423
292
483
natural-forest%
5.0
1
0
Number

INPUTBOX
147
487
287
547
exotic-forest%
20.0
1
0
Number

MONITOR
151
554
290
599
Land Use total
artificial% + water% + annual-crops% + perennial-crops% + intensive-pasture% + extensive-pasture% + scrub% + natural-forest% + exotic-forest%
17
1
11

INPUTBOX
13
423
140
483
annual-crops%
10.0
1
0
Number

PLOT
1265
367
1896
863
Map-LU
Time
%
0.0
10.0
0.0
1.0
true
true
"" ""
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
328
820
467
853
Neighborhood
Neighborhood
0
1
-1000

SWITCH
474
782
614
815
Network
Network
0
1
-1000

BUTTON
77
32
140
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
11
803
99
864
BAU%
33.0
1
0
Number

INPUTBOX
105
803
192
863
Industry%
33.0
1
0
Number

INPUTBOX
197
803
282
863
CC%
34.0
1
0
Number

SLIDER
158
150
317
183
occurrence-max
occurrence-max
0
10
7.0
1
1
NIL
HORIZONTAL

SWITCH
328
783
467
816
Baseline
Baseline
0
1
-1000

BUTTON
429
43
522
76
network
set-patch-color-to-landuse-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
759
41
859
74
CO2eq
ask patches [set plabel CO2eq]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
547
78
647
111
value
ask patches [set plabel value$]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
652
42
755
75
land use age
ask patches [set plabel landuse-age]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
652
79
754
112
carbon stock
ask patches [set plabel carbon-stock]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
547
42
648
75
land use code
ask patches [set plabel LU]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
330
43
423
77
land use
set-patch-color-to-landuse
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
147
32
210
65
step
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
949
197
1252
357
Total emissions
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "plot sum [CO2eq] of patches"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1568
36
1901
195
Total crop yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "plot sum [crop-yield] of patches"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
949
35
1249
194
Total value
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "plot sum [value$] of patches"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1252
35
1563
196
Total livestock yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "plot sum [livestock-yield] of patches"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1258
200
1564
358
Total carbon stock
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "plot sum [carbon-stock] of patches"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1569
200
1895
355
Diversity index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "plot diversity-index"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
949
363
1250
527
Contiguity index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "plot contiguity-index"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
950
529
1251
696
Pollination index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "plot pollination-index"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
949
699
1250
858
Bird suitability index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "plot bird-suitability-index"
PENS
"" 1.0 0 -15973838 true "" ""

SWITCH
618
783
779
816
Industry-level
Industry-level
0
1
-1000

SWITCH
619
820
778
853
Government-level
Government-level
0
1
-1000

TEXTBOX
16
778
208
796
Farmer behaviour%
16
0.0
1

TEXTBOX
15
282
240
312
Distribution of random land use (%)
12
0.0
1

TEXTBOX
333
767
467
785
Fine scale
12
0.0
1

TEXTBOX
475
769
590
787
Intermediate scale
12
0.0
1

TEXTBOX
618
768
713
787
Landscape rules
12
0.0
1

CHOOSER
6
141
151
186
initial-landuse-source
initial-landuse-source
"gis-vector" "gis-raster" "random"
2

CHOOSER
759
79
873
124
map-label
map-label
"landuse code" "landuse value" "CO2eq" "landuse age" "carbon stock" "none"
5

INPUTBOX
12
707
274
767
gis-vector-filename
gis_data/test/poly.shp
1
0
String

INPUTBOX
14
641
272
701
gis-raster-filename
gis_data/test/Mosquitos.grd
1
0
String

SLIDER
5
71
282
104
world-size
world-size
5
100
20.0
5
1
NIL
HORIZONTAL

TEXTBOX
331
27
424
51
Colour
12
0.0
1

TEXTBOX
545
26
624
46
Label
12
0.0
1

TEXTBOX
947
13
1202
31
World statistics
16
0.0
1

TEXTBOX
5
10
181
29
Control model
16
0.0
1

TEXTBOX
332
746
505
767
Agent rules
16
0.0
1

TEXTBOX
332
10
424
30
World map
16
0.0
1

TEXTBOX
8
118
204
138
Initialise model
16
0.0
1

TEXTBOX
12
623
200
646
Source of GIS land use
12
0.0
1

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
