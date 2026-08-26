#import "../lib.typ": *

= What Derivatives Are For

== The theorem everything rests on

Almost every use of the derivative depends on one theorem, and it is worth
seeing why.

#theorem(title: "Fermat's theorem on interior extrema")[
  If $f$ has a local maximum or minimum at an interior point $c$ of its
  domain, and $f'(c)$ exists, then $f'(c) = 0$.
]

#proof[
  Suppose $c$ is a local maximum, so $f(c + h) <= f(c)$ for all small $h$.

  For $h > 0$: $(f(c+h) - f(c)) slash h <= 0$, so the right-hand limit
  $f'(c) <= 0$.

  For $h < 0$: the numerator is still $<= 0$ but the denominator is negative,
  so the quotient is $>= 0$, giving $f'(c) >= 0$.

  Both hold, so $f'(c) = 0$. The minimum case reverses the inequalities.
]

#warning(title: "the converse is false, and both hypotheses matter")[
  $f'(c) = 0$ does *not* imply an extremum: $f(x) = x^3$ has $f'(0) = 0$ and
  no extremum at $0$. Points with $f' = 0$ are *candidates*, called *critical
  points*, and must be tested.

  "Interior" matters: on $[0,1]$, $f(x) = x$ has its maximum at $x=1$, where
  the derivative is $1$, not $0$. Endpoints must be checked separately.

  "$f'(c)$ exists" matters: $abs(x)$ has a minimum at $0$ where there is no
  derivative at all.

  So the full recipe for optimising $f$ on $[a,b]$ is: evaluate $f$ at every
  point where $f' = 0$, at every point where $f'$ fails to exist, and at the
  two endpoints. Compare. The Extreme Value Theorem (Chapter 13) is what
  guarantees the answer is in that finite list.
]

#theorem(title: "Rolle's theorem")[
  If $f$ is continuous on $[a,b]$, differentiable on $(a,b)$, and
  $f(a) = f(b)$, then $f'(c) = 0$ for some $c in (a,b)$.
]

#proof[
  By the Extreme Value Theorem $f$ attains a maximum and a minimum on
  $[a,b]$. If both occur at endpoints, then since $f(a) = f(b)$ the max and
  min are equal, so $f$ is constant and $f' = 0$ everywhere inside. Otherwise
  one of them occurs at an interior point $c$, and Fermat's theorem gives
  $f'(c) = 0$.
]

#theorem(title: "mean value theorem")[
  If $f$ is continuous on $[a,b]$ and differentiable on $(a,b)$, then there is
  $c in (a,b)$ with
  $ f'(c) = (f(b) - f(a))/(b - a). $
]

#proof[
  Let $L(x)$ be the straight line through $(a,f(a))$ and $(b,f(b))$, and set
  $g = f - L$. Then $g(a) = g(b) = 0$, so Rolle gives $c$ with $g'(c) = 0$,
  i.e. $f'(c) = L'(c) = (f(b)-f(a)) slash (b-a)$.
]

#intuition(title: "the MVT is the bridge from local to global")[
  In words: *somewhere in the interval, the instantaneous rate equals the
  average rate.* If you averaged 60 mph over an hour, at some instant your
  speedometer read exactly 60.

  Its importance is structural. The derivative is a purely *local* object ---
  it knows only about an infinitesimal neighbourhood. The MVT is the tool that
  converts local information into global conclusions, and essentially every
  such conversion goes through it:

  - $f' = 0$ everywhere $arrow.r.double$ $f$ is constant.
  - $f' > 0$ everywhere $arrow.r.double$ $f$ is increasing.
  - $abs(f') <= M$ everywhere $arrow.r.double$ $abs(f(x)-f(y)) <= M abs(x-y)$
    (Lipschitz).

  Each of these is proved by applying the MVT on an arbitrary subinterval, and
  none of them can be proved without it.
]

#corollary[
  If $f' > 0$ on an interval, $f$ is strictly increasing there.
]

#proof[
  Take $x < y$ in the interval. By the MVT there is $c$ between them with
  $f(y) - f(x) = f'(c)(y - x) > 0$.
]

The Lipschitz corollary above is worth naming, since it is the standard
hypothesis in numerical analysis and in optimisation:

