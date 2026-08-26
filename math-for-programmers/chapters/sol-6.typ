#import "../lib.typ": *

== Chapter 25 --- The Singular Value Decomposition

#soln("25.1")[
  $A = diag(3, -2)$ already scales the two coordinate axes, so the singular
  values --- which must be *nonnegative* --- are $3$ and $2$.

  The sign has to go somewhere, and it goes into one of the orthogonal
  factors. One valid choice:
  $ U = I, quad Sigma = mat(3,0;0,2), quad V = mat(1,0;0,-1), $
  since then $U Sigma V^T = mat(3,0;0,-2)$. ✓

  Equally valid: $U = diag(1,-1)$, $V = I$. The SVD is not unique when signs
  or repeated singular values are involved --- only $Sigma$ is determined.

  Geometrically: $A$ reflects the $y$-axis and stretches by $(3,2)$. The
  reflection is absorbed into $V$ (or $U$), leaving a pure positive scaling in
  $Sigma$.
]

#soln("25.2")[
  $A = mat(1,1;0,1)$, so
  $ A^T A = mat(1,0;1,1) mat(1,1;0,1) = mat(1,1;1,2). $

  Characteristic polynomial: $(1-lambda)(2-lambda) - 1 = lambda^2 - 3lambda + 1$,
  with roots
  $ lambda = (3 plus.minus sqrt(5))/2 approx 2.618 "and" 0.382. $

  Singular values are the square roots:
  $ sigma_1 = sqrt(2.618) approx 1.618, quad sigma_2 = sqrt(0.382) approx 0.618. $

  Those are $phi$ and $1 slash phi$, the golden ratio and its reciprocal ---
  which is not a coincidence, since $lambda^2 - 3lambda + 1$ is the
  characteristic polynomial of $phi^2$.

  $ kappa_2 (A) = sigma_1 / sigma_2 = phi^2 approx 2.618. $

  So a unit shear is mildly ill-conditioned: it stretches by 1.618 in one
  direction and squeezes by 0.618 in another.
]

#soln("25.3")[
  Let $A = U Sigma V^T$ with $A$ of rank $n$ (full column rank), $m > n$.

  Then $A^T A = V Sigma^T Sigma V^T$, where $Sigma^T Sigma = diag(sigma_1^2, dots, sigma_n^2)$
  is $n times n$ and invertible.

  $
  (A^T A)^(-1) A^T &= (V Sigma^T Sigma V^T)^(-1) V Sigma^T U^T \
  &= V (Sigma^T Sigma)^(-1) V^T V Sigma^T U^T \
  &= V (Sigma^T Sigma)^(-1) Sigma^T U^T.
  $

  Now $(Sigma^T Sigma)^(-1) Sigma^T$ is the $n times m$ matrix with
  $1 slash sigma_i$ on the diagonal --- which is exactly $Sigma^+$. So

  $ (A^T A)^(-1) A^T = V Sigma^+ U^T = A^+. $

  The two formulas agree whenever the second one is defined; the pseudoinverse
  is the version that survives rank deficiency, where $A^T A$ is singular and
  the other formula does not exist.
]

#soln("25.4")[
  From Solution 20.4, $tr(A^T A) = sum_(i,j) A_(i j)^2 = norm(A)_F^2$.

  Now substitute the SVD and use cyclicity of the trace (Chapter 20):
  $ tr(A^T A) = tr(V Sigma^T U^T U Sigma V^T) = tr(V Sigma^T Sigma V^T) = tr(Sigma^T Sigma V^T V) = tr(Sigma^T Sigma), $
  using $U^T U = I$ and $V^T V = I$.

  And $Sigma^T Sigma$ is diagonal with entries $sigma_i^2$, so its trace is
  $sum_i sigma_i^2$.

  $ norm(A)_F = sqrt(sum_i sigma_i^2). $

  So the Frobenius norm is blind to the orthogonal factors --- it depends only
  on the stretching. This is the precise sense in which it is a
  rotation-invariant measure of "how big" a matrix is.
]

#soln("25.5")[
  With $sigma_i = 100 slash i$ for $i = 1, dots, 800$:
  $ sum_i sigma_i^2 = 10^4 sum_(i=1)^800 1/i^2 approx 10^4 times 1.6437 = 16,!437. $
  (The sum converges to $pi^2 slash 6 approx 1.6449$; truncating at 800
  removes about $1 slash 800$.)

  Ninety per cent of that is $0.9 times 1.6437 = 1.4793$ in the normalised
  units. Accumulating:
  #table(
    columns: 7, inset: 5pt, stroke: 0.4pt + luma(180), align: center,
    table.header([$k$], [1], [2], [3], [4], [5], [6]),
    [$sum_(i<=k) 1 slash i^2$], [1.000], [1.250], [1.361], [1.424], [1.464], [1.491],
  )

  $k = 5$ gives $1.464 < 1.479$; $k = 6$ gives $1.491 >= 1.479$. So *6
  singular values* suffice.

  *Storage.* Full matrix: $1000 times 800 = 800,!000$ numbers. Rank-6
  truncation: $6 times (1000 + 800 + 1) = 10,!806$ numbers. A saving of about
  *74$times$*.

  Note how fast this is: a $1 slash i$ spectrum is not especially rapid decay,
  and six components still carry 90% of the energy. Genuine data often decays
  faster still.
]

#soln("25.6")[
  Suppose $A^T A v = lambda v$ with $lambda != 0$ and $v != 0$.

  Consider $w = A v$. First, $w != 0$: if $A v = 0$ then
  $A^T A v = 0 = lambda v$, and since $lambda != 0$ that would force
  $v = 0$.

  Now
  $ A A^T w = A A^T A v = A(lambda v) = lambda (A v) = lambda w. $

  So $w$ is an eigenvector of $A A^T$ with the same eigenvalue $lambda$.

  The argument with $A$ and $A^T$ swapped gives the reverse inclusion, so the
  nonzero eigenvalues of $A^T A$ and $A A^T$ coincide (with multiplicity).

  They differ only in their *zero* eigenvalues: $A^T A$ is $n times n$ and
  $A A^T$ is $m times m$, so the larger one simply has $abs(m - n)$ extra
  zeros. Which is exactly why $Sigma$ in the SVD is rectangular with zero rows
  or columns padding it out.
]

