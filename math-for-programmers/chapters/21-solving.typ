#import "../lib.typ": *

= Solving Linear Systems

== The problem

Given $A in RR^(m times n)$ and $b in RR^m$, find every $x$ with $A x = b$.

Chapter 20 already told us the *shape* of the answer: no solutions, one, or
infinitely many, and in the last case the solution set is a shifted copy of
the null space. This chapter gives the algorithm that finds it, and the theory
that falls out of the algorithm.

That ordering is deliberate. Gaussian elimination is not merely a computational
recipe; running it is how you *discover* rank, independence, dimension, and
the rank--nullity theorem. The theory is the algorithm's exhaust.

== Gaussian elimination

#definition(title: "elementary row operations")[
  #set enum(numbering: "(R1)")
  + Swap two rows.
  + Multiply a row by a nonzero scalar.
  + Add a multiple of one row to another.
]

#theorem[
  Elementary row operations do not change the solution set of $A x = b$.
]

#proof[
  Each operation is reversible --- swap back, divide back, subtract back --- so
  the new system implies the old and vice versa. Two systems that imply each
  other have the same solution set. (This is Chapter 2's distinction between
  equivalent and one-way transformations, applied to systems.)
]

#definition(title: "row echelon form")[
  A matrix is in *row echelon form* (REF) if:
  all zero rows are at the bottom; the first nonzero entry of each row (the
  *pivot*) is strictly to the right of the pivot above it.

  It is in *reduced row echelon form* (RREF) if additionally every pivot is
  $1$ and is the only nonzero entry in its column.
]

#algo(title: "Gaussian elimination with partial pivoting")[
```
for each column j = 1..n:
    find row i >= current with the largest |A[i][j]|      # pivoting
    if that entry is 0: continue        # no pivot in this column
    swap row i with the current row
    for each row k below the current:
        factor := A[k][j] / A[current][j]
        row_k  := row_k - factor * row_current
    advance to the next row
```
]

This produces REF in $O(n^3)$ operations for a square system --- roughly
$2 n^3 slash 3$ multiply-adds. Continuing upwards to clear above the pivots
gives RREF (Gauss--Jordan), which costs about 50% more and is usually not
worth it.

#warning(title: "pivoting is not optional")[
  In exact arithmetic you may pick any nonzero pivot. In floating point you
  must pick the *largest available*, and the reason is Chapter 1's warning
  about cancellation.

  Consider
  $ mat(10^(-20), 1; 1, 1) vec(x,y) = vec(1,2). $
  Eliminating with the tiny pivot multiplies the second row by $10^20$, which
  swamps its original entries: the value $1 - 10^20$ rounds to exactly
  $-10^20$, and the information in that row is destroyed. You get
  $y = 1$, $x = 0$ --- badly wrong.

  Swapping the rows first makes the pivot $1$, the multiplier tiny, and the
  answer accurate to full precision. The matrix was perfectly well-conditioned;
  only the pivot choice was bad. This is why every library routine pivots by
  default, and why writing your own solver without pivoting is a mistake you
  make exactly once.
]

== Reading the answer off the echelon form

#definition(title: "pivot and free variables")[
  Variables whose columns contain a pivot are *pivot variables*; the rest are
  *free variables*.
]

#algo(title: "Solving from RREF")[
```
1. If a row reads [0 0 ... 0 | c] with c != 0, the system is
   inconsistent: no solutions.  Stop.
2. Otherwise, set each free variable to an arbitrary parameter.
3. Solve for each pivot variable in terms of the parameters
   by back-substitution.
```
]

#example(title: "a full worked system")[
  $
  mat(1, 2, -1, 3; 2, 4, 0, 8; -1, -2, 2, -1) vec(x_1,x_2,x_3,x_4) = vec(2, 6, 0).
  $

  Augment and eliminate. Row 2 minus 2(Row 1), Row 3 plus Row 1:
  $
  mat(1,2,-1,3, 2; 0,0,2,2, 2; 0,0,1,2, 2; augment: #4)
  $
  Row 3 minus $1 slash 2$(Row 2):
  $
  mat(1,2,-1,3, 2; 0,0,2,2, 2; 0,0,0,1, 1; augment: #4)
  $
  Pivots in columns 1, 3, 4; column 2 is free. Back-substituting:
  $x_4 = 1$; then $2 x_3 + 2 = 2$ so $x_3 = 0$; then
  $x_1 + 2 x_2 - 0 + 3 = 2$ so $x_1 = -1 - 2 x_2$.

  With $x_2 = t$ free, the solution set is
  $ x = vec(-1,0,0,1) + t vec(-2,1,0,0), quad t in RR. $

  Exactly the structure Chapter 20 predicted: one particular solution plus the
  null space, which here is one-dimensional and spanned by $(-2,1,0,0)$.
]

== Rank

#definition(title: "rank")[
  $rank(A)$ is the number of pivots in any echelon form of $A$.
]

