#import "../lib.typ": *

== Chapter 31 --- Estimation and Inference

#soln("31.1")[
  For $X_i tilde Pois(lambda)$,
  $ ell(lambda) = sum_i [ x_i log lambda - lambda - log(x_i !) ]. $
  Differentiating:
  $ ell'(lambda) = (sum_i x_i)/lambda - n = 0 quad arrow.r.double quad hat(lambda) = (1)/n sum_i x_i = overline(x). $

  *Maximum?* $ell''(lambda) = -(sum x_i) slash lambda^2 < 0$ (assuming not all
  observations are zero), so $ell$ is strictly concave and the critical point
  is the global maximum.

  The sample mean --- reassuring, since $lambda$ *is* the mean of a Poisson.
]

#soln("31.2")[
  For $X_i tilde "Exp"(lambda)$,
  $ ell(lambda) = n log lambda - lambda sum_i x_i. $
  $ ell'(lambda) = n/lambda - sum_i x_i = 0 quad arrow.r.double quad hat(lambda) = n/(sum_i x_i) = 1/overline(x). $

  *Unbiased?* No. $sum X_i tilde "Gamma"(n, lambda)$, and for that
  distribution $EE[1 slash sum X_i] = lambda slash (n-1)$. So
  $ EE[hat(lambda)] = n EE[1/(sum X_i)] = (n lambda)/(n-1) > lambda. $

  The MLE *overestimates* the rate, by a factor $n slash (n-1)$. Multiplying
  by $(n-1) slash n$ gives an unbiased estimator.

  This is the general situation: MLEs are *consistent* (the bias vanishes as
  $n -> infinity$) but not generally unbiased at finite $n$, because
  maximum likelihood does not commute with nonlinear transformations. Here the
  parameter is $1 slash "mean"$, and the reciprocal of an unbiased estimate of
  the mean is not an unbiased estimate of the reciprocal --- Jensen's
  inequality (Chapter 28), in fact.
]

#soln("31.3")[
  Expand the sum of squared deviations:
  $ sum_i (X_i - overline(X))^2 = sum_i X_i^2 - n overline(X)^2. $

  Taking expectations, and using $EE[X_i^2] = sigma^2 + mu^2$ and
  $EE[overline(X)^2] = Var(overline(X)) + (EE[overline(X)])^2 = sigma^2 slash n + mu^2$:
  $
  EE[ sum_i (X_i - overline(X))^2 ] &= n(sigma^2 + mu^2) - n( (sigma^2)/n + mu^2 ) \
  &= n sigma^2 + n mu^2 - sigma^2 - n mu^2 = (n-1) sigma^2.
  $

  Dividing by $n - 1$:
  $ EE[ 1/(n-1) sum_i (X_i - overline(X))^2 ] = sigma^2. $

  *Where the missing degree of freedom went.* The deviations are measured from
  $overline(X)$, not from the true $mu$ --- and $overline(X)$ is the value that
  *minimises* the sum of squared deviations, so it necessarily sits closer to
  the data than $mu$ does. Dividing by $n$ would systematically underestimate.
  The one degree of freedom consumed estimating the mean is exactly the
  correction.
]

#soln("31.4")[
  10 flips, 7 heads.

  *MLE:* $hat(p) = 7 slash 10 = 0.700$.

  *$"Beta"(1,1)$ prior* (uniform, equivalent to 2 pseudo-observations, one of
  each). Posterior is $"Beta"(1+7, thin 1+3) = "Beta"(8,4)$, with mean
  $ 8/(8+4) = 2/3 approx 0.667. $

  *$"Beta"(10,10)$ prior* (equivalent to 20 pseudo-observations, 10 heads and
  10 tails). Posterior is $"Beta"(17, 13)$, with mean
  $ 17/30 approx 0.567. $

  *The difference.* The $"Beta"(10,10)$ prior encodes a fairly strong belief
  that the coin is near-fair, carrying twice the weight of the actual data
  (20 pseudo-observations against 10 real ones). So the posterior is pulled
  most of the way back towards $0.5$.

  The $"Beta"(1,1)$ prior is nearly uninformative --- it shifts the estimate
  only from $0.700$ to $0.667$, which is Laplace's rule of succession
  $(k+1) slash (n+2)$.

  The right question is always "how many observations is my prior worth?", and
  for the Beta family the answer is literally $alpha + beta$.
]

#soln("31.5")[
  With Gaussian likelihood (noise variance $sigma^2$) and prior
  $x tilde cal(N)(0, tau^2 I)$, the log posterior is
  $
  log p(x | b) = "const" - (norm(A x - b)^2)/(2 sigma^2) - (norm(x)^2)/(2 tau^2).
  $

  Maximising this is minimising
  $ (norm(A x - b)^2)/(2 sigma^2) + (norm(x)^2)/(2 tau^2), $
  and multiplying through by $2 sigma^2$ (which does not move the minimiser):
  $ norm(A x - b)^2 + (sigma^2)/(tau^2) norm(x)^2. $

  That is exactly ridge regression with
  $ lambda = (sigma^2)/(tau^2). $

  *Reading it.* $lambda$ is the ratio of noise variance to prior variance ---
  the ratio of "how uncertain the data is" to "how uncertain I was
  beforehand". Noisy data (large $sigma^2$) or a confident prior (small
  $tau^2$) both mean strong regularisation. A vague prior
  ($tau^2 -> infinity$) gives $lambda -> 0$ and recovers ordinary least
  squares.

  This is why tuning $lambda$ by cross-validation is, in Bayesian terms,
  empirically choosing how much you believe your prior.
]

#soln("31.6")[
  40 independent tests, no true effects, $alpha = 0.05$.

  *Expected number of "significant" results:* by linearity of expectation,
  $40 times 0.05 = 2$.

  *Probability of at least one:*
  $ 1 - (0.95)^40 = 1 - 0.1285 = 0.8715. $

  So you would be *unlucky not to find something*, and whatever you found
  would be noise.

  *Bonferroni threshold:* to keep the family-wise error rate at 5%, use
  $ alpha' = alpha/m = 0.05/40 = 0.00125. $

  Bonferroni is conservative --- it controls the probability of *any* false
  positive, which is a strong requirement, and with many tests it becomes very
  hard to detect anything real. When you have hundreds of tests and expect
  some genuine effects, Benjamini--Hochberg (controlling the *false discovery
  rate*, the expected proportion of discoveries that are false) is usually the
  better trade.

  And the count $m$ must include every test you ran, including the ones you
  decided not to report. That is not a technicality; it is the whole content
  of the multiple comparisons problem.
]

#soln("31.7")[
  For a Bernoulli, $log p(x; p) = x log p + (1-x) log(1-p)$.

  $ (partial)/(partial p) log p(x;p) = x/p - (1-x)/(1-p). $
  $ (partial^2)/(partial p^2) log p(x;p) = -x/(p^2) - (1-x)/((1-p)^2). $

  Taking $-EE[dot]$ with $EE[X] = p$:
  $ I(p) = p/(p^2) + (1-p)/((1-p)^2) = 1/p + 1/(1-p) = 1/(p(1-p)). $

  *Cramér--Rao bound:*
  $ Var(hat(p)) >= 1/(n I(p)) = (p(1-p))/n. $

  *The sample proportion.* $hat(p) = k slash n$ with $k tilde Bin(n,p)$, so
  $ Var(hat(p)) = (n p(1-p))/(n^2) = (p(1-p))/n. $

  *It attains the bound exactly.* The sample proportion is an *efficient*
  estimator: no unbiased estimator of $p$ can do better, at any $n$. There is
  no cleverer statistic waiting to be found.

  Note also that $I(p) = 1 slash (p(1-p))$ is smallest at $p = 1 slash 2$ and
  blows up near $0$ and $1$ --- the data is *most* informative about
  extreme rates and least informative about a fair coin, which matches the
  intuition that distinguishing $p = 0.5$ from $p = 0.51$ is much harder than
  distinguishing $p = 0.001$ from $p = 0.011$.
]

