#import "../lib.typ": *

= Derivatives

== The definition, and why it looks like that

#definition(title: "derivative")[
  The *derivative* of $f$ at $a$ is
  $ f'(a) = lim_(h -> 0) (f(a+h) - f(a))/h, $
  provided the limit exists, in which case $f$ is *differentiable* at $a$.
]

The quotient inside is the slope of the *secant* line through the points
$(a, f(a))$ and $(a+h, f(a+h))$: rise over run. As $h -> 0$ the second point
slides towards the first and the secant line pivots towards the *tangent*.
The derivative is the slope of that limiting line.

Note it is exactly the $0 slash 0$ situation of Chapter 13: numerator and
denominator both go to zero, and everything depends on their *rate*.

#intuition(title: "four readings of the same object")[
  You need all four, because different problems present it differently.

  *Geometric:* the slope of the tangent line.

  *Physical:* the instantaneous rate of change. If $s(t)$ is position,
  $s'(t)$ is velocity.

  *Approximation:* near $a$, $f(a + h) approx f(a) + f'(a) h$. The derivative
  is *the best linear approximation* to $f$ at $a$. This is the reading that
  generalises to many variables and is the one that matters for machine
  learning.

  *Sensitivity:* if you perturb the input by a small amount, the output moves
  by $f'(a)$ times as much. The derivative is a gain, an amplification factor.
  This is the reading that explains exploding and vanishing gradients.
]

The linear-approximation reading deserves its own statement, because it is
what "differentiable" really means.

#proposition(title: "differentiability is local linearity")[
  $f$ is differentiable at $a$ with derivative $m$ if and only if
  $ f(a + h) = f(a) + m h + r(h) quad "where" quad lim_(h->0) r(h)/h = 0. $
]

#proof[
  Define $r(h) = f(a+h) - f(a) - m h$. Then
  $ r(h)/h = (f(a+h)-f(a))/h - m, $
  and this tends to $0$ exactly when the difference quotient tends to $m$.
]

So $f$ is differentiable at $a$ precisely when it can be approximated by a
straight line with an error that vanishes *faster than linearly*. That is the
form which generalises: in Chapter 18, "derivative" in many variables will
mean exactly the same thing with $m h$ replaced by a matrix times a vector.

== Notation

Several notations coexist, each good for something.

#align(center)[
  #table(
    columns: 3,
    inset: 7pt,
    align: (left, left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Notation*], [*Name*], [*Best for*]),
    [$f'(x)$, $f''(x)$], [Lagrange], [compact, when the variable is obvious],
    [$(dif y)/(dif x)$], [Leibniz], [chain rule and substitution; the "fractions" cancel suggestively],
    [$dot(x)$], [Newton], [derivatives with respect to time, in physics],
    [$D f$, $partial_x f$], [operator], [when you want to emphasise that differentiation is a function of functions],
  )
]

Leibniz notation is the most useful and the most philosophically dubious.
$(dif y) slash (dif x)$ is *not* a fraction --- $dif y$ and $dif x$ are not
numbers. But it behaves like one often enough that the notation is worth its
danger, and Chapter 18 will explain when it stops working.

== Computing derivatives from the definition

Do this a few times and then never again.

#example(title: "the power rule for small n")[
  $f(x) = x^2$:
  $ (f(x+h)-f(x))/h = ((x+h)^2 - x^2)/h = (2 x h + h^2)/h = 2x + h -> 2x. $

  The cancellation of $h$ is the whole trick, and it is legal because the
  limit never evaluates at $h = 0$.
]

#theorem(title: "power rule")[
  For any real $n$, $ dif/(dif x) x^n = n x^(n-1). $
]

#proof[
  For positive integer $n$, use the difference-of-powers identity from
  Chapter 2 with $a = x+h$, $b = x$:
  $ ((x+h)^n - x^n)/h = (h dot sum_(k=0)^(n-1) (x+h)^(n-1-k) x^k)/h = sum_(k=0)^(n-1)(x+h)^(n-1-k) x^k. $
  As $h -> 0$ each of the $n$ terms tends to $x^(n-1)$, giving $n x^(n-1)$.

  The general real case follows from the chain rule and the derivative of
  $exp$, by writing $x^n = e^(n ln x)$ for $x > 0$.
]

#theorem(title: "derivative of the exponential")[
  $ dif/(dif x) e^x = e^x. $
]

#proof[
  $ (e^(x+h) - e^x)/h = e^x (e^h - 1)/h. $
  By the definition of $e$ in Chapter 4, the second factor tends to $1$.
]

#theorem(title: "derivative of sine")[
  $ dif/(dif x) sin x = cos x. $
]

