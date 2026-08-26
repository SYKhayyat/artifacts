#import "../lib.typ": *

== Chapter 15 --- What Derivatives Are For

#soln("15.1")[
  $f(x) = x^3 - 3x^2 - 9x + 5$ on $[-2,4]$.

  $f'(x) = 3x^2 - 6x - 9 = 3(x^2 - 2x - 3) = 3(x-3)(x+1)$, so the critical
  points are $x = -1$ and $x = 3$, both interior to the interval. $f'$ exists
  everywhere, so there are no other candidates besides the endpoints.

  #table(
    columns: 5, inset: 6pt, stroke: 0.4pt + luma(180), align: center,
    table.header([$x$], [$-2$], [$-1$], [$3$], [$4$]),
    [$f(x)$], [$3$], [$10$], [$-22$], [$-15$],
  )

  (For instance $f(-1) = -1 - 3 + 9 + 5 = 10$ and
  $f(3) = 27 - 27 - 27 + 5 = -22$.)

  Absolute maximum $10$ at $x = -1$; absolute minimum $-22$ at $x = 3$.
]

#soln("15.2")[
  $f(x) = x^3 - x$ is a polynomial, hence continuous on $[-1,1]$ and
  differentiable on $(-1,1)$. And $f(-1) = -1 + 1 = 0 = 1 - 1 = f(1)$. All
  hypotheses hold.

  $f'(x) = 3x^2 - 1 = 0$ gives $x = plus.minus 1 slash sqrt(3) approx plus.minus 0.577$,
  both inside $(-1,1)$.

  So Rolle's theorem promises at least one such point and there are two.
]

#soln("15.3")[
  If $a = b$ both sides are zero. Otherwise, $sin$ is differentiable
  everywhere, so by the mean value theorem on the interval with endpoints $a$
  and $b$ there is a $c$ between them with
  $ sin a - sin b = cos(c) (a - b). $
  Taking absolute values and using $abs(cos c) <= 1$:
  $ abs(sin a - sin b) = abs(cos c) abs(a - b) <= abs(a-b). $

  In the vocabulary of the chapter: $sin$ is 1-Lipschitz, because its
  derivative is bounded by 1.
]

#soln("15.4")[
  *(a)* $0 slash 0$. Apply twice:
  $ lim (e^x - 1 - x)/(x^2) = lim (e^x - 1)/(2x) = lim (e^x)/2 = 1/2. $
  (Check with the series: $e^x - 1 - x = x^2 slash 2 + O(x^3)$.)

  *(b)* $0 dot infinity$ --- must be converted first. Write
  $x ln x = (ln x) slash (1 slash x)$, now $-infinity slash infinity$:
  $ lim_(x->0^+) (1 slash x)/(-1 slash x^2) = lim_(x->0^+) (-x) = 0. $

  *(c)* $1^infinity$. Take logs: $ln y = x ln(1 + 1 slash x) = ln(1+1 slash x) slash (1 slash x)$,
  which is $0 slash 0$. Differentiating top and bottom with respect to $x$:
  $ (-1 slash x^2)/(1 + 1 slash x) dot 1/(-1 slash x^2) = 1/(1 + 1 slash x) -> 1. $
  So $ln y -> 1$ and $y -> e$. (Which is the definition of $e$ from Chapter 4,
  recovered.)

  *(d)* $0 slash 0$:
  $ lim (tan x - x)/(x^3) = lim (sec^2 x - 1)/(3x^2) = lim (tan^2 x)/(3x^2) = 1/3, $
  using $sec^2 - 1 = tan^2$ and $tan x slash x -> 1$.
]

#soln("15.5")[
  With fixed volume $V = pi r^2 h$, the surface area of a closed cylinder is
  $A = 2 pi r^2 + 2 pi r h$. Substituting $h = V slash (pi r^2)$:
  $ A(r) = 2 pi r^2 + (2V)/r, quad r > 0. $

  $A'(r) = 4 pi r - 2V slash r^2 = 0$ gives $4 pi r^3 = 2V$, so
  $V = 2 pi r^3$. Then
  $ h = V/(pi r^2) = (2 pi r^3)/(pi r^2) = 2r. $

  So $h slash r = 2$: *the optimal can is as tall as it is wide* --- the
  height equals the diameter.

  $A''(r) = 4pi + 4V slash r^3 > 0$ for $r > 0$, so $A$ is convex and this is
  the global minimum.

  (Real drinks cans are noticeably taller than this, because the top and
  bottom are thicker than the walls and because people like the shape.)
]

