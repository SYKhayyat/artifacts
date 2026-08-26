#import "../lib.typ": *

= Sequences, Series, and Taylor Expansion

== Why infinite sums

Every non-trivial function your computer evaluates --- $sin$, $exp$, $ln$,
$sqrt(dot)$ --- is computed as a finite chunk of an infinite sum. There is no
other way; a CPU has addition and multiplication and nothing else.

So this chapter is not abstraction for its own sake. It is the theory of how a
transcendental function becomes a polynomial you can actually evaluate, and of
how much error you incur when you stop.

== Sequences

#definition(title: "convergence of a sequence")[
  $(a_n)$ *converges* to $L$, written $lim_(n->infinity) a_n = L$, if for
  every $epsilon > 0$ there is $N$ such that $n >= N$ implies
  $abs(a_n - L) < epsilon$. Otherwise it *diverges*.
]

Same negotiation as Chapter 13, with "close to $a$" replaced by "far enough
along". The tools transfer directly: limit laws, squeeze theorem, and the two
theorems that do the real work:

- *Monotone convergence* (Chapter 13): bounded and monotone implies
  convergent.
- *Bolzano--Weierstrass*: bounded implies a convergent subsequence.

#example(title: "the sequences to know")[
  $
  lim n^(1 slash n) &= 1, quad lim (1 + x/n)^n = e^x, \
  lim r^n &= cases(0 &abs(r) < 1, 1 &r = 1, "diverges" &"otherwise"), \
  lim (n^k)/(b^n) &= 0 quad (b>1), quad lim (ln n)/n^epsilon = 0.
  $
  The last two are Chapter 15's L'Hôpital computations, restated for
  sequences.
]

== Series

#definition(title: "series and partial sums")[
  Given $(a_n)$, the *series* $sum_(n=1)^infinity a_n$ is defined as the limit
  of its *partial sums*
  $ s_N = sum_(n=1)^N a_n. $
  If $(s_N)$ converges to $S$, the series converges to $S$; otherwise it
  diverges.
]

#warning(title: "a series is not a sum")[
  An infinite series is *defined* as a limit. It is not "addition, done
  forever" --- that phrase means nothing. Everything surprising about series
  comes from forgetting this.

  In particular, the familiar laws of addition do not automatically apply.
  Commutativity fails: a *conditionally* convergent series can be rearranged
  to converge to any value you like (the Riemann rearrangement theorem, below).
  Associativity fails for divergent series: grouping
  $1 - 1 + 1 - 1 + dots.c$ as $(1-1)+(1-1)+dots.c$ gives $0$ and as
  $1 - (1-1) - (1-1) - dots.c$ gives $1$, which proves only that the series
  diverges.
]

#theorem(title: "divergence test")[
  If $sum a_n$ converges then $a_n -> 0$. Contrapositively: if
  $a_n arrow.r.not 0$, the series diverges.
]

#proof[
  $a_n = s_n - s_(n-1)$, and both partial sums tend to the same $S$, so the
  difference tends to $0$.
]

#warning(title: "the converse is false and this is the classic error")[
  $a_n -> 0$ does *not* imply convergence. The harmonic series
  $sum 1 slash n$ has terms tending to zero and diverges.

  The divergence test can only ever prove divergence. It never proves
  convergence.
]

=== The two series you must know

#theorem(title: "geometric series")[
  For $abs(r) < 1$, $ sum_(n=0)^infinity r^n = 1/(1-r). $ For
  $abs(r) >= 1$ it diverges.
]

#proof[
  From Chapter 2, $s_N = (1 - r^N) slash (1 - r)$. If $abs(r)<1$ then
  $r^N -> 0$, so $s_N -> 1 slash (1-r)$. If $abs(r) >= 1$ then $r^N$ does not
  tend to $0$, so the terms fail the divergence test.
]

#theorem(title: "the harmonic series diverges")[
  $ sum_(n=1)^infinity 1/n = infinity. $
]

#proof[
  Group the terms in blocks of doubling length:
  $
  1 + underbrace(1/2, >= 1 slash 2) + underbrace(1/3 + 1/4, >= 2 dot 1 slash 4 = 1 slash 2) + underbrace(1/5 + dots.c + 1/8, >= 4 dot 1 slash 8 = 1 slash 2) + dots.c
  $
  Each block sums to at least $1 slash 2$, and there are infinitely many
  blocks, so the partial sums exceed any bound.
]

