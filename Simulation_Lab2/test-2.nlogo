globals [
  percent-similar  ;; середній відсоток сусідів того ж кольору
  percent-unhappy  ;; відсоток незадоволених черепах
  colors           ;; список кольорів для черепах
  population-size  ;; розмір популяції
  percent-similar-wanted ;; необхідний відсоток схожих сусідів для щастя
  attraction-factor ;; фактор притягання між черепахами одного кольору
]

turtles-own [
  happy?                  ;; чи задоволена черепаха своїм оточенням
  similar-nearby          ;; кількість сусідніх черепах того ж кольору
  total-nearby            ;; загальна кількість сусідніх черепах
  disappearance-probability ;; ймовірність зникнення черепахи
]

to setup
  clear-all
  set colors [red green yellow blue orange]
  set percent-similar-wanted 50  ;; Припустимо, 50% схожих сусідів потрібно для щастя
  ;; створюємо черепах на випадкових патчах
  ask n-of number patches [
    sprout 1 [
      set color (item (random number-of-ethnicities) colors)
    ]
  ]
  set attraction-factor 0.1 ;; Припустимо, 0.1 як базове значення
  update-turtles
  update-globals
  reset-ticks
end

to go
  if all? turtles [happy?] [ stop ]
  move-unhappy-turtles
  check-for-disappearance
  update-turtles
  update-globals
  update-population-size
  tick
end

to move-unhappy-turtles
  ask turtles with [not happy?] [
    let my-color color  ; зберігаємо колір поточної черепахи
    let target-patch max-one-of (neighbors) [
      count (turtles-here) with [color = my-color]
    ]

    if target-patch != nobody [
      face target-patch
      fd 1 + (attraction-factor * count (turtles-on target-patch) with [color = my-color])
    ]

    if any? other turtles-here [
      find-new-spot
    ]
    setxy pxcor pycor
  ]
end


to find-new-spot
  rt random-float 360
  fd random-float 10
  if any? other turtles-here [
    find-new-spot
  ]
  setxy pxcor pycor
end

to update-turtles
  ask turtles [
    set similar-nearby count (turtles-on neighbors) with [color = [color] of myself]
    set total-nearby count (turtles-on neighbors)
    set happy? similar-nearby >= (percent-similar-wanted * total-nearby / 100)
  ]
end

to update-globals
  let similar-neighbors sum [similar-nearby] of turtles
  let total-neighbors sum [total-nearby] of turtles
  set percent-similar (similar-neighbors / total-neighbors) * 100
  set percent-unhappy (count turtles with [not happy?]) / (count turtles) * 100
end

to update-population-size
  set population-size count turtles
end

to check-for-disappearance
  ask turtles [
    calculate-disappearance-probability
    if random-float 1 < disappearance-probability [ die ]
  ]
end

to calculate-disappearance-probability
  let foreign-neighbors count (turtles-on neighbors) with [color != [color] of myself]
  let same-neighbors count (turtles-on neighbors) with [color = [color] of myself]

  set total-nearby foreign-neighbors + same-neighbors

  ;; Використання ifelse замість if
  ifelse total-nearby > 0 [
    set disappearance-probability (foreign-neighbors - same-neighbors) / total-nearby
  ] [
    ;; Якщо немає сусідів, можна встановити ймовірність зникнення як 0 або будь-яке інше базове значення
    set disappearance-probability 0
  ]
end