globals
[
  value$
  total-value$
  previous-total-value$
  CO2eq
  total-CO2eq
  previous-CO2eq
  all-landuses                  ; a list of all possible landuses
  landuse-names
]




breed
[farmer farmers]

patches-own
[LU Nb-network]

farmer-own
[My-plot behaviour LUnetwork LUneighbor
first-occurrence list-neighbor list-network]

;;###################################################################### SETUP #####################################################################################################################
to setup
  __clear-all-and-reset-ticks
  random-seed 99                                                                       ;; set a specific random seed to see whether output is changed in detail by code changes, for development and debugging only


  set all-landuses [1 2 3 4 5 6 7 8 9] 
  set landuse-names ["artificial" "water" "crop annual" "crop perennial" "scrub" "intensive pasture" "extensive pasture" "native forest" "exotic forest"]


  setup-land
  ask patches
  [sprout-farmer 1 [set shape "person" set size 0.5 set color black]]                    ;; create one farmer per patch
  setup-plot
  setup-behaviour
  setup-network
  setup-occurrence
end

to setup-land                                                                            ;; setup the LU within the landscape
  ask patches
  [let tiralea random-float 100                                                         ;; LU types are randomly setup within the landscape following a % given by the user in the interface
    set [LU pcolor] (ifelse-value ;set LU and pcolor according to the tiralea condition
    (tiralea < artificial%) [[1 8]]
    (tiralea < ( artificial% + water% )) [[2 87]]
    (tiralea < ( artificial% + water% + annual_crops%)) [[3 45]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops%)) [[4 125]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops% + scrub%)) [[5 26]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops% + scrub% + intensive_pasture%)) [[6 65]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops% + scrub% + intensive_pasture% + extensive_pasture%)) [[7 56]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops% + scrub% + intensive_pasture% + extensive_pasture% + natural_forest%)) [[8 73]]
    (tiralea < ( artificial% + water% + annual_crops% + perennial_crops% + scrub% + intensive_pasture% + extensive_pasture% + natural_forest% + exotic_forest%)) [[9 63]]
    [[10 white]])]              ;final command is run if nothing matches above
end

to setup-plot                                                                              ;; create link between farmer and the patch he is standing on = he is owning
  ask farmer [set My-plot patch-here]
end

to setup-behaviour                                                                         ;; create 3 types of behaviour 1 is BAU, 2 is industry$, 3 is climate and environment concious
  ask farmer
  [let tiralea random-float 100
    set [behaviour color] (
      ifelse-value
        (tiralea < BAU%) [[1 red]]
        (tiralea < ( BAU% + Industry% )) [[2 blue]]
        [[3 white]])]
end

to setup-network                                                                         ;; create a number of networks that can influence the decision making, switch button
  ask patches [set nb-network random nbr_network + 1]
end

to setup-occurrence                                                                       ;; occurrence is the number of year a LU is setup. That gives more or less changing dynamic during the timeframe.
  ask farmer [ set first-occurrence random occurrence_max]
end

;;######################################################################## GO ##############################################################
to go

  if Baseline [basic-LU-rule]
  if Neighborhood [LU-neighbor-rule]
  if Network [LU-network-rule]
  ;;  if Combine = true [basic-LU-rule LU-neighbor-rule LU-network-rule]
  update-color
  message-landscape
  tick
  if ticks = 30 [stop]
  Map-LU
  ;;  count$
  Map-$
  Map-CO2eq
  ;; message-landscape
  ;; message-industry

end

to basic-LU-rule
  ask farmer [
  
  ;; ridiculous list to ensure changes are only made when the
  ;; occurrence allow it to happen ANH: replace these cases with a
  ;; modulo, will continue to trigger behaviour after 30 iterations.
  ;; I also used ticks in this predicate to remove the need to for teh
  ;; update-occurence function
  if (ticks mod occurrence_max ) =  first-occurrence

    [(ifelse

      (behaviour = 1) [if LU = 1 [ask one-of neighbors [if LU = 3 or LU = 4 or LU = 6 or LU = 7 [set LU 1]]]]                 ;; LU change rule under the baseline option

      (behaviour = 2) [(ifelse
        (LU = 1) [ask one-of neighbors [if LU != 1 [set LU 1]]]
        (LU = 3) [set LU one-of [6 4]]
        (LU = 6) [set LU one-of [6 4 3]]
        (LU = 7) [set LU one-of [7 9]]
        (LU = 9) [set LU one-of [9 7]]
        [else-do-nothing])]

      (behaviour = 3) [(ifelse
        (behaviour = 3) [if LU = 3 [set LU one-of [4]]]
        (behaviour = 3) [if LU = 4 [set LU one-of [4 8]]]
        (behaviour = 3) [if LU = 6 [set LU one-of [4 3]]]
        (behaviour = 3) [if LU = 7 [set LU one-of [7 8 9]]]
        (behaviour = 3) [if LU = 9 [set LU one-of [9 8 7]]]
        [else-do-nothing])]

      [else-do-nothing])]

  ]
end

