#import "../lib.typ": *

= Several Random Variables

== Joint distributions

One variable at a time is rarely enough. The interesting questions are about
how quantities move together.

#definition(title: "joint distribution")[
  For discrete $X, Y$: the *joint pmf* $p(x,y) = PP(X=x, Y=y)$, with
  $sum_x sum_y p(x,y) = 1$.

  For continuous: the *joint pdf* $f(x,y)$ with
  $ PP((X,Y) in A) = integral.double_A f(x,y) dif x dif y. $
]

#definition(title: "marginal and conditional")[
  The *marginals* are obtained by summing (or integrating) out the other
  variable:
  $ p_X (x) = sum_y p(x,y), quad f_X (x) = integral f(x,y) dif y. $
  The *conditional* is
  $ p_(Y|X)(y | x) = (p(x,y))/(p_X (x)), quad f_(Y|X)(y|x) = (f(x,y))/(f_X (x)). $
]

#intuition(title: "marginalising is a `GROUP BY`")[
  Think of the joint distribution as a two-dimensional table of probabilities.

  The *marginal* of $X$ is the row sums --- collapse the table along $Y$.
  (The name is literal: the totals were written in the margins.) In database
  terms, `SELECT x, SUM(p) FROM joint GROUP BY x`.

  The *conditional* is one row, renormalised to sum to 1:
  `WHERE x = ... `, then divide by the row total.

  Everything in multivariate probability is one of those two operations, plus
  Bayes to swap which variable you are conditioning on.
]

#definition(title: "independence of random variables")[
  $X$ and $Y$ are *independent* if
  $ p(x,y) = p_X (x) p_Y (y) quad "for all" x,y $
  (or the same with densities). Equivalently, the joint *factors*.
]

#theorem[
  If $X$ and $Y$ are independent then $EE[X Y] = EE[X] EE[Y]$.
]

#proof[
  $ EE[X Y] = sum_x sum_y x y thin p(x,y) = sum_x sum_y x y thin p_X (x) p_Y (y) = ( sum_x x p_X (x) )( sum_y y p_Y (y) ). $
]

The converse is false, which is the subject of the next section.

== Covariance and correlation

#definition(title: "covariance")[
  $ Cov(X,Y) = EE[(X - mu_X)(Y - mu_Y)] = EE[X Y] - EE[X]EE[Y]. $
]

#definition(title: "correlation")[
  $ rho = Corr(X,Y) = (Cov(X,Y))/(sigma_X sigma_Y) in [-1,1]. $
]

#proof[
  That $abs(rho) <= 1$ is Cauchy--Schwarz (Chapter 19) applied to the inner
  product $lr(⟨ U, V ⟩) = EE[U V]$ on centred random variables. Equality holds
  iff $Y - mu_Y$ is a constant multiple of $X - mu_X$ --- that is, iff the
  relationship is exactly linear.
]

#intuition(title: "covariance is a dot product")[
  Treat centred random variables as vectors, with $EE[U V]$ as the inner
  product. Then:

  - $Cov(X,Y)$ is the dot product.
  - $Var(X) = Cov(X,X)$ is the squared norm.
  - $sigma_X$ is the length.
  - $rho$ is $cos theta$ between them.
  - *Uncorrelated means orthogonal.*

  Everything from Chapter 24 now transfers. Projecting $Y$ onto $X$ gives the
  least-squares regression line, with slope
  $Cov(X,Y) slash Var(X)$ --- literally the projection formula. The residual
  is orthogonal to $X$, which is why regression residuals are uncorrelated
  with the predictor. And $rho^2$ is the fraction of variance explained, which
  is $cos^2 theta$.

  Correlation is geometry.
]

#warning(title: "uncorrelated does not mean independent")[
  Correlation only detects *linear* relationship.

  Let $X tilde Unif(-1,1)$ and $Y = X^2$. Then $Y$ is a deterministic function
  of $X$ --- as dependent as it is possible to be. But
  $ Cov(X,Y) = EE[X^3] - EE[X]EE[X^2] = 0 - 0 = 0, $
  since odd moments of a symmetric distribution vanish. Zero correlation,
  total dependence.

  Independence implies uncorrelated. The converse holds only in special cases
  --- most importantly for *jointly normal* variables, where uncorrelated does
  imply independent. That exception is why the distinction is so easy to
  forget: in the Gaussian world it does not bite.

  Practical consequence: a correlation matrix of zeros does not license you to
  treat your features as independent. Mutual information (Chapter 32) detects
  dependence of any kind, and is the right tool when you actually need
  independence.
]