#definition(title: "Lipschitz")[
  $f$ is *$L$-Lipschitz* on $S$ if $abs(f(x) - f(y)) <= L abs(x-y)$ for all
  $x,y in S$. By the MVT, $abs(f') <= L$ implies $L$-Lipschitz.
]

A Lipschitz function cannot change faster than a fixed rate. Gradient descent
converges (Chapter 34) precisely under the assumption that the *gradient* is
Lipschitz, and the learning rate you are allowed to use is $1 slash L$.

== Optimisation

#algo(title: "Finding the extrema of $f$ on $[a,b]$")[
```
1. Compute f'.
2. Solve f'(x) = 0 for critical points in (a,b).
3. Find points in (a,b) where f' does not exist.
4. Evaluate f at all points from 2, 3, and at a and b.
5. The largest value is the max; the smallest is the min.
```
]

To classify an interior critical point without evaluating everything:

#theorem(title: "second derivative test")[
  Let $f'(c) = 0$. If $f''(c) > 0$ then $c$ is a local minimum; if
  $f''(c) < 0$, a local maximum. If $f''(c) = 0$ the test is inconclusive.
]

#proof[
  Suppose $f''(c) > 0$. Then $f'$ is increasing near $c$ (previous corollary
  applied to $f'$). Since $f'(c) = 0$, $f'$ is negative just left of $c$ and
  positive just right. So $f$ decreases into $c$ and increases out of it: a
  local minimum.
]

$f(x) = x^4$ and $f(x) = x^3$ both have $f'' (0)= 0$; the first has a minimum
and the second does not. Hence "inconclusive".

#example(title: "a real optimisation")[
  A rectangular box with a square base and no lid must hold $32$ cubic units.
  Minimise the material used.

  Let the base be $x times x$ and the height $h$. The constraint is
  $x^2 h = 32$, so $h = 32 slash x^2$. The surface area is
  $ A = x^2 + 4 x h = x^2 + 4x dot 32/x^2 = x^2 + 128/x, quad x > 0. $

  Differentiate: $A' = 2x - 128 slash x^2$. Setting $A' = 0$ gives
  $2x^3 = 128$, so $x = 4$, and then $h = 2$.

  Check: $A'' = 2 + 256 slash x^3 > 0$ for $x>0$, so this is a minimum, and
  since it is the only critical point on $(0,infinity)$ it is the global one.
  The minimum area is $16 + 32 = 48$.

  Note the shape of the work: *express the objective in one variable using the
  constraint, then differentiate.* Chapter 34 shows how to avoid the
  substitution using Lagrange multipliers, which is essential when the
  constraint cannot be solved.
]

== L'Hôpital's rule

#theorem(title: "L'Hôpital's rule")[
  Suppose $f(a) = g(a) = 0$ (or both tend to $plus.minus infinity$), $f$ and
  $g$ are differentiable near $a$, and $g' != 0$ near $a$. If
  $lim_(x->a) f'(x) slash g'(x)$ exists, then
  $ lim_(x -> a) f(x)/g(x) = lim_(x->a) (f'(x))/(g'(x)). $
]

#proof[
  Sketch, for the $0 slash 0$ case with $f, g$ continuous at $a$. Apply the
  *Cauchy mean value theorem* --- a two-function version of the MVT which
  says there is $c$ between $a$ and $x$ with
  $ (f(x) - f(a)) g'(c) = (g(x)-g(a)) f'(c). $
  Since $f(a) = g(a) = 0$ this becomes $f(x) g'(c) = g(x) f'(c)$, so
  $ f(x)/g(x) = (f'(c))/(g'(c)). $
  As $x -> a$, $c$ is squeezed to $a$ too, and the right side tends to the
  assumed limit.
]

#intuition(title: "why differentiating both parts is legitimate")[
  Near $a$, $f(x) approx f'(a)(x-a)$ and $g(x) approx g'(a)(x - a)$, since
  both vanish at $a$. The ratio is then approximately
  $f'(a) slash g'(a)$ --- the $(x-a)$ factors cancel.

  So L'Hôpital is not a trick; it is the statement that the ratio of two
  vanishing quantities is the ratio of the *rates* at which they vanish.
]