#soln("31.8")[
  Baseline $p_1 = 0.02$, 10% relative lift means $p_2 = 0.022$, so
  $Delta = 0.002$.

  For 80% power at two-sided $alpha = 0.05$, the standard formula for the
  sample size per arm is
  $ n = ((z_(alpha slash 2) + z_beta)^2 [p_1(1-p_1) + p_2(1-p_2)])/(Delta^2), $
  with $z_(0.025) = 1.96$ and $z_(0.20) = 0.84$.

  $ (1.96 + 0.84)^2 = 7.84. $
  $ p_1(1-p_1) = 0.0196, quad p_2(1-p_2) = 0.021516, quad "sum" = 0.041116. $
  $ n = (7.84 times 0.041116)/(0.002^2) = (0.32235)/(4 times 10^(-6)) approx 80,!600. $

  *About 80,000 users per arm*, so 160,000 in total.

  Two things to note. The requirement scales as $1 slash Delta^2$, so halving
  the effect you want to detect quadruples the cost. And it scales roughly as
  $1 slash p$ for small $p$, so low-conversion funnels are much more expensive
  to experiment on --- which is why teams working on rare events measure
  upstream proxies instead.
]

== Chapter 32 --- Information Theory

#soln("32.1")[
  *(a) Fair 8-sided die.* Uniform over 8 outcomes:
  $Hent = log_2 8 = 3$ bits.

  *(b) $(0.5, 0.25, 0.125, 0.125)$.*
  $ Hent = 0.5(1) + 0.25(2) + 0.125(3) + 0.125(3) = 0.5 + 0.5 + 0.375 + 0.375 = 1.75 "bits". $

  *(c) $(0.97, 0.01, 0.01, 0.01)$.*
  $ Hent = -0.97 log_2 0.97 - 3(0.01 log_2 0.01) = 0.0426 + 0.1993 = 0.242 "bits". $

  *Compressibility.* Naively each source needs 3, 2, and 2 bits per symbol
  respectively. The entropies say the true limits are 3, 1.75, and 0.242.

  So (a) is *incompressible* --- it is already at its limit. (b) can be
  compressed by 12.5%. And (c) can be compressed by a factor of more than 8,
  because it is almost always the same symbol and a good coder spends almost
  nothing saying so.
]

#soln("32.2")[
  *Huffman code for (b).* Merge the two smallest repeatedly:
  $0.125 + 0.125 = 0.25$; then $0.25 + 0.25 = 0.5$; then $0.5 + 0.5 = 1$.
  Reading off the tree:
  $ a -> 0 quad (1 "bit"), quad b -> 10 quad (2), quad c -> 110 quad (3), quad d -> 111 quad (3). $
  Average length:
  $ 0.5(1) + 0.25(2) + 0.125(3) + 0.125(3) = 1.75 "bits" = Hent. $ ✓

  *Does (a) achieve equality?* Yes. Eight equally likely symbols get 3-bit
  codes, average 3 bits, which equals the entropy.

  *Why these two work.* In both cases every probability is a power of
  $1 slash 2$, so the ideal codeword length $-log_2 p_i$ is an *integer* and
  Huffman can hit it exactly. This is the condition for a *dyadic*
  distribution.

  *Why (c) cannot.* Here $-log_2 0.97 = 0.044$ bits --- but a Huffman codeword
  must be at least 1 bit long. So the common symbol is charged 1 bit when it
  deserves 0.044, and the average length is at least 1 bit against an entropy
  of 0.242. Huffman is off by a factor of four.

  *The fix* is arithmetic coding, which encodes the whole message as a single
  number and therefore charges fractional bits per symbol, approaching the
  entropy arbitrarily closely. This is exactly why modern compressors (and
  neural compressors) use arithmetic or range coding rather than Huffman.
]

#soln("32.3")[
  Start from the chain rule for entropy,
  $ Hent(X,Y) = Hent(X) + Hent(Y|X), $
  which follows from $p(x,y) = p(x) p(y|x)$ and expanding the logarithm.

  So $Hent(X,Y) = Hent(X) + Hent(Y)$ holds iff
  $Hent(Y|X) = Hent(Y)$, i.e. iff
  $ I(X;Y) = Hent(Y) - Hent(Y|X) = 0. $

  And by Gibbs' inequality, $I(X;Y) = KL(p(x,y) || p(x)p(y)) = 0$ iff the two
  distributions are equal, i.e. iff $p(x,y) = p(x)p(y)$ --- which is exactly
  independence.

  *In words:* the information in the pair equals the sum of the individual
  informations precisely when neither tells you anything about the other. Any
  dependence means some of the information is shared, hence counted twice in
  the sum.
]

#soln("32.4")[
  $p = (0.5, 0.5)$, $q = (0.9, 0.1)$, in bits.

  $
  KL(p||q) &= 0.5 log_2 (0.5/0.9) + 0.5 log_2 (0.5/0.1) \
  &= 0.5(-0.848) + 0.5(2.322) = -0.424 + 1.161 = 0.737 "bits".
  $

  $
  KL(q||p) &= 0.9 log_2 (0.9/0.5) + 0.1 log_2 (0.1/0.5) \
  &= 0.9(0.848) + 0.1(-2.322) = 0.763 - 0.232 = 0.531 "bits".
  $

  *$KL(p||q)$ is larger.*

  *Why, in the language of the chapter.* $KL(p||q)$ weights the log-ratio by
  $p$. Here $p$ puts a full half of its mass on the outcome where $q$ assigns
  only $0.1$, and the ratio there is $5$ --- so the term
  $0.5 log_2 5 = 1.16$ dominates. The first argument punishes $q$ for
  *under-covering* $p$'s support, and it does so severely.

  $KL(q||p)$ weights by $q$, which is concentrated on the outcome where $p$ is
  perfectly adequate ($0.5$ versus $0.9$, a ratio of only $1.8$), so the
  penalty is milder.

  This is the mean-seeking/mode-seeking asymmetry made numerical: the first
  direction hates missing mass, the second tolerates it.
]

#soln("32.5")[
  *Reduction to $-log q_y$.* With one-hot $p$, the vector $y$ has $y_c = 1$
  for the true class $c$ and $0$ elsewhere. So
  $ Hent(p,q) = -sum_i y_i log q_i = -log q_c, $
  because every term but one is multiplied by zero.

  *Gradient with respect to the logits.* Let $p = softmax(z)$ (writing $p$
  now for the model's output). Then
  $ L = -sum_i y_i log p_i, quad (partial L)/(partial z_j) = -sum_i (y_i)/(p_i) (partial p_i)/(partial z_j). $
  Substituting the softmax Jacobian $partial p_i slash partial z_j = p_i(delta_(i j) - p_j)$:
  $ (partial L)/(partial z_j) = -sum_i (y_i)/(p_i) p_i (delta_(i j) - p_j) = -sum_i y_i (delta_(i j) - p_j) = -y_j + p_j sum_i y_i = p_j - y_j, $
  using $sum_i y_i = 1$.

  $ nabla_z L = p - y. $

  Note the cancellation: the $1 slash p_i$ from the logarithm met the $p_i$
  from the softmax and vanished. That is why the fused
  `softmax_cross_entropy` op exists --- computing the two separately performs a
  division that mathematically was never needed and numerically loses
  precision.
]

