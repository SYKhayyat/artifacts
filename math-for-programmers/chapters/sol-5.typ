#import "../lib.typ": *

== Chapter 19 --- Vectors and Geometry

#soln("19.1")[
  $u = (1,-2,3)$, $v = (4,0,-1)$.

  $u dot v = 4 + 0 - 3 = 1$.
  $norm(u) = sqrt(1+4+9) = sqrt(14)$, $norm(v) = sqrt(16+0+1) = sqrt(17)$.

  $ cos theta = 1/(sqrt(14) sqrt(17)) = 1/sqrt(238) approx 0.0648, quad theta approx 86.3 degree. $
  Nearly perpendicular.

  $ proj_v (u) = ((u dot v)/(v dot v)) v = 1/17 (4, 0, -1). $

  $ u times v = ((-2)(-1) - (3)(0), thin (3)(4) - (1)(-1), thin (1)(0) - (-2)(4)) = (2, 13, 8). $

  Checks: $u dot (u times v) = 2 - 26 + 24 = 0$ ✓ and
  $v dot (u times v) = 8 + 0 - 8 = 0$ ✓.
]

#soln("19.2")[
  *(a) ${(x,y,z) : x + 2y = 0}$.* Subspace. Contains $0$; if
  $x_1 + 2y_1 = 0$ and $x_2 + 2y_2 = 0$ then the sum and any scalar multiple
  satisfy the same equation (it is linear and homogeneous).

  *(b) ${(x,y,z) : x >= 0}$.* Not a subspace. $(1,0,0)$ is in it,
  $(-1)(1,0,0) = (-1,0,0)$ is not. Fails under negative scaling.

  *(c) ${(x,y,z) : x y = 0}$.* Not a subspace. It is the union of two planes.
  $(1,0,0)$ and $(0,1,0)$ are both in it, but their sum $(1,1,0)$ has
  $x y = 1 != 0$. Fails under addition.

  *(d) ${(x,y,z) : x = y = z}$.* Subspace --- it is the line spanned by
  $(1,1,1)$, and a span is always a subspace.
]

#soln("19.3")[
  Look for $a, b$ with $a(1,2,3) + b(2,1,0) = (4,5,6)$:
  $
  a + 2b &= 4 \
  2a + b &= 5 \
  3a &= 6
  $
  The third gives $a = 2$, then the first gives $b = 1$, and the second checks
  out: $4 + 1 = 5$. ✓

  So the vectors are *dependent*, with the explicit relation
  $ 2(1,2,3) + 1(2,1,0) - 1(4,5,6) = (0,0,0). $
]

#soln("19.4")[
  Suppose the set is ${v_1, dots, v_k}$ with $v_1 = 0$. Then
  $ 1 dot v_1 + 0 dot v_2 + dots.c + 0 dot v_k = 0 $
  is a linear combination equal to zero in which not all coefficients are zero
  --- the coefficient of $v_1$ is $1$.

  That is precisely the definition of linear dependence.

  (Intuitively: the zero vector contributes no direction, so it is always
  redundant.)
]

#soln("19.5")[
  Expand both squared norms using $norm(w)^2 = w dot w$ and bilinearity:
  $
  norm(u+v)^2 &= norm(u)^2 + 2 u dot v + norm(v)^2, \
  norm(u-v)^2 &= norm(u)^2 - 2 u dot v + norm(v)^2.
  $
  Adding, the cross terms cancel:
  $ norm(u+v)^2 + norm(u-v)^2 = 2 norm(u)^2 + 2 norm(v)^2. $

  *Geometrically:* in a parallelogram with sides $u$ and $v$, the diagonals
  are $u+v$ and $u-v$. The law says *the sum of the squares of the diagonals
  equals the sum of the squares of the four sides.*

  It also characterises which norms come from an inner product: a norm
  satisfies the parallelogram law iff it is Euclidean-like. The $ell_1$ and
  $ell_infinity$ norms do not, which is why there is no "$ell_1$ dot product"
  and no notion of $ell_1$ angle.
]

#soln("19.6")[
  *$norm(v)_infinity <= norm(v)_2$.* Let $j$ be an index achieving the max.
  Then
  $ norm(v)_infinity^2 = v_j^2 <= sum_i v_i^2 = norm(v)_2^2. $

  *$norm(v)_2 <= norm(v)_1$.* Square the right side:
  $ norm(v)_1^2 = ( sum_i abs(v_i) )^2 = sum_i v_i^2 + sum_(i != j) abs(v_i) abs(v_j) >= sum_i v_i^2 = norm(v)_2^2, $
  since the cross terms are nonnegative.

  *Equality.* Both become equalities exactly when at most one component is
  nonzero --- e.g. $v = (5,0,0)$, where all three norms equal 5. The
  inequalities are strict as soon as two components are nonzero, and the gap
  grows with the spread: for $v = (1,1,dots,1) in RR^n$ the three norms are
  $1$, $sqrt(n)$, and $n$.
]

#soln("19.7")[
  *Basis.* ${1, x, x^2}$ spans $cal(P)_2$ by definition of a polynomial of
  degree at most 2. Independent: if $a + b x + c x^2 = 0$ *as a function*,
  then the polynomial has infinitely many roots, so by Chapter 2 it is the
  zero polynomial and $a = b = c = 0$.

  *Coordinates of $p(x) = 3 - x + 2x^2$:* $(3, -1, 2)$.

  *In the basis ${1, 1+x, (1+x)^2}$.* Substitute $u = 1 + x$, so
  $x = u - 1$ and $x^2 = u^2 - 2u + 1$:
  $
  p &= 3 - (u-1) + 2(u^2 - 2u + 1) \
    &= 3 - u + 1 + 2u^2 - 4u + 2 = 2u^2 - 5u + 6.
  $
  Coordinates $(6, -5, 2)$ in the order $(1, thin 1+x, thin (1+x)^2)$.

  Same vector, different names --- which is exactly the point of a basis.
]

