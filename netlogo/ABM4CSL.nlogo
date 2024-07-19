;; NetLogo extensions used the model
extensions [
  gis        ; built-in extension to work with raster and vector GIS layers
  csv        ; built-in extension to access CSV files
  pathdir    ; external extension to create directories
  rnd        ; random selection with weightsconvenience functions used elsewhere
  profiler   ; to profile code execution
]


;; all model code is actually in these included files
__includes[
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
38
908
647
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
42
68
75
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
600
762
876
795
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
14
944
141
1004
artificial-weight
3.0
1
0
Number

INPUTBOX
145
944
270
1008
water-weight
5.0
1
0
Number

INPUTBOX
407
944
533
1004
crop-perennial-weight
10.0
1
0
Number

INPUTBOX
540
944
665
1004
scrub-weight
6.0
1
0
Number

INPUTBOX
670
944
797
1004
intensive-pasture-weight
18.0
1
0
Number

INPUTBOX
800
940
932
1003
extensive-pasture-weight
23.0
1
0
Number

INPUTBOX
947
944
1072
1004
native-forest-weight
5.0
1
0
Number

INPUTBOX
1080
944
1210
1004
exotic-forest-weight
20.0
1
0
Number

INPUTBOX
14
1024
139
1084
artificial-product-yield
1.0
1
0
Number

INPUTBOX
147
1024
272
1084
water-product-yield
0.0
1
0
Number

INPUTBOX
277
1024
405
1084
crop-annual-product-yield
10.0
1
0
Number

INPUTBOX
410
1024
535
1084
crop-perennial-product-yield
20.0
1
0
Number

INPUTBOX
545
1024
670
1084
scrub-product-yield
0.0
1
0
Number

INPUTBOX
680
1024
805
1084
intensive-pasture-product-yield
1.1
1
0
Number

INPUTBOX
815
1024
940
1084
extensive-pasture-product-yield
0.3
1
0
Number

INPUTBOX
950
1024
1075
1084
native-forest-product-yield
0.0
1
0
Number

INPUTBOX
1085
1024
1210
1084
exotic-forest-product-yield
1.0
1
0
Number

INPUTBOX
15
1107
140
1167
artificial-product-value
300000.0
1
0
Number

INPUTBOX
147
1107
272
1167
water-product-value
0.0
1
0
Number

INPUTBOX
275
1107
408
1167
crop-annual-product-value
450.0
1
0
Number

INPUTBOX
410
1107
535
1167
crop-perennial-product-value
3500.0
1
0
Number

INPUTBOX
545
1107
670
1167
scrub-product-value
0.0
1
0
Number

INPUTBOX
680
1107
805
1167
intensive-pasture-product-value
10000.0
1
0
Number

INPUTBOX
815
1107
940
1167
extensive-pasture-product-value
5500.0
1
0
Number

INPUTBOX
950
1107
1075
1167
native-forest-product-value
0.0
1
0
Number

INPUTBOX
1085
1107
1210
1167
exotic-forest-product-value
4500.0
1
0
Number

INPUTBOX
14
1192
139
1252
artificial-emissions
0.0
1
0
Number

INPUTBOX
147
1192
272
1252
water-emissions
0.0
1
0
Number

INPUTBOX
275
1194
408
1254
crop-annual-emissions
95.0
1
0
Number

INPUTBOX
410
1194
535
1254
crop-perennial-emissions
90.0
1
0
Number

INPUTBOX
545
1194
670
1254
scrub-emissions
0.0
1
0
Number

INPUTBOX
680
1194
805
1254
intensive-pasture-emissions
480.0
1
0
Number

INPUTBOX
815
1194
940
1254
extensive-pasture-emissions
150.0
1
0
Number

INPUTBOX
950
1194
1075
1254
native-forest-emissions
0.0
1
0
Number

INPUTBOX
1085
1194
1210
1254
exotic-forest-emissions
0.0
1
0
Number

INPUTBOX
15
1277
140
1337
artificial-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
150
1277
275
1337
water-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
275
1277
408
1337
crop-annual-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
414
1277
539
1337
crop-perennial-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
545
1277
670
1337
scrub-carbon-stock-rate
3.5
1
0
Number

INPUTBOX
684
1277
809
1337
intensive-pasture-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
815
1277
940
1337
extensive-pasture-carbon-stock-rate
0.0
1
0
Number

INPUTBOX
954
1277
1079
1337
native-forest-carbon-stock-rate
8.0
1
0
Number

INPUTBOX
1087
1277
1212
1337
exotic-forest-carbon-stock-rate
25.0
1
0
Number

INPUTBOX
17
1365
142
1425
artificial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
150
1365
275
1425
water-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
275
1365
408
1425
crop-annual-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
410
1365
535
1425
crop-perennial-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
545
1365
670
1425
scrub-carbon-stock-maximum
100.0
1
0
Number

INPUTBOX
680
1365
805
1425
intensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
815
1365
940
1425
extensive-pasture-carbon-stock-maximum
0.0
1
0
Number

INPUTBOX
950
1365
1075
1425
native-forest-carbon-stock-maximum
250.0
1
0
Number

INPUTBOX
1087
1365
1212
1425
exotic-forest-carbon-stock-maximum
700.0
1
0
Number

MONITOR
1085
895
1212
940
Total weight
sum landuse-weight
17
1
11

INPUTBOX
275
940
392
1004
crop-annual-weight
10.0
1
0
Number

PLOT
1253
44
1892
334
Percentage land use
Time
%
0.0
10.0
0.0
1.0
true
true
"" "plot-land-use-fraction"
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

BUTTON
76
42
139
75
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
13
335
137
397
BAU-weight
33.0
1
0
Number

INPUTBOX
144
335
268
396
industry-weight
33.0
1
0
Number

INPUTBOX
11
400
135
463
CC-weight
34.0
1
0
Number

SWITCH
105
162
285
195
fixed-seed
fixed-seed
0
1
-1000

SWITCH
105
198
286
231
performance-mode
performance-mode
1
1
-1000

BUTTON
148
43
224
76
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
915
502
1238
662
Total emissions
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot total-emissions]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1573
506
1893
666
Total crop yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot total-crop-yield]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
916
339
1240
499
Total value
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0) [plot total-value]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1576
339
1894
502
Total livestock yield
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot total-livestock-yield]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
914
668
1241
827
Total carbon stock
time
NIL
0.0
5.0
0.0
5.0
true
true
"" "if (ticks > 0)[plot total-carbon-stock]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1243
340
1569
495
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
1242
501
1566
666
Mean patch size
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot mean-patch-size]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1243
668
1567
833
Fragmentation index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot fragmentation-index]"
PENS
"" 1.0 0 -15973838 true "" ""