#soln("15.6")[
  $f(x) = x^2 - 2$, $f'(x) = 2x$, so $x_(n+1) = x_n - (x_n^2 - 2) slash (2 x_n) = (x_n + 2 slash x_n) slash 2$.

  #table(
    columns: 4, inset: 6pt, stroke: 0.4pt + luma(180), align: (center, left, left, center),
    table.header([$n$], [$x_n$], [error $abs(x_n - sqrt(2))$], [correct digits]),
    [0], [$1$], [$4.14 times 10^(-1)$], [$0$],
    [1], [$1.5$], [$8.58 times 10^(-2)$], [$1$],
    [2], [$1.4166666dots$], [$2.45 times 10^(-3)$], [$2.6$],
    [3], [$1.4142156dots$], [$2.1 times 10^(-6)$], [$5.7$],
  )

  ($sqrt(2) = 1.41421356 dots$)

  The digit count roughly doubles at each step: $1 -> 2.6 -> 5.7$, and a
  fourth iteration would give about 12. That is quadratic convergence, exactly
  as the theorem predicts, with the asymptotic constant
  $abs(f'') slash (2 abs(f')) = 2 slash (2 dot 2 sqrt(2)) approx 0.354$.
]

#soln("15.7")[
  $f(x) = x^(1 slash 3)$, so $f'(x) = (1 slash 3) x^(-2 slash 3)$. The Newton
  step is
  $ x_(n+1) = x_n - (x_n^(1 slash 3))/((1 slash 3) x_n^(-2 slash 3)) = x_n - 3 x_n^(1 slash 3) x_n^(2 slash 3) = x_n - 3 x_n = -2 x_n. $

  So $x_n = (-2)^n x_0$: the iterates alternate in sign and *double* in
  magnitude every step. From any $x_0 != 0$ the method diverges, and it does
  so spectacularly.

  *Which hypothesis fails.* The convergence theorem requires $f'(r) != 0$ at
  the root $r = 0$. Here $f'(x) = (1 slash 3)x^(-2 slash 3) -> infinity$ as
  $x -> 0$: $f$ is not differentiable at the root at all (it has a vertical
  tangent, Chapter 14). The tangent line at any $x_n$ is nearly vertical near
  the root, so its intercept overshoots wildly.
]

#soln("15.8")[
  The pile is a cone with $h = r$ always, so
  $ V = (pi r^2 h)/3 = (pi h^3)/3. $

  *Differentiate the relation with respect to $t$ before substituting any
  values:*
  $ (dif V)/(dif t) = pi h^2 (dif h)/(dif t). $

  Now substitute $(dif V) slash (dif t) = 10$ and $h = 5$:
  $ 10 = pi (25) (dif h)/(dif t) quad arrow.r.double quad (dif h)/(dif t) = 10/(25 pi) = 2/(5 pi) approx 0.127. $

  The height is increasing at about $0.127$ units per second.

  Substituting $h = 5$ *before* differentiating would have turned $h$ into a
  constant and given $(dif V) slash (dif t) = 0$ --- the classic error in this
  topic.
]

== Chapter 16 --- Integration

#soln("16.1")[
  Partition $[0,1]$ into $n$ equal pieces, $Delta x = 1 slash n$, right
  endpoints $x_i = i slash n$:
  $
  sum_(i=1)^n f(x_i) Delta x = sum_(i=1)^n (i/n)^2 (1/n) = 1/(n^3) sum_(i=1)^n i^2.
  $
  By Chapter 2, $sum i^2 = n(n+1)(2n+1) slash 6$, so the sum is
  $ (n(n+1)(2n+1))/(6 n^3) = ((1)(1 + 1 slash n)(2 + 1 slash n))/6 arrow.r.long 2/6 = 1/3. $

  So $integral_0^1 x^2 dif x = 1 slash 3$, agreeing with the power rule
  antiderivative $x^3 slash 3$.
]