#intuition(title: "the harmonic series shows up in your code")[
  $H_n = sum_(k=1)^n 1 slash k approx ln n + gamma$, where
  $gamma approx 0.5772$ is the Euler--Mascheroni constant. The approximation
  comes from comparing the sum to $integral_1^n (dif x) slash x$.

  This appears constantly in algorithm analysis:

  - The expected number of comparisons in randomised quicksort is
    $approx 2 n ln n$, and the $ln$ comes from a harmonic sum over pivot
    positions.
  - The *coupon collector* problem --- how many random draws to see all $n$
    coupons --- has expectation $n H_n approx n ln n$.
  - The expected depth of a random binary search tree is $approx 2 ln n$.

  Every one of those is the harmonic series in disguise, and its slow
  logarithmic divergence is why these bounds are $n log n$ and not $n$ or
  $n^2$.
]

== Convergence tests

#theorem(title: "p-series")[
  $sum_(n=1)^infinity 1 slash n^p$ converges if and only if $p > 1$.
]

#proof[
  Compare with $integral_1^infinity x^(-p) dif x$ from Chapter 16. Precisely:
  since $1 slash x^p$ is decreasing,
  $ integral_1^(N+1) (dif x)/x^p <= sum_(n=1)^N 1/n^p <= 1 + integral_1^N (dif x)/x^p, $
  by comparing each term to the area of a unit-width rectangle. Both bounds
  are finite iff the integral converges, which by Chapter 16 happens iff
  $p>1$.
]

That argument is the *integral test* in general: for positive decreasing $f$,
$sum f(n)$ and $integral_1^infinity f$ converge together.

#theorem(title: "comparison tests")[
  Suppose $0 <= a_n <= b_n$ for all large $n$.
  - If $sum b_n$ converges, so does $sum a_n$.
  - If $sum a_n$ diverges, so does $sum b_n$.

  *Limit comparison:* if $a_n, b_n > 0$ and $lim a_n slash b_n = c$ with
  $0 < c < infinity$, then the two series converge or diverge together.
]

#theorem(title: "ratio test")[
  Let $L = lim_(n->infinity) abs(a_(n+1) slash a_n)$. If $L < 1$ the series
  converges absolutely; if $L > 1$ it diverges; if $L = 1$ the test says
  nothing.
]

#proof[
  Suppose $L < 1$; pick $r$ with $L < r < 1$. For large $n$,
  $abs(a_(n+1)) <= r abs(a_n)$, so from some index $N$ onwards
  $abs(a_(N+k)) <= r^k abs(a_N)$. The tail is dominated by a convergent
  geometric series, so it converges by comparison.

  If $L > 1$, terms eventually grow, so $a_n arrow.r.not 0$ and the divergence
  test applies.
]

The ratio test is the workhorse for anything containing factorials or
exponentials, because those simplify beautifully in a ratio. It fails
(returning $L=1$) exactly on $p$-series, where you need the integral test
instead.

#definition(title: "absolute versus conditional convergence")[
  $sum a_n$ converges *absolutely* if $sum abs(a_n)$ converges, and
  *conditionally* if it converges but $sum abs(a_n)$ does not.
]

#theorem(title: "absolute convergence implies convergence")[
  If $sum abs(a_n)$ converges then $sum a_n$ converges.
]

#theorem(title: "alternating series test")[
  If $b_n > 0$, $b_n$ is decreasing, and $b_n -> 0$, then
  $sum (-1)^n b_n$ converges. Moreover the error from truncating after $N$
  terms is at most $b_(N+1)$ --- the first omitted term.
]

The alternating harmonic series $sum (-1)^(n+1) slash n = ln 2$ is
conditionally convergent: it converges, but the absolute series diverges.

#warning(title: "conditional convergence is genuinely unstable")[
  *Riemann rearrangement theorem:* the terms of a conditionally convergent
  series can be permuted to sum to *any* real number, or to $plus.minus infinity$.

  The mechanism: the positive terms alone diverge to $+infinity$ and the
  negative terms alone to $-infinity$. So to hit a target $T$, take positive
  terms until you overshoot, then negative terms until you undershoot, and
  repeat. Since the terms tend to zero, the oscillation shrinks and you
  converge to $T$.

  This is not a curiosity. It means the *order of summation matters* for a
  conditionally convergent series --- so any parallel or reordered summation
  of such a series is meaningless. Absolute convergence is exactly the
  condition under which reordering is safe. This is the mathematical statement
  underneath "do not reduce a numerically delicate sum in arbitrary order".
]

== Power series

#definition(title: "power series")[
  $ sum_(n=0)^infinity c_n (x - a)^n. $
  There is a *radius of convergence* $R in [0, infinity]$ such that the series
  converges absolutely for $abs(x - a) < R$ and diverges for
  $abs(x-a) > R$. Behaviour at $abs(x-a) = R$ must be checked separately.
]