#proposition(title: "variance of a sum, in general")[
  $ Var(X + Y) = Var(X) + Var(Y) + 2 Cov(X,Y), $
  and more generally
  $ Var( sum_i a_i X_i ) = sum_i sum_j a_i a_j Cov(X_i, X_j). $
]

#proof[
  Expand $EE[((X - mu_X) + (Y - mu_Y))^2]$ and use linearity of expectation.
]

#example(title: "why diversification works, and when it stops")[
  Average $n$ measurements each with variance $sigma^2$ and pairwise
  correlation $rho$. Then
  $ Var(overline(X)) = (sigma^2)/n + ((n-1))/n rho sigma^2 arrow.r.long sigma^2 rho quad "as" n -> infinity. $

  If $rho = 0$, the variance goes to zero like $1 slash n$: averaging
  independent noise works, and this is why ensembles help and why more data
  reduces error.

  If $rho > 0$, the variance floors out at $rho sigma^2$ *no matter how many
  measurements you take*. Correlated errors cannot be averaged away.

  This is why ensembling near-identical models buys almost nothing; why
  replicating a service across one datacentre does not protect against a
  datacentre failure; and why a portfolio of correlated assets is not
  diversified. The interesting quantity is never $n$ alone, it is $rho$.
]

== The covariance matrix

#definition(title: "covariance matrix")[
  For a random vector $X = (X_1, dots, X_n)^T$ with mean $mu$,
  $ Sigma = EE[(X - mu)(X - mu)^T], quad Sigma_(i j) = Cov(X_i, X_j). $
]

#proposition[
  $Sigma$ is symmetric and positive semidefinite.
]

#proof[
  Symmetry is immediate from $Cov(X_i,X_j) = Cov(X_j,X_i)$. For semidefinite,
  take any $a in RR^n$:
  $ a^T Sigma a = a^T EE[(X-mu)(X-mu)^T] a = EE[(a^T (X - mu))^2] = Var(a^T X) >= 0. $
]

That computation is worth keeping: $a^T Sigma a$ is the variance of the
projection of $X$ onto direction $a$. So the covariance matrix is a machine
that reports the spread of your data in any direction you ask about.

#theorem(title: "linear transformation")[
  If $Y = A X + b$ then
  $ EE[Y] = A mu + b, quad Sigma_Y = A Sigma A^T. $
]

#proof[
  The mean is linearity. For the covariance,
  $ Sigma_Y = EE[(A(X-mu))(A(X-mu))^T] = A EE[(X-mu)(X-mu)^T] A^T = A Sigma A^T. $
]

The $A Sigma A^T$ form is the multivariate version of $Var(a X) = a^2 Var(X)$
--- the "square" becomes a sandwich because covariance is a bilinear form.

#intuition(title: "principal component analysis, in three lines")[
  $Sigma$ is symmetric, so by the spectral theorem (Chapter 23),
  $Sigma = Q Lambda Q^T$ with orthonormal eigenvectors and nonnegative
  eigenvalues.

  Since $a^T Sigma a$ is the variance in direction $a$, and since (from
  Chapter 23) that quadratic form is maximised over unit $a$ by the top
  eigenvector with value $lambda_1$:

  *The eigenvectors of the covariance matrix are the directions of greatest
  variance, and the eigenvalues are the variances in those directions.*

  Those directions are the principal components. Rotating your data into that
  basis, $Y = Q^T X$, gives
  $Sigma_Y = Q^T Q Lambda Q^T Q = Lambda$ --- diagonal. The new coordinates
  are *uncorrelated*.

  So PCA is: find the basis in which your data has no correlations, ordered by
  how much they vary. It is diagonalisation, applied to the covariance matrix,
  and it is the same computation as the SVD of the centred data matrix
  (Chapter 25).
]

#definition(title: "multivariate normal")[
  $X tilde cal(N)(mu, Sigma)$ with density
  $ f(x) = 1/((2 pi)^(n slash 2) (det Sigma)^(1 slash 2)) exp(-1/2 (x - mu)^T Sigma^(-1) (x-mu)). $
]