#soln("16.2")[
  *(a)* Substitute $u = x^2 + 1$, $dif u = 2x dif x$:
  $ integral x sqrt(x^2+1) dif x = 1/2 integral sqrt(u) dif u = 1/3 u^(3 slash 2) + C = ((x^2+1)^(3 slash 2))/3 + C. $

  *(b)* Substitute $u = ln x$, $dif u = dif x slash x$:
  $ integral (ln x)/x dif x = integral u dif u = ((ln x)^2)/2 + C. $

  *(c)* Substitute $u = sin x$, $dif u = cos x dif x$; the limits become
  $0$ and $1$:
  $ integral_0^(pi slash 2) sin^3 x cos x dif x = integral_0^1 u^3 dif u = 1/4. $

  *(d)* $ integral (dif x)/(x^2+9) = 1/3 arctan(x/3) + C, $ from the standard
  form with $u = x slash 3$.
]

#soln("16.3")[
  Take $u = x^2$, $dif v = e^(-x) dif x$, so $dif u = 2x dif x$ and
  $v = -e^(-x)$:
  $ integral x^2 e^(-x) dif x = -x^2 e^(-x) + 2 integral x e^(-x) dif x. $

  Parts again on the new integral, with $u = x$:
  $ integral x e^(-x) dif x = -x e^(-x) + integral e^(-x) dif x = -x e^(-x) - e^(-x). $

  Combining:
  $ integral x^2 e^(-x) dif x = -x^2 e^(-x) - 2x e^(-x) - 2 e^(-x) + C = -e^(-x)(x^2 + 2x + 2) + C. $

  Each application of parts reduced the power of $x$ by one --- which is the
  reason to choose the polynomial as $u$.
]

#soln("16.4")[
  Take $u = ln x$ and $dif v = dif x$, so $dif u = dif x slash x$ and
  $v = x$:
  $ integral ln x dif x = x ln x - integral x dot 1/x dif x = x ln x - x + C. $

  The trick is recognising that "there is only one factor" is not an obstacle:
  the second factor is $1$, and $dif v = dif x$ is a legitimate choice. The
  same device handles $integral arctan x dif x$ and $integral arcsin x dif x$.
]

#soln("16.5")[
  $x^2 + x - 6 = (x+3)(x-2)$, so
  $ (x+5)/((x+3)(x-2)) = A/(x+3) + B/(x-2), quad x + 5 = A(x-2) + B(x+3). $
  Put $x = 2$: $7 = 5B$, so $B = 7 slash 5$.
  Put $x = -3$: $2 = -5A$, so $A = -2 slash 5$.

  $ integral (x+5)/(x^2+x-6) dif x = -2/5 ln abs(x+3) + 7/5 ln abs(x-2) + C. $
]

#soln("16.6")[
  *(a)* $ integral_1^infinity x^(-3 slash 2) dif x = [ -2 x^(-1 slash 2) ]_1^infinity = 0 - (-2) = 2. $
  Converges ($p = 3 slash 2 > 1$).

  *(b)* $ integral_0^1 (dif x)/x = lim_(t->0^+) [ln x]_t^1 = lim_(t->0^+)(-ln t) = +infinity. $
  Diverges.

  *(c)* $ integral_0^infinity e^(-x) dif x = [-e^(-x)]_0^infinity = 0 + 1 = 1. $
  Converges.
]

#soln("16.7")[
  *Area.* The curves $y = x^2$ and $y = x+2$ meet where $x^2 = x + 2$, i.e.
  $x^2 - x - 2 = 0$, giving $x = -1$ and $x = 2$. On that interval the line is
  above the parabola, so
  $
  A = integral_(-1)^2 (x + 2 - x^2) dif x = [ x^2/2 + 2x - x^3/3 ]_(-1)^2 = (2 + 4 - 8/3) - (1/2 - 2 + 1/3) = 10/3 + 7/6 = 9/2.
  $

  *Volume.* Rotating $y = sqrt(x)$ on $[0,4]$ about the $x$-axis, the disc
  method gives cross-sectional area $pi (sqrt(x))^2 = pi x$:
  $ V = integral_0^4 pi x dif x = pi [x^2 slash 2]_0^4 = 8 pi. $
]

