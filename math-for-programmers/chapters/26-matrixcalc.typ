#import "../lib.typ": *

= Matrix Calculus

== The notation ML papers are written in

Chapter 18 established that the derivative of a multivariable function is a
gradient or a Jacobian. In practice you rarely compute those entry by entry;
you manipulate whole matrices, using a small set of identities.

This chapter is that toolkit. It is short, it is mostly a table, and having it
is the difference between reading a paper and staring at one.

#warning(title: "layout conventions differ, and they will confuse you")[
  There are two conventions for arranging the derivative of a vector with
  respect to a vector.

  *Numerator layout* (Jacobian layout): $partial y slash partial x$ has shape
  (size of $y$) $times$ (size of $x$). The derivative of a scalar with respect
  to a column vector is a *row* vector.

  *Denominator layout* (gradient layout): the transpose of that. The gradient
  of a scalar is a *column* vector.

  Neither is standard. Papers switch between them, sometimes within a section.

  *This book uses denominator layout*, so that $nabla f$ is a column vector
  and shapes line up naturally in optimisation. When you read anything else,
  the reliable defence is not to memorise the convention but to *check the
  dimensions* --- there is generally only one arrangement that type-checks.
]

== The building blocks

Throughout, $x in RR^n$ is a column vector, $a in RR^n$ a constant vector,
$A in RR^(n times n)$ a constant matrix.

#theorem(title: "the essential gradients")[
  $
  nabla_x (a^T x) &= a \
  nabla_x (x^T A x) &= (A + A^T) x, quad "and" = 2 A x "if" A "is symmetric" \
  nabla_x norm(x)^2 &= 2 x \
  nabla_x norm(A x - b)^2 &= 2 A^T (A x - b)
  $
]

#proof[
  *First.* $a^T x = sum_i a_i x_i$, so
  $partial slash partial x_j = a_j$. Stacking gives $a$.

  *Second.* $x^T A x = sum_i sum_j A_(i j) x_i x_j$. Differentiate with
  respect to $x_k$; the terms involving $x_k$ are those with $i = k$ (giving
  $sum_j A_(k j) x_j$), those with $j = k$ (giving $sum_i A_(i k) x_i$), and
  the diagonal term $A_(k k) x_k^2$ (whose derivative $2 A_(k k) x_k$ is
  exactly what the first two contribute at $i = j = k$, so no double count).
  So
  $ (partial)/(partial x_k) x^T A x = sum_j A_(k j) x_j + sum_i A_(i k) x_i = (A x)_k + (A^T x)_k. $

  *Third.* Special case of the second with $A = I$.

  *Fourth.* Expand $norm(A x - b)^2 = x^T A^T A x - 2 b^T A x + b^T b$. The
  first term uses the second identity with the symmetric matrix $A^T A$,
  giving $2 A^T A x$; the second uses the first identity with
  $a = A^T b$, giving $-2 A^T b$. Adding: $2 A^T (A x - b)$.
]

#intuition(title: "the analogy that actually works")[
  Compare to single-variable calculus:
  $
  a^T x quad &tilde.op quad a x quad &&arrow.r.double quad "derivative " a \
  x^T A x quad &tilde.op quad a x^2 quad &&arrow.r.double quad "derivative " 2 a x \
  norm(A x - b)^2 quad &tilde.op quad (a x - b)^2 quad &&arrow.r.double quad "derivative " 2a(a x - b)
  $
  The pattern is the same; the only new content is *where the transposes go*,
  and the transposes are forced by dimensional consistency. If a formula
  type-checks and reduces to the scalar case when $n = 1$, it is almost
  certainly right.
]

#theorem(title: "traces and determinants")[
  $
  (partial)/(partial A) tr(A B) &= B^T \
  (partial)/(partial A) tr(A^T B) &= B \
  (partial)/(partial A) tr(A^T A) &= 2 A \
  (partial)/(partial A) log det A &= (A^(-1))^T = (A^T)^(-1) \
  (partial)/(partial A) det A &= det(A) (A^(-1))^T
  $
]

#proof[
  *First.* $tr(A B) = sum_i sum_j A_(i j) B_(j i)$, so the derivative with
  respect to $A_(i j)$ is $B_(j i) = (B^T)_(i j)$.

  *Last two.* By cofactor expansion (Chapter 22) along row $i$,
  $det A = sum_j A_(i j) C_(i j)$ where the cofactors $C_(i j)$ do not involve
  row $i$. Hence $partial det A slash partial A_(i j) = C_(i j)$. The adjugate
  formula $A^(-1) = "adj"(A) slash det A$ with $"adj"(A)_(j i) = C_(i j)$ then
  gives $partial det A slash partial A = det(A)(A^(-1))^T$. Dividing by
  $det A$ gives the log version.
]

