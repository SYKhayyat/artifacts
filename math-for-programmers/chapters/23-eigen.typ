#import "../lib.typ": *

= Eigenvalues and Eigenvectors

== The question

A matrix moves vectors around: it rotates them, stretches them, shears them.
Most vectors change direction.

*Some do not.* For those, the matrix acts as pure scaling --- multiplication
by a number. Those directions are the *eigenvectors*, and the numbers are the
*eigenvalues*, and finding them is the closest thing linear algebra has to a
central problem.

#definition(title: "eigenvalue and eigenvector")[
  For square $A$, a nonzero vector $v$ is an *eigenvector* with *eigenvalue*
  $lambda$ if
  $ A v = lambda v. $
  The set of all eigenvectors for a given $lambda$, together with $0$, is the
  *eigenspace* --- a subspace.
]

We require $v != 0$ because $A dot 0 = lambda dot 0$ for every $lambda$,
which would make the definition vacuous. Eigenvalues may be zero; eigenvectors
may not.

#intuition(title: "why anyone cares")[
  Along an eigenvector, a matrix is *just a number*. All the complexity of the
  linear map collapses to scalar multiplication.

  If you can find a whole basis of eigenvectors, then in *that* basis the
  matrix is diagonal --- the coordinates do not interact at all, and every
  question about the matrix becomes $n$ independent scalar questions.

  That is why they matter. Eigen-decomposition is the search for the
  coordinate system in which a problem falls apart into independent pieces.
  Applications:

  - $A^k$ becomes $lambda^k$: matrix powers, Markov chains, linear
    recurrences (Chapter 11).
  - Stability: the system runs away iff some $abs(lambda) > 1$ (discrete) or
    $"Re"(lambda) > 0$ (continuous).
  - Principal components: the eigenvectors of the covariance matrix are the
    directions of greatest variance.
  - PageRank: the ranking vector is the dominant eigenvector of the link
    matrix.
  - Vibration and resonance: eigenvalues are the natural frequencies.
]

== Finding them

$A v = lambda v$ rearranges to $(A - lambda I) v = 0$, which asks for a
nonzero null-space vector of $A - lambda I$. By Chapter 22 that happens
exactly when the matrix is singular:

#definition(title: "characteristic polynomial")[
  $ p_A (lambda) = det(A - lambda I). $
  Its roots are exactly the eigenvalues of $A$. It is a degree-$n$ polynomial
  in $lambda$.
]

#algo(title: "Eigen-decomposition by hand (small matrices only)")[
```
1. Form det(A - lambda I) and expand: a degree-n polynomial.
2. Find its roots.  These are the eigenvalues.
3. For each eigenvalue, solve (A - lambda I)v = 0 by elimination.
   The null space basis vectors are the eigenvectors.
```
]

#example(title: "a worked 2x2")[
  $ A = mat(4, 1; 2, 3). $

  $ det(A - lambda I) = det mat(4-lambda, 1; 2, 3-lambda) = (4-lambda)(3-lambda) - 2 = lambda^2 - 7lambda + 10, $
  with roots $lambda = 5$ and $lambda = 2$.

  For $lambda = 5$: solve $mat(-1, 1; 2, -2) v = 0$, giving $v_1 = v_2$, so
  $v = (1,1)^T$ (any nonzero multiple).

  For $lambda = 2$: solve $mat(2,1;2,1) v = 0$, giving $2 v_1 = -v_2$, so
  $v = (1,-2)^T$.

  Sanity checks: the eigenvalues sum to $7 = tr(A)$ and multiply to
  $10 = det A$. Always do this; it catches most arithmetic errors.
]

#theorem(title: "trace and determinant from eigenvalues")[
  With eigenvalues $lambda_1, dots, lambda_n$ counted with multiplicity,
  $ tr(A) = sum_i lambda_i, quad det(A) = product_i lambda_i. $
]

#proof[
  $p_A (lambda) = det(A - lambda I) = product_i (lambda_i - lambda)$ by the
  factor theorem (Chapter 2), since the $lambda_i$ are exactly its roots and
  the leading coefficient works out.

  Setting $lambda = 0$ gives $det A = product lambda_i$.

  Comparing coefficients of $lambda^(n-1)$ on both sides gives
  $tr(A) = sum lambda_i$, by Vieta's relations (Chapter 2) applied to the
  characteristic polynomial. This is the promise made in Chapter 2, now
  delivered.
]

