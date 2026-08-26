#import "../lib.typ": *

= Geometry for Graphics and Simulation

== Transformations, and the affine problem

Chapter 20 established that linear maps are matrices. There is one thing they
cannot do: translation. $T(x) = x + t$ is not linear, because $T(0) != 0$.

That is inconvenient, because a graphics pipeline is a long chain of
transformations and you would like to compose them all into one matrix.

#definition(title: "homogeneous coordinates")[
  Represent a point $(x,y,z) in RR^3$ as the 4-vector $(x,y,z,1)$, and a
  *direction* as $(x,y,z,0)$. Then a translation becomes a matrix:
  $ T = mat(1,0,0,t_x; 0,1,0,t_y; 0,0,1,t_z; 0,0,0,1), quad T vec(x,y,z,1) = vec(x + t_x, y+t_y, z+t_z, 1). $
]

#intuition(title: "why the extra coordinate works")[
  An affine map in $n$ dimensions is a linear map in $n+1$ dimensions,
  restricted to the hyperplane $w = 1$. Adding a dimension buys you the
  translation.

  Two immediate benefits, both large:

  *Composition.* Every transformation --- translate, rotate, scale, shear,
  and projection --- is now a $4 times 4$ matrix, so a whole chain multiplies
  into one matrix applied once per vertex. This is why GPUs are built around
  $4 times 4$ matrix multiplication.

  *Points versus directions is now type-safe.* Points have $w = 1$;
  directions and normals have $w = 0$. Translating a direction should do
  nothing, and with $w = 0$ the translation column is multiplied by zero, so
  it correctly does nothing. The representation enforces a distinction you
  would otherwise have to remember.

  Also, with a general $w$, the convention is that $(x,y,z,w)$ represents
  $(x slash w, y slash w, z slash w)$ --- and *that* is what makes perspective
  projection expressible as a matrix, since the divide is deferred to the end.
]

#definition(title: "the standard 3D transforms")[
  $
  "Scale": &mat(s_x,0,0,0; 0,s_y,0,0; 0,0,s_z,0; 0,0,0,1) quad
  "Rotate about " z: mat(cos theta, -sin theta, 0, 0; sin theta, cos theta, 0,0; 0,0,1,0; 0,0,0,1)
  $
  and similarly about $x$ and $y$, each being the $2 times 2$ rotation of
  Chapter 5 embedded in the appropriate plane.
]

#warning(title: "transform order matters, and normals do not transform like points")[
  *Order.* $T R$ and $R T$ are different: rotating then translating puts the
  object somewhere different from translating then rotating (the second
  rotates the translated position about the origin). Matrix multiplication is
  composition (Chapter 20), and composition is not commutative. Read a chain
  right to left: in $M = T R S$, the scale is applied first.

  *Normals.* If you transform a surface by $M$, its normal vectors must be
  transformed by $(M^(-1))^T$, not by $M$.

  Why: a normal $n$ satisfies $n^T v = 0$ for every tangent $v$. After the
  transform the tangent is $M v$, and we need the new normal $n'$ to satisfy
  $n'^T M v = 0$. Taking $n' = (M^(-1))^T n$ gives
  $n'^T M v = n^T M^(-1) M v = n^T v = 0$. Correct.

  For a rotation, $(M^(-1))^T = M$, so nothing goes wrong and people forget
  the rule. Introduce a non-uniform scale and normals visibly break --- they
  stop being perpendicular to the surface and the lighting goes wrong. This is
  a classic graphics bug, and it is one line of linear algebra.
]

== Rotations in three dimensions

#definition(title: "rotation matrix")[
  A $3 times 3$ matrix $R$ is a rotation if $R^T R = I$ and $det R = +1$. The
  set of these is the group $"SO"(3)$.
]

The condition $R^T R = I$ makes it orthogonal --- preserving lengths and
angles (Chapter 20) --- and $det R = +1$ excludes reflections (Chapter 22).

#theorem(title: "Euler's rotation theorem")[
  Every element of $"SO"(3)$ is a rotation by some angle about some fixed
  axis.
]

#proof[
  $R$ is a real $3 times 3$ matrix, so its characteristic polynomial is a real
  cubic and therefore has at least one real root (Chapter 6). Since $R$ is
  orthogonal, all eigenvalues have modulus 1, and since $det R = 1$ is the
  product of the eigenvalues, the real one must be $+1$.

  The eigenvector for $lambda = 1$ is fixed by $R$: that is the axis. In the
  plane perpendicular to it, $R$ acts as a $2 times 2$ rotation with
  eigenvalues $e^(plus.minus i theta)$.
]

So a 3D rotation has three degrees of freedom: two for the axis direction, one
for the angle.

=== Euler angles and their failure

Represent a rotation as three successive rotations about coordinate axes ---
yaw, pitch, roll. Intuitive, compact (three numbers), and defective.