PLOT
1578
673
1890
827
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
832
1892
999
Bird suitable index
time
NIL
0.0
5.0
0.0
0.0
true
true
"" "if (ticks > 0)[plot bird-suitable-index]"
PENS
"" 1.0 0 -15973838 true "" ""

TEXTBOX
15
243
160
261
Farmers
16
0.0
1

TEXTBOX
15
925
373
955
Weight in random initial distribution
12
0.0
1

TEXTBOX
13
513
147
531
Fine scale
12
0.0
1

TEXTBOX
14
608
166
627
Intermediate scale
12
0.0
1

TEXTBOX
15
665
155
685
Hard landscape rules
12
0.0
1

CHOOSER
303
759
586
804
initial-landuse-source
initial-landuse-source
"gis-vector" "gis-raster" "random"
2

CHOOSER
302
674
581
719
landuse-parameter-source
landuse-parameter-source
"preset: default" "preset: forest" "csv file" "manual entry"
0

CHOOSER
1074
90
1234
135
map-label
map-label
"land use" "value" "emissions" "land use age" "carbon stock" "bird suitable" "pollinated" "cluster size" "decision interval" "none"
3

CHOOSER
1074
38
1233
83
map-color
map-color
"land use" "network" "carbon stock" "emissions" "bird suitable" "pollinated" "cluster size" "neighbour examples"
0

INPUTBOX
597
813
883
873
gis-vector-filename
test/gis/example_vector.shp
1
0
String

INPUTBOX
304
811
586
871
gis-raster-filename
test/gis/example_raster.grd
1
0
String

INPUTBOX
593
669
880
729
landuse-data-csv-filename
test/landuse/example.csv
1
0
String

SLIDER
6
83
291
116
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
1253
15
1508
33
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
12
495
185
516
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
303
734
499
754
Initialise land use
16
0.0
1

BUTTON
232
43
290
76
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
13
319
252
339
Distribution of random attitude
12
0.0
1

TEXTBOX
300
651
506
674
Land use parameters\n
16
0.0
1

TEXTBOX
14
1007
164
1025
Product yield (t/ha/a)
12
0.0
1

TEXTBOX
15
1089
165
1107
Product value (NZD/t)
12
0.0
1

TEXTBOX
15
1174
165
1192
Emissions (t/ha/a)
12
0.0
1

TEXTBOX
15
1259
296
1277
Carbon stock rate (t/ha/a)
12
0.0
1

TEXTBOX
15
1347
271
1367
Carbon stock maximum (t/ha)
12
0.0
1

TEXTBOX
15
905
372
923
Current land use values and manual entry
16
0.0
1

INPUTBOX
7
161
98
234
seed
99.0
1
0
Number

SLIDER
8
123
292
156
years-to-run-before-stopping
years-to-run-before-stopping
0
100
30.0
1
1
NIL
HORIZONTAL

TEXTBOX
1244
1057
1411
1077
Model output
16
0.0
1

INPUTBOX
1242
1087
1509
1147
export-directory
output
1
0
String

BUTTON
1518
1089
1676
1124
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
14
276
284
309
maximum-neighbour-distance
maximum-neighbour-distance
0
10
1.5
0.5
1
NIL
HORIZONTAL

TEXTBOX
18
761
168
779
Soft landscape rules
12
0.0
1

SLIDER
11
532
288
565
baseline-rule-weight
baseline-rule-weight
0
2
1.0
0.2
1
NIL
HORIZONTAL

SLIDER
10
569
287
602
neighbour-rule-weight
neighbour-rule-weight
0
2
2.0
0.2
1
NIL
HORIZONTAL

SLIDER
15
628
286
661
network-rule-weight
network-rule-weight
0
2
1.0
0.2
1
NIL
HORIZONTAL

SLIDER
17
684
292
717
industry-rule-percentage
industry-rule-percentage
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
13
723
291
756
government-rule-percentage
government-rule-percentage
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
16
782
291
815
economy-rule-weight
economy-rule-weight
0
2
1.0
0.2
1
NIL
HORIZONTAL

SLIDER
14
826
292
859
emissions-rule-weight
emissions-rule-weight
0
2
1.0
0.2
1
NIL
HORIZONTAL

PLOT
912
38
1072
330
legend
NIL
NIL
0.0
0.0
0.0
0.0
false
true
"" ""
PENS

BUTTON
1242
1189
1353
1222
NIL
profile
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1239
1161
1685
1179
Run profiler with output to \"profile.csv\"
16
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
