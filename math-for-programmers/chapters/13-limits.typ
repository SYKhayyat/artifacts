#import "../lib.typ": *

= Limits and Continuity

== The problem calculus was invented to solve

Two questions, both about two thousand years old, both apparently
unanswerable.

*What is the slope of a curve at a point?* Slope is rise over run, but at a
single point there is no run. You get $0 slash 0$.

*What is the area under a curve?* Area is base times height, but the height
keeps changing. You get an infinite sum of infinitely thin things.

Both questions have the same shape: a quantity that is undefined at the
target, but which seems to be *approaching* something as you get close. The
concept that makes "approaching something" precise is the limit, and it is the
single foundational idea of all of calculus.

#intuition(title: "what a limit is, before any symbols")[
  $lim_(x -> a) f(x) = L$ says:

  *You can make $f(x)$ as close to $L$ as anyone demands, provided you take
  $x$ close enough to $a$.*

  Not "$f(a) = L$". Not "$f$ eventually equals $L$". It is a promise about a
  negotiation: you name a tolerance, and I can name a neighbourhood of $a$
  inside which I meet it. Every time. No matter how small your tolerance.

  Note especially: *the value of $f$ at $a$ is irrelevant.* The limit is about
  the neighbourhood of $a$ with $a$ itself deleted. That is not a technicality
  --- it is the entire point, because the interesting cases are exactly the
  ones where $f(a)$ is undefined.
]

== The definition

#definition(title: "limit")[
  $ lim_(x -> a) f(x) = L $
  means: for every $epsilon > 0$ there exists $delta > 0$ such that for all
  $x$,
  $ 0 < abs(x - a) < delta quad arrow.r.double quad abs(f(x) - L) < epsilon. $
]

Read it with the vocabulary of Chapter 7. It is
$forall epsilon thin exists delta thin forall x : (dots)$, and the order
matters: $delta$ is allowed to depend on $epsilon$ (and on $a$), which is
exactly the negotiation described above.

Read $abs(x-a)$ and $abs(f(x)-L)$ as *distances*, per Chapter 1. Then the
statement is: for any target distance $epsilon$ around $L$, there is a
distance $delta$ around $a$ that guarantees it. The strict inequality
$0 < abs(x-a)$ is what excludes $x = a$ itself.

#example(title: "an epsilon-delta proof, in full")[
  *Claim:* $lim_(x -> 3) (2x + 1) = 7$.

  *Scratch work* (this is not the proof; it is how you find it). We want
  $abs((2x+1) - 7) < epsilon$, i.e. $abs(2x - 6) < epsilon$, i.e.
  $2 abs(x - 3) < epsilon$, i.e. $abs(x-3) < epsilon slash 2$. So
  $delta = epsilon slash 2$ should work.

  *Proof.* Let $epsilon > 0$ be given. Choose $delta = epsilon slash 2$.
  Suppose $0 < abs(x - 3) < delta$. Then
  $ abs((2x+1) - 7) = 2 abs(x - 3) < 2 delta = epsilon. $
  Since $epsilon$ was arbitrary, the limit is $7$. 

  The structure is fixed and worth memorising: *let $epsilon$ be given; choose
  $delta = dots$; suppose $abs(x-a) < delta$; derive $abs(f(x)-L) < epsilon$.*
  All the creativity is in the scratch work, which you do backwards and then
  discard.
]

#example(title: "the limit that motivates everything")[
  $ lim_(x -> 2) (x^2 - 4)/(x - 2). $

  At $x = 2$ this is $0 slash 0$ --- genuinely undefined, the function has no
  value there. But for every $x != 2$,
  $ (x^2 - 4)/(x-2) = ((x-2)(x+2))/(x-2) = x + 2, $
  and the cancellation is legal precisely because $x != 2$, which is exactly
  the region the limit looks at. So the limit is $4$.

  This is the shape of every derivative: a quotient that is $0 slash 0$ at the
  point, but which simplifies to something well-behaved everywhere else.
]

== Limit laws

#theorem(title: "algebra of limits")[
  Suppose $lim_(x->a) f(x) = L$ and $lim_(x->a) g(x) = M$. Then
  $
  lim (f + g) &= L + M, quad lim (f g) = L M, \
  lim (c f) &= c L, quad lim (f/g) = L/M "if" M != 0.
  $
]

