;; all model code is actually in these included files

__includes[
    "extensions.nls"            ;manage extensions
    "variables.nls" ;definition of variables, agents, and links not managed by UI
    "setup.nls"     ;code to setup model
    "go.nls"        ;code to step model
    "rules.nls"     ;rule definitions
    "utilities.nls" ;convenience functions used elsewhere
]


;; below this line are the user interface elements that are preferably
;; changed in the interface


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
277
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
2.0
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
artificial-emissions
0.0
1
0
Number

INPUTBOX
162
1183
287
1243
water-emissions
0.0
1
0
Number

INPUTBOX
289
1184
422
1244
crop-annual-emissions
95.0
1
0
Number

INPUTBOX
424
1184
549
1244
crop-perennial-emissions
90.0
1
0
Number

INPUTBOX
559
1184
684
1244
scrub-emissions
0.0
1
0
Number

INPUTBOX
694
1184
819
1244
intensive-pasture-emissions
480.0
1
0
Number

INPUTBOX
829
1184
954
1244
extensive-pasture-emissions
150.0
1
0
Number

INPUTBOX
964
1184
1089
1244
native-forest-emissions
0.0
1
0
Number

INPUTBOX
1099
1184
1224
1244
exotic-forest-emissions
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
30
1357
155
1417
artificial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
165
1357
290
1417
water-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
290
1357
423
1417
crop-annual-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
425
1357
550
1417
crop-perennial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
560
1357
685
1417
scrub-carbon-stock-maximum
100.0
1
0
Number

INPUTBOX
695
1357
820
1417
intensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
830
1357
955
1417
extensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
965
1357
1090
1417
native-forest-carbon-stock-maximum
250.0
1
0
Number

INPUTBOX
1100
1357
1225
1417
exotic-forest-carbon-stock-maximum
700.0
1
0
Number

MONITOR
1098
886
1225
931
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
Percentage land use
Time
%
0.0
10.0
0.0
1.0
true
true
"" "plot-land-use-frequency"
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
150
557
289
590
Neighbourhood
Neighbourhood
0
1
-1000

SWITCH
6
615
146
648
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
9
382
133
444
BAU-weight
33.0
1
0
Number

INPUTBOX
140
382
264
443
industry-weight
33.0
1
0
Number

INPUTBOX
8
447
132
510
CC-weight
34.0
1
0
Number

SLIDER
9
245
281
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
5
557
144
590
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
"" "if (ticks > 0)[plot sum [emissions] of valid-patches]"
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
"" "if (ticks > 0)[plot sum [crop-yield] of valid-patches]"
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
"" "if (ticks > 0) [plot sum [value] of valid-patches]"
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
"" "if (ticks > 0)[plot sum [livestock-yield] of valid-patches]"
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
"" "if (ticks > 0)[plot sum [carbon-stock] of valid-patches]"
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
8
674
146
707
Industry-level
Industry-level
0
1
-1000

SWITCH
150
675
287
708
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
Weight in random initial distribution
12
0.0
1

TEXTBOX
8
535
142
553
Fine scale
12
0.0
1

TEXTBOX
6
596
158
615
Intermediate scale
12
0.0
1

TEXTBOX
8
653
148
673
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
land_use_data/example.csv
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
6
516
179
537
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
9
366
248
386
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
203
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
26.0
1
1
NIL
HORIZONTAL

OUTPUT
1258
910
1896
1159
12

TEXTBOX
1259
885
1426
905
Model output
16
0.0
1

INPUTBOX
1258
1169
1572
1229
export-directory
output
1
0
String

BUTTON
1583
1170
1741
1205
export everything
export-everything
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
323
280
356
maximum-neighbour-distance
maximum-neighbour-distance
0
10
1.0
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