#soln("25.7")[
  With $A = U Sigma V^T$,
  $ A^T A = V Sigma^T Sigma V^T, $
  which is an eigendecomposition of $A^T A$ with eigenvalues $sigma_i^2$.
  Since $A^T A$ is symmetric, its singular values *are* its eigenvalues (in
  absolute value), so the singular values of $A^T A$ are $sigma_i^2$.

  Hence
  $ kappa(A^T A) = (sigma_1^2)/(sigma_n^2) = ( sigma_1/sigma_n )^2 = kappa(A)^2. $

  *Practical consequence.* The rule of thumb is that $kappa approx 10^k$
  costs you $k$ decimal digits. Forming the normal equations *doubles* $k$, so
  it doubles the number of digits lost --- for free, before any arithmetic has
  been performed. Use QR (or SVD) instead, which works with $kappa(A)$
  directly.
]

#soln("25.8")[
  With $X = U Sigma V^T$ (rows of $X$ are samples, already centred), for any
  unit vector $w$:
  $ norm(X w)^2 = w^T X^T X w = w^T V Sigma^T Sigma V^T w. $

  Substitute $z = V^T w$. Since $V$ is orthogonal, $norm(z) = norm(w) = 1$,
  and
  $ norm(X w)^2 = z^T Sigma^T Sigma z = sum_i sigma_i^2 z_i^2. $

  This is a weighted average of the $sigma_i^2$ with weights $z_i^2$ summing
  to 1, so it is maximised by putting all the weight on the largest ---
  $z = e_1$, i.e. $w = V e_1 = v_1$ --- with maximum value $sigma_1^2$.

  So *the first principal component is the first right singular vector of the
  centred data matrix*, and the variance it captures is
  $sigma_1^2 slash (n-1)$.

  Continuing the argument on the orthogonal complement gives $v_2$, $v_3$, and
  so on: PCA is the SVD, and no separate algorithm is needed.
]

== Chapter 26 --- Matrix Calculus

#soln("26.1")[
  With $A = mat(1,2;3,4)$:
  $ x^T A x = x_1^2 + 2 x_1 x_2 + 3 x_2 x_1 + 4 x_2^2 = x_1^2 + 5 x_1 x_2 + 4 x_2^2. $

  Differentiating entry by entry:
  $ (partial)/(partial x_1) = 2 x_1 + 5 x_2, quad (partial)/(partial x_2) = 5 x_1 + 8 x_2. $

  And the formula:
  $ (A + A^T) x = mat(2,5;5,8) vec(x_1,x_2) = vec(2x_1 + 5x_2, thin 5x_1 + 8x_2). $

  Agreement. ✓ Note that the answer depends on $A$ only through its symmetric
  part $(A + A^T) slash 2$ --- the antisymmetric part contributes nothing to
  the quadratic form, which is why $x^T A x = x^T ((A+A^T) slash 2) x$ always.
]

#soln("26.2")[
  $norm(x) = (x^T x)^(1 slash 2)$. Taking differentials:
  $ dif norm(x) = 1/2 (x^T x)^(-1 slash 2) dot dif(x^T x) = 1/2 (1)/norm(x) dot 2 x^T dif x = (x^T)/norm(x) dif x. $
  By the identification rule,
  $ nabla_x norm(x) = x/norm(x), $
  the *unit vector in the direction of $x$*.

  *At $x = 0$* the expression is $0 slash 0$ and the gradient does not exist
  --- $norm(x)$ has a corner at the origin, exactly like $abs(x)$ in one
  dimension. (Its directional derivative in direction $u$ is $norm(u) = 1$
  regardless of direction, which cannot be $nabla f^T u$ for any fixed
  gradient.)

  *The standard fix* in optimisation code is to smooth it: use
  $sqrt(norm(x)^2 + epsilon)$, whose gradient is
  $x slash sqrt(norm(x)^2 + epsilon)$ and is well defined everywhere. This is
  what group-lasso and total-variation implementations do, and it is why they
  have an $epsilon$ parameter.
]

#soln("26.3")[
  *With respect to $x$.* Holding $y$ fixed,
  $ dif(x^T A y) = (dif x)^T A y = (A y)^T dif x, $
  so $nabla_x (x^T A y) = A y$.

  *With respect to $y$.* Holding $x$ fixed,
  $ dif(x^T A y) = x^T A thin dif y = (A^T x)^T dif y, $
  so $nabla_y (x^T A y) = A^T x$.

  The transpose appears in exactly one of them, and the reason is shapes: the
  gradient with respect to $y in RR^n$ must be in $RR^n$, and only $A^T x$ has
  that shape.
]

#soln("26.4")[
  $L(x) = norm(A x - b)^2 + lambda norm(x)^2$.

  By the two identities of the chapter,
  $ nabla L = 2 A^T (A x - b) + 2 lambda x. $

  Setting it to zero:
  $ A^T A x - A^T b + lambda x = 0 quad arrow.r.double quad (A^T A + lambda I) x = A^T b, $
  so
  $ hat(x) = (A^T A + lambda I)^(-1) A^T b. $

  *Effect on conditioning.* $A^T A$ is symmetric positive semidefinite with
  eigenvalues $sigma_i^2$. Adding $lambda I$ shifts every eigenvalue up by
  $lambda$, so the condition number becomes
  $ (sigma_1^2 + lambda)/(sigma_n^2 + lambda), $
  which is strictly smaller than $sigma_1^2 slash sigma_n^2$ and tends to 1 as
  $lambda$ grows.

  Crucially, the smallest eigenvalue is now at least $lambda > 0$, so the
  matrix is *invertible even when $A^T A$ is singular*. Ridge regression turns
  an ill-posed problem into a well-posed one, at the cost of bias --- exactly
  the bias--variance trade of Chapter 31.
]

