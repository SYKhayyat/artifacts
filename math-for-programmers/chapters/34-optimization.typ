#import "../lib.typ": *

= Optimization

== The shape of the problem

$ min_(x in RR^n) f(x) quad "subject to" quad g_i (x) <= 0, quad h_j (x) = 0. $

Training a model, fitting a curve, allocating resources, planning a route,
scheduling jobs --- all of it is this. What determines whether the problem is
easy or hopeless is not the size of $n$; it is *convexity*.

== Convexity

#definition(title: "convex set and convex function")[
  A set $C$ is *convex* if for all $x,y in C$ and $t in [0,1]$,
  $t x + (1-t) y in C$: the segment between any two points stays inside.

  A function $f$ on a convex set is *convex* if
  $ f(t x + (1-t) y) <= t f(x) + (1-t) f(y), $
  i.e. the chord lies above the graph. *Strictly* convex if the inequality is
  strict for $x != y$.
]

#theorem(title: "characterisations of convexity")[
  For differentiable $f$, convexity is equivalent to
  $ f(y) >= f(x) + nabla f(x)^T (y - x) quad "for all" x, y, $
  and for twice-differentiable $f$, to the Hessian $H(x)$ being positive
  semidefinite everywhere.
]

The first-order form says the tangent plane lies *below* the function
everywhere --- so a local linear model never overpromises. The second-order
form is the $n$-dimensional version of $f'' >= 0$.

#theorem(title: "the reason convexity matters")[
  For a convex $f$ on a convex set:
  #set enum(numbering: "(a)")
  + Every local minimum is a global minimum.
  + The set of minimisers is convex.
  + If $f$ is strictly convex, the minimiser is unique.
  + $nabla f(x) = 0$ is *sufficient*, not merely necessary, for a global
    minimum.
]

#proof[
  *(a)* Suppose $x$ is a local minimum and $f(y) < f(x)$ for some $y$. For
  small $t > 0$,
  $ f(x + t(y - x)) <= (1-t) f(x) + t f(y) < f(x), $
  giving points arbitrarily close to $x$ with smaller value --- contradicting
  local minimality.

  *(d)* If $nabla f(x) = 0$ then the first-order condition reads
  $f(y) >= f(x)$ for every $y$.
]

#intuition(title: "convex versus non-convex is the real dividing line")[
  *Convex problems are solved.* Not "solvable in principle" --- solved.
  Interior-point methods find the global optimum of a convex problem to high
  accuracy in polynomial time, reliably, with certificates of optimality. If
  you can formulate your problem as convex, you are done; pick a solver.

  *Non-convex problems are, in general, hopeless.* Finding the global minimum
  of a general non-convex function is NP-hard. You get local minima, you get
  no guarantees, and you get heuristics.

  So the single most valuable skill in applied optimisation is *recognising or
  reformulating a problem as convex*. Sometimes a change of variables does it;
  sometimes a relaxation (replace rank with nuclear norm, replace
  count-of-nonzeros with $ell_1$) gives a convex problem whose solution is
  good enough.

  Deep learning is spectacularly non-convex and works anyway, which is a
  genuine puzzle rather than a counterexample. The current partial explanation
  involves the saddle-point picture of Chapter 18: in very high dimensions,
  bad local minima are rare, most critical points are saddles, and the many
  global-ish minima that exist are of similar quality.
]

Convexity-preserving operations, worth knowing so you can check quickly:
nonnegative combinations of convex functions; pointwise maximum; composition
with an affine map; and $f(A x + b)$ whenever $f$ is convex. Norms are convex.
$-log$ is convex. Squared error is convex. Cross-entropy in the *logits of a
linear model* is convex; in the weights of a deep network it is not, and that
is where the difficulty enters.

== Gradient descent

#algo(title: "Gradient descent")[
```
x := x0
repeat:
    x := x - eta * grad_f(x)
until converged
```
]

The direction is justified by Chapter 18: $-nabla f$ is the direction of
steepest decrease. The step size $eta$ (the *learning rate*) is the entire
difficulty.

