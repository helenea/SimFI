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
  path-transmission-rate       ;; transmission rate for the second pathogen
  path-true-pathogenicity-rate ;; pathogenicity rate for the second pathogen
  path-asymp-new               ;; second pathogen incidence for the asymptomatic state
  path-asymp-total             ;; cumulated asymptomatic incidence
  path-symp-new                ;; second pathogen incidence for the symptomatic state
  path-symp-total              ;; cumulated symptomatic incidence
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
  path-susceptible?            ;; if true, the turtle is susceptible to the other pathogen
  path-ill?                    ;; if true, the turtle has developed an infection with the other pathogen
  path-contagious?             ;; if true, the turtle is contagious with the other pathogen
  path-immune?                 ;; if true, the turtle is immune to the other pathogen

  path-susceptible-previous?   ;; susceptible status for the previous time step
  path-ill-previous?           ;; ill status for the previous time step
  path-contagious-previous?    ;; contagious status for the previous time step
  path-immune-previous?        ;; immune status for the previous time step

  path-asymp-count             ;; how long the turtle has been in the asymptomatic phase
  path-true-asymp-duration     ;; how long the turtle will stay in the asymptomatic phase, drawn from a gamma law
  path-symp-count              ;; how long the turtle has been in the symptomatic phase
  path-true-symp-duration      ;; how long the turtle will stay in the symptomatic phase, drawn from a gamma law
  path-immune-count            ;; how long the turtle has been immunized against the other pathogen
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

;; initialization of all global parameters
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
  set path-transmission-rate 10000 / ((100 - initial-asymp-prev) * (nb-contact + 1) * (path-asymp-duration))

  set path-asymp-new 0
  set path-asymp-total 0
  set path-symp-new 0
  set path-symp-total 0

end