#soln("26.5")[
  Start from the given identity
  $ dif det A = det(A) tr(A^(-1) dif A). $

  By the chain rule for the scalar function $log$,
  $ dif (log det A) = (dif det A)/(det A) = (det(A) tr(A^(-1) dif A))/(det A) = tr(A^(-1) dif A). $

  By the identification rule, since
  $tr(A^(-1) dif A) = tr( ((A^(-1))^T)^T dif A)$, the derivative is
  $ (partial)/(partial A) log det A = (A^(-1))^T. $

  Two sanity checks. For $1 times 1$ matrices this reads
  $dif log a = dif a slash a$. ✓ And for symmetric positive definite $A$ (the
  case that matters for Gaussians) the transpose is redundant and the answer
  is simply $A^(-1)$.
]

#soln("26.6")[
  Write $h = W_1 x$, $a = phi(h)$, $y = W_2 a$, and let
  $g = partial L slash partial y$.

  *Output layer.* By the linear-layer proposition with input $a$:
  $ (partial L)/(partial W_2) = g thin a^T. $
  Shapes: $g$ is $(dim y) times 1$, $a^T$ is $1 times h$, so the result is
  $(dim y) times h$ --- matching $W_2$. ✓

  *Backpropagate through $W_2$ and $phi$.*
  $ (partial L)/(partial a) = W_2^T g quad (h times 1), $
  $ delta = (partial L)/(partial h) = (W_2^T g) circle.small phi'(h) quad (h times 1), $
  using the elementwise-nonlinearity proposition.

  *Input layer.*
  $ (partial L)/(partial W_1) = delta thin x^T. $
  Shapes: $delta$ is $h times 1$, $x^T$ is $1 times n$, so the result is
  $h times n$ --- matching $W_1$. ✓

  Every step is a matrix--vector product or an elementwise product; nothing
  larger than a weight matrix is ever formed.
]

#soln("26.7")[
  With $n = 2$, write $S = e^(z_1) + e^(z_2)$, so
  $p_1 = e^(z_1) slash S$ and $p_2 = e^(z_2) slash S$.

  *Diagonal entry.*
  $ (partial p_1)/(partial z_1) = (e^(z_1) S - e^(z_1) dot e^(z_1))/(S^2) = (e^(z_1))/S - ((e^(z_1))/S)^2 = p_1 - p_1^2 = p_1 (1 - p_1). $
  Matching $p_i(delta_(i i) - p_i) = p_1(1 - p_1)$. ✓

  *Off-diagonal entry.*
  $ (partial p_1)/(partial z_2) = (0 dot S - e^(z_1) dot e^(z_2))/(S^2) = -p_1 p_2. $
  Matching $p_1(delta_(1 2) - p_2) = p_1(0 - p_2) = -p_1 p_2$. ✓

  Note the rows sum to zero: $p_1(1-p_1) + (-p_1 p_2) = p_1(1 - p_1 - p_2) = 0$.
  That is the next exercise.
]

#soln("26.8")[
  The softmax Jacobian is $J = diag(p) - p p^T$.

  *Symmetric.* $diag(p)$ is symmetric and $(p p^T)^T = p p^T$. ✓

  *Positive semidefinite.* For any $x$,
  $ x^T J x = sum_i p_i x_i^2 - ( sum_i p_i x_i )^2. $
  Treating $p$ as a probability distribution over indices and $x$ as a random
  variable taking value $x_i$ with probability $p_i$, this is exactly
  $ EE[x^2] - (EE[x])^2 = Var(x) >= 0. $
  A lovely appearance of Chapter 28 inside Chapter 26.

  *Singular.* Let $bold(1)$ be the all-ones vector. Then
  $ J bold(1) = p - p (bold(1)^T p) = p - p dot 1 = 0, $
  since the entries of $p$ sum to 1.

  *What that means.* The all-ones direction is in the null space, which says:
  *moving all logits by the same amount changes nothing.* That is precisely
  the shift invariance of Chapter 4, now visible in the derivative.

  Consequence: the softmax parameterisation is *over-parameterised* by exactly
  one degree of freedom. For $n$ classes, only $n - 1$ logits are
  identifiable, which is why binary classification uses a single output rather
  than two, and why softmax regression coefficients are only determined up to
  a common shift.
]

== Chapter 27 --- Probability

#soln("27.1")[
  Sample space: the 36 equally likely ordered pairs.

  *(a) Sum is 7.* Six outcomes ($(1,6)$ through $(6,1)$):
  $PP = 6 slash 36 = 1 slash 6$.

  *(b) Sum is 7 given the first is 3.* Given the first die, only the second
  matters, and it must be 4: $PP = 1 slash 6$. (Notice this equals the
  unconditional probability --- the sum being 7 is independent of the value of
  either individual die, which is a special feature of 7.)

  *(c) At least one 6.* Complementary counting: $1 - (5 slash 6)^2 = 11 slash 36$.

  *(d) Sum 7 and at least one 6.* Only $(1,6)$ and $(6,1)$:
  $PP = 2 slash 36 = 1 slash 18$.

  *Independence of (a) and (c).*
  $ PP(A) PP(C) = 1/6 dot 11/36 = 11/216, quad PP(A inter C) = 1/18 = 12/216. $
  Not equal, so *not independent* --- though only just. Conditioning on "at
  least one 6" slightly raises the chance of a 7, because a 6 is a
  particularly useful die to have when aiming for 7.
]