#theorem(title: "rank is well defined and symmetric")[
  The number of pivots does not depend on the elimination path, and
  $ rank(A) = dim "Col"(A) = dim "Row"(A) = rank(A^T). $
]

#intuition(title: "row rank equals column rank is not obvious")[
  The columns live in $RR^m$ and the rows live in $RR^n$ --- different spaces,
  possibly wildly different sizes. That the maximum number of independent
  columns equals the maximum number of independent rows is a genuinely
  surprising theorem.

  One clean proof: if $rank(A) = r$ by columns, then $A$ can be written as
  $A = C R$ where $C$ is $m times r$ (a basis of the column space) and $R$ is
  $r times n$ (the coefficients). But then every *row* of $A$ is a combination
  of the $r$ rows of $R$, so the row rank is at most $r$ too. Applying the
  same argument to $A^T$ gives the reverse inequality.

  The factorisation $A = C R$ is worth noticing on its own: *a rank-$r$ matrix
  factors through $RR^r$.* An $m times n$ matrix of rank $r$ needs only
  $r(m+n)$ numbers instead of $m n$. That is the compression at the heart of
  low-rank approximation, of recommender systems, and of LoRA fine-tuning ---
  where you freeze a large weight matrix and learn only a rank-$r$ update.
]

#theorem(title: "rank--nullity")[
  For $A in RR^(m times n)$,
  $ rank(A) + dim "Null"(A) = n. $
]

#proof[
  Run elimination to RREF. Each of the $n$ columns is either a pivot column or
  a free column, so
  $ "(number of pivot columns)" + "(number of free columns)" = n. $
  The pivot count is $rank(A)$ by definition. And each free variable
  contributes exactly one basis vector to the null space --- set that variable
  to 1, the other free variables to 0, and solve --- so the free count is
  $dim "Null"(A)$. These null-space vectors are independent (each has a 1 in a
  slot where the others have 0) and they span it (any solution is determined
  by its free values).
]

#intuition(title: "rank--nullity is a conservation law")[
  You start with $n$ dimensions of input. The map $A$ either *keeps* a
  direction (contributing to the rank, i.e. to the output) or *crushes* it
  (contributing to the null space). Nothing else can happen. So
  kept $+$ crushed $=$ started with.

  Reading it as information: a linear map cannot create dimensions, and
  whatever it does not preserve, it destroys. A projection from $RR^3$ to a
  plane has rank 2 and nullity 1 --- the direction perpendicular to the plane
  is exactly what is lost, and it is lost irrecoverably.
]

#corollary[
  A square matrix is injective iff surjective iff invertible.
]

#proof[
  For $m = n$: injective means nullity $0$, which by rank--nullity means
  rank $n$, which means the column space is all of $RR^n$, which is
  surjectivity. And Chapter 20 recorded that both together give
  invertibility.
]

This is a purely finite-dimensional phenomenon and it is worth knowing that it
fails in infinite dimensions: the shift operator on infinite sequences,
$(a_1, a_2, dots) arrow.bar (0, a_1, a_2, dots)$, is injective and not
surjective.

== LU decomposition

Elimination can be recorded as a factorisation, and that is what you actually
want in practice.

#theorem(title: "LU with pivoting")[
  For any square $A$ there is a permutation matrix $P$, a unit lower
  triangular $L$, and an upper triangular $U$ with
  $ P A = L U. $
]

The idea: $U$ is the echelon form; $L$ stores the multipliers used to get
there; $P$ records the row swaps.

#intuition(title: "why factor rather than just solve")[
  Elimination costs $O(n^3)$. Solving a triangular system by substitution
  costs $O(n^2)$.

  If you need to solve $A x = b$ for many different $b$ with the *same* $A$
  --- which happens constantly: time-stepping a simulation, Newton iterations,
  multiple right-hand sides --- then factoring once for $O(n^3)$ and reusing
  it for $O(n^2)$ per solve is an enormous saving.

  $ A x = b quad arrow.r.double quad L underbrace(U x, y) = P b: quad "solve" L y = P b "(forward), then" U x = y "(backward)". $

  This is exactly why `lu_factor` and `lu_solve` are separate calls in every
  numerical library, and why `solve(A, b)` in a loop over $b$ is a performance
  bug.
]

Related factorisations, each specialised:

- *Cholesky*, $A = L L^T$, for symmetric positive definite $A$. Half the
  work of LU, needs no pivoting, and *fails* precisely when $A$ is not
  positive definite --- which makes it the standard numerical test for
  positive definiteness.
- *QR*, $A = Q R$ with $Q$ orthogonal (Chapter 24). More expensive but
  numerically superior, and the right tool for least squares.
- *SVD* (Chapter 25). Most expensive, most informative, works for any shape.

== Homogeneous systems and the null space

$A x = 0$ always has the solution $x = 0$. The question is whether it has
others.

