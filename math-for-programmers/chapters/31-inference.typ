#import "../lib.typ": *

= Estimation and Inference

== The inverse problem

Chapters 27--30 went forwards: given a model, what does the data look like?

Statistics goes backwards: given the data, what is the model? That is a harder
question --- it has no unique answer, only better and worse ones --- and the
whole subject is about what "better" should mean.

#definition(title: "statistical model and estimator")[
  A *model* is a family of distributions $p(x ; theta)$ indexed by a parameter
  $theta$ (possibly a vector).

  An *estimator* $hat(theta)(X_1, dots, X_n)$ is any function of the data used
  to guess $theta$. Being a function of random data, an estimator is itself a
  random variable.
]

#definition(title: "how to judge an estimator")[
  - *Bias:* $"Bias"(hat(theta)) = EE[hat(theta)] - theta$. Zero bias means
    right *on average*.
  - *Variance:* $Var(hat(theta))$. How much it jumps around between samples.
  - *Mean squared error:* $"MSE" = EE[(hat(theta) - theta)^2]$.
  - *Consistency:* $hat(theta) -> theta$ in probability as $n -> infinity$.
]

#theorem(title: "bias--variance decomposition")[
  $ "MSE"(hat(theta)) = "Bias"(hat(theta))^2 + Var(hat(theta)). $
]

#proof[
  Write $hat(theta) - theta = (hat(theta) - EE[hat(theta)]) + (EE[hat(theta)] - theta)$
  and square. The cross term is
  $2 EE[hat(theta) - EE[hat(theta)]] dot (EE[hat(theta)] - theta) = 0$, since
  the first factor has expectation zero.
]

#intuition(title: "unbiased is not the goal")[
  Beginners treat unbiasedness as a requirement. It is not; it is one term of
  two, and trading a little bias for a lot of variance reduction is usually a
  win.

  This is exactly the bias--variance trade-off in machine learning. A
  high-capacity model has low bias (it can represent the truth) and high
  variance (it fits the noise). Regularisation deliberately introduces bias
  --- ridge regression shrinks coefficients towards zero, which is *wrong on
  average* --- and reduces variance enough that total error falls.

  The James--Stein estimator is the famous formal example: for estimating
  three or more means simultaneously, a *biased* shrinkage estimator has
  strictly lower MSE than the obvious unbiased one, for every value of the
  parameters. Unbiasedness is not free and it is not sacred.
]

== Maximum likelihood

#definition(title: "likelihood")[
  Given observed data $x_1, dots, x_n$, the *likelihood* is
  $ cal(L)(theta) = product_(i=1)^n p(x_i ; theta), $
  and the *log-likelihood* is $ell(theta) = sum_i log p(x_i ; theta)$.

  The *maximum likelihood estimator* is
  $ hat(theta)_"MLE" = argmax_theta cal(L)(theta) = argmax_theta ell(theta). $
]

#intuition(title: "read the likelihood in the right direction")[
  $cal(L)(theta)$ is *the probability of the data you actually saw, as a
  function of the parameter*. The data is fixed; $theta$ varies. That is the
  reverse of how you read $p(x;theta)$, and getting the direction right is
  most of understanding likelihood.

  MLE picks the parameter that makes the observed data least surprising.

  Two reasons to take logs, both from Chapter 4. Numerically, a product of
  thousands of small probabilities underflows and a sum of logs does not.
  Analytically, sums differentiate far more pleasantly than products. And the
  maximiser is unchanged, because $log$ is strictly increasing --- a "safe
  transformation" in the sense of Chapter 2.
]

#example(title: "MLE for a Bernoulli")[
  $n$ coin flips, $k$ heads. Then
  $ ell(p) = k log p + (n-k) log(1-p). $
  Differentiate and set to zero:
  $ ell'(p) = k/p - (n-k)/(1-p) = 0 quad arrow.r.double quad k(1-p) = (n-k)p quad arrow.r.double quad hat(p) = k/n. $
  The sample proportion. Reassuring, and it did not have to be: the *method*
  produced the obvious answer rather than the answer being assumed.

  Check it is a maximum: $ell''(p) = -k slash p^2 - (n-k) slash (1-p)^2 < 0$,
  so $ell$ is concave and the critical point is the global maximum.
]