#soln("27.2")[
  $A$ is the disjoint union of $A inter B$ and $A inter overline(B)$, so
  $ PP(A inter overline(B)) = PP(A) - PP(A inter B). $
  Using independence of $A$ and $B$:
  $ = PP(A) - PP(A)PP(B) = PP(A)(1 - PP(B)) = PP(A) PP(overline(B)). $
  Which is the definition of independence for $A$ and $overline(B)$.

  Applying the result twice shows $overline(A)$ and $overline(B)$ are also
  independent --- as they should be, since "these two events carry no
  information about each other" ought to be immune to how you phrase them.
]

#soln("27.3")[
  5 red, 3 blue, two drawn without replacement.

  *(a) Both red.* $ (5/8)(4/7) = 20/56 = 5/14. $

  *(b) Second is red.* By total probability, conditioning on the first:
  $ (5/8)(4/7) + (3/8)(5/7) = 20/56 + 15/56 = 35/56 = 5/8. $

  *(c) First red given second red.*
  $ PP("1st red" | "2nd red") = (PP("both red"))/(PP("2nd red")) = (5 slash 14)/(5 slash 8) = 4/7. $

  *Comment on (b).* The answer $5 slash 8$ is exactly the unconditional
  probability that *any* particular draw is red. The reason is *
  exchangeability*: before you look at anything, the 8 balls are in a uniformly
  random order, and the ball in position 2 is as likely to be red as the ball
  in position 1. Labelling the draws "first" and "second" is a description of
  the order, not a physical asymmetry.

  Note that (c) is $4 slash 7$, not $5 slash 8$ --- learning the second is red
  *does* change the first, because it removes a red ball from the pool. The
  relation is symmetric in a way that surprises people: each draw informs the
  other equally.
]

#soln("27.4")[
  *At 40% spam.*
  $
  PP("flag") &= PP("flag"|"spam")PP("spam") + PP("flag"|"ham")PP("ham") \
  &= (0.95)(0.4) + (0.02)(0.6) = 0.380 + 0.012 = 0.392.
  $
  $ PP("spam" | "flag") = (0.380)/(0.392) = 0.969. $
  A flagged message is 97% likely to be spam. Good filter.

  *At 1% spam.*
  $ PP("flag") = (0.95)(0.01) + (0.02)(0.99) = 0.0095 + 0.0198 = 0.0293, $
  $ PP("spam"|"flag") = (0.0095)/(0.0293) = 0.324. $

  *Only 32%.* The filter has not changed at all --- same sensitivity, same
  specificity --- but *two thirds of its flags are now false positives*,
  because there are 99 times as many legitimate messages to misflag.

  This is the base-rate effect, and the practical lesson is direct: a
  detector's usefulness depends on the prevalence of what it detects, so
  quality metrics quoted without a base rate are meaningless. It is also why
  the same fraud model performs beautifully in one market and floods the
  review queue in another.
]

#soln("27.5")[
  Take $Omega = {1,2,3,4}$ with the uniform distribution, and
  $ A = {1,2}, quad B = {1,3}, quad C = {1,4}. $

  Each has probability $1 slash 2$.

  *Pairwise independent.* Each pairwise intersection is ${1}$, of probability
  $1 slash 4$, and $PP(A)PP(B) = 1 slash 4$. ✓ Likewise for the other two
  pairs.

  *Not mutually independent.* $A inter B inter C = {1}$, so
  $ PP(A inter B inter C) = 1/4 != 1/8 = PP(A)PP(B)PP(C). $

  Interpretation: any *one* of the events tells you nothing about any other,
  but any *two* of them together determine the third (if two hold, the outcome
  must be 1, so the third holds too). Mutual independence is strictly stronger
  than pairwise, and the extra content is exactly this kind of higher-order
  coupling.
]

#soln("27.6")[
  $ PP("all distinct") = product_(i=0)^(n-1) (365 - i)/365. $

  Evaluating:
  #table(
    columns: 5, inset: 6pt, stroke: 0.4pt + luma(180), align: center,
    table.header([$n$], [22], [23], [56], [57]),
    [$PP("shared")$], [0.476], [0.507], [0.988], [0.990],
  )

  So the smallest $n$ exceeding $1 slash 2$ is *23*, and the smallest
  exceeding $0.99$ is *57*.

  The reason 23 feels too small: there are $binom(23,2) = 253$ *pairs* of
  people, and each pair has about a $1 slash 365$ chance of matching. The
  expected number of matches is about $253 slash 365 approx 0.69$, which is
  already of order 1. Intuition anchors on 23 versus 365 rather than on 253
  versus 365, and the pairs are what matter.
]

#soln("27.7")[
  Let $F$ = "picked the fair coin", $D$ = "picked the double-headed coin",
  each with prior $1 slash 2$. Let $E$ = "three heads".

  $PP(E | F) = (1 slash 2)^3 = 1 slash 8$ and $PP(E | D) = 1$.

  $
  PP(D | E) = (PP(E|D) PP(D))/(PP(E|D)PP(D) + PP(E|F)PP(F))
  = (1 dot 1 slash 2)/(1 dot 1 slash 2 + (1 slash 8)(1 slash 2))
  = (1 slash 2)/(9 slash 16) = 8/9.
  $

  About 89%. Note that the fair coin is not ruled out --- it can produce three
  heads --- but it is eight times less likely to, and that ratio is exactly the
  factor by which the odds shift: prior odds $1:1$ become posterior odds
  $8:1$.

  Thinking in *odds* rather than probabilities makes Bayes a multiplication:
  posterior odds $=$ prior odds $times$ likelihood ratio. Often far easier.
]

#soln("27.8")[
  Start from the two-event form
  $ PP(B_j | A) = (PP(A | B_j) PP(B_j))/(PP(A)). $
  The law of total probability, applied to the partition ${B_i}$, says
  $ PP(A) = sum_i PP(A | B_i) PP(B_i). $
  Substituting into the denominator gives the expanded form.

  *What the denominator represents.* It is $PP(A)$ --- the total probability
  of observing the evidence, averaged over every hypothesis weighted by its
  prior. In Bayesian language it is called the *evidence* or the *marginal
  likelihood*.

  Operationally it is just the normalising constant: it is whatever makes the
  posterior probabilities sum to 1 across the hypotheses. That is why in
  practice one often computes the unnormalised posterior
  $PP(A|B_j)PP(B_j)$ for each $j$ and divides by the total at the end --- and
  why, when only the *ratio* of two posteriors is wanted, the denominator
  cancels and never has to be computed at all.
]

