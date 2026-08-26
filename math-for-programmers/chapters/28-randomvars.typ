#import "../lib.typ": *

= Random Variables and Distributions

== From events to numbers

Chapter 27 assigned probabilities to sets. That is the right foundation and a
clumsy way to work: you usually care about a *number* attached to an outcome
--- the sum of the dice, the latency of the request, the loss of the model.

#definition(title: "random variable")[
  A *random variable* is a function $X : Omega -> RR$.
]

#warning(title: "it is neither random nor a variable")[
  A random variable is a *deterministic function*. The randomness lives in
  which $omega in Omega$ occurs; $X$ just reports a number about it.

  Programmer's reading: $omega$ is the seed, and $X$ is a pure function of it.
  Two random variables on the same $Omega$ are two pure functions of the same
  seed --- which is exactly why they can be dependent. This picture makes
  dependence obvious and it is worth keeping.

  Notation: $PP(X <= 3)$ is shorthand for
  $PP({omega in Omega : X(omega) <= 3})$. The set is suppressed, which is
  convenient and occasionally confusing.
]

#definition(title: "discrete and continuous")[
  $X$ is *discrete* if it takes countably many values. Its *probability mass
  function* is $p(x) = PP(X = x)$, with $p(x) >= 0$ and $sum_x p(x) = 1$.

  $X$ is *continuous* if there is a *probability density function* $f$ with
  $ PP(a <= X <= b) = integral_a^b f(x) dif x, $
  where $f(x) >= 0$ and $integral_(-infinity)^infinity f = 1$.
]

#warning(title: "a density is not a probability")[
  For continuous $X$, $PP(X = c) = 0$ for *every* single value $c$ --- the
  integral over a point is zero. That does not mean the value is impossible;
  it means single values have no probability mass.

  So $f(x)$ is not $PP(X = x)$. It is probability *per unit length*, and it
  can exceed 1: a uniform distribution on $[0, 0.1]$ has density $10$
  everywhere on that interval. Only $integral f$ over a set is a probability.

  Consequence: for continuous variables, $PP(X <= a)$ and $PP(X < a)$ are
  equal, and endpoint conventions never matter. For discrete ones they do.
]

#definition(title: "cumulative distribution function")[
  $ F(x) = PP(X <= x). $
  $F$ is non-decreasing, right-continuous, with $F(-infinity) = 0$ and
  $F(infinity) = 1$. For continuous $X$, $F' = f$ by the Fundamental Theorem
  of Calculus.
]

The CDF exists for every random variable, discrete or continuous, which makes
it the right object for general statements. It is also what you invert for
inverse-transform sampling (Chapter 27) and what you compare in a
Kolmogorov--Smirnov test.

== Expectation

#definition(title: "expectation")[
  $ EE[X] = cases(
    sum_x x thin p(x) quad &"discrete",
    integral_(-infinity)^infinity x f(x) dif x quad &"continuous"
  ) $
  when the sum or integral converges absolutely.
]

#intuition(title: "expectation is a weighted average, and also a centre of mass")[
  Each value, weighted by how likely it is. If you ran the experiment
  infinitely often and averaged, you would get $EE[X]$ --- that is the law of
  large numbers (Chapter 30), and it is a theorem, not the definition.

  The mechanical picture is useful: put a point mass $p(x)$ at position $x$ on
  a rod. $EE[X]$ is where the rod balances. It follows immediately that the
  expectation need not be an attainable value --- the expected number of pips
  on a die is $3.5$ --- and that it is dragged hard by distant mass, which is
  why the mean is not robust to outliers.
]

#theorem(title: "linearity of expectation")[
  For *any* random variables $X, Y$ on the same space and constants $a, b$,
  $ EE[a X + b Y] = a EE[X] + b EE[Y]. $
  No independence is required.
]

#proof[
  In the discrete case, summing over the underlying outcomes:
  $ EE[a X + b Y] = sum_omega (a X(omega) + b Y(omega)) PP(omega) = a sum_omega X(omega)PP(omega) + b sum_omega Y(omega) PP(omega). $
  The continuous case is the same computation with an integral, and linearity
  of the integral (Chapter 16) doing the work.
]