#soln("19.8")[
  $ norm(u+v)^2 = (u+v) dot (u+v) = norm(u)^2 + 2 u dot v + norm(v)^2 = norm(u)^2 + norm(v)^2, $
  since $u dot v = 0$.

  This is the *Pythagorean theorem*. In $RR^2$ with $u$ and $v$ along the
  axes, it is literally $a^2 + b^2 = c^2$ --- but the vector proof works in
  any dimension and, more importantly, in any inner product space, which is
  why it applies to random variables (Chapter 29) and to functions
  (Chapter 24).
]

== Chapter 20 --- Matrices Are Functions

#soln("20.1")[
  $ A B = mat(1,2;3,4) mat(0,1;1,0) = mat(2,1;4,3), quad B A = mat(0,1;1,0) mat(1,2;3,4) = mat(3,4;1,2). $
  Different. ✓

  *What $B$ does:* it sends $e_1 arrow.bar (0,1) = e_2$ and
  $e_2 arrow.bar (1,0) = e_1$ --- it swaps the coordinates. Geometrically that
  is a *reflection in the line $y = x$*. (It is orthogonal with determinant
  $-1$, confirming a reflection rather than a rotation.)

  Reading the two products: $A B$ swaps first then applies $A$, so its columns
  are $A$'s columns in the other order. $B A$ applies $A$ first then swaps, so
  its *rows* are $A$'s rows in the other order.
]

#soln("20.2")[
  *Reflection in the $x y$-plane* negates $z$ and fixes $x, y$:
  $ M = mat(1,0,0; 0,1,0; 0,0,-1). $

  *Rotation by $90 degree$ about the $z$-axis* sends $e_1 -> e_2$,
  $e_2 -> -e_1$, $e_3 -> e_3$:
  $ R = mat(0,-1,0; 1,0,0; 0,0,1). $

  Both products:
  $ R M = M R = mat(0,-1,0; 1,0,0; 0,0,-1). $

  *They commute*, which is unusual and has a reason: the reflection is in the
  plane *perpendicular to* the rotation axis, so the two operations act on
  disjoint sets of coordinates ($z$ for the reflection, $x y$ for the
  rotation).

  The result has determinant $(-1)(1) = -1$, so it is orientation-reversing:
  a *rotary reflection* (an improper rotation), not a rotation.
]

#soln("20.3")[
  *Inverse of a product.*
  $ (A B)(B^(-1) A^(-1)) = A (B B^(-1)) A^(-1) = A I A^(-1) = A A^(-1) = I, $
  and symmetrically $(B^(-1)A^(-1))(A B) = I$. So $A B$ is invertible with the
  stated inverse.

  The order reversal is forced: without it, $(A B)(A^(-1)B^(-1))$ has
  $B A^(-1)$ stuck in the middle and does not simplify.

  *Sum need not be invertible.* Take $A = I$ and $B = -I$. Both are
  invertible; $A + B = 0$ is not.

  More sharply, invertibility is a property of the *map*, and adding two
  invertible maps can produce one that collapses everything.
]

#soln("20.4")[
  $
  tr(A^T A) = sum_i (A^T A)_(i i) = sum_i sum_k (A^T)_(i k) A_(k i) = sum_i sum_k A_(k i) A_(k i) = sum_(i,k) A_(k i)^2.
  $

  So $tr(A^T A)$ is the sum of the squares of all entries --- the squared
  Frobenius norm.

  If it is zero, then a sum of squares of real numbers is zero, which forces
  every term to be zero, so $A = 0$.

  This is the standard way to prove a matrix identity of the form $X = Y$:
  show $norm(X - Y)_F^2 = 0$.
]

#soln("20.5")[
  $A = mat(1,2,3; 2,4,6)$. Row 2 is exactly twice Row 1, so
  $rank(A) = 1$.

  *Column space:* every column is a multiple of $(1,2)^T$, so
  $"Col"(A) = span{(1,2)^T}$, a line in $RR^2$. Dimension 1.

  *Null space:* the single independent equation is $x_1 + 2x_2 + 3x_3 = 0$.
  With $x_2, x_3$ free:
  $ "Null"(A) = span{ (-2,1,0)^T, thin (-3,0,1)^T }. $
  Dimension 2.

  *Check:* $1 + 2 = 3 = $ number of columns. ✓ (Rank--nullity.)
]

#soln("20.6")[
  $ (Q_1 Q_2)^T (Q_1 Q_2) = Q_2^T Q_1^T Q_1 Q_2 = Q_2^T I Q_2 = Q_2^T Q_2 = I. $

  So the product is orthogonal.

  Together with the facts that $I$ is orthogonal and that $Q^(-1) = Q^T$ is
  orthogonal whenever $Q$ is, this makes the set of $n times n$ orthogonal
  matrices a *group* under multiplication --- the orthogonal group $O(n)$.
  Restricting to determinant $+1$ gives the rotation group $"SO"(n)$ of
  Chapter 35.
]

#soln("20.7")[
  $A$ is $100 times 5$, $B$ is $5 times 100$, $C$ is $100 times 1$. Computing
  an $(m times p)(p times n)$ product costs $m p n$ scalar multiplications.

  *$(A B) C$:*
  $A B$ costs $100 times 5 times 100 = 50,!000$ and gives a $100 times 100$
  matrix; then $(100 times 100)(100 times 1)$ costs $10,!000$.
  Total *$60,!000$*.

  *$A (B C)$:*
  $B C$ costs $5 times 100 times 1 = 500$ and gives a $5 times 1$ vector; then
  $(100 times 5)(5 times 1)$ costs $500$.
  Total *$1,!000$*.

  Ratio: *60 to 1*, for the identical mathematical result.

  Note *why*: the right-to-left order never materialises a large intermediate
  matrix. This is exactly the reverse-mode-versus-forward-mode argument of
  Chapter 18, in miniature.
]

