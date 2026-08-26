#import "../lib.typ": *

= Orthogonality, Projection, and Least Squares

== Why orthogonality is the good case

Chapter 19 introduced the dot product and noticed that $u dot v = 0$ --- being
perpendicular --- is a special condition. This chapter is about why it is
*the* special condition.

#intuition(title: "orthogonal means independent in the strongest sense")[
  Linear independence says no vector is a combination of the others.
  Orthogonality says something much stronger: *the vectors do not interact at
  all.*

  Concretely, with an orthonormal basis:

  - Finding coordinates requires no solving. It is one dot product per
    coordinate, in $O(n)$, instead of an $O(n^3)$ elimination.
  - Lengths decompose by Pythagoras: $norm(sum c_i q_i)^2 = sum c_i^2$.
  - Changing basis is done by a matrix whose inverse is its transpose. No
    inversion, no numerical loss.
  - Errors in one coordinate do not leak into the others.

  Every good numerical algorithm is built from orthogonal transformations,
  and this is why.
]

#definition(title: "orthogonal and orthonormal sets")[
  A set ${v_1, dots, v_k}$ is *orthogonal* if $v_i dot v_j = 0$ for $i != j$,
  and *orthonormal* if additionally $norm(v_i) = 1$ for all $i$.
]

#proposition[
  An orthogonal set of nonzero vectors is linearly independent.
]

#proof[
  Suppose $sum c_i v_i = 0$. Take the dot product with $v_j$:
  $ 0 = v_j dot sum_i c_i v_i = sum_i c_i (v_j dot v_i) = c_j norm(v_j)^2, $
  since all cross terms vanish. As $v_j != 0$, $c_j = 0$. This holds for
  every $j$.
]

#theorem(title: "coordinates in an orthonormal basis are free")[
  If ${q_1, dots, q_n}$ is an orthonormal basis of $V$ and $v in V$, then
  $ v = sum_(i=1)^n (v dot q_i) q_i. $
]

#proof[
  Write $v = sum c_i q_i$ (possible, since it is a basis). Dot with $q_j$:
  all terms vanish except $i = j$, leaving $v dot q_j = c_j norm(q_j)^2 = c_j$.
]

That formula is a Fourier series in miniature. The coefficients of a function
in the basis of sines and cosines are computed by exactly this recipe, with
the integral $integral f g$ playing the role of the dot product.

== Orthogonal complements

#definition[
  For a subspace $W subset.eq RR^n$,
  $ W^perp = {v in RR^n : v dot w = 0 "for all" w in W}. $
]

#theorem(title: "orthogonal decomposition")[
  For any subspace $W$ of $RR^n$, every $v in RR^n$ decomposes *uniquely* as
  $ v = w + w^perp, quad w in W, thin w^perp in W^perp, $
  and $dim W + dim W^perp = n$.
]

#theorem(title: "the fundamental theorem of linear algebra")[
  For any $A in RR^(m times n)$:
  $ "Null"(A) = "Row"(A)^perp quad "in" RR^n, quad "Null"(A^T) = "Col"(A)^perp quad "in" RR^m. $
]

#proof[
  $A x = 0$ says every row of $A$ dots to zero with $x$ --- which is exactly
  the statement $x in "Row"(A)^perp$. Applying this to $A^T$ gives the second.
]

#intuition(title: "the four subspaces, pictured")[
  Chapter 20 named four subspaces; now they lock together.

  $RR^n$ (the input space) splits into two orthogonal pieces: the row space
  (dimension $r$) and the null space (dimension $n - r$).

  $RR^m$ (the output space) splits into the column space (dimension $r$) and
  the left null space (dimension $m - r$).

  And $A$ maps the row space *bijectively* onto the column space --- both have
  dimension $r$ --- while crushing the null space to zero.

  So every matrix, however complicated it looks, does one thing: it throws
  away a subspace, and acts invertibly on what is left. Rank--nullity is the
  dimension count of that picture; the SVD (Chapter 25) will give explicit
  orthonormal bases for all four pieces at once.
]

