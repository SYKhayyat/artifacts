#import "../lib.typ": *

= Numerical Computing

== The gap between mathematics and machines

Every previous chapter assumed exact real arithmetic. Your machine does not
have it. This chapter is about the difference, and it is not a footnote: most
"the code is right but the answer is wrong" bugs in numerical work live here.

The organising distinction:

#definition(title: "conditioning and stability")[
  A *problem* is *ill-conditioned* if small changes in the input cause large
  changes in the exact answer. This is a property of the problem, and no
  algorithm can fix it.

  An *algorithm* is *unstable* if it introduces errors much larger than the
  problem's conditioning requires. This is the algorithm's fault, and a better
  algorithm can fix it.
]

#intuition(title: "assign blame correctly")[
  When your numerical result is garbage, exactly one of two things happened.

  Either the *problem* was hopeless --- you asked for the intersection of two
  nearly parallel lines, and the answer genuinely does depend enormously on
  the tenth digit of the input. Then no code will save you and you need to
  reformulate.

  Or your *method* was bad --- you subtracted two nearly equal numbers, or
  eliminated with a tiny pivot, or squared a condition number by forming
  $A^T A$. Then a different method with the same mathematics will work.

  The professional habit is to ask which before reaching for higher precision.
  Doubling precision buys 16 more digits, which is a lot when the algorithm is
  slightly unstable and nothing at all when $kappa = 10^30$.
]

== Floating point

#definition(title: "IEEE 754 binary64")[
  A double is $plus.minus 1.f times 2^(e)$: one sign bit, 11 exponent bits
  (biased), 52 stored fraction bits giving 53 bits of significand (the leading
  1 is implicit for normal numbers).

  - *Machine epsilon:* $epsilon = 2^(-52) approx 2.22 times 10^(-16)$, the
    gap between $1$ and the next representable number.
  - *Range:* roughly $10^(-308)$ to $10^(308)$, plus subnormals down to
    $10^(-324)$ at reduced precision.
  - *Special values:* $plus.minus 0$, $plus.minus infinity$, and NaN.
]

#theorem(title: "the fundamental axiom of floating point")[
  For any basic operation $circle.small in {+,-,times,div}$ on
  representable $a, b$,
  $ "fl"(a circle.small b) = (a circle.small b)(1 + delta), quad abs(delta) <= epsilon slash 2. $
  Each individual operation is correctly rounded, with tiny *relative* error.
]

The word *relative* is the key. Absolute error scales with magnitude: near
$1$ the spacing is $10^(-16)$; near $10^9$ it is $10^(-7)$; beyond $2^53$
consecutive integers are not representable at all.

#warning(title: "the consequences you must internalise")[
  *Never test equality.* `0.1 + 0.2 == 0.3` is false, because none of the
  three is representable exactly (Chapter 1). Test
  `abs(a-b) <= max(atol, rtol * max(abs(a), abs(b)))` --- absolute tolerance
  for values near zero, relative tolerance elsewhere.

  *Addition is not associative.* $(a+b)+c != a+(b+c)$. Parallel reductions
  give different answers on different runs and different thread counts. If you
  need reproducibility you need a fixed reduction order, or compensated
  summation.

  *NaN is not equal to itself.* `NaN == NaN` is false, by design, so
  `x != x` is the standard NaN test. NaN also poisons everything it touches,
  which is useful for debugging: the first NaN is where the bug is, and
  everything after it is a symptom.

  *Integers above $2^53$ lose precision as doubles.* This is why JSON is not
  safe for 64-bit IDs, and why they get quoted as strings.

  *Subnormals are slow.* On many CPUs, arithmetic on subnormal numbers takes
  a hundred times longer, and audio code and physics simulations that decay
  towards zero hit this. Flush-to-zero mode exists for this reason.
]

== Catastrophic cancellation

The single most important failure mode.