#proposition[
  $A x = 0$ has a nonzero solution iff $rank(A) < n$; in particular, always
  when $m < n$ (more unknowns than equations).
]

#proof[
  Nonzero solutions exist iff the nullity is positive, which by rank--nullity
  means $rank(A) < n$. And $rank(A) <= min(m,n)$, so $m < n$ forces it.
]

"More unknowns than equations implies infinitely many solutions" is the
formal version of a fact you already use when counting degrees of freedom.

== Conditioning

Solvability is binary; *usefulness* is not. A system can be technically
solvable and practically worthless.

#definition(title: "condition number")[
  For invertible $A$,
  $ kappa(A) = norm(A) dot norm(A^(-1)) >= 1, $
  where $norm(dot)$ is a matrix norm (Chapter 25 identifies the natural
  choice as the ratio of largest to smallest singular value).
]

#theorem(title: "error amplification")[
  If $A x = b$ and $A hat(x) = b + delta b$, then
  $ (norm(hat(x) - x))/norm(x) <= kappa(A) (norm(delta b))/norm(b). $
]

So $kappa(A)$ is the worst-case factor by which relative input error is
magnified in the output.

#intuition(title: "what an ill-conditioned system looks like")[
  $ mat(1, 1; 1, 1.0001) vec(x,y) = vec(2, 2.0001). $
  The exact solution is $x = y = 1$. Perturb the right-hand side by $0.0001$
  in the second entry and the solution jumps to $x = 0$, $y = 2$. A relative
  input change of about $5 times 10^(-5)$ produced a relative output change of
  order $1$: an amplification of roughly $10^4$, which is $kappa$.

  Geometrically, the two equations are two nearly parallel lines. Their
  intersection point is well defined but slides a long way when either line is
  nudged. The matrix is not singular --- it is *nearly* singular, and near is
  bad enough.

  The rule of thumb: with $kappa(A) approx 10^k$, you lose about $k$ decimal
  digits of accuracy. Double precision gives you 16, so $kappa = 10^12$ leaves
  4 --- and $kappa = 10^16$ leaves nothing. This is not a defect of your
  algorithm; no algorithm can do better, because the *problem* is sensitive.
  Chapter 33 separates these two kinds of blame properly.
]

== Iterative methods, briefly

Direct elimination is $O(n^3)$ and destroys sparsity through *fill-in*: zeros
become nonzeros as the algorithm proceeds. For the enormous sparse systems
that come out of discretised PDEs, meshes, and graphs, that is fatal.

Iterative methods only ever *multiply* by $A$ --- which is cheap and preserves
sparsity --- and converge to the solution.

- *Jacobi and Gauss--Seidel:* split $A$ into easy and hard parts and iterate.
  Simple, slow, converge under diagonal dominance.
- *Conjugate gradient:* for symmetric positive definite $A$. In exact
  arithmetic it terminates in $n$ steps, and in practice it gets a good answer
  in far fewer --- roughly $sqrt(kappa)$ iterations for a given accuracy,
  which is why *preconditioning* (transforming to reduce $kappa$) matters so
  much.
- *GMRES:* the general non-symmetric workhorse.

The theme: for large sparse problems, an approximate answer obtained by
repeated matrix--vector products beats an exact answer you cannot afford to
compute.

== Exercises

#exercise[
  Solve by Gaussian elimination, giving the complete solution set:
  $
  x + 2y + z &= 4 \
  2x + y - z &= 1 \
  3x + 3y &= 5
  $
]

#exercise[
  Find the rank and a basis for the null space of
  $ A = mat(1, 3, 1, 4; 2, 6, 3, 9; 1, 3, 2, 5). $
  Verify rank--nullity explicitly.
]

#exercise[
  For which values of $k$ does the system
  $x + k y = 1$, $k x + 4 y = 2$ have (a) a unique solution, (b) no solution,
  (c) infinitely many?
]

#exercise[
  Show that if $A$ is $3 times 5$, then $A x = 0$ must have a nonzero
  solution. What is the smallest possible dimension of the null space?
]

#exercise[
  Compute the LU factorisation (without pivoting) of
  $ A = mat(2, 1, 1; 4, 3, 3; 8, 7, 9), $
  and then use it to solve $A x = (4, 10, 24)^T$ by forward and back
  substitution.
]

#exercise[
  Carry out elimination on $ mat(10^(-4), 1; 1, 1) vec(x,y) = vec(1, 2) $
  first without pivoting and then with, working to 3 significant figures
  throughout. Compare both answers to the exact solution.
]

#exercise[
  Prove that $rank(A B) <= min(rank(A), rank(B))$. Hint: the column space of
  $A B$ is contained in the column space of $A$; for the other bound use
  transposes.
]

#exercise[
  Let $A$ be $m times n$ with $m > n$ and $rank(A) = n$. Show that $A x = b$
  has at most one solution, and explain what it means when it has none. (This
  is the overdetermined case that motivates least squares in Chapter 24.)
]
