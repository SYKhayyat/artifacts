#import "../lib.typ": *

= Vectors and Geometry

== What a vector is

Three answers, all correct, all needed.

*The physicist's:* a quantity with magnitude and direction --- an arrow.

*The programmer's:* an ordered list of numbers, `[3.0, -1.5, 2.0]`.

*The mathematician's:* an element of a *vector space* --- any set where you
can add elements and scale them by numbers, subject to some axioms.

The third looks like abstraction for its own sake, and it is the one that pays
off. Its point is that a great many things behave like arrows without being
arrows: polynomials, functions, matrices, images, random variables,
solutions of differential equations. Every theorem proved for abstract vector
spaces applies to all of them at once.

#definition(title: "vector space")[
  A *vector space* over $RR$ is a set $V$ with an addition
  $V times V -> V$ and a scalar multiplication $RR times V -> V$, such that
  for all $u,v,w in V$ and $a, b in RR$:

  #set enum(numbering: "(V1)")
  + $u + v = v + u$
  + $(u+v)+w = u+(v+w)$
  + there is a zero vector $0$ with $v + 0 = v$
  + each $v$ has an inverse $-v$ with $v + (-v) = 0$
  + $a(u+v) = a u + a v$
  + $(a+b)v = a v + b v$
  + $(a b) v = a (b v)$
  + $1 v = v$
]

Compare Chapter 8: (V1)--(V4) say $V$ is an abelian group under addition; the
rest say the scalars act compatibly. If you find yourself reaching for a
property not on that list, it does not hold in general.

#example(title: "vector spaces you already use")[
  - $RR^n$, tuples of $n$ reals. The prototype.
  - $RR^(m times n)$, all $m times n$ matrices.
  - $cal(P)_n$, polynomials of degree at most $n$. Adding polynomials and
    scaling them behaves exactly like adding arrows.
  - $C[0,1]$, continuous functions on $[0,1]$. Infinite-dimensional.
  - Solutions of a homogeneous linear ODE or recurrence --- which is why
    Chapter 11's "linear combination of characteristic roots" was legitimate.
  - Images: an RGB image is a vector in $RR^(3 h w)$, and averaging two images
    is vector addition.
]

#warning(title: "not everything is a vector space")[
  Vectors in $RR^3$ under the *cross product* are not a vector space under
  that operation --- it is not associative.

  Probability distributions over $n$ outcomes are *not* a vector space: they
  are not closed under scaling (doubling breaks the sum-to-one constraint) or
  under general addition. They form a *simplex*, a convex set, which is why
  optimising over distributions requires convex optimisation rather than plain
  linear algebra.

  Unsigned image pixel values in $[0,255]$ are not a vector space either.
  Clipping is exactly the failure of closure.
]

== $RR^n$ and its geometry

Write vectors as columns:
$ v = vec(v_1, v_2, dots.v, v_n) in RR^n. $

Addition and scaling are componentwise. Geometrically, addition is
tip-to-tail; scaling stretches (and flips, if negative).

#definition(title: "dot product")[
  $ u dot v = u^T v = sum_(i=1)^n u_i v_i. $
]

#definition(title: "norm")[
  $ norm(v) = sqrt(v dot v) = sqrt(sum_i v_i^2). $
  This is the *Euclidean* or $ell_2$ norm --- the length of the arrow, by
  Pythagoras.
]

#theorem(title: "the geometric meaning of the dot product")[
  $ u dot v = norm(u) norm(v) cos theta, $
  where $theta$ is the angle between $u$ and $v$.
]

#proof[
  Apply the law of cosines (Chapter 5) to the triangle with sides $u$, $v$,
  and $v - u$:
  $ norm(v-u)^2 = norm(u)^2 + norm(v)^2 - 2 norm(u) norm(v) cos theta. $
  Expand the left side algebraically:
  $ norm(v-u)^2 = (v-u) dot (v-u) = norm(v)^2 - 2 u dot v + norm(u)^2. $
  Comparing the two gives the result.
]

#intuition(title: "the dot product measures agreement")[
  Read $u dot v = norm(u) norm(v) cos theta$ as: *how much of $u$ points along
  $v$, times how big $v$ is.*

  - $u dot v > 0$: the vectors broadly agree, angle under $90 degree$.
  - $u dot v = 0$: perpendicular. This is the definition of *orthogonal*, and
    it is the single most useful condition in linear algebra.
  - $u dot v < 0$: they oppose.

  This is the reason cosine similarity is *the* similarity measure for
  embeddings. Two word vectors are similar when they point the same way; their
  magnitudes usually encode frequency rather than meaning, so you divide them
  out:
  $ "cos-sim"(u,v) = (u dot v)/(norm(u) norm(v)) in [-1,1]. $
  And when your embeddings are pre-normalised to unit length --- as they
  usually are --- cosine similarity *is* the dot product, which is why
  similarity search is a matrix multiplication.
]

