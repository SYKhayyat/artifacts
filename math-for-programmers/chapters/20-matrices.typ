#import "../lib.typ": *

= Matrices Are Functions

== The single idea of this chapter

A matrix is not a table of numbers. A matrix is a *function* --- specifically,
a linear function --- written down in a particular way. Everything strange
about matrices becomes obvious once you believe that, and stays strange
forever if you do not.

#definition(title: "linear map")[
  A function $T : RR^n -> RR^m$ is *linear* if for all $u, v$ and scalars $c$:
  $ T(u + v) = T(u) + T(v), quad T(c u) = c thin T(u). $
]

Equivalently, $T(a u + b v) = a T(u) + b T(v)$: *linear maps preserve linear
combinations.* Note $T(0) = 0$ always, so $x arrow.bar x + 1$ is not linear
(it is *affine*).

#theorem(title: "every linear map is a matrix")[
  Let $T : RR^n -> RR^m$ be linear and let $e_1, dots, e_n$ be the standard
  basis of $RR^n$. Define $A$ to be the $m times n$ matrix whose $j$-th column
  is $T(e_j)$. Then $T(x) = A x$ for every $x$.
]

#proof[
  Write $x = x_1 e_1 + dots.c + x_n e_n$. By linearity,
  $ T(x) = x_1 T(e_1) + x_2 T(e_2) + dots.c + x_n T(e_n). $
  The right-hand side is precisely the linear combination of the columns of
  $A$ with coefficients $x_i$, which is the definition of $A x$.
]

#intuition(title: "this theorem is why matrices exist")[
  A general function $RR^n -> RR^m$ needs infinite information to specify.
  A *linear* one is pinned down by what it does to $n$ basis vectors ---
  because linearity forces everything else.

  So a matrix is a finite encoding of an infinite object, and the encoding is
  exactly "where each basis vector goes". Read that way:

  - The columns of $A$ are the images of the basis vectors. To see what a
    matrix does, look at its columns as destinations.
  - $A x$ is *a linear combination of the columns of $A$*, weighted by the
    entries of $x$. This is the single most useful way to read matrix--vector
    multiplication, more useful than the row-by-row dot product recipe.
  - The set of possible outputs is the span of the columns --- the *column
    space*.
]

#example(title: "reading a matrix off its geometry")[
  What matrix rotates $RR^2$ by angle $theta$?

  Do not derive; just ask where the basis vectors go. $e_1 = (1,0)$ lands on
  $(cos theta, sin theta)$, straight off the unit circle. $e_2 = (0,1)$ is a
  quarter turn ahead, so it lands on $(-sin theta, cos theta)$. Those are the
  columns:
  $ R_theta = mat(cos theta, -sin theta; sin theta, cos theta). $

  Similarly, scaling by $s_x, s_y$ is $mat(s_x, 0; 0, s_y)$; reflection in the
  $x$-axis is $mat(1,0;0,-1)$; the shear that slides $x$ by $k y$ is
  $mat(1,k;0,1)$ --- because $e_1 arrow.bar e_1$ and $e_2 arrow.bar (k,1)$.

  You can now write down any linear transformation you can picture, with no
  algebra.
]

== Matrix multiplication is composition

#definition(title: "matrix product")[
  For $A in RR^(m times p)$ and $B in RR^(p times n)$, the product $A B$ is
  the $m times n$ matrix with
  $ (A B)_(i j) = sum_(k=1)^p A_(i k) B_(k j). $
]

#theorem[
  $A B$ is the matrix of the composition: $(A B) x = A(B x)$ for all $x$.
]

#proof[
  Compute the $i$-th entry of $A(B x)$:
  $ (A(B x))_i = sum_k A_(i k) (B x)_k = sum_k A_(i k) sum_j B_(k j) x_j = sum_j ( sum_k A_(i k) B_(k j) ) x_j = ((A B) x)_i. $
]