#intuition(title: "linearity without independence is the most useful fact in probability")[
  This is the workhorse. It lets you compute expectations of horribly
  dependent things by chopping them into simple pieces.

  The standard technique is *indicator variables*: let $I_A = 1$ if event $A$
  happens and $0$ otherwise. Then $EE[I_A] = PP(A)$, and any count is a sum of
  indicators.

  *Example.* Expected number of fixed points of a random permutation of $n$
  items. Let $I_i$ indicate that item $i$ stays put. The $I_i$ are strongly
  dependent --- but linearity does not care:
  $ EE[sum_i I_i] = sum_i PP(I_i = 1) = n dot 1/n = 1. $
  Exactly one, for every $n$. Compare Chapter 9's derangement count, which
  needed inclusion--exclusion; the *expected* value needs one line.

  *Example.* Coupon collector: to collect all $n$ coupons, the time to get the
  $k$-th new one after having $k-1$ is geometric with success probability
  $(n-k+1) slash n$, hence expectation $n slash (n-k+1)$. Summing,
  $ EE[T] = sum_(k=1)^n n/(n-k+1) = n H_n approx n ln n, $
  the harmonic sum of Chapter 17.
]

#theorem(title: "law of the unconscious statistician")[
  For any function $g$,
  $ EE[g(X)] = sum_x g(x) p(x) quad "or" quad integral g(x) f(x) dif x. $
]

The name is a joke about people using it without noticing it needs proof.
Note what it says: you do *not* need the distribution of $g(X)$ to compute its
expectation. And note what it does *not* say: in general
$EE[g(X)] != g(EE[X])$.

#theorem(title: "Jensen's inequality")[
  If $g$ is convex, $EE[g(X)] >= g(EE[X])$. If concave, the inequality
  reverses.
]

#intuition(title: "Jensen, and why averages of ratios lie")[
  A convex function bends upwards, so averaging inputs and then applying it
  undershoots; applying it and then averaging catches the curvature.

  Consequences worth having:

  - $EE[X^2] >= (EE[X])^2$ --- which rearranges to $Var(X) >= 0$, so variance
    being nonnegative *is* Jensen.
  - $EE[1 slash X] >= 1 slash EE[X]$ for positive $X$. So the average of
    speeds is not the speed of the average, and average latency does not give
    you average throughput.
  - $EE[log X] <= log EE[X]$, which is why the log-likelihood bound in
    variational inference (the ELBO) goes the way it does.
  - The AM--GM inequality of Chapter 2 is Jensen applied to $log$.
]

== Variance

#definition(title: "variance and standard deviation")[
  $ Var(X) = EE[(X - mu)^2], quad mu = EE[X], quad sigma = sqrt(Var(X)). $
]

#proposition(title: "computational formula")[
  $ Var(X) = EE[X^2] - (EE[X])^2. $
]

#proof[
  Expand and use linearity:
  $ EE[(X-mu)^2] = EE[X^2 - 2 mu X + mu^2] = EE[X^2] - 2mu EE[X] + mu^2 = EE[X^2] - mu^2. $
]

#warning(title: "that formula is numerically dangerous")[
  $EE[X^2] - (EE[X])^2$ is a difference of two nearly equal large numbers when
  the mean is large relative to the spread --- catastrophic cancellation
  (Chapter 1). Computing the variance of values near $10^9$ with a spread of
  $1$ can return a negative number.

  Use *Welford's algorithm*, which maintains the mean and the sum of squared
  deviations incrementally and never subtracts large quantities:
  #algo[
  ```
  n := 0; mean := 0; M2 := 0
  for each x:
      n     := n + 1
      d     := x - mean
      mean  := mean + d / n
      M2    := M2 + d * (x - mean)     # note: new mean
  variance := M2 / (n - 1)
  ```
  ]
  Same answer in exact arithmetic, vastly better in floating point. This is
  the standard example of an algebraically valid rearrangement being
  numerically unacceptable.
]

#proposition(title: "properties")[
  $Var(a X + b) = a^2 Var(X)$, and if $X, Y$ are *independent*,
  $Var(X + Y) = Var(X) + Var(Y)$.
]

Note the asymmetry with expectation: linearity of expectation needs nothing;
additivity of variance needs independence. Shifting does not change spread;
scaling changes it quadratically, which is why standard deviation (in the same
units as $X$) is often the more interpretable quantity.

== The distributions worth knowing

=== Discrete

#definition(title: "Bernoulli")[
  $X in {0,1\}$ with $PP(X=1) = p$. $EE[X] = p$, $Var(X) = p(1-p)$.
]

