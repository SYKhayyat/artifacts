#import "../lib.typ": *

= Backpropagation, Derived

== Everything, in one place

This chapter builds a neural network and derives its training algorithm from
first principles. Every ingredient has already appeared:

- the chain rule (Chapter 14) and its matrix form (Chapter 18);
- matrix multiplication as composition (Chapter 20);
- the matrix calculus identities (Chapter 26);
- cross-entropy from information theory (Chapter 32);
- gradient descent and conditioning (Chapter 34);
- floating-point behaviour (Chapter 33).

Nothing new is required. That is the point of the chapter: what looks like a
separate subject is an assembly of things you now know.

== The model

#definition(title: "a feedforward network")[
  With input $a^((0)) = x$, for $ell = 1, dots, L$:
  $
  z^((ell)) &= W^((ell)) a^((ell-1)) + b^((ell)) quad &&"(affine)" \
  a^((ell)) &= phi(z^((ell))) quad &&"(elementwise nonlinearity)"
  $
  and a scalar loss $cal(L) = "loss"(a^((L)), y)$.
]

#intuition(title: "why the nonlinearity is not optional")[
  Compose two affine maps:
  $ W_2 (W_1 x + b_1) + b_2 = (W_2 W_1) x + (W_2 b_1 + b_2), $
  which is one affine map. By induction, a network of $L$ affine layers with
  no nonlinearity is *exactly* a single affine layer --- the depth buys
  literally nothing, and every extra parameter is wasted.

  That is Chapter 20: the composition of linear maps is a linear map, and the
  set of matrices is closed under multiplication.

  The elementwise $phi$ is what breaks the closure. It is the only source of
  expressive power in the architecture, and the universal approximation
  theorem says that one hidden layer with a non-polynomial $phi$ and enough
  width can approximate any continuous function on a compact set to any
  accuracy.

  (That theorem is much less useful than it sounds --- it says nothing about
  how *wide*, or whether gradient descent will find the weights. Depth wins in
  practice for reasons the theorem does not address.)
]

#definition(title: "the usual activations")[
  $
  "ReLU"(z) &= max(0,z), &quad phi'(z) &= cases(1 quad &z>0, 0 &z<0) \
  sigma(z) &= 1/(1+e^(-z)), &quad phi'(z) &= sigma(z)(1-sigma(z)) \
  tanh(z) &= (e^(2z)-1)/(e^(2z)+1), &quad phi'(z) &= 1 - tanh^2 (z) \
  "GELU"(z) &= z Phi(z), && quad Phi "the normal CDF"
  $
]

ReLU's derivative at exactly $0$ does not exist (Chapter 14: it is a corner).
Frameworks pick $0$ by convention. This is a *subgradient* choice, it is
harmless in practice, and it is worth knowing that it is a choice rather than
a derivative.

== Forward and backward

#theorem(title: "backpropagation")[
  Define $delta^((ell)) = partial cal(L) slash partial z^((ell))$. Then
  $
  delta^((L)) &= nabla_(a^((L))) cal(L) circle.small phi'(z^((L))) \
  delta^((ell)) &= (W^((ell+1)))^T delta^((ell+1)) circle.small phi'(z^((ell))) \
  (partial cal(L))/(partial W^((ell))) &= delta^((ell)) (a^((ell-1)))^T \
  (partial cal(L))/(partial b^((ell))) &= delta^((ell))
  $
  where $circle.small$ is the elementwise product.
]

#proof[
  The last two lines are Chapter 26's linear-layer proposition applied with
  upstream gradient $delta^((ell))$.

  For the recursion, apply the chain rule through the path
  $z^((ell)) -> a^((ell)) -> z^((ell+1))$:
  $ (partial cal(L))/(partial z^((ell))) = ((partial a^((ell)))/(partial z^((ell))))^T ((partial z^((ell+1)))/(partial a^((ell))))^T (partial cal(L))/(partial z^((ell+1))). $

  The second Jacobian is $W^((ell+1))$, so its transpose is
  $(W^((ell+1)))^T$. The first is diagonal with entries $phi'(z^((ell)))$
  (Chapter 26), and multiplying by a diagonal matrix is an elementwise
  product. Composing gives the stated recursion.

  The base case is the same computation at the output layer, where the
  upstream gradient is the loss gradient directly.
]