#intuition(title: "why the formula looks like that")[
  The formula $sum_k A_(i k) B_(k j)$ is not arbitrary and it is not a
  convention. It is: *to get from input $j$ to output $i$, sum over every
  intermediate slot $k$; along each route, multiply the two gains.*

  Sum over paths, multiply along paths. That is the same reading as:

  - Chapter 10's theorem that $(A^k)_(i j)$ counts walks of length $k$;
  - Chapter 18's multivariate chain rule, where Jacobians multiply;
  - composition of relations, and of probability transition matrices.

  All four are the same computation. Once you see composition, the definition
  is forced.
]

Consequences that now need no memorisation:

*Dimensions must match.* $(m times p)(p times n) = (m times n)$. You cannot
compose $g compose f$ unless $f$'s outputs are $g$'s inputs.

*$A B != B A$ in general.* Rotating then scaling differs from scaling then
rotating. Function composition is not commutative, so matrix multiplication is
not either. Do not expect it to be, ever.

*$A(B C) = (A B) C$.* Composition is associative (Chapter 3), so this is free.
It is also the most economically important identity in numerical computing:
the two groupings can differ by orders of magnitude in cost. Multiplying
$(1000 times 1) dot (1 times 1000) dot (1000 times 1)$ left-to-right costs a
million operations; right-to-left costs two thousand. This is why
reverse-mode autodiff wins (Chapter 18) and why matrix-chain ordering is a
classic dynamic programming problem.

*$A B = 0$ does not imply $A = 0$ or $B = 0$.* Two nonzero maps can compose to
nothing if the first sends everything into the second's null space.

== The basic operations

#definition[
  - *Transpose:* $(A^T)_(i j) = A_(j i)$. Flip across the main diagonal.
  - *Identity:* $I_n$, ones on the diagonal, zeros elsewhere; $A I = I A = A$.
  - *Inverse:* $A^(-1)$ with $A A^(-1) = A^(-1) A = I$, when it exists.
  - *Trace:* $tr(A) = sum_i A_(i i)$, defined for square $A$.
]

#proposition(title: "transpose rules")[
  $(A+B)^T = A^T + B^T$, $(c A)^T = c A^T$, $(A^T)^T = A$, and crucially
  $ (A B)^T = B^T A^T. $
]

#proof[
  $((A B)^T)_(i j) = (A B)_(j i) = sum_k A_(j k) B_(k i) = sum_k (B^T)_(i k)(A^T)_(k j) = (B^T A^T)_(i j)$.
]

The order reversal is the same phenomenon as $(A B)^(-1) = B^(-1) A^(-1)$:
undoing a composition means undoing the last step first. Socks then shoes;
shoes off then socks off.

#proposition(title: "trace is cyclic")[
  $tr(A B) = tr(B A)$, and more generally $tr(A B C) = tr(C A B)$.
]

#proof[
  $tr(A B) = sum_i sum_k A_(i k) B_(k i) = sum_k sum_i B_(k i) A_(i k) = tr(B A)$,
  just by swapping the order of two finite sums.
]

Cyclicity looks minor and is used constantly in matrix calculus (Chapter 26)
to move factors around inside a trace until a derivative is recognisable.

== Special matrices worth recognising

#align(center)[
  #table(
    columns: 2,
    inset: 7pt,
    align: (left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Type*], [*Definition and significance*]),
    [Diagonal], [Nonzero only on the diagonal. Acts by independent scaling of each coordinate. Trivial to invert, exponentiate, and multiply.],
    [Symmetric], [$A^T = A$. Real eigenvalues, orthogonal eigenvectors (Ch. 23). Covariance matrices and Hessians are symmetric.],
    [Orthogonal], [$Q^T Q = I$, so $Q^(-1) = Q^T$. Preserves lengths and angles: a rotation or reflection. Numerically ideal --- never amplifies error.],
    [Triangular], [Zeros above (lower) or below (upper) the diagonal. Solvable by back-substitution in $O(n^2)$. The output of LU and QR.],
    [Positive definite], [Symmetric with $x^T A x > 0$ for all $x != 0$. Defines a genuine "energy". Cholesky-factorisable; the Hessian at a strict minimum.],
    [Sparse], [Mostly zeros. Not a mathematical class but the dominant practical one --- graphs, meshes, and discretised PDEs give sparse matrices, and exploiting that is the difference between feasible and impossible.],
    [Permutation], [A single 1 in each row and column. Reorders coordinates. Orthogonal, and its inverse is its transpose.],
  )
]

