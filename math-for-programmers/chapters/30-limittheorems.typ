#import "../lib.typ": *

= The Limit Theorems

== Why these two theorems matter more than the rest

Everything in statistics rests on two results.

The *law of large numbers* says sample averages converge to the true mean. It
is what licenses estimating anything from data at all --- without it, a
measurement tells you nothing about the underlying quantity.

The *central limit theorem* says the *error* in that estimate is approximately
normal, with a size you can calculate. It is what licenses error bars,
confidence intervals, hypothesis tests, and A/B testing.

Together: you can measure things, and you can say how wrong you probably are.

== Inequalities first

The limit theorems need tools for bounding tail probabilities. These
inequalities are also useful in their own right --- they appear all over the
analysis of randomised algorithms.

#theorem(title: "Markov's inequality")[
  If $X >= 0$ and $a > 0$, then
  $ PP(X >= a) <= (EE[X])/a. $
]

#proof[
  Split the expectation according to whether $X >= a$:
  $ EE[X] = EE[X dot I_(X >= a)] + EE[X dot I_(X < a)] >= EE[X dot I_(X>=a)] >= a thin EE[I_(X >= a)] = a thin PP(X >= a), $
  using $X >= 0$ for the first inequality and $X >= a$ on the event for the
  second.
]

#intuition(title: "Markov, in words")[
  *A nonnegative quantity cannot often be much larger than its average.*

  At most $1 slash 10$ of a population can earn ten times the mean income, for
  the simple reason that they would otherwise account for more than all the
  income.

  It is a weak bound --- it uses only the mean and nonnegativity --- and its
  virtue is that it needs almost nothing. Every sharper bound below is Markov
  applied to a cleverly chosen function of $X$.
]

#theorem(title: "Chebyshev's inequality")[
  For any $X$ with finite variance,
  $ PP(abs(X - mu) >= k sigma) <= 1/(k^2). $
]

#proof[
  Apply Markov to the nonnegative variable $(X - mu)^2$ with threshold
  $k^2 sigma^2$:
  $ PP((X-mu)^2 >= k^2 sigma^2) <= (EE[(X-mu)^2])/(k^2 sigma^2) = (sigma^2)/(k^2 sigma^2) = 1/k^2. $
  The event $(X-mu)^2 >= k^2 sigma^2$ is the same as $abs(X - mu) >= k sigma$.
]

So at most 25% of any distribution lies beyond $2 sigma$, at most 11% beyond
$3 sigma$ --- for *any* distribution with finite variance, however weird. For
a normal distribution the true figures are 4.6% and 0.3%; Chebyshev is loose,
but it is universal, and that is the trade.

#theorem(title: "Chernoff bound, for sums of independent bounded variables")[
  Let $X = sum_(i=1)^n X_i$ with the $X_i$ independent and in $[0,1]$, and
  $mu = EE[X]$. Then for $delta > 0$,
  $ PP(X >= (1+delta) mu) <= exp( -(delta^2 mu)/(2 + delta) ), quad PP(X <= (1-delta)mu) <= exp(-(delta^2 mu)/2). $
]

#intuition(title: "why Chernoff is exponentially better")[
  Chebyshev gives a bound decaying like $1 slash k^2$. Chernoff gives one
  decaying like $e^(-k^2)$. The difference is enormous and it comes from using
  *more information*: Chebyshev uses only the variance, Chernoff uses the full
  moment generating function and independence.

  Mechanically: apply Markov to $e^(t X)$ rather than to $(X-mu)^2$, use
  $EE[e^(t X)] = product EE[e^(t X_i)]$ by independence (Chapter 29), and then
  optimise over $t$. Every "concentration inequality" in the literature is
  that recipe with different bookkeeping.

  This is the workhorse for randomised algorithms. It is why a randomised
  quicksort is $O(n log n)$ *with high probability*, not merely in
  expectation; why load balancing $n$ jobs across $n$ machines gives a maximum
  load of $O(log n slash log log n)$; and why a Bloom filter's false positive
  rate is tightly concentrated rather than merely correct on average.
]