== Chapter 28 --- Random Variables and Distributions

#soln("28.1")[
  $ EE[X] = (1+2+3+4+5+6)/6 = 21/6 = 3.5. $
  $ EE[X^2] = (1+4+9+16+25+36)/6 = 91/6 approx 15.167. $
  $ Var(X) = 91/6 - (7/2)^2 = 91/6 - 49/4 = (182 - 147)/12 = 35/12 approx 2.917. $
  Standard deviation $approx 1.708$.

  Note $EE[X] = 3.5$ is not an attainable value --- expectations need not be
  in the range of the variable.
]

#soln("28.2")[
  $X tilde Bin(10, 0.3)$.

  $ PP(X = 3) = binom(10,3)(0.3)^3 (0.7)^7 = 120 times 0.027 times 0.0823543 approx 0.2668. $

  $ EE[X] = n p = 3, quad Var(X) = n p (1-p) = 10(0.3)(0.7) = 2.1. $

  $ PP(X >= 1) = 1 - PP(X = 0) = 1 - (0.7)^10 = 1 - 0.02825 = 0.9718. $

  The complementary form is both easier and numerically better --- summing ten
  terms would be more work and would lose precision.
]

#soln("28.3")[
  First, $PP(X > k) = (1-p)^k$: the event "more than $k$ trials are needed" is
  exactly "the first $k$ trials all failed", and by independence that has
  probability $(1-p)^k$.

  Then
  $
  PP(X > s + t | X > s) = (PP(X > s+t inter X > s))/(PP(X > s)) = (PP(X > s+t))/(PP(X>s)) = ((1-p)^(s+t))/((1-p)^s) = (1-p)^t = PP(X > t),
  $
  where the second step uses $\{X > s+t\} subset.eq \{X > s\}$.

  *Reading.* Having already failed $s$ times tells you *nothing* about how
  many more attempts you need. Each trial is a fresh start.

  This is why "I have missed five times, I am due" is wrong for genuinely
  independent trials, and why an exponentially-distributed remaining lifetime
  does not shorten with age. It is also the property that makes the geometric
  and exponential distributions so analytically convenient --- and that makes
  them the wrong model for anything that genuinely wears out.
]

#soln("28.4")[
  *(a)* $lambda = 3$:
  $ PP(X = 5) = (3^5 e^(-3))/(5!) = (243)(0.049787)/120 approx 0.1008. $

  *(b)* $ PP(X = 0) = e^(-3) approx 0.0498. $

  *(c)* Over half a second the rate is $lambda = 1.5$:
  $
  PP(X > 1) = 1 - PP(0) - PP(1) = 1 - e^(-1.5) - 1.5 e^(-1.5) = 1 - 2.5 e^(-1.5) approx 1 - 0.5578 = 0.4422.
  $

  Note the rate scales linearly with the interval --- that is part of what
  "Poisson process" means, and it is why you can freely change the time unit
  as long as you scale $lambda$ with it.
]

#soln("28.5")[
  *By CDF.* For $y >= 0$,
  $
  PP(Y <= y) &= PP(-ln(X)/lambda <= y) = PP(ln X >= -lambda y) \
  &= PP(X >= e^(-lambda y)) = 1 - e^(-lambda y),
  $
  using $PP(X >= c) = 1 - c$ for $X tilde Unif(0,1)$ and $c in [0,1]$.

  That is exactly the CDF of $"Exp"(lambda)$.

  *By the change-of-variable formula.* $g(x) = -ln(x) slash lambda$ has
  inverse $x = g^(-1)(y) = e^(-lambda y)$, so
  $abs(dif x slash dif y) = lambda e^(-lambda y)$. Since $f_X = 1$ on
  $(0,1)$:
  $ f_Y (y) = 1 dot lambda e^(-lambda y). $ ✓

  This is inverse transform sampling (Chapter 27) worked out for the
  exponential, and it is exactly how `numpy.random.exponential` generates
  variates: one uniform, one logarithm.
]

#soln("28.6")[
  Let $I_i = 1$ if the $i$-th element is a record --- larger than everything
  before it.

  *Key observation.* Among the first $i$ elements, the largest is equally
  likely to be in any of the $i$ positions, by symmetry of the random
  permutation. The $i$-th element is a record exactly when it is that largest,
  so
  $ PP(I_i = 1) = 1/i. $

  By linearity of expectation --- and the $I_i$ are emphatically *not*
  independent, which does not matter:
  $ EE["records"] = sum_(i=1)^n 1/i = H_n approx ln n + gamma. $

  So a list of a million random numbers has only about 14 records. This is
  also the expected number of times a "running maximum" variable gets updated,
  and the reason randomised incremental algorithms (like randomised
  linear programming or incremental convex hulls) are fast: the expensive
  update only happens $O(log n)$ times.
]

#soln("28.7")[
  *($arrow.l.double$)* If $X = c$ with probability 1 then $EE[X] = c$ and
  $Var(X) = EE[(c-c)^2] = 0$.

  *($arrow.r.double$)* Suppose $Var(X) = EE[(X-mu)^2] = 0$. The random
  variable $(X - mu)^2$ is nonnegative with expectation zero.

  A nonnegative random variable with zero expectation must be zero almost
  surely: if $PP((X-mu)^2 > epsilon) = delta > 0$ for some $epsilon > 0$, then
  by Markov's inequality reasoning $EE[(X-mu)^2] >= epsilon delta > 0$, a
  contradiction.

  So $(X - mu)^2 = 0$ with probability 1, i.e. $X = mu$ with probability 1.
]

