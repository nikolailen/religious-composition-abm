
turtles-own [
  age
  religion  ; "muslim" or "non-muslim"
  sex  ; "female" or "male"
]

to setup
  clear-all
  set-default-shape turtles "person"
  initialize-population
  reset-ticks
end

to initialize-population
  create-turtles 670 [
    setxy random-xcor random-ycor
    setup-demographics
  ]
end

to setup-demographics
  set age draw-initial-age
  ; TeO2 survey (2019-2020): ~10% of 18-59 identify as Muslim.
  set religion ifelse-value (random-float 1 < 0.1) ["muslim"] ["non-muslim"]
  set sex ifelse-value (random-float 1 < 0.5) ["female"] ["male"]
  update-appearance
end

to go
  age-turtles
  death
  determine-births
  migration
  update-population-plots
  tick
end

to age-turtles
  ask turtles [
    set age age + 1
  ]
end

to death
  ; Age- and sex-specific annual mortality.
  ask turtles [
    if random-float 1 < mortality-probability age sex [ die ]
  ]

  ; Symmetric out-migration (all groups), concentrated in working ages.
  ; Fractional rates are realized stochastically so non-integer sliders are effective.
  let eligible-leavers turtles with [age >= 18 and age <= 64]
  let whole-leavers floor agents-leaving
  let fractional-leaver-prob (agents-leaving - whole-leavers)
  let leavers-count min
    (list
      (whole-leavers + ifelse-value (random-float 1 < fractional-leaver-prob) [1] [0])
      count eligible-leavers)
  ask n-of leavers-count eligible-leavers [ die ]
end

to determine-births
  let eligible-turtles turtles with [sex = "female" and age >= 15 and age <= 49]
  ask eligible-turtles [
    let target-tfr ifelse-value (religion = "muslim") [muslim-birth-rate] [non-muslim-birth-rate]
    let annual-birth-probability target-tfr * fertility-weight age
    let adjusted-probability min (list (annual-birth-probability * coverage-coefficient) 0.95)
    if random-float 1 < adjusted-probability [
      hatch 1 [
        set age 0
        set religion [religion] of myself
        set sex ifelse-value (random-float 1 < 0.5) ["female"] ["male"]
        update-appearance
      ]
    ]
  ]
end

to migration
  ; Fractional rates are realized stochastically so non-integer sliders are effective.
  let whole-arrivals floor agents-coming
  let fractional-arrival-prob (agents-coming - whole-arrivals)
  let arrivals-count (whole-arrivals + ifelse-value (random-float 1 < fractional-arrival-prob) [1] [0])
  create-turtles arrivals-count [
    setxy random-xcor random-ycor
    set age draw-migrant-age
    ; Default share-muslim-incoming calibrated from INSEE 2023 entrant origins x Pew 2020 country composition.
    set religion ifelse-value (random-float 1 < share-muslim-incoming) ["muslim"] ["non-muslim"]
    set sex ifelse-value (random-float 1 < 0.5) ["female"] ["male"]
    update-appearance
  ]
end

to-report draw-initial-age
  ; Approximate INSEE age structure (France, 1 Jan 2026 provisional).
  let r random-float 1
  if r < 0.1625 [ report random 15 ]          ; 0-14
  if r < 0.3984 [ report 15 + random 20 ]     ; 15-34
  if r < 0.6508 [ report 35 + random 20 ]     ; 35-54
  if r < 0.8887 [ report 55 + random 20 ]     ; 55-74
  report 75 + random 26                       ; 75-100+
end

to-report draw-migrant-age
  let r random-float 1
  if r < 0.12 [ report random 18 ]            ; 0-17
  if r < 0.82 [ report 18 + random 33 ]       ; 18-50
  if r < 0.96 [ report 51 + random 19 ]       ; 51-69
  report 70 + random 21                       ; 70-90
end

to-report fertility-weight [a]
  ; Shape calibrated from INSEE 2022 age-specific fertility rates.
  if ((a < 15) or (a > 49)) [ report 0 ]
  if a <= 19 [ report 0.013615 / 5 ]
  if a <= 24 [ report 0.103916 / 5 ]
  if a <= 29 [ report 0.278665 / 5 ]
  if a <= 34 [ report 0.345055 / 5 ]
  if a <= 39 [ report 0.199280 / 5 ]
  if a <= 44 [ report 0.055137 / 5 ]
  report 0.004332 / 5
end

