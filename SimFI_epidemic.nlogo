;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; GLOBAL PARAMETERS ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals
[
  lifespan                     ;; lifespan of a turtle
  movement                     ;; max possible distance for moving each day
  nb-contact                   ;; mean number of contacts a turtle has each day

  ;;;;; FLU ;;;;;
  date-first-infection-flu     ;; date of flu importation each year
  real-flu-infectiousness      ;; flu infectiousness drawn from normal law each year
  flu-total-duration           ;; total duration of the flu illness, drawn from a gamma law

  flu-new                      ;; flu incidence : number of turtles infected by the flu each day
  flu-total                    ;; cumulated flu incidence

  ;;;;; OTHER PATHOGEN ;;;;;
  date-first-infection-path    ;; date of the second pathogen importation each year
  real-path-infectiousness     ;; second pathogen infectiousness drawn from normal law each year
  path-total-duration          ;; total duration of the second pathogen illness, drawn from a gamma law

  path-new                     ;; second pathogen incidence : number of turtles infected by the second pathogen each day
  path-total                   ;; cumulated incidence for the second pathogen
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; TURTLES PARAMETERS ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own
[
  age                          ;; age of the turtle in days

  ;;;;; FLU ;;;;;
  flu-susceptible?             ;; if true, the turtle is susceptible to the flu
  flu-contagious?              ;; if true, the turtle is contagious for the flu
  flu-immune?                  ;; if true, the turtle is immune to the flu for the current year

  flu-susceptible-previous?    ;; susceptible status for the previous time step
  flu-contagious-previous?     ;; contagious status for the previous time step
  flu-immune-previous?         ;; immune status for the previous time step

  flu-incub-count              ;; how long the turtle has been incubating the flu
  flu-true-incubation-duration ;; how long the turtle will stay in the incubation phase, drawn from a gamma law
  flu-inf-count                ;; how long the turtle has been in the symptomatic phase
  flu-true-infection-duration  ;; how long the turtle will stay in the symptomatic phase, drawn from a gamma law

  ;;;;; OTHER PATHOGEN ;;;;;
  path-susceptible?             ;; if true, the turtle is susceptible to the second pathogen
  path-contagious?              ;; if true, the turtle is contagious for the second pathogen
  path-immune?                  ;; if true, the turtle is immune to the second pathogen for the current year

  path-susceptible-previous?    ;; susceptible status for the previous time step
  path-contagious-previous?     ;; contagious status for the previous time step
  path-immune-previous?         ;; immune status for the previous time step

  path-incub-count              ;; how long the turtle has been incubating the second pathogen
  path-true-incubation-duration ;; how long the turtle will stay in the incubation phase, drawn from a gamma law
  path-inf-count                ;; how long the turtle has been in the symptomatic phase
  path-true-infection-duration  ;; how long the turtle will stay in the symptomatic phase, drawn from a gamma law
  path-immune-count             ;; how long the turtle has been immune to the second pathogen
  path-true-immune-duration     ;; how long the turtle will stay in the immune phase
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; SETUP ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup

  ;; reset the world and plots (while preserving the parameters value when using the Behavior Space)
  clear-output
  clear-all-plots
  clear-patches
  clear-turtles

  ;; set-up the simulation
  setup-globals
  setup-turtles
  recap-parameters

  ;; reset the time steps
  reset-ticks
  tick

end


;;;;; setup procedures ;;;;;

to setup-globals

  ;; set the world size to control the mean number of turtles on each patch (and thus the number of contacts)
  set nb-contact 13
  resize-world 0 sqrt (population-size / (nb-contact + 1)) 0 sqrt (population-size / (nb-contact + 1))

  set lifespan 364 * 80
  set movement 10

  ;;;;; FLU ;;;;;
  set flu-new 0
  set flu-total 0

  ;;;;; OTHER PATHOGEN ;;;;;
  set path-new 0
  set path-total 0

end


to setup-turtles

  ;; create healthy turtles randomly distributed in position and age
  create-turtles population-size
  [
    setxy random-xcor random-ycor
    set age random lifespan

    get-flu-susceptible
    get-path-susceptible

    set-flu-previous
    set-path-previous
  ]

end


;;;;; turtle procedures ;;;;;

to get-flu-susceptible

  ;; susceptible state
  set flu-susceptible? true
  set flu-contagious? false
  set flu-immune? false

  ;; defaulted flu counters
  set flu-incub-count -1
  set flu-inf-count -1

end


to get-flu-incub

  ;; incubation state
  set flu-susceptible? false
  set flu-contagious? false
  set flu-immune? false

  ;; start of flu incubation counter
  set flu-incub-count 0

  ;; true durations for asymptomatic and symptomatic states
  set flu-true-incubation-duration ceiling(random-gamma (flu-incubation-duration * flu-incubation-duration / 0.1) (flu-incubation-duration / 0.1))
  set flu-true-infection-duration ceiling(random-gamma (flu-symp-duration * flu-symp-duration / 1) (flu-symp-duration / 1))

end


to get-flu-immune

  ;; immune state
  set flu-susceptible? false
  set flu-contagious? false
  set flu-immune? true

  ;; defaulted flu counters
  set flu-incub-count -1
  set flu-inf-count -1

end


to get-path-susceptible

  set path-susceptible? true
  set path-contagious? false
  set path-immune? false

  set path-incub-count -1
  set path-inf-count -1
  set path-immune-count -1

end


to get-path-incub

  ;; asymptomatic state
  set path-susceptible? false
  set path-contagious? false
  set path-immune? false

  ;; start of path asymptomatic counter
  set path-incub-count 0

  ;; true duration for asymptomatic state
  set path-true-incubation-duration ceiling(random-gamma (path-incubation-duration * path-incubation-duration / 0.1) (path-incubation-duration / 0.1))
  set path-true-infection-duration ceiling(random-gamma (path-symp-duration * path-symp-duration / 1) (path-symp-duration / 1))

end


to get-path-immune

  ;; susceptible state
  set path-susceptible? false
  set path-contagious? false
  set path-immune? true

  ;; defaulted path counters
  set path-incub-count -1
  set path-inf-count -1
  set path-immune-count 0

end


;; update the "previous" statuses for flu
to set-flu-previous

  set flu-susceptible-previous? flu-susceptible?
  set flu-contagious-previous? flu-contagious?
  set flu-immune-previous? flu-immune?

end

;; update the "previous" statuses for the second pathogen
to set-path-previous

  set path-susceptible-previous? path-susceptible?
  set path-contagious-previous? path-contagious?
  set path-immune-previous? path-immune?

end


to recap-parameters

  output-type "population-size " output-print population-size
  output-type "flu-rate-immune" output-print flu-rate-immune
  output-type "flu-transmission-rate " output-print flu-transmission-rate
  output-type "flu-report " output-print flu-reporting-rate
  output-type "flu-report " output-print flu-incubation-duration
  output-type "flu-start-shedding " output-print flu-start-shedding
  output-type "flu-stop-shedding " output-print flu-stop-shedding
  output-type "flu-infection-duration " output-print flu-symp-duration
  output-type "path-transmission-rate " output-print path-transmission-rate
  output-type "path-latent-duration " output-print path-incubation-duration
  output-type "path-report " output-print path-reporting-rate
  output-type "path-infection-duration " output-print path-symp-duration
  output-type "latent-state-contagious? " output-print latent-state-contagious?
  output-type "path-start-shedding " output-print path-start-shedding
  output-type "infected-state-contagious? " output-print infected-state-contagious?
  output-type "path-stop-shedding " output-print path-stop-shedding
  output-type "day-min " output-print day-min
  output-type "day-max " output-print day-max
  output-type "nb-cases-min " output-print nb-cases-min
  output-type "nb-cases-max " output-print nb-cases-max
  output-type "path-rate-immune " output-print path-rate-immune
  output-type "acq-12 " output-print acq-12
  output-type "trans-12 " output-print trans-12
  output-type "cross-12 " output-print cross-12
  output-type "acq-21 " output-print acq-21
  output-type "trans-21 " output-print trans-21
  output-type "cross-21 " output-print cross-21

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; GO ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  reset-variables

  begin-epidemics

  flu-transmission
  path-transmission

  changements-etats

  incidence-counters
  tick
end


;;;;; RESET-VARIABLES ;;;;;

to reset-variables

  set flu-new 0
  set path-new 0

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;; BEGIN-EPIDEMICS ;;;;;

to begin-epidemics

  ;; prepare epidemics characteristics on the first day of the year
  if (ticks mod 364) = 1
  [
    ;;; FLU ;;;
    ;; set the date for flu importation
    set date-first-infection-flu ceiling (random-gamma (71 * 71 / (28 * 28)) (71 / (28 * 28)))
    ;; draw the current year flu infectiousness
    set real-flu-infectiousness random-normal (flu-transmission-rate) (flu-transmission-rate / 30)

    ;; reset immunity
    ask turtles with [flu-immune?]
    [ get-flu-susceptible ]

    ;; immunize a portion of the population
    ask n-of (flu-rate-immune / 100 * population-size) turtles
    [ get-flu-immune ]


    ;;; OTHER PATHOGEN ;;;
    ;; set the date for path importation
    set date-first-infection-path ceiling ((date-first-infection-flu + day-min) + (random-float 1) * (day-max - day-min))
    ;; draw the current year path infectiousness
    set real-path-infectiousness random-normal (path-transmission-rate) (path-transmission-rate / 30)

    ;; reset immunity
    ask turtles with [path-immune?]
    [ get-path-susceptible ]

    ;; immunize a portion of the population
    ask n-of (path-rate-immune / 100 * population-size) turtles
    [ get-path-immune ]
  ]

  ;; beginning of flu season, importation of cases
  if (ticks mod 364) = date-first-infection-flu
  [
    ;; infect some turtles with the flu
    let nb-first-infection-flu ceiling (20 + (random-float 1) * 10)
    ask n-of nb-first-infection-flu turtles with [flu-susceptible?]
    [ get-flu-incub ]
  ]

  ;; beginning of the other pathogen epidemic
  if (ticks mod 364) = date-first-infection-path
  [
    ;; infect some turtles with the other pathogen
    let nb-first-infection-path ceiling (nb-cases-min + (random-float 1) * (nb-cases-max - nb-cases-min))
    ask n-of nb-first-infection-path turtles with [path-susceptible?]
    [ get-path-incub ]
  ]

end


;;;;; FLU-TRANSMISSION ;;;;;

to flu-transmission

  ;; select all flu-contagious individuals
  ask turtles with [flu-contagious-previous?]
  [
    ifelse (path-susceptible-previous? or path-immune-previous?)
    ;; transmitter is not co-infected with the second pathogen
    [
      ;; select all flu-susceptible individuals in contact with the transmitter
      ask other turtles-here with [flu-susceptible-previous?]
      [
        ;; potential receiver is not path infected
        if (path-susceptible-previous? and random-float 100 < real-flu-infectiousness)
        [ get-flu-incub ]

        ;; potential receiver is path infected
        if (not (path-susceptible-previous? or path-immune-previous?) and random-float 100 < acq-21 * real-flu-infectiousness)
        [ get-flu-incub ]

        ;; potential receiver is path immune
        if path-immune-previous?
        [
          ifelse (path-immune-count <= cross-21-duration)
          [
            if (random-float 100 < cross-21 * real-flu-infectiousness)
            [ get-flu-incub ]
          ]
          [
            if (random-float 100 < real-flu-infectiousness)
            [ get-flu-incub ]
          ]
        ]
      ]
    ]

    ;; transmitter is co-infected with the second pathogen
    [
      ;; select all flu-susceptible individuals in contact with the transmitter
      ask other turtles-here with [flu-susceptible-previous?]
      [
        ;; potential receiver is not path infected
        if (path-susceptible-previous? and random-float 100 < trans-21 * real-flu-infectiousness)
        [ get-flu-incub ]

        ;; potential receiver is path infected
        if (not (path-susceptible-previous? or path-immune-previous?) and random-float 100 < acq-21 * trans-21 * real-flu-infectiousness)
        [ get-flu-incub ]

        ;; potential receiver is path immune
        if path-immune-previous?
        [
          ifelse (path-immune-count <= cross-21-duration)
          [
            if random-float 100 < trans-21 * cross-21 * real-flu-infectiousness
            [ get-flu-incub ]
          ]
          [
            if random-float 100 < trans-21 * real-flu-infectiousness
            [ get-flu-incub ]
          ]
        ]
      ]
    ]
  ]

end


;;;;; PATH-TRANSMISSION ;;;;;

to path-transmission

  ;; select all path-contagious individuals
  ask turtles with [path-contagious-previous?]
  [
    ifelse (flu-susceptible-previous? or flu-immune-previous?)
    ;; transmitter is not co-infected with the flu
    [
      ;; select all path-susceptible individuals in contact with the transmitter
      ask other turtles-here with [path-susceptible-previous?]
      [
        ;; potential receiver is not flu infected
        if (flu-susceptible-previous? and random-float 100 < real-path-infectiousness)
        [ get-path-incub ]

        ;; potential receiver is flu infected
        if (not (flu-susceptible-previous? or flu-immune-previous?) and random-float 100 < acq-12 * real-path-infectiousness)
        [ get-path-incub ]

        ;; potential receiver is flu immune
        if (flu-immune-previous? and random-float 100 < cross-12 * real-path-infectiousness)
        [ get-path-incub ]
      ]
    ]

    ;; transmitter is co-infected with the flu
    [
      ;; select all path-susceptible individuals in contact with the transmitter
      ask other turtles-here with [path-susceptible-previous?]
      [
        ;; potential receiver is not flu infected
        if (flu-susceptible-previous? and random-float 100 < trans-12 * real-path-infectiousness)
        [ get-path-incub ]

        ;; potential receiver is flu infected
        if (not (flu-susceptible-previous? or flu-immune-previous?) and random-float 100 < acq-12 * trans-12 * real-path-infectiousness)
        [ get-path-incub ]

        ;; potential receiver is flu immune
        if (flu-immune-previous? and random-float 100 < trans-12 * cross-12 * real-path-infectiousness)
        [ get-path-incub ]
      ]
    ]
  ]

end


;;;;; CHANGEMENTS-ETATS ;;;;;

to changements-etats

  ask turtles
  [
    ;;;; REPRODUCTION ;;;;;
    ;; calibrated to keep the population stable
    let average-offspring 1

    if random-float lifespan < average-offspring
    [
      hatch 1
      [
        set age 0
        right random 360
        forward 1
        get-flu-susceptible
        get-path-susceptible
        set-flu-previous
        set-path-previous
      ]
    ]


    ;;;; GET-OLDER ;;;;
    ifelse age = lifespan
    [ die ]
    [ set age age + 1 ]


    ;;;; FLU ;;;;
    ;; start shedding
    if flu-incub-count = flu-start-shedding
    [ set flu-contagious? true ]

    ;; infection: transition from incubation to symptomatic state
    if flu-incub-count = flu-true-incubation-duration
    [
      set flu-incub-count -1
      set flu-inf-count 0

      ;; detection
      if (random 100 < flu-reporting-rate)
      [ set flu-new flu-new + 1 ]
    ]

    ;; stop shedding
    if flu-inf-count = flu-stop-shedding
    [ set flu-contagious? false ]

    ;; recovery
    if flu-inf-count = flu-true-infection-duration
    [ get-flu-immune ]


    ;;;; OTHER PATHOGEN ;;;;
    ;; start shedding
    if path-incub-count = path-start-shedding
    [ set path-contagious? true ]

    ;; infection: transition from incubation to symptomatic state
    if path-incub-count = path-true-incubation-duration
    [
      set path-incub-count -1
      set path-inf-count 0

      ;; detection
      if (random 100 < path-reporting-rate)
      [ set path-new path-new + 1 ]
    ]

    ;; stop shedding
    if path-inf-count = path-stop-shedding
    [ set path-contagious? false ]

    ;; recovery
    if path-inf-count = path-true-infection-duration
    [
      ifelse path-immunity?
      [ get-path-immune ]
      [ get-path-susceptible ]
    ]

    ;; stop immunity
    if path-immune-count = path-immunity-duration
    [ get-path-susceptible ]


    ;;;; DURATION-COUNTERS ;;;;
    if (flu-incub-count >= 0)
    [ set flu-incub-count flu-incub-count + 1 ]

    if (flu-inf-count >= 0)
    [ set flu-inf-count flu-inf-count + 1 ]

    if (path-incub-count >= 0)
    [ set path-incub-count path-incub-count + 1 ]

    if (path-inf-count >= 0)
    [ set path-inf-count path-inf-count + 1 ]

    if path-immune-count >= 0
    [ set path-immune-count path-immune-count + 1 ]

    set-flu-previous
    set-path-previous


    ;;;; MOVE ;;;;
    right random 360
    jump random movement
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;; INCIDENCE-COUNTERS ;;;;;

to incidence-counters

  set flu-total flu-total + flu-new
  set path-total path-total + path-new

end
@#$#@#$#@
GRAPHICS-WINDOW
1049
10
1543
525
-1
-1
5.704
1
10
1
1
1
0
1
1
1
0
84
0
84
0
0
1
ticks
30.0

BUTTON
15
10
88
43
NIL
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
102
10
165
43
NIL
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

INPUTBOX
205
10
329
70
population-size
100000
1
0
Number

INPUTBOX
17
181
133
241
flu-transmission-rate
3.3
1
0
Number

INPUTBOX
17
240
133
300
flu-reporting-rate
20
1
0
Number

INPUTBOX
17
299
133
359
flu-incubation-duration
2
1
0
Number

INPUTBOX
17
358
133
418
flu-start-shedding
1
1
0
Number

INPUTBOX
17
417
133
477
flu-stop-shedding
2
1
0
Number

INPUTBOX
17
476
133
536
flu-symp-duration
4
1
0
Number

INPUTBOX
167
181
291
241
path-transmission-rate
3.3
1
0
Number

INPUTBOX
167
240
291
300
path-reporting-rate
20
1
0
Number

INPUTBOX
167
299
291
359
path-incubation-duration
2
1
0
Number

INPUTBOX
291
154
415
214
path-start-shedding
1
1
0
Number

INPUTBOX
167
358
291
418
path-symp-duration
4
1
0
Number

INPUTBOX
291
245
415
305
path-stop-shedding
2
1
0
Number

SWITCH
291
122
497
155
latent-state-contagious?
latent-state-contagious?
0
1
-1000

SWITCH
291
213
514
246
infected-state-contagious?
infected-state-contagious?
0
1
-1000

INPUTBOX
514
169
597
229
day-min
30
1
0
Number

INPUTBOX
514
228
597
288
day-max
60
1
0
Number

INPUTBOX
596
169
679
229
nb-cases-min
20
1
0
Number

INPUTBOX
596
228
679
288
nb-cases-max
30
1
0
Number

INPUTBOX
167
122
291
182
path-rate-immune
23
1
0
Number

INPUTBOX
792
121
852
181
acq-12
100
1
0
Number

INPUTBOX
792
180
852
240
trans-12
1
1
0
Number

INPUTBOX
792
239
852
299
cross-12
1
1
0
Number

INPUTBOX
851
121
911
181
acq-21
1
1
0
Number

INPUTBOX
851
180
911
240
trans-21
1
1
0
Number

INPUTBOX
851
239
911
299
cross-21
1
1
0
Number

OUTPUT
380
437
771
817
12

INPUTBOX
17
122
133
182
flu-rate-immune
23
1
0
Number

INPUTBOX
291
336
446
396
path-immunity-duration
300
1
0
Number

SWITCH
291
304
431
337
path-immunity?
path-immunity?
0
1
-1000

INPUTBOX
792
298
911
358
cross-12-duration
7
1
0
Number

INPUTBOX
792
357
911
417
cross-21-duration
7
1
0
Number

TEXTBOX
18
97
168
115
Influenza parameters
12
0.0
1

TEXTBOX
215
97
441
127
Epidemic pathogen parameters
12
0.0
1

TEXTBOX
516
119
680
164
Parameters for setting up the second pathogen outbreak
12
0.0
1

TEXTBOX
792
95
942
113
Interaction parameters
12
0.0
1

TEXTBOX
453
414
717
444
Parameters recap for the current run
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
NetLogo 5.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="100ans" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 36765</exitCondition>
    <metric>flu-new</metric>
    <metric>path-new</metric>
    <enumeratedValueSet variable="acq-12">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cross-12">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trans-12">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acq-21">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cross-21">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trans-21">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