;; initializartion of the turtles
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

  ;; colonize a portion of the population with the other pathogen
  ask n-of (initial-asymp-prev * population-size / 100) turtles
  [
    get-path-asymp
    set path-asymp-count random path-asymp-duration

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

  ;; susceptible state
  set path-susceptible? true
  set path-ill? false
  set path-contagious? false
  set path-immune? false

  ;; defaulted path counters
  set path-asymp-count -1
  set path-symp-count -1
  set path-immune-count -1

end


to get-path-asymp

  ;; asymptomatic state
  set path-susceptible? false
  set path-ill? false
  set path-contagious? false
  set path-immune? false

  ;; start of path asymptomatic counter
  set path-asymp-count 0

  ;; true duration for asymptomatic state
  set path-true-asymp-duration ceiling(random-gamma (path-asymp-duration * path-asymp-duration / 25) (path-asymp-duration / 25))

  ;; incidence counter
  set path-asymp-new path-asymp-new + 1

end


to get-path-infection

  ;; symptomatic state
  set path-susceptible? false
  set path-ill? true
  ifelse symp-state-contagious?
  [ set path-contagious? true ]
  [ set path-contagious? false ]
  set path-immune? false

  ;; start of the symptomatic counter
  set path-asymp-count -1
  set path-symp-count 0

  ;; true duration for symptomatic state
  set path-true-symp-duration ceiling(random-gamma (path-symp-duration * path-symp-duration / 16) (path-symp-duration / 16))

  ;; incidence counter if detection
  if (random 100 < path-reporting-rate)
  [ set path-symp-new path-symp-new + 1 ]

end


to get-path-immune

  ;; immune state
  set path-susceptible? false
  set path-ill? false
  set path-contagious? false
  set path-immune? true

  ;; start of the immune counter
  set path-asymp-count -1
  set path-symp-count -1
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
  set path-ill-previous? path-ill?
  set path-contagious-previous? path-contagious?
  set path-immune-previous? path-immune?

end


;; print all the parameters values on the interface
to recap-parameters

  output-type "population-size " output-print population-size
  output-type "flu-transmission-rate " output-print flu-transmission-rate
  output-type "flu-reporting-rate " output-print flu-reporting-rate
  output-type "flu-incubation-duration " output-print flu-incubation-duration
  output-type "flu-start-shedding " output-print flu-start-shedding
  output-type "flu-stop-shedding " output-print flu-stop-shedding
  output-type "flu-symp-duration " output-print flu-symp-duration
  output-type "path-transmission-rate " output-print path-transmission-rate
  output-type "path-asymp-duration " output-print path-asymp-duration
  output-type "path-pathogenicity-rate " output-print path-pathogenicity-rate
  output-type "path-reporting-rate " output-print path-reporting-rate
  output-type "path-symp-duration " output-print path-symp-duration
  output-type "asymp-state-contagious? " output-print asymp-state-contagious?
  output-type "path-start-shedding " output-print path-start-shedding
  output-type "symp-state-contagious? " output-print symp-state-contagious?
  output-type "path-stop-shedding " output-print path-stop-shedding
  output-type "initial-asymp-prev " output-print initial-asymp-prev
  output-type "path-immunity? " output-print path-immunity?
  output-type "immunity-duration " output-print immunity-duration
  output-type "acq-12 " output-print acq-12
  output-type "trans-12 " output-print trans-12
  output-type "inf-12 " output-print inf-12
  output-type "acq-21 " output-print acq-21
  output-type "trans-21 " output-print trans-21

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; GO ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; procedures executed on each time step
to go
  reset-variables

  begin-flu

  flu-transmission
  path-transmission

  update-states

;  incidence-counters
  tick
end


;;;;; RESET-VARIABLES ;;;;;

;; reset incidence counters
to reset-variables

  set flu-new 0
  set path-asymp-new 0
  set path-symp-new 0

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;; BEGIN-EPIDEMICS ;;;;;

to begin-flu

  ;; prepare epidemics characteristics on the first day of the year
  if (ticks mod 364) = 1
  [
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
  ]

  ;; beginning of flu season, importation of cases
  if (ticks mod 364) = date-first-infection-flu
  [
    ;; infect some turtles with the flu
    let nb-first-infection-flu ceiling (20 + (random-float 1) * 10)
    ask n-of nb-first-infection-flu turtles with [flu-susceptible?]
    [ get-flu-incub ]
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
        ifelse (path-susceptible-previous? or path-immune-previous?)
        ;; potential receiver is not path infected
        [
          if random-float 100 < real-flu-infectiousness
          [ get-flu-incub ]
        ]

        ;; potential receiver is path infected
        [
          if random-float 100 < acq-21 * real-flu-infectiousness
          [ get-flu-incub ]
        ]
      ]
    ]

    ;; transmitter is co-infected with the second pathogen
    [
      ;; select all flu-susceptible individuals in contact with the transmitter
      ask other turtles-here with [flu-susceptible-previous?]
      [
        ;; potential receiver is not path infected
        ifelse (path-susceptible-previous? or path-immune-previous?)
        [
          if random-float 100 < trans-21 * real-flu-infectiousness
          [ get-flu-incub ]
        ]

        ;; potential receiver is path infected
        [
          if random-float 100 < acq-21 * trans-21 * real-flu-infectiousness
          [ get-flu-incub ]
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
        ifelse (flu-susceptible-previous? or flu-immune-previous?)
        [
          if random-float 100 < path-transmission-rate
          [ get-path-asymp ]
        ]

        ;; potential receiver is flu infected
        [
          if random-float 100 < acq-12 * path-transmission-rate
          [ get-path-asymp ]
        ]
      ]
    ]

    ;; transmitter is co-infected with the flu
    [
      ;; select all path-susceptible individuals in contact with the transmitter
      ask other turtles-here with [path-susceptible-previous?]
      [
        ;; potential receiver is not flu infected
        ifelse (flu-susceptible-previous? or flu-immune-previous?)
        [
          if random-float 100 < trans-12 * path-transmission-rate
          [ get-path-asymp ]
        ]

        ;; potential receiver is flu infected
        [
          if random-float 100 < acq-12 * trans-12 * path-transmission-rate
          [ get-path-asymp ]
        ]
      ]
    ]
  ]

end


;;;;; UPDATE-STATES ;;;;;

to update-states

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
    ;; start shedding, asymptomatic state
    if asymp-state-contagious? and (path-asymp-count >= path-start-shedding)
    [ set path-contagious? true ]

    ;; stop shedding, symptomatic state
    if path-symp-count = path-stop-shedding
    [ set path-contagious? false ]

    ;; recovery from asymptomatic state
    if path-asymp-count >= path-true-asymp-duration
    [ get-path-susceptible ]

    ;; recovery from symptomatic state
    if path-symp-count = path-true-symp-duration
    [
      ifelse path-immunity?
      [ get-path-immune ]
      [ get-path-susceptible ]
    ]

    ;; stop immunity
    if path-immune-count = immunity-duration
    [ get-path-susceptible ]


    ;;; transition from asymptomatic to symptomatic state ;;;
    ;; seasonal adjustment for the second pathogen: step function on the pathogenicity rate
    ifelse ((ticks mod 364) < 29 or (ticks mod 364) > 238)
    [ set path-true-pathogenicity-rate path-pathogenicity-rate * 0.25 ]
    [ set path-true-pathogenicity-rate path-pathogenicity-rate ]

    ;; potential receiver is not flu infected (SI)
    if (path-asymp-count >= 0) and (flu-susceptible-previous? or flu-immune-previous?) and (random-float 100 < path-true-pathogenicity-rate)
    [ get-path-infection ]

    ;; potential receiver is flu-infected (II)
    if (path-asymp-count >= 0) and (not (flu-susceptible-previous? or flu-immune-previous?)) and (random-float 100 < inf-12 * path-true-pathogenicity-rate)
    [ get-path-infection ]


    ;;;; DURATION-COUNTERS ;;;;
    if (flu-incub-count >= 0)
    [ set flu-incub-count flu-incub-count + 1 ]

    if (flu-inf-count >= 0)
    [ set flu-inf-count flu-inf-count + 1 ]

    if (path-asymp-count >= 0)
    [ set path-asymp-count path-asymp-count + 1 ]

    if (path-symp-count >= 0)
    [ set path-symp-count path-symp-count + 1 ]

    if (path-immune-count >= 0)
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

