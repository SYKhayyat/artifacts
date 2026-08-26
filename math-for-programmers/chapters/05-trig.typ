#import "../lib.typ": *

= Trigonometry

== Forget the triangles

School trigonometry is taught with right triangles: SOH-CAH-TOA, opposite over
hypotenuse, and so on. That definition is historically first and pedagogically
last, because it only makes sense for angles between $0$ and $90 degree$, and
every interesting use of trigonometry involves angles outside that range or no
angles at all.

The right definition is the *unit circle*, and it makes everything else fall
out.

#definition(title: "sine and cosine")[
  Let $theta in RR$. Start at the point $(1, 0)$ and travel counterclockwise
  along the unit circle $x^2 + y^2 = 1$ for an arc length of $theta$ (going
  clockwise if $theta < 0$). You arrive at a point. Define
  $ (cos theta, sin theta) = "that point". $
]

That is the whole definition. Everything below is a consequence.

#intuition(title: "the one picture to keep")[
  A point going round and round a circle at constant speed. Its $x$-coordinate
  is $cos$, its $y$-coordinate is $sin$.

  Immediately obvious from that picture, with no algebra:

  - $cos^2 theta + sin^2 theta = 1$, because the point is on the unit circle.
    That is Pythagoras and it is now a triviality.
  - Both functions live in $[-1, 1]$.
  - Both repeat with period $2 pi$, because that is how far round the circle
    is.
  - $cos$ is even and $sin$ is odd: going $-theta$ reflects the point in the
    $x$-axis, which negates $y$ and leaves $x$ alone.
  - $sin(theta + pi slash 2) = cos theta$: a quarter turn swaps the roles.

  Every "identity" you were made to memorise is a statement about that
  rotating point.
]

== Radians, and why degrees are wrong

The definition above measured angle as *arc length on the unit circle*. That
unit is the *radian*. A full turn is the circumference, $2 pi$; a half turn is
$pi$; a right angle is $pi slash 2$.

Degrees are an arbitrary division of the circle into $360$ parts, inherited
from Babylonian astronomy. Nothing in mathematics prefers them, and using them
breaks calculus.

#warning(title: "degrees break the derivative")[
  In radians, $dif/(dif theta) sin theta = cos theta$. In degrees, it is
  $ dif/(dif theta) sin(theta degree) = (pi/180) cos(theta degree), $
  and that stray $pi slash 180$ then infects every formula downstream.

  The deep reason is the small-angle limit
  $ lim_(theta -> 0) (sin theta)/theta = 1, $
  which is *true only in radians* --- and which is itself just the statement
  that for a small arc, arc length and chord length agree. Radians are the
  unit that makes that ratio $1$, and calculus is built on it.

  Your language's `sin()` takes radians. Assume it does, always.
]

Useful conversions to have automatic: $pi slash 6 = 30 degree$,
$pi slash 4 = 45 degree$, $pi slash 3 = 60 degree$, $pi slash 2 = 90 degree$,
$pi = 180 degree$.

== The special values

These come from two triangles and are worth knowing cold.

#align(center)[
  #table(
    columns: 6,
    inset: 7pt,
    align: center,
    stroke: 0.4pt + luma(180),
    table.header([$theta$], [$0$], [$pi slash 6$], [$pi slash 4$], [$pi slash 3$], [$pi slash 2$]),
    [$sin theta$], [$0$], [$1 slash 2$], [$sqrt(2) slash 2$], [$sqrt(3) slash 2$], [$1$],
    [$cos theta$], [$1$], [$sqrt(3) slash 2$], [$sqrt(2) slash 2$], [$1 slash 2$], [$0$],
    [$tan theta$], [$0$], [$1 slash sqrt(3)$], [$1$], [$sqrt(3)$], [undef.],
  )
]

#intuition(title: "how to never memorise this table")[
  Write the sine row as
  $ sqrt(0)/2, quad sqrt(1)/2, quad sqrt(2)/2, quad sqrt(3)/2, quad sqrt(4)/2 $
  --- the numerators are just $sqrt(0), sqrt(1), sqrt(2), sqrt(3), sqrt(4)$ in
  order. The cosine row is the same list backwards, because
  $cos theta = sin(pi slash 2 - theta)$.

  That is the entire table, reconstructible in five seconds.
]

== The other four functions

$
tan theta = (sin theta)/(cos theta), quad
cot theta = (cos theta)/(sin theta), quad
sec theta = 1/(cos theta), quad
csc theta = 1/(sin theta).
$

$tan theta$ is the *slope* of the line from the origin through the point at
angle $theta$ --- which is why it appears whenever you convert between a
direction and a gradient. It has period $pi$, not $2 pi$, because opposite
directions have the same slope, and it blows up at $theta = pi slash 2$ where
the line is vertical.

== The identities that matter

#theorem(title: "Pythagorean identity")[
  $ cos^2 theta + sin^2 theta = 1. $
]