#theorem(title: "Cauchy--Schwarz inequality")[
  $ abs(u dot v) <= norm(u) norm(v), $
  with equality iff $u$ and $v$ are parallel.
]

#proof[
  If $v = 0$ both sides are zero. Otherwise consider, for real $t$,
  $ p(t) = norm(u - t v)^2 = norm(u)^2 - 2 t (u dot v) + t^2 norm(v)^2. $
  This is a quadratic in $t$ that is never negative (it is a squared norm).
  A quadratic $a t^2 + b t + c$ with $a>0$ is nonnegative for all $t$ exactly
  when its discriminant is $<= 0$ (Chapter 2):
  $ 4(u dot v)^2 - 4 norm(v)^2 norm(u)^2 <= 0. $
  Rearranged, that is the claim. Equality holds iff the quadratic has a real
  root, i.e. $u = t v$ for some $t$.
]

Note this proof does not use the geometric formula, so it holds in *any* space
with an inner product --- including infinite-dimensional function spaces. It
is also what guarantees $cos theta in [-1,1]$, so that the angle is
well-defined in the first place.

#corollary(title: "triangle inequality in $RR^n$")[
  $norm(u + v) <= norm(u) + norm(v)$.
]

#proof[
  $ norm(u+v)^2 = norm(u)^2 + 2 u dot v + norm(v)^2 <= norm(u)^2 + 2 norm(u) norm(v) + norm(v)^2 = (norm(u)+norm(v))^2, $
  using Cauchy--Schwarz in the middle. Take square roots.
]

== Other norms

$ norm(v)_p = ( sum_i abs(v_i)^p )^(1 slash p). $

- $p = 2$: Euclidean. Rotation-invariant, differentiable away from zero, the
  default.
- $p = 1$: $norm(v)_1 = sum abs(v_i)$, "Manhattan" or taxicab distance.
- $p = infinity$: $norm(v)_infinity = max_i abs(v_i)$, the limiting case.

#intuition(title: "why $ell_1$ produces sparsity")[
  Picture the unit balls in $RR^2$: the $ell_2$ ball is a circle, the $ell_1$
  ball is a diamond with corners on the axes, the $ell_infinity$ ball is a
  square.

  Now think about a regularised regression, which minimises error subject to
  the coefficient vector lying in a small ball. Geometrically you inflate the
  error contours until they first touch the ball.

  A circle has no corners, so the touch point is generically somewhere
  arbitrary --- no coordinate is zero. A diamond has corners *on the axes*, and
  a generic contour is much more likely to touch a corner. A corner is a point
  where some coordinates are exactly zero.

  That is the entire geometric explanation of why lasso ($ell_1$) gives sparse
  models and ridge ($ell_2$) does not. It is one picture and it is worth
  drawing.
]

== Linear combinations, span, independence

#definition(title: "linear combination and span")[
  A *linear combination* of $v_1, dots, v_k$ is $sum_i c_i v_i$ for scalars
  $c_i$. Their *span* is the set of all such combinations:
  $ span{v_1,dots,v_k} = { sum_i c_i v_i : c_i in RR }. $
]

The span is always a subspace: it contains $0$ and is closed under addition
and scaling. In $RR^3$, the span of one nonzero vector is a line, of two
independent vectors a plane, of three a copy of all of $RR^3$.

#definition(title: "linear independence")[
  $v_1, dots, v_k$ are *linearly independent* if
  $ c_1 v_1 + dots.c + c_k v_k = 0 quad arrow.r.double quad c_1 = dots.c = c_k = 0. $
  Otherwise they are *dependent*.
]

#intuition(title: "independence means no redundancy")[
  Dependent means one of the vectors can be written in terms of the others ---
  it adds no new directions. Independent means every vector contributes
  something the rest cannot produce.

  The definition is phrased via "the only way to get zero is trivially"
  because that formulation is symmetric in the vectors and easy to check: it
  is a homogeneous linear system, and Chapter 21 will solve it by elimination.

  Programmer's reading: a dependent set is a schema with a derived column ---
  storing it is redundant, and it will make your normal equations singular.
]

#definition(title: "basis and dimension")[
  A *basis* of a vector space $V$ is a linearly independent set that spans
  $V$. Every basis of $V$ has the same number of elements, called the
  *dimension* $dim V$.
]

#theorem(title: "unique representation")[
  If $B = {v_1, dots, v_n}$ is a basis of $V$, every $v in V$ has *exactly
  one* expression $v = sum c_i v_i$.
]

#proof[
  Existence is spanning. For uniqueness, suppose
  $sum c_i v_i = sum d_i v_i$. Subtracting, $sum (c_i - d_i) v_i = 0$, and
  independence forces every $c_i - d_i = 0$.
]