;to incidence-counters
;
;  set flu-total flu-total + flu-new
;  set path-asymp-total path-asymp-total + path-asymp-new
;  set path-symp-total path-symp-total + path-symp-new
;
;end
@#$#@#$#@
GRAPHICS-WINDOW
673
10
12271
11629
-1
-1
136.3333333333334
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
204
10
320
70
population-size
100000
1
0
Number

INPUTBOX
12
176
128
236
flu-transmission-rate
3.3
1
0
Number

INPUTBOX
12
235
128
295
flu-reporting-rate
20
1
0
Number

INPUTBOX
12
294
128
354
flu-incubation-duration
2
1
0
Number

INPUTBOX
12
353
128
413
flu-start-shedding
1
1
0
Number

INPUTBOX
12
412
128
472
flu-stop-shedding
2
1
0
Number

INPUTBOX
12
471
128
531
flu-symp-duration
4
1
0
Number

INPUTBOX
162
295
286
355
path-reporting-rate
100
1
0
Number

INPUTBOX
162
177
286
237
path-asymp-duration
21
1
0
Number

INPUTBOX
286
150
410
210
path-start-shedding
0
1
0
Number

INPUTBOX
162
354
286
414
path-symp-duration
12
1
0
Number

INPUTBOX
286
241
410
301
path-stop-shedding
2
1
0
Number

INPUTBOX
162
118
286
178
initial-asymp-prev
20
1
0
Number

INPUTBOX
162
236
286
296
path-pathogenicity-rate
0.0044
1
0
Number

PLOT
1114
92
1742
530
incidence of flu + prevalence of path infected state
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"flu" 1.0 0 -2674135 true "" "plot flu-new"
"inf" 1.0 0 -955883 true "" "plot count turtles with [path-ill?]"

SWITCH
286
118
481
151
asymp-state-contagious?
asymp-state-contagious?
0
1
-1000

SWITCH
286
209
474
242
symp-state-contagious?
symp-state-contagious?
0
1
-1000

SWITCH
286
300
466
333
path-immunity?
path-immunity?
1
1
-1000

INPUTBOX
15
580
65
640
acq-12
1
1
0
Number

INPUTBOX
64
580
114
640
acq-21
1
1
0
Number

INPUTBOX
15
639
65
699
trans-12
1
1
0
Number

INPUTBOX
64
639
114
699
trans-21
1
1
0
Number

INPUTBOX
15
698
65
758
inf-12
1
1
0
Number

INPUTBOX
286
332
410
392
immunity-duration
0
1
0
Number

OUTPUT
187
460
577
804
12

PLOT
691
92
1102
443
prevalence of path asymptomatic state
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot count turtles with [path-asymp-count >= 0]"

MONITOR
494
33
644
78
NIL
real-flu-infectiousness
2
1
11

INPUTBOX
12
117
128
177
flu-rate-immune
23
1
0
Number

MONITOR
494
77
644
122
NIL
path-transmission-rate
2
1
11

TEXTBOX
15
93
165
111
Influenza parameters
12
0.0
1

TEXTBOX
213
94
472
124
Endemic pathogen parameters
12
0.0
1

TEXTBOX
17
557
167
575
Interaction parameters
12
0.0
1

TEXTBOX
498
10
648
28
Monitors
12
0.0
1

TEXTBOX
262
439
506
469
Parameters recap for current run
12
0.0
1

@#$#@#$#@
# PURPOSE

We aim to simulate the co-circulation of influenza and another pathogen, interacting with each other at the host level in a virtual human population. Interactions with influenza and their consequences can vary according to several characteristics of the other pathogen at stake. Here we identified two groups of pathogens: some causing annual regular outbreaks but absent most of the year, and some that are endemically present in the population throughout the year. We implemented a simulator with two models based on the same core structure: one to represent the co-circulation of an influenza virus and an endemic pathogen, the other representing the co-circulation of an influenza virus and an epidemic pathogen.