#soln("20.8")[
  Let $S = { mat(a, -b; b, a) : a,b in RR }$.

  *Closed under addition:* obvious, entrywise.

  *Closed under multiplication:*
  $
  mat(a,-b;b,a) mat(c,-d;d,c) = mat(a c - b d, -(a d + b c); a d + b c, a c - b d),
  $
  which has the same form with $a' = a c - b d$ and $b' = a d + b c$.

  *This is exactly complex multiplication:*
  $(a + b i)(c + d i) = (a c - b d) + (a d + b c) i$. So the map
  $a + b i arrow.bar mat(a,-b;b,a)$ preserves both addition and
  multiplication --- it is an isomorphism of $CC$ onto $S$.

  *The matrix for $i$* is $J = mat(0,-1;1,0)$, and
  $ J^2 = mat(0,-1;1,0) mat(0,-1;1,0) = mat(-1,0;0,-1) = -I. $

  And $J$ is the $90 degree$ rotation matrix. So "$i^2 = -1$" reads as "two
  quarter turns make a half turn" --- exactly the geometric account given in
  Chapter 6, now as a matrix identity.
]

== Chapter 21 --- Solving Linear Systems

#soln("21.1")[
  Augmented matrix and elimination:
  $
  mat(1,2,1,4; 2,1,-1,1; 3,3,0,5; augment: #3)
  arrow.r
  mat(1,2,1,4; 0,-3,-3,-7; 0,-3,-3,-7; augment: #3)
  arrow.r
  mat(1,2,1,4; 0,-3,-3,-7; 0,0,0,0; augment: #3)
  $
  (using $R_2 - 2R_1$, $R_3 - 3R_1$, then $R_3 - R_2$).

  Rank 2, three unknowns, so one free variable: $z$.

  From row 2: $-3y - 3z = -7$, so $y = 7 slash 3 - z$.
  From row 1: $x + 2(7 slash 3 - z) + z = 4$, so $x = z - 2 slash 3$.

  $ vec(x,y,z) = vec(-2 slash 3, 7 slash 3, 0) + t vec(1, -1, 1), quad t in RR. $

  A particular solution plus the null space, exactly as Chapter 20 predicted.
]

#soln("21.2")[
  $
  A = mat(1,3,1,4; 2,6,3,9; 1,3,2,5) arrow.r mat(1,3,1,4; 0,0,1,1; 0,0,1,1) arrow.r mat(1,3,1,4; 0,0,1,1; 0,0,0,0).
  $

  Pivots in columns 1 and 3, so $rank(A) = 2$. Free variables $x_2, x_4$, so
  the nullity is 2.

  *Null space.* Row 2: $x_3 + x_4 = 0$, so $x_3 = -x_4$.
  Row 1: $x_1 + 3x_2 + x_3 + 4x_4 = 0$, so
  $x_1 = -3x_2 - (-x_4) - 4x_4 = -3x_2 - 3x_4$.

  Setting $(x_2, x_4) = (1,0)$ and $(0,1)$:
  $ "Null"(A) = span{ (-3, 1, 0, 0)^T, thin (-3, 0, -1, 1)^T }. $

  *Rank--nullity:* $2 + 2 = 4$ = number of columns. ✓
]

#soln("21.3")[
  The coefficient matrix is $mat(1, k; k, 4)$ with determinant $4 - k^2$.

  *(a) Unique solution* iff the determinant is nonzero: $k != plus.minus 2$.

  *(b) and (c).* When $k = 2$ the system is
  $x + 2y = 1$ and $2x + 4y = 2$ --- the second equation is exactly twice the
  first, so they describe the same line: *infinitely many solutions*.

  When $k = -2$: $x - 2y = 1$ and $-2x + 4y = 2$. Dividing the second by
  $-2$ gives $x - 2y = -1$, contradicting the first: *no solution* (two
  parallel lines).

  So: unique for $k != plus.minus 2$; infinitely many for $k = 2$; none for
  $k = -2$.
]

#soln("21.4")[
  $A$ is $3 times 5$, so $rank(A) <= 3$ (the rank cannot exceed either
  dimension).

  By rank--nullity, $ dim "Null"(A) = 5 - rank(A) >= 5 - 3 = 2 > 0. $

  A null space of positive dimension contains nonzero vectors, so $A x = 0$
  has nontrivial solutions.

  The *smallest possible* nullity is 2, attained when $A$ has full row rank 3.
]

#soln("21.5")[
  $A = mat(2,1,1; 4,3,3; 8,7,9)$.

  Eliminate: multiplier $ell_(21) = 2$ gives $R_2 - 2R_1 = (0,1,1)$;
  $ell_(31) = 4$ gives $R_3 - 4R_1 = (0,3,5)$; then $ell_(32) = 3$ gives
  $R_3 - 3R_2 = (0,0,2)$.

  $ L = mat(1,0,0; 2,1,0; 4,3,1), quad U = mat(2,1,1; 0,1,1; 0,0,2). $

  *Forward substitution*, $L y = b = (4,10,24)^T$:
  $y_1 = 4$; $2(4) + y_2 = 10$ so $y_2 = 2$; $4(4) + 3(2) + y_3 = 24$ so
  $y_3 = 2$.

  *Back substitution*, $U x = y = (4,2,2)^T$:
  $2 x_3 = 2$ so $x_3 = 1$; $x_2 + x_3 = 2$ so $x_2 = 1$;
  $2x_1 + x_2 + x_3 = 4$ so $x_1 = 1$.

  $x = (1,1,1)^T$. Check: the row sums of $A$ are $4, 10, 24$. ✓
]