#soln("32.6")[
  *Parent entropy.* 60 positive, 40 negative, so $p = 0.6$:
  $ Hent("parent") = -0.6 log_2 0.6 - 0.4 log_2 0.4 = 0.442 + 0.529 = 0.971 "bits". $

  *Children.* Left: 45 positive, 5 negative, so $p = 0.9$:
  $ Hent("left") = -0.9 log_2 0.9 - 0.1 log_2 0.1 = 0.137 + 0.332 = 0.469. $
  Right: the remaining 15 positive and 35 negative, so $p = 0.3$:
  $ Hent("right") = -0.3 log_2 0.3 - 0.7 log_2 0.7 = 0.521 + 0.360 = 0.881. $

  *Weighted child entropy* (both children have 50 of the 100 examples):
  $ 0.5(0.469) + 0.5(0.881) = 0.675. $

  *Information gain:*
  $ "IG" = 0.971 - 0.675 = 0.296 "bits". $

  So this split resolves about 0.3 of the 0.97 bits of uncertainty in the
  label --- roughly 30%. A decision tree would compare this against every
  other candidate split and take the largest.
]

#soln("32.7")[
  From the definition,
  $
  I(X;Y) &= sum_(x,y) p(x,y) log (p(x,y))/(p(x)p(y)) \
  &= sum_(x,y) p(x,y) log (p(x|y))/(p(x)) \
  &= sum_(x,y) p(x,y) log p(x|y) - sum_(x,y) p(x,y) log p(x) \
  &= -Hent(X|Y) + Hent(X),
  $
  using $p(x,y) slash p(y) = p(x|y)$ in the second line and marginalising over
  $y$ in the last term.

  *Why symmetry survives.* The *defining* expression
  $p(x,y) slash (p(x)p(y))$ is manifestly symmetric in $x$ and $y$, so
  $I(X;Y) = I(Y;X)$ immediately.

  But $Hent(X|Y) != Hent(Y|X)$ in general --- they are not even measured
  against the same total. What is symmetric is the *reduction*:
  $ Hent(X) - Hent(X|Y) = Hent(Y) - Hent(Y|X). $
  Both sides equal $Hent(X) + Hent(Y) - Hent(X,Y)$, which is visibly
  symmetric. The shared information is symmetric even though the amounts of
  private information are not --- exactly like the overlap of two sets of
  different sizes.
]

#soln("32.8")[
  *Perplexity* is $e^Hent$ when the cross-entropy is in nats.

  $ e^(3.2) = 24.53, quad e^(2.9) = 18.17. $

  *Improvement factor:* $24.53 slash 18.17 = 1.35$. The better model behaves
  as though it were choosing among 18 equally likely options rather than 25.

  *Compressed size.* The number of bits needed per token is proportional to
  the cross-entropy, so the ratio of compressed sizes is
  $ 2.9/3.2 = 0.906. $
  The compressed text would be about *9.4% smaller*.

  Worth noticing the scale mismatch: a 35% improvement in perplexity buys only
  a 9% reduction in file size. Perplexity is exponential in the thing that
  actually costs bits, so it exaggerates progress --- which is one reason
  cross-entropy (or bits-per-byte) is the more honest metric to report.
]

== Chapter 33 --- Numerical Computing

#soln("33.1")[
  *(a) Directly, to 4 significant figures.*
  $sqrt(10001) = 100.0$ and $sqrt(10000) = 100.0$, so the difference is
  $0.000$.

  *Every significant digit has been destroyed.* The two operands agreed to
  more digits than we carried, so the difference carried none.

  *(b) By the conjugate.*
  $ sqrt(10001) - sqrt(10000) = 1/(sqrt(10001) + sqrt(10000)) = 1/(100.0 + 100.0) = 1/200.0 = 0.005000. $

  The true value is $0.00499999 dots$, so this is correct to all four figures
  carried.

  *The lesson.* The two expressions are algebraically identical. One is a
  subtraction of nearly equal numbers; the other has no subtraction at all.
  The rearrangement did not add precision --- it avoided throwing precision
  away.
]

#soln("33.2")[
  $1 slash 10 = 1 slash (2 times 5)$, and $5$ is not a power of $2$. By the
  proposition of Chapter 1 --- a fraction has a terminating expansion in base
  $b$ iff its denominator's prime factors all divide $b$ --- $1 slash 10$ has a
  *repeating* binary expansion:
  $ 0.1_(10) = 0.0overline(0011)_2. $

  A double stores 53 significant bits, so the expansion must be truncated and
  rounded, giving a value very slightly *above* $1 slash 10$. The same happens
  for $0.2$.

  Adding the two rounded values and rounding again gives a result that is not
  the nearest double to $0.3$:
  $ "0.1 + 0.2" = 0.3000000000000000444089209850062616169452667236328125. $

  To 20 digits, $0.30000000000000004441$.

  Meanwhile the double nearest $0.3$ is $0.299999999999999988898 dots$. The two
  differ by one unit in the last place, so `==` returns false.

  Nothing went wrong: three exact roundings produced a result one ulp away
  from the rounding of the exact answer. That is the best that can be
  guaranteed.
]

#soln("33.3")[
  $f(x) = 1 slash (1-x)$, so $f'(x) = 1 slash (1-x)^2$.

  $ kappa_f (x) = abs((x f'(x))/(f(x))) = abs( (x slash (1-x)^2)/(1 slash (1-x)) ) = abs(x/(1-x)). $

  At $x = 0.999$:
  $ kappa = 0.999/0.001 = 999 approx 10^3. $

  *Expect to lose about 3 decimal digits.* With double precision (about 16
  digits) you would retain roughly 13 --- acceptable. But the condition number
  grows without bound as $x -> 1$: at $x = 1 - 10^(-15)$ it is $10^(15)$ and
  essentially nothing survives.

  This is a property of the *function near the pole*, not of any algorithm. No
  implementation of $1 slash (1-x)$ can do better, because the true answer
  genuinely does depend that sensitively on the input.
]

#soln("33.4")[
  Values $1.0$, $10^(-16)$, $10^(-16)$, with
  $epsilon = 2^(-52) approx 2.22 times 10^(-16)$ (the gap just above 1).

  *Naive summation.* $1.0 + 10^(-16)$: the addend is smaller than half an ulp
  ($1.11 times 10^(-16)$), so it rounds away entirely and the sum stays
  $1.0$. The same happens again. *Result: $1.0$.*

  *Kahan.*
  #table(
    columns: 5, inset: 6pt, stroke: 0.4pt + luma(180), align: (center, left, left, left, left),
    table.header([step], [$y = x - c$], [$t = "sum" + y$], [$c = (t - "sum") - y$], [sum]),
    [$x=1.0$], [$1.0$], [$1.0$], [$0$], [$1.0$],
    [$x=10^(-16)$], [$10^(-16)$], [$1.0$ (rounded)], [$0 - 10^(-16) = -10^(-16)$], [$1.0$],
    [$x=10^(-16)$], [$2 times 10^(-16)$], [$1 + epsilon$], [$epsilon - 2 times 10^(-16) = 2.2 times 10^(-17)$], [$1 + epsilon$],
  )

  On the second step the addend is lost --- but the compensation $c$ *records
  exactly how much was lost*. On the third step that recorded loss is added
  back, making the effective addend $2 times 10^(-16)$, which now exceeds half
  an ulp and rounds *up*.

  *Result: $1.0000000000000002$*, the correctly rounded answer.

  Kahan recovered a quantity that naive summation discarded twice. Over
  millions of terms this is the difference between a usable answer and drift.
]