#warning(title: "gimbal lock is a real loss of a degree of freedom")[
  With the common yaw--pitch--roll convention, set pitch to $90 degree$. Now
  the yaw axis and the roll axis have been rotated into alignment: changing
  yaw and changing roll do *the same thing*. You have lost a degree of
  freedom, and there is no way to rotate out of the configuration smoothly.

  It is not a bug in a particular convention --- every three-parameter
  representation of $"SO"(3)$ has singularities somewhere. That is a
  topological fact: $"SO"(3)$ is not homeomorphic to any open subset of
  $RR^3$, so no global three-number chart exists.

  Practical consequences: interpolating between two orientations in Euler
  angles produces wobble and can pass through a singularity; and Apollo 11
  really did have to be flown around gimbal lock in its physical IMU.

  The fix is to use four numbers.
]

=== Quaternions

#definition(title: "quaternions")[
  $ q = w + x i + y j + z k, $
  with $i^2 = j^2 = k^2 = i j k = -1$, from which
  $ i j = k, quad j k = i, quad k i = j, quad j i = -k, dots $
  Multiplication is associative but *not commutative*.
]

#theorem(title: "quaternions represent rotations")[
  A rotation by angle $theta$ about a unit axis $u$ corresponds to the *unit*
  quaternion
  $ q = cos(theta/2) + sin(theta/2)(u_x i + u_y j + u_z k). $
  A point $v$ is rotated by
  $ v' = q v q^(-1), $
  treating $v$ as a quaternion with zero real part. Composition of rotations
  is quaternion multiplication.
]

#intuition(title: "why the half-angle, and what it costs")[
  The rotation formula applies $q$ *twice* --- once on each side --- so each
  application contributes half the rotation. Hence $theta slash 2$.

  This has a visible consequence: $q$ and $-q$ give the *same* rotation, since
  the two sign flips cancel in $q v q^(-1)$. A full $2 pi$ turn takes
  $q$ to $-q$, and you need $4 pi$ to return to $q$. Quaternions form a
  *double cover* of $"SO"(3)$.

  That sounds like a defect and it is the source of the advantages:

  - *No gimbal lock.* Four parameters with one constraint ($norm(q) = 1$)
    covers $"SO"(3)$ smoothly with no singularities.
  - *Cheap composition.* 16 multiplications, versus 27 for two $3 times 3$
    matrices.
  - *Cheap renormalisation.* Numerical drift is corrected by dividing by
    $norm(q)$, one square root. Re-orthogonalising a drifted rotation matrix
    requires Gram--Schmidt or an SVD.
  - *Correct interpolation.* Spherical linear interpolation (*slerp*) walks
    along the great circle between two unit quaternions, giving constant
    angular velocity. Interpolating Euler angles or matrix entries does not.
    (Watch the double cover: negate one quaternion if their dot product is
    negative, or you interpolate the long way round.)

  Quaternions are the reason every game engine, robotics stack, and IMU
  library represents orientation the way it does. And they are the direct
  descendant of Chapter 6: complex numbers rotate the plane; quaternions
  rotate space.
]

== Projection

#definition(title: "orthographic and perspective")[
  *Orthographic:* drop a coordinate. Parallel lines stay parallel; no
  foreshortening. Used for CAD and isometric games.

  *Perspective:* divide by depth. With the eye at the origin looking down
  $-z$, a point $(x,y,z)$ projects to $(-d x slash z, -d y slash z)$ on the
  plane $z = -d$.
]

The division by $z$ is what homogeneous coordinates were for. The perspective
matrix leaves a $z$-dependent value in the $w$ component, and the pipeline's
*perspective divide* --- dividing all components by $w$ at the end --- does
the projection.

#example(title: "the graphics pipeline, as matrix algebra")[
  $ "clip" = underbrace(P, "projection") dot underbrace(V, "view") dot underbrace(M, "model") dot "vertex". $

  $M$ places the object in the world, $V$ moves the world into the camera's
  frame (it is the inverse of the camera's pose), and $P$ applies the
  projection frustum. The three multiply into one matrix per object, uploaded
  once and applied to every vertex in parallel.

  After the perspective divide you are in normalised device coordinates and a
  viewport transform maps to pixels.

  The whole pipeline is Chapter 20's "composition is matrix multiplication",
  built into silicon.
]

== Curves and surfaces

#definition(title: "Bézier curve")[
  For control points $P_0, dots, P_n$,
  $ B(t) = sum_(i=0)^n binom(n,i) (1-t)^(n-i) t^i P_i, quad t in [0,1]. $
]

The coefficients are the *Bernstein polynomials* --- and they are the binomial
theorem of Chapter 9 with $x = t$ and $y = 1-t$, which is why they sum to 1.
That fact matters: the curve is a *weighted average* of the control points
with weights summing to one, so it always lies in their convex hull.

Properties, each with a one-line reason:

- Passes through $P_0$ and $P_n$ (all other weights vanish at the endpoints).
- Tangent at $P_0$ points towards $P_1$ (differentiate at $t=0$).
- Lies in the convex hull of the control points (weights are nonnegative and
  sum to 1).
- Affine invariant: transforming the control points transforms the curve.