The exponent contains $(x-mu)^T Sigma^(-1)(x-mu)$, the *Mahalanobis
distance* squared. It is the natural distance for correlated data: it measures
how many standard deviations away a point is, *accounting for the
correlations*. Level sets are ellipsoids with axes along the eigenvectors of
$Sigma$ and semi-axis lengths proportional to $sqrt(lambda_i)$ --- exactly the
geometry of Chapter 23. The $sqrt(det Sigma)$ in the normalising constant is
the volume of that ellipsoid (Chapter 22).

Key properties, all worth knowing:

- Every marginal of a multivariate normal is normal.
- Every conditional is normal, with a mean that is a *linear* function of the
  conditioning variables.
- Any linear transform $A X + b$ is normal, with parameters given by the
  theorem above.
- For jointly normal variables, uncorrelated *does* imply independent (since
  $Sigma$ diagonal makes the density factor).

That last one is why Gaussians are so pleasant and so misleading as a mental
model for probability in general.

== Conditional expectation

#definition[
  $ EE[Y | X = x] = sum_y y thin p_(Y|X)(y|x) quad "or" quad integral y f_(Y|X)(y|x) dif y. $
  Note $EE[Y|X]$, without a specific value, is a *random variable*: it is a
  function of $X$.
]

#theorem(title: "law of total expectation (tower property)")[
  $ EE[Y] = EE[ EE[Y | X] ]. $
]

#proof[
  $ EE[EE[Y|X]] = sum_x EE[Y|X=x] p_X (x) = sum_x ( sum_y y thin (p(x,y))/(p_X (x)) ) p_X (x) = sum_y y sum_x p(x,y) = sum_y y thin p_Y (y). $
]

#intuition(title: "condition on the thing you wish you knew")[
  The tower property is the probabilistic version of case analysis, and it is
  the standard technique for computing expectations that look intractable:
  condition on something that makes the problem easy, then average over it.

  *Example.* Expected number of coin flips to get two heads in a row.
  Condition on the first flip. Let $E$ be the answer.
  - Tails (prob $1 slash 2$): one flip wasted, start over. Cost $1 + E$.
  - Heads then tails (prob $1 slash 4$): two flips wasted, start over. Cost
    $2 + E$.
  - Heads then heads (prob $1 slash 4$): done in 2.

  So $E = (1 slash 2)(1+E) + (1 slash 4)(2+E) + (1 slash 4)(2)$, giving
  $E = 6$.

  Recursive expectation computations like this are the probabilistic analogue
  of recurrence relations (Chapter 11), and they are solved the same way.
]

#theorem(title: "law of total variance")[
  $ Var(Y) = EE[Var(Y|X)] + Var(EE[Y|X]). $
]

Read: total variance $=$ (average within-group variance) $+$ (variance of the
group means). This decomposition is the foundation of analysis of variance,
of the bias--variance decomposition in machine learning, and of variance
reduction techniques in Monte Carlo --- if you can find an $X$ that explains a
lot of the variation, conditioning on it shrinks the first term.

#theorem(title: "conditional expectation is a projection")[
  Among all functions $g$, the one minimising $EE[(Y - g(X))^2]$ is
  $g(X) = EE[Y|X]$.
]

#proof[
  Write $Y - g(X) = (Y - EE[Y|X]) + (EE[Y|X] - g(X))$ and expand the square.
  The cross term is
  $ 2 EE[ (Y - EE[Y|X])(EE[Y|X] - g(X)) ]. $
  Condition on $X$: the second factor is then constant and the first has
  conditional expectation zero, so the whole thing vanishes by the tower
  property. Hence
  $ EE[(Y-g(X))^2] = EE[(Y - EE[Y|X])^2] + EE[(EE[Y|X] - g(X))^2], $
  and the second term is minimised (at zero) by $g = EE[Y|X]$.
]

#intuition(title: "this is why regression is what it is")[
  That proof is the Pythagorean argument of Chapter 24, verbatim, in the space
  of random variables with inner product $EE[U V]$.

  $EE[Y|X]$ is the *orthogonal projection* of $Y$ onto the space of functions
  of $X$. The residual is orthogonal to everything you could have computed
  from $X$ --- which is exactly the statement that you have extracted all the
  predictive information $X$ carries.

  So: the best possible predictor of $Y$ from $X$, under squared loss, is the
  conditional mean. That is what a regression model is trying to approximate,
  and it is why squared loss and conditional expectation always appear
  together. Train with a different loss and you converge to a different
  functional --- absolute loss gives the conditional *median*, which is a
  genuinely different (and more robust) thing to predict.
]