#soln("16.8")[
  $h = 0.25$, and $f(x) = e^(-x^2)$:
  $
  f(0) &= 1, quad f(0.25) = 0.939413, quad f(0.5) = 0.778801, \
  f(0.75) &= 0.569783, quad f(1) = 0.367879.
  $

  *Trapezoid.*
  $ T = h [ f_0/2 + f_1 + f_2 + f_3 + f_4/2 ] = 0.25 [0.5 + 2.287997 + 0.183940] = 0.742984. $
  Error: $abs(0.746824 - 0.742984) = 3.84 times 10^(-3)$.

  *Simpson.*
  $ S = h/3 [f_0 + 4f_1 + 2f_2 + 4f_3 + f_4] = (0.25)/3 [1 + 3.757652 + 1.557602 + 2.279132 + 0.367879] = 0.746855. $
  Error: $abs(0.746824 - 0.746855) = 3.1 times 10^(-5)$.

  *Comparison.* The errors differ by a factor of about $124$. The theory
  predicts trapezoid error $prop h^2$ and Simpson error $prop h^4$, so at
  $h = 0.25$ the ratio should be of order $1 slash h^2 = 16$ times the ratio
  of the two constants ($1 slash 12$ versus $1 slash 180$, another factor of
  15). $16 times 15 = 240$, the same order of magnitude as observed. The
  agreement is as good as one should expect from a four-interval estimate.
]

== Chapter 17 --- Sequences, Series, and Taylor Expansion

#soln("17.1")[
  *(a) $sum n slash (n^2+1)$.* Limit comparison with $sum 1 slash n$:
  the ratio $(n slash (n^2+1)) slash (1 slash n) = n^2 slash (n^2+1) -> 1$.
  Since the harmonic series diverges, so does this. *Diverges.*

  *(b) $sum 1 slash (n^2+1)$.* Comparison: $1 slash (n^2+1) < 1 slash n^2$,
  and $sum 1 slash n^2$ converges ($p = 2 > 1$). *Converges.*

  *(c) $sum n! slash n^n$.* Ratio test:
  $ (a_(n+1))/(a_n) = ((n+1)!)/((n+1)^(n+1)) dot (n^n)/(n!) = (n^n)/((n+1)^n) = 1/((1 + 1 slash n)^n) arrow.r.long 1/e < 1. $
  *Converges.*

  *(d) $sum (-1)^n slash sqrt(n)$.* Alternating series test: $1 slash sqrt(n)$
  is positive, decreasing, and tends to 0. *Converges* --- but only
  conditionally, since $sum 1 slash sqrt(n)$ is a $p$-series with
  $p = 1 slash 2 <= 1$ and diverges.

  *(e) $sum 2^n slash n!$.* Ratio test:
  $a_(n+1) slash a_n = 2 slash (n+1) -> 0 < 1$. *Converges* (to $e^2 - 1$ if
  the sum starts at $n=1$).
]

#soln("17.2")[
  *First.* Geometric with first term 3 and ratio $1 slash 4$:
  $ sum_(n=0)^infinity 3/4^n = 3 dot 1/(1 - 1 slash 4) = 3 dot 4/3 = 4. $

  *Second.* Geometric with ratio $2 slash 3$, starting at $n = 2$ so the first
  term is $(2 slash 3)^2 = 4 slash 9$:
  $ sum_(n=2)^infinity (2/3)^n = (4 slash 9)/(1 - 2 slash 3) = (4 slash 9)/(1 slash 3) = 4/3. $
]

#soln("17.3")[
  Ratio test on $sum (x-2)^n slash (n 3^n)$:
  $ abs((a_(n+1))/(a_n)) = abs(x-2)/3 dot n/(n+1) arrow.r.long abs(x-2)/3. $
  This is less than 1 iff $abs(x - 2) < 3$, so $R = 3$ and the open interval
  is $(-1, 5)$.

  *At $x = 5$:* the series becomes $sum 3^n slash (n 3^n) = sum 1 slash n$ ---
  the harmonic series. *Diverges.*

  *At $x = -1$:* it becomes $sum (-3)^n slash (n 3^n) = sum (-1)^n slash n$ ---
  alternating harmonic. *Converges* (conditionally).

  Interval of convergence: $[-1, 5)$.
]