#proof[
  Using the angle addition formula of Chapter 5,
  $
  (sin(x+h) - sin x)/h &= (sin x cos h + cos x sin h - sin x)/h \
  &= sin x dot (cos h - 1)/h + cos x dot (sin h)/h.
  $
  The second bracket tends to $1$ by the fundamental trigonometric limit of
  Chapter 13. For the first, multiply by the conjugate:
  $ (cos h - 1)/h = (cos^2 h - 1)/(h(cos h + 1)) = (-sin^2 h)/(h(cos h+1)) = -(sin h)/h dot (sin h)/(cos h + 1) -> -1 dot 0/2 = 0. $
  So the whole expression tends to $cos x$.
]

Everything else is built by rules, which is the point of having rules.

== The rules

#theorem(title: "linearity")[
  $(f + g)' = f' + g'$ and $(c f)' = c f'$.
]

#proof[
  Immediate from the limit laws of Chapter 13, since the difference quotient
  of a sum is the sum of the difference quotients.
]

#theorem(title: "product rule")[
  $ (f g)' = f' g + f g'. $
]

#proof[
  The trick is to add and subtract a cross term:
  $
  (f(x+h)g(x+h) - f(x)g(x))/h
  &= (f(x+h)g(x+h) - f(x)g(x+h) + f(x)g(x+h) - f(x)g(x))/h \
  &= (f(x+h)-f(x))/h dot g(x+h) + f(x) dot (g(x+h)-g(x))/h.
  $
  As $h -> 0$ the first quotient tends to $f'(x)$, and $g(x+h) -> g(x)$
  because differentiability implies continuity. The second tends to $g'(x)$.
]

#intuition(title: "why the product rule is not $f' g'$")[
  Think of a rectangle with sides $f$ and $g$; its area is the product. Grow
  each side a little: $f$ by $Delta f$ and $g$ by $Delta g$. The new area
  exceeds the old by three pieces --- a strip of size $Delta f dot g$, a strip
  of size $f dot Delta g$, and a tiny corner of size $Delta f dot Delta g$.

  Divide by $h$ and take the limit: the two strips give $f' g + f g'$, and the
  corner is *second order* --- it involves the product of two small things, so
  it vanishes faster than $h$ and contributes nothing.

  "Second-order terms vanish" is the recurring theme of all of calculus.
]

#theorem(title: "quotient rule")[
  $ (f/g)' = (f' g - f g')/(g^2), quad g != 0. $
]

#proof[
  Write $f = (f slash g) dot g$ and differentiate with the product rule:
  $ f' = (f/g)' g + (f/g) g'. $
  Solve for $(f slash g)'$:
  $ (f/g)' = (f' - (f slash g) g')/g = (f' g - f g')/(g^2). $
]

#theorem(title: "chain rule")[
  If $g$ is differentiable at $x$ and $f$ is differentiable at $g(x)$, then
  $ (f compose g)'(x) = f'(g(x)) dot g'(x). $
  In Leibniz notation, with $u = g(x)$: $ (dif y)/(dif x) = (dif y)/(dif u) dot (dif u)/(dif x). $
]

#proof[
  Use the local-linearity form. Near $x$,
  $ g(x + h) = g(x) + g'(x) h + r_1(h), quad r_1(h)/h -> 0, $
  and writing $k = g'(x) h + r_1(h)$ (which tends to $0$ with $h$), near
  $g(x)$,
  $ f(g(x) + k) = f(g(x)) + f'(g(x)) k + r_2(k), quad r_2(k)/k -> 0. $
  Substituting,
  $ f(g(x+h)) = f(g(x)) + f'(g(x))[g'(x) h + r_1(h)] + r_2(k). $
  Divide by $h$. The main term is $f'(g(x)) g'(x)$. The term
  $f'(g(x)) r_1(h) slash h -> 0$. And $r_2(k) slash h = (r_2(k) slash k)(k slash h)$
  where $k slash h -> g'(x)$ is bounded and $r_2(k) slash k -> 0$. So the
  error terms vanish.
]

#intuition(title: "the chain rule is gain composition, and it is all of backprop")[
  Read the derivative as *sensitivity*, the fourth reading above. If nudging
  $x$ moves $u$ by a factor of $3$, and nudging $u$ moves $y$ by a factor of
  $5$, then nudging $x$ moves $y$ by a factor of $15$. Gains multiply along a
  chain.

  Now stack a hundred of them. The gain of the whole chain is the product of a
  hundred numbers. If they average slightly below 1, the product goes
  exponentially to zero --- *vanishing gradients*. If slightly above,
  exponentially to infinity --- *exploding gradients*.

  That is not an analogy. A deep network is a composition of a hundred
  functions, backpropagation is the chain rule applied to it, and the numerical
  pathology of deep learning is the numerical behaviour of a long product.
  Chapter 36 does this properly.
]

