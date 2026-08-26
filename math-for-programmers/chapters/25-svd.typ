#import "../lib.typ": *

= The Singular Value Decomposition

== The best theorem in linear algebra

Eigen-decomposition is powerful and fragile. It needs a square matrix, it can
fail to exist (defective matrices, Chapter 23), it can produce complex
eigenvalues for a real matrix, and the eigenvector basis is generally not
orthogonal so the change of basis is numerically dangerous.

The SVD has none of those problems. It exists for *every* matrix, of any
shape, always, with real nonnegative singular values and *orthonormal* bases
on both sides. If you learn one factorisation, learn this one.

#theorem(title: "singular value decomposition")[
  Every $A in RR^(m times n)$ factors as
  $ A = U Sigma V^T $
  where $U in RR^(m times m)$ is orthogonal, $V in RR^(n times n)$ is
  orthogonal, and $Sigma in RR^(m times n)$ is "diagonal" with nonnegative
  entries
  $ sigma_1 >= sigma_2 >= dots.c >= sigma_r > 0 = sigma_(r+1) = dots.c $
  down its main diagonal, where $r = rank(A)$.

  The $sigma_i$ are the *singular values*; the columns of $U$ are the *left
  singular vectors* and those of $V$ the *right singular vectors*.
]

#intuition(title: "every matrix is a rotation, a scaling, and a rotation")[
  Read $A = U Sigma V^T$ right to left as a pipeline:

  + $V^T$: an orthogonal map --- a rotation (possibly with a reflection). No
    stretching, no distortion.
  + $Sigma$: scale each coordinate axis independently by $sigma_i$. Some axes
    may be scaled by zero, which is how dimensions get destroyed.
  + $U$: another rotation, into the output space.

  That is *every linear map that has ever existed*. Rotate, stretch along
  axes, rotate. Nothing else can happen.

  The geometric statement: *$A$ maps the unit sphere to an ellipsoid.* The
  right singular vectors $v_i$ are the directions on the sphere that map to
  the ellipsoid's axes; the left singular vectors $u_i$ are those axes'
  directions; and the $sigma_i$ are the semi-axis lengths.

  Once you can picture that, the SVD stops being a formula and becomes
  obvious.
]

#theorem(title: "existence, via the symmetric case")[
  The SVD exists for every real matrix.
]

#proof[
  $A^T A$ is $n times n$, symmetric, and positive semidefinite:
  $x^T A^T A x = norm(A x)^2 >= 0$. By the spectral theorem (Chapter 23) it
  has an orthonormal eigenbasis $v_1, dots, v_n$ with real eigenvalues
  $lambda_1 >= dots.c >= lambda_n >= 0$.

  Define $sigma_i = sqrt(lambda_i)$, and for the $r$ indices with
  $sigma_i > 0$ set
  $ u_i = (A v_i)/sigma_i. $

  These $u_i$ are orthonormal:
  $ u_i dot u_j = (v_i^T A^T A v_j)/(sigma_i sigma_j) = (lambda_j (v_i dot v_j))/(sigma_i sigma_j), $
  which is $0$ for $i != j$ and $lambda_i slash sigma_i^2 = 1$ for $i = j$.
  Extend $u_1, dots, u_r$ to an orthonormal basis of $RR^m$.

  Finally $A v_i = sigma_i u_i$ for $i <= r$, and $A v_i = 0$ for $i > r$
  (since $norm(A v_i)^2 = lambda_i = 0$). Stacking these column relations is
  exactly $A V = U Sigma$, i.e. $A = U Sigma V^T$.
]

#proposition(title: "relations to eigen-decompositions")[
  $ A^T A = V Sigma^T Sigma V^T, quad A A^T = U Sigma Sigma^T U^T. $
  So the right singular vectors are eigenvectors of $A^T A$, the left ones are
  eigenvectors of $A A^T$, and the nonzero eigenvalues of both are
  $sigma_i^2$.
]

#warning(title: "computing the SVD from $A^T A$ is a bad idea")[
  The proof above is a construction, and like the characteristic polynomial in
  Chapter 23 it is a proof rather than an algorithm.

  Forming $A^T A$ squares the condition number, so singular values smaller
  than $sqrt(epsilon_"mach") sigma_1 approx 10^(-8) sigma_1$ are lost
  entirely. Real algorithms (Golub--Kahan bidiagonalisation followed by an
  implicit QR sweep) work on $A$ directly and resolve singular values down to
  $epsilon_"mach" sigma_1$.

  Use the library. But know that the library is doing something cleverer than
  the textbook proof.
]

== What the SVD tells you