#soln("33.5")[
  $y' = y$, $y(0) = 1$, $h = 0.5$. Exact: $y(1) = e = 2.718282$.

  *RK4, step 1.*
  $ k_1 = 1, quad k_2 = 1 + 0.25 = 1.25, quad k_3 = 1 + 0.25(1.25) = 1.3125, quad k_4 = 1 + 0.5(1.3125) = 1.65625. $
  $ y_1 = 1 + (0.5)/6 (1 + 2.5 + 2.625 + 1.65625) = 1 + 0.083333(7.78125) = 1.648438. $
  (Exact $e^(0.5) = 1.648721$.)

  *RK4, step 2.* With $y = 1.648438$:
  $ k_1 = 1.648438, quad k_2 = 2.060547, quad k_3 = 2.163574, quad k_4 = 2.730225, $
  $ y_2 = 1.648438 + 0.083333(12.826904) = 2.717346. $

  *Forward Euler.* $y_1 = 1 + 0.5(1) = 1.5$; $y_2 = 1.5 + 0.5(1.5) = 2.25$.

  #table(
    columns: 3, inset: 6pt, stroke: 0.4pt + luma(180), align: (left, center, center),
    table.header([Method], [$y(1)$], [error]),
    [Exact], [$2.718282$], [---],
    [RK4, 2 steps], [$2.717346$], [$9.4 times 10^(-4)$],
    [Euler, 2 steps], [$2.250000$], [$4.7 times 10^(-1)$],
  )

  RK4 is *500 times* more accurate for the same number of steps, at 4 times
  the function evaluations. Even per evaluation it wins by two orders of
  magnitude, and the gap widens as $h$ shrinks --- $h^4$ against $h$.
]

#soln("33.6")[
  $y' = -1000 y$.

  *Forward Euler.* $y_(n+1) = y_n + h(-1000 y_n) = (1 - 1000h) y_n$.

  The iteration decays iff the amplification factor has modulus below 1:
  $ abs(1 - 1000 h) <= 1 quad arrow.r.double quad 0 <= 1000 h <= 2 quad arrow.r.double quad h <= 0.002. $

  Any larger step and the numerical solution oscillates with *growing*
  amplitude, while the true solution decays smoothly to zero. The instability
  is entirely an artefact of the method.

  *Backward Euler.* $y_(n+1) = y_n + h(-1000 y_(n+1))$, so
  $ y_(n+1) = (y_n)/(1 + 1000 h). $
  For every $h > 0$ the factor $1 slash (1 + 1000h)$ lies strictly between 0
  and 1, so the iteration decays. *Unconditionally stable.*

  This is the whole argument for implicit methods on stiff problems: the
  explicit method's step size is dictated by the *fastest* timescale even when
  that mode has long since decayed and you do not care about it. The implicit
  method's step is dictated only by the accuracy you want.
]

#soln("33.7")[
  *Double precision inputs, 10 accurate digits.* With
  $kappa = 10^7$, the relative error in the solution can be $10^7$ times the
  relative error in the input. Losing 7 digits from 10 leaves
  *about 3 trustworthy digits*.

  *`float32` inputs.* Single precision carries about 7 decimal digits.
  Losing 7 leaves *none*. The computed solution would be numerical noise ---
  it would have the right shape and no correct digits.

  The general rule: you need input precision *exceeding* $log_10 kappa$ plus
  however many digits you actually want out. For $kappa = 10^7$ and a demand
  of 6 good digits you need 13 digits in, which rules out `float32` entirely
  and leaves double precision with little margin.

  This is why "just use `float32`, it is twice as fast" is a decision that
  requires knowing $kappa$ first.
]

#soln("33.8")[
  *Gauss--Legendre.* An $n$-node rule is exact for polynomials of degree up to
  $2n - 1$. For $x^7$ we need $2n - 1 >= 7$, so $n >= 4$.

  *Four nodes suffice*, and give the exact answer $1 slash 8$.

  *Simpson.* Simpson is exact for cubics only. Its composite error is
  $ E approx ((b-a) h^4)/180 f^((4))(xi), quad f^((4))(x) = 840 x^3, thin max = 840. $
  To reach machine precision, $10^(-16)$:
  $ (h^4 times 840)/180 <= 10^(-16) quad arrow.r.double quad h^4 <= 2.1 times 10^(-17) quad arrow.r.double quad h <= 2.1 times 10^(-5), $
  needing about $48,!000$ subintervals, hence roughly $10^5$ function
  evaluations.

  *The gap: 4 evaluations against about 100,000.*

  *Why.* Simpson fixes the nodes at even spacing and optimises only the $n$
  weights, buying exactness to degree $n - 1$. Gauss optimises the nodes *and*
  the weights --- $2n$ free parameters --- buying exactness to degree
  $2n - 1$. For a smooth integrand that doubling of the exactness degree is
  worth an enormous amount, and it costs nothing but giving up the even grid.
]

== Chapter 34 --- Optimization

#soln("34.1")[
  *Convex.* $f(x) = x^4$ has $f''(x) = 12 x^2 >= 0$ for all $x$, so $f$ is
  convex. (It is even *strictly* convex: $f'' > 0$ except at the single point
  $x=0$, which is not enough to create a flat segment.)

  *Not strongly convex.* $mu$-strong convexity requires
  $f''(x) >= mu > 0$ *everywhere*. Here $f''(0) = 0$, so no positive $mu$
  works.

  *Where it fails, and why it matters.* The failure is exactly at the
  minimiser. Near $x = 0$ the function is extraordinarily flat --- it looks
  like $x^4$, not like a parabola --- so the gradient carries almost no
  information about how far you are from the optimum.

  Consequently gradient descent on $x^4$ converges *sublinearly*: the error
  decays like $1 slash sqrt(k)$ rather than geometrically. Strong convexity is
  precisely the hypothesis that buys the linear rate of Chapter 34's theorem,
  and this is what its absence costs.
]

#soln("34.2")[
  *Maximum of convex functions is convex.* Let $h = max(f,g)$ with $f, g$
  convex. For $t in [0,1]$:
  $
  h(t x + (1-t)y) &= max( f(t x + (1-t)y), thin g(t x + (1-t)y) ) \
  &<= max( t f(x) + (1-t)f(y), thin t g(x) + (1-t)g(y) ) \
  &<= t max(f(x),g(x)) + (1-t) max(f(y),g(y)) = t h(x) + (1-t) h(y).
  $
  (The last step uses $t f(x) <= t h(x)$ and similarly for the other three
  terms.)

  *Minimum need not be.* Take $f(x) = x^2$ and $g(x) = (x-2)^2$, both convex.
  Then $h = min(f,g)$ equals $x^2$ for $x <= 1$ and $(x-2)^2$ for $x >= 1$,
  with a *downward* kink at $x = 1$.

  Check convexity at the midpoint of $0$ and $2$:
  $ h(1) = 1, quad "but" quad (h(0) + h(2))/2 = (0+0)/2 = 0. $
  Since $h(1) > 0$, the chord lies *below* the function. Not convex.

  This generalises: an arbitrary maximum of convex functions is convex (which
  is why the pointwise supremum of linear functions --- the support function
  --- is always convex), while minima are not. It is also why "the best of
  several models" is a hard object to optimise over.
]