#theorem(title: "convergence for smooth convex functions")[
  If $f$ is convex with $L$-Lipschitz gradient, and $eta <= 1 slash L$, then
  $ f(x_k) - f^* <= (norm(x_0 - x^*)^2)/(2 eta k). $
  So $O(1 slash epsilon)$ iterations for accuracy $epsilon$.

  If additionally $f$ is $mu$-strongly convex, convergence is *linear*:
  $ f(x_k) - f^* <= (1 - mu/L)^k (f(x_0) - f^*), $
  needing only $O(kappa log(1 slash epsilon))$ iterations, where
  $kappa = L slash mu$.
]

#intuition(title: "the condition number is the learning rate problem")[
  Read those two rates. Everything depends on $kappa = L slash mu$, the ratio
  of the largest to the smallest curvature --- which for a quadratic is
  exactly the condition number of the Hessian (Chapter 25).

  Geometrically: the level sets are ellipsoids with axis ratio $sqrt(kappa)$.
  If $kappa = 1$ they are spheres, the gradient points straight at the
  minimum, and one step of the right size finishes.

  If $kappa$ is large they are long thin valleys. The gradient points mostly
  *across* the valley, not along it. You are forced to use a small step size
  to avoid overshooting the narrow direction, and then you crawl along the
  long direction. The result is the characteristic zigzag.

  This single picture explains most practical optimisation advice:

  - *Feature scaling* reduces $kappa$, which is why normalising inputs
    accelerates training so dramatically. It is not a superstition; it is
    conditioning.
  - *Batch normalisation and layer normalisation* keep the effective
    conditioning under control during training.
  - *Momentum* damps the oscillation across the valley while accumulating
    speed along it, improving the rate from $kappa$ to $sqrt(kappa)$.
  - *Adam* and its relatives estimate a per-coordinate scale, which is a
    diagonal approximation to preconditioning --- an attempt to make the
    problem look better-conditioned without computing a Hessian.
  - *Newton's method* uses the exact Hessian and is therefore invariant to
    conditioning altogether. That is why it converges so fast, and why it
    costs so much.
]

#definition(title: "momentum and Nesterov acceleration")[
  $
  v_(k+1) &= beta v_k + nabla f(x_k), &quad x_(k+1) &= x_k - eta v_(k+1) quad "(heavy ball)" \
  v_(k+1) &= beta v_k + nabla f(x_k - eta beta v_k), &quad x_(k+1) &= x_k - eta v_(k+1) quad "(Nesterov)"
  $
]

Nesterov's version evaluates the gradient at the *look-ahead* point, and that
small change is enough to achieve the optimal $O(1 slash k^2)$ rate for smooth
convex functions --- provably the best possible for any method using only
gradients. The physical reading of momentum: a heavy ball rolling downhill
does not reverse direction every time the slope wobbles.

== Stochastic gradient descent

For $f(x) = (1 slash n) sum_(i=1)^n f_i (x)$ with $n$ enormous, computing the
full gradient costs $O(n)$ per step. SGD uses a random subset:

#algo(title: "Minibatch SGD")[
```
repeat:
    sample a minibatch B of indices
    g := (1/|B|) * sum over i in B of grad f_i(x)
    x := x - eta_k * g
```
]

$g$ is an *unbiased* estimate of the true gradient: $EE[g] = nabla f(x)$. The
noise does not bias the direction, only adds variance.

#theorem(title: "SGD convergence")[
  With a decreasing step size satisfying
  $sum_k eta_k = infinity$ and $sum_k eta_k^2 < infinity$ (for instance
  $eta_k = c slash k$), SGD converges to the optimum for convex $f$, at rate
  $O(1 slash sqrt(k))$.
]

The two conditions have clean readings: $sum eta_k = infinity$ means the steps
must total enough distance to reach the optimum from anywhere;
$sum eta_k^2 < infinity$ means the accumulated noise must be finite so you can
settle.