== The law of large numbers

#definition(title: "sample mean")[
  For i.i.d. $X_1, dots, X_n$ (independent and identically distributed) with
  mean $mu$,
  $ overline(X)_n = 1/n sum_(i=1)^n X_i. $
]

#proposition[
  $EE[overline(X)_n] = mu$ and $Var(overline(X)_n) = sigma^2 slash n$.
]

#proof[
  Linearity gives the mean. For the variance, independence gives
  $Var(sum X_i) = n sigma^2$, and scaling by $1 slash n$ divides the variance
  by $n^2$.
]

That $sigma^2 slash n$ is the whole story of statistics in one expression: the
spread of your estimate shrinks like $1 slash n$, so its *standard deviation*
shrinks like $1 slash sqrt(n)$.

#theorem(title: "weak law of large numbers")[
  For i.i.d. $X_i$ with finite mean $mu$ and variance, for every
  $epsilon > 0$,
  $ PP(abs(overline(X)_n - mu) >= epsilon) arrow.r.long 0 quad "as" n -> infinity. $
]

#proof[
  Apply Chebyshev to $overline(X)_n$, whose standard deviation is
  $sigma slash sqrt(n)$:
  $ PP(abs(overline(X)_n - mu) >= epsilon) <= (sigma^2)/(n epsilon^2) -> 0. $
]

Three lines, and it is the entire justification for empirical measurement.

The *strong* law says more: $overline(X)_n -> mu$ with probability 1, meaning
the sequence of averages converges for almost every infinite sequence of
draws. The proof is harder and the practical difference is small.

#warning(title: "the gambler's fallacy is a misreading of the LLN")[
  The LLN says the *average* converges. It does *not* say deviations get
  corrected.

  After 100 tosses with 60 heads, the excess is $+10$. The LLN does not
  predict a compensating run of tails. It predicts that the excess becomes
  *negligible relative to $n$*: after a million tosses, an excess of $10$ ---
  or even $1000$ --- is a rounding error in the average.

  Deviations are not cancelled, they are *diluted*. Indeed the expected
  absolute deviation from $n slash 2$ *grows*, like $sqrt(n)$; it just grows
  slower than $n$.

  This also disposes of the "law of averages" in system design: a service that
  has been unusually reliable this month is not "due" for an outage.
]

== The central limit theorem

#theorem(title: "central limit theorem")[
  Let $X_1, X_2, dots$ be i.i.d. with mean $mu$ and finite variance
  $sigma^2 > 0$. Then
  $ Z_n = (overline(X)_n - mu)/(sigma slash sqrt(n)) arrow.r.long cal(N)(0,1) $
  in distribution: $PP(Z_n <= z) -> Phi(z)$ for every $z$, where $Phi$ is the
  standard normal CDF.
]

#proof[
  Sketch via moment generating functions (Chapter 29). Let
  $Y_i = (X_i - mu) slash sigma$, so $EE[Y_i] = 0$ and $Var(Y_i) = 1$, and
  $Z_n = (1 slash sqrt(n)) sum Y_i$.

  Expand the MGF of $Y$ as a power series (Chapter 17):
  $ M_Y (t) = 1 + t EE[Y] + (t^2)/2 EE[Y^2] + O(t^3) = 1 + (t^2)/2 + O(t^3). $

  By independence,
  $ M_(Z_n)(t) = ( M_Y (t slash sqrt(n)) )^n = ( 1 + (t^2)/(2n) + O(n^(-3 slash 2)) )^n. $

  Taking logs and using $ln(1+u) approx u$ for small $u$:
  $ ln M_(Z_n)(t) = n ln(1 + (t^2)/(2n) + dots.c) -> (t^2)/2. $

  So $M_(Z_n)(t) -> e^(t^2 slash 2)$, which is the MGF of $cal(N)(0,1)$. A
  continuity theorem for MGFs converts convergence of MGFs into convergence in
  distribution.
]