$R$ is usually found by the ratio test. Within the radius, a power series can
be differentiated and integrated term by term, and the result has the same
radius --- which is what makes them so pleasant to work with.

== Taylor series

Here is the payoff.

#definition(title: "Taylor series")[
  If $f$ is infinitely differentiable at $a$, its *Taylor series* about $a$ is
  $ sum_(n=0)^infinity (f^((n))(a))/(n!) (x-a)^n. $
  With $a = 0$ it is also called the *Maclaurin series*.
]

#intuition(title: "where the coefficients come from")[
  Suppose $f(x) = c_0 + c_1 x + c_2 x^2 + c_3 x^3 + dots.c$ and ask what the
  $c_n$ must be.

  Set $x=0$: everything but $c_0$ vanishes, so $c_0 = f(0)$.

  Differentiate once, then set $x=0$: $f'(0) = c_1$.

  Differentiate twice: the $x^2$ term becomes $2 c_2$, so $c_2 = f''(0) slash 2$.

  Differentiate $n$ times: the $x^n$ term becomes $n! c_n$ and everything else
  is either gone or still has an $x$. Hence $c_n = f^((n))(0) slash n!$.

  So the Taylor coefficients are *forced*. The $n!$ is not decoration --- it
  is exactly the factor that differentiating $x^n$ down to a constant
  produces. The polynomial is the unique one matching $f$'s value, slope,
  curvature, and every higher derivative at the point.
]

#theorem(title: "Taylor's theorem with Lagrange remainder")[
  If $f$ is $(n+1)$-times differentiable on an interval containing $a$ and
  $x$, then
  $ f(x) = underbrace(sum_(k=0)^n (f^((k))(a))/(k!)(x-a)^k, P_n (x)) + R_n (x), $
  where for some $xi$ between $a$ and $x$,
  $ R_n (x) = (f^((n+1))(xi))/((n+1)!) (x-a)^(n+1). $
]

#proof[
  Sketch. Fix $x$ and define $g(t) = f(x) - P_n^([t])(x) - M (x-t)^(n+1)$,
  where $P_n^([t])$ is the Taylor polynomial expanded about $t$ and $M$ is
  chosen so that $g(a) = 0$. Note $g(x) = 0$ as well. By Rolle's theorem
  (Chapter 15) there is $xi$ between with $g'(xi) = 0$. Differentiating,
  almost everything telescopes and one is left with
  $ 0 = -(f^((n+1))(xi))/(n!)(x-xi)^n + M(n+1)(x-xi)^n, $
  giving $M = f^((n+1))(xi) slash (n+1)!$. Substituting $M$ into $g(a)=0$
  yields the stated formula.
]

#intuition(title: "the remainder is the whole point")[
  The Taylor *polynomial* is what you compute. The *remainder* is what tells
  you whether the answer is any good.

  Read the remainder formula: the error is controlled by (a) the size of the
  next derivative and (b) $(x-a)^(n+1) slash (n+1)!$. The second factor
  collapses very fast --- factorial in the denominator beats everything --- so
  as long as the derivatives do not blow up, adding terms helps enormously and
  staying near $a$ helps enormously.

  This is why `sin(x)` in a standard library first reduces $x$ modulo
  $2 pi$ into a small range: the error term is $x^(n+1) slash (n+1)!$, so
  keeping $abs(x)$ small is worth many terms of the series.
]

=== The standard expansions

$
e^x &= sum_(n=0)^infinity (x^n)/(n!) = 1 + x + (x^2)/2 + (x^3)/6 + dots.c &quad& (R = infinity) \
sin x &= sum_(n=0)^infinity ((-1)^n x^(2n+1))/((2n+1)!) = x - (x^3)/6 + (x^5)/120 - dots.c &quad& (R = infinity) \
cos x &= sum_(n=0)^infinity ((-1)^n x^(2n))/((2n)!) = 1 - (x^2)/2 + (x^4)/24 - dots.c &quad& (R = infinity) \
1/(1-x) &= sum_(n=0)^infinity x^n &quad& (R = 1) \
ln(1+x) &= sum_(n=1)^infinity ((-1)^(n+1) x^n)/n = x - (x^2)/2 + (x^3)/3 - dots.c &quad& (R=1) \
(1+x)^alpha &= sum_(n=0)^infinity binom(alpha, n) x^n &quad& (R = 1)
$

The last is the *binomial series*, valid for any real $alpha$ with
$binom(alpha,n) = alpha(alpha-1)dots.c(alpha-n+1) slash n!$. For a
nonnegative integer $alpha$ it terminates and reduces to Chapter 9's binomial
theorem.