#theorem(title: "inverse function rule")[
  If $f$ is differentiable and invertible near $a$, with $f'(a) != 0$, then
  $ (f^(-1))'(f(a)) = 1/(f'(a)). $
]

#proof[
  Differentiate $f(f^(-1)(y)) = y$ with respect to $y$ using the chain rule:
  $ f'(f^(-1)(y)) dot (f^(-1))'(y) = 1. $
  Solve.
]

#example(title: "the derivative of the logarithm")[
  $ln$ is the inverse of $exp$. By the rule, with $y = e^x$,
  $ (ln)'(y) = 1/(exp)'(x) = 1/(e^x) = 1/y. $
  So $ dif/(dif x) ln x = 1/x. $

  Notice what happened: the derivative of a transcendental function turned out
  to be a simple rational function. This is the reason $ln$ appears whenever
  you integrate $1 slash x$ (Chapter 16) and the reason harmonic sums are
  logarithmic.
]

== The standard table

$
dif/(dif x) x^n &= n x^(n-1) &quad dif/(dif x) e^x &= e^x \
dif/(dif x) ln abs(x) &= 1/x &quad dif/(dif x) a^x &= a^x ln a \
dif/(dif x) sin x &= cos x &quad dif/(dif x) cos x &= -sin x \
dif/(dif x) tan x &= sec^2 x &quad dif/(dif x) arctan x &= 1/(1+x^2) \
dif/(dif x) arcsin x &= 1/sqrt(1-x^2) &quad dif/(dif x) sigma(x) &= sigma(x)(1 - sigma(x))
$

That last one is worth deriving, since it is the reason sigmoid was
computationally attractive.

#example(title: "the sigmoid derivative")[
  $sigma(x) = (1 + e^(-x))^(-1)$. By the chain rule,
  $ sigma'(x) = -(1+e^(-x))^(-2) dot (-e^(-x)) = (e^(-x))/((1+e^(-x))^2). $
  Now rewrite: $ (e^(-x))/((1+e^(-x))^2) = 1/(1+e^(-x)) dot (e^(-x))/(1+e^(-x)) = sigma(x) dot (1 - sigma(x)), $
  using $ (e^(-x))/(1+e^(-x)) = (1 + e^(-x) - 1)/(1+e^(-x)) = 1 - sigma(x)$.

  So the derivative is expressible in terms of the *output value alone* --- no
  need to keep the input around. In a network, the forward pass already
  computed $sigma(x)$; the backward pass gets the derivative for one
  multiplication. That efficiency is why sigmoid and tanh dominated for so
  long, and $tanh' = 1 - tanh^2$ has the same property.
]

== Differentiability versus continuity

#theorem[
  Differentiable at $a$ $arrow.r.double$ continuous at $a$.
]

#proof[
  $ lim_(h->0)[f(a+h) - f(a)] = lim_(h->0) (f(a+h)-f(a))/h dot h = f'(a) dot 0 = 0. $
]

The converse is false, and the counterexamples matter.

#example(title: "three ways to be continuous but not differentiable")[
  *A corner.* $f(x) = abs(x)$ at $0$. The left difference quotient is $-1$,
  the right is $+1$; they disagree, so no limit. This is exactly ReLU's kink,
  and it is why frameworks adopt the convention $"ReLU"'(0) = 0$ --- a choice,
  not a derivative.

  *A vertical tangent.* $f(x) = x^(1 slash 3)$ at $0$. The difference quotient
  is $h^(-2 slash 3) -> infinity$. The tangent line exists but is vertical, so
  its slope is not a real number.

  *A cusp.* $f(x) = x^(2 slash 3)$ at $0$: the two sides go to
  $+infinity$ and $-infinity$.

  And in the extreme: the *Weierstrass function* is continuous everywhere and
  differentiable nowhere. In a precise sense, such functions are the typical
  case --- smooth functions are the rare exception, which is a good thing to
  know before you assume anything about a function you did not construct.
]

== Higher derivatives

$f''$ is the derivative of $f'$, and so on. $f^((n))$ denotes the $n$-th.

*Physical:* if $s$ is position, $s'$ is velocity, $s''$ is acceleration.

*Geometric:* $f''$ measures *concavity*. Where $f'' > 0$ the curve bends
upwards (convex, holds water); where $f'' < 0$ it bends downwards. A sign
change is an *inflection point*.

*Optimisation:* Chapter 34 is essentially the study of $f''$. First
derivatives find candidate optima; second derivatives tell you which kind you
found and how fast an algorithm will converge. In many variables $f''$ becomes
the Hessian matrix, and its eigenvalues describe the local shape of the loss
surface.

== Implicit and logarithmic differentiation

Sometimes $y$ is defined by an equation rather than a formula.