#warning(title: "the characteristic polynomial is a terrible algorithm")[
  For anything larger than $3 times 3$, do not compute eigenvalues by finding
  roots of $p_A$.

  Polynomial root-finding is severely ill-conditioned: tiny changes in the
  coefficients can move the roots enormously (*Wilkinson's polynomial* is the
  standard horror story). And going from $A$ to its characteristic polynomial
  throws away structure the algorithm could have used.

  Real algorithms --- the QR algorithm, and Krylov methods like Lanczos and
  Arnoldi for large sparse problems --- work on the matrix directly with
  orthogonal transformations, which cannot amplify error (Chapter 20). The
  characteristic polynomial is a definition, not a method.

  Amusingly, the relationship runs the other way in practice: to find roots of
  a polynomial, numerical libraries build its *companion matrix* and compute
  eigenvalues.
]

== Diagonalisation

#definition(title: "diagonalisable")[
  $A$ is *diagonalisable* if there is an invertible $P$ and diagonal $D$ with
  $ A = P D P^(-1). $
]

#theorem[
  $A$ is diagonalisable iff it has $n$ linearly independent eigenvectors. In
  that case the columns of $P$ are those eigenvectors and the diagonal entries
  of $D$ are the corresponding eigenvalues.
]

#proof[
  Suppose $v_1, dots, v_n$ are independent eigenvectors with eigenvalues
  $lambda_i$. Let $P = [v_1 | dots.c | v_n]$. Then
  $ A P = [A v_1 | dots.c | A v_n] = [lambda_1 v_1 | dots.c | lambda_n v_n] = P D. $
  $P$ is invertible since its columns are independent, so $A = P D P^(-1)$.

  Conversely, if $A = P D P^(-1)$ then $A P = P D$, and reading that column by
  column says each column of $P$ is an eigenvector. $P$ invertible makes them
  independent.
]

#intuition(title: "diagonalisation is a change of coordinates")[
  Read $A = P D P^(-1)$ right to left, as a pipeline applied to a vector $x$:

  + $P^(-1) x$: rewrite $x$ in the eigenvector basis. "What are your
    coordinates in the natural coordinate system for this problem?"
  + $D dot$: scale each coordinate independently. Trivial.
  + $P dot$: translate back to the original coordinates.

  So $A$ *is* a diagonal matrix; you were just looking at it in the wrong
  basis. Similar matrices $A$ and $P^(-1) A P$ are the same map described by
  two different observers.

  Once you see this, the computational payoff is obvious:
  $ A^k = (P D P^(-1))^k = P D^k P^(-1), $
  because all the interior $P^(-1) P$ pairs cancel. And $D^k$ is just each
  diagonal entry raised to the $k$. An $O(n^3 k)$ computation becomes $O(n^3)$
  plus $n$ scalar powers.
]

#example(title: "Fibonacci, closed form, again")[
  Chapter 11 solved $F_n = F_(n-1) + F_(n-2)$ with characteristic roots. Here
  is the same thing as diagonalisation.
  $ vec(F_(n+1), F_n) = mat(1,1;1,0) vec(F_n, F_(n-1)), quad M = mat(1,1;1,0). $
  So $vec(F_(n+1), F_n) = M^n vec(1,0)$.

  $det(M - lambda I) = lambda^2 - lambda - 1$, whose roots are $phi$ and
  $psi$ --- the *same polynomial* as Chapter 11's characteristic equation, and
  now you can see why: a linear recurrence is a matrix power, and its
  characteristic equation is the matrix's characteristic polynomial.

  Diagonalising and extracting the second component gives Binet's formula.
  And since $M^n$ can be computed by repeated squaring, $F_n$ is available in
  $O(log n)$ big-integer multiplications.
]

#theorem(title: "distinct eigenvalues give independent eigenvectors")[
  Eigenvectors corresponding to distinct eigenvalues are linearly independent.
  In particular, a matrix with $n$ distinct eigenvalues is diagonalisable.
]

#proof[
  Induction on the number of eigenvectors. Suppose
  $c_1 v_1 + dots.c + c_k v_k = 0$ with distinct $lambda_i$, and that any
  $k-1$ of them are independent.

  Apply $A$: $sum c_i lambda_i v_i = 0$. Also multiply the original by
  $lambda_k$: $sum c_i lambda_k v_i = 0$. Subtract:
  $ sum_(i=1)^(k-1) c_i (lambda_i - lambda_k) v_i = 0. $
  By the inductive hypothesis these $k-1$ vectors are independent, so every
  $c_i (lambda_i - lambda_k) = 0$; since the eigenvalues are distinct,
  $c_i = 0$ for $i < k$. Then $c_k v_k = 0$ forces $c_k = 0$ too.
]

=== When diagonalisation fails