== Sums of independent random variables

#theorem(title: "convolution")[
  If $X$ and $Y$ are independent with densities $f_X$, $f_Y$, then $Z = X + Y$
  has density
  $ f_Z (z) = integral_(-infinity)^infinity f_X (x) f_Y (z - x) dif x. $
]

#proof[
  $PP(Z <= z) = integral.double_(x + y <= z) f_X (x) f_Y (y) dif x dif y$.
  Substituting $y = t - x$ and differentiating with respect to $z$ gives the
  stated integral.
]

Convolution appears in image processing, signal processing, and neural
networks under the same name and for the same reason: it is what happens when
two independent things combine additively.

#definition(title: "moment generating function")[
  $ M_X (t) = EE[e^(t X)]. $
]

#proposition[
  $M_(X+Y) = M_X dot M_Y$ for independent $X, Y$; and
  $EE[X^n] = M_X^((n))(0)$.
]

#proof[
  The first is $EE[e^(t(X+Y))] = EE[e^(t X)] EE[e^(t Y)]$ by independence.

  The second: expand $e^(t X) = sum_n (t X)^n slash n!$ (Chapter 17), so
  $M_X (t) = sum_n EE[X^n] t^n slash n!$, and the $n$-th derivative at $0$
  picks out $EE[X^n]$.
]

MGFs turn the awkward operation of convolution into multiplication --- the
same trick as logarithms, and the same trick as the Fourier transform. They
are the standard tool for proving that sums of familiar distributions stay
familiar, and they are the machinery behind the central limit theorem in
Chapter 30.

#example[
  Sums of independent normals are normal. The MGF of $cal(N)(mu,sigma^2)$ is
  $exp(mu t + sigma^2 t^2 slash 2)$. Multiplying two such gives
  $exp((mu_1 + mu_2)t + (sigma_1^2+sigma_2^2)t^2 slash 2)$, which is the MGF
  of $cal(N)(mu_1+mu_2, sigma_1^2 + sigma_2^2)$. Since the MGF determines the
  distribution, done.

  Compare doing this by convolution: a two-dimensional Gaussian integral,
  completing the square. The MGF turns it into multiplying two exponentials.
]

== Exercises

#exercise[
  The joint pmf of $(X,Y)$ is: $p(0,0) = 0.1$, $p(0,1) = 0.2$,
  $p(1,0) = 0.3$, $p(1,1) = 0.4$. Find both marginals, $EE[X]$, $EE[Y]$,
  $Cov(X,Y)$, and determine whether $X$ and $Y$ are independent.
]

#exercise[
  Let $X tilde Unif(-1,1)$ and $Y = X^2$. Verify directly that
  $Cov(X,Y) = 0$, and explain in one sentence why this does not contradict
  their obvious dependence.
]

#exercise[
  Prove that $Cov(a X + b, c Y + d) = a c thin Cov(X,Y)$, and deduce that
  correlation is unchanged by shifting and by positive scaling.
]

#exercise[
  Two assets each have return variance $sigma^2 = 0.04$ and correlation
  $rho = 0.6$. Compute the variance of an equally weighted portfolio, and
  compare to the $rho = 0$ case. Then find the limiting variance of an
  equally-weighted portfolio of $n$ such assets as $n -> infinity$.
]

#exercise[
  A random vector has covariance matrix $ Sigma = mat(4, 2; 2, 3). $ Find the
  variance of $X_1 + X_2$, the variance of $X_1 - X_2$, and the direction of
  maximum variance (the top eigenvector).
]

#exercise[
  Use the tower property to find the expected number of coin flips needed to
  see the pattern HTH. (Set up conditional expectations on the progress made
  so far --- there are four states.)
]

#exercise[
  A number $N$ of items is Poisson with mean $lambda$, and each item
  independently has weight with mean $mu$ and variance $tau^2$. Use the laws
  of total expectation and total variance to find the mean and variance of the
  total weight.
]

#exercise[
  Compute the MGF of the exponential distribution with rate $lambda$, state
  for which $t$ it converges, and use it to derive the mean and variance.
]