#example(title: "proving Euler's formula")[
  Chapter 6 promised this. Substitute $x = i theta$ into the exponential
  series and split by parity, using $i^2 = -1$:
  $
  e^(i theta) &= sum_(n=0)^infinity ((i theta)^n)/(n!) \
  &= underbrace(1 - (theta^2)/2! + (theta^4)/4! - dots.c, cos theta) + i underbrace((theta - (theta^3)/3! + (theta^5)/5! - dots.c), sin theta) \
  &= cos theta + i sin theta.
  $
  The even powers of $i$ are real and alternate in sign; the odd powers are
  imaginary and alternate. Splitting the single exponential series by parity
  produces exactly the cosine and sine series.

  The rearrangement is legitimate because the series converges absolutely
  everywhere --- which is precisely where the Riemann rearrangement warning
  above bites, and precisely why absolute convergence was worth defining.
]

#warning(title: "a Taylor series can converge to the wrong function")[
  Let
  $ f(x) = cases(e^(-1 slash x^2) quad &x != 0, 0 &x = 0). $
  Every derivative of $f$ at $0$ is zero (the exponential decays faster than
  any polynomial grows). So its Taylor series about $0$ is
  $0 + 0x + 0x^2 + dots.c = 0$, which converges everywhere --- to the zero
  function, which is not $f$.

  A function whose Taylor series converges to it on a neighbourhood is called
  *analytic*. Infinitely differentiable is strictly weaker than analytic, and
  this is the standard example. Over the *complex* numbers the distinction
  vanishes: complex differentiability once implies analyticity, which is one
  of the reasons complex analysis is a nicer subject than real analysis.
]

== Series in practice

*Function evaluation.* $exp(x)$ in a library: reduce $x = k ln 2 + r$ with
$abs(r)$ small, compute $e^r$ by a short polynomial (often a minimax
polynomial, not literally Taylor --- Taylor is optimal *at a point*, and you
want uniform accuracy over an interval), then multiply by $2^k$ by adjusting
the exponent field directly.

*Small-angle approximations.* $sin x approx x$, $cos x approx 1 - x^2 slash 2$,
$e^x approx 1 + x$, $ln(1+x) approx x$, $(1+x)^alpha approx 1 + alpha x$.
These are first- or second-order truncations, and physics and graphics run on
them.

*Numerical stability.* $ln(1+x)$ for tiny $x$: computing `1.0 + x` first
rounds away $x$'s low bits, then the log of something near 1 loses more.
That is why `log1p(x)` exists --- it evaluates the series
$x - x^2 slash 2 + dots.c$ directly. Likewise `expm1(x)` for $e^x - 1$.

*Generating functions.* Encode a sequence $(a_n)$ as the coefficients of a
power series $A(x) = sum a_n x^n$. Then recurrences on the sequence become
*algebraic equations* on $A$. For Fibonacci one gets
$A(x) = x slash (1 - x - x^2)$, and partial fractions (Chapter 2) plus the
geometric series recover Binet's formula from Chapter 11. It is a whole
technique, and this is the bridge to it.

== Exercises

#exercise[
  Determine convergence or divergence, naming the test used:
  (a) $sum n slash (n^2+1)$; (b) $sum 1 slash (n^2 + 1)$;
  (c) $sum n! slash n^n$; (d) $sum (-1)^n slash sqrt(n)$;
  (e) $sum (2^n) slash (n!)$.
]

#exercise[
  Find the sum of $sum_(n=0)^infinity 3 slash 4^n$ and of
  $sum_(n=2)^infinity (2 slash 3)^n$.
]

#exercise[
  Find the radius and interval of convergence of
  $sum_(n=1)^infinity (x-2)^n slash (n 3^n)$, checking both endpoints.
]

#exercise[
  Compute the Maclaurin series of $f(x) = 1 slash (1+x^2)$ two ways: by
  substituting into the geometric series, and by differentiating repeatedly.
  Then integrate it term by term to derive the series for $arctan x$, and
  set $x=1$ to obtain a (very slowly converging) series for $pi slash 4$.
]

#exercise[
  Use Taylor's theorem to bound the error in approximating $e^(0.5)$ by the
  first four terms of the exponential series. Compare with the true error.
]

#exercise[
  Use the series for $sin$ to evaluate $lim_(x->0)(sin x - x) slash x^3$
  without L'Hôpital.
]

#exercise[
  Show that the series $sum (-1)^(n+1) slash n$ converges, and estimate how
  many terms are needed to compute $ln 2$ to within $10^(-3)$. Then explain
  why nobody computes $ln 2$ this way.
]

#exercise[
  Prove that $sum 1 slash (n (ln n)^p)$ converges iff $p > 1$, using the
  integral test with the substitution $u = ln x$.
]