#intuition(title: "a basis is a coordinate system")[
  The unique coefficients $(c_1, dots, c_n)$ are the *coordinates* of $v$ in
  the basis $B$. Choosing a basis is choosing how to name points with numbers.

  The standard basis $e_1, dots, e_n$ of $RR^n$ (ones in one slot, zeros
  elsewhere) is one choice among infinitely many, and often not the best one.
  Much of applied linear algebra is *finding the right basis*:

  - Eigenvectors (Chapter 23): the basis in which a linear map is diagonal.
  - Principal components (Chapter 25): the basis in which your data has
    uncorrelated coordinates, ordered by variance.
  - Fourier basis: the basis in which convolution becomes multiplication.
  - Wavelets: the basis in which natural images are sparse --- which is what
    JPEG-2000 exploits.

  Same objects, different names for them, radically different difficulty.
]

== Subspaces

#definition(title: "subspace")[
  A subset $W subset.eq V$ is a *subspace* if it contains $0$ and is closed
  under addition and scalar multiplication.
]

Checking those three conditions is the standard exercise, and the first one
does most of the work: a set not containing the origin is never a subspace.
The plane $x + y + z = 1$ is not a subspace; the plane $x + y + z = 0$ is.
That distinction --- *affine* versus *linear* --- is the same one that
distinguishes $y = m x + b$ from $y = m x$, and it is why neural networks
carry a separate bias term.

== Projection

#definition(title: "projection onto a vector")[
  The projection of $u$ onto the direction of $v != 0$ is
  $ proj_v (u) = ((u dot v)/(v dot v)) v. $
]

#proof[
  We want the multiple $t v$ closest to $u$; equivalently, the one for which
  the error $u - t v$ is orthogonal to $v$. Setting $(u - t v) dot v = 0$
  gives $u dot v = t (v dot v)$, so $t = (u dot v) slash (v dot v)$.
]

#intuition(title: "orthogonality of the residual is the whole story")[
  The condition that made the projection optimal was: *the error is
  perpendicular to the thing you projected onto.*

  That single principle, repeated, gives:

  - least squares regression (Chapter 24): the residual is orthogonal to the
    column space of the design matrix;
  - Gram--Schmidt: subtract off projections until what remains is orthogonal;
  - Fourier coefficients: each is a projection onto a basis sinusoid;
  - conditional expectation in probability (Chapter 29): $EE[Y|X]$ is the
    orthogonal projection of $Y$ onto the space of functions of $X$, and the
    "error is orthogonal" statement is the law of total expectation.

  If you take one thing from Part IV, take this.
]

== The cross product (three dimensions only)

#definition[
  For $u, v in RR^3$,
  $ u times v = vec(u_2 v_3 - u_3 v_2, u_3 v_1 - u_1 v_3, u_1 v_2 - u_2 v_1). $
]

Properties: $u times v$ is orthogonal to both $u$ and $v$;
$norm(u times v) = norm(u) norm(v) sin theta$, which is the area of the
parallelogram they span; the direction follows the right-hand rule; and
$u times v = -(v times u)$, so it is anticommutative and definitely not
associative.

Uses: surface normals in graphics, torque and angular momentum in physics,
testing which side of a line a point falls on (the sign of a $2 times 2$
determinant, which is the $z$-component of a cross product) --- the primitive
underneath every convex hull and polygon-triangulation algorithm.

The cross product exists only in $RR^3$ (and, in a degenerate way, $RR^7$).
The general-dimension replacement is the *wedge product* of exterior algebra,
and the determinant of Chapter 22 is its shadow.

== Exercises

#exercise[
  Let $u = (1, -2, 3)$ and $v = (4, 0, -1)$. Compute $u dot v$, $norm(u)$,
  $norm(v)$, the angle between them, $proj_v (u)$, and $u times v$. Verify
  that $u times v$ is orthogonal to both.
]

#exercise[
  Determine whether each is a subspace of $RR^3$, justifying: (a)
  ${(x,y,z) : x + 2y = 0}$; (b) ${(x,y,z): x >= 0}$;
  (c) ${(x,y,z) : x y = 0}$; (d) ${(x,y,z) : x = y = z}$.
]

#exercise[
  Determine whether $(1,2,3), (2,1,0), (4,5,6)$ are linearly independent. If
  not, exhibit an explicit dependence relation.
]

#exercise[
  Prove that any set of vectors containing the zero vector is linearly
  dependent.
]

#exercise[
  Prove the *parallelogram law*:
  $norm(u+v)^2 + norm(u-v)^2 = 2 norm(u)^2 + 2 norm(v)^2$. Then explain what
  it says geometrically about a parallelogram's diagonals.
]

#exercise[
  Show that $norm(v)_infinity <= norm(v)_2 <= norm(v)_1$ for every
  $v in RR^n$, and find vectors achieving equality in each.
]

#exercise[
  Show that ${1, x, x^2}$ is a basis for the space of polynomials of degree at
  most 2, and find the coordinates of $p(x) = 3 - x + 2x^2$ in that basis.
  Then find its coordinates in the basis ${1, 1+x, (1+x)^2}$.
]

#exercise[
  Prove that if $u dot v = 0$ then $norm(u+v)^2 = norm(u)^2 + norm(v)^2$, and
  identify the classical theorem this is.
]