The cubic case ($n = 3$) is the one that runs the world: SVG paths, font
outlines, animation easing curves, and vector illustration tools are all cubic
Béziers.

#definition(title: "de Casteljau's algorithm")[
  Evaluate $B(t)$ by repeated linear interpolation: interpolate between
  consecutive control points at parameter $t$, producing $n$ new points;
  repeat until one point remains. That point is $B(t)$.
]

Numerically stable (it is a sequence of convex combinations, so nothing can
blow up), and it *also* splits the curve into two Bézier curves at $t$ for
free --- which is what makes adaptive subdivision rendering possible.

*Splines* chain low-degree pieces together with continuity conditions at the
joins: $C^0$ matching position, $C^1$ matching tangent, $C^2$ matching
curvature. B-splines and NURBS generalise this with local control, so moving
one control point does not perturb the entire curve.

== Distances, intersections, and the primitives

The bread and butter of graphics, collision detection, and computational
geometry. All of it is Chapter 19.

#align(center)[
  #table(
    columns: 2,
    inset: 7pt,
    align: (left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Problem*], [*Solution*]),
    [Point to plane $n dot x = d$], [$(n dot p - d) slash norm(n)$; signed, so it also tells you which side],
    [Point to line through $a$ with direction $v$], [$norm((p - a) - proj_v (p-a))$],
    [Ray--sphere], [substitute the ray into $norm(x - c)^2 = r^2$; a quadratic in $t$, and the discriminant decides hit or miss],
    [Ray--plane], [solve $n dot (o + t d) = D$ for $t$; parallel iff $n dot d = 0$],
    [Ray--triangle], [Möller--Trumbore: solve for barycentric coordinates directly],
    [Which side of a line is $p$?], [sign of the $2 times 2$ determinant --- the cross product of Chapter 19],
    [Do segments intersect?], [the two endpoints of each must straddle the other's line: four orientation tests],
  )
]

#intuition(title: "barycentric coordinates")[
  Any point in a triangle $A B C$ is
  $ P = alpha A + beta B + gamma C, quad alpha + beta + gamma = 1. $

  The weights $(alpha,beta,gamma)$ are *barycentric coordinates*, and they are
  ratios of sub-triangle areas --- each of which is a determinant (Chapter 22).

  $P$ is inside the triangle exactly when all three are nonnegative, which is
  the standard point-in-triangle test.

  And they are how a rasteriser interpolates: colour, texture coordinates,
  normals, and depth at an interior pixel are the barycentric-weighted
  averages of the vertex values. The entire inner loop of a GPU is barycentric
  interpolation, and it is nothing more than "write the point as a weighted
  average of the corners".
]

== Rotations elsewhere

Two connections worth naming, since the same mathematics keeps reappearing.

*Rotary position embeddings.* A transformer with RoPE encodes token position
by rotating pairs of embedding coordinates by an angle proportional to
position. The dot product between a query at position $m$ and a key at
position $n$ then depends only on $m - n$, because composing a rotation with
the inverse of another leaves a rotation by the difference. That is the angle
addition formula of Chapter 5, doing load-bearing work in a language model.

*Orthogonal initialisation and constraints.* Orthogonal matrices preserve
norms (Chapter 20), so a recurrent network whose transition matrix is
constrained to be orthogonal cannot suffer exploding or vanishing gradients
from that matrix --- all its singular values are exactly 1. Orthogonal
initialisation is a cheaper approximation to the same idea.

== Exercises

#exercise[
  Write the $4 times 4$ homogeneous matrix that translates by $(2,3,4)$, and
  the one that scales by 2 about the origin. Compute both products and
  describe geometrically how the two results differ.
]

#exercise[
  Verify that the $z$-axis rotation matrix is orthogonal with determinant 1,
  and find its eigenvalues. Interpret the complex ones using Chapter 6.
]

#exercise[
  Show that if $M$ is a rotation matrix then $(M^(-1))^T = M$, so normals
  transform correctly under rotation without the special rule. Then find a
  non-uniform scale for which they do not.
]

#exercise[
  Convert a rotation of $90 degree$ about the $y$-axis to a unit quaternion,
  and verify that $q$ and $-q$ rotate the point $(1,0,0)$ identically.
]

#exercise[
  Compute the point at $t = 0.5$ on the cubic Bézier with control points
  $(0,0)$, $(0,1)$, $(1,1)$, $(1,0)$, using de Casteljau's algorithm. Sketch
  the curve.
]

#exercise[
  A ray starts at $(0,0,0)$ with direction $(1,1,1) slash sqrt(3)$. Find where
  it meets the sphere of radius 2 centred at $(3,3,3)$, by substituting into
  the sphere equation and solving the quadratic.
]

#exercise[
  Find the barycentric coordinates of the point $(2,1)$ with respect to the
  triangle $(0,0)$, $(4,0)$, $(0,3)$, and determine whether the point is
  inside.
]

#exercise[
  Explain in a paragraph why interpolating between two orientations by
  linearly interpolating their $3 times 3$ rotation matrices entrywise
  produces a matrix that is not a rotation, and what slerp does instead.
]