#proposition(title: "orthogonal matrices preserve geometry")[
  If $Q^T Q = I$ then $norm(Q x) = norm(x)$ and $(Q x) dot (Q y) = x dot y$.
]

#proof[
  $ (Q x) dot (Q y) = (Q x)^T (Q y) = x^T Q^T Q y = x^T I y = x dot y. $
  Setting $y = x$ and taking square roots gives the norm statement.
]

This is why numerical algorithms prefer orthogonal transformations wherever
possible: they cannot magnify an error, since they do not magnify anything.
Gaussian elimination can lose precision badly; QR factorisation, built from
orthogonal steps, cannot. Chapter 33 makes that precise.

== Block matrices

A matrix can be partitioned into submatrices and multiplied blockwise, as long
as the block dimensions are compatible:
$ mat(A, B; C, D) mat(X; Y) = mat(A X + B Y; C X + D Y). $

This is not just notation. It is the basis of cache-blocked matrix
multiplication (operate on tiles that fit in cache), of Strassen's algorithm
(Chapter 11), and of how a transformer's multi-head attention is implemented
as one big matrix multiply rather than many small ones.

== The four fundamental subspaces

#definition[
  For $A in RR^(m times n)$:
  $
  "Col"(A) &= {A x : x in RR^n} subset.eq RR^m &quad& "(column space, or range)" \
  "Null"(A) &= {x : A x = 0} subset.eq RR^n &quad& "(null space, or kernel)" \
  "Row"(A) &= "Col"(A^T) subset.eq RR^n \
  "Null"(A^T) &subset.eq RR^m &quad& "(left null space)"
  $
]

Each is a subspace (check the three conditions). The two that matter most:

*The column space* is *what outputs are achievable*. $A x = b$ has a solution
iff $b in "Col"(A)$.

*The null space* is *what inputs get destroyed*. If $x in "Null"(A)$, then
$A(x_0 + x) = A x_0$, so solutions are never unique when the null space is
bigger than ${0}$.

#theorem(title: "solutions to a linear system")[
  If $A x_0 = b$, then the full solution set is
  $ {x_0 + z : z in "Null"(A)}. $
]

#proof[
  If $A z = 0$ then $A(x_0 + z) = b$. Conversely if $A x = b$ then
  $A(x - x_0) = 0$, so $x - x_0 in "Null"(A)$.
]

So a linear system has either no solution ($b in.not "Col"(A)$), exactly one
($b in "Col"(A)$ and $"Null"(A) = {0}$), or infinitely many. Never exactly
two. That trichotomy is a complete answer to "what can happen", and Chapter 21
turns it into an algorithm.

#intuition(title: "injective, surjective, bijective --- again")[
  Chapter 3's three words, now for matrices:

  - $A$ is *injective* iff $"Null"(A) = {0}$ iff the columns are independent.
  - $A$ is *surjective* iff $"Col"(A) = RR^m$ iff the columns span $RR^m$.
  - $A$ is *bijective* (invertible) iff both. This requires $m = n$.

  Chapter 3 said linear algebra is what happens to function theory when the
  functions are linear. This is that promise being kept.
]

== Inverses

#definition[
  A square $A$ is *invertible* (or *nonsingular*) if there is $A^(-1)$ with
  $A A^(-1) = A^(-1) A = I$.
]