== Projection onto a subspace

#theorem(title: "projection formula")[
  Let $W = "Col"(A)$ with the columns of $A$ linearly independent. The
  orthogonal projection of $b$ onto $W$ is
  $ hat(b) = A(A^T A)^(-1) A^T b, $
  and $P = A(A^T A)^(-1) A^T$ is the *projection matrix*.
]

#proof[
  $hat(b) in W$ means $hat(b) = A x$ for some $x$. The defining property of
  orthogonal projection is that the residual $b - A x$ is orthogonal to $W$,
  i.e. orthogonal to every column of $A$:
  $ A^T (b - A x) = 0 quad arrow.r.double quad A^T A x = A^T b. $
  Independence of the columns makes $A^T A$ invertible (see below), so
  $x = (A^T A)^(-1) A^T b$ and $hat(b) = A x$.
]

#lemma[
  If the columns of $A$ are independent, $A^T A$ is invertible.
]

#proof[
  Suppose $A^T A x = 0$. Then $x^T A^T A x = 0$, i.e. $norm(A x)^2 = 0$, so
  $A x = 0$. Independence of the columns gives $x = 0$. So $A^T A$ has trivial
  null space and, being square, is invertible.
]

#proposition(title: "properties of a projection matrix")[
  $P^2 = P$ (idempotent) and $P^T = P$ (symmetric). Its eigenvalues are $0$
  and $1$: it acts as the identity on $W$ and as zero on $W^perp$.
]

#proof[
  Symmetry: $P^T = (A(A^T A)^(-1)A^T)^T = A((A^T A)^(-1))^T A^T = P$, since
  $A^T A$ is symmetric and so is its inverse.

  Idempotence: $P^2 = A(A^T A)^(-1) underbrace(A^T A (A^T A)^(-1), I) A^T = P$.
  Which is what projection should do: projecting twice is projecting once.
]

== Least squares

Now the payoff, and the most-used application of linear algebra there is.

#definition(title: "the least squares problem")[
  Given $A in RR^(m times n)$ with $m > n$ (more equations than unknowns) and
  $b in RR^m$, the system $A x = b$ generally has *no* solution. Instead find
  $ hat(x) = argmin_x norm(A x - b)^2. $
]

#theorem(title: "normal equations")[
  $hat(x)$ minimises $norm(A x - b)$ iff
  $ A^T A hat(x) = A^T b. $
  If $A$ has independent columns this has the unique solution
  $hat(x) = (A^T A)^(-1) A^T b$.
]

#proof[
  *Geometric proof.* $A x$ ranges over $"Col"(A)$ as $x$ varies. So we are
  looking for the point of $"Col"(A)$ closest to $b$ --- which is exactly the
  orthogonal projection. The residual must be orthogonal to the column space:
  $A^T(b - A hat(x)) = 0$, which rearranges to the normal equations.

  *Calculus proof.* Let $f(x) = norm(A x - b)^2 = x^T A^T A x - 2 b^T A x + b^T b$.
  By Chapter 26's rules, $nabla f = 2 A^T A x - 2 A^T b$. Setting it to zero
  gives the same equations, and the Hessian $2 A^T A$ is positive
  semidefinite, so the critical point is a minimum.

  The two proofs agreeing is not a coincidence: "the gradient vanishes" and
  "the residual is orthogonal" are the same statement.
]

#intuition(title: "why *least squares* and not least absolute error")[
  Minimising $sum abs(r_i)$ is a perfectly reasonable thing to want, and it is
  more robust to outliers. Why is squared error the default?

  *It is the only choice that makes the problem linear.* The derivative of a
  square is linear, so setting the gradient to zero gives a *linear system*
  --- solvable exactly, in closed form, in $O(m n^2)$. The absolute value has
  no derivative at zero and gives a linear program instead: solvable, but
  iteratively and more slowly.

  *It is geometry.* Squared error is squared Euclidean distance, so the
  solution is an orthogonal projection, and the entire Pythagorean apparatus
  applies.

  *It is maximum likelihood under Gaussian noise.* If $b = A x + epsilon$ with
  $epsilon tilde cal(N)(0, sigma^2 I)$, then maximising the likelihood is
  exactly minimising $norm(A x - b)^2$ (Chapter 31). So "least squares"
  encodes an assumption --- that errors are Gaussian --- and when that
  assumption is wrong (heavy tails, outliers), least squares is genuinely the
  wrong estimator and you should know it.
]