The $log det$ derivative is not exotic: it appears every time you fit a
Gaussian (the log-likelihood contains $-log det Sigma$), and in every
normalising-flow model.

== The chain rule in matrix form

The rule from Chapter 18, restated for practical use. If $y = f(u)$ and
$u = g(x)$, then in denominator layout
$ (partial y)/(partial x) = ((partial u)/(partial x))^T (partial y)/(partial u) ... $
--- and this is exactly where the layout confusion bites hardest. The reliable
method is different, and it is worth adopting permanently.

#intuition(title: "differentials: the technique that never gets the shapes wrong")[
  Instead of manipulating derivative arrays, manipulate *differentials* and
  read the derivative off at the end.

  The rules are the ones you already know, applied to matrices:
  $
  dif(A + B) &= dif A + dif B \
  dif(A B) &= (dif A) B + A (dif B) quad "(order matters!)" \
  dif(A^T) &= (dif A)^T \
  dif(A^(-1)) &= -A^(-1) (dif A) A^(-1) \
  dif thin tr(A) &= tr(dif A) \
  dif thin log det A &= tr(A^(-1) dif A)
  $

  Then use the *identification rule*: for a scalar $f$,
  $ dif f = tr(G^T dif A) quad arrow.r.double quad (partial f)/(partial A) = G. $
  Manipulate with the trace's cyclic property (Chapter 20) until the
  differential is isolated on the right, and whatever multiplies it is the
  derivative.

  Once you work this way, the layout question disappears: you never write a
  Jacobian, you just push differentials around and read off the answer at the
  end.
]

#example(title: "least squares, by differentials")[
  $f(x) = norm(A x - b)^2 = (A x - b)^T (A x - b)$.

  $
  dif f &= (A dif x)^T (A x - b) + (A x - b)^T (A dif x) \
        &= 2 (A x - b)^T A dif x quad "(both terms are equal scalars)" \
        &= tr( (2 A^T (A x - b))^T dif x ).
  $
  By the identification rule, $nabla f = 2 A^T (A x - b)$. Setting it to zero
  gives the normal equations of Chapter 24 in three lines.
]

#example(title: "the derivative of the inverse")[
  Differentiate $A A^(-1) = I$. The right side is constant, so
  $ (dif A) A^(-1) + A thin dif(A^(-1)) = 0, $
  hence $dif(A^(-1)) = -A^(-1)(dif A) A^(-1)$.

  Compare the scalar $dif(1 slash a) = -(1 slash a^2) dif a$. Same shape; the
  matrix version just cannot commute the factors, so the perturbation sits in
  the middle.
]

== The three derivatives you need for neural networks

Everything in Chapter 36 rests on these.

#proposition(title: "a linear layer")[
  Let $y = W x + b$ with $W in RR^(m times n)$. If $L$ is a scalar loss and
  $g = partial L slash partial y in RR^m$ is known, then
  $ (partial L)/(partial x) = W^T g, quad (partial L)/(partial W) = g x^T, quad (partial L)/(partial b) = g. $
]

#proof[
  $dif y = (dif W) x + W dif x + dif b$, and
  $dif L = g^T dif y = g^T (dif W) x + g^T W dif x + g^T dif b$.

  Reading off the $dif x$ term: $partial L slash partial x = W^T g$.

  For $dif W$: $g^T (dif W) x = tr(g^T (dif W) x) = tr(x g^T dif W)$ by
  cyclicity, which is $tr((g x^T)^T dif W)$. So
  $partial L slash partial W = g x^T$.
]

#intuition(title: "read the shapes and you can reconstruct these")[
  You do not need to memorise these. Reconstruct them from shapes.

  $partial L slash partial W$ must be $m times n$, same as $W$. You have
  $g in RR^m$ and $x in RR^n$ available. The only way to combine them into an
  $m times n$ matrix is $g x^T$. Done.

  $partial L slash partial x$ must be $n times 1$. You have $W$ ($m times n$)
  and $g$ ($m times 1$). The only product that works is $W^T g$. Done.

  This shape-matching heuristic is remarkably reliable in matrix calculus,
  because there are usually only one or two dimensionally valid arrangements
  and the correct one is among them. It is not a proof, but it will get you
  through a paper.
]

#proposition(title: "an elementwise nonlinearity")[
  Let $y = phi(x)$ applied elementwise. Then the Jacobian is diagonal, and
  $ (partial L)/(partial x) = phi'(x) circle.small (partial L)/(partial y), $
  where $circle.small$ is the elementwise (Hadamard) product.
]

#proof[
  $y_i$ depends only on $x_i$, so $partial y_i slash partial x_j = 0$ for
  $i != j$ and $phi'(x_i)$ for $i = j$. Multiplying by a diagonal matrix is
  elementwise scaling.
]