#intuition(title: "why noisy gradients are not just tolerable but useful")[
  The obvious framing is that SGD trades accuracy for speed: $n$ times cheaper
  per step, more steps needed. For large $n$ that trade is overwhelmingly
  favourable, and that alone justifies it.

  But the noise does more:

  - It escapes saddle points. A deterministic method can stall exactly at a
    saddle; noise knocks you off.
  - It is implicitly regularising. SGD tends to find flatter minima, which
    generalise better --- a sharp minimum is one where the noise cannot settle.
  - It is why the learning rate *schedule* matters so much. A large rate early
    explores; decaying it later lets you settle into the basin you found.
    Warmup, cosine decay, and cyclic schedules are all engineering around this
    exploration/exploitation trade.
]

== Second-order methods

#definition(title: "Newton's method for optimisation")[
  $ x_(k+1) = x_k - H(x_k)^(-1) nabla f(x_k). $
]

Derived by minimising the second-order Taylor model
$f(x) + nabla f^T d + (1 slash 2) d^T H d$ over the step $d$: differentiate
and set to zero, giving $H d = -nabla f$.

Quadratically convergent near the optimum and *affine invariant* --- rescaling
the variables does not change its trajectory at all, so conditioning is
irrelevant to it. In exchange: computing $H$ is $O(n^2)$ entries, solving with
it is $O(n^3)$, and $H$ may not be positive definite away from a minimum, in
which case the Newton step can point uphill.

#definition(title: "quasi-Newton and the practical alternatives")[
  - *BFGS:* build an approximation to $H^(-1)$ from successive gradients. No
    Hessian required, superlinear convergence, $O(n^2)$ memory.
  - *L-BFGS:* store only the last $m approx 10$ gradient pairs and reconstruct
    the action of $H^(-1)$ implicitly. $O(m n)$ memory. The standard choice for
    smooth medium-scale problems.
  - *Gauss--Newton and Levenberg--Marquardt:* for least-squares objectives,
    approximate $H approx 2 J^T J$ using only first derivatives.
    Levenberg--Marquardt adds a damping term $lambda I$ that interpolates
    between Gauss--Newton (fast, when the model is good) and gradient descent
    (safe, when it is not).
  - *Adam:* a diagonal approximation to preconditioning, using running
    estimates of the first and second moments of the gradient. Cheap, robust,
    and the default in deep learning --- where the true Hessian has $10^12$
    entries and is out of the question.
]

== Constrained optimization

#definition(title: "the Lagrangian")[
  For $min f(x)$ subject to $g_i (x) <= 0$ and $h_j (x) = 0$:
  $ cal(L)(x, lambda, nu) = f(x) + sum_i lambda_i g_i (x) + sum_j nu_j h_j (x), quad lambda_i >= 0. $
]

#theorem(title: "Karush--Kuhn--Tucker conditions")[
  Under mild regularity, $x^*$ is optimal only if there exist
  $lambda^*, nu^*$ with:
  #set enum(numbering: "(K1)")
  + $nabla_x cal(L) = 0$ #h(1fr) (stationarity)
  + $g_i (x^*) <= 0$, $h_j (x^*) = 0$ #h(1fr) (primal feasibility)
  + $lambda_i^* >= 0$ #h(1fr) (dual feasibility)
  + $lambda_i^* g_i (x^*) = 0$ for every $i$ #h(1fr) (complementary slackness)

  For a convex problem these conditions are also *sufficient*.
]

#intuition(title: "complementary slackness is the interesting one")[
  (K4) says: for each inequality constraint, either it is *active*
  ($g_i = 0$, you are pressed against the boundary) or its multiplier is zero
  (the constraint is irrelevant and could be deleted). Never both nonzero.

  This is exactly the "shadow price" reading from Chapter 18. A constraint you
  are not touching has zero value; a constraint you are pressed against has a
  price equal to how much the objective would improve if you relaxed it by one
  unit.

  In a support vector machine, the constraints are one per training point and
  the active ones are precisely the *support vectors*. Every other point has
  $lambda_i = 0$ and could be deleted from the dataset without changing the
  solution at all. That fact --- which is what makes SVMs sparse in the data
  --- is complementary slackness and nothing else.
]