#theorem(title: "the SVD reveals everything")[
  With $A = U Sigma V^T$ and $r$ nonzero singular values:

  #set enum(numbering: "(a)")
  + $rank(A) = r$.
  + $u_1, dots, u_r$ is an orthonormal basis of $"Col"(A)$.
  + $u_(r+1), dots, u_m$ is an orthonormal basis of $"Null"(A^T)$.
  + $v_1, dots, v_r$ is an orthonormal basis of $"Row"(A)$.
  + $v_(r+1), dots, v_n$ is an orthonormal basis of $"Null"(A)$.
  + $norm(A)_2 = sigma_1$ (the largest factor by which $A$ can stretch a
    vector).
  + $norm(A)_F = sqrt(sum_i sigma_i^2)$ (the Frobenius norm).
  + For square invertible $A$, $kappa_2(A) = sigma_1 slash sigma_n$.
]

So the four fundamental subspaces of Chapter 24, which needed elimination and
careful bookkeeping, all fall out of one factorisation with *orthonormal*
bases attached.

#intuition(title: "the condition number, finally explained")[
  $kappa = sigma_1 slash sigma_n$ is the ratio of the longest to the shortest
  axis of the ellipsoid $A$ maps the unit sphere to.

  If that ratio is 1, the sphere maps to a sphere --- $A$ is a scaled
  orthogonal matrix, perfectly conditioned, no direction is favoured.

  If the ratio is $10^12$, the sphere maps to a needle. Going forwards,
  everything gets squashed into the long direction; going backwards, the tiny
  direction has to be blown up by $10^12$, and so does any error in it.

  That is the entire content of ill-conditioning, and it is a *geometric*
  statement about the matrix, not a defect of any algorithm.
]

== Low-rank approximation

Here is the result that makes the SVD indispensable in practice.

#definition(title: "truncated SVD")[
  Writing the SVD as a sum of rank-one pieces,
  $ A = sum_(i=1)^r sigma_i u_i v_i^T, $
  the *rank-$k$ truncation* is
  $ A_k = sum_(i=1)^k sigma_i u_i v_i^T. $
]

#theorem(title: "Eckart--Young--Mirsky")[
  $A_k$ is the *best* rank-$k$ approximation to $A$, in both the spectral and
  Frobenius norms:
  $ min_(rank(B) <= k) norm(A - B)_2 = norm(A - A_k)_2 = sigma_(k+1), $
  $ min_(rank(B) <= k) norm(A - B)_F = norm(A - A_k)_F = sqrt(sum_(i>k) sigma_i^2). $
]

#intuition(title: "why this theorem is remarkable")[
  There are infinitely many rank-$k$ matrices. The theorem says the best one
  is found by a *completely mechanical* procedure --- compute the SVD, keep
  the top $k$ terms, discard the rest --- with no search and no optimisation.

  Optimisation problems almost never have closed-form solutions. This one
  does, and the residual error is exactly $sigma_(k+1)$, so you know in
  advance how good a rank-$k$ approximation can possibly be.

  Practically: plot the singular values. If they decay fast, your matrix is
  *approximately* low rank and can be compressed with little loss. If they
  decay slowly, it cannot, and no method will do better --- Eckart--Young says
  so.
]

#example(title: "what this is used for")[
  *Image compression.* A grayscale image is a matrix. Keeping the top $k$
  singular values stores $k(m + n + 1)$ numbers instead of $m n$. Natural
  images have rapidly decaying spectra, so $k = 50$ on a $512 times 512$ image
  is a $10 times$ compression and often visually indistinguishable. (Actual
  codecs use DCT, which is cheaper and does not require per-image
  factorisation --- but the principle is identical.)

  *Principal component analysis.* Centre your data matrix $X$ (subtract the
  column means). Then $X^T X slash (n-1)$ is the covariance matrix, and the
  right singular vectors of $X$ are its eigenvectors --- the *principal
  components*. Projecting onto the first $k$ gives the best $k$-dimensional
  linear summary of the data, by exactly the Eckart--Young criterion. And
  $sigma_i^2 slash sum_j sigma_j^2$ is the fraction of variance explained by
  component $i$.

  *Latent semantic analysis / recommender systems.* A user--item matrix is
  huge, sparse, and approximately low rank because preferences are driven by a
  small number of latent factors. Truncating the SVD both compresses and
  *fills in* the missing entries, which is the recommendation.

  *Noise removal.* Signal tends to live in the large singular values, noise is
  spread across all of them. Truncating keeps the signal and discards a
  proportional share of the noise.

  *LoRA.* Fine-tuning a large model by learning $W + B A$ with $B$, $A$ thin
  --- a low-rank update. The bet is that the weight *change* needed for a new
  task is approximately low rank, so a few million parameters suffice where
  billions would otherwise be needed. Whether that bet holds is an empirical
  question about the spectrum of the update.
]