#example(title: "implicit differentiation")[
  The circle $x^2 + y^2 = 25$. Differentiate both sides with respect to $x$,
  treating $y$ as a function of $x$ and using the chain rule on $y^2$:
  $ 2x + 2y (dif y)/(dif x) = 0 quad arrow.r.double quad (dif y)/(dif x) = -x/y. $
  At $(3,4)$ the slope is $-3 slash 4$, which is perpendicular to the radius
  --- as it must be.

  No need to solve for $y$ first, which is fortunate, since for most implicit
  equations you cannot.
]

#example(title: "logarithmic differentiation")[
  To differentiate $y = x^x$ (where the power rule does not apply, since the
  exponent is not constant, and the exponential rule does not apply, since the
  base is not constant): take logs first.
  $ ln y = x ln x. $
  Differentiate both sides:
  $ (1/y) (dif y)/(dif x) = ln x + 1, quad "so" quad (dif y)/(dif x) = x^x (ln x + 1). $

  The same technique turns any big product into a sum before differentiating,
  which is exactly why log-likelihood is the thing that gets differentiated in
  statistics rather than likelihood itself (Chapter 31).
]

== Numerical differentiation, and its trap

You will sometimes want $f'$ without a formula. The obvious approach is to
take the definition and stop before the limit:
$ f'(x) approx (f(x+h) - f(x))/h. $

#warning(title: "there is an optimal $h$ and it is not tiny")[
  Two errors fight each other.

  *Truncation error.* Taylor's theorem (Chapter 17) gives
  $(f(x+h)-f(x)) slash h = f'(x) + (h slash 2) f''(xi)$, so this error is
  $O(h)$: it *shrinks* as $h$ shrinks.

  *Roundoff error.* $f(x+h)$ and $f(x)$ are nearly equal, so subtracting them
  cancels leading digits. If each is computed with relative error
  $epsilon_"mach" approx 10^(-16)$, the difference carries absolute error
  about $epsilon_"mach" abs(f(x))$, and dividing by $h$ inflates it to
  $epsilon_"mach" abs(f(x)) slash h$: this error *grows* as $h$ shrinks.

  Total error is roughly $C h + epsilon_"mach" slash h$, minimised (by
  Chapter 15's technique) at $h approx sqrt(epsilon_"mach") approx 10^(-8)$,
  giving about 8 correct digits --- half your precision, gone.

  The *central difference* $(f(x+h) - f(x-h)) slash (2h)$ has truncation error
  $O(h^2)$, giving optimal $h approx epsilon_"mach"^(1 slash 3) approx 10^(-5)$
  and about 10 correct digits. Better, still not great.

  This is why automatic differentiation exists. AD applies the chain rule
  symbolically to the computation graph and computes derivatives to *full*
  machine precision with no step size at all. It is not numerical
  differentiation and it is not symbolic differentiation; it is the chain rule
  executed alongside the program. Chapter 36 builds one.
]

== Exercises

#exercise[
  Compute from the definition (not from the rules): the derivative of
  $f(x) = 1 slash x$ at a general $x != 0$.
]

#exercise[
  Differentiate: (a) $x^3 e^x$; (b) $(2x+1) slash (x^2 - 3)$;
  (c) $sin(x^2 + 1)$; (d) $e^(cos x)$; (e) $ln(ln x)$;
  (f) $sqrt(1 + tan x)$.
]

#exercise[
  Prove the quotient rule directly from the definition (not via the product
  rule), by adding and subtracting a suitable term as in the product-rule
  proof.
]

#exercise[
  Use implicit differentiation to find $(dif y) slash (dif x)$ for
  $x^3 + y^3 = 6 x y$ (the folium of Descartes), and find the points where the
  tangent is horizontal.
]

#exercise[
  Use logarithmic differentiation to find the derivative of
  $ y = ((x^2+1)^3 sqrt(x-1))/((x+4)^5). $
]

#exercise[
  Show that $tanh'(x) = 1 - tanh^2(x)$, and explain the computational
  significance of the derivative depending only on the output.
]

#exercise[
  Let $f(x) = x^2 sin(1 slash x)$ for $x != 0$ and $f(0) = 0$. Show that
  $f'(0)$ exists (compute it from the definition), and show that $f'$ is not
  continuous at $0$. This is a function that is differentiable everywhere but
  not continuously so.
]

#exercise[
  For $f(x) = e^x$ at $x = 1$, estimate the total error of the forward
  difference at $h = 10^(-3)$, $10^(-8)$, and $10^(-14)$, using the error
  model $C h + epsilon_"mach" slash h$ with $C approx e slash 2$ and
  $epsilon_"mach" = 2.2 times 10^(-16)$. Which $h$ wins?
]
