globals[
  mouse-was-down?  ; a boolean representing whether the mouse was already clicked
  grabbed   ; a user-selected vertex
  v1   ; vertex 1
  v2   ; vertex 2
  v3   ; vertex 3
  d1   ; distance of Line 1 (which lies opposite Vertex 1)
  d2   ; distance of Line 2 (which lies opposite Vertex 2)
  d3   ; distance of Line 3 (which lies opposite Vertex 3)
]

breed [ dots dot ]
breed [ users user ]
breed [ vertices vertex ]

to setup
  clear-all
  ; Create lattice with dots at each patch
  ask patches [
    set pcolor 0
    sprout-dots 1 [
      set color 45
      set size 0.2
      set heading 0
      set shape "circle"
    ]
  ]

  set v1 nobody
  set v2 nobody
  set v3 nobody
  set d1 0
  set d2 0
  set d3 0

  draw-triangle
  create-users 1 [ hide-turtle ]   ; sets up user in the background
  reset-ticks

end

to draw-triangle
  ; Randomly generate three vertices
  create-vertices 3 [
    move-to one-of patches with [not any? vertices-here]
    set shape "target"
    set size 0.5
    set color 115
    create-links-with other vertices         ; creates links to form a triangle
    ask links [
      set color 85   set thickness 0.1
    ]
  ]
  ; label all vertices V1, V2, V3
  set v1 min-one-of vertices [who]
  ask v1 [ set label "V1      " ]
  set v2 vertex ([who] of v1 + 1)
  ask v2 [ set label "V2      " ]
  set v3 max-one-of vertices [who]
  ask v3 [ set label "V3      " ]
  ask vertices [ set label-color yellow ]
  ; measure length of each side using distances between vertices
  ask v1 [
    set d1 distance v2
    set d2 distance v3
  ]
  ask v2 [
    set d3 distance v3
  ]
  ; label all sides S1, S2, S3
  ask link [who] of v1 [who] of v2 [ set label "S3  " ]
  ask link [who] of v1 [who] of v3 [ set label "S2  " ]
  ask link [who] of v2 [who] of v3 [ set label "S1  " ]
  ask links [ set label-color white ]
  display
end


to go
  ; set the (hidden) user's coordinates to the mouse coordinates
  ask users [ setxy mouse-xcor mouse-ycor ]
  ; when mouse is first clicked, select a vertex (if there is one nearby)
  if mouse-down? and not mouse-was-down? [
    set grabbed one-of vertices with [distance one-of users < 0.4]
  ]
  ; while the mouse is down,
  ; update location of grabbed vertex to the lattice dot closest to the mouse
  if-else mouse-down?  [
    if grabbed != nobody [
      if-else mouse-was-down? [
        ; move grabbed vertex to lattice dot nearest to the mouse
        let v-xcor [xcor] of min-one-of dots [ distancexy mouse-xcor mouse-ycor ]
        let v-ycor [ycor] of min-one-of dots [ distancexy mouse-xcor mouse-ycor ]
        ask grabbed [ setxy v-xcor v-ycor ]
        ; update length of each side
        ask v1 [
          set d1 distance v2
          set d2 distance v3
        ]
        ask v2 [
          set d3 distance v3
        ]
        display
      ][
        ask grabbed [ set color white   set size 0.75 ]
      ]
      set mouse-was-down? true
    ]
  ][ ; when mouse released, reset global variables, and vertex color and size
    set mouse-was-down? false
    ask vertices [ set color 115   set size 0.5 ]
    set grabbed nobody
  ]
end

; Use Heron's Formula to calculate area of a triangle: Area = sqrt(s(s-a)(s-b)(s-c))
; where s is the semiperimeter (half the perimeter) of the triangle
to-report area
  let accurate-area sqrt (semiperimeter * (semiperimeter - d1) * (semiperimeter - d2) * (semiperimeter - d3))
  let nearest-tenth round (10 * accurate-area)
  report nearest-tenth / 10
end

; reports semiperimeter (used in area reporter)
to-report semiperimeter
  let perimeter d1 + d2 + d3    ; perimeter is the sum of the lengths of all sides
  report perimeter / 2          ; semiperimeter is half the perimeter
end

; reports area to the user
; prompts user to think about further problems
to check-area
  let area-new area + 0.5
  user-message (word
    (word "The area of the triangle is " area " square units.  Can you make a different triangle with the same area?  Can you make a triangle with area ")
    area-new " square units?")
end


; Copyright 2017 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
185
10
543
369
-1
-1
70.0
1
14
1
1
1
0
0
0
1
0
4
0
4
0
0
1
ticks
30.0