to LU-neighbor-rule
  
  ask farmer [
    ;; a list counting network members of this farmer with particular land uses
    let count-LU 
      map [this-LU -> count neighbors with [LU = this-LU]]
      all-landuses
    ;; landuse of network membesr with the maximum count.  If a tie, then is the first (or random?) LU
    set LUneighbor position max count-LU all-landuses

    if (ticks mod occurrence_max ) = first-occurrence
     [(ifelse

        (behaviour = 1) [
           if LU = 3 or LU = 4 or LU = 6 or LU = 7 or LU = 5 or LU = 9 and LUneighbor = 1 [set LU 1]
         ]                  ;; LU change rule under the Neighborhood option

        (behaviour = 2) [
          set LU (ifelse-value
            (LU != 1 and LUneighbor = 1) [1]
            (LU = 4 or LU = 5 or LU = 6 or LU = 7 and LUneighbor = 3) [3]
            (LU = 3 or LU = 6 or LU = 7 and LUneighbor = 4) [4]
            (LU = 3 or LU = 4 or LU = 7 and LUneighbor = 6) [6]
            (LU = 3 or LU = 5 or LU = 9 and LUneighbor = 7) [7]
            (LU = 3 or LU = 5 or LU = 7 and LUneighbor = 9) [9]
            [LU])]

        (behaviour = 3) [
            set LU (ifelse-value
              (LU = 6 or LU = 7 and LUneighbor = 3) [3]
              (LU = 3 or LU = 6 or LU = 7 and LUneighbor = 4) [4]
              (LU = 3 or LU = 6 and LUneighbor = 7) [7]
              (LU = 7 and LUneighbor = 9) [9]
              (LU != 8 or LU != 1 and LUneighbor = 8) [8]
              [LU])]

        [else-do-nothing]       ;actually should never happen because only 3 behaviours, but require an else clause
      )]
      ]

end

to LU-network-rule
  
  ask farmer [
    ;; a list counting network members of this farmer with particular land uses
    let count-LU
      map [this-LU -> count patches with [nb-network = [nb-network] of myself and LU = this-LU]]
      all-landuses
    ;; landuse of network membesr with the maximum count.  If a tie, then is the first (or random?) LU
    set LUnetwork position max count-LU all-landuses

  if (ticks mod occurrence_max) = first-occurrence
    [set LU (ifelse-value

      (behaviour = 1 and ( LU = 3 or LU = 4 or LU = 6 or LU = 7 or LU = 5 or LU = 9 and LUnetwork = 1 )) [1]                    ;; LU change rule under the Network option

      (behaviour = 2 and ( LU != 1 and LUnetwork = 1)) [1]
      (behaviour = 2 and ( LU = 4 or LU = 5 or LU = 6 or LU = 7 and LUnetwork = 3)) [3]
      (behaviour = 2 and ( LU = 3 or LU = 6 or LU = 7 and LUnetwork = 4)) [4]
      (behaviour = 2 and ( LU = 3 or LU = 4 or LU = 7 and LUnetwork = 6)) [6]
      (behaviour = 2 and ( LU = 3 or LU = 5 or LU = 9 and LUnetwork = 7)) [7]
      (behaviour = 2 and ( LU = 3 or LU = 5 or LU = 7 and LUnetwork = 9)) [9]

      (behaviour = 3 and ( LU = 6 or LU = 7 and LUnetwork = 3)) [3]
      (behaviour = 3 and ( LU = 3 or LU = 6 or LU = 7 and LUnetwork = 4)) [4]
      (behaviour = 3 and ( LU = 3 or LU = 6 and LUnetwork = 7)) [7]
      (behaviour = 3 and ( LU = 7 and LUnetwork = 9)) [9]
      (behaviour = 3 and ( LU != 8 or LU != 1 and LUnetwork = 8)) [8]

      [LU])]                     ;else no change in value

  ]
end

to message-landscape                                                                                                                ;; procedures for the top-down process
  count$
  countCO2eq
  ;;countenv
  if Industry-level = true [economy-rule]
  if Government-level = true [reduce-emission-rule]
end

to count$
  ask patches                                                                                                                       ;; define gross margin values per LU (ref Herzig et al)
 [set value$ (ifelse-value
    (LU = 1) [50000]
    (LU = 2) [0]
    (LU = 3) [2000]
    (LU = 4) [15000]
    (LU = 5) [0]
    (LU = 6) [4000]
    (LU = 7) [1400]
    (LU = 8) [0]
    (LU = 9) [1150]
    [value$])]
  set previous-total-value$ total-value$
  set total-value$ 0
  set total-value$ sum [value$] of patches
end

to countCO2eq
  ask patches                                                                                                                       ;; define CO2 equivalent emission per LU (source OLW, Vannier et al)
  [set CO2eq (ifelse-value
    (LU = 1) [0]
    (LU = 2) [0]
    (LU = 3) [95]
    (LU = 4) [90]
    (LU = 5) [-100]
    (LU = 6) [480]
    (LU = 7) [150]
    (LU = 8) [-250]
    (LU = 9) [-700]
    [CO2eq])]
  set previous-CO2eq total-CO2eq
  set total-CO2eq 0
  set total-CO2eq sum [CO2eq] of patches
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

to update-color
  ask patches [
    set pcolor (ifelse-value
    (LU = 1) [8]
    (LU = 2) [87]
    (LU = 3) [45]
    (LU = 4) [125]
    (LU = 5) [26]
    (LU = 6) [65]
    (LU = 7) [56]
    (LU = 8) [73]
    (LU = 9) [63]
    [white])]
end


;;########################################## INDICATORS  ############################################################################################################################################################################

to show-network                                                                                               ;; procedure for the interface button - to see the network in the landacpe instead of the LU
  ask farmer [set pcolor (nb-network + 10)]
end

;; ANH: this the sanme function as update-color?
to show-map-LU                                                                                                ;; reverse procedure to go back to the LU visualisation in the iterface
  ask patches  [
    set pcolor (ifelse-value
    (LU = 1) [8]
    (LU = 2) [87]
    (LU = 3) [45]
    (LU = 4) [125]
    (LU = 5) [26]
    (LU = 6) [65]
    (LU = 7) [56]
    (LU = 8) [73]
    (LU = 9) [63]
    [white])]
end

to Map-LU                                                                                                    ;; report LU% in the plot
  set-current-plot "Map-LU"
  (foreach landuse-names all-landuses this-map-lu)
end

;; a small function used by Map-LU
to this-Map-LU [this-pen this-LU]
    set-current-plot-pen this-pen
    plot count patches with [LU = this-LU] / 100 
end

to Map-$                                                                                                 ;; report total revenue of the landscape in the plot
  set-current-plot "Map-$"
  set-current-plot-pen "$"
  plot total-value$
  set-current-plot-pen "$year-1"
  plot previous-total-value$
end

to Map-CO2eq                                                                                             ;; report total landscape emissions in the plot
  set-current-plot "Map-CO2eq"
  set-current-plot-pen "CO2eq"
  plot total-CO2eq
  set-current-plot-pen "CO2eq previous"
  plot previous-CO2eq
end

;; a command that does nothing
to else-do-nothing
end

@#$#@#$#@
GRAPHICS-WINDOW
320
21
981
683
-1
-1
6.47
1
10
1
1
1
0
0
0
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
17
22
80
55
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
164
459
287
492
nbr_network
nbr_network
0
10
2.0
1
1
NIL
HORIZONTAL

INPUTBOX
16
98
143
158
artificial%
3.0
1
0
Number

INPUTBOX
16
160
143
220
water%
5.0
1
0
Number

INPUTBOX
17
286
143
346
perennial_crops%
10.0
1
0
Number

INPUTBOX
17
471
143
531
scrub%
6.0
1
0
Number

INPUTBOX
16
348
143
408
intensive_pasture%
18.0
1
0
Number

INPUTBOX
17
410
143
470
extensive_pasture%
23.0
1
0
Number

INPUTBOX
17
533
143
593
natural_forest%
5.0
1
0
Number

INPUTBOX
17
596
144
656
exotic_forest%
20.0
1
0
Number

MONITOR
17
659
144
704
Land Use total
artificial% + water% + annual_crops% + perennial_crops% + intensive_pasture% + extensive_pasture% + scrub% + natural_forest% + exotic_forest%
17
1
11

INPUTBOX
16
222
143
282
annual_crops%
10.0
1
0
Number

PLOT
999
21
1387
214
Map-LU
Time
% LU
0.0
10.0
0.0
10.0
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
164
358
287
391
Neighborhood
Neighborhood
1
1
-1000

SWITCH
165
419
288
452
Network
Network
1
1
-1000

BUTTON
89
22
152
55
NIL
GO
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
163
99
274
159
BAU%
33.0
1
0
Number

INPUTBOX
163
162
274
222
Industry%
33.0
1
0
Number

INPUTBOX
163
226
274
286
CC%
34.0
1
0
Number

SLIDER
17
708
189
741
occurrence_max
occurrence_max
0
10
7.0
1
1
NIL
HORIZONTAL

PLOT
998
292
1383
481
Map-$
time
Total $
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"$" 1.0 0 -7500403 true "" ""
"$year-1" 1.0 0 -2674135 true "" ""

SWITCH
164
321
288
354
Baseline
Baseline
1
1
-1000

BUTTON
171
501
283
534
NIL
show-network
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
171
540
284
573
NIL
show-map-LU
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
162
23
225
56
Step
tick
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
235
23
298
56
Stop
stop
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
998
491
1383
690
Map-CO2eq
time
Total emissions
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"CO2eq" 1.0 0 -15973838 true "" ""
"CO2eq previous" 1.0 0 -7500403 true "" ""

SWITCH
157
605
295
638
Industry-level
Industry-level
1
1
-1000

SWITCH
157
644
294
677
Government-level
Government-level
1
1
-1000

TEXTBOX
171
78
321
96
Choose behaviour%
11
0.0
1

TEXTBOX
26
76
176
94
Choose Land Use %
11
0.0
1

TEXTBOX
178
301
328
319
Fine scale rules
11
0.0
1

TEXTBOX
167
398
317
416
Intermediate scale rules
11
0.0
1

TEXTBOX
175
585
325
603
Landscape scale rules
11
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