#example(title: "MLE for a normal")[
  With $x_1, dots, x_n$ from $cal(N)(mu, sigma^2)$,
  $ ell(mu, sigma^2) = -n/2 log(2 pi) - n/2 log sigma^2 - 1/(2 sigma^2) sum_i (x_i - mu)^2. $

  $partial ell slash partial mu = 0$ gives $sum (x_i - mu) = 0$, so
  $hat(mu) = overline(x)$.

  $partial ell slash partial sigma^2 = 0$ gives
  $ -n/(2 sigma^2) + 1/(2 sigma^4) sum (x_i - hat(mu))^2 = 0 quad arrow.r.double quad hat(sigma)^2 = 1/n sum_i (x_i - overline(x))^2. $

  Note the $1 slash n$. This estimator is *biased*: its expectation is
  $((n-1) slash n) sigma^2$, because $overline(x)$ was itself estimated from
  the same data and sits slightly closer to the points than the true $mu$
  does. Dividing by $n-1$ instead gives the unbiased *sample variance* --- and
  that is where the mysterious $n-1$ comes from. One degree of freedom was
  consumed estimating the mean.
]

#theorem(title: "least squares is maximum likelihood under Gaussian noise")[
  If $y_i = f(x_i ; theta) + epsilon_i$ with $epsilon_i tilde cal(N)(0,sigma^2)$
  independent, then
  $ hat(theta)_"MLE" = argmin_theta sum_i (y_i - f(x_i;theta))^2. $
]

#proof[
  $ ell(theta) = sum_i [ -1/2 log(2 pi sigma^2) - ((y_i - f(x_i;theta))^2)/(2 sigma^2) ]. $
  The first term does not involve $theta$; maximising the rest is minimising
  the sum of squares.
]

#intuition(title: "every loss function is a distributional assumption")[
  This theorem is the reason to care about likelihood even if you never do
  statistics. It says that *choosing a loss function is choosing a noise
  model*, whether or not you realise it:

  #align(center)[
    #table(
      columns: 2, inset: 7pt, stroke: 0.4pt + luma(180), align: (left, left),
      table.header([*Loss*], [*Implied noise model*]),
      [Squared error], [Gaussian],
      [Absolute error], [Laplace (heavier tails, robust)],
      [Cross-entropy], [Categorical / Bernoulli],
      [Poisson deviance], [Poisson counts],
      [Huber], [Gaussian centre, Laplace tails],
    )
  ]

  So "my model is sensitive to outliers" is not a mysterious pathology --- it
  is the Gaussian assumption in your squared loss telling you it did not
  expect outliers, and correctly concluding that an extreme point must be very
  informative. Switching to absolute or Huber loss is switching to a noise
  model with heavier tails, which discounts extremes.

  Similarly, adding $ell_2$ regularisation is placing a Gaussian *prior* on
  the parameters, and $ell_1$ regularisation is a Laplace prior. Chapter 34's
  regularisers all have this reading.
]

#theorem(title: "properties of the MLE")[
  Under regularity conditions, as $n -> infinity$ the MLE is:
  - *consistent:* $hat(theta) -> theta_0$ in probability;
  - *asymptotically normal:* $sqrt(n)(hat(theta) - theta_0) -> cal(N)(0, I(theta_0)^(-1))$;
  - *asymptotically efficient:* no consistent estimator has smaller asymptotic
    variance.
]

#definition(title: "Fisher information")[
  $ I(theta) = EE[ ( (partial)/(partial theta) log p(X;theta) )^2 ] = -EE[ (partial^2)/(partial theta^2) log p(X;theta) ]. $
]

#theorem(title: "Cramér--Rao lower bound")[
  For any unbiased estimator, $ Var(hat(theta)) >= 1/(n I(theta)). $
]

#intuition(title: "information is curvature")[
  Fisher information is (minus) the expected *curvature* of the
  log-likelihood at the truth.

  A sharply peaked log-likelihood means the data strongly discriminates
  between nearby parameter values: high curvature, high information, low
  achievable variance. A flat log-likelihood means many parameter values
  explain the data about equally well: low information, and no estimator can
  do better than badly.

  The Cramér--Rao bound is the statistical analogue of a complexity lower
  bound. It says: this is the best any unbiased estimator can do, so stop
  looking. And the MLE attains it asymptotically, which is why the MLE is the
  default.

  In practice, the inverse Hessian of the negative log-likelihood at the
  optimum estimates $I^(-1)$, which is how standard errors are computed for
  fitted models --- including for a logistic regression, where the reported
  coefficient standard errors are exactly this.
]

== Bayesian inference

#definition(title: "the Bayesian setup")[
  Treat $theta$ as a random variable with a *prior* $p(theta)$. After
  observing data $D$, Bayes' theorem (Chapter 27) gives the *posterior*
  $ p(theta | D) = (p(D|theta) p(theta))/(p(D)) prop cal(L)(theta) p(theta). $
]