BUTTON
20
10
83
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
96
10
159
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

BUTTON
20
210
160
243
NIL
check-area
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
20
60
160
105
length of side S3
d1
2
1
11

MONITOR
20
105
160
150
length of side S2
d2
2
1
11

MONITOR
20
150
160
195
length of side S1
d3
2
1
11

@#$#@#$#@
## WHAT IS IT?

_Lattice Land - Triangles Explore_ is one of several models in the Lattice Land software suite. Lattice Land is an interactive MathLand, a microworld in which students can uncover advanced mathematical thinking through play, conjecture, and experimentation. It provides another entryway into geometry, investigating the geometry of a discrete lattice of points. In Lattice Land, there is no one right answer and no pre-determined pathway you must travel. However, even seemingly trivial exercises can quickly become rich explorations.

A lattice is an array of dots on a plane such that there is one dot at each coordinate (x,y), where x and y are integers. Thus each dot on the lattice is one unit away from each of its four closest neighbors (one above, one below, one to the left, and one to the right). A lattice triangle is a triangle whose vertices fall on dots of the lattice.

The setup of this model resembles a traditional GeoBoard with 25 pegs and 16 square units. In this exploratory triangles model, you can click and drag the vertices of a lattice triangle to explore all possible triangles within this space. You can track and explore the relationships between side lengths, perimeter, and area of triangles, as well as the space of possible and impossible lattice triangles.

## HOW IT WORKS

We've implemented a lattice in NetLogo by using agents called DOTS sprouted at the center of each patch. The segments between the dots are simply edges or links. The environment then responds to click-and-drag of the mouse.

In this model, the lattice is restricted to a 4 unit by 4 unit lattice. Additionally, the user can only work with the triangle, which is randomly generated at setup. This model mimics the appearance and functionality of the popular geometry manipulative GeoBoard. Students can make triangles with areas ranging from 0.5 square units to 8 square units, and every 0.5 square-unit increment in between. This will require them to create triangles which have neither base nor height parallel to the Cartesian x- or y-axis.

This model uses Heron's Formula to calculate area of a triangle:

* Area = sqrt(s(s-a)(s-b)(s-c))
* where s is the semiperimeter (half the perimeter) of the triangle

## HOW TO USE IT

The SETUP button creates a world with the given dimensions and size set by the sliders.

Press the GO button.

Click and hold any vertex of the triangle to drag the vertex to any other DOT on the lattice.  Create triangles with different areas and perimeters.

Look at the three LENGTH OF SIDE monitors to track the lengths of sides S1, S2, and S3, labeled on the triangle.

Press CHECK-AREA to verify area calculations.

## THINGS TO NOTICE

Students should be encouraged to think about how they define a triangle. Not all possible constructions with this model are what we typically think of as triangles. For example, if all three sides of the triangle are collinear is it still a triangle? (In this example, we have a three-sided closed figure, but it forms a line segment.) How can we make more rigorous definitions of "triangle" to exclude non-triangles?

## THINGS TO TRY

Consider all the ways we classify triangles. Some triangles are easy to construct (right triangles, or isosceles triangles) while others are impossible in Lattice Land. Challenge students to prove why it is impossible to construct an equilateral triangle in Lattice Land. It is helpful to use the LENGTH monitors to help determine distances when they appear to be similar.

See if you can generalize some rules or formulas for the area of lattice triangles.

* What is the smallest possible area you can get on the lattice?
* What is the largest possible area you can get with a GeoBoard Triangle?
* Notice that you can produce a triangle with every possible area in between (at 0.5 square unit increments).
* How many different triangles can you create on the GeoBoard with the same area?

## EXTENDING THE MODEL

This model does not report the angles within the triangle. How would you incorporate angles into the study of triangle area?

## NETLOGO FEATURES

This model uses continuous updates, rather than tick-based updates. This means that the model does not update at regular time intervals (ticks) dictated by the code. Instead, this model updates when the user performs an action. Thus, the depth of inquiry into the mathematics of Lattice Land is dictated by the user: nothing (other than the lattice) is generated until the user draws something.

## RELATED MODELS

* Lattice Land - Triangles Dissection
* Lattice Land - Explore

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Pei, C. and Wilensky, U. (2017).  NetLogo Lattice Land - Triangles Explore model.  http://ccl.northwestern.edu/netlogo/models/LatticeLand-TrianglesExplore.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2017 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2017 Cite: Pei, C. -->
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
NetLogo 6.1.0
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
1
@#$#@#$#@