#intuition(title: "what the CLT is really saying, and what it is not")[
  Look at where the normal came from in that proof. Only the first two moments
  survived: everything past $t^2 slash 2$ vanished in the limit. *The
  distribution of the individual $X_i$ is completely forgotten* --- all that
  remains is the mean and the variance.

  That is why the normal is universal. Whatever the underlying distribution
  --- uniform, exponential, some grotesque bimodal thing --- averaging washes
  out every feature except the first two moments, and what is left is
  Gaussian.

  Two things the CLT does *not* say:

  *It is not about the data.* The CLT says the *sample mean* is approximately
  normal. Your data can be as non-normal as it likes; that is a separate
  question.

  *It needs finite variance.* Averages of Cauchy-distributed variables are
  *not* asymptotically normal --- the average of $n$ Cauchy variables has
  exactly the same distribution as one of them, so more data buys nothing at
  all. Heavy-tailed data with infinite variance genuinely breaks this theorem,
  and the correct limits are the *stable distributions*.
]

#example(title: "how fast is 'asymptotically'?")[
  The usual rule of thumb is $n >= 30$, which is folklore rather than a
  theorem. The truth depends on skewness:

  - Symmetric, light-tailed (uniform): $n = 5$ already looks normal.
  - Moderately skewed (exponential): $n approx 30$ is reasonable.
  - Heavily skewed (a Bernoulli with $p = 0.01$): you need
    $n p >= 10$ or so, i.e. $n >= 1000$, before the normal approximation to
    the count is any good.

  The *Berry--Esseen theorem* makes this quantitative: the error in the CLT
  approximation is at most $C rho slash (sigma^3 sqrt(n))$ where $rho$ is the
  third absolute moment. Note the $1 slash sqrt(n)$: convergence is *slow*,
  and skewness makes it slower.

  For rare events, use the Poisson approximation (Chapter 28) instead --- it
  is the right limit for that regime, and the normal is the wrong one.
]

== Standard error and confidence intervals

#definition(title: "standard error")[
  The *standard error* of the sample mean is
  $ "SE" = sigma / sqrt(n), $
  estimated by $s slash sqrt(n)$ when $sigma$ is unknown, with $s$ the sample
  standard deviation.
]

#intuition(title: "the tyranny of the square root")[
  Standard error shrinks like $1 slash sqrt(n)$, not $1 slash n$. To halve
  your uncertainty you need *four times* the data. To gain one decimal digit
  you need a hundred times.

  This single fact governs the economics of measurement:

  - A/B tests with small effects need enormous samples. Detecting a 1% lift
    with reasonable power typically needs tens of thousands of users per arm,
    and there is no clever way around it.
  - Benchmarking: 10 runs give you about $30%$ better precision than 6.
    Getting to $10 times$ better precision needs 100 times the runs. Reducing
    the *variance* of each run --- pinning cores, disabling turbo, controlling
    the environment --- is almost always cheaper than more runs.
  - Monte Carlo integration converges at $1 slash sqrt(n)$ regardless of
    dimension (Chapter 27). Terrible in 1D, unbeatable in 50D.

  Variance reduction beats sample size. Always look there first.
]

#theorem(title: "confidence interval for a mean")[
  By the CLT, an approximate $95%$ confidence interval for $mu$ is
  $ overline(X) plus.minus 1.96 dot s/sqrt(n), $
  since $PP(abs(Z) <= 1.96) approx 0.95$ for standard normal $Z$.
]

#warning(title: "what a confidence interval does not mean")[
  A 95% confidence interval does *not* mean "there is a 95% probability that
  $mu$ lies in this interval". Under the frequentist reading, $mu$ is a fixed
  unknown constant --- it is either in the interval or it is not, with no
  probability involved.

  What it means: *the procedure* produces an interval containing $mu$ 95% of
  the time, across hypothetical repetitions of the experiment. The randomness
  is in the interval, not in $mu$.

  The statement people actually want --- "given the data, there is a 95%
  probability that $mu$ is in here" --- is a *credible interval*, and it is a
  Bayesian object requiring a prior (Chapter 31). The two often coincide
  numerically, which is why the misinterpretation persists and usually does no
  damage. But they are different claims, and they can diverge sharply when the
  prior matters.
]