#warning(title: "the ways people misuse it")[
  *Check the indeterminate form first.* $lim_(x->0)(x+1) slash (x+2)$ is
  $1 slash 2$. Applying L'Hôpital blindly gives $1 slash 1 = 1$, which is
  wrong. The rule requires $0 slash 0$ or $infinity slash infinity$.

  *It can loop.* $lim_(x->infinity) (e^x) slash (e^x)$ differentiates to
  itself forever.

  *It can fail to help even when valid.* Some limits get worse with each
  application. Series expansion (Chapter 17) is often better.

  *Other indeterminate forms need conversion first.* $0 dot infinity$,
  $infinity - infinity$, $1^infinity$, $0^0$, $infinity^0$ must be rewritten
  as a quotient --- typically by taking logs or by combining into a single
  fraction --- before the rule applies.
]

#example(title: "proving the growth hierarchy of Chapter 4")[
  *Logarithms lose to every power.* For $k > 0$,
  $ lim_(x->infinity) (ln x)/(x^k) = lim_(x->infinity) (1 slash x)/(k x^(k-1)) = lim_(x->infinity) 1/(k x^k) = 0. $

  *Every power loses to every exponential.* For $b > 1$ and positive integer
  $k$, apply L'Hôpital $k$ times:
  $ lim_(x->infinity) (x^k)/(b^x) = lim (k x^(k-1))/(b^x ln b) = dots.c = lim (k!)/(b^x (ln b)^k) = 0. $

  Those two computations justify the entire asymptotic hierarchy of Chapter 11.
]

== Linear approximation and Newton's method

#definition(title: "linearisation")[
  The *linearisation* of $f$ at $a$ is
  $ L(x) = f(a) + f'(a)(x - a). $
  For $x$ near $a$, $f(x) approx L(x)$, with error $o(abs(x-a))$.
]

This is the first-order Taylor polynomial and, per Chapter 14, is what
differentiability *means*. Two large consequences.

=== Error propagation