#proof[
  We prove the sum; it shows the technique.

  Let $epsilon > 0$. Since $f -> L$, there is $delta_1$ with
  $abs(f(x) - L) < epsilon slash 2$ whenever $0 < abs(x-a) < delta_1$.
  Similarly there is $delta_2$ for $g$ with tolerance $epsilon slash 2$.

  Let $delta = min(delta_1, delta_2)$. Then for $0 < abs(x - a) < delta$,
  both hold, and by the triangle inequality (Chapter 1)
  $ abs((f(x)+g(x)) - (L+M)) <= abs(f(x)-L) + abs(g(x)-M) < epsilon/2 + epsilon/2 = epsilon. $
]

#intuition(title: "the epsilon-over-2 trick")[
  Splitting the budget --- give each source of error half the tolerance ---
  is the standard move in every analysis proof. You will see $epsilon slash 3$
  when there are three error terms, and $epsilon slash 2^n$ when there are
  infinitely many.

  It is exactly error-budget reasoning: total error must stay under
  $epsilon$, so allocate a share to each contributor.
]

== One-sided limits, and when limits fail

#definition(title: "one-sided limits")[
  $lim_(x -> a^+) f(x)$ requires the condition only for $a < x < a + delta$;
  $lim_(x -> a^-) f(x)$ only for $a - delta < x < a$.
]

#proposition[
  $lim_(x->a) f(x) = L$ if and only if both one-sided limits exist and equal
  $L$.
]

A limit can fail to exist in three distinguishable ways:

*The two sides disagree.* $sgn(x)$ at $0$: the left limit is $-1$, the right
is $+1$. This is a *jump discontinuity*.

*It blows up.* $1 slash x^2$ at $0$. We write $lim = +infinity$, which is
shorthand for "exceeds any bound", not a claim that the limit exists.

*It oscillates.* $sin(1 slash x)$ at $0$ oscillates infinitely fast and never
settles. There is no $L$ and no infinity.

#theorem(title: "squeeze theorem")[
  If $g(x) <= f(x) <= h(x)$ near $a$ (except possibly at $a$) and
  $lim_(x->a) g = lim_(x->a) h = L$, then $lim_(x->a) f = L$.
]

#proof[
  Let $epsilon > 0$. Choose $delta$ small enough that both
  $abs(g(x) - L) < epsilon$ and $abs(h(x) - L) < epsilon$ hold. Then
  $ L - epsilon < g(x) <= f(x) <= h(x) < L + epsilon, $
  so $abs(f(x) - L) < epsilon$.
]

#example(title: "the squeeze in action")[
  $lim_(x->0) x^2 sin(1 slash x)$. The sine oscillates wildly and has no
  limit, so the product law does not apply. But
  $-1 <= sin(1 slash x) <= 1$, so
  $ -x^2 <= x^2 sin(1/x) <= x^2, $
  and both outer functions tend to $0$. Hence the limit is $0$.

  This is also the standard example of a function that is differentiable
  everywhere but whose derivative is not continuous, once you get to Chapter
  14.
]

#theorem(title: "the fundamental trigonometric limit")[
  $ lim_(theta -> 0) (sin theta)/theta = 1. $
]

#proof[
  Take $0 < theta < pi slash 2$ and compare three areas in the unit circle:
  the triangle with vertices $(0,0), (1,0), (cos theta, sin theta)$; the
  circular sector of angle $theta$; and the triangle with vertices
  $(0,0),(1,0),(1,tan theta)$. Nesting gives
  $ 1/2 sin theta <= 1/2 theta <= 1/2 tan theta. $
  Divide through by $(1 slash 2) sin theta > 0$:
  $ 1 <= theta/(sin theta) <= 1/(cos theta). $
  Take reciprocals (reversing the inequalities):
  $ cos theta <= (sin theta)/theta <= 1. $
  As $theta -> 0^+$, $cos theta -> 1$, so the squeeze theorem gives the limit
  from the right. The function is even, so the left limit agrees.
]

This is where the radian convention pays for itself (Chapter 5): the middle
term is the *arc length* of the sector, and it is $theta$ only in radians.
Every derivative of a trigonometric function traces back to this limit.

== Limits at infinity