#soln("28.8")[
  Let $I_j = 1$ if bucket $j$ is empty. Each of the $n$ keys independently
  misses bucket $j$ with probability $1 - 1 slash m$, so
  $ PP(I_j = 1) = (1 - 1/m)^n. $

  By linearity,
  $ EE["empty buckets"] = m (1 - 1/m)^n. $

  *At $n = m$:* using $(1 - 1 slash m)^m -> e^(-1)$,
  $ EE["empty"] approx m/e approx 0.368 m. $

  So loading a hash table to exactly 100% occupancy leaves *37% of buckets
  empty* --- and correspondingly, a great many buckets hold two or more keys.
  Randomness is much lumpier than intuition suggests, which is why chaining
  needs to handle collisions gracefully and why "load factor 1" does not mean
  "one key per bucket".
]

== Chapter 29 --- Several Random Variables

#soln("29.1")[
  *Marginals.*
  $
  p_X (0) = 0.1 + 0.2 = 0.3, quad p_X (1) = 0.3 + 0.4 = 0.7, \
  p_Y (0) = 0.1 + 0.3 = 0.4, quad p_Y (1) = 0.2 + 0.4 = 0.6.
  $

  $EE[X] = 0.7$, $EE[Y] = 0.6$.

  $EE[X Y] = (1)(1)(0.4) = 0.4$ --- only the $(1,1)$ cell contributes.

  $ Cov(X,Y) = 0.4 - (0.7)(0.6) = 0.4 - 0.42 = -0.02. $

  *Independent?* No. Check one cell:
  $p(0,0) = 0.1$ but $p_X (0) p_Y (0) = (0.3)(0.4) = 0.12$. The joint does not
  factor.

  Consistent with the nonzero covariance --- though note that a zero
  covariance would *not* have established independence (next exercise).
]

#soln("29.2")[
  $X tilde Unif(-1,1)$, $Y = X^2$.

  $EE[X] = 0$ by symmetry. And
  $ EE[X Y] = EE[X^3] = integral_(-1)^1 x^3 dot 1/2 dif x = 0, $
  since $x^3$ is odd and the density is symmetric.

  $ Cov(X,Y) = EE[X Y] - EE[X]EE[Y] = 0 - 0 = 0. $

  *No contradiction:* covariance measures only the *linear* component of
  association, and here the dependence is purely quadratic and symmetric ---
  $Y$ increases as $X$ moves away from zero in *either* direction, so the
  positive and negative contributions cancel exactly.

  $Y$ is a deterministic function of $X$, so they are about as dependent as
  two variables can be. Mutual information (Chapter 32) would report this
  correctly; correlation cannot.
]

#soln("29.3")[
  Let $mu_X = EE[X]$, $mu_Y = EE[Y]$. Then
  $EE[a X + b] = a mu_X + b$, so the centred version of $a X + b$ is
  $a(X - mu_X)$. Likewise for $Y$. Hence
  $
  Cov(a X + b, c Y + d) = EE[a(X-mu_X) dot c(Y - mu_Y)] = a c thin Cov(X,Y).
  $

  *Correlation.* The standard deviations scale as
  $sigma_(a X + b) = abs(a) sigma_X$, so
  $ Corr(a X + b, c Y + d) = (a c thin Cov(X,Y))/(abs(a) abs(c) sigma_X sigma_Y) = sgn(a c) thin Corr(X,Y). $

  For $a, c > 0$ the correlation is unchanged. So correlation is invariant
  under shifting and positive rescaling --- which is exactly why it is
  unitless and comparable across variables measured in different units. A
  negative scaling flips its sign, as it should.
]

#soln("29.4")[
  Two assets, $sigma^2 = 0.04$, $rho = 0.6$, equal weights $1 slash 2$:
  $
  Var(overline(R)) &= 1/4 [ Var(R_1) + Var(R_2) + 2 Cov(R_1,R_2) ] \
  &= 1/4 [0.04 + 0.04 + 2(0.6)(0.04)] = 1/4 [0.128] = 0.032.
  $

  *With $rho = 0$:* $ 1/4 [0.08] = 0.02. $

  So correlation of 0.6 costs you 60% more variance than independence would
  have given.

  *As $n -> infinity$* with all pairwise correlations $rho$:
  $ Var(overline(R)) = (sigma^2)/n + (n-1)/n rho sigma^2 arrow.r.long rho sigma^2 = 0.6 times 0.04 = 0.024. $

  You can never do better than $0.024$, no matter how many such assets you
  hold. The idiosyncratic risk averages away; the *common* risk does not. That
  floor is what "systematic risk" means, and it is why a portfolio of a
  thousand correlated tech stocks is not diversified.
]

#soln("29.5")[
  $Sigma = mat(4,2;2,3)$.

  $ Var(X_1 + X_2) = Sigma_(11) + Sigma_(22) + 2 Sigma_(12) = 4 + 3 + 4 = 11. $
  $ Var(X_1 - X_2) = Sigma_(11) + Sigma_(22) - 2 Sigma_(12) = 4 + 3 - 4 = 3. $

  (Both are $a^T Sigma a$ with $a = (1,1)$ and $a = (1,-1)$.)

  *Direction of maximum variance.* Characteristic polynomial
  $(4-lambda)(3-lambda) - 4 = lambda^2 - 7lambda + 8$, so
  $ lambda = (7 plus.minus sqrt(17))/2 approx 5.562 "and" 1.438. $

  For $lambda_1 approx 5.562$: $(4 - 5.562)v_1 + 2 v_2 = 0$ gives
  $v_2 approx 0.781 v_1$, so the direction is
  $ v_1 approx (0.788, thin 0.616). $

  The variance in that direction is $5.562$ --- larger than either coordinate
  variance, and larger than the naive guess that the maximum must be along an
  axis. That is the whole point of PCA: the informative directions are
  generally not the ones you happened to measure.
]

