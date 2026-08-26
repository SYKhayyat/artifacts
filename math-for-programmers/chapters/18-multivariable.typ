#import "../lib.typ": *

= Calculus in Many Variables

== The jump

Every real problem has more than one input. A loss function has a million
parameters. A physical field depends on three coordinates and time. A
rendering equation depends on position and direction.

The good news: nothing conceptually new happens. The derivative is still *the
best linear approximation*, and the integral is still *a limit of sums*. What
changes is that "linear approximation" now needs a vector or a matrix to write
down, and the bookkeeping grows.

This chapter is where calculus and linear algebra meet. It is also where the
gradient comes from, and therefore where machine learning comes from.

#warning(title: "read Chapters 19-20 first if you need to")[
  From here on we use vectors and matrices freely. If they are unfamiliar,
  read the first two chapters of Part IV now and come back. Nothing is lost by
  reading Part IV before finishing Part III --- the dependency genuinely runs
  that way.
]

== Functions of several variables

$f : RR^n -> RR$ takes a vector and returns a number: a *scalar field*. A loss
function is one of these.

$f : RR^n -> RR^m$ returns a vector: a *vector field* or a *map*. A neural
network layer is one of these.

Visualisation for $n = 2$: the graph is a surface in $RR^3$. More useful in
practice is the *contour plot* --- the curves $f(x,y) = c$ for various $c$,
exactly like a topographic map. Contours are how you should picture a loss
landscape, and they make the geometry of gradient descent obvious.

== Partial derivatives

#definition(title: "partial derivative")[
  $ (partial f)/(partial x_i) (a) = lim_(h->0) (f(a + h e_i) - f(a))/h, $
  where $e_i$ is the $i$-th standard basis vector. That is: differentiate with
  respect to $x_i$, holding all other variables fixed.
]

Computationally this is trivially easy --- treat the other variables as
constants and use every rule from Chapter 14.

#example[
  $f(x,y) = x^2 y + sin(x y)$.
  $ (partial f)/(partial x) = 2 x y + y cos(x y), quad (partial f)/(partial y) = x^2 + x cos(x y). $
]

#warning(title: "partial derivatives alone do not mean much")[
  Here is a function whose partials both exist at the origin but which is not
  even continuous there:
  $ f(x,y) = cases((x y)/(x^2+y^2) quad &(x,y) != (0,0), 0 &"otherwise"). $

  Along either axis $f$ is identically $0$, so both partials at the origin are
  $0$. But along the line $y = x$, $f = 1 slash 2$ everywhere except at the
  origin --- so the limit as you approach the origin depends on the direction,
  and $f$ is discontinuous.

  In one variable, differentiable implied continuous. In many variables,
  *having partial derivatives does not*. Partials only probe $n$ special
  directions; they can miss what happens in between. The correct notion of
  differentiability is stronger, and it is next.
]

== The gradient and total differentiability

#definition(title: "gradient")[
  For $f : RR^n -> RR$, the *gradient* is the vector of partials
  $ nabla f = ((partial f)/(partial x_1), (partial f)/(partial x_2), dots, (partial f)/(partial x_n))^T. $
]

#definition(title: "differentiable, properly")[
  $f : RR^n -> RR$ is *differentiable* at $a$ if there is a vector $g$ with
  $ f(a + h) = f(a) + g^T h + r(h), quad "where" quad (r(h))/norm(h) -> 0 "as" h -> 0. $
  When this holds, $g = nabla f(a)$.
]

Compare Chapter 14's local-linearity proposition. It is the *same definition*,
with the scalar $m h$ replaced by the dot product $g^T h$. That is the whole
generalisation.

#theorem[
  If all partial derivatives of $f$ exist and are continuous near $a$, then
  $f$ is differentiable at $a$.
]

So the pathological example above is ruled out by continuity of the partials,
and for every function you will meet in practice, "compute the partials and
stack them" is legitimate.

#definition(title: "directional derivative")[
  For a unit vector $u$,
  $ D_u f(a) = lim_(h->0) (f(a + h u) - f(a))/h = nabla f(a)^T u. $
]

#theorem(title: "the gradient points uphill, steepest")[
  Among all unit vectors $u$, $D_u f(a)$ is largest when $u$ points in the
  direction of $nabla f(a)$, and its value is then $norm(nabla f(a))$.
]

#proof[
  $D_u f = nabla f^T u = norm(nabla f) norm(u) cos theta = norm(nabla f) cos theta$
  where $theta$ is the angle between $u$ and $nabla f$ (Chapter 19). This is
  maximised at $cos theta = 1$, i.e. $theta = 0$.
]