#example(title: "fitting a line")[
  Fit $y = m x + c$ to points $(x_i, y_i)$, $i = 1, dots, N$. Set
  $ A = mat(x_1, 1; x_2, 1; dots.v, dots.v; x_N, 1), quad
    beta = vec(m, c), quad b = vec(y_1, y_2, dots.v, y_N). $
  Then
  $ A^T A = mat(sum x_i^2, sum x_i; sum x_i, N), quad A^T b = vec(sum x_i y_i, sum y_i), $
  and solving the $2 times 2$ system gives the familiar formulas
  $ m = (N sum x_i y_i - sum x_i sum y_i)/(N sum x_i^2 - (sum x_i)^2), quad c = overline(y) - m overline(x). $

  Those formulas are usually presented as something to memorise. They are just
  Cramer's rule on the normal equations. And the same setup with more columns
  fits a polynomial, a multiple regression, or any linear-in-parameters model
  --- the framework does not change at all.
]

#warning(title: "do not form $A^T A$")[
  The normal equations are the right *theory* and the wrong *algorithm*.

  Forming $A^T A$ squares the condition number: $kappa(A^T A) = kappa(A)^2$.
  If $A$ has condition number $10^8$ --- unremarkable for a polynomial fit ---
  then $A^T A$ has $10^16$, and in double precision you have no digits left.

  The correct method is QR factorisation. Write $A = Q R$ with $Q$ orthogonal
  and $R$ upper triangular. Then
  $ norm(A x - b) = norm(Q R x - b) = norm(R x - Q^T b) $
  (orthogonal matrices preserve norms), and the minimiser solves the
  triangular system $R x = Q^T b$ by back-substitution. Condition number
  untouched. This is what `numpy.linalg.lstsq` and every serious library
  actually do.

  For rank-deficient or nearly rank-deficient $A$, use the SVD (Chapter 25),
  which handles the degenerate case gracefully by truncating tiny singular
  values.
]

== Gram--Schmidt and QR

#theorem(title: "Gram--Schmidt")[
  Given independent $v_1, dots, v_n$, define
  $
  u_1 &= v_1, &quad q_1 &= u_1 slash norm(u_1) \
  u_k &= v_k - sum_(j<k) (v_k dot q_j) q_j, &quad q_k &= u_k slash norm(u_k).
  $
  Then ${q_1, dots, q_n}$ is orthonormal and spans the same space, with
  $span{q_1,dots,q_k} = span{v_1,dots,v_k}$ for every $k$.
]

#proof[
  By induction. Suppose $q_1, dots, q_(k-1)$ are orthonormal with the right
  spans. Then for $i < k$,
  $ u_k dot q_i = v_k dot q_i - sum_(j<k) (v_k dot q_j)(q_j dot q_i) = v_k dot q_i - v_k dot q_i = 0, $
  using orthonormality to kill all but the $j = i$ term. So $u_k$ is
  orthogonal to all previous $q$'s. It is nonzero because $v_k$ is not in the
  span of the earlier vectors (independence), and normalising gives $q_k$.
]

The idea in one line: *subtract off everything that is already accounted for,
keep what is new.* The sum is exactly the projection onto the span of what
came before.

#theorem(title: "QR factorisation")[
  Every $A in RR^(m times n)$ with independent columns factors as $A = Q R$
  with $Q in RR^(m times n)$ having orthonormal columns and $R in RR^(n times n)$
  upper triangular with positive diagonal.
]