to-report mortality-probability [a s]
  ; Approximate 2022 INSEE age-group mortality rates by sex.
  if a = 0 [ report ifelse-value (s = "male") [0.00383] [0.00315] ]
  if a <= 4 [ report ifelse-value (s = "male") [0.00030] [0.00026] ]
  if a <= 9 [ report 0.00009 ]
  if a <= 14 [ report ifelse-value (s = "male") [0.00010] [0.00009] ]
  if a <= 19 [ report ifelse-value (s = "male") [0.00028] [0.00015] ]
  if a <= 24 [ report ifelse-value (s = "male") [0.00061] [0.00023] ]
  if a <= 29 [ report ifelse-value (s = "male") [0.00069] [0.00027] ]
  if a <= 34 [ report ifelse-value (s = "male") [0.00085] [0.00037] ]
  if a <= 39 [ report ifelse-value (s = "male") [0.00121] [0.00053] ]
  if a <= 44 [ report ifelse-value (s = "male") [0.00175] [0.00083] ]
  if a <= 49 [ report ifelse-value (s = "male") [0.00263] [0.00135] ]
  if a <= 54 [ report ifelse-value (s = "male") [0.00424] [0.00217] ]
  if a <= 59 [ report ifelse-value (s = "male") [0.00657] [0.00330] ]
  if a <= 64 [ report ifelse-value (s = "male") [0.01027] [0.00502] ]
  if a <= 69 [ report ifelse-value (s = "male") [0.01543] [0.00746] ]
  if a <= 79 [ report ifelse-value (s = "male") [0.02657] [0.01405] ]
  if a <= 89 [ report ifelse-value (s = "male") [0.07565] [0.05046] ]
  report ifelse-value (s = "male") [0.23088] [0.18637]
end

to update-appearance
  ifelse religion = "muslim" [
    set color green
  ] [
    ifelse religion = "non-muslim" [
      set color blue
    ] [
      set color gray
    ]
  ]
end

to update-population-plots
  set-current-plot "Population Over Time"
  set-current-plot-pen "Total population"
  plot count turtles

  set-current-plot-pen "Muslim Population"
  plot count turtles with [religion = "muslim"]

  set-current-plot-pen "Non-Muslim Population"
  plot count turtles with [religion = "non-muslim"]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
13
10
77
43
Setup
setup
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
119
10
182
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
180
186
213
non-muslim-birth-rate
non-muslim-birth-rate
0.8
4
1.56
0.01
1
NIL
HORIZONTAL

SLIDER
13
221
185
254
muslim-birth-rate
muslim-birth-rate
0.8
4
2.81
0.01
1
NIL
HORIZONTAL

SLIDER
12
137
184
170
agents-leaving
agents-leaving
0
20
1.66
0.1
1
NIL
HORIZONTAL

SLIDER
12
54
184
87
agents-coming
agents-coming
0
20
3.36
0.1
1
NIL
HORIZONTAL

SLIDER
12
96
185
129
share-muslim-incoming
share-muslim-incoming
0
1
0.52
0.01
1
NIL
HORIZONTAL

MONITOR
658
10
808
55
Total Population
count turtles
0
1
11