This model is the one with the endemic pathogen.



# STATE VARIABLES AND SCALES
## INDIVIDUALS

Each individual is characterized by several state variables: age, a series of variables regarding their infectious status for influenza, and a series of variables regarding their infectious status for the second pathogen.



## TIME SCALE

The simulator time step unit is a day. The mean duration of all the possible states regarding the two pathogens have to be set by the user through several buttons. During the simulation, the true duration of a state for each individual getting infected is drawn from a gamma distribution of mean the value set by the user.

For the first pathogen we provide parameters’ values corresponding to influenza natural history: the incubation period has a mean duration of two days and is followed by a symptomatic phase with a mean duration of four days. During these two states, an individual is contagious starting the second day of influenza presence and ending two days after the beginning of symptoms. After the symptomatic period, we chose in our simulator to immunize the individual to this year’s influenza virus.

The same scheme applies to the second pathogen. The user has to define the mean durations of the asymptomatic and symptomatic phases, the duration of the contagious period, and the possible immunity after infection.

## SPACE

The model is spatially explicit. The individuals can move in what is referred to as a “world” in the NetLogo software. Here it is a torus, which is divided in patches. Two persons are considered in contact if they coincide on the same patch during a given time step. The dimension of the patches – and thus of the world – is set in order to have, on average, 13 contacts per person and per day.



# PROCESS OVERVIEW AND SCHEDULING

During each time step, six procedures are executed in a given order:

  1. reset of the daily new cases counters for each pathogen
  2. set of the characteristics (on the first day of the year) and launch of the current year’s epidemics of influenza and of the other pathogen if it is an epidemic one (on the chosen first days of the outbreaks)
  3. transmission of influenza
  4. transmission of the second pathogen
  5. global processes:
    a. reproduction of humans
    b. aging
    c. status update regarding influenza
    d. status update regarding the second pathogen
    e. counters update for the different pathogens states’ durations
    f. move of individuals in the world
  6. update of the daily new cases counters



# DESIGN CONCEPTS
## INTERACTIONS

Different interaction mechanisms are embedded in our model. They are based on the several biological mechanisms which were found in literature, and summed up into different macroscopic mechanisms in order to be implemented in the model.

Two mechanisms are common to both SimFI models: “acquisition” and “transmission”, and each model also have another interaction mechanism specific to the second pathogen’s nature: “cross-immunity” has only been observed in the case of two viruses co-circulating (SimFI-Epi), and “pathogenicity” has only been encountered when an epidemic and an endemic pathogens co-circulate (SimFI-End).

### Direction
Each mechanism can represent either an interaction from influenza on the second pathogen or the other way around, except for the “pathogenicity” interaction which is only an action of influenza on the endemic pathogen.

### Acquisition interaction
When already infected with one pathogen, one has a modified probability to be infected with the other pathogen during a certain period of time.
### Transmission interaction
When infected by the two pathogens, one has a modified probability to transmit the pathogens to susceptible others.

### Cross-immunity interaction
When immune to one pathogen, one has a modified probability to be infected with the other pathogen.

### Pathogenicity interaction
When infected by influenza and in the asymptomatic period of the endemic pathogen, one has a modified probability to develop an infection with the second pathogen.

## STOCHASTICITY

All random numbers and probabilities of transmission, acquisition and infection for both pathogens are randomly chosen (see below).

## REPRODUCIBILITY

NetLogo uses a random number generator to provide pseudo-random numbers which are determined by the choice of a seed at the beginning of each new simulation.

## OBSERVATIONS

NetLogo offers different visualization solutions like plots and variable monitors while the simulation is running, or recording of chosen variables values at each time step at the end of a simulation. By default, our simulator records the daily number of new symptomatic cases for influenza and the other pathogen.



# INITIALIZATION
## INDIVIDUALS SETUP

Upon initialization the individuals are uniformly distributed at random around the world, with uniformly distributed ages. All individuals are healthy. In the SimFI-End model, a number of randomly chosen individuals get infected with the endemic pathogen, according to the value set by the user.

## OUTBREAKS SETUP

At the beginning of each simulated year, the immunity from the past year is reset for all individuals and the characteristics for the epidemics pathogens are drawn from probability distributions: importation date, number of imported cases, infectiousness, and proportion of immune individuals at the beginning of the new season.

## DEFAULT VALUES

All default values are meant to reproduce the natural history of influenza virus and Streptococcus pneumoniae as second pathogen. The years are defined as starting on September 1st (ticks = 1 [364]) and ending on August 31st (ticks = 0 [364]).



# RELATED MODELS

This model was originally based on the Virus model from the NetLogo library.
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