#intuition(title: "subtraction does not lose precision --- it reveals loss")[
  Take $a = 1.0000000000000002$ and $b = 1.0000000000000000$, each with 16
  correct digits. Their difference is $2 times 10^(-16)$, computed exactly ---
  the subtraction itself is fine.

  The problem is that the *inputs* already had rounding error of order
  $10^(-16)$, which was invisible when it was in the 16th digit of a number
  near 1, and is now the *entire content* of the result. The relative error
  went from $10^(-16)$ to order 1.

  Cancellation does not create error. It promotes existing error from
  irrelevant to dominant. Which is why the cure is never "be more careful with
  the subtraction" and always "rearrange so the subtraction does not happen".
]

#example(title: "four cancellations and their fixes")[
  *The quadratic formula.* When $b^2 gt.double 4 a c$,
  $-b + sqrt(b^2 - 4 a c)$ cancels. Fix (Chapter 2): compute the root with
  matching signs, then get the other from $x_1 x_2 = c slash a$.

  *Variance.* $EE[X^2] - (EE[X])^2$ cancels when the mean is large relative to
  the spread. Fix (Chapter 28): Welford's algorithm.

  *$log(1+x)$ for tiny $x$.* Computing `1.0 + x` rounds away $x$'s low bits.
  Fix: `log1p(x)`, which evaluates the series directly. Likewise `expm1`.

  *$sqrt(x+1) - sqrt(x)$ for large $x$.* Two nearly equal numbers. Fix:
  multiply by the conjugate,
  $ sqrt(x+1) - sqrt(x) = 1/(sqrt(x+1) + sqrt(x)), $
  which has no subtraction at all. Algebraically identical, numerically
  entirely different.
]

#algo(title: "Kahan compensated summation")[
```
sum := 0.0
c   := 0.0            # running compensation for lost low-order bits
for each x:
    y := x - c        # add back what was lost last time
    t := sum + y      # this rounds, losing the low bits of y
    c := (t - sum) - y  # recover exactly what was lost
    sum := t
```
]

Naive summation of $n$ terms has error growing like $n epsilon$; Kahan's is
bounded by about $2 epsilon$ regardless of $n$. The trick is that
`(t - sum) - y` computes the rounding error of the previous addition exactly
--- an identity that holds because floating-point subtraction of nearby
numbers is exact.

== Condition numbers

#definition(title: "condition number of a function")[
  $ kappa_f (x) = abs((x f'(x))/(f(x))). $
  The factor by which relative input error is amplified into relative output
  error.
]

#example[
  $f(x) = sqrt(x)$: $kappa = 1 slash 2$. Well conditioned everywhere ---
  square roots are safe.

  $f(x) = x_1 - x_2$ for $x_1 approx x_2$: the condition number blows up as
  the arguments approach each other. This is cancellation, quantified.

  $f(x) = tan(x)$ near $pi slash 2$: enormous. A tiny error in $x$ produces an
  arbitrary output.

  Root-finding for a polynomial with nearly-repeated roots: enormous, which is
  Wilkinson's polynomial and the reason Chapter 23 warned against the
  characteristic-polynomial route to eigenvalues.
]

For linear systems the condition number is $kappa(A) = sigma_1 slash sigma_n$
(Chapter 25), and the rule of thumb is: with $kappa approx 10^k$, expect to
lose $k$ decimal digits. Always check it before trusting a solve. `numpy`
exposes it as `np.linalg.cond`.

== Root finding

#align(center)[
  #table(
    columns: 4,
    inset: 7pt,
    align: (left, center, center, left),
    stroke: 0.4pt + luma(180),
    table.header([*Method*], [*Order*], [*Needs*], [*Notes*]),
    [Bisection], [linear], [sign change], [Always converges. One bit per step.],
    [Secant], [$approx 1.618$], [two points], [No derivative needed. Golden ratio order --- genuinely.],
    [Newton], [quadratic], [$f'$], [Fastest, can diverge (Chapter 15).],
    [Brent], [superlinear], [sign change], [Hybrid. Guaranteed *and* fast. The default.],
  )
]