#example(title: "a defective matrix")[
  $ A = mat(1,1;0,1). $
  $det(A - lambda I) = (1-lambda)^2$, so $lambda = 1$ with *algebraic
  multiplicity* 2. But solving $(A - I)v = 0$ gives $mat(0,1;0,0)v = 0$, i.e.
  $v_2 = 0$: the eigenspace is only one-dimensional. *Geometric multiplicity*
  1.

  There is no basis of eigenvectors, so $A$ is not diagonalisable. Such a
  matrix is called *defective*.

  Geometrically, $A$ is a shear. A shear fixes one direction and tilts
  everything else; it has no second invariant direction to find.
]

The general repair is the *Jordan normal form*: every matrix is similar to a
block-diagonal matrix with eigenvalues on the diagonal and some $1$s on the
superdiagonal. It is theoretically complete and numerically useless --- the
Jordan structure is destroyed by any perturbation, since an arbitrarily small
change makes the eigenvalues distinct. In practice, use the SVD (Chapter 25),
which always exists and is stable.

== The symmetric case, which is the good case

#theorem(title: "spectral theorem")[
  Let $A$ be real and symmetric ($A^T = A$). Then:

  #set enum(numbering: "(i)")
  + All eigenvalues of $A$ are real.
  + Eigenvectors for distinct eigenvalues are *orthogonal*.
  + $A$ is always diagonalisable, by an *orthogonal* matrix:
    $ A = Q Lambda Q^T, quad Q^T Q = I. $
]

#proof[
  *(i)* Let $A v = lambda v$ with $v$ possibly complex, and let
  $overline(v)^T$ denote the conjugate transpose. Then
  $ overline(v)^T A v = lambda overline(v)^T v = lambda norm(v)^2. $
  Taking the conjugate transpose of the left side, and using
  $A^T = A$ with $A$ real:
  $ overline(overline(v)^T A v) = v^T A overline(v) = overline(lambda) norm(v)^2. $
  But the left side is a $1 times 1$ real-symmetric quantity equal to its own
  conjugate, so $lambda norm(v)^2 = overline(lambda) norm(v)^2$. Since
  $norm(v)^2 > 0$, $lambda = overline(lambda)$: real.

  *(ii)* Let $A u = lambda u$, $A v = mu v$ with $lambda != mu$. Then
  $ lambda (u dot v) = (A u) dot v = u^T A^T v = u^T A v = u dot (A v) = mu (u dot v), $
  using symmetry in the middle. So $(lambda - mu)(u dot v) = 0$, and since
  $lambda != mu$, $u dot v = 0$.

  *(iii)* Requires an induction on dimension (restrict $A$ to the orthogonal
  complement of one eigenvector and repeat); the content is that even repeated
  eigenvalues get a full orthogonal eigenspace in the symmetric case.
]

#intuition(title: "why symmetric matrices are the ones you actually meet")[
  The spectral theorem is one of the most useful theorems in applied
  mathematics, and it applies to almost everything you care about:

  - *Covariance matrices* $Sigma = EE[(X - mu)(X-mu)^T]$ are symmetric by
    construction. Their eigenvectors are the principal components.
  - *Hessians* are symmetric by Clairaut (Chapter 18). Their eigenvalues are
    the curvatures.
  - *Graph Laplacians* $L = D - A$ are symmetric for undirected graphs.
  - *Gram matrices* $A^T A$ are always symmetric, whatever $A$ is.
  - Kernel matrices, adjacency matrices, distance matrices, inertia tensors.

  In each case you get: real eigenvalues (no complex bookkeeping), an
  *orthonormal* eigenbasis (so $P^(-1) = P^T$ --- inversion is free and
  numerically perfect), and the guarantee that diagonalisation never fails.
]

#definition(title: "positive definite")[
  A symmetric $A$ is *positive definite* if $x^T A x > 0$ for all $x != 0$,
  and *positive semidefinite* if $x^T A x >= 0$.
]

#theorem[
  A symmetric matrix is positive definite iff all its eigenvalues are
  positive.
]

#proof[
  Write $x = Q y$ in the eigenbasis. Then
  $ x^T A x = y^T Q^T Q Lambda Q^T Q y = y^T Lambda y = sum_i lambda_i y_i^2. $
  This is positive for all $y != 0$ iff every $lambda_i > 0$: sufficiency is
  clear, and if some $lambda_j <= 0$ take $y = e_j$.
]

That computation is worth keeping. It says a quadratic form, in the
eigenbasis, is just a weighted sum of squares --- so the geometry of
$x^T A x = 1$ is an ellipsoid with axes along the eigenvectors and
semi-axis lengths $1 slash sqrt(lambda_i)$. Chapter 34 uses exactly this
picture for optimisation.