#soln("29.6")[
  Track states by the progress made towards HTH.

  - $S_0$: no useful prefix.
  - $S_1$: last flip was H.
  - $S_2$: last two were HT.

  Let $E_i$ be the expected additional flips from state $i$.

  $
  E_0 &= 1 + 1/2 E_1 + 1/2 E_0 quad &&"(H -> " S_1", T -> " S_0")" \
  E_1 &= 1 + 1/2 E_1 + 1/2 E_2 quad &&"(H -> " S_1 "again, T -> " S_2")" \
  E_2 &= 1 + 1/2 (0) + 1/2 E_0 quad &&"(H -> done, T -> " S_0")"
  $

  The second line is the subtle one: from HT, another H completes the pattern;
  but from H, another H leaves you still with a single trailing H.

  Solving: the first gives $E_0 = 2 + E_1$; the second gives $E_1 = 2 + E_2$;
  the third gives $E_2 = 1 + E_0 slash 2$.

  Substituting upwards: $E_1 = 3 + E_0 slash 2$, then
  $E_0 = 5 + E_0 slash 2$, so $E_0 = 10$.

  *Ten flips on average.*

  Worth knowing: the answer depends on the *pattern*, not just its length.
  HTT takes 8 on average, HHH takes 14. Patterns that can overlap themselves
  take longer, because a near-miss throws away more progress --- the
  Conway leading-number algorithm quantifies this exactly.
]

#soln("29.7")[
  $N tilde Pois(lambda)$, weights $W_i$ i.i.d. with mean $mu$ and variance
  $tau^2$, and $S = sum_(i=1)^N W_i$.

  *Mean, by the tower property.*
  $ EE[S] = EE[EE[S | N]] = EE[N mu] = mu EE[N] = lambda mu. $

  *Variance, by the law of total variance.*
  Given $N = n$, $S$ is a sum of $n$ i.i.d. terms, so
  $EE[S|N] = N mu$ and $Var(S|N) = N tau^2$. Hence
  $
  Var(S) &= EE[Var(S|N)] + Var(EE[S|N]) \
  &= EE[N tau^2] + Var(N mu) \
  &= lambda tau^2 + mu^2 lambda = lambda(tau^2 + mu^2).
  $

  (Using $EE[N] = Var(N) = lambda$ for a Poisson.)

  This is the *compound Poisson* model, and it is the standard model for
  aggregate insurance claims, total bytes transferred in a session, and total
  cost of a random number of random-sized operations. Note the variance has
  two sources --- randomness in *how many* and randomness in *how big* --- and
  the decomposition separates them cleanly.
]

#soln("29.8")[
  $
  M(t) = EE[e^(t X)] = integral_0^infinity e^(t x) lambda e^(-lambda x) dif x = lambda integral_0^infinity e^(-(lambda - t)x) dif x.
  $
  The integral converges iff $lambda - t > 0$, i.e. $t < lambda$, and then
  equals $1 slash (lambda - t)$. So
  $ M(t) = lambda/(lambda - t), quad t < lambda. $

  *Moments.*
  $ M'(t) = lambda/((lambda-t)^2), quad M'(0) = 1/lambda = EE[X]. $
  $ M''(t) = (2 lambda)/((lambda-t)^3), quad M''(0) = 2/lambda^2 = EE[X^2]. $
  $ Var(X) = 2/lambda^2 - 1/lambda^2 = 1/lambda^2. $

  Matching the values quoted in Chapter 28. The restriction $t < lambda$ is
  not a technicality: it says the exponential's tail is exactly at the
  boundary of what an MGF can handle, and distributions with heavier tails
  (like the Cauchy, or a power law) have no MGF at all for any $t > 0$ ---
  which is precisely why the CLT machinery fails for them.
]

== Chapter 30 --- The Limit Theorems

#soln("30.1")[
  $mu = 10$, $sigma = 2$. The event $X >= 20$ implies $abs(X - 10) >= 10$,
  which is $5 sigma$. By Chebyshev,
  $ PP(X >= 20) <= PP(abs(X - mu) >= 5 sigma) <= 1/25 = 0.04. $

  *If $X$ were normal:* $PP(Z >= 5) approx 2.87 times 10^(-7)$.

  *The gap is a factor of about 140,000.*

  Chebyshev is loose because it uses only the variance and must hold for
  *every* distribution with that variance --- including ones with all their
  excess mass sitting exactly at $plus.minus 5 sigma$. The normal has
  extremely thin tails, so it is nowhere near the worst case.

  The lesson is not that Chebyshev is bad; it is that distribution-free bounds
  buy universality at the cost of tightness. If you know your distribution,
  use it. If you do not, Chebyshev still gives you something.
]

#soln("30.2")[
  Markov's inequality with $a = 100$:
  $ PP(X >= 100) <= (EE[X])/100 = 1/100 = 0.01. $

  *A distribution achieving equality.* Let
  $ X = cases(100 quad &"with probability" 0.01, 0 &"with probability" 0.99). $
  Then $EE[X] = 100 times 0.01 = 1$ ✓ and
  $PP(X >= 100) = 0.01$ --- exactly the bound.

  So Markov cannot be improved without further assumptions. The extremal
  distribution puts all its mass at $0$ and at the threshold, which is
  precisely the case in which the proof's two inequalities are both tight.
]

#soln("30.3")[
  $overline(x) = 250$ ms, $s = 40$ ms, $n = 100$.
  $ "SE" = s/sqrt(n) = 40/10 = 4 "ms". $
  A 95% confidence interval:
  $ 250 plus.minus 1.96 times 4 = 250 plus.minus 7.84 = [242.2, thin 257.8] "ms". $

  *To halve the width* you need to halve the standard error, and since
  $"SE" prop 1 slash sqrt(n)$, you need *four times* the data: $n = 400$.

  Worth noting for benchmarking: reducing $s$ is usually cheaper than
  quadrupling $n$. Pinning CPU affinity, disabling frequency scaling, warming
  caches, and discarding the first few runs all attack $s$ directly, and a 2$times$
  reduction in $s$ is worth a 4$times$ increase in $n$.
]