== The pseudoinverse

#definition(title: "Moore--Penrose pseudoinverse")[
  For $A = U Sigma V^T$, define
  $ A^+ = V Sigma^+ U^T, $
  where $Sigma^+$ is formed by transposing $Sigma$ and replacing each nonzero
  $sigma_i$ with $1 slash sigma_i$ (leaving the zeros alone).
]

#theorem[
  $hat(x) = A^+ b$ is the least-squares solution of $A x = b$ of *minimum
  norm*. When $A$ is invertible, $A^+ = A^(-1)$; when $A$ has independent
  columns, $A^+ = (A^T A)^(-1) A^T$.
]

#intuition(title: "the pseudoinverse does the only sensible thing")[
  A general $A x = b$ has two possible pathologies: no exact solution
  (inconsistent) and too many (a nontrivial null space). $A^+$ handles both.

  *On the directions $A$ preserves* ($sigma_i > 0$), it inverts: divide by
  $sigma_i$.

  *On the directions $A$ destroyed* ($sigma_i = 0$), there is no information
  to invert, so it returns zero rather than inventing something. That choice
  is what makes the answer minimum-norm.

  Note it does *not* try to invert tiny singular values into enormous ones ---
  or rather, it does, which is why in practice you use a *truncated*
  pseudoinverse, zeroing every $sigma_i$ below a tolerance. That is exactly
  what `numpy.linalg.pinv(A, rcond=...)` does, and the `rcond` parameter is
  the line between "small but real" and "numerical noise". Choosing it is a
  judgement call, and it is the same judgement as choosing $k$ in a truncated
  SVD.
]

The truncated pseudoinverse is also a form of *regularisation*: it stabilises
an ill-posed problem by refusing to amplify the directions in which the data
carries no information. Ridge regression does the same thing more smoothly, by
replacing $1 slash sigma_i$ with $sigma_i slash (sigma_i^2 + lambda)$ ---
which is close to $1 slash sigma_i$ for large $sigma_i$ and close to zero for
small ones.

== Matrix norms

#definition[
  $
  norm(A)_2 &= max_(x != 0) (norm(A x))/(norm(x)) = sigma_1 &quad& "(spectral / operator norm)" \
  norm(A)_F &= sqrt(sum_(i j) A_(i j)^2) = sqrt(sum_i sigma_i^2) &quad& "(Frobenius)" \
  norm(A)_* &= sum_i sigma_i &quad& "(nuclear / trace norm)"
  $
]

The spectral norm is the worst-case amplification factor --- the right norm
for error analysis. The Frobenius norm treats the matrix as a long vector ---
the right norm when you want something differentiable and cheap. The nuclear
norm is the convex relaxation of *rank*, in the same way that the $ell_1$ norm
is the convex relaxation of "number of nonzeros" (Chapter 19); minimising it
is how matrix completion problems are made tractable.

== Exercises

#exercise[
  Compute the SVD of $ A = mat(3, 0; 0, -2) $ by inspection. What are $U$,
  $Sigma$, $V$? (Note that singular values must be nonnegative --- where does
  the sign go?)
]

#exercise[
  Find the singular values of $ A = mat(1, 1; 0, 1) $ by computing the
  eigenvalues of $A^T A$. Then compute $kappa_2(A)$.
]

#exercise[
  Let $A$ be $m times n$ with $m > n$ and rank $n$. Show that
  $A^+ = (A^T A)^(-1) A^T$ by substituting the SVD into both sides.
]

#exercise[
  Prove that $norm(A)_F^2 = tr(A^T A)$, and then that this equals
  $sum_i sigma_i^2$. (Use the cyclic property of the trace and the
  orthogonality of $U$ and $V$.)
]

#exercise[
  A $1000 times 800$ matrix has singular values that decay like
  $sigma_i = 100 slash i$. How many singular values must you keep to capture
  90% of the Frobenius norm squared? Roughly how much storage does that
  truncation save?
]

#exercise[
  Show that for any $A$, the matrices $A^T A$ and $A A^T$ have the same
  nonzero eigenvalues. (Hint: if $A^T A v = lambda v$ with $lambda != 0$,
  consider $A v$.)
]

#exercise[
  Explain, using the SVD, why $kappa(A^T A) = kappa(A)^2$. Then state in one
  sentence the practical consequence for solving least-squares problems.
]

#exercise[
  A data matrix $X$ (rows = samples, columns = features) has been centred. Show
  that the first principal component --- the unit vector $w$ maximising the
  variance of $X w$ --- is the first right singular vector of $X$. (Maximise
  $norm(X w)^2$ subject to $norm(w) = 1$, using the SVD.)
]