#definition[
  $lim_(x -> infinity) f(x) = L$ means: for every $epsilon > 0$ there is $M$
  such that $x > M$ implies $abs(f(x) - L) < epsilon$.
]

Same negotiation, with "close to $a$" replaced by "large". These limits are
where asymptotic analysis lives: $f(n) = o(g(n))$ from Chapter 11 is exactly
$lim_(n->infinity) f(n) slash g(n) = 0$.

For rational functions, divide top and bottom by the highest power in the
denominator:
$ lim_(x->infinity) (3x^2 + 5x)/(2x^2 - 1) = lim_(x->infinity) (3 + 5 slash x)/(2 - 1 slash x^2) = 3/2. $

== Continuity

#definition(title: "continuous")[
  $f$ is *continuous at $a$* if
  $ lim_(x -> a) f(x) = f(a). $
  This bundles three requirements: $f(a)$ is defined, the limit exists, and
  they agree. $f$ is *continuous on a set* if it is continuous at each point
  of it.
]

#intuition(title: "continuity is 'no surprises'")[
  The informal "you can draw it without lifting the pen" is a decent picture
  and a bad definition (it fails for functions on disconnected domains, and it
  smuggles in the intermediate value theorem).

  The engineering reading is better: *continuity means a small change in input
  produces a small change in output.* A discontinuous function is one where an
  arbitrarily tiny nudge to the input can swing the output by a fixed amount
  --- which is exactly the situation in which floating-point error, sensor
  noise, or a rounding decision becomes catastrophic rather than negligible.

  Chapter 33's notion of a *well-conditioned* problem is a quantitative
  version of this.
]

By the limit laws, sums, products, quotients (where the denominator is
nonzero), and compositions of continuous functions are continuous. Polynomials
are continuous everywhere; rational functions wherever defined;
$sin, cos, exp$ everywhere; $ln$ on $(0,infinity)$.

=== The three big theorems

These are the payoff for the completeness axiom of Chapter 1, and all three
are false over $QQ$.

#theorem(title: "intermediate value theorem")[
  If $f$ is continuous on $[a,b]$ and $y$ lies between $f(a)$ and $f(b)$, then
  there is $c in [a,b]$ with $f(c) = y$.
]

#proof[
  Assume $f(a) < y < f(b)$ (the other case is symmetric). Let
  $ S = {x in [a,b] : f(x) < y}. $
  $S$ is nonempty ($a in S$) and bounded above by $b$, so by completeness it
  has a supremum $c = sup S$.

  *Not $f(c) > y$:* by continuity there would be a neighbourhood of $c$ where
  $f > y$, so points slightly below $c$ are not in $S$, making a smaller
  number an upper bound --- contradicting leastness.

  *Not $f(c) < y$:* then $c < b$, and by continuity there is a neighbourhood
  of $c$ where $f < y$, so some point above $c$ is in $S$ --- contradicting
  that $c$ is an upper bound.

  By trichotomy, $f(c) = y$.
]

#example(title: "the IVT is the bisection algorithm")[
  To solve $f(x) = 0$ with $f$ continuous, $f(a) < 0 < f(b)$: evaluate at the
  midpoint, keep whichever half still brackets a sign change, repeat.

  The IVT is the *correctness proof*: at every stage the bracket contains a
  root, and the bracket width halves each iteration, so after $k$ steps you
  have located a root to within $(b-a) slash 2^k$. Guaranteed convergence, no
  assumptions beyond continuity.

  And this is why it fails over $QQ$: $f(x) = x^2 - 2$ changes sign on $[1,2]$
  but has no rational root. Bisection would run forever, narrowing on nothing.
  Completeness is what puts something at the limit.
]

#theorem(title: "extreme value theorem")[
  A continuous function on a *closed, bounded* interval $[a,b]$ attains a
  maximum and a minimum.
]

Both hypotheses are essential. On the open interval $(0,1)$, $f(x) = x$ has no
maximum. On the unbounded $[0,infinity)$, $f(x) = x$ has no maximum. On
$[0,1]$ with $f(x) = 1 slash x$ for $x>0$ and $f(0)=0$, discontinuity kills
it. Remove any one hypothesis and there is a counterexample.

The EVT is why "find the maximum of $f$ on $[a,b]$" is a well-posed problem at
all --- Chapter 15's optimisation procedure would be searching for something
that might not exist.

