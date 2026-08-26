#import "../lib.typ": *

= Determinants

== What the determinant measures

The determinant is usually introduced as a formula, which is the worst
possible way in: the formula for a $3 times 3$ is ugly and the formula for an
$n times n$ has $n!$ terms. Nobody could guess what it means.

Start with the meaning instead.

#intuition(title: "the determinant is a volume scale factor, with a sign")[
  A matrix $A$ is a linear map. Feed it the unit cube --- the box spanned by
  $e_1, dots, e_n$, of volume 1. It comes out as a parallelepiped.

  $ abs(det A) = "the volume of that parallelepiped". $

  In other words, $A$ multiplies every volume by $abs(det A)$. That is the
  definition worth carrying.

  The *sign* records orientation. $det A > 0$ means the map preserves
  handedness; $det A < 0$ means it flips it, like a mirror. In 2D, positive
  means counterclockwise stays counterclockwise.

  And then the single most important fact is immediate: $det A = 0$ means the
  cube is squashed *flat* --- into something of lower dimension, with zero
  volume. Information has been destroyed, the map is not invertible, and the
  null space is nontrivial. Everything about singularity follows from
  "flattened".
]

== The defining properties

Rather than a formula, characterise the determinant by what it must do. This
is how mathematicians actually think about it, and it makes proofs short.

#definition(title: "determinant, axiomatically")[
  $det : RR^(n times n) -> RR$ is the unique function satisfying:

  #set enum(numbering: "(D1)")
  + *Multilinear in the columns.* Holding the other columns fixed,
    $det$ is linear in each column:
    $det(dots, a u + b v, dots) = a det(dots, u, dots) + b det(dots, v, dots)$.
  + *Alternating.* If two columns are equal, $det = 0$.
  + *Normalised.* $det I = 1$.
]

From these three, everything follows.

#proposition(title: "immediate consequences")[
  #set enum(numbering: "(a)")
  + Swapping two columns negates the determinant.
  + Adding a multiple of one column to another leaves it unchanged.
  + Scaling one column by $c$ scales the determinant by $c$.
  + If any column is zero, $det = 0$.
  + If the columns are linearly dependent, $det = 0$.
]

#proof[
  *(a)* Consider $det(dots, u+v, dots, u+v, dots)$, which is $0$ by (D2).
  Expanding by multilinearity gives four terms; the two with a repeated column
  vanish, leaving
  $ det(dots,u,dots,v,dots) + det(dots,v,dots,u,dots) = 0. $

  *(b)* $det(dots, u + c v, dots, v, dots) = det(dots,u,dots,v,dots) + c det(dots,v,dots,v,dots)$,
  and the second term is $0$ by (D2).

  *(c)* Immediate from (D1). *(d)* Take $c = 0$ in (c).

  *(e)* If dependent, one column is a combination of the others; subtract that
  combination using (b), producing a zero column, then apply (d).
]

Property (b) is the practically important one: *elimination does not change
the determinant.* So the way to compute a determinant is to run Gaussian
elimination and multiply the pivots --- $O(n^3)$, not $O(n!)$.

#theorem(title: "determinant of a triangular matrix")[
  If $A$ is triangular, $det A = product_i A_(i i)$.
]

#theorem(title: "computing determinants in practice")[
  If $P A = L U$ is the LU factorisation with $k$ row swaps, then
  $ det A = (-1)^k product_i U_(i i). $
]

#proof[
  $det L = 1$ ($L$ is unit lower triangular), $det U$ is the product of its
  diagonal by the previous theorem, $det P = (-1)^k$ by property (a) applied
  $k$ times, and $det$ is multiplicative by the theorem below.
]

== The formula, for completeness

#definition(title: "Leibniz formula")[
  $ det A = sum_(sigma in S_n) sgn(sigma) product_(i=1)^n A_(i, sigma(i)), $
  where the sum runs over all $n!$ permutations of ${1,dots,n}$ and
  $sgn(sigma)$ is $+1$ for an even permutation, $-1$ for odd.
]

For $n = 2$ this is $a d - b c$. For $n = 3$ it is the six-term rule of Sarrus.
For $n = 20$ it has $2.4 times 10^18$ terms and is entirely useless as an
algorithm.

*Cofactor expansion* along a row or column,
$ det A = sum_j (-1)^(i+j) A_(i j) M_(i j), $
where $M_(i j)$ is the determinant of $A$ with row $i$ and column $j$ deleted,
is the recursive version. It costs $O(n!)$ too. It is useful for hand
computation on small or sparse matrices --- expand along a row with many
zeros --- and for proving things, and for nothing else.

== The multiplicative property

#theorem(title: "determinant is multiplicative")[
  $ det(A B) = det(A) det(B). $
]

#proof[
  Read it as volume scaling. $B$ scales volumes by $det B$, then $A$ scales by
  $det A$; composing scales by the product. Signs compose the same way: two
  flips make no flip.

  (A rigorous proof fixes $B$ and checks that $A arrow.bar det(A B) slash det B$
  satisfies the three axioms as a function of the columns of $A$; uniqueness
  then forces it to equal $det A$. The volume argument is the reason it is
  true.)
]

#corollary[
  #set enum(numbering: "(a)")
  + $det(A^(-1)) = 1 slash det(A)$.
  + $det(A^T) = det(A)$.
  + $det(c A) = c^n det(A)$ for $n times n$ matrices.
  + Similar matrices have equal determinants:
    $det(P^(-1) A P) = det(A)$.
]

#proof[
  *(a)* $det(A) det(A^(-1)) = det(I) = 1$.

  *(c)* Scaling all $n$ columns by $c$ multiplies by $c$ each time --- this
  catches people out, since $det(2A) = 2^n det A$, not $2 det A$.

  *(d)* $det(P^(-1) A P) = det(P^(-1)) det(A) det(P) = det(A)$ by (a) and
  commutativity of scalar multiplication.
]