#soln("21.6")[
  System: $10^(-4) x + y = 1$, $x + y = 2$.

  *Exact solution.* Subtracting: $(10^(-4) - 1)x = -1$, so
  $x = 1 slash (1 - 10^(-4)) = 1.00010001dots$ and
  $y = 2 - x = 0.99989999 dots$.

  *Without pivoting, to 3 significant figures.* Multiplier
  $1 slash 10^(-4) = 10000$. Then
  $ R_2 - 10000 R_1: quad "coefficient of" y: 1 - 10000 = -9999 -> -10000, $
  $ "RHS": 2 - 10000(1) = -9998 -> -10000. $
  So $y = (-10000) slash (-10000) = 1.00$. Substituting back into row 1:
  $10^(-4) x + 1.00 = 1$, giving $x = 0.00$.

  *Answer: $(0, 1)$ --- and $x$ is wrong by 100%.*

  *With pivoting.* Swap the rows first. Multiplier $10^(-4)$:
  $ R_2 - 10^(-4) R_1: quad 1 - 10^(-4) = 0.9999 -> 1.00, quad 1 - 2 times 10^(-4) = 0.9998 -> 1.00. $
  So $y = 1.00$, and then $x = 2 - 1.00 = 1.00$.

  *Answer: $(1.00, 1.00)$ --- correct to 3 significant figures.*

  The matrix was perfectly well conditioned ($kappa approx 2.6$). The entire
  failure was the choice of pivot, which forced a subtraction that annihilated
  the smaller entries.
]

#soln("21.7")[
  *$rank(A B) <= rank(A)$.* Every column of $A B$ is $A$ times the
  corresponding column of $B$, so every column of $A B$ lies in $"Col"(A)$.
  Hence $"Col"(A B) subset.eq "Col"(A)$, and the dimension of a subspace is
  at most that of the containing space.

  *$rank(A B) <= rank(B)$.* Apply the first result to transposes:
  $ rank(A B) = rank((A B)^T) = rank(B^T A^T) <= rank(B^T) = rank(B), $
  using $rank(M) = rank(M^T)$ twice.

  Together, $rank(A B) <= min(rank(A), rank(B))$.

  Consequence worth noting: multiplying can only ever *lose* rank. This is why
  a low-rank factorisation $A = C R$ with inner dimension $r$ forces
  $rank(A) <= r$ --- and why LoRA can only make rank-$r$ changes to a weight
  matrix.
]

#soln("21.8")[
  *At most one solution.* $rank(A) = n$ and $A$ has $n$ columns, so by
  rank--nullity $dim "Null"(A) = 0$. If $A x_1 = A x_2 = b$ then
  $A(x_1 - x_2) = 0$, so $x_1 - x_2 in "Null"(A) = {0}$, giving $x_1 = x_2$.

  *When there is none.* $A x = b$ is solvable iff $b in "Col"(A)$. Here
  $"Col"(A)$ is an $n$-dimensional subspace of $RR^m$ with $m > n$ --- a
  proper subspace, of measure zero. So for a *generic* $b$ there is no
  solution at all.

  This is the overdetermined case: more equations than unknowns, so the
  equations generically conflict. The response is not to give up but to change
  the question --- find the $x$ minimising $norm(A x - b)$, which is exactly
  the least-squares problem of Chapter 24. And since the columns are
  independent, $A^T A$ is invertible and that problem has a unique answer.
]

== Chapter 22 --- Determinants

#soln("22.1")[
  $ det mat(3,1;2,4) = (3)(4) - (1)(2) = 10. $

  $ det mat(1,2,3;4,5,6;7,8,9) = 0. $

  *Why, in terms of the columns:* $c_1 - 2c_2 + c_3 = (1-4+3, thin 4-10+6, thin 7-16+9) = (0,0,0)$.
  The columns are linearly dependent, so by property (e) the determinant is
  zero. Geometrically, the three columns lie in a plane rather than spanning
  $RR^3$, so the unit cube is flattened and the image has zero volume.
]

#soln("22.2")[
  Row reduce, tracking the pivots (no row swaps are needed, so no sign
  change):
  $
  mat(2,1,0,1; 1,3,1,0; 0,1,2,1; 1,0,1,3)
  arrow.r
  mat(2,1,0,1; 0,2.5,1,-0.5; 0,1,2,1; 0,-0.5,1,2.5)
  $
  ($R_2 - 0.5 R_1$, $R_4 - 0.5 R_1$). Then $R_3 - 0.4 R_2$ and
  $R_4 + 0.2 R_2$:
  $
  arrow.r mat(2,1,0,1; 0,2.5,1,-0.5; 0,0,1.6,1.2; 0,0,1.2,2.4)
  arrow.r mat(2,1,0,1; 0,2.5,1,-0.5; 0,0,1.6,1.2; 0,0,0,1.5)
  $
  ($R_4 - 0.75 R_3$).

  Adding a multiple of one row to another does not change the determinant, so
  $ det = 2 times 2.5 times 1.6 times 1.5 = 12. $
]

#soln("22.3")[
  $A$ is $4 times 4$ with $det A = 5$.

  $
  det(2A) &= 2^4 det A = 16 times 5 = 80 quad ("not" 10!) \
  det(A^T) &= det A = 5 \
  det(A^(-1)) &= 1 slash 5 \
  det(A^3) &= 5^3 = 125 \
  det(A^T A) &= det(A^T) det(A) = 25
  $

  The first is the one that catches people: scaling a matrix scales *every
  column*, so the determinant picks up $c$ once per dimension.
]