#theorem(title: "the invertible matrix theorem, first instalment")[
  For square $A in RR^(n times n)$, the following are equivalent:

  #set enum(numbering: "(i)")
  + $A$ is invertible.
  + $A x = b$ has a unique solution for every $b$.
  + $A x = 0$ has only the solution $x = 0$.
  + The columns of $A$ are linearly independent.
  + The columns of $A$ span $RR^n$.
  + $rank(A) = n$.
  + $det A != 0$ (Chapter 22).
  + $0$ is not an eigenvalue of $A$ (Chapter 23).
]

The equivalences are proved as the machinery arrives; the list is here so you
have it in one place. Learn it as a single fact with eight faces --- in
practice you check whichever face is cheapest and conclude all the others.

For $2 times 2$:
$ mat(a,b;c,d)^(-1) = 1/(a d - b c) mat(d, -b; -c, a), $
valid when $a d - b c != 0$. That quantity is the determinant.

#warning(title: "never actually compute an inverse")[
  To solve $A x = b$, do *not* compute $A^(-1)$ and multiply. Factor $A$ (LU
  or QR) and solve by substitution.

  Three reasons. It is about three times more arithmetic. It is numerically
  worse --- forming the inverse introduces error that solving directly avoids.
  And it destroys sparsity: the inverse of a sparse matrix is generally dense,
  so a matrix that fit in memory produces an inverse that does not.

  When mathematical writing says $x = A^(-1) b$, read it as "solve the system",
  not as an instruction to invert. Numerical libraries make this distinction
  in their API for exactly this reason: `solve(A, b)`, not `inv(A) @ b`.
]

== Matrices as data versus matrices as maps

Both readings are legitimate and you should know which one you are using.

*As a map:* a rotation, a projection, a network layer. Multiplication is
composition, and the natural questions are about eigenvalues, invertibility,
and geometry.

*As data:* a table of $m$ observations by $n$ features, an adjacency matrix, a
grayscale image. Multiplication does something less obvious, and the natural
questions are about low-rank approximation and factorisation.

The bridge between the two is the SVD (Chapter 25), which says that *every*
matrix, read either way, is a rotation, then a scaling, then a rotation.

== Exercises

#exercise[
  Let $A = mat(1,2;3,4)$ and $B = mat(0,1;1,0)$. Compute $A B$ and $B A$ and
  confirm they differ. Describe in words what $B$ does geometrically.
]

#exercise[
  Write the $3 times 3$ matrix that reflects $RR^3$ in the $x y$-plane, and
  the one that rotates $RR^3$ by $90 degree$ about the $z$-axis. Find their
  product both ways and describe the two resulting transformations.
]

#exercise[
  Prove that if $A$ and $B$ are invertible then $A B$ is invertible with
  $(A B)^(-1) = B^(-1) A^(-1)$. Then show by example that $A + B$ need not be
  invertible even when both are.
]

#exercise[
  Show that $tr(A^T A) = sum_(i,j) A_(i j)^2$, and explain why this means
  $tr(A^T A) = 0$ forces $A = 0$. (This quantity is the squared *Frobenius
  norm* of $A$.)
]

#exercise[
  Find the null space and column space of
  $ A = mat(1,2,3; 2,4,6). $
  State the dimension of each and check they sum to the number of columns.
]

#exercise[
  Prove that if $Q_1$ and $Q_2$ are orthogonal then so is $Q_1 Q_2$. (Together
  with the inverse property this makes the orthogonal matrices a group,
  Chapter 8.)
]

#exercise[
  You must compute $A B C$ where $A$ is $100 times 5$, $B$ is $5 times 100$,
  and $C$ is $100 times 1$. Count the scalar multiplications for both
  association orders and state the ratio.
]

#exercise[
  Prove that the set of $2 times 2$ matrices of the form $mat(a, -b; b, a)$ is
  closed under addition and multiplication, and show that this set behaves
  exactly like the complex numbers of Chapter 6. What matrix corresponds to
  $i$, and what is its square?
]