#intuition(title: "everything about the gradient, in one place")[
  - *Direction:* $nabla f$ points in the direction of steepest *increase*.
  - *Magnitude:* $norm(nabla f)$ is the rate of increase in that direction.
  - *Descent:* $-nabla f$ is steepest decrease. That is the entire idea of
    gradient descent: $x_(k+1) = x_k - eta nabla f(x_k)$.
  - *Orthogonality:* $nabla f$ is perpendicular to the level set (contour)
    through the point. Proof: moving along a contour keeps $f$ constant, so
    the directional derivative along it is $0$, so $nabla f^T u = 0$.
  - *Zero at optima:* at a local max or min, $nabla f = 0$ --- Fermat's
    theorem (Chapter 15) applied in each coordinate.

  The contour picture makes gradient descent intuitive: you are standing on a
  hillside in fog, you can feel which way is downhill, you take a step. If the
  contours are long thin ellipses (an *ill-conditioned* problem), the gradient
  points mostly *across* the valley rather than along it, and you zigzag.
  Chapter 34 quantifies exactly how badly, in terms of the condition number.
]

== The Jacobian

#definition(title: "Jacobian")[
  For $f : RR^n -> RR^m$ with components $f_1, dots, f_m$, the *Jacobian* is
  the $m times n$ matrix
  $ J = (partial f)/(partial x) = mat(
    (partial f_1)/(partial x_1), dots.c, (partial f_1)/(partial x_n);
    dots.v, dots.down, dots.v;
    (partial f_m)/(partial x_1), dots.c, (partial f_m)/(partial x_n)
  ), quad J_(i j) = (partial f_i)/(partial x_j). $
]

The defining property is exactly the same as before:
$ f(a + h) approx f(a) + J h. $

*The Jacobian is the derivative.* Row $i$ is the gradient of the $i$-th output;
column $j$ says how every output responds to input $j$. For $m = 1$ the
Jacobian is the gradient written as a row.

#theorem(title: "multivariate chain rule")[
  If $g : RR^n -> RR^m$ and $f : RR^m -> RR^p$, then
  $ J_(f compose g)(x) = J_f (g(x)) dot J_g (x), $
  a $p times m$ matrix times an $m times n$ matrix.
]

#intuition(title: "the chain rule is matrix multiplication, and that is backprop")[
  In one variable, gains multiplied. Here, *Jacobians multiply* --- and matrix
  multiplication is the correct generalisation because each output can depend
  on each input through every intermediate.

  Now consider a network: $x -> h_1 -> h_2 -> dots.c -> h_L -> L$ where the
  final loss $L$ is a scalar. The chain rule gives
  $ (partial L)/(partial x) = (partial L)/(partial h_L) (partial h_L)/(partial h_(L-1)) dots.c (partial h_1)/(partial x). $

  You can multiply that chain of matrices left-to-right or right-to-left, and
  it matters enormously.

  *Right to left (forward mode):* you multiply matrices together, cost
  dominated by matrix--matrix products.

  *Left to right (reverse mode):* the leftmost factor is a $1 times n$ row
  vector (since $L$ is a scalar), so every product is *vector times matrix* ---
  far cheaper. You get the gradient with respect to *all* parameters at
  roughly the cost of one forward pass.

  That asymmetry --- one output, many inputs --- is why reverse mode wins for
  machine learning, and reverse-mode automatic differentiation is exactly what
  backpropagation is. It is a statement about the associativity of matrix
  multiplication and nothing more. Chapter 36 works it out in full.
]

The special case worth writing separately: if $z = f(x,y)$ with
$x = x(t)$, $y = y(t)$, then
$ (dif z)/(dif t) = (partial f)/(partial x) (dif x)/(dif t) + (partial f)/(partial y) (dif y)/(dif t). $
Sum over every path by which $t$ influences $z$. That is how you should read
every chain rule: *sum over paths, multiply along each path* --- which is
exactly the matrix product of Chapter 10's walk-counting theorem, again.

== Second derivatives: the Hessian

#definition(title: "Hessian")[
  For $f : RR^n -> RR$, the *Hessian* is the $n times n$ matrix of second
  partials
  $ H_(i j) = (partial^2 f)/(partial x_i partial x_j). $
]

#theorem(title: "Clairaut / Schwarz")[
  If the second partials are continuous, then
  $ (partial^2 f)/(partial x partial y) = (partial^2 f)/(partial y partial x), $
  so the Hessian is *symmetric*.
]

Symmetry is not a technicality: Chapter 23 shows symmetric matrices have real
eigenvalues and orthogonal eigenvectors, and that is what makes the second
derivative test below work.

#theorem(title: "second derivative test in $n$ dimensions")[
  Let $nabla f(a) = 0$. Then:
  - $H(a)$ positive definite (all eigenvalues $> 0$) $arrow.r.double$ local
    minimum;
  - $H(a)$ negative definite (all eigenvalues $< 0$) $arrow.r.double$ local
    maximum;
  - $H(a)$ indefinite (eigenvalues of both signs) $arrow.r.double$ *saddle
    point*;
  - $H(a)$ singular $arrow.r.double$ inconclusive.
]