#soln("22.4")[
  From $Q^T Q = I$, take determinants:
  $ det(Q^T) det(Q) = det(I) = 1. $
  Since $det(Q^T) = det(Q)$, this is $(det Q)^2 = 1$, so
  $det Q = plus.minus 1$.

  *$det Q = +1$: a rotation.* Orientation is preserved --- a right-handed
  frame stays right-handed. These form the special orthogonal group
  $"SO"(n)$.

  *$det Q = -1$: a reflection* (or, in odd dimensions, a rotation composed
  with a reflection). Orientation is reversed; a right-handed frame becomes
  left-handed.

  This is the algebraic version of the fact that you cannot continuously
  deform a rotation into a reflection: the determinant is continuous and
  cannot jump from $+1$ to $-1$ without passing through $0$, which orthogonal
  matrices never do.
]

#soln("22.5")[
  Translate so that $P_1$ is at the origin; the other two vertices become
  $u = (x_2 - x_1, thin y_2 - y_1)$ and $v = (x_3 - x_1, thin y_3 - y_1)$.

  The parallelogram spanned by $u$ and $v$ has area $abs(det[u | v])$ --- the
  determinant is the area scale factor applied to the unit square. The
  triangle is half of it:
  $ "Area" = 1/2 abs(det mat(x_2 - x_1, x_3 - x_1; y_2 - y_1, y_3 - y_1)). $

  *The sign as an orientation test.* Without the absolute value, the
  determinant is positive iff $(P_1, P_2, P_3)$ are in counterclockwise order
  and negative iff clockwise (and zero iff collinear).

  That single sign is the primitive underneath computational geometry: Graham
  scan and Andrew's monotone chain build a convex hull by repeatedly asking
  "does adding this point turn left or right?" and popping the stack while the
  turn is the wrong way. Segment intersection, point-in-polygon, and Delaunay
  triangulation all reduce to the same test. It is one $2 times 2$
  determinant, and it is exact in integer arithmetic --- which is why robust
  geometry code keeps coordinates as integers where it can.
]

#soln("22.6")[
  From $A^2 = I$, take determinants: $(det A)^2 = det I = 1$, so
  $det A = plus.minus 1$.

  *$det A = +1$:* take $A = I$. Then $A^2 = I$. ✓

  *$det A = -1$:* take $A = diag(1, -1, dots, -1)$ with an odd number of
  $-1$s --- or simply $A = mat(1,0;0,-1)$ in two dimensions, a reflection.
  Reflecting twice returns you to the start, so $A^2 = I$, and
  $det A = -1$. ✓

  (Such matrices are called *involutions*, and geometrically they are
  reflections in some subspace: $A^2 = I$ forces the eigenvalues to be
  $plus.minus 1$, and the determinant is $-1$ exactly when an odd number of
  them are $-1$.)
]

#soln("22.7")[
  With $x = rho sin phi cos theta$, $y = rho sin phi sin theta$,
  $z = rho cos phi$:
  $
  J = mat(
    sin phi cos theta, rho cos phi cos theta, -rho sin phi sin theta;
    sin phi sin theta, rho cos phi sin theta, rho sin phi cos theta;
    cos phi, -rho sin phi, 0
  ).
  $

  Expand along the third row, which has a zero.

  The cofactor of $cos phi$ (position 3,1, sign $+$) is
  $
  det mat(rho cos phi cos theta, -rho sin phi sin theta; rho cos phi sin theta, rho sin phi cos theta)
  = rho^2 sin phi cos phi (cos^2 theta + sin^2 theta) = rho^2 sin phi cos phi.
  $

  The cofactor of $-rho sin phi$ (position 3,2, sign $-$) is
  $
  - det mat(sin phi cos theta, -rho sin phi sin theta; sin phi sin theta, rho sin phi cos theta)
  = -rho sin^2 phi (cos^2 theta + sin^2 theta) = -rho sin^2 phi.
  $

  So
  $ det J = cos phi (rho^2 sin phi cos phi) + (-rho sin phi)(-rho sin^2 phi) = rho^2 sin phi (cos^2 phi + sin^2 phi) = rho^2 sin phi. $

  Hence $dif V = rho^2 sin phi thin dif rho thin dif phi thin dif theta$,
  which is the volume element you have seen quoted --- now derived rather than
  memorised. It correctly vanishes at the poles ($phi = 0, pi$), where the
  coordinate system degenerates.
]

#soln("22.8")[
  *Magnitude.* For an $n times n$ matrix with i.i.d. entries of variance
  $sigma^2$, the typical magnitude of the determinant is around
  $sigma^n sqrt(n!)$. For $U[0,1]$ entries, $sigma^2 = 1 slash 12$ and
  $n = 200$:
  $ log_10 abs(det) approx 200 log_10 (1 slash sqrt(12)) + 1/2 log_10 (200!) approx -108 + 187 approx 79. $
  So $abs(det)$ is of order $10^(79)$ --- nowhere near $1$, and nowhere near
  $0$.

  *Why this makes `det` a bad singularity test.* The point is not that the
  value is small; it is that the value is *arbitrary*. It is not a normalised
  quantity, and it moves by hundreds of orders of magnitude for reasons having
  nothing to do with invertibility:

  - Scale every entry by $c$ and the determinant scales by $c^(200)$. Draw
    entries from $U[0, 0.01]$ instead --- a matrix with *identical*
    conditioning, since scaling multiplies all singular values equally and
    leaves $kappa$ unchanged --- and the determinant becomes
    $10^(79) times 10^(-400) = 10^(-321)$, which underflows a double to
    exactly zero.
  - Conversely $10^(-6) I$ in 200 dimensions has determinant $10^(-1200)$
    (zero, in floating point) and is trivially invertible with $kappa = 1$.

  The determinant is a *product* of all the singular values, so it measures
  volume. Conditioning is a *ratio* of the largest to the smallest. A product
  tells you nothing about a ratio. Test with the smallest singular value or
  `rcond`, never with `det`.
]