If $x$ is known with uncertainty $Delta x$, then $f(x)$ has uncertainty
approximately $abs(f'(x)) Delta x$. The derivative is the amplification
factor for error.

In relative terms, dividing by $f(x)$:
$ ("relative error in " f)/("relative error in " x) approx abs((x f'(x))/(f(x))). $
That quantity is the *condition number* of $f$ at $x$, and Chapter 33 is
largely about it. A function with a large condition number destroys precision
no matter how carefully you implement it.

=== Newton's method

To solve $f(x) = 0$: replace $f$ by its linearisation at the current guess and
solve *that* exactly.

$ 0 = f(x_n) + f'(x_n)(x - x_n) quad arrow.r.double quad x_(n+1) = x_n - (f(x_n))/(f'(x_n)). $

#theorem(title: "quadratic convergence")[
  If $f$ is twice continuously differentiable, $f(r) = 0$, $f'(r) != 0$, and
  $x_0$ is close enough to $r$, then the errors $e_n = x_n - r$ satisfy
  $ abs(e_(n+1)) <= C abs(e_n)^2 $
  for a constant $C$ near $abs(f''(r)) slash (2 abs(f'(r)))$.
]

#proof[
  Taylor-expand $f$ about $x_n$ and evaluate at $r$ (Chapter 17 supplies the
  remainder form):
  $ 0 = f(r) = f(x_n) + f'(x_n)(r - x_n) + (f''(xi))/2 (r - x_n)^2 $
  for some $xi$ between. Divide by $f'(x_n)$ and rearrange:
  $ r - [x_n - (f(x_n))/(f'(x_n))] = -(f''(xi))/(2 f'(x_n)) (r-x_n)^2. $
  The bracket is $x_(n+1)$, so $abs(e_(n+1)) = abs(f''(xi)) slash (2 abs(f'(x_n))) dot e_n^2$.
]

#intuition(title: "what quadratic convergence buys you")[
  The number of correct digits *doubles* each iteration. From 3 correct digits
  you get 6, then 12, then 24. In practice Newton's method reaches full double
  precision in four or five iterations from a decent start.

  Compare bisection, which gains one *bit* per iteration --- about 50
  iterations for full precision. The difference is the difference between
  linear and quadratic convergence, and it is why Newton is the default
  wherever a derivative is available.
]

#warning(title: "Newton's failure modes are all real")[
  *Bad start.* Convergence is only guaranteed locally. Far away, Newton can
  diverge, oscillate between two points, or jump to a different root.

  *$f'(x_n) approx 0$.* The step is enormous and you are thrown off.

  *Multiple roots.* If $f'(r) = 0$ too (a repeated root), convergence degrades
  to linear.

  Production root-finders (Brent's method, for one) hybridise: use Newton or
  secant steps when they look productive, fall back to bisection when they do
  not. That gives Newton's speed with bisection's guarantee, and it is the
  right engineering answer.
]

Newton's method generalises directly to optimisation: to minimise $f$, solve
$f'(x) = 0$ by Newton, giving
$ x_(n+1) = x_n - (f'(x_n))/(f''(x_n)). $
In many variables the derivative becomes the gradient and the second
derivative becomes the Hessian, and that is Chapter 34.

== Curve sketching

A checklist, useful mostly as a way of organising what the derivatives tell
you.

+ *Domain* and any points of discontinuity.
+ *Intercepts:* solve $f(x) = 0$ and evaluate $f(0)$.
+ *Symmetry:* even, odd, periodic (Chapter 3).
+ *Asymptotes:* vertical where the function blows up; horizontal from
  $lim_(x->plus.minus infinity) f$; slant if $deg$ of numerator exceeds
  denominator by exactly one.
+ *First derivative:* critical points, intervals of increase and decrease.
+ *Second derivative:* inflection points, intervals of concavity.
+ Assemble.

The two derivative rows are the informative ones: $f'$ gives the *direction*
of travel, $f''$ gives the *bend*. Everything else is bookkeeping.

== Related rates

If several quantities are linked by an equation and all vary with time,
differentiating the equation with respect to $t$ links their rates.

#example[
  A ladder 10 units long leans against a wall. Its base slides away at 1 unit
  per second. How fast is the top descending when the base is 6 units from the
  wall?

  Let $x$ be the base distance and $y$ the height. Then $x^2 + y^2 = 100$
  at all times. Differentiate with respect to $t$:
  $ 2x (dif x)/(dif t) + 2y (dif y)/(dif t) = 0. $
  At the instant in question $x = 6$, so $y = 8$, and $(dif x) slash (dif t) = 1$.
  Substituting: $12 + 16 (dif y) slash (dif t) = 0$, so
  $(dif y) slash (dif t) = -3 slash 4$. Descending at $0.75$ units per second.

  The pattern: write the *constraint* that holds at all times, then
  differentiate it. Do not substitute the instantaneous values until after
  differentiating --- substituting first turns variables into constants and
  destroys their derivatives. This is the single most common error in the
  topic.
]

== Exercises

#exercise[
  Find the absolute maximum and minimum of $f(x) = x^3 - 3x^2 - 9x + 5$ on
  $[-2, 4]$, following the full recipe including endpoints.
]

#exercise[
  Verify that $f(x) = x^3 - x$ satisfies the hypotheses of Rolle's theorem on
  $[-1, 1]$ and find every $c$ the theorem promises.
]

#exercise[
  Use the mean value theorem to prove that $abs(sin a - sin b) <= abs(a - b)$
  for all reals $a, b$.
]

#exercise[
  Evaluate with L'Hôpital where valid, and say explicitly which indeterminate
  form each is: (a) $lim_(x->0) (e^x - 1 - x) slash x^2$;
  (b) $lim_(x->0^+) x ln x$; (c) $lim_(x->infinity)(1 + 1 slash x)^x$;
  (d) $lim_(x->0) (tan x - x) slash x^3$.
]

#exercise[
  A closed cylindrical can must hold a fixed volume $V$. Find the ratio of
  height to radius that minimises the surface area, and check with the second
  derivative test.
]

#exercise[
  Carry out three iterations of Newton's method on $f(x) = x^2 - 2$ starting
  from $x_0 = 1$. Record the error at each step and verify that the number of
  correct digits roughly doubles.
]

#exercise[
  Show that Newton's method applied to $f(x) = x^(1 slash 3)$ from any
  $x_0 != 0$ diverges, by computing the iteration explicitly. Which hypothesis
  of the convergence theorem fails?
]

#exercise[
  Sand falls into a conical pile whose height always equals its base radius,
  at a rate of $10$ cubic units per second. How fast is the height increasing
  when the pile is $5$ units high? (The volume of a cone is
  $V = pi r^2 h slash 3$.)
]