#intuition(title: "why Brent's method is the right answer")[
  Bisection is guaranteed and slow. Newton is fast and can fail. Brent's
  method keeps a bracket at all times --- so it can never diverge --- but
  attempts an inverse quadratic interpolation step at each iteration and takes
  it only if it lands inside the bracket and is making adequate progress,
  falling back to bisection otherwise.

  Guaranteed convergence with near-Newton speed. This *hybridise a safe method
  with a fast one* pattern recurs throughout numerical computing: trust-region
  optimisation, adaptive quadrature, and line searches all do it.

  Use your library's `brentq`. Do not hand-roll a Newton iteration for
  production root-finding.
]

== Numerical differentiation and integration

Chapter 14 established the trade-off for differentiation: truncation error
falls with $h$, roundoff error rises, and the optimum is
$h approx sqrt(epsilon)$ for forward differences (about 8 good digits) or
$epsilon^(1 slash 3)$ for central differences (about 10). Automatic
differentiation avoids the trade-off entirely and is what you should use when
you control the code.

For integration, Chapter 16 gave midpoint, trapezoid, and Simpson. Two things
to add.

#definition(title: "Gaussian quadrature")[
  Approximate $integral_(-1)^1 f(x) dif x approx sum_(i=1)^n w_i f(x_i)$,
  choosing *both* the nodes $x_i$ and the weights $w_i$ optimally. With $n$
  nodes this is exact for all polynomials of degree up to $2n - 1$.
]

#intuition(title: "why choosing the nodes doubles the accuracy")[
  Newton--Cotes rules (trapezoid, Simpson) fix the nodes at equal spacing and
  choose only the $n$ weights: $n$ free parameters, so exactness for degree
  $n-1$.

  Gauss chooses the nodes too: $2n$ free parameters, so exactness for degree
  $2n-1$. The optimal nodes turn out to be the roots of the Legendre
  polynomials, and they cluster towards the endpoints.

  A 5-point Gauss rule is exact for degree-9 polynomials. Simpson with 5
  points is exact for degree 3. The gap is enormous and it comes from nothing
  more than not insisting on an even grid.

  The catch: Gauss nodes are fixed by $n$, so refining means recomputing
  everything. Gauss--Kronrod extends a Gauss rule with extra points so the two
  estimates share evaluations and their difference gives an error estimate.
  That is what `scipy.integrate.quad` does, inside an adaptive subdivision
  loop.
]

Also worth knowing: for high-dimensional integrals nothing grid-based works
(the curse of dimensionality), and Monte Carlo's dimension-independent
$O(1 slash sqrt(n))$ rate wins --- Chapter 27.

== Ordinary differential equations

#definition(title: "initial value problem")[
  Find $y(t)$ with $y' = f(t,y)$, $y(t_0) = y_0$.
]

#align(center)[
  #table(
    columns: 3,
    inset: 7pt,
    align: (left, left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Method*], [*Step*], [*Error per step / global*]),
    [Forward Euler], [$y_(n+1) = y_n + h f(t_n, y_n)$], [$O(h^2)$ / $O(h)$],
    [Backward Euler], [$y_(n+1) = y_n + h f(t_(n+1), y_(n+1))$], [$O(h^2)$ / $O(h)$, implicit],
    [Midpoint (RK2)], [evaluate at the half-step], [$O(h^3)$ / $O(h^2)$],
    [RK4], [four evaluations, weighted], [$O(h^5)$ / $O(h^4)$],
  )
]

#algo(title: "Classical fourth-order Runge--Kutta")[
```
k1 := f(t, y)
k2 := f(t + h/2, y + h*k1/2)
k3 := f(t + h/2, y + h*k2/2)
k4 := f(t + h,   y + h*k3)
y  := y + h*(k1 + 2*k2 + 2*k3 + k4)/6
```
]

RK4 is four function evaluations per step for fourth-order accuracy, which is
an unusually good deal, and it is the default for non-stiff problems.