MONITOR
821
10
972
55
Muslim Population
count turtles with [religion = \"muslim\"]
0
1
11

MONITOR
986
10
1129
55
Non-Muslim Population
count turtles with [religion = \"non-muslim\"]
0
1
11

PLOT
659
65
1128
330
Population Over Time
Time
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total population" 1.0 0 -16777216 true "" "plot count turtles"
"Muslim Population" 1.0 0 -10899396 true "" "plot count turtles with [religion = \"muslim\"]"
"Non-Muslim Population" 1.0 0 -7500403 true "" "plot count turtles with [religion = \"non-muslim\"]"

SLIDER
13
264
185
297
coverage-coefficient
coverage-coefficient
0
1
1
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a data-informed demographic agent-based model with two population groups ("muslim" and "non-muslim").
Each tick represents one year.
The structure is calibrated to recent official France demography data (INSEE, as of January 2026), with explicit caveats for religion-specific data.

Core demographic mechanisms:
- Sex for each agent.
- Age-specific fertility (female ages 15-49).
- Age- and sex-specific annual mortality.
- Symmetric out-migration (all groups can leave).

Visual legend:
- Blue turtles: non-muslim agents
- Green turtles: muslim agents
- Plot lines: black = total population, green = muslim population, gray = non-muslim population

## HOW IT WORKS

At setup:
- 670 agents are created.
- Each agent gets age, sex, and religion.
- Age initialization follows INSEE 1 January 2026 provisional age structure.
- Initial muslim share is set to 0.10 (proxy from TeO2 2019-2020 for ages 18-59).

Each tick:
1. All agents age by 1.
2. Mortality is applied using age- and sex-specific annual probabilities (from INSEE 2022 age-group rates).
3. Out-migration removes `agents-leaving` people sampled from ages 18-64 across all groups.
4. Births are generated by female agents ages 15-49 using an INSEE 2022 age fertility schedule.
5. Fertility schedule is scaled by group TFR sliders and by `coverage-coefficient`.
6. New migrants are added (`agents-coming`) with religion share controlled by `share-muslim-incoming`.
7. Fractional migration rates are realized stochastically (for example 1.66 means 1 or 2 each tick with matching long-run average).
8. Monitors and plot are updated.

## HOW TO USE IT

1. Click `Setup` to initialize the population.
2. Click `Go` to run continuously.
3. Adjust sliders and compare trajectories on monitors and the population plot.

Interface controls:
- `agents-coming`: number of incoming migrants per year.
- `share-muslim-incoming`: share (0 to 1) of incoming agents assigned "muslim" (default calibrated to ~0.52 from known-country origin mapping, see credits).
- `agents-leaving`: number of outgoing migrants per year (sampled from all groups, ages 18-64).
- `non-muslim-birth-rate`: target total fertility rate (children per woman lifetime) for non-muslim group.
- `muslim-birth-rate`: target total fertility rate (children per woman lifetime) for muslim group (default proxy from majority-muslim origin countries in the 2023 entrant list).
- `coverage-coefficient`: fertility realization factor (0 to 1) scaling annual birth probabilities.

Default calibration targets (aggregate France):
- `non-muslim-birth-rate = 1.56`
- `muslim-birth-rate = 2.81`
- `coverage-coefficient = 1.00`
- `agents-coming = 3.36`
- `agents-leaving = 1.66`
- `share-muslim-incoming = 0.52`

With 670 agents representing about 69.1 million people, net migration of about +1.70 agents/year is roughly +176,000 people/year.

Monitors:
- `Total Population`
- `Muslim Population`
- `Non-Muslim Population`

## THINGS TO NOTICE

- With equal TFR sliders, composition changes come mostly from migration-share assumptions.
- Net migration balance (`agents-coming` minus `agents-leaving`) strongly affects total population trend.
- `share-muslim-incoming` mainly changes composition, while migration balance changes total size.

## THINGS TO TRY

- Set `agents-coming = agents-leaving` to isolate natural increase/decrease from fertility and mortality.
- Set `muslim-birth-rate = non-muslim-birth-rate` and test composition sensitivity only to migration share.
- Vary `coverage-coefficient` from 0.6 to 1.0 and compare long-run total population.
- Run multiple seeds and compare spread to evaluate stochastic sensitivity.

## EXTENDING THE MODEL

- Add explicit households or partnerships instead of independent fertility draws.
- Add age-specific migration schedules by sex and group.
- Replace current fixed 2022 fertility/mortality schedules with time-varying yearly schedules.
- Track additional categories (education, region, income) and interactions.
- Add data export for reproducible scenario comparison.

## NETLOGO FEATURES

- Uses `turtles-own` variables (`age`, `sex`, `religion`) to store demographic state.
- Uses reporters for age-specific fertility and mortality schedules.
- Uses `hatch` to generate offspring inheriting maternal religion.
- Uses monitors and multi-pen plots to visualize subgroup and total dynamics.
- Uses slider-driven parameters for rapid scenario testing from the Interface tab.

## RELATED MODELS

Any NetLogo model with births, deaths, and age structure is a useful comparison baseline.
Population-dynamics and migration-focused ABMs are particularly relevant for method comparison.

## CREDITS AND REFERENCES

Model file: `france_religious_composition_abm.nlogo`

Primary data used in this calibration:
- INSEE Premiere No. 2087 (published January 13, 2026): 2025 births, deaths, TFR, life expectancy, net migration estimate.
- INSEE table "Population au 1er janvier par sexe et age detaille" (includes provisional 2026 age structure).
- INSEE table "Taux de fecondite des femmes par age detaille" (latest available detailed age pattern in file: 2022).
- INSEE table "Taux de mortalite par sexe et groupe d'ages" (latest available detailed age pattern in file: 2022).
- INSEE/INED TeO2 (2019-2020): religion identification estimates, including about 10% muslim among ages 18-59.
- INSEE table "Origine geographique des immigres arrives en France en 2023" (entrant countries of birth).
- Pew Research Center dataset "Religious Composition 2010-2020" (country-level 2020 religion percentages).
- World Bank indicator SP.DYN.TFRT.IN (latest available TFR by country) for fertility proxy in majority-muslim origin countries.
- Local reproducibility files: `data/incoming_origin_religion_mapping_2023.csv`, `data/incoming_origin_religion_summary_2023.json`, `data/muslim_country_fertility_proxy.csv`, and `data/muslim_country_fertility_proxy_summary.json`.

Important limitation:
- France has no annual official religion census counts by age, births, deaths, and migration.
- Migration religion share is inferred from country of birth and country-level religion composition, not measured individual religion at entry.
- The current setup does not explicitly impose an older native age structure versus younger muslim age structure at initialization.
- Therefore religion-specific demographic rates in this model remain scenario assumptions around an aggregate calibrated demographic core.
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