#definition(title: "point estimates from a posterior")[
  - *MAP* (maximum a posteriori): $argmax_theta p(theta | D)$ --- the mode.
  - *Posterior mean:* $EE[theta | D]$ --- minimises posterior squared error
    (Chapter 29).
  - *Credible interval:* a region containing, say, 95% of the posterior mass.
    This *does* mean "95% probability the parameter is in here", unlike a
    confidence interval.
]

#proposition(title: "MAP is regularised MLE")[
  $ argmax_theta [ log cal(L)(theta) + log p(theta) ]. $
  A Gaussian prior $cal(N)(0, tau^2 I)$ contributes
  $-norm(theta)^2 slash (2 tau^2)$ --- exactly $ell_2$ regularisation. A
  Laplace prior contributes $-norm(theta)_1 slash b$ --- exactly $ell_1$.
]

So ridge regression is MAP estimation with a Gaussian prior, and lasso is MAP
with a Laplace prior. The regularisation strength $lambda$ is the inverse
prior variance: strong regularisation means a confident prior that the
coefficients are small.

#example(title: "Beta-Bernoulli, worked")[
  Estimate a coin's bias $p$ from $k$ heads in $n$ flips, with prior
  $p tilde "Beta"(alpha, beta)$, whose density is proportional to
  $p^(alpha-1)(1-p)^(beta-1)$.

  $
  p(p | D) prop underbrace(p^k (1-p)^(n-k), "likelihood") dot underbrace(p^(alpha-1)(1-p)^(beta-1), "prior") = p^(k+alpha-1)(1-p)^(n-k+beta-1),
  $
  which is $"Beta"(alpha + k, beta + n - k)$. The posterior is in the same
  family as the prior --- the Beta is *conjugate* to the Bernoulli --- so
  updating is just adding counts.

  Posterior mean: $ (alpha + k)/(alpha + beta + n). $

  Read the prior parameters as *pseudo-counts*: $alpha$ imagined heads and
  $beta$ imagined tails, seen before any data. With
  $alpha = beta = 1$ (a uniform prior) the estimate is $(k+1) slash (n+2)$ ---
  *Laplace's rule of succession*, and a far better default than $k slash n$
  when $n$ is small.

  With $n = 0$ the MLE $k slash n$ is undefined; with $k = 0$ it says the
  event is impossible, which is a strong claim from no evidence. The Bayesian
  estimate degrades gracefully in both cases, which is exactly why additive
  smoothing is standard practice in naive Bayes classifiers and in language
  modelling.
]

#intuition(title: "frequentist versus Bayesian, practically")[
  The philosophical argument is old and mostly unproductive. The practical
  differences:

  *Priors.* Bayesian methods require one. That is a cost (it is a choice you
  must defend) and a benefit (you can encode real knowledge, and you get
  sensible answers from small samples).

  *What you get out.* A frequentist gives you a point estimate and a
  procedure with long-run guarantees. A Bayesian gives you a full distribution
  over parameters, which composes: uncertainty propagates naturally through
  downstream calculations.

  *Compute.* Frequentist methods are usually cheap and closed-form. Bayesian
  posteriors usually are not, requiring MCMC or variational approximation. This
  was decisive before about 1990 and matters much less now.

  *Convergence.* With enough data they agree: the likelihood swamps any
  reasonable prior, and the posterior concentrates around the MLE. The
  disagreement is about the small-data regime --- which is, unfortunately, the
  regime most real decisions are made in.
]

== Hypothesis testing

#definition(title: "the setup")[
  A *null hypothesis* $H_0$ (the boring explanation) and an *alternative*
  $H_1$. Choose a test statistic $T$, compute its distribution *assuming $H_0$
  is true*, and see whether the observed value is extreme.

  The *p-value* is
  $ p = PP(T "at least as extreme as observed" | H_0). $
  Reject $H_0$ if $p < alpha$, a threshold fixed in advance.
]

#definition(title: "the two errors")[
  - *Type I* (false positive): rejecting a true $H_0$. Probability $alpha$.
  - *Type II* (false negative): failing to reject a false $H_0$. Probability
    $beta$; the *power* is $1 - beta$.
]