== Convergence, and the different kinds of it

Worth naming, since the literature distinguishes them and the distinctions
matter.

#definition[
  - *In probability:* $PP(abs(X_n - X) > epsilon) -> 0$ for every $epsilon$.
    (Weak LLN.)
  - *Almost surely:* $PP(lim X_n = X) = 1$. (Strong LLN.) Stronger.
  - *In distribution:* $F_n (x) -> F(x)$ at every continuity point. (CLT.)
    Weakest of the three --- it says nothing about the variables being close,
    only their distributions.
  - *In $L^2$:* $EE[(X_n - X)^2] -> 0$. Implies convergence in probability.
]

Almost sure $arrow.r.double$ in probability $arrow.r.double$ in distribution,
and none of the reverse implications hold. When a paper says a estimator "is
consistent" it means convergence in probability to the true value; when it
says "asymptotically normal" it means a CLT-style convergence in distribution
of the rescaled error.

== The bootstrap

A modern technique that makes the CLT unnecessary in many practical cases, and
which is worth knowing because it is so easy to implement.

#algo(title: "Bootstrap confidence interval")[
```
given a sample x[1..n] and a statistic T:
    repeat B times (B = 10000, say):
        draw n items from x WITH replacement
        compute T on that resample
    the 2.5th and 97.5th percentiles of the B values
    form a 95% confidence interval for T
```
]

#intuition(title: "why resampling your own data works")[
  You want to know how much $T$ would vary if you drew a new sample from the
  population. You cannot --- you only have one sample.

  The bootstrap's move: *use the empirical distribution as a stand-in for the
  population.* Resampling with replacement from your data simulates drawing
  fresh samples from that stand-in, and the variability you observe estimates
  the variability you care about.

  It works because the empirical distribution converges to the true one (a
  uniform version of the LLN), so the simulated variability converges to the
  real variability.

  Its virtues: it needs no formula for the standard error, so it works for
  medians, ratios, correlations, and arbitrary statistics with no analytic
  theory. Its costs: it needs the sample to be representative, it struggles
  for statistics that depend on the extreme tails (the maximum, for instance),
  and it is $B$ times the compute --- which, for a modern machine, is usually
  nothing.
]

== Exercises

#exercise[
  A random variable has mean 10 and standard deviation 2. Use Chebyshev to
  bound $PP(X >= 20)$, then compare with the exact value if $X$ were normal.
  Comment on the gap.
]

#exercise[
  Use Markov's inequality to show that for a nonnegative $X$ with
  $EE[X] = 1$, $PP(X >= 100) <= 0.01$. Then construct a distribution achieving
  equality, showing the bound is tight.
]

#exercise[
  You measure a latency 100 times and get $overline(x) = 250$ ms with
  $s = 40$ ms. Give a 95% confidence interval for the mean latency. How many
  measurements would you need to halve the interval width?
]

#exercise[
  A fair coin is tossed 10,000 times. Use the CLT to estimate the probability
  of getting between 4900 and 5100 heads.
]

#exercise[
  Prove that if $X_1, dots, X_n$ are i.i.d. with variance $sigma^2$, then
  $Var(overline(X)) = sigma^2 slash n$. Then redo the computation when the
  $X_i$ have pairwise correlation $rho$, and find the limit as
  $n -> infinity$.
]

#exercise[
  Explain why the CLT does not apply to the sample mean of Cauchy-distributed
  variables, and state what actually happens to $overline(X)_n$ in that case.
]

#exercise[
  You want to detect a 2% relative improvement in a conversion rate currently
  at 5%. Using the normal approximation, estimate the sample size per arm
  needed for the standard error of the difference to be small enough that a 2%
  relative lift is two standard errors.
]

#exercise[
  You have 200 measurements and want a confidence interval for their *median*,
  not their mean. Explain why the standard formula does not apply, and
  describe how you would use the bootstrap instead.
]