== Chapter 23 --- Eigenvalues and Eigenvectors

#soln("23.1")[
  $A = mat(3,1;1,3)$.

  $det(A - lambda I) = (3-lambda)^2 - 1 = lambda^2 - 6lambda + 8 = (lambda-2)(lambda-4)$,
  so $lambda = 2, 4$.

  *$lambda = 4$:* $(A - 4I) = mat(-1,1;1,-1)$, giving $v_1 = v_2$, so
  $v = (1,1)^T$.

  *$lambda = 2$:* $(A - 2I) = mat(1,1;1,1)$, giving $v_1 = -v_2$, so
  $v = (1,-1)^T$.

  *Orthogonality check:* $(1,1) dot (1,-1) = 1 - 1 = 0$. ✓ As the spectral
  theorem requires, since $A$ is symmetric.

  Also $lambda_1 + lambda_2 = 6 = tr(A)$ and
  $lambda_1 lambda_2 = 8 = det A$. ✓
]

#soln("23.2")[
  $A = mat(2,-1;1,2)$. $det(A - lambda I) = (2-lambda)^2 + 1 = 0$, so
  $lambda = 2 plus.minus i$.

  *Geometric interpretation.* Factor out the modulus:
  $ A = sqrt(5) mat(2 slash sqrt(5), -1 slash sqrt(5); 1 slash sqrt(5), 2 slash sqrt(5)) = sqrt(5) thin R_theta, quad cos theta = 2/sqrt(5), thin sin theta = 1/sqrt(5). $
  So $A$ is a *rotation by $theta = arctan(1 slash 2) approx 26.6 degree$,
  scaled by $sqrt(5)$*.

  The eigenvalues say exactly that:
  $abs(lambda) = sqrt(4 + 1) = sqrt(5)$ is the scaling, and
  $arg(lambda) = arctan(1 slash 2)$ is the rotation angle. Writing
  $lambda = sqrt(5) e^(plus.minus i theta)$ makes it explicit.

  A real matrix with non-real eigenvalues has *no* real eigenvector --- and it
  cannot, since a rotation leaves no direction fixed. The conjugate pair
  encodes a rotation in an invariant plane. This is Chapter 6 doing real work.
]

#soln("23.3")[
  $A = mat(2,1;0,2)$.

  $det(A - lambda I) = (2-lambda)^2$, so $lambda = 2$ with *algebraic
  multiplicity 2*.

  $(A - 2I) = mat(0,1;0,0)$. Solving $(A-2I)v = 0$ gives $v_2 = 0$ with $v_1$
  free, so the eigenspace is $span{(1,0)^T}$: *geometric multiplicity 1*.

  Since $1 < 2$, there is no basis of eigenvectors and $A$ is not
  diagonalisable --- it is *defective*.

  Geometrically $A$ is a shear (composed with a scaling by 2): it fixes the
  $x$-axis and tilts everything else. A shear has exactly one invariant
  direction, so there is nothing else to find.
]

#soln("23.4")[
  $ det(A^T - lambda I) = det((A - lambda I)^T) = det(A - lambda I), $
  using $(A - lambda I)^T = A^T - lambda I$ and $det(M^T) = det(M)$.

  Same characteristic polynomial, hence same eigenvalues with the same
  algebraic multiplicities.

  *Eigenvectors generally differ.* Take $A = mat(1,1;0,1)$. Its eigenvector
  for $lambda = 1$ is $(1,0)^T$. But $A^T = mat(1,0;1,1)$ has eigenvector
  $(0,1)^T$.

  The eigenvectors of $A^T$ are called the *left* eigenvectors of $A$ (they
  satisfy $w^T A = lambda w^T$), and they coincide with the right ones exactly
  when $A$ is symmetric --- or more generally normal.
]

#soln("23.5")[
  Let $A v = lambda v$ with $v != 0$ and $A$ invertible. Then $lambda != 0$
  (otherwise $A v = 0$ with $v != 0$ would make $A$ singular).

  *Inverse.* Apply $A^(-1)$ to both sides of $A v = lambda v$:
  $ v = lambda A^(-1) v quad arrow.r.double quad A^(-1) v = 1/lambda v. $
  Same eigenvector, reciprocal eigenvalue.

  *Square.* $A^2 v = A(lambda v) = lambda A v = lambda^2 v$.

  More generally $p(A) v = p(lambda) v$ for any polynomial $p$ --- which is
  why $A = P D P^(-1)$ makes every polynomial (and, by extension, the matrix
  exponential) trivial to evaluate.
]

#soln("23.6")[
  $A = mat(5,-2;-2,5)$. Characteristic: $(5-lambda)^2 - 4 = 0$, so
  $5 - lambda = plus.minus 2$, giving $lambda = 3, 7$.

  *$lambda = 7$:* $(A - 7I) = mat(-2,-2;-2,-2)$, so $v = (1,-1)^T$.
  *$lambda = 3$:* $(A - 3I) = mat(2,-2;-2,2)$, so $v = (1,1)^T$.

  $ P = mat(1,1;-1,1), quad D = mat(7,0;0,3), quad P^(-1) = 1/2 mat(1,-1;1,1). $

  Then $A^10 = P D^10 P^(-1)$ with $7^10 = 282,!475,!249$ and
  $3^10 = 59,!049$:
  $
  A^10 = 1/2 mat(7^10 + 3^10, 3^10 - 7^10; 3^10 - 7^10, 7^10 + 3^10)
  = mat(141,!267,!149, -141,!208,!100; -141,!208,!100, 141,!267,!149).
  $

  Two scalar exponentiations rather than ten matrix multiplications --- and
  for $A^(10^6)$ the saving becomes the difference between possible and not.
]