#soln("34.3")[
  $f(x,y) = x^2 + 10 y^2$.

  $ H = mat(2, 0; 0, 20), quad lambda_min = 2, thin lambda_max = 20, quad kappa = 10. $

  *Largest stable learning rate:* $eta < 2 slash lambda_max = 0.1$.

  *At $eta = 0.05$.* The updates decouple:
  $ x_(k+1) = (1 - 0.05 times 2) x_k = 0.9 x_k, quad y_(k+1) = (1 - 0.05 times 20) y_k = 0 dot y_k. $

  From $(1,1)$: $(0.9, 0)$, then $(0.81, 0)$.

  Here $eta = 0.05$ happens to be *exactly* $1 slash lambda_max$, which
  annihilates the $y$ component in a single step --- a lucky accident of the
  numbers. The point that remains: the $x$ component decays by only 0.9 per
  step, needing about 44 iterations to reach $10^(-2)$. *The steep direction
  is solved instantly and the shallow one crawls.*

  *The classic zigzag* appears at a rate closer to the maximum. At
  $eta = 0.09$:
  $ x "factor" = 1 - 0.18 = 0.82, quad y "factor" = 1 - 1.8 = -0.8, $
  so from $(1,1)$ the iterates are $(0.82, -0.8)$, $(0.672, 0.64)$,
  $(0.551, -0.512)$ --- oscillating across the valley in $y$ while creeping
  along it in $x$. Exactly the picture in the chapter, and it is caused
  entirely by $kappa = 10$.
]

#soln("34.4")[
  $f(x) = (1 slash 2) x^T A x$ has $nabla f = A x$, so the iteration is
  $ x_(k+1) = x_k - eta A x_k = (I - eta A) x_k. $

  Diagonalise: $A = Q Lambda Q^T$ with $Q$ orthogonal (spectral theorem,
  Chapter 23). Writing $z_k = Q^T x_k$, the iteration decouples completely:
  $ z_(k+1, i) = (1 - eta lambda_i) z_(k,i), $
  so $z_(k,i) = (1 - eta lambda_i)^k z_(0,i)$.

  This tends to zero for every component iff
  $ abs(1 - eta lambda_i) < 1 quad "for all" i quad arrow.l.r.double quad 0 < eta lambda_i < 2 quad "for all" i. $

  Since all $lambda_i > 0$ (positive definite), the binding constraint is the
  largest:
  $ 0 < eta < 2/(lambda_max). $

  And the *rate* is governed by the worst factor,
  $max_i abs(1 - eta lambda_i)$, which is minimised at
  $eta^* = 2 slash (lambda_min + lambda_max)$, giving the contraction factor
  $(kappa - 1) slash (kappa + 1)$. Large $kappa$ pushes that towards 1 --- the
  quantitative version of "ill-conditioning makes gradient descent slow".
]

#soln("34.5")[
  Write the constraint in standard form $g(x,y) = 2 - x - y <= 0$, and form
  $ cal(L) = x^2 + y^2 + lambda(2 - x - y), quad lambda >= 0. $

  *Stationarity:* $2x - lambda = 0$ and $2y - lambda = 0$, so
  $x = y = lambda slash 2$.

  *Complementary slackness:* $lambda(2 - x - y) = 0$.

  *Case $lambda = 0$.* Then $x = y = 0$, but $g(0,0) = 2 > 0$ --- infeasible.
  Rejected.

  *Case constraint active.* Then $x + y = 2$, so with $x = y$ we get
  $x = y = 1$ and $lambda = 2$.

  Check the remaining conditions: primal feasibility ✓ ($1 + 1 = 2$), dual
  feasibility ✓ ($lambda = 2 >= 0$). Since the problem is convex, KKT is
  sufficient, so this is the global minimum.

  *Answer:* $(1,1)$ with value $2$; the constraint is *active*, with
  multiplier $lambda = 2$.

  *Reading the multiplier.* Relaxing the constraint to $x + y >= 2 - epsilon$
  would reduce the optimal value by about $2 epsilon$. Indeed the optimum for
  a right-hand side $c$ is $c^2 slash 2$, whose derivative at $c = 2$ is
  $2$. ✓ The shadow price is exact.
]

#soln("34.6")[
  $f(x) = e^x - 2x$, $f'(x) = e^x - 2$, $f''(x) = e^x$. The minimiser is
  $x^* = ln 2 = 0.693147$.

  *Newton*, $x_(n+1) = x_n - (e^(x_n) - 2) slash e^(x_n)$:
  $
  x_1 &= 0 - (1-2)/1 = 1, \
  x_2 &= 1 - (e - 2)/e = 1 - 0.264 = 0.736.
  $

  *Gradient descent* at $eta = 0.5$, $x_(n+1) = x_n - 0.5(e^(x_n) - 2)$:
  $
  x_1 &= 0 - 0.5(-1) = 0.5, \
  x_2 &= 0.5 - 0.5(1.6487 - 2) = 0.5 + 0.176 = 0.676.
  $

  #table(
    columns: 3, inset: 6pt, stroke: 0.4pt + luma(180), align: (left, center, center),
    table.header([After 2 steps], [$x_2$], [error]),
    [Newton], [$0.736$], [$0.043$],
    [Gradient descent], [$0.676$], [$0.017$],
  )

  *Gradient descent is closer* --- which is not what the theory advertises, and
  is worth understanding.

  Two reasons. First, Newton's first step *overshot* badly: from $x_0 = 0$ the
  quadratic model is a poor fit and the step lands at $1$, well past the
  minimum. Newton's guarantees are *local*.

  Second, and more amusing: $f''(x^*) = e^(ln 2) = 2$, so the ideal Newton
  scaling near the optimum is $1 slash f'' = 0.5$ --- exactly the learning rate
  chosen. For this problem, gradient descent at $eta = 0.5$ *is* Newton's
  method near the optimum.

  A third Newton step gives $0.694$ (error $9 times 10^(-4)$) and a fourth
  essentially machine precision; gradient descent continues to halve its error
  each step. The quadratic advantage appears once you are close, and not
  before.
]

#soln("34.7")[
  With $A = U Sigma V^T$, the ridge solution is
  $
  hat(x) &= (A^T A + lambda I)^(-1) A^T b \
  &= (V Sigma^T Sigma V^T + lambda V V^T)^(-1) V Sigma^T U^T \
  &= V (Sigma^T Sigma + lambda I)^(-1) Sigma^T U^T b.
  $
  The middle factor is diagonal with entries
  $ (sigma_i)/(sigma_i^2 + lambda), $
  against $1 slash sigma_i$ for ordinary least squares ($lambda = 0$).

  *Behaviour of the filter.*
  - For $sigma_i^2 gt.double lambda$: the factor is
    $approx 1 slash sigma_i$. Directions where the data is informative are
    essentially untouched.
  - For $sigma_i^2 lt.double lambda$: the factor is
    $approx sigma_i slash lambda -> 0$. Directions where the data carries
    almost nothing are *suppressed* rather than amplified.

  *The directions with $sigma_i approx 0$* are exactly where plain least
  squares divides by nearly zero and produces enormous, noise-driven
  coefficients. Ridge replaces that blow-up with a graceful decay to zero: it
  declines to make claims about directions the data cannot see.

  Compare the truncated pseudoinverse (Chapter 25), which does the same thing
  with a hard cutoff. Ridge is the smooth version, and the smoothness is why
  it is differentiable and easy to tune.
]