== Powers, stability, and the dominant eigenvalue

#definition(title: "spectral radius")[
  $ rho(A) = max_i abs(lambda_i). $
]

#theorem[
  $A^k -> 0$ as $k -> infinity$ if and only if $rho(A) < 1$.
]

#proof[
  For diagonalisable $A$, $A^k = P Lambda^k P^(-1)$ and
  $Lambda^k = diag(lambda_i^k)$, which tends to $0$ iff every
  $abs(lambda_i) < 1$. (The defective case needs a Jordan-form argument but
  the conclusion is the same.)
]

#example(title: "Markov chains and PageRank")[
  A *stochastic matrix* has nonnegative entries and columns summing to 1: it
  transports probability. Then:

  - $lambda = 1$ is always an eigenvalue (the all-ones vector is a left
    eigenvector, since columns sum to 1).
  - All eigenvalues satisfy $abs(lambda) <= 1$ (probability cannot grow).
  - The eigenvector for $lambda = 1$ is the *stationary distribution* $pi$
    with $P pi = pi$.

  *Perron--Frobenius* guarantees that if the chain is irreducible and
  aperiodic, $lambda = 1$ is simple and every other eigenvalue is strictly
  smaller in modulus. Then from any start, $P^k x -> pi$, and the *rate* of
  convergence is governed by $abs(lambda_2)$: the *spectral gap*
  $1 - abs(lambda_2)$ is the mixing rate.

  PageRank is exactly this: a random surfer's transition matrix, damped to
  guarantee irreducibility, and the ranking is the dominant eigenvector. It is
  computed by *power iteration*, which is the crudest possible eigenvalue
  algorithm and here the right one.
]

#algo(title: "Power iteration")[
```
x := random nonzero vector
repeat:
    x := A x
    x := x / ||x||          # renormalise to avoid overflow
converges to the dominant eigenvector; the Rayleigh quotient
x^T A x / (x^T x) converges to the dominant eigenvalue.
```
]

#proof[
  Expand $x_0 = sum c_i v_i$ in the eigenbasis. Then
  $ A^k x_0 = sum_i c_i lambda_i^k v_i = lambda_1^k ( c_1 v_1 + sum_(i>=2) c_i (lambda_i/lambda_1)^k v_i ). $
  If $abs(lambda_1) > abs(lambda_i)$ for all $i >= 2$, every ratio tends to
  zero and the direction converges to $v_1$. The error decays like
  $(abs(lambda_2) slash abs(lambda_1))^k$ --- so a large spectral gap means
  fast convergence, and a small one means slow.

  The renormalisation exists only to stop $lambda_1^k$ from overflowing; it
  does not affect the direction.
]

== Exercises

#exercise[
  Find the eigenvalues and eigenvectors of $ mat(3, 1; 1, 3) $ and verify
  that the eigenvectors are orthogonal, as the spectral theorem promises.
]

#exercise[
  Find the eigenvalues of $ mat(2, -1; 1, 2). $ They are complex --- interpret
  the matrix geometrically and explain what the eigenvalues say about it.
  (Compare Chapter 6.)
]

#exercise[
  Show that $ A = mat(2,1;0,2) $ is not diagonalisable, by computing the
  algebraic and geometric multiplicities of its eigenvalue.
]

#exercise[
  Prove that $A$ and $A^T$ have the same eigenvalues. (Consider the
  characteristic polynomial and use $det(M^T) = det(M)$.) Do they have the
  same eigenvectors?
]

#exercise[
  Let $A$ be invertible with eigenvalue $lambda$ and eigenvector $v$. Show
  that $A^(-1)$ has eigenvalue $1 slash lambda$ with the same eigenvector, and
  that $A^2$ has eigenvalue $lambda^2$.
]

#exercise[
  Diagonalise $ A = mat(5, -2; -2, 5) $ and use the result to compute $A^10$
  without multiplying matrices ten times.
]

#exercise[
  Determine whether $ mat(2,1;1,2) $ and $ mat(1, 2; 2, 1) $ are positive
  definite, by computing eigenvalues. Then check your answers by testing
  $x^T A x$ on a well-chosen $x$.
]

#exercise[
  A Markov chain has transition matrix $ P = mat(0.9, 0.4; 0.1, 0.6) $
  (columns sum to 1). Find its stationary distribution as the eigenvector for
  $lambda = 1$, find $lambda_2$, and state how many steps it takes for the
  deviation from stationarity to shrink by a factor of 100.
]