The variance is maximised at $p = 1 slash 2$ --- maximum uncertainty --- and
zero at $p = 0$ or $1$. A single yes/no trial. Every classification label is
one of these.

#definition(title: "binomial")[
  $X tilde Bin(n,p)$ counts successes in $n$ independent Bernoulli trials.
  $ PP(X = k) = binom(n,k) p^k (1-p)^(n-k), quad EE[X] = n p, quad Var(X) = n p (1-p). $
]

#proof[
  The pmf: choose which $k$ trials succeed ($binom(n,k)$ ways, Chapter 9),
  each such pattern having probability $p^k (1-p)^(n-k)$ by independence.

  The mean and variance: $X = sum_i X_i$ with each $X_i$ Bernoulli. Linearity
  gives $EE[X] = n p$; independence gives $Var(X) = n p(1-p)$.
]

#definition(title: "geometric")[
  $X$ counts trials until the first success. $PP(X = k) = (1-p)^(k-1) p$,
  $EE[X] = 1 slash p$, $Var(X) = (1-p) slash p^2$.
]

The geometric distribution is *memoryless*: $PP(X > s + t | X > s) = PP(X > t)$.
Having waited does not bring success closer. It is the only discrete
distribution with that property, and it is why "this hash probe has failed
five times, surely the next will work" is wrong.

#definition(title: "Poisson")[
  $X tilde Pois(lambda)$ counts events in a fixed interval when they occur
  independently at constant average rate $lambda$:
  $ PP(X = k) = (lambda^k e^(-lambda))/(k!), quad EE[X] = Var(X) = lambda. $
]

#proof[
  As a limit of the binomial. Take $n$ trials with $p = lambda slash n$ and
  let $n -> infinity$:
  $
  binom(n,k) (lambda/n)^k (1 - lambda/n)^(n-k)
  = underbrace((n(n-1)dots.c(n-k+1))/(n^k), -> 1) dot (lambda^k)/(k!) dot underbrace((1-lambda/n)^n, -> e^(-lambda)) dot underbrace((1-lambda/n)^(-k), -> 1),
  $
  using $lim (1 + x slash n)^n = e^x$ from Chapter 17.
]

That derivation says what Poisson *is*: many opportunities, each unlikely,
constant rate. Requests arriving at a server, packets dropped, mutations,
typos per page, cosmic-ray bit flips. The variance equalling the mean is a
strong signature --- real count data with variance much larger than its mean
is *overdispersed*, and Poisson is the wrong model for it.

=== Continuous

#definition(title: "uniform")[
  $X tilde Unif(a,b)$ with $f(x) = 1 slash (b-a)$ on $[a,b]$.
  $EE[X] = (a+b) slash 2$, $Var(X) = (b-a)^2 slash 12$.
]

#definition(title: "exponential")[
  $X tilde "Exp"(lambda)$ with $f(x) = lambda e^(-lambda x)$ for $x >= 0$.
  $EE[X] = 1 slash lambda$, $Var(X) = 1 slash lambda^2$.
]

The exponential is the continuous memoryless distribution --- the waiting time
between Poisson events. It is the standard model for time-to-failure with
constant hazard rate, and for inter-arrival times in queueing theory. Its
memorylessness is why "the process has been running an hour, it must be due to
finish" is wrong under this model, and why the exponential is often a *bad*
model for things that genuinely age.

#definition(title: "normal (Gaussian)")[
  $X tilde cal(N)(mu, sigma^2)$ with
  $ f(x) = 1/(sigma sqrt(2 pi)) e^(-(x-mu)^2 slash (2 sigma^2)). $
  $EE[X] = mu$, $Var(X) = sigma^2$.
]

#proposition(title: "the density integrates to 1")[
  The normalising constant $1 slash (sigma sqrt(2 pi))$ is exactly right.
]

#proof[
  Substituting $z = (x - mu) slash sigma$ reduces the claim to
  $integral_(-infinity)^infinity e^(-z^2 slash 2) dif z = sqrt(2 pi)$, and
  substituting $z = u sqrt(2)$ reduces that to
  $integral e^(-u^2) dif u = sqrt(pi)$ --- the Gaussian integral computed in
  Chapter 18 by converting to polar coordinates. That $sqrt(2 pi)$ has been
  waiting for this since then.
]