#algo(title: "One training step")[
```
# forward
a[0] := x
for l = 1..L:
    z[l] := W[l] @ a[l-1] + b[l]
    a[l] := phi(z[l])
loss := loss_fn(a[L], y)

# backward
d := grad_loss(a[L], y) * phi_prime(z[L])
for l = L..1:
    gradW[l] := outer(d, a[l-1])
    gradb[l] := d
    if l > 1:
        d := (W[l].T @ d) * phi_prime(z[l-1])

# update
for l = 1..L:
    W[l] -= eta * gradW[l]
    b[l] -= eta * gradb[l]
```
]

#intuition(title: "why this is efficient, stated precisely")[
  There are $P$ parameters and one scalar loss.

  *Finite differences* would need $P + 1$ forward passes --- perturb each
  parameter, recompute. For $P = 10^9$ that is impossible, and each estimate
  would carry the numerical error of Chapter 14.

  *Forward-mode autodiff* propagates derivatives forwards alongside the
  values. Each pass gives the derivative with respect to *one* input
  direction, so you again need $P$ passes. Forward mode is the right choice
  when there are few inputs and many outputs.

  *Reverse mode* --- backpropagation --- propagates derivatives backwards from
  the single scalar output, and gets the gradient with respect to *all* $P$
  parameters in one backward pass costing about the same as one forward pass.

  The reason is the associativity observed in Chapter 18. The gradient is a
  product of Jacobians; the leftmost factor is a $1 times n$ row vector
  because the loss is a scalar; so multiplying left to right keeps every
  intermediate a *vector*, and every operation is a matrix--vector product
  rather than matrix--matrix.

  One scalar output, many inputs: reverse mode. That is the entire argument,
  and it is a statement about associativity of matrix multiplication.

  The cost is *memory*: the backward pass needs every $a^((ell))$ from the
  forward pass, so activation memory scales with depth times batch size. That
  is what gradient checkpointing trades against --- recompute some activations
  instead of storing them, spending time to save memory.
]

== The gradient pathologies

#warning(title: "vanishing and exploding gradients, quantified")[
  Unroll the recursion:
  $ delta^((1)) = ( product_(ell=2)^L (W^((ell)))^T D^((ell-1)) ) delta^((L)), quad D^((ell)) = diag(phi'(z^((ell)))). $

  The gradient at layer 1 is a *product of $L-1$ matrices*. Taking norms, its
  magnitude scales roughly as $product_ell norm(W^((ell))) norm(D^((ell)))$.

  If those factors average below 1, the product decays exponentially in $L$:
  early layers receive essentially no gradient and never learn. If above 1, it
  grows exponentially and training diverges to NaN.

  It is Chapter 14's "gains multiply along a chain", with $L = 100$ factors.

  For sigmoid, $max phi' = 0.25$, so even with perfectly scaled weights the
  gradient shrinks by at least $4^(-L)$. That is why deep sigmoid networks
  were untrainable, and why the field stalled for two decades on exactly this
  fact.

  The fixes, each attacking one factor of the product:

  - *ReLU:* $phi' = 1$ on the active half, so $D$ contributes no shrinkage.
  - *Careful initialisation:* He/Xavier scaling chooses
    $Var(W_(i j)) approx 2 slash n_"in"$ precisely so that
    $norm(W^((ell)))$ is near 1 and the product neither grows nor decays.
  - *Residual connections:* $a^((ell)) = a^((ell-1)) + F(a^((ell-1)))$ makes
    the layer Jacobian $I + partial F$, so the product is
    $product (I + partial F_ell)$ --- close to the identity, with a gradient
    path that reaches every layer without attenuation. This is the single
    change that made hundred-layer networks trainable.
  - *Normalisation layers:* keep the scale of activations, and hence of the
    Jacobians, under control at every depth.
  - *Gradient clipping:* rescale the gradient when its norm exceeds a
    threshold. A blunt instrument, and effective against the exploding
    direction.
]