Item (d) matters: similar matrices are *the same linear map written in
different bases* (Chapter 23), and the determinant does not care which basis
you chose. Volume scaling is a property of the map, not of its coordinates.

== The big theorem

#theorem(title: "determinant and invertibility")[
  $A$ is invertible $arrow.l.r.double$ $det A != 0$.
]

#proof[
  ($arrow.r.double$) If $A^(-1)$ exists then $det(A) det(A^(-1)) = 1$, so
  $det A != 0$.

  ($arrow.l.double$) Contrapositive. If $A$ is not invertible, its columns are
  linearly dependent (Chapter 20), so $det A = 0$ by property (e).
]

This adds a line to the invertible matrix theorem, and it is the entry people
reach for first --- for small matrices.

#warning(title: "do not test for singularity with the determinant")[
  Numerically, $det A != 0$ is nearly useless as a test.

  The determinant scales like $c^n$: a perfectly well-conditioned
  $100 times 100$ matrix with entries around $0.1$ has determinant around
  $10^(-100)$, which underflows to zero. Meanwhile $10^(-6) I$ in $100$
  dimensions has determinant $10^(-600)$ and is trivially invertible.

  Conversely, a matrix can have a healthy-looking determinant and be
  catastrophically ill-conditioned.

  The determinant measures *volume*, which is a product of all $n$ singular
  values. Conditioning depends on the *ratio* of the largest to the smallest.
  Those are different questions. To test invertibility numerically, look at
  the smallest singular value (Chapter 25) or the condition number ---
  `rcond`, not `det`.
]

== The determinant in calculus and probability

Three places you will meet it outside linear algebra.

*Change of variables* (Chapter 18). $dif x = abs(det J) dif u$. The Jacobian
determinant is the local volume scale factor of the coordinate change, which
is exactly the interpretation above applied to the linearisation.

*Probability density transformation.* If $Y = g(X)$ with $g$ invertible and
differentiable, then
$ p_Y (y) = p_X (g^(-1)(y)) abs(det J_(g^(-1))(y)). $
Densities are "probability per unit volume", so changing coordinates requires
dividing by the volume change. This formula is the entire basis of
*normalising flows* in machine learning, where the model is a chain of
invertible maps and the training objective requires the log-determinant of
each Jacobian --- which is why such models are designed to have triangular or
otherwise cheap Jacobians.

*The multivariate normal.* Its density carries a factor
$1 slash sqrt(det Sigma)$, which is the normalising constant making the total
probability 1. $sqrt(det Sigma)$ is the volume of the ellipsoid of
one-standard-deviation spread (Chapter 29).

== Cramer's rule, and why not to use it

#theorem(title: "Cramer's rule")[
  If $A$ is invertible, the solution of $A x = b$ has
  $ x_i = (det A_i)/(det A), $
  where $A_i$ is $A$ with its $i$-th column replaced by $b$.
]

#proof[
  Let $X_i$ be the identity matrix with its $i$-th column replaced by $x$.
  Then $A X_i = A_i$ --- check column by column: the $i$-th column of
  $A X_i$ is $A x = b$, and every other column of $A X_i$ is the
  corresponding column of $A$. Taking determinants,
  $det(A) det(X_i) = det(A_i)$. But $X_i$ is triangular-ish with $x_i$ on the
  diagonal in position $i$ and ones elsewhere, so $det X_i = x_i$.
]

Beautiful, and never used for computation: it requires $n+1$ determinants, so
$O(n^4)$ against elimination's $O(n^3)$, and it is numerically poor. Its value
is theoretical --- it shows the solution depends *smoothly* (indeed
rationally) on the entries of $A$ and $b$, which matters when you want to
differentiate through a linear solve.

== Exercises

#exercise[
  Compute $det mat(3, 1; 2, 4)$ and $det mat(1,2,3;4,5,6;7,8,9)$. For the
  second, explain the answer in terms of the columns.
]

#exercise[
  Use row reduction (not cofactor expansion) to compute
  $ det mat(2,1,0,1; 1,3,1,0; 0,1,2,1; 1,0,1,3), $
  keeping track of any sign changes from row swaps.
]

#exercise[
  Let $A$ be $4 times 4$ with $det A = 5$. Find $det(2A)$, $det(A^T)$,
  $det(A^(-1))$, $det(A^3)$, and $det(A^T A)$.
]

#exercise[
  Prove that if $A$ is orthogonal then $det A = plus.minus 1$. Which sign
  corresponds to a rotation and which to a reflection?
]

#exercise[
  Show that the area of the triangle with vertices $(x_1,y_1)$, $(x_2,y_2)$,
  $(x_3,y_3)$ is $ 1/2 abs(det mat(x_2 - x_1, x_3 - x_1; y_2 - y_1, y_3 - y_1)). $
  Then explain how the *sign* of that determinant is used to decide the
  orientation of three points --- the primitive behind convex hull algorithms.
]

#exercise[
  Prove that if $A$ is $n times n$ with $A^2 = I$, then $det A = plus.minus 1$.
  Give an example of each sign.
]

#exercise[
  Compute the Jacobian determinant of the spherical coordinate map
  $x = rho sin phi cos theta$, $y = rho sin phi sin theta$, $z = rho cos phi$,
  and confirm it equals $rho^2 sin phi$.
]

#exercise[
  A matrix has entries drawn independently and uniformly from $[0,1]$ and is
  $200 times 200$. Estimate the order of magnitude of its determinant, and use
  that to explain in one paragraph why `det(A) == 0` is a bad singularity
  test.
]