#soln("17.4")[
  *By substitution.* In the geometric series
  $1 slash (1-u) = sum u^n$ put $u = -x^2$:
  $ 1/(1+x^2) = sum_(n=0)^infinity (-1)^n x^(2n) = 1 - x^2 + x^4 - dots.c, quad abs(x) < 1. $

  *By repeated differentiation* one gets the same coefficients, but the
  computation is unpleasant --- $f''$, $f'''$, $f^((4))$ of
  $(1+x^2)^(-1)$ are already messy. This is the general lesson: build new
  series from known ones by substitution, differentiation, and integration
  rather than from the definition.

  *Integrating term by term* from $0$ to $x$ (legal inside the radius):
  $ arctan x = sum_(n=0)^infinity ((-1)^n x^(2n+1))/(2n+1) = x - x^3/3 + x^5/5 - dots.c $

  *At $x = 1$* (where it converges, by the alternating series test, though the
  radius argument alone does not cover the endpoint):
  $ pi/4 = 1 - 1/3 + 1/5 - 1/7 + dots.c $
  --- the Leibniz formula. It converges so slowly that computing $pi$ to 10
  digits would need about $10^10$ terms.
]

#soln("17.5")[
  Four terms means the degree-3 Taylor polynomial:
  $ P_3 (0.5) = 1 + 0.5 + (0.25)/2 + (0.125)/6 = 1 + 0.5 + 0.125 + 0.0208333 = 1.6458333. $

  *Error bound.* By Taylor's theorem,
  $ R_3 = (e^xi)/(4!) (0.5)^4 quad "for some" xi in (0, 0.5). $
  Since $e^xi <= e^(0.5) approx 1.6487$,
  $ abs(R_3) <= (1.6487)(0.0625)/24 = 4.29 times 10^(-3). $

  *Actual error.* $e^(0.5) = 1.6487213$, so the true error is
  $1.6487213 - 1.6458333 = 2.89 times 10^(-3)$.

  The bound $4.29 times 10^(-3)$ correctly exceeds the actual
  $2.89 times 10^(-3)$, and is within a factor of 1.5 --- Taylor bounds are
  usually pessimistic by a small constant because they use the worst-case
  derivative on the interval.
]

#soln("17.6")[
  $ sin x = x - x^3/6 + x^5/120 - dots.c $
  so
  $ sin x - x = -x^3/6 + x^5/120 - dots.c $
  and dividing by $x^3$:
  $ (sin x - x)/(x^3) = -1/6 + x^2/120 - dots.c arrow.r.long -1/6. $

  Compare the L'Hôpital route: three applications, each requiring you to
  differentiate correctly and confirm the form is still $0 slash 0$. The
  series does it by inspection --- which is generally true, and is why series
  are the better tool for limits at a point once you have them.
]

#soln("17.7")[
  *Convergence.* $1 slash n$ is positive, decreasing, and tends to 0, so the
  alternating series test applies. (The sum is $ln 2$, from the series for
  $ln(1+x)$ at $x = 1$.)

  *Error.* The alternating series bound says the error after $N$ terms is at
  most the first omitted term, $1 slash (N+1)$. Requiring
  $1 slash (N+1) < 10^(-3)$ gives $N >= 1000$.

  *Why nobody does this.* A thousand terms for three decimal digits --- and by
  the same bound, a million terms for six, and $10^(15)$ for fifteen. Each
  extra digit costs a factor of ten in work.

  The practical alternative: use
  $ ln((1+x)/(1-x)) = 2(x + x^3/3 + x^5/5 + dots.c) $
  with $x = 1 slash 3$, which gives $ln 2$ and converges like $9^(-n)$ ---
  about one digit per term. Argument reduction plus a fast-converging series
  is the standard recipe for every transcendental function in a library.
]

#soln("17.8")[
  Integral test with $f(x) = 1 slash (x (ln x)^p)$, which is positive and
  decreasing for $x >= 2$.

  Substitute $u = ln x$, $dif u = dif x slash x$:
  $ integral_2^infinity (dif x)/(x (ln x)^p) = integral_(ln 2)^infinity (dif u)/(u^p). $

  By the $p$-test of Chapter 16, this converges iff $p > 1$.

  So $sum 1 slash (n (ln n)^p)$ converges iff $p > 1$.

  Note the case $p = 1$: $sum 1 slash (n ln n)$ *diverges*, but only just ---
  its partial sums grow like $ln ln n$. Iterating gives an infinite hierarchy
  of series each diverging more slowly than the last, and no single "slowest
  divergent series" exists.
]

== Chapter 18 --- Calculus in Many Variables

#soln("18.1")[
  $f(x,y) = x^3 y - 4 x y^2 + y$.

  $
  (partial f)/(partial x) = 3x^2 y - 4y^2, quad (partial f)/(partial y) = x^3 - 8 x y + 1.
  $

  At $(1,2)$:
  $ nabla f(1,2) = vec(3(1)(2) - 4(4), 1 - 8(1)(2) + 1) = vec(-10, -14). $

  Second partials:
  $
  f_(x x) = 6 x y, quad f_(x y) = 3x^2 - 8y, quad f_(y y) = -8x,
  $
  so
  $ H = mat(6 x y, 3x^2 - 8y; 3x^2 - 8y, -8x), quad H(1,2) = mat(12, -13; -13, -8). $
  Symmetric, as Clairaut requires.
]

#soln("18.2")[
  $f(x,y) = x^2 + 3x y$, so $nabla f = (2x + 3y, thin 3x)$ and
  $nabla f(1,2) = (8, 3)$.

  *Normalise the direction:* $norm((3,4)) = 5$, so $u = (3 slash 5, 4 slash 5)$.

  $ D_u f(1,2) = nabla f dot u = (8)(3 slash 5) + (3)(4 slash 5) = (24+12)/5 = 36/5 = 7.2. $

  Forgetting to normalise would give $36$ --- five times too large, and
  dimensionally meaningless, since a directional derivative is a rate per unit
  distance.
]

#soln("18.3")[
  $f(x,y) = x^2 e^(x y)$.

  $ f_x = 2x e^(x y) + x^2 y e^(x y) = e^(x y)(2x + x^2 y), $
  $ f_(x y) = x e^(x y)(2x + x^2 y) + e^(x y)(x^2) = e^(x y)(2x^2 + x^3 y + x^2) = e^(x y)(3x^2 + x^3 y). $

  Other order:
  $ f_y = x^3 e^(x y), quad f_(y x) = 3x^2 e^(x y) + x^3 y e^(x y) = e^(x y)(3x^2 + x^3 y). $

  Equal. ✓
]

#soln("18.4")[
  $f(x,y) = x^3 - 3x + y^2$.

  $nabla f = (3x^2 - 3, thin 2y) = 0$ gives $x = plus.minus 1$, $y = 0$: two
  critical points, $(1,0)$ and $(-1,0)$.

  $ H = mat(6x, 0; 0, 2). $

  *At $(1,0)$:* $H = diag(6, 2)$, both eigenvalues positive --- positive
  definite. *Local minimum*, value $f(1,0) = -2$.

  *At $(-1,0)$:* $H = diag(-6, 2)$, eigenvalues of both signs --- indefinite.
  *Saddle point*, value $f(-1,0) = 2$.

  Geometrically: along the $x$-axis $f$ behaves like a cubic (up then down),
  along the $y$-axis like a parabola (up). At $(-1,0)$ those two disagree,
  which is exactly what a saddle is.
]

#soln("18.5")[
  *By the chain rule.* With $z = x^2 y$, $x = cos t$, $y = sin t$:
  $
  (dif z)/(dif t) &= (partial z)/(partial x) (dif x)/(dif t) + (partial z)/(partial y) (dif y)/(dif t) \
  &= (2 x y)(-sin t) + (x^2)(cos t) \
  &= -2 cos t sin^2 t + cos^3 t.
  $

  *By substitution first.* $z = cos^2 t sin t$, so by the product and chain
  rules
  $ (dif z)/(dif t) = 2 cos t (-sin t) sin t + cos^2 t cos t = -2 cos t sin^2 t + cos^3 t. $

  Identical. ✓ The chain rule version generalises to cases where substituting
  is impossible; the direct version is a good check.
]

#soln("18.6")[
  Minimise $f = x^2 + y^2 + z^2$ subject to $g = 2x + 3y + z - 12 = 0$.

  *Why squaring is legitimate:* $sqrt(dot)$ is strictly increasing on
  $[0,infinity)$, so it preserves the order of nonnegative quantities and
  therefore has the same minimiser (Chapter 2's "safe transformation"). And
  the squared distance is differentiable at the origin while the distance is
  not.

  $nabla f = lambda nabla g$ gives
  $ 2x = 2 lambda, quad 2y = 3 lambda, quad 2z = lambda, $
  so $x = lambda$, $y = 3 lambda slash 2$, $z = lambda slash 2$.

  Substituting into the constraint:
  $ 2 lambda + (9 lambda)/2 + lambda/2 = 12 quad arrow.r.double quad 7 lambda = 12 quad arrow.r.double quad lambda = 12/7. $

  So the closest point is $(12 slash 7, thin 18 slash 7, thin 6 slash 7)$, at
  distance $sqrt(144 + 324 + 36) slash 7 = sqrt(504) slash 7 = 12 slash sqrt(14)$.

  Sanity check: the closest point on a plane to the origin lies along the
  normal direction $(2,3,1)$ --- and indeed our point is
  $(6 slash 7)(2,3,1)$. ✓
]

#soln("18.7")[
  $
  integral_0^1 integral_0^2 (x + y^2) dif x dif y = integral_0^1 [ x^2/2 + y^2 x ]_(x=0)^(x=2) dif y = integral_0^1 (2 + 2y^2) dif y = 2 + 2/3 = 8/3.
  $

  Other order:
  $
  integral_0^2 integral_0^1 (x + y^2) dif y dif x = integral_0^2 [ x y + y^3/3 ]_(y=0)^(y=1) dif x = integral_0^2 (x + 1/3) dif x = 2 + 2/3 = 8/3.
  $

  Equal, as Fubini guarantees for a continuous integrand on a rectangle.
]

#soln("18.8")[
  In polar coordinates $x^2 + y^2 = r^2$ and $dif A = r dif r dif theta$, and
  the unit disc is $0 <= r <= 1$, $0 <= theta <= 2pi$:
  $
  integral.double_R (x^2+y^2) dif A = integral_0^(2pi) integral_0^1 r^2 dot r dif r dif theta = 2 pi [ r^4/4 ]_0^1 = (2 pi)/4 = pi/2.
  $

  The extra $r$ from the Jacobian is what makes the inner integral
  $integral r^3 dif r$ rather than $integral r^2 dif r$ --- getting it wrong
  gives $2 pi slash 3$, and the error is invisible unless you know it should
  be there.
]

#soln("18.9")[
  Write $h = W_1 x in RR^h$, $a = sigma(h)$, $y = W_2 a in RR$, $L = f(y)$.

  Chain rule as a product of Jacobians, from the loss backwards:
  $ (partial L)/(partial W_1) quad "requires" quad underbrace((partial L)/(partial y), 1 times 1) dot underbrace((partial y)/(partial a), 1 times h) dot underbrace((partial a)/(partial h), h times h "diagonal") dot underbrace((partial h)/(partial W_1), "" ). $

  Concretely, with $g = partial L slash partial y$ (a scalar here):
  $ delta = (W_2^T g) circle.small sigma'(h) in RR^h, quad (partial L)/(partial W_1) = delta thin x^T in RR^(h times n). $

  *Cost.* Multiplying *left to right* (reverse mode): $W_2^T g$ is a
  matrix--vector product costing $O(h)$, the elementwise product costs $O(h)$,
  and the outer product $delta x^T$ costs $O(h n)$. Total $O(h n)$ ---
  the same order as one forward pass.

  Multiplying *right to left* (forward mode) would require materialising
  $partial h slash partial W_1$, which has $h times (h n)$ entries, and then
  contracting through the $h times h$ Jacobian: $O(h^2 n)$.

  Reverse mode is cheaper by a factor of $h$, the hidden width --- and in a
  real network, by a factor equal to the parameter count.
]