#intuition(title: "saddle points are the real obstacle in high dimensions")[
  In one variable a critical point is a max or a min (or an inflection). In
  $n$ dimensions there are $n$ eigenvalue signs to get right, so there are
  many more ways to be neither.

  Heuristically, if the signs were random, a critical point would be a local
  minimum with probability about $2^(-n)$. For $n$ in the millions, local
  minima are vanishingly rare and *saddle points overwhelmingly dominate*.

  This overturns the folk story that neural network training is hard because
  it gets stuck in bad local minima. The actual difficulty is saddle points
  and long flat regions, where the gradient is nearly zero but you are not at a
  minimum. Momentum-based optimisers exist largely to escape them.
]

The multivariate Taylor expansion, to second order:
$ f(a + h) approx f(a) + nabla f(a)^T h + 1/2 h^T H(a) h. $
The quadratic form $h^T H h$ is the local shape of the surface, and its
eigenvalues are the curvatures along the principal axes. When the ratio of
largest to smallest eigenvalue is huge, the bowl is a long thin valley --- the
ill-conditioning of the intuition box above.

== Optimisation with constraints: Lagrange multipliers

#theorem(title: "Lagrange multipliers")[
  To find the extrema of $f(x)$ subject to $g(x) = 0$, solve
  $ nabla f = lambda nabla g, quad g(x) = 0 $
  for $x$ and the scalar $lambda$.
]

#intuition(title: "why the gradients must be parallel")[
  Picture the contours of $f$ and the constraint curve $g = 0$.

  If the constraint curve *crosses* a contour of $f$, you can slide along the
  curve to a higher contour --- so you are not at an extremum. At an extremum
  the constraint curve must be *tangent* to a contour of $f$.

  Tangency of the curves means their normals are parallel. The normal to a
  contour of $f$ is $nabla f$; the normal to $g = 0$ is $nabla g$. So
  $nabla f = lambda nabla g$.

  The multiplier $lambda$ is not junk either: it is the *shadow price*, the
  rate at which the optimal value changes as you relax the constraint. In an
  economics problem it is the marginal value of the resource; in a machine
  learning problem it is the trade-off weight in the corresponding penalty
  term. Ridge regression and its constrained form are related exactly by this
  $lambda$.
]

#example[
  Maximise $f(x,y) = x y$ subject to $x + y = 10$.

  $nabla f = (y, x)$, $g = x + y - 10$, $nabla g = (1,1)$. The conditions are
  $y = lambda$, $x = lambda$, $x + y = 10$, giving $x = y = 5$ and the maximum
  $25$.

  Sanity check with AM--GM from Chapter 2: $sqrt(x y) <= (x+y) slash 2 = 5$,
  so $x y <= 25$ with equality iff $x = y$. The two methods agree, as they
  must.
]

For several constraints, one multiplier each: $nabla f = sum_i lambda_i nabla g_i$.
With inequality constraints the conditions become the Karush--Kuhn--Tucker
conditions, which are the foundation of constrained convex optimisation
(Chapter 34).

== Multiple integrals

#definition(title: "double integral")[
  $ integral.double_R f(x,y) dif A = lim sum f(x_i^*, y_j^*) Delta A_(i j), $
  a limit of Riemann sums over small rectangles tiling the region $R$.
]

#theorem(title: "Fubini's theorem")[
  If $f$ is continuous on a rectangle $[a,b] times [c,d]$, then
  $ integral.double f dif A = integral_a^b ( integral_c^d f(x,y) dif y ) dif x = integral_c^d ( integral_a^b f(x,y) dif x ) dif y. $
]

So a double integral is computed as two nested single integrals, in either
order. Choosing the convenient order can turn an impossible integral into an
easy one, and for non-rectangular regions the inner limits become functions of
the outer variable.

#theorem(title: "change of variables")[
  Under a substitution $x = T(u)$ with Jacobian matrix $J_T$,
  $ integral.double_R f(x) dif x = integral.double_(T^(-1)(R)) f(T(u)) abs(det J_T) dif u. $
]

#intuition(title: "the determinant is a volume scale factor")[
  In one variable, substitution introduced a factor $(dif x) slash (dif u)$.
  Here that factor becomes $abs(det J_T)$, and the reason is Chapter 22's
  interpretation of the determinant: *$abs(det A)$ is the factor by which the
  linear map $A$ scales volume.*

  Locally, $T$ looks like the linear map $J_T$. So a tiny box of volume
  $dif u$ maps to a tiny parallelepiped of volume $abs(det J_T) dif u$. The
  determinant is the exchange rate between the two coordinate systems.
]