== Automatic differentiation as a general technique

Backpropagation is a special case. The general framework is worth
understanding because it is what your framework implements.

#definition(title: "computation graph")[
  A DAG (Chapter 10) whose nodes are variables and whose edges are primitive
  operations. Each primitive knows its own local derivative.
]

#definition(title: "the two modes")[
  *Forward mode:* propagate $dot(v) = partial v slash partial x$ forwards
  from the inputs. Implementable with *dual numbers*: carry pairs
  $(v, dot(v))$ with the arithmetic $ (a, dot(a)) times (b, dot(b)) = (a b, thin a dot(b) + dot(a) b), $
  which is the product rule built into the number type. One pass gives one
  column of the Jacobian.

  *Reverse mode:* run forwards recording the graph, then propagate
  $overline(v) = partial cal(L) slash partial v$ backwards from the output.
  One pass gives one row of the Jacobian --- which is the whole gradient when
  there is one output.
]

Cost: forward mode is $O(n)$ passes for $n$ inputs; reverse is $O(m)$ passes
for $m$ outputs. For neural networks $n approx 10^9$ and $m = 1$, so reverse
wins by nine orders of magnitude. For a function $RR -> RR^1000$ --- sensitivity
of many outputs to one parameter --- forward mode wins instead.

#intuition(title: "AD is neither symbolic nor numerical differentiation")[
  *Symbolic* differentiation manipulates expressions and produces a formula.
  It suffers *expression swell*: the derivative of a product of $n$ terms has
  $n$ terms, and nested products explode combinatorially.

  *Numerical* differentiation uses finite differences and loses half your
  precision to the trade-off of Chapter 14.

  *Automatic* differentiation applies the chain rule to the *execution trace*
  of the program, at the level of individual operations, evaluating
  derivatives numerically as it goes. It gives exact derivatives --- to machine
  precision, with no step size --- at a constant factor of the cost of the
  original function.

  It is one of the genuinely great ideas in scientific computing, it is much
  older than deep learning, and it is the reason modern frameworks let you
  differentiate through arbitrary code including loops and branches.
]

== The mathematics of a transformer

To close, the current dominant architecture --- entirely in terms of this
book.

#definition(title: "scaled dot-product attention")[
  Given queries $Q in RR^(n times d)$, keys $K in RR^(m times d)$, and values
  $V in RR^(m times d_v)$:
  $ "Attention"(Q,K,V) = softmax( (Q K^T)/sqrt(d) ) V. $
]

#intuition(title: "reading the formula piece by piece")[
  *$Q K^T$.* Every query dotted with every key: an $n times m$ matrix of
  similarity scores. This is Chapter 19 --- the dot product measures agreement,
  and if the vectors are normalised it is cosine similarity. Computing all
  pairs at once is a matrix multiplication, which is why attention maps onto
  GPUs so well.

  *$slash sqrt(d)$.* Suppose the entries of $q$ and $k$ are independent with
  mean 0 and variance 1. Then $q dot k = sum_(i=1)^d q_i k_i$ has variance
  $d$ (Chapter 29: variances of independent terms add), so a typical score has
  magnitude $sqrt(d)$.

  For $d = 512$ that is around 23. Feeding scores of that size into softmax
  saturates it: one entry dominates, the output is nearly one-hot, and the
  Jacobian (Chapter 26) is nearly zero --- so no gradient flows.

  Dividing by $sqrt(d)$ restores unit variance and keeps softmax in its
  responsive regime. It is a variance calculation, and it is the whole
  justification for that term.

  *$softmax$.* Chapter 4: turn scores into a probability distribution over
  positions. Each output is a convex combination of the value vectors, so
  attention outputs live in the convex hull of the values --- the same
  observation as Bézier curves in Chapter 35.

  *$dot V$.* Take the weighted average. Attention is a differentiable,
  content-addressed lookup: a soft dictionary where every key contributes in
  proportion to how well it matches.
]