#soln("34.8")[
  *Newton is impossible.* The Hessian of a function of $10^7$ parameters has
  $10^(14)$ entries. In `float64` that is $8 times 10^(14)$ bytes ---
  *800 terabytes*, for one matrix, at one point. Solving with it would cost
  $O(n^3) = 10^(21)$ operations. Both numbers are off by many orders of
  magnitude from feasible, and no amount of hardware closes the gap.

  *L-BFGS is marginal.* It stores $m approx 10$ pairs of $n$-vectors, so
  $20 times 10^7 times 8$ bytes $= 1.6$ GB --- large but not absurd, and each
  iteration is $O(m n)$. The real obstacles are elsewhere: L-BFGS assumes a
  *deterministic, smooth* objective, and it uses a line search. Minibatch
  gradients are stochastic, so the curvature estimates built from successive
  noisy gradients are unreliable, and a line search on a noisy objective is
  meaningless. L-BFGS is excellent for full-batch smooth problems and poorly
  suited to SGD-style training.

  *What Adam approximates.* Adam maintains two running averages ---
  $m_t$ of the gradient and $v_t$ of the *squared* gradient, both
  $n$-vectors, so $160$ MB total --- and steps with
  $ x_(t+1) = x_t - eta (hat(m)_t)/(sqrt(hat(v)_t) + epsilon). $

  Dividing each coordinate by the root-mean-square of its recent gradients is
  a *diagonal preconditioner*: it approximates multiplying by
  $"diag"(H)^(-1 slash 2)$, rescaling each coordinate so that they all have
  comparable effective curvature.

  In the language of the chapter, it is trying to reduce the *effective
  condition number* --- the same goal as Newton's method, achieved with $O(n)$
  memory instead of $O(n^2)$ by throwing away every off-diagonal coupling.
  That approximation is crude, and for problems where the important curvature
  is off-diagonal it helps little. It is nonetheless the best cost--benefit
  trade anyone has found at this scale.
]

== Chapter 35 --- Geometry for Graphics and Simulation

#soln("35.1")[
  $
  T = mat(1,0,0,2; 0,1,0,3; 0,0,1,4; 0,0,0,1), quad
  S = mat(2,0,0,0; 0,2,0,0; 0,0,2,0; 0,0,0,1).
  $

  $
  T S = mat(2,0,0,2; 0,2,0,3; 0,0,2,4; 0,0,0,1), quad
  S T = mat(2,0,0,4; 0,2,0,6; 0,0,2,8; 0,0,0,1).
  $

  *Reading them.* Remember the rightmost factor acts first.

  $T S$: *scale, then translate.* The object doubles in size about the origin
  and then moves by $(2,3,4)$.

  $S T$: *translate, then scale.* The object moves by $(2,3,4)$ and then
  everything --- including that displacement --- doubles, so the net
  translation is $(4,6,8)$.

  The difference is the whole reason transform order matters in a scene graph.
  Scaling after translating scales the object's *position* as well as its
  size, which is almost never what an artist means.
]

#soln("35.2")[
  $ R_z (theta) = mat(cos theta, -sin theta, 0; sin theta, cos theta, 0; 0,0,1). $

  *Orthogonal.* The columns are
  $(cos theta, sin theta, 0)$, $(-sin theta, cos theta, 0)$, $(0,0,1)$. Each
  has norm 1 (Pythagorean identity) and the pairwise dot products are
  $-cos theta sin theta + sin theta cos theta = 0$ and $0$. ✓

  *Determinant.* Expanding along the last row:
  $det = 1 dot (cos^2 theta + sin^2 theta) = 1$. ✓

  *Eigenvalues.* The characteristic polynomial factors as
  $ (1 - lambda) [ (cos theta - lambda)^2 + sin^2 theta ], $
  giving $lambda = 1$ and $lambda = cos theta plus.minus i sin theta = e^(plus.minus i theta)$.

  *Interpretation.* The eigenvalue $1$ has eigenvector $(0,0,1)$ --- the
  rotation *axis*, the one direction left fixed (Euler's theorem).

  The complex pair $e^(plus.minus i theta)$ describes the action in the
  $x y$-plane, where there is no real invariant direction. By Chapter 6,
  multiplication by $e^(i theta)$ *is* rotation by $theta$ --- so the rotation
  angle is sitting in the argument of the eigenvalue, and the modulus being 1
  says no stretching occurs.
]

#soln("35.3")[
  *For a rotation.* $M$ orthogonal means $M^(-1) = M^T$, so
  $ (M^(-1))^T = (M^T)^T = M. $
  The normal transform rule and the point transform rule coincide, and no
  special handling is needed. This is why the bug stays hidden in
  rotation-only code.

  *A non-uniform scale where it fails.* Take $S = diag(2,1,1)$ and the plane
  $x + y = 0$, whose normal is $n = (1,1,0)$.

  Points on the plane have the form $(t, -t, z)$. Applying $S$ gives
  $(2t, -t, z)$, which satisfies $x slash 2 + y = 0$ --- a plane with normal
  proportional to $(1, 2, 0)$.

  Now compare:
  $ S n = (2,1,0) quad "(wrong)", quad (S^(-1))^T n = diag(1/2,1,1)(1,1,0) = (1/2, 1, 0) prop (1,2,0) quad "(right)". $

  Transforming the normal by $S$ gives $(2,1,0)$, which is *not* perpendicular
  to the transformed plane. Visually this shows up as lighting that is subtly
  wrong on any non-uniformly scaled object --- highlights in the wrong place,
  surfaces that look bent.
]

#soln("35.4")[
  Rotation by $90 degree$ about the $y$-axis, so $u = (0,1,0)$ and
  $theta = pi slash 2$:
  $ q = cos(pi/4) + sin(pi/4) j = (sqrt(2))/2 (1 + j) approx 0.7071 + 0.7071 j. $

  *Rotating $(1,0,0)$.* Treating $v = i$ and computing $q v q^(-1)$ (with
  $q^(-1) = overline(q)$ since $norm(q) = 1$):
  $ q i overline(q) = -k, $
  i.e. the point $(0,0,-1)$. ✓ Correct: a right-handed $90 degree$ rotation
  about $+y$ sends $hat(x)$ to $-hat(z)$.

  *$q$ and $-q$ agree.* Substituting $-q$:
  $ (-q) v (-q)^(-1) = (-q) v (-q^(-1)) = (-1)(-1) q v q^(-1) = q v q^(-1). $
  The two sign flips cancel exactly, because $q$ appears once on each side.

  So the map from unit quaternions to rotations is *two-to-one*. Practically
  this matters in one place: when interpolating between two orientations, take
  the dot product of the quaternions first and negate one of them if it is
  negative --- otherwise slerp takes the long way round the sphere, and the
  object spins through nearly $360 degree$ to reach a nearby orientation.
]