#example(title: "polar coordinates, and the Gaussian integral")[
  With $x = r cos theta$, $y = r sin theta$,
  $ J = mat(cos theta, -r sin theta; sin theta, r cos theta), quad det J = r(cos^2 + sin^2) = r, $
  so $dif A = r dif r dif theta$. The extra $r$ is not a convention to
  memorise; it is the determinant, and it says that a patch far from the
  origin subtends more area for the same $dif theta$.

  Now the famous application. Let $I = integral_(-infinity)^infinity e^(-x^2) dif x$,
  which has no elementary antiderivative. Square it and convert to polar:
  $
  I^2 &= ( integral_(-infinity)^infinity e^(-x^2) dif x ) ( integral_(-infinity)^infinity e^(-y^2) dif y )
  = integral.double_(RR^2) e^(-(x^2+y^2)) dif A \
  &= integral_0^(2pi) integral_0^infinity e^(-r^2) r dif r dif theta
  = 2 pi dot [ -1/2 e^(-r^2) ]_0^infinity = 2 pi dot 1/2 = pi.
  $
  So $I = sqrt(pi)$.

  That $r$ from the Jacobian is exactly what makes the inner integral
  elementary --- $r e^(-r^2)$ integrates by substitution while $e^(-r^2)$ does
  not. This computation is why the normal distribution has a $sqrt(2 pi)$ in
  its denominator (Chapter 28), and it is one of the most satisfying pieces of
  mathematics in this book.
]

== Vector calculus, briefly

For completeness, since the notation appears in physics, graphics, and PDE
literature.

#definition[
  For a vector field $F = (F_1, F_2, F_3)$ and scalar field $f$:
  $
  "grad" f &= nabla f &&"(vector: direction of steepest ascent)" \
  "div" F &= nabla dot F = sum_i (partial F_i)/(partial x_i) &&"(scalar: net outflow per volume)" \
  "curl" F &= nabla times F &&"(vector: local rotation)" \
  "Laplacian" &= nabla^2 f = "div"("grad" f) = sum_i (partial^2 f)/(partial x_i^2) &&"(scalar: how far f is from its local average)"
  $
]

The Laplacian reading is the useful one: $nabla^2 f$ at a point is
proportional to (average of $f$ on a small sphere around the point) minus
($f$ at the point). It is a *smoothing detector*, which is why it governs heat
diffusion, why $nabla^2 f = 0$ (Laplace's equation) means "equal to your own
average", and why the discrete Laplacian is an edge-detection kernel in image
processing --- and why the graph Laplacian of Chapter 10 has the same name.

The three great theorems --- Green's, Stokes', and the divergence theorem ---
are all the Fundamental Theorem of Calculus in higher dimensions: *the
integral of a derivative over a region equals something evaluated on the
boundary.* Chapter 16's $integral_a^b f' = f(b)-f(a)$ is the one-dimensional
case, where the "boundary" of $[a,b]$ is the two points $a$ and $b$.

== Exercises

#exercise[
  For $f(x,y) = x^3 y - 4 x y^2 + y$, compute both partial derivatives, the
  gradient at $(1,2)$, and the Hessian.
]

#exercise[
  Find the directional derivative of $f(x,y) = x^2 + 3 x y$ at $(1,2)$ in the
  direction of the vector $(3,4)$. (Remember to normalise.)
]

#exercise[
  Verify Clairaut's theorem for $f(x,y) = x^2 e^(x y)$ by computing both mixed
  partials.
]

#exercise[
  Find and classify all critical points of $f(x,y) = x^3 - 3x + y^2$, using the
  Hessian.
]

#exercise[
  Use the chain rule to find $(dif z) slash (dif t)$ where
  $z = x^2 y$, $x = cos t$, $y = sin t$. Then verify by substituting first and
  differentiating directly.
]

#exercise[
  Use Lagrange multipliers to find the point on the plane
  $2x + 3y + z = 12$ closest to the origin. (Minimise the squared distance,
  not the distance --- and say why that is legitimate.)
]

#exercise[
  Evaluate $integral_0^1 integral_0^2 (x + y^2) dif x dif y$, then swap the
  order and confirm you get the same answer.
]

#exercise[
  Use polar coordinates to evaluate $integral.double_R (x^2 + y^2) dif A$
  where $R$ is the unit disc.
]

#exercise[
  A network computes $L = f(W_2 sigma(W_1 x))$ with $x in RR^n$,
  $W_1 in RR^(h times n)$, $W_2 in RR^(1 times h)$. Write the chain rule for
  $partial L slash partial W_1$ as a product of Jacobians, and state the
  dimensions of each factor. Then say which multiplication order is cheaper
  and by how much.
]