#soln("23.7")[
  *$mat(2,1;1,2)$.* Characteristic $(2-lambda)^2 - 1 = 0$ gives
  $lambda = 1, 3$. Both positive, so *positive definite*.

  Direct check with $x = (1,-1)^T$: $x^T A x = 2 - 2 - 2 + 2 = 0$? Let us
  compute properly:
  $x^T A x = 2(1)^2 + 2(1)(1)(-1) + 2(-1)^2 = 2 - 2 + 2 = 2 > 0$. ✓
  (The general quadratic form is $2x_1^2 + 2x_1 x_2 + 2x_2^2$, which is
  positive for all nonzero $x$.)

  *$mat(1,2;2,1)$.* Characteristic $(1-lambda)^2 - 4 = 0$ gives
  $1 - lambda = plus.minus 2$, so $lambda = 3, -1$. Eigenvalues of both
  signs: *indefinite*, not positive definite.

  Direct check with $x = (1,-1)^T$:
  $x^T A x = 1 - 2 - 2 + 1 = -2 < 0$. ✓ Confirms indefiniteness, and shows
  the vector realising it is the eigenvector for $lambda = -1$ --- as it must
  be, since that is the direction of most negative curvature.
]

#soln("23.8")[
  $P = mat(0.9, 0.4; 0.1, 0.6)$ (columns sum to 1).

  *Stationary distribution.* Solve $(P - I) pi = 0$:
  $ mat(-0.1, 0.4; 0.1, -0.4) pi = 0 quad arrow.r.double quad pi_1 = 4 pi_2. $
  Normalising so $pi_1 + pi_2 = 1$: $ pi = (0.8, thin 0.2)^T. $

  *Second eigenvalue.* $tr(P) = 0.9 + 0.6 = 1.5 = lambda_1 + lambda_2 = 1 + lambda_2$,
  so $lambda_2 = 0.5$.

  *Mixing time.* Deviations from stationarity decay like
  $abs(lambda_2)^k = 0.5^k$. Requiring a factor of 100:
  $ 0.5^k <= 0.01 quad arrow.r.double quad k >= (ln 0.01)/(ln 0.5) = 6.64, $
  so *7 steps*.

  The spectral gap here is $1 - 0.5 = 0.5$, which is large --- this chain
  mixes very fast. A chain with $lambda_2 = 0.999$ would need about 4600 steps
  for the same factor, and that gap is exactly what "slow mixing" means.
]

== Chapter 24 --- Orthogonality, Projection, and Least Squares

#soln("24.1")[
  $v_1 = (1,1,0)$, $v_2 = (1,0,1)$, $v_3 = (0,1,1)$.

  *Step 1.* $u_1 = (1,1,0)$, $norm(u_1) = sqrt(2)$, so
  $q_1 = (1,1,0) slash sqrt(2)$.

  *Step 2.* $v_2 dot q_1 = 1 slash sqrt(2)$, so
  $ u_2 = (1,0,1) - 1/2 (1,1,0) = (1/2, -1/2, 1), quad norm(u_2) = sqrt(3 slash 2), $
  giving $q_2 = (1,-1,2) slash sqrt(6)$.

  *Step 3.* $v_3 dot q_1 = 1 slash sqrt(2)$ and
  $v_3 dot q_2 = (0 - 1 + 2) slash sqrt(6) = 1 slash sqrt(6)$, so
  $
  u_3 = (0,1,1) - 1/2 (1,1,0) - 1/6 (1,-1,2) = (-2/3, thin 2/3, thin 2/3),
  $
  with $norm(u_3) = (2 slash 3) sqrt(3)$, giving
  $q_3 = (-1,1,1) slash sqrt(3)$.

  *Checks.* $q_1 dot q_2 = (1 - 1 + 0) slash sqrt(12) = 0$ ✓;
  $q_1 dot q_3 = (-1 + 1 + 0) slash sqrt(6) = 0$ ✓;
  $q_2 dot q_3 = (-1 - 1 + 2) slash sqrt(18) = 0$ ✓. All unit length by
  construction.
]

#soln("24.2")[
  With $A = mat(1,0;0,1;1,1)$ (columns $a_1 = (1,0,1)$, $a_2 = (0,1,1)$) and
  $b = (1,2,3)$:
  $ A^T A = mat(2,1;1,2), quad A^T b = vec(1 + 3, 2 + 3) = vec(4,5). $
  Solving $mat(2,1;1,2) x = (4,5)^T$ (determinant 3):
  $x_1 = (8-5) slash 3 = 1$, $x_2 = (10-4) slash 3 = 2$.

  $ hat(b) = 1 dot (1,0,1) + 2 dot (0,1,1) = (1,2,3). $

  *The residual is zero.* And indeed it should be: $b = a_1 + 2 a_2$ exactly,
  so $b$ was already in the plane and its projection is itself.

  This is a legitimate outcome and a useful check on the machinery: when
  $b in "Col"(A)$, least squares reduces to exact solution, the residual is
  $0$, and $0$ is trivially orthogonal to both spanning vectors.
]

#soln("24.3")[
  Data: $(1,1), (2,3), (3,4), (4,6)$. So $n = 4$,
  $ sum x = 10, quad sum y = 14, quad sum x y = 1 + 6 + 12 + 24 = 43, quad sum x^2 = 30. $

  The normal equations are
  $ mat(30, 10; 10, 4) vec(m, c) = vec(43, 14). $

  Solving (determinant $120 - 100 = 20$):
  $ m = (4(43) - 10(14))/20 = (172 - 140)/20 = 32/20 = 1.6, $
  $ c = overline(y) - m overline(x) = 3.5 - 1.6(2.5) = -0.5. $

  Fitted line: $y = 1.6 x - 0.5$.

  Residuals: $-0.1, +0.3, -0.3, +0.1$ --- summing to zero, as they must, since
  the residual is orthogonal to the column of ones.
]