#soln("30.4")[
  $X tilde Bin(10000, 0.5)$, so
  $ mu = 5000, quad sigma = sqrt(n p (1-p)) = sqrt(2500) = 50. $

  By the CLT, $X$ is approximately $cal(N)(5000, 50^2)$, so
  $ PP(4900 <= X <= 5100) approx PP(-2 <= Z <= 2) approx 0.9545. $

  About 95.5%.

  Note how tight that is in *relative* terms: the interval is
  $5000 plus.minus 100$, which is $plus.minus 2%$. With ten thousand tosses
  the proportion of heads is pinned to within about 1% with high confidence.
  With a hundred tosses, $sigma = 5$, and the same $plus.minus 2 sigma$ is
  $plus.minus 10%$. The $1 slash sqrt(n)$ shrinkage, made concrete.
]

#soln("30.5")[
  *Independent case.* $Var(sum X_i) = sum Var(X_i) = n sigma^2$, and
  $overline(X) = (1 slash n) sum X_i$, so
  $ Var(overline(X)) = 1/(n^2) dot n sigma^2 = (sigma^2)/n. $

  *Correlated case.* Using the general formula,
  $
  Var( sum_i X_i ) = sum_i Var(X_i) + sum_(i != j) Cov(X_i, X_j) = n sigma^2 + n(n-1) rho sigma^2.
  $
  Dividing by $n^2$:
  $ Var(overline(X)) = (sigma^2)/n + (n-1)/n rho sigma^2. $

  *Limit.* As $n -> infinity$ the first term vanishes and
  $(n-1) slash n -> 1$, so
  $ Var(overline(X)) arrow.r.long rho sigma^2. $

  Averaging removes the independent part of the noise entirely and the
  correlated part not at all. If $rho = 0.01$ --- a correlation you would
  barely notice --- then no amount of data reduces the variance below
  $0.01 sigma^2$, which caps the achievable precision at one tenth of a single
  measurement's standard deviation.
]

#soln("30.6")[
  The CLT requires *finite variance*. The Cauchy distribution has density
  $f(x) = 1 slash (pi(1+x^2))$, whose tails decay like $1 slash x^2$. Then
  $ integral abs(x) f(x) dif x approx integral (dif x)/(pi abs(x)) $
  diverges logarithmically, so the Cauchy has *no mean*, let alone a finite
  variance. The hypothesis fails at the first step.

  *What actually happens.* The average of $n$ i.i.d. standard Cauchy variables
  is *again standard Cauchy* --- exactly, for every $n$. (This follows from the
  characteristic function $e^(-abs(t))$: the average has characteristic
  function $(e^(-abs(t) slash n))^n = e^(-abs(t))$.)

  So $overline(X)_n$ does not concentrate at all. Its distribution is
  identical for $n = 1$ and $n = 10^9$. Collecting more data buys you
  literally nothing, which is a startling and genuinely important failure
  mode.

  The correct limit theory here uses *stable distributions*; the Cauchy is
  itself stable, which is why it is its own limit. And the practical warning
  is real: heavy-tailed data (network latencies, financial returns, file
  sizes) can be much closer to this regime than to the Gaussian one, and
  sample means of such data are far less trustworthy than their standard
  errors suggest.
]

#soln("30.7")[
  Baseline $p = 0.05$; a 2% *relative* lift means the treatment rate is
  $0.05 times 1.02 = 0.051$, so the difference to detect is
  $Delta = 0.001$.

  The standard error of the difference of two proportions, with $n$ per arm,
  is
  $ "SE" = sqrt( (2 p (1-p))/n ) = sqrt( (2 times 0.05 times 0.95)/n ) = sqrt(0.095/n). $

  Requiring $Delta = 2 dot "SE"$:
  $ 0.001 = 2 sqrt(0.095/n) quad arrow.r.double quad 0.095/n = 2.5 times 10^(-7) quad arrow.r.double quad n = 380,!000. $

  *About 380,000 users per arm.*

  Two lessons. First, small relative effects on small base rates are
  *extremely* expensive to measure --- and note that the required $n$ scales as
  $1 slash Delta^2$, so detecting a 1% lift instead of 2% would cost four
  times as much. Second, this calculation must be done *before* running the
  experiment; discovering afterwards that you were underpowered means the
  experiment could not have answered the question, whatever it returned.
]

#soln("30.8")[
  *Why the standard formula does not apply.* The $overline(X) plus.minus 1.96 "SE"$
  interval rests on the CLT for the *sample mean*, and specifically on
  $"SE" = sigma slash sqrt(n)$. The sample median has a different asymptotic
  distribution: it is asymptotically normal with variance
  $1 slash (4 n f(m)^2)$, where $f$ is the *density at the true median*.

  That is the problem: $f(m)$ is a property of the unknown distribution, and
  estimating a density well is much harder than estimating a mean. There is no
  formula you can evaluate from the data alone in the way $s slash sqrt(n)$
  can be.

  *Bootstrap procedure.*
  #algo[
  ```
  given the sample x[1..200]:
      for b = 1 .. 10000:
          resample 200 values from x, WITH replacement
          m[b] := median of that resample
      sort m[]
      CI := [ m[250], m[9750] ]     # 2.5th and 97.5th percentiles
  ```
  ]

  This needs no density estimate and no formula. It works because the
  empirical distribution converges to the true one, so the simulated
  variability of the median converges to its real variability.

  *One caveat:* the bootstrap is less reliable for statistics that depend on
  the extreme tails (the maximum, say) or for very small samples, where the
  empirical distribution is a poor stand-in. For the median at $n = 200$ it is
  entirely trustworthy.
]