That is why activation functions are cheap in the backward pass: the Jacobian
is diagonal, so you never form it --- you just multiply elementwise.

#proposition(title: "softmax and cross-entropy")[
  Let $p = softmax(z)$ and $L = -sum_i y_i log p_i$ for a one-hot target $y$.
  Then
  $ (partial L)/(partial z) = p - y. $
]

#proof[
  First the Jacobian of softmax. With $p_i = e^(z_i) slash S$,
  $S = sum_k e^(z_k)$:
  $ (partial p_i)/(partial z_j) = cases(p_i (1 - p_i) quad &i = j, -p_i p_j &i != j) quad = quad p_i (delta_(i j) - p_j). $

  Now the loss. $L = -sum_i y_i log p_i$, so
  $ (partial L)/(partial z_j) = -sum_i (y_i)/(p_i) (partial p_i)/(partial z_j) = -sum_i (y_i)/(p_i) p_i (delta_(i j) - p_j) = -sum_i y_i (delta_(i j) - p_j). $
  Expanding: $-y_j + p_j sum_i y_i = p_j - y_j$, using $sum_i y_i = 1$.
]

#intuition(title: "why $p - y$ is such a nice gradient")[
  The gradient of the loss with respect to the logits is *predicted minus
  actual*. Nothing could be simpler, and there is no division by anything that
  might be near zero.

  Note what did *not* happen: the $1 slash p_i$ from the log's derivative was
  cancelled exactly by the $p_i$ from the softmax's derivative. That
  cancellation is why softmax and cross-entropy are always implemented as a
  *single fused operation*. Computing them separately means computing a
  logarithm, then a division, and losing precision to a cancellation that
  should never have been performed.

  This is also why the same $p - y$ appears in logistic regression and in
  linear regression with squared loss. It is not a coincidence: all three are
  generalised linear models whose loss is the negative log-likelihood of an
  exponential-family distribution, and for that whole family the gradient is
  always "prediction minus observation" (Chapter 31).
]

== A reference table

#align(center)[
  #table(
    columns: 2,
    inset: 7pt,
    align: (left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Expression*], [*Derivative*]),
    [$a^T x$], [$a$],
    [$x^T a$], [$a$],
    [$x^T x$], [$2x$],
    [$x^T A x$], [$(A + A^T)x$; $2 A x$ if symmetric],
    [$a^T A b$ w.r.t. $A$], [$a b^T$],
    [$norm(A x - b)^2$], [$2 A^T (A x - b)$],
    [$tr(A B)$ w.r.t. $A$], [$B^T$],
    [$tr(A^T B)$ w.r.t. $A$], [$B$],
    [$log det A$ w.r.t. $A$], [$(A^(-1))^T$],
    [$A^(-1)$ (differential)], [$-A^(-1) (dif A) A^(-1)$],
    [$W x + b$ w.r.t. $W$], [$g x^T$ (with upstream $g$)],
    [$phi(x)$ elementwise], [$phi'(x) circle.small g$],
    [softmax + cross-entropy], [$p - y$],
  )
]

== Exercises

#exercise[
  Compute $nabla_x (x^T A x)$ for $A = mat(1,2;3,4)$ and $x = (x_1, x_2)^T$
  by expanding the quadratic form fully and differentiating entry by entry.
  Check your answer against $(A + A^T)x$.
]

#exercise[
  Use differentials to derive $nabla_x norm(x)$ (not the square) for
  $x != 0$. What goes wrong at $x = 0$, and what is the standard fix in
  optimisation code?
]

#exercise[
  Show that $nabla_x (x^T A y) = A y$ and $nabla_y (x^T A y) = A^T x$.
]

#exercise[
  Derive the gradient of ridge regression,
  $L(x) = norm(A x - b)^2 + lambda norm(x)^2$, and solve
  $nabla L = 0$ for $x$. Explain what the $lambda I$ term does to the
  conditioning of the system.
]

#exercise[
  Use the differential rules to show that
  $dif thin log det A = tr(A^(-1) dif A)$, starting from
  $dif det A = det(A) tr(A^(-1) dif A)$.
]

#exercise[
  For a two-layer network $y = W_2 phi(W_1 x)$ with scalar loss $L$, write out
  $partial L slash partial W_1$ and $partial L slash partial W_2$ in terms of
  $g = partial L slash partial y$, using the three propositions of this
  chapter. State the shape of each factor.
]

#exercise[
  Verify the softmax Jacobian formula $partial p_i slash partial z_j = p_i(delta_(i j) - p_j)$
  directly for the case $n = 2$, by writing out $p_1$ and $p_2$ explicitly and
  differentiating.
]

#exercise[
  Show that the softmax Jacobian is symmetric and positive semidefinite, and
  that it is singular. What vector is in its null space, and what does that
  say about the parameterisation?
]