#definition(title: "multi-head attention")[
  Run $h$ attention operations in parallel with separate learned projections,
  and concatenate:
  $ "MHA"(X) = [ "head"_1 ; dots.c ; "head"_h ] W^O, quad "head"_i = "Attention"(X W_i^Q, X W_i^K, X W_i^V). $
]

Each head projects into a $d slash h$-dimensional subspace (Chapter 19) and
attends within it, so different heads can specialise --- one on syntax, one on
coreference, and so on. The concatenation and $W^O$ recombine them. In
implementation it is one batched matrix multiplication, not $h$ separate ones
(Chapter 20's block matrices).

The rest of a transformer block:

- *Residual connections* $x + "sublayer"(x)$: the identity-Jacobian trick
  above, which is what allows the depth.
- *Layer normalisation*: standardise each token's activation vector to zero
  mean and unit variance, then rescale by learned parameters. Keeps the
  Jacobian norms controlled at every depth.
- *A feedforward network*: two linear layers with a nonlinearity, applied
  independently at each position. This is where most of the parameters live.
- *Positional encoding*: attention is permutation-equivariant, so position
  must be injected. Sinusoidal encodings (Chapter 5) or rotary embeddings
  (Chapter 35) do it.
- *Training objective*: cross-entropy on the next token, which by Chapter 32
  is maximum likelihood, which is minimum KL divergence to the data
  distribution.
- *Optimiser*: Adam, a diagonal preconditioner (Chapter 34), on minibatch
  gradients computed by reverse-mode AD.

#intuition(title: "what you should take from this")[
  There is no step in that description that this book has not covered.

  A transformer is: dot products for similarity, softmax for normalisation, a
  variance calculation for the scaling, matrix multiplication for composition
  and for batching, the chain rule for training, cross-entropy from
  information theory, and gradient descent with a diagonal preconditioner.

  The engineering is formidable --- the systems work, the data curation, the
  scale --- and the *mathematics* is a few hundred pages of undergraduate
  material assembled thoughtfully.

  That is the honest picture, and it is the one worth having. Papers that look
  impenetrable are usually assembling familiar pieces in an unfamiliar order.
  Having the pieces is what lets you see the order.
]

== Exercises

#exercise[
  For a two-layer network $y = W_2 phi(W_1 x)$ with squared loss
  $cal(L) = norm(y - t)^2$, derive
  $partial cal(L) slash partial W_1$ and
  $partial cal(L) slash partial W_2$ explicitly, and state the shape of every
  intermediate quantity.
]

#exercise[
  Show that a network with $L$ linear layers and no activation function is
  equivalent to a single linear layer, and count how many parameters are
  wasted for $L = 5$ layers of width 100.
]

#exercise[
  A 50-layer network uses sigmoid activations and weights initialised with
  $norm(W) approx 1$. Estimate the factor by which the gradient at layer 1 is
  smaller than at layer 50. Repeat for ReLU.
]

#exercise[
  Verify that for a residual block $a = x + F(x)$, the Jacobian is
  $I + partial F slash partial x$, and explain in one sentence why a product
  of such Jacobians resists both vanishing and exploding.
]

#exercise[
  Implement (on paper) dual-number arithmetic for $f(x) = x^2 sin(x)$ at
  $x = 2$: carry the pair $(2, 1)$ through each operation and read off
  $f'(2)$. Check against the analytic derivative.
]

#exercise[
  Show that if $q$ and $k$ have i.i.d. entries with mean 0 and variance 1,
  then $Var(q dot k) = d$. Then explain what would go wrong in a transformer
  with $d = 4096$ and no $1 slash sqrt(d)$ scaling.
]

#exercise[
  Attention has cost $O(n^2 d)$ in sequence length $n$. Derive that from the
  matrix shapes in the definition, and state which of the two matrix products
  dominates for large $n$.
]

#exercise[
  Explain, in terms of the associativity argument of Chapter 18, why
  reverse-mode AD is preferred for training neural networks but forward-mode
  is preferred for computing the sensitivity of a large simulation output to a
  single scalar input.
]