#intuition(title: "stiffness, and why implicit methods exist")[
  A system is *stiff* when it contains processes on wildly different
  timescales --- a fast transient that decays almost immediately alongside slow
  dynamics you actually care about.

  Explicit methods are *stability-limited*: forward Euler on $y' = -lambda y$
  requires $h < 2 slash lambda$ or the numerical solution oscillates and blows
  up, even though the true solution decays smoothly. With $lambda = 10^6$ from
  some irrelevant fast mode, you are forced to take a million steps to
  integrate one second of interesting behaviour.

  Implicit methods have no such limit. Backward Euler on $y' = -lambda y$
  gives $y_(n+1) = y_n slash (1 + h lambda)$, which decays for *every* $h > 0$:
  unconditionally stable. The price is that each step requires solving an
  equation for $y_(n+1)$ --- typically Newton's method with a Jacobian, so
  each step is far more expensive. For stiff problems it is still a massive
  win.

  Diagnosing stiffness: if your explicit solver is taking absurdly small steps
  and the solution looks smooth, you are stiff. Switch to an implicit solver
  (BDF, Radau) and the problem usually evaporates.
]

For *stiff* problems, and for anything you actually care about, use a library:
adaptive step size control (estimate the local error, shrink or grow $h$ to
hit a tolerance) is what makes solvers usable, and it is fiddly to implement
correctly.

== Practical advice

+ *Use the library.* LAPACK, BLAS, SciPy, and Eigen encode decades of hard-won
  numerical judgement. Your hand-rolled version will be slower and less
  accurate.

+ *Check the condition number* before trusting any linear solve or fit.

+ *Prefer orthogonal transformations.* QR over normal equations, SVD over
  eigendecomposition of $A^T A$, Householder over Gram--Schmidt.

+ *Scale your variables.* If one feature is in nanoseconds and another in
  terabytes, your matrix is ill-conditioned for a purely cosmetic reason.
  Normalising features is not just an ML convention; it is conditioning.

+ *Work in log space* for products of probabilities (Chapter 4), and use
  `logsumexp` rather than `log(sum(exp(...)))`.

+ *Test against a slow reference.* Compare your fast method to a naive
  high-precision implementation on small inputs. Most numerical bugs are
  visible at $n = 3$.

+ *Do not use `float32` because it is faster, without checking.* It has
  $epsilon approx 10^(-7)$ --- about 7 decimal digits --- which is fine for
  neural network weights and disastrous for accumulating a long sum or
  inverting an ill-conditioned matrix. Mixed precision (compute in `float32`,
  accumulate in `float32` or higher) exists for exactly this reason.

== Exercises

#exercise[
  Compute $sqrt(10001) - sqrt(10000)$ (a) directly and (b) using the conjugate
  rearrangement, to 4 significant figures at each intermediate step. Compare
  with the true value $0.0049999$.
]

#exercise[
  Explain why `0.1 + 0.2 != 0.3` in binary floating point, referring to the
  repeating-expansion result of Chapter 1. What is the actual value of
  `0.1 + 0.2` to 20 digits?
]

#exercise[
  Estimate the condition number of $f(x) = 1 slash (1 - x)$ at $x = 0.999$,
  and state how many digits you would expect to lose.
]

#exercise[
  Implement (on paper) three iterations of Kahan summation on the values
  $1.0$, $10^(-16)$, $10^(-16)$ in a system with $epsilon = 2^(-52)$, and
  compare with naive summation.
]

#exercise[
  Apply two steps of RK4 to $y' = y$, $y(0) = 1$, with $h = 0.5$. Compare with
  the exact answer $e$ and with two steps of forward Euler.
]

#exercise[
  For the stiff equation $y' = -1000 y$, find the largest step size for which
  forward Euler is stable, and verify that backward Euler is stable for every
  positive step size.
]

#exercise[
  A $3 times 3$ linear system has condition number $10^7$ and your inputs are
  accurate to 10 significant digits. How many digits of the solution can you
  trust? What if you switched to `float32` inputs?
]

#exercise[
  You need $integral_0^1 x^7 dif x$. How many Gauss--Legendre nodes are needed
  for an *exact* answer, and how many Simpson subintervals would give
  comparable accuracy? Explain the gap.
]