#soln("24.4")[
  *Idempotent.* $(I-P)^2 = I - 2P + P^2 = I - 2P + P = I - P$, using
  $P^2 = P$.

  *Symmetric.* $(I-P)^T = I^T - P^T = I - P$.

  So $I - P$ is a projection matrix.

  *Onto what.* For $v in W$: $P v = v$, so $(I-P)v = 0$. For
  $v in W^perp$: $P v = 0$, so $(I-P)v = v$.

  So $I - P$ projects onto $W^perp$, the orthogonal complement. Together,
  $v = P v + (I-P)v$ is exactly the orthogonal decomposition theorem, realised
  as a pair of matrices summing to the identity.
]

#soln("24.5")[
  *$"Null"(A) subset.eq "Null"(A^T A)$.* If $A x = 0$ then
  $A^T A x = A^T 0 = 0$.

  *$"Null"(A^T A) subset.eq "Null"(A)$.* If $A^T A x = 0$, multiply on the
  left by $x^T$:
  $ 0 = x^T A^T A x = (A x)^T (A x) = norm(A x)^2, $
  so $A x = 0$.

  Hence the two null spaces are equal.

  *Rank.* Both $A$ and $A^T A$ have $n$ columns, so rank--nullity gives
  $ rank(A^T A) = n - dim "Null"(A^T A) = n - dim "Null"(A) = rank(A). $

  No hypothesis about independence was needed --- the identity holds for every
  $A$. (When the columns *are* independent, both ranks are $n$ and $A^T A$ is
  invertible, which is the lemma the projection formula needed.)
]

#soln("24.6")[
  For orthogonal $Q$, $Q^T Q = I$, so $Q^T Q$ has every eigenvalue equal to 1,
  so every singular value of $Q$ is $sqrt(1) = 1$. Hence
  $ kappa_2 (Q) = sigma_max / sigma_min = 1/1 = 1. $

  (Directly: $norm(Q x) = norm(x)$ for all $x$, so $norm(Q)_2 = 1$, and
  $Q^(-1) = Q^T$ is also orthogonal so $norm(Q^(-1))_2 = 1$.)

  *Why this makes QR the right method.* Condition numbers multiply through a
  chain of operations. An orthogonal transformation contributes a factor of 1,
  so it cannot amplify error at all. QR factorisation transforms the least
  squares problem using only orthogonal operations, so the solve inherits
  $kappa(A)$.

  The normal equations instead form $A^T A$, whose condition number is
  $kappa(A)^2$ --- squaring the difficulty and halving the number of correct
  digits, before any arithmetic has been done.
]

#soln("24.7")[
  $A = mat(1,1; 1,0; 0,1)$, columns $a_1 = (1,1,0)$, $a_2 = (1,0,1)$.

  Gram--Schmidt (the first two steps of Solution 24.1):
  $ q_1 = (1,1,0)/sqrt(2), quad q_2 = (1,-1,2)/sqrt(6). $

  $ R = mat(a_1 dot q_1, a_2 dot q_1; 0, a_2 dot q_2) = mat(sqrt(2), 1 slash sqrt(2); 0, sqrt(3 slash 2)). $

  *Least squares* for $b = (1,2,3)$:
  $ Q^T b = vec(q_1 dot b, q_2 dot b) = vec((1+2)/sqrt(2), (1 - 2 + 6)/sqrt(6)) = vec(3 slash sqrt(2), thin 5 slash sqrt(6)). $

  Back-substitute in $R x = Q^T b$:
  $ sqrt(3 slash 2) thin x_2 = 5 slash sqrt(6) quad arrow.r.double quad x_2 = 5/(sqrt(6) sqrt(3 slash 2)) = 5/3. $
  $ sqrt(2) x_1 + (1 slash sqrt(2))(5 slash 3) = 3 slash sqrt(2) quad arrow.r.double quad 2 x_1 + 5/3 = 3 quad arrow.r.double quad x_1 = 2/3. $

  $ hat(x) = (2 slash 3, thin 5 slash 3)^T. $

  *Cross-check with the normal equations:* $A^T A = mat(2,1;1,2)$,
  $A^T b = (3,4)^T$, and solving gives $x_1 = (6-4) slash 3 = 2 slash 3$,
  $x_2 = (8-3) slash 3 = 5 slash 3$. ✓
]

#soln("24.8")[
  Use the product-to-sum identity (Chapter 5):
  $ sin(2x) cos(3x) = 1/2 [ sin(5x) + sin(-x) ] = 1/2 [sin 5x - sin x]. $
  Each of $sin(5x)$ and $sin(x)$ integrates to a cosine, evaluated over a
  whole number of periods on $[-pi, pi]$:
  $ integral_(-pi)^pi sin(k x) dif x = [ -cos(k x)/k ]_(-pi)^pi = 0 $
  since $cos$ is even. So the integral is $0$.

  *Faster argument:* $sin(2x)$ is odd and $cos(3x)$ is even, so the product is
  odd, and the integral of an odd function over an interval symmetric about
  the origin vanishes.

  *The general principle:* distinct members of the Fourier basis
  ${1, cos n x, sin n x}$ are orthogonal with respect to the inner product
  $lr(⟨ f,g ⟩) = integral_(-pi)^pi f g$. That orthogonality is what makes the
  Fourier coefficient formula a simple projection, and it is the entire reason
  the decomposition works.
]