#intuition(title: "why the normal distribution is everywhere")[
  Three separate reasons, and it is worth knowing they are separate.

  *The central limit theorem* (Chapter 30). Sums of many independent
  contributions are approximately normal, regardless of what the contributions
  look like. Since a great many measured quantities are sums of small
  independent effects, a great many are approximately normal.

  *Maximum entropy.* Among all distributions with a given mean and variance,
  the normal has the largest entropy (Chapter 32). It is the least
  presumptuous choice given only those two facts.

  *Mathematical convenience.* Sums of independent normals are normal. Linear
  transforms of normals are normal. Marginals and conditionals of a
  multivariate normal are normal. The maximum-likelihood estimate under normal
  noise is least squares. Nothing else is this well behaved.

  The rule of thumb: about 68% of the mass within $1 sigma$, 95% within
  $2 sigma$, 99.7% within $3 sigma$.
]

#warning(title: "assuming normality is a real assumption")[
  Normal distributions have very thin tails --- the density decays like
  $e^(-x^2)$, so a $5 sigma$ event has probability about $3 times 10^(-7)$.

  Many real distributions do not. Financial returns, file sizes, network
  traffic, city populations, and word frequencies have *heavy tails*, often
  power-law. Under a power law, extreme events are orders of magnitude more
  likely than a normal model predicts, and the sample mean converges slowly or
  --- if the tail index is small enough --- the mean may not exist at all.

  Every "six sigma event" that occurs twice a decade is a normality assumption
  being wrong, not a miracle. Check your tails: plot the empirical
  distribution on log-log axes (Chapter 4) and see whether it straightens.
]

== Transformations

#theorem(title: "change of variable for densities")[
  If $Y = g(X)$ with $g$ monotone and differentiable, then
  $ f_Y (y) = f_X (g^(-1)(y)) abs((dif)/(dif y) g^(-1)(y)). $
]

#proof[
  For increasing $g$,
  $ F_Y (y) = PP(g(X) <= y) = PP(X <= g^(-1)(y)) = F_X (g^(-1)(y)). $
  Differentiate with respect to $y$ using the chain rule. For decreasing $g$
  the inequality flips and the derivative is negative, which the absolute
  value absorbs.
]

The Jacobian factor is Chapter 22's volume interpretation: densities are
probability per unit length, so stretching the axis must dilute the density.
In several variables the factor becomes $abs(det J)$, and that is the
foundation of normalising flows.

#example(title: "standardisation")[
  If $X tilde cal(N)(mu, sigma^2)$ then $Z = (X - mu) slash sigma tilde cal(N)(0,1)$.
  Every normal computation reduces to the standard normal by this shift and
  scale, which is why tables and library functions only ever provide the
  standard one.
]

== Exercises

#exercise[
  A fair die is rolled. Let $X$ be the result. Compute $EE[X]$, $EE[X^2]$, and
  $Var(X)$.
]

#exercise[
  Let $X tilde Bin(10, 0.3)$. Compute $PP(X = 3)$, $EE[X]$, and $Var(X)$.
  Then compute $PP(X >= 1)$ using complementary counting.
]

#exercise[
  Prove that the geometric distribution is memoryless:
  $PP(X > s+t | X > s) = PP(X > t)$. Start by showing
  $PP(X > k) = (1-p)^k$.
]

#exercise[
  Requests arrive at a mean rate of 3 per second, Poisson distributed. Find
  the probability of (a) exactly 5 in a given second, (b) none in a given
  second, (c) more than 1 in a given half-second.
]

#exercise[
  Let $X tilde Unif(0,1)$ and $Y = -ln(X) slash lambda$. Use the change of
  variable formula to show $Y tilde "Exp"(lambda)$. (This is how exponential
  variates are generated in practice.)
]

#exercise[
  Use indicator variables and linearity of expectation to find the expected
  number of "records" in a random permutation of $n$ distinct numbers --- a
  record being an element larger than everything before it. (You will get a
  harmonic number.)
]

#exercise[
  Show that $Var(X) = 0$ if and only if $X$ is constant with probability 1.
]

#exercise[
  A hash table with $m$ buckets receives $n$ keys uniformly at random. Use
  indicators to find the expected number of empty buckets, and evaluate it for
  $n = m$.
]

#exercise[
  Use Jensen's inequality to prove that for positive $X$ that is not constant,
  $EE[1 slash X] > 1 slash EE[X]$ strictly. Then give a concrete two-point
  example showing how large the gap can be.
]