#proof[
  The point $(cos theta, sin theta)$ lies on the unit circle $x^2 + y^2 = 1$
  by definition. That is the identity.
]

Dividing through by $cos^2 theta$ gives $1 + tan^2 theta = sec^2 theta$, and
dividing by $sin^2 theta$ gives $cot^2 theta + 1 = csc^2 theta$. Do not
memorise those two; derive them when needed, it takes four seconds.

#theorem(title: "angle addition")[
  $
  cos(alpha + beta) &= cos alpha cos beta - sin alpha sin beta \
  sin(alpha + beta) &= sin alpha cos beta + cos alpha sin beta
  $
]

These are the workhorses. Everything else --- double angle, half angle,
product-to-sum --- is a corollary. Here is a proof that also explains *why*
they are true, which the usual geometric proof does not.

#proof[
  Recall from Chapter 3 that a rotation of the plane by angle $theta$ is a
  linear map, and (as we will verify in Chapter 20) its matrix is
  $ R_theta = mat(cos theta, -sin theta; sin theta, cos theta), $
  because it must send $(1,0) arrow.bar (cos theta, sin theta)$ and
  $(0,1) arrow.bar (-sin theta, cos theta)$ --- read straight off the unit
  circle.

  Now, rotating by $beta$ and then by $alpha$ is the same as rotating by
  $alpha + beta$. In matrix terms, $R_alpha R_beta = R_(alpha + beta)$.
  Multiply out the left side:
  $
  mat(cos alpha, -sin alpha; sin alpha, cos alpha)
  mat(cos beta, -sin beta; sin beta, cos beta)
  = mat(
    cos alpha cos beta - sin alpha sin beta, -(sin alpha cos beta + cos alpha sin beta);
    sin alpha cos beta + cos alpha sin beta, cos alpha cos beta - sin alpha sin beta
  ).
  $
  Setting this equal to $R_(alpha+beta)$ and comparing the top-left and
  bottom-left entries gives exactly the two identities.
]

#intuition(title: "what the angle addition formulas really are")[
  They are the statement that *rotations compose*. That is the whole content.

  This is also why they reappear as the multiplication rule for complex
  numbers in polar form (Chapter 6), as the rotation matrices of computer
  graphics (Chapter 35), and as the reason the Fourier transform turns
  convolution into multiplication. One fact, four costumes.
]

Setting $beta = alpha$ gives the *double angle* formulas:
$
sin 2 alpha &= 2 sin alpha cos alpha \
cos 2 alpha &= cos^2 alpha - sin^2 alpha = 2 cos^2 alpha - 1 = 1 - 2 sin^2 alpha
$
The last two forms come from substituting the Pythagorean identity, and they
rearrange into the *half angle* formulas
$ cos^2 alpha = (1 + cos 2 alpha)/2, quad sin^2 alpha = (1 - cos 2 alpha)/2, $
which are how you integrate $sin^2$ and $cos^2$ in Chapter 16.

== Waves: amplitude, frequency, phase

#definition(title: "sinusoid")[
  A *sinusoid* is a function
  $ f(t) = A sin(omega t + phi) $
  with *amplitude* $A$ (peak height), *angular frequency* $omega$ (radians per
  unit time; the period is $2 pi slash omega$), and *phase* $phi$ (where in the
  cycle it starts).
]

#theorem(title: "sum of two sinusoids of the same frequency")[
  For any $a, b$,
  $ a cos(omega t) + b sin(omega t) = R cos(omega t - phi) $
  where $R = sqrt(a^2 + b^2)$ and $phi = "atan2"(b, a)$.
]

#proof[
  Expand the right side with the angle addition formula:
  $ R cos(omega t - phi) = R cos phi cos(omega t) + R sin phi sin(omega t). $
  Matching coefficients requires $R cos phi = a$ and $R sin phi = b$. Squaring
  and adding: $R^2 (cos^2 phi + sin^2 phi) = a^2 + b^2$, so
  $R = sqrt(a^2+b^2)$. Dividing: $tan phi = b slash a$, with the quadrant
  determined by the signs of $a$ and $b$ --- which is exactly what `atan2`
  computes.
]

That theorem is the reason Fourier analysis works with sines and cosines
rather than needing an amplitude-and-phase representation everywhere: any
phase shift is a linear combination of a fixed sine and a fixed cosine. It is
also, geometrically, the conversion between Cartesian $(a,b)$ and polar
$(R, phi)$ coordinates --- the same conversion, seen twice.

== Inverse trigonometric functions

None of $sin$, $cos$, $tan$ is injective --- they repeat forever --- so none
has an inverse on its full domain. The fix, as always, is to restrict the
domain until the function is injective, then invert.