#soln("35.5")[
  Control points $P_0 = (0,0)$, $P_1 = (0,1)$, $P_2 = (1,1)$, $P_3 = (1,0)$,
  at $t = 0.5$ --- so every interpolation is a midpoint.

  *Level 1.*
  $ Q_0 = (0, 0.5), quad Q_1 = (0.5, 1), quad Q_2 = (1, 0.5). $

  *Level 2.*
  $ R_0 = (0.25, 0.75), quad R_1 = (0.75, 0.75). $

  *Level 3.*
  $ B(0.5) = (0.5, thin 0.75). $

  *The curve* is a symmetric arch: it starts at $(0,0)$ heading straight up
  (towards $P_1$), turns over, and lands at $(1,0)$ heading straight down
  (away from $P_2$). Its apex is the computed point $(0.5, 0.75)$ --- note it
  does *not* reach $y = 1$, since the curve is pulled towards but not through
  its interior control points, and always stays inside their convex hull.

  The two halves produced by the algorithm --- control points
  $P_0, Q_0, R_0, B(0.5)$ and $B(0.5), R_1, Q_2, P_3$ --- are exactly the two
  sub-curves, which is the subdivision property that makes adaptive rendering
  work.
]

#soln("35.6")[
  Ray $p(t) = t d$ with $d = (1,1,1) slash sqrt(3)$, sphere centre
  $c = (3,3,3)$, radius $2$.

  Substituting into $norm(p - c)^2 = 4$:
  $ t^2 - 2t (d dot c) + norm(c)^2 - 4 = 0. $
  Here $d dot c = 9 slash sqrt(3) = 3 sqrt(3) approx 5.196$ and
  $norm(c)^2 = 27$, so
  $ t^2 - 6 sqrt(3) thin t + 23 = 0. $

  Discriminant: $108 - 92 = 16 > 0$, so two intersections.
  $ t = (6 sqrt(3) plus.minus 4)/2 = 3 sqrt(3) plus.minus 2 approx 3.196 "and" 7.196. $

  The points are $t d$:
  $ approx (1.845, 1.845, 1.845) quad "and" quad (4.155, 4.155, 4.155). $

  *Check:* the distance from $(3,3,3)$ to the first point is
  $sqrt(3) times 1.155 = 2.00$. ✓

  In a renderer you take the *smaller positive* root (the near hit), and the
  sign of the discriminant is the entire hit test --- negative means miss, zero
  means tangent.
]

#soln("35.7")[
  Triangle $A = (0,0)$, $B = (4,0)$, $C = (0,3)$; point $P = (2,1)$.

  Since $A$ is the origin, $P = alpha A + beta B + gamma C$ reduces to
  $ (2,1) = beta(4,0) + gamma(0,3), $
  so $4 beta = 2$ giving $beta = 1 slash 2$, and $3 gamma = 1$ giving
  $gamma = 1 slash 3$. Then
  $ alpha = 1 - beta - gamma = 1 - 1/2 - 1/3 = 1/6. $

  $ (alpha, beta, gamma) = (1/6, thin 1/2, thin 1/3). $

  All three are *nonnegative* (and they sum to 1), so *$P$ is inside* the
  triangle.

  As a check by areas: the whole triangle has area 6, and the sub-triangle
  opposite $A$ (namely $P B C$) should have area $alpha times 6 = 1$. Indeed
  $P B C$ has vertices $(2,1), (4,0), (0,3)$ and area
  $(1 slash 2) abs(det mat(2, -2; -1, 2)) = (1 slash 2)(2) = 1$. ✓
]

#soln("35.8")[
  *Why entrywise interpolation fails.* The rotation matrices form
  $"SO"(3)$, which is a *curved manifold* --- a three-dimensional surface
  sitting inside the nine-dimensional space of $3 times 3$ matrices, cut out
  by the six equations $Q^T Q = I$ plus $det Q = 1$.

  A straight-line interpolation $(1-t)R_1 + t R_2$ is a *chord* through that
  ambient space, and a chord of a curved surface leaves the surface. The
  result generally has columns that are neither unit length nor mutually
  orthogonal: it is not a rotation, and applying it will shear and shrink the
  object.

  The pathological case makes it vivid: in two dimensions interpolate
  $R(0) = I$ and $R(pi) = -I$ at $t = 0.5$. You get the *zero matrix* ---
  the object collapses to a point halfway through the animation.

  *What slerp does instead.* Represent each orientation as a unit quaternion
  and interpolate along the *great circle* joining them on the unit sphere in
  $RR^4$:
  $ "slerp"(q_1, q_2, t) = (sin((1-t)Omega) thin q_1 + sin(t Omega) thin q_2)/(sin Omega), quad cos Omega = q_1 dot q_2. $

  Every intermediate value is a unit quaternion, hence a genuine rotation. And
  because the path is a geodesic traversed at constant speed, the *angular
  velocity is constant* --- the object turns smoothly rather than speeding up
  and slowing down.

  (Two practical notes: negate $q_2$ if $q_1 dot q_2 < 0$, to take the short
  way round the double cover; and fall back to linear interpolation when
  $Omega$ is tiny, since $sin Omega$ in the denominator is then a division by
  nearly zero --- a Chapter 33 problem inside a Chapter 35 formula.)
]

== Chapter 36 --- Backpropagation, Derived

#soln("36.1")[
  Let $h = W_1 x in RR^p$, $a = phi(h)$, $y = W_2 a in RR^m$, and
  $cal(L) = norm(y - t)^2$.

  *Loss gradient.* $g = partial cal(L) slash partial y = 2(y - t)$, shape
  $m times 1$.

  *Output weights.* By the linear-layer rule with input $a$:
  $ (partial cal(L))/(partial W_2) = g thin a^T, quad (m times 1)(1 times p) = m times p. ✓ $

  *Backpropagate.*
  $ (partial cal(L))/(partial a) = W_2^T g, quad (p times m)(m times 1) = p times 1, $
  $ delta = (W_2^T g) circle.small phi'(h), quad p times 1. $

  *Input weights.*
  $ (partial cal(L))/(partial W_1) = delta thin x^T, quad (p times 1)(1 times n) = p times n. ✓ $

  Every intermediate is a vector; the only matrices produced are the two
  gradients themselves, each the same shape as its weight matrix. That is the
  signature of reverse mode done correctly, and checking the shapes is the
  fastest way to catch an error.
]

#soln("36.2")[
  *Collapse.* Composing $L$ affine maps:
  $ W_L (W_(L-1) ( dots.c (W_1 x) dots.c )) = (W_L W_(L-1) dots.c W_1) x = W_"eff" x, $
  since matrix multiplication is associative. The product $W_"eff"$ is a
  single matrix of the same shape as the composite map, so the network is
  exactly equivalent to one linear layer.

  (With biases the same holds for affine maps: the composition is affine, with
  a single effective weight and a single effective bias.)

  *Parameter count for $L = 5$, width 100.* The five layers hold
  $5 times 100 times 100 = 50,!000$ parameters. The equivalent single layer
  needs $100 times 100 = 10,!000$.

  *$40,!000$ parameters are wasted* --- they add memory, compute, and
  optimisation difficulty while adding exactly zero expressive power.

  Worth noting they are not entirely inert: the *parameterisation* differs, so
  gradient descent takes a different path through a different landscape (this
  is the subject of "implicit regularisation of deep linear networks"). But
  the set of functions representable is identical.
]