#warning(title: "what a p-value is not")[
  A p-value is $PP("data" | H_0)$. It is *not* $PP(H_0 | "data")$. Those
  differ by exactly the Bayes factor of Chapter 27, and confusing them is the
  base-rate fallacy in another costume.

  Specifically, a p-value is not:

  - the probability the null hypothesis is true;
  - the probability the result was due to chance;
  - a measure of effect size --- with enough data, a trivially small effect
    gives a tiny p-value;
  - evidence *for* $H_0$ when it is large; failing to reject is not accepting.

  And *p-hacking* is a real mechanism, not a moralism. Test 20 independent
  hypotheses at $alpha = 0.05$ and the probability of at least one false
  positive is $1 - 0.95^20 approx 64%$. Multiple comparisons must be corrected
  for --- Bonferroni ($alpha slash m$, conservative) or
  Benjamini--Hochberg (controls the false discovery rate, more powerful) ---
  and the number of tests includes the ones you tried and did not report.
]

#example(title: "the standard tests, and when each applies")[
  #align(center)[
    #table(
      columns: 2, inset: 7pt, stroke: 0.4pt + luma(180), align: (left, left),
      table.header([*Test*], [*Use*]),
      [$z$-test], [Mean, known variance, large $n$],
      [$t$-test], [Mean, unknown variance --- uses the $t$ distribution, which has heavier tails than the normal to account for estimating $sigma$],
      [Paired $t$-test], [Before/after on the same units; removes between-unit variance],
      [Chi-squared], [Goodness of fit; independence in a contingency table],
      [Mann--Whitney], [Two groups, no distributional assumption (rank-based)],
      [Kolmogorov--Smirnov], [Does a sample come from a given distribution],
      [ANOVA], [Comparing more than two group means at once],
    )
  ]
]

#example(title: "an A/B test, done properly")[
  Control: 1000 users, 50 conversions ($hat(p)_A = 0.05$). Treatment: 1000
  users, 65 conversions ($hat(p)_B = 0.065$).

  Under $H_0$ (no difference), pool the rates:
  $hat(p) = 115 slash 2000 = 0.0575$. The standard error of the difference is
  $ "SE" = sqrt( hat(p)(1-hat(p)) (1/n_A + 1/n_B) ) = sqrt(0.0575 times 0.9425 times 0.002) approx 0.0104. $
  The test statistic is
  $ z = (0.065 - 0.05)/0.0104 approx 1.44, $
  giving a two-sided p-value of about $0.15$. Not significant at $alpha = 0.05$.

  The right conclusion is *not* "there is no effect". It is "this experiment
  could not distinguish a 1.5-point lift from noise". A power calculation done
  *before* running it would have said so: detecting a lift of this size with
  80% power needs roughly 3500 users per arm.

  Running the test first and computing power afterwards --- or worse, peeking
  at the results daily and stopping when $p < 0.05$ --- inflates the false
  positive rate substantially. Sequential testing requires its own machinery
  (alpha spending, or always-valid confidence sequences).
]

== Exercises

#exercise[
  Derive the MLE for the rate $lambda$ of a Poisson distribution given
  observations $x_1, dots, x_n$. Verify it is a maximum.
]

#exercise[
  Derive the MLE for the parameter $lambda$ of an exponential distribution,
  and check whether it is unbiased.
]

#exercise[
  Show that the sample variance with divisor $n-1$ is unbiased, i.e.
  $EE[ (1 slash (n-1)) sum (X_i - overline(X))^2 ] = sigma^2$. (Expand and use
  $EE[overline(X)^2] = mu^2 + sigma^2 slash n$.)
]

#exercise[
  A coin is flipped 10 times, giving 7 heads. Give the MLE for $p$, and the
  posterior mean under a $"Beta"(1,1)$ prior and under a $"Beta"(10,10)$
  prior. Explain the difference.
]

#exercise[
  Show that MAP estimation with a Gaussian prior $cal(N)(0, tau^2 I)$ and
  Gaussian likelihood gives exactly ridge regression, and identify $lambda$ in
  terms of $tau^2$ and the noise variance $sigma^2$.
]

#exercise[
  You run 40 independent A/B tests, all with no true effect, at
  $alpha = 0.05$. What is the expected number of "significant" results, and
  the probability of at least one? What Bonferroni threshold would keep the
  family-wise error rate at 5%?
]

#exercise[
  Compute the Fisher information for a Bernoulli parameter $p$, and use the
  Cramér--Rao bound to state the minimum possible variance of an unbiased
  estimator from $n$ samples. Compare with the actual variance of
  $hat(p) = k slash n$.
]

#exercise[
  Design an A/B test to detect a relative lift of 10% on a baseline
  conversion rate of 2%, with 80% power at $alpha = 0.05$. Estimate the
  required sample size per arm using the normal approximation.
]