#proof[
  Run Gram--Schmidt on the columns of $A$ to get the columns of $Q$. Since
  each $v_k$ is a combination of $q_1, dots, q_k$ only --- never of later ones
  --- the coefficient matrix $R$ with $R_(j k) = v_k dot q_j$ is upper
  triangular, and $A = Q R$ by construction.
]

#warning(title: "classical Gram--Schmidt is numerically unstable")[
  Written exactly as stated, Gram--Schmidt loses orthogonality badly in
  floating point: the computed $q_k$ drift away from perpendicular as $k$
  grows, and for ill-conditioned input they can end up almost parallel.

  *Modified Gram--Schmidt* --- subtract each projection immediately and update
  the running vector, rather than computing all the projections against the
  original $v_k$ --- is mathematically identical and substantially more
  stable.

  Better still are *Householder reflections*, which build $Q$ as a product of
  reflections rather than by orthogonalising. Householder QR is
  backward-stable and is what libraries implement. Gram--Schmidt is how you
  *understand* QR; Householder is how you *compute* it.
]

== Function spaces and Fourier, briefly

Everything above needed only an *inner product* --- a way to multiply two
vectors into a scalar with the right properties. So it all works in any space
that has one, including spaces of functions.

#definition[
  On $C[-pi, pi]$, define
  $ lr(⟨ f, g ⟩) = integral_(-pi)^pi f(x) g(x) dif x. $
]

#proposition[
  The functions $1, cos x, sin x, cos 2x, sin 2x, dots$ are *orthogonal* under
  this inner product.
]

#proof[
  Each integral $integral_(-pi)^pi cos(m x) cos(n x) dif x$ with $m != n$ is
  evaluated by the product-to-sum identity (Chapter 5), giving integrals of
  $cos((m plus.minus n)x)$ over a whole number of periods, which vanish.
  Similarly for the other combinations.
]

So the Fourier coefficients
$ a_n = 1/pi integral_(-pi)^pi f(x) cos(n x) dif x $
are exactly the coordinate formula of this chapter, in the basis of sinusoids.
Truncating the Fourier series to $N$ terms is *orthogonal projection onto the
span of the first $N$ basis functions*, which is why the truncation is the
best possible $N$-term approximation in the mean-square sense.

That is the whole conceptual content of Fourier analysis. The rest is
computation, and the FFT (Chapter 6) is how you do it fast.

== Exercises

#exercise[
  Apply Gram--Schmidt to $v_1 = (1,1,0)$, $v_2 = (1,0,1)$, $v_3 = (0,1,1)$ and
  verify the result is orthonormal.
]

#exercise[
  Find the orthogonal projection of $b = (1,2,3)$ onto the plane spanned by
  $(1,0,1)$ and $(0,1,1)$, and verify that the residual is orthogonal to both
  spanning vectors.
]

#exercise[
  Fit a least-squares line to the points $(1,1), (2,3), (3,4), (4,6)$ by
  setting up and solving the normal equations by hand.
]

#exercise[
  Prove that if $P$ is a projection matrix then $I - P$ is also a projection
  matrix, and identify which subspace it projects onto.
]

#exercise[
  Let $A$ be $m times n$ with independent columns. Prove that
  $"Null"(A^T A) = "Null"(A)$, and deduce that $rank(A^T A) = rank(A)$ for
  *any* $A$, independent columns or not.
]

#exercise[
  Show that for an orthogonal matrix $Q$, $kappa(Q) = 1$ in the 2-norm. Then
  explain in one sentence why this is the reason QR-based least squares beats
  the normal equations.
]

#exercise[
  Find the QR factorisation of $ A = mat(1, 1; 1, 0; 0, 1) $ using
  Gram--Schmidt, and use it to solve the least-squares problem
  $A x approx (1, 2, 3)^T$.
]

#exercise[
  Verify by direct integration that $integral_(-pi)^pi sin(2x) cos(3x) dif x = 0$,
  and state the general principle it illustrates.
]