#definition(title: "duality")[
  The *dual function* is $ d(lambda,nu) = inf_x cal(L)(x,lambda,nu), $ and the
  *dual problem* is to maximise it subject to $lambda >= 0$.
]

*Weak duality* always holds: $d(lambda,nu) <= f(x^*)$ for any feasible dual
point. So any dual point certifies a lower bound on the optimum --- which is
how solvers prove optimality and how branch-and-bound prunes. *Strong duality*
--- equality --- holds for convex problems under Slater's condition (a
strictly feasible point exists).

The dual is often easier: it may have fewer variables, or nicer constraints.
The kernel trick in SVMs works because the dual involves the data only through
inner products $x_i^T x_j$, which can then be replaced by a kernel.

== Regularisation

#definition[
  $ min_x f(x) + lambda R(x). $
  - $R = norm(x)_2^2$: *ridge*. Shrinks coefficients smoothly, keeps all of
    them, improves conditioning (it adds $lambda I$ to the Hessian).
  - $R = norm(x)_1$: *lasso*. Produces exact zeros --- sparsity --- for the
    geometric reason given in Chapter 19.
  - $R = norm(x)_*$ (nuclear norm): low rank, the convex relaxation of rank.
]

Chapter 31 gave the other reading: regularisation is a prior, and $lambda$ is
the inverse prior variance. Ridge is a Gaussian prior; lasso is Laplace.

#example(title: "ridge regression, three ways")[
  $ min_x norm(A x - b)^2 + lambda norm(x)^2. $

  *By calculus* (Chapter 26): the gradient is $2A^T(A x - b) + 2 lambda x$,
  so $(A^T A + lambda I) x = A^T b$.

  *By conditioning:* adding $lambda I$ shifts every eigenvalue of $A^T A$ up
  by $lambda$, so the condition number falls from
  $sigma_1^2 slash sigma_n^2$ to
  $(sigma_1^2 + lambda) slash (sigma_n^2 + lambda)$. A singular problem
  becomes solvable.

  *By SVD* (Chapter 25): the solution filters the singular values,
  $1 slash sigma_i arrow.bar sigma_i slash (sigma_i^2 + lambda)$. Directions
  with large $sigma_i$ are barely touched; directions where the data carries
  almost no information are suppressed rather than amplified.

  Three derivations, one answer, and each explains a different aspect of *why*
  it works. That is what it looks like when you actually understand something.
]

== Exercises

#exercise[
  Prove that $f(x) = x^4$ is convex on $RR$ but not strongly convex, and
  identify where the strong convexity fails.
]

#exercise[
  Show that the maximum of two convex functions is convex, but the minimum
  need not be. Give a counterexample for the minimum.
]

#exercise[
  For $f(x,y) = x^2 + 10 y^2$, compute the Hessian, its condition number, and
  the largest stable learning rate for gradient descent. Then trace two
  iterations from $(1,1)$ with $eta$ half that maximum and observe the zigzag.
]

#exercise[
  Show that gradient descent on a quadratic $f(x) = (1 slash 2) x^T A x$ with
  $A$ symmetric positive definite converges iff $0 < eta < 2 slash lambda_max$.
  (Write the iteration in the eigenbasis.)
]

#exercise[
  Use Lagrange multipliers with the KKT conditions to solve
  $min x^2 + y^2$ subject to $x + y >= 2$. Identify whether the constraint is
  active and state the multiplier's value.
]

#exercise[
  Derive the Newton step for minimising $f(x) = e^x - 2x$ and carry out two
  iterations from $x_0 = 0$. Compare with two gradient descent steps at
  $eta = 0.5$.
]

#exercise[
  Show that adding $lambda norm(x)^2$ to a least-squares objective changes the
  singular values of the effective solution operator from $1 slash sigma_i$ to
  $sigma_i slash (sigma_i^2 + lambda)$, and explain what happens to the
  directions with $sigma_i approx 0$.
]

#exercise[
  You are minimising a function of 10 million parameters. Explain in a short
  paragraph why Newton's method is not an option, why L-BFGS is marginal, and
  what Adam is actually approximating.
]