#theorem(title: "Bolzano--Weierstrass")[
  Every bounded sequence of reals has a convergent subsequence.
]

#proof[
  Let $(a_n)$ lie in $[A, B]$. Bisect the interval; at least one half contains
  infinitely many terms of the sequence --- pick it. Bisect again, and so on.
  This produces nested intervals of width $(B-A) slash 2^k$, each containing
  infinitely many terms. Choose $a_(n_1)$ from the first, $a_(n_2)$ from the
  second with $n_2 > n_1$, and so on.

  The interval endpoints converge to a common point $L$ by completeness, and
  $abs(a_(n_k) - L) <= (B-A) slash 2^k -> 0$.
]

#theorem(title: "monotone convergence")[
  A bounded, monotone sequence converges.
]

#proof[
  Say $(a_n)$ is increasing and bounded above. Let $L = sup{a_n}$, which
  exists by completeness. Given $epsilon > 0$, $L - epsilon$ is not an upper
  bound, so some $a_N > L - epsilon$. Since the sequence is increasing, for
  all $n >= N$ we have $L - epsilon < a_N <= a_n <= L$, hence
  $abs(a_n - L) < epsilon$.
]

This is the theorem you use constantly without noticing: it is why an
increasing, bounded loop variable settles; why Newton's method converges once
it is monotone; and why the definition of $e$ in Chapter 4 makes sense at all
($(1 + 1 slash n)^n$ is increasing and bounded above).

== Uniform continuity, briefly

#definition[
  $f$ is *uniformly continuous* on $S$ if
  $ forall epsilon > 0 thin exists delta > 0 thin forall x, y in S : abs(x-y) < delta arrow.r.double abs(f(x)-f(y)) < epsilon. $
]

Compare with ordinary continuity: there, $delta$ was allowed to depend on the
point $a$. Here one $delta$ must work everywhere. That is Chapter 7's warning
about quantifier order, made concrete.

$f(x) = 1 slash x$ on $(0,1)$ is continuous but not uniformly so: near zero
the function is so steep that no single $delta$ suffices. $f(x) = x^2$ on all
of $RR$ has the same problem at infinity.

#theorem[
  A continuous function on a closed bounded interval is uniformly continuous.
]

This matters computationally: uniform continuity is what lets you pick a
single step size for a numerical method and have the error bound hold across
the whole interval. Without it you would need an adaptive mesh --- which, when
uniform continuity genuinely fails, is exactly what adaptive quadrature does
(Chapter 33).

== Exercises

#exercise[
  Prove from the definition that $lim_(x->1)(3x - 2) = 1$, exhibiting your
  $delta$ explicitly in terms of $epsilon$.
]

#exercise[
  Prove from the definition that $lim_(x->2) x^2 = 4$. (You will need to bound
  $abs(x+2)$; do so by first restricting $delta <= 1$.)
]

#exercise[
  Evaluate, showing your reasoning:
  (a) $lim_(x->3) (x^2 - 9) slash (x - 3)$;
  (b) $lim_(x->0) (sqrt(1+x) - 1) slash x$ (multiply by the conjugate);
  (c) $lim_(x->0) sin(5x) slash x$;
  (d) $lim_(x->infinity) (4x^3 - x) slash (2x^3 + 7)$.
]

#exercise[
  Use the squeeze theorem to evaluate $lim_(x->0) x cos(1 slash x^2)$.
]

#exercise[
  Give an example of functions $f$ and $g$ where neither $lim_(x->0) f$ nor
  $lim_(x->0) g$ exists, but $lim_(x->0)(f+g)$ does. Explain why this does not
  contradict the sum law.
]

#exercise[
  Determine the value of $c$ that makes
  $ f(x) = cases((x^2 - 1)/(x-1) quad &x != 1, c &x = 1) $
  continuous at $x = 1$.
]

#exercise[
  Use the intermediate value theorem to prove that $x^3 - x - 1 = 0$ has a
  root in $[1,2]$, and state how many bisection steps are needed to locate it
  to within $10^(-6)$.
]

#exercise[
  Prove that every polynomial of odd degree has at least one real root. (Use
  the IVT plus the behaviour of the leading term as $x -> plus.minus infinity$.)
]