#soln("36.3")[
  *Sigmoid.* $sigma'(z) = sigma(z)(1 - sigma(z))$ is maximised at
  $z = 0$, where it equals $0.25$. So each layer's diagonal Jacobian
  contributes a factor of at most $0.25$.

  With $norm(W) approx 1$, the gradient at layer 1 relative to layer 50 is at
  most
  $ 0.25^49 = 10^(49 log_10 0.25) = 10^(-29.5) approx 3 times 10^(-30). $

  That is not "small"; it is *below the smallest normal double*
  ($10^(-308)$ is the limit, so it survives, but in `float32`
  --- minimum around $10^(-38)$ --- it is within a factor of $10^8$ of
  flushing to zero). In practice the early layers receive no usable signal at
  all and simply do not train.

  *ReLU.* $phi'(z) = 1$ on the active half and $0$ on the inactive half. On
  the active path there is *no* systematic shrinkage: with $norm(W) approx 1$
  the product stays $O(1)$ across depth.

  The caveat is that roughly half the units are inactive at initialisation, so
  the effective variance is halved per layer --- which is precisely why He
  initialisation uses $Var(W_(i j)) = 2 slash n_"in"$ rather than
  $1 slash n_"in"$. The factor of 2 exactly compensates for ReLU discarding
  half its input.

  That one factor of 2 is the difference between a 50-layer network that
  trains and one that does not.
]

#soln("36.4")[
  For a residual block $a = x + F(x)$, differentiate termwise:
  $ (partial a)/(partial x) = I + (partial F)/(partial x). $

  *Why the product resists both pathologies.* Over $L$ blocks the gradient
  carries a factor
  $ product_(ell=1)^L (I + J_ell), quad J_ell = (partial F_ell)/(partial x). $
  Expanding, this is
  $ I + sum_ell J_ell + sum_(ell < m) J_m J_ell + dots.c $

  The leading term is the *identity*. So there is always a path from the loss
  back to every layer that passes through no multiplication at all --- the
  gradient cannot be attenuated to nothing by a long product, because one term
  of the expansion never multiplies anything.

  And if the $J_ell$ are individually small (as they are at initialisation,
  when $F$ is initialised near zero), the whole product stays close to $I$
  rather than exploding.

  This is why residual connections were the change that made hundred-layer and
  thousand-layer networks trainable, and why essentially every deep
  architecture since 2015 --- including every transformer --- has them. It is
  one line of calculus with an enormous consequence.
]

#soln("36.5")[
  Dual numbers for $f(x) = x^2 sin x$ at $x = 2$. Carry the pair
  $(2, 1)$ --- the value and its derivative with respect to $x$.

  *Step 1: $u = x dot x$.* By the product rule built into the arithmetic,
  $ u = (2 times 2, thin 2 times 1 + 1 times 2) = (4, thin 4). $

  *Step 2: $v = sin x$.* By the chain rule for the primitive $sin$,
  $ v = (sin 2, thin cos 2 times 1) = (0.909297, thin -0.416147). $

  *Step 3: $f = u dot v$.*
  $
  f &= (4 times 0.909297, thin 4 times (-0.416147) + 4 times 0.909297) \
    &= (3.637190, thin -1.664588 + 3.637190) = (3.637190, thin 1.972602).
  $

  *Check analytically.* $f'(x) = 2x sin x + x^2 cos x$, so
  $ f'(2) = 4(0.909297) + 4(-0.416147) = 3.637190 - 1.664588 = 1.972602. $ ✓

  Exact to every digit carried, with no step size and no cancellation. That is
  forward-mode automatic differentiation: overload the arithmetic, run the
  program once, read the derivative out of the second component.
]

#soln("36.6")[
  With $q, k in RR^d$ having i.i.d. entries of mean 0 and variance 1:
  $ q dot k = sum_(i=1)^d q_i k_i. $
  The terms are independent, so their variances add:
  $ Var(q dot k) = sum_(i=1)^d Var(q_i k_i). $
  For each term, $EE[q_i k_i] = EE[q_i]EE[k_i] = 0$, so
  $ Var(q_i k_i) = EE[q_i^2 k_i^2] = EE[q_i^2] EE[k_i^2] = 1 times 1 = 1. $
  Hence $Var(q dot k) = d$, and the typical magnitude of a score is
  $sqrt(d)$.

  *At $d = 4096$ with no scaling.* Typical scores are of order
  $sqrt(4096) = 64$, with the largest a few multiples of that.

  Feeding scores separated by tens of units into softmax makes it saturate
  completely: the exponentials differ by factors of $e^(64) approx 10^(28)$,
  so the output is numerically one-hot.

  Then the softmax Jacobian $diag(p) - p p^T$ is essentially the zero matrix
  (every $p_i(1-p_i) approx 0$), and *no gradient flows back through the
  attention weights at all*. The model cannot learn what to attend to; it is
  stuck with whatever its initialisation happened to pick.

  Dividing by $sqrt(d)$ restores unit-variance scores, keeping softmax in the
  regime where its derivative is non-negligible. One line of variance
  arithmetic, and the architecture works.
]

#soln("36.7")[
  With $Q in RR^(n times d)$, $K in RR^(m times d)$, $V in RR^(m times d_v)$:

  + *$Q K^T$*: an $(n times d)(d times m)$ product, costing $O(n m d)$ and
    producing an $n times m$ matrix.
  + *Softmax over each row*: $O(n m)$.
  + *$times V$*: an $(n times m)(m times d_v)$ product, costing
    $O(n m d_v)$.

  In self-attention $m = n$ and $d_v approx d$, so the total is
  $ O(n^2 d). $

  *Which dominates.* Both matrix products are $O(n^2 d)$ --- they are the same
  order, and neither dominates asymptotically. What differs is that the first
  *materialises* an $n times n$ matrix, so the memory cost is $O(n^2)$, and
  for long sequences that is the binding constraint rather than the arithmetic.

  This is exactly what FlashAttention addresses: it computes the same result
  by tiling, never storing the full $n times n$ matrix, trading a little
  recomputation for a large reduction in memory traffic. The FLOP count is
  unchanged; the memory-bandwidth cost is not, and on modern hardware that is
  what determines the wall clock.
]

#soln("36.8")[
  The gradient of a composition is a product of Jacobians, and matrix
  multiplication is associative --- so you may bracket the product any way you
  like, and the cost depends entirely on the bracketing (Chapter 20,
  Exercise 7).

  *Training a network: many inputs, one output.* The chain is
  $ (partial cal(L))/(partial theta) = underbrace((partial cal(L))/(partial h_L), 1 times n_L) dot (partial h_L)/(partial h_(L-1)) dots.c (partial h_1)/(partial theta). $
  The *leftmost* factor is a row vector, because the loss is a scalar. So
  multiplying *left to right* keeps every intermediate a row vector, and every
  operation is a cheap vector--matrix product. One backward pass yields the
  gradient with respect to all $10^9$ parameters.

  Forward mode would need one pass per input direction --- $10^9$ passes.
  Reverse mode wins by that factor.

  *A simulation: one input, many outputs.* Now the *rightmost* factor is a
  column vector, because there is a single scalar parameter. Multiplying
  *right to left* keeps every intermediate a column vector, and one forward
  pass gives the sensitivity of *every* output to that one parameter.

  Reverse mode would need one pass per output.

  *The rule.* Start from the narrow end. Few outputs, many inputs: reverse.
  Few inputs, many outputs: forward. Comparable numbers: either, and the
  optimal bracketing of a general chain is a dynamic programming problem ---
  which is why some autodiff systems perform "optimal Jacobian accumulation"
  and why the general problem is NP-hard.
]