#align(center)[
  #table(
    columns: 4,
    inset: 7pt,
    align: (left, center, center, left),
    stroke: 0.4pt + luma(180),
    table.header([*Function*], [*Restricted domain*], [*Range of inverse*], [*Notes*]),
    [$arcsin$], [$[-pi slash 2, pi slash 2]$], [$[-pi slash 2, pi slash 2]$], [input in $[-1,1]$],
    [$arccos$], [$[0, pi]$], [$[0, pi]$], [input in $[-1,1]$],
    [$arctan$], [$(-pi slash 2, pi slash 2)$], [$(-pi slash 2, pi slash 2)$], [input any real],
  )
]

#warning(title: "arctan loses half the plane; use atan2")[
  Given a point $(x,y)$, you want its angle. Writing
  $theta = arctan(y slash x)$ is wrong and it is wrong in production code all
  the time.

  Two failures. First, $x = 0$ divides by zero. Second, and worse, the ratio
  $y slash x$ is identical for $(1,1)$ and $(-1,-1)$, so $arctan$ cannot tell
  the first quadrant from the third; it always returns an answer in
  $(-pi slash 2, pi slash 2)$, silently collapsing two quadrants onto two
  others.

  The correct function is the two-argument `atan2(y, x)`, which inspects the
  signs of both arguments and returns a full-range angle in $(-pi, pi]$. Use
  it. Always. Note the argument order: $y$ first.
]

== Laws of sines and cosines

For a triangle with sides $a, b, c$ and opposite angles $A, B, C$:

$ (sin A)/a = (sin B)/b = (sin C)/c quad "(law of sines)" $
$ c^2 = a^2 + b^2 - 2 a b cos C quad "(law of cosines)" $

The law of cosines is Pythagoras with a correction term, and it reduces to
Pythagoras exactly when $C = pi slash 2$, since $cos(pi slash 2) = 0$.

#intuition(title: "the law of cosines is the dot product")[
  In Chapter 19 we define the dot product of two vectors and prove
  $ u dot v = norm(u) norm(v) cos theta. $
  Put $u$ and $v$ as two sides of a triangle from a common vertex; the third
  side is $v - u$. Then
  $ norm(v-u)^2 = (v-u) dot (v-u) = norm(v)^2 - 2 u dot v + norm(u)^2 = norm(u)^2 + norm(v)^2 - 2 norm(u) norm(v) cos theta. $
  That *is* the law of cosines, in one line. The classical geometric proof is
  a page long; the vector proof is three symbols wide. This is a fair preview
  of what Part IV does to geometry generally.
]

== Where you will actually meet this

*Rotations.* Chapter 35. The matrix $R_theta$ above is the single most-used
object in computer graphics, robotics, and physics simulation.

*Periodic signals and Fourier analysis.* Any periodic function decomposes into
a sum of sinusoids. That is the basis of audio processing, JPEG, MP3, and the
convolution theorem.

*Complex numbers.* Chapter 6, where $e^(i theta) = cos theta + i sin theta$
compresses this entire chapter into one line.

*Distances on a sphere.* The haversine formula for great-circle distance is
trigonometry, and it is what every mapping API is doing.

*Attention.* In a transformer, rotary position embeddings (RoPE) encode token
position by *rotating* pairs of coordinates by an angle proportional to
position. The reason relative position falls out cleanly is the angle addition
formula: rotating by $theta_m$ then by $-theta_n$ leaves a rotation by
$theta_(m-n)$, which depends only on the difference.

== Exercises

#exercise[
  Using only the unit circle definition, evaluate $sin(7 pi slash 6)$,
  $cos(3 pi slash 4)$, and $tan(5 pi slash 3)$. State which quadrant each
  angle is in and use that to check the sign of your answer.
]

#exercise[
  Prove that $sin(alpha - beta) = sin alpha cos beta - cos alpha sin beta$
  from the addition formula, using only the fact that $sin$ is odd and $cos$ is
  even.
]

#exercise[
  Express $3 cos t + 4 sin t$ in the form $R cos(t - phi)$. Give $R$ exactly
  and $phi$ as an `atan2` expression.
]

#exercise[
  Derive $tan(alpha + beta) = (tan alpha + tan beta) slash (1 - tan alpha tan beta)$
  from the sine and cosine addition formulas. State the condition under which
  your derivation is valid.
]

#exercise[
  Show that $sin^4 theta$ can be written as a linear combination of
  $1$, $cos 2 theta$, and $cos 4 theta$, by applying the half-angle formula
  twice. (This is precisely the manipulation needed to integrate $sin^4$.)
]

#exercise[
  A point is at $(x, y) = (-3, -4)$. Compute its distance from the origin and
  its angle, giving the angle in $(-pi, pi]$. Explain in one sentence what
  $arctan(y slash x)$ would have returned instead and why that is wrong.
]

#exercise[
  Prove the law of sines. Hint: drop a perpendicular from one vertex to the
  opposite side and compute its length two different ways.
]
