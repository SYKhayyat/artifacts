#import "../lib.typ": *

= Integration

== Two completely different ideas that turn out to be one

Integration comes in two flavours, and confusing them is a common source of
misery. They are genuinely different questions, and the fact that they have
the same answer is a *theorem* --- arguably the most important theorem in
mathematics.

*The definite integral* is a limit of sums. It answers: what is the total
accumulated amount? Area under a curve, total distance from a velocity,
total charge from a density.

*The antiderivative* is the reverse of differentiation. It answers: which
function has this derivative?

There is no obvious reason these should be related. The Fundamental Theorem of
Calculus says they are, and that is what makes areas computable.

== The definite integral

#definition(title: "Riemann sum")[
  Partition $[a,b]$ into $n$ subintervals with points
  $a = x_0 < x_1 < dots.c < x_n = b$. Choose a sample point $x_i^*$ in each
  subinterval $[x_(i-1), x_i]$, and write $Delta x_i = x_i - x_(i-1)$. The
  *Riemann sum* is
  $ sum_(i=1)^n f(x_i^*) Delta x_i. $
]

Each term is (height) $times$ (width) --- the area of a thin rectangle. The
sum approximates the area under the curve; the approximation improves as the
rectangles get thinner.

#definition(title: "definite integral")[
  $ integral_a^b f(x) dif x = lim_(max Delta x_i -> 0) sum_(i=1)^n f(x_i^*) Delta x_i, $
  provided the limit exists and does not depend on the partitions or sample
  points chosen. Then $f$ is *Riemann integrable* on $[a,b]$.
]

#intuition(title: "reading the notation")[
  The symbol $integral$ is an elongated S, for *sum*. The $dif x$ is what is
  left of $Delta x$ after the limit. So $integral f(x) dif x$ is literally
  "sum of (value $times$ width)", with the widths going to zero.

  The $dif x$ is not decoration and not a multiplication. It tells you *which
  variable is being integrated over* --- essential once there are several ---
  and it carries the units. If $f$ is a velocity in m/s and $x$ is a time in
  s, the integral is in metres. Dimensional analysis of an integral works
  exactly as you would hope, and it is a good check on whether you have set one
  up correctly.
]

#theorem(title: "integrability")[
  Every continuous function on $[a,b]$ is Riemann integrable. So is every
  bounded function with only finitely many discontinuities.
]

Not everything is integrable. The *Dirichlet function* --- $1$ on rationals,
$0$ on irrationals --- has upper Riemann sums always $1$ and lower sums always
$0$, so the limit does not exist. Repairing this is what the Lebesgue integral
does, and it is the reason measure theory exists. For everything in this book,
Riemann is enough.

=== Properties

$
integral_a^b (f + g) &= integral_a^b f + integral_a^b g \
integral_a^b c f &= c integral_a^b f \
integral_a^b f &= integral_a^c f + integral_c^b f \
integral_a^b f &= -integral_b^a f, quad integral_a^a f = 0
$

The last line is a convention chosen, as usual, to make the additivity rule
hold without caring about the order of $a$, $b$, $c$.

Also: if $f <= g$ on $[a,b]$ then $integral f <= integral g$; and
$ abs(integral_a^b f) <= integral_a^b abs(f), $
which is the integral form of the triangle inequality and is used constantly
to bound things.

== The Fundamental Theorem

#theorem(title: "Fundamental Theorem of Calculus, Part I")[
  Let $f$ be continuous on $[a,b]$ and define
  $ F(x) = integral_a^x f(t) dif t. $
  Then $F$ is differentiable on $(a,b)$ and $F'(x) = f(x)$.
]

#proof[
  Compute the difference quotient. By the additivity property,
  $ F(x+h) - F(x) = integral_x^(x+h) f(t) dif t. $

  Since $f$ is continuous on $[x, x+h]$, it attains a minimum $m_h$ and a
  maximum $M_h$ there (Extreme Value Theorem, Chapter 13). The integral of a
  function over an interval of width $h$ is between the width times the
  minimum and the width times the maximum:
  $ m_h h <= integral_x^(x+h) f(t) dif t <= M_h h. $
  Dividing by $h > 0$:
  $ m_h <= (F(x+h)-F(x))/h <= M_h. $

  As $h -> 0$, both $m_h$ and $M_h$ tend to $f(x)$, by continuity of $f$. The
  squeeze theorem gives $F'(x) = f(x)$.
]

#theorem(title: "Fundamental Theorem of Calculus, Part II")[
  If $f$ is continuous on $[a,b]$ and $G$ is *any* antiderivative of $f$
  (that is, $G' = f$), then
  $ integral_a^b f(x) dif x = G(b) - G(a). $
]

#proof[
  Let $F(x) = integral_a^x f$ as in Part I, so $F' = f = G'$. Then
  $(F - G)' = 0$ on $(a,b)$, so by the mean value theorem corollary of
  Chapter 15, $F - G$ is constant: $F(x) = G(x) + C$.

  Now $F(a) = 0$, so $C = -G(a)$. Therefore
  $ integral_a^b f = F(b) = G(b) - G(a). $
]

#intuition(title: "why these two things are the same, in one picture")[
  Think of $F(x)$ as the accumulated area up to $x$. Push $x$ forward by a
  tiny $h$. The area gains a sliver of width $h$ and height about $f(x)$, so
  it gains about $f(x) h$. Therefore the *rate* at which accumulated area
  grows is $f(x)$.

  That is Part I in a sentence: *the rate of accumulation is the thing being
  accumulated.*

  Part II is then the telescoping observation. Chop $[a,b]$ into pieces. The
  total change in $G$ is the sum of the changes over the pieces --- almost
  everything cancels --- and each small change in $G$ is about $G'$ times the
  width, which is $f$ times the width, which is a Riemann sum. So the total
  change in $G$ equals the integral of $f$.

  The Fundamental Theorem is a telescoping sum in the limit. Chapter 2's
  telescoping identity was the discrete rehearsal.
]

#definition(title: "indefinite integral")[
  $ integral f(x) dif x = F(x) + C $
  denotes the family of all antiderivatives of $f$. The $+C$ is not
  decoration: by the MVT corollary, two antiderivatives on an interval differ
  by a constant, and *every* constant occurs.
]

#warning(title: "the $+C$ has a real edge case")[
  "Antiderivatives differ by a constant" is true *on an interval*. On a
  disconnected domain it is false: you get an independent constant on each
  component.

  $integral (dif x) slash x = ln abs(x) + C$ is the standard answer, but the
  domain is $RR without {0}$, and the honest answer has different constants on
  the two sides. This bites in practice when a symbolic integrator hands you an
  antiderivative and you evaluate it across a singularity --- getting a
  confident, finite, completely wrong number for a divergent integral.
]

== Techniques

=== The basic table

$
integral x^n dif x &= (x^(n+1))/(n+1) + C quad (n != -1) \
integral 1/x dif x &= ln abs(x) + C \
integral e^x dif x &= e^x + C \
integral sin x dif x &= -cos x + C \
integral cos x dif x &= sin x + C \
integral 1/(1+x^2) dif x &= arctan x + C \
integral 1/sqrt(1-x^2) dif x &= arcsin x + C
$

Note the exception at $n = -1$: the power rule would divide by zero. That gap
is exactly where the logarithm lives, and it is why $ln$ is unavoidable.

=== Substitution: the chain rule backwards

#theorem(title: "substitution")[
  $ integral f(g(x)) g'(x) dif x = integral f(u) dif u, quad u = g(x). $
  For a definite integral, change the limits too:
  $ integral_a^b f(g(x)) g'(x) dif x = integral_(g(a))^(g(b)) f(u) dif u. $
]

#proof[
  Let $F' = f$. By the chain rule, $(F compose g)'(x) = f(g(x)) g'(x)$. So
  $F compose g$ is an antiderivative of the left integrand, and by Part II the
  definite integral is $F(g(b)) - F(g(a))$, which is the right-hand side.
]

#example[
  $ integral 2x e^(x^2) dif x. $
  Put $u = x^2$, so $dif u = 2x dif x$ --- and the $2x dif x$ is sitting right
  there. The integral becomes $integral e^u dif u = e^u + C = e^(x^2) + C$.

  Substitution works exactly when the integrand contains an inner function
  *and* its derivative as a factor. Training yourself to spot that pattern is
  most of the skill.
]

=== Integration by parts: the product rule backwards

#theorem(title: "integration by parts")[
  $ integral u dif v = u v - integral v dif u, $
  or explicitly $ integral f g' = f g - integral f' g. $
]

#proof[
  Integrate the product rule $(f g)' = f' g + f g'$ over $[a,b]$ and apply
  Part II to the left side:
  $ f(b)g(b) - f(a)g(a) = integral_a^b f' g + integral_a^b f g'. $
  Rearrange.
]

#intuition(title: "what parts is for, and how to choose $u$")[
  Integration by parts trades one integral for another. It is useful when the
  new integral is easier --- which happens when differentiating one factor
  simplifies it.

  The standard mnemonic for choosing $u$ (the factor to differentiate) is
  *LIATE*: Logarithmic, Inverse trig, Algebraic, Trigonometric, Exponential ---
  earlier in the list makes a better $u$. The reason is that logs and inverse
  trig get *much* simpler when differentiated, while exponentials do not change
  at all, so they are better left as $dif v$.
]

#example[
  $ integral x e^x dif x. $
  Take $u = x$ (algebraic, differentiates to 1) and $dif v = e^x dif x$. Then
  $dif u = dif x$ and $v = e^x$, so
  $ integral x e^x dif x = x e^x - integral e^x dif x = x e^x - e^x + C. $
]

#example(title: "the trick where the integral comes back")[
  $ I = integral e^x sin x dif x. $
  Parts with $u = sin x$, $dif v = e^x dif x$:
  $ I = e^x sin x - integral e^x cos x dif x. $
  Parts again on the new integral, with $u = cos x$:
  $ integral e^x cos x dif x = e^x cos x + integral e^x sin x dif x = e^x cos x + I. $
  Substituting back:
  $ I = e^x sin x - e^x cos x - I quad arrow.r.double quad 2I = e^x(sin x - cos x), $
  so $I = e^x (sin x - cos x) slash 2 + C$.

  Solving for the unknown integral algebraically is a legitimate and
  underused move.
]

=== Partial fractions

Chapter 2 decomposed a rational function into simple pieces. Now the reason:
each piece integrates to a logarithm or an arctangent.

#example[
  $ integral (3x+1)/(x^2 - x - 2) dif x. $
  Chapter 2 gave the decomposition
  $ (7 slash 3)/(x-2) + (2 slash 3)/(x+1), $
  so the integral is
  $ 7/3 ln abs(x-2) + 2/3 ln abs(x+1) + C. $
]

Any rational function can be integrated this way in principle: factor the
denominator (possible over $RR$ into linear and irreducible quadratic factors,
by Chapter 6's fundamental theorem of algebra), decompose, and integrate each
piece. Linear factors give logs, irreducible quadratics give arctangents.

=== Trigonometric substitution

When the integrand contains $sqrt(a^2 - x^2)$, $sqrt(a^2 + x^2)$, or
$sqrt(x^2 - a^2)$, substitute $x = a sin theta$, $x = a tan theta$, or
$x = a sec theta$ respectively. Each choice makes the Pythagorean identity
collapse the square root.

#example[
  $ integral sqrt(1 - x^2) dif x. $ Put $x = sin theta$, $dif x = cos theta dif theta$.
  Then $sqrt(1 - sin^2 theta) = cos theta$, and
  $ integral cos^2 theta dif theta = integral (1 + cos 2 theta)/2 dif theta = theta/2 + (sin 2 theta)/4 + C, $
  using the half-angle formula of Chapter 5. Converting back with
  $theta = arcsin x$ and $sin 2theta = 2 x sqrt(1-x^2)$:
  $ integral sqrt(1-x^2) dif x = (arcsin x)/2 + (x sqrt(1-x^2))/2 + C. $
  Evaluating from $-1$ to $1$ gives $pi slash 2$ --- the area of a
  semicircle of radius 1, as it must be.
]

== Improper integrals

#definition[
  If the interval is infinite or the integrand blows up, define the integral
  as a limit:
  $ integral_a^infinity f = lim_(b -> infinity) integral_a^b f, quad integral_0^1 1/sqrt(x) dif x = lim_(t->0^+) integral_t^1 1/sqrt(x) dif x. $
  If the limit exists and is finite, the integral *converges*; otherwise it
  *diverges*.
]

#example(title: "the p-test, which you will use for series too")[
  $ integral_1^infinity 1/(x^p) dif x = cases(
    1/(p-1) quad &"if" p > 1 quad ("converges"),
    infinity &"if" p <= 1 quad ("diverges")
  ). $

  In particular $integral_1^infinity (dif x) slash x = lim_(b->infinity) ln b = infinity$
  diverges, while $integral_1^infinity (dif x) slash x^2 = 1$ converges. The
  boundary is exactly at $p = 1$, and $1 slash x$ is on the wrong side of it.

  Note the mirror image near zero: $integral_0^1 x^(-p) dif x$ converges iff
  $p < 1$. The same exponent that saves you at infinity kills you at the
  origin.
]

== Applications

*Area between curves.* $integral_a^b [f(x) - g(x)] dif x$ where $f >= g$.

*Volume by slicing.* If $A(x)$ is the cross-sectional area at position $x$,
the volume is $integral_a^b A(x) dif x$. For a solid of revolution about the
$x$-axis, $A(x) = pi f(x)^2$, giving the *disc method*.

*Arc length.* A tiny piece of curve has length
$sqrt((dif x)^2 + (dif y)^2) = sqrt(1 + (y')^2) dif x$, so
$ L = integral_a^b sqrt(1 + f'(x)^2) dif x. $

*Average value.* $ overline(f) = 1/(b-a) integral_a^b f(x) dif x. $ This is the
continuous version of the arithmetic mean, and the *mean value theorem for
integrals* says a continuous $f$ actually attains its average somewhere.

*Probability.* If $p(x)$ is a probability density (Chapter 28), then
$integral_a^b p = PP(a <= X <= b)$, $integral_(-infinity)^infinity p = 1$, and
$EE[X] = integral x p(x) dif x$. Every formula in continuous probability is an
integral, which is why Part V waits until now.

== Numerical integration

Most integrals have no closed form. $integral e^(-x^2) dif x$ has no
elementary antiderivative --- and that is a theorem, not a failure of
ingenuity. So you compute numerically.

#align(center)[
  #table(
    columns: 3,
    inset: 7pt,
    align: (left, left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Rule*], [*Formula on $[a,b]$*], [*Error*]),
    [Midpoint], [$(b-a) f((a+b)/2)$], [$O(h^2)$ per interval],
    [Trapezoid], [$(b-a) (f(a)+f(b))/2$], [$O(h^2)$],
    [Simpson], [$(b-a)/6 [f(a) + 4f((a+b)/2) + f(b)]$], [$O(h^4)$],
  )
]

#intuition(title: "why Simpson's rule is so much better")[
  Trapezoid fits a straight line through two points. Simpson fits a *parabola*
  through three. Since a parabola matches the function to one more order, the
  error drops by two powers of $h$ rather than one --- Simpson is exact for
  all cubics, not just quadratics, by a symmetry cancellation.

  For a composite rule with $n$ subintervals, halving $h$ improves trapezoid by
  a factor of 4 and Simpson by a factor of 16. That gap compounds, and it is
  why Simpson is the default for smooth integrands.

  For *non-smooth* integrands all of this collapses: the error bounds involve
  $f''$ or $f^((4))$, and if those are large or nonexistent the rules are no
  better than their worst behaviour. That is when you reach for adaptive
  quadrature, which subdivides only where the estimated error is large.
]

Chapter 33 develops this properly, including Gaussian quadrature, which
achieves $O(h^(2n))$ accuracy by choosing the sample points cleverly instead
of evenly.

== Exercises

#exercise[
  Evaluate directly from the definition, as a limit of Riemann sums with equal
  subintervals and right endpoints: $integral_0^1 x^2 dif x$. (You will need
  the sum-of-squares formula from Chapter 2.)
]

#exercise[
  Compute: (a) $integral x sqrt(x^2+1) dif x$; (b) $integral (ln x) slash x dif x$;
  (c) $integral_0^(pi slash 2) sin^3 x cos x dif x$; (d) $integral (dif x) slash (x^2 + 9)$.
]

#exercise[
  Use integration by parts to compute $integral x^2 e^(-x) dif x$. (You will
  need to apply it twice.)
]

#exercise[
  Compute $integral ln x dif x$. Hint: take $u = ln x$ and $dif v = dif x$ ---
  parts works even when there appears to be only one factor.
]

#exercise[
  Decompose and integrate $ integral (x + 5)/(x^2 + x - 6) dif x. $
]

#exercise[
  Determine whether each converges, and evaluate if so:
  (a) $integral_1^infinity (dif x) slash x^(3 slash 2)$;
  (b) $integral_0^1 (dif x) slash x$;
  (c) $integral_0^infinity e^(-x) dif x$.
]

#exercise[
  Find the area between $y = x^2$ and $y = x + 2$, and then the volume
  obtained by rotating the region between $y = sqrt(x)$ and the $x$-axis, for
  $0 <= x <= 4$, about the $x$-axis.
]

#exercise[
  Estimate $integral_0^1 e^(-x^2) dif x$ using the trapezoid rule and
  Simpson's rule, each with 4 subintervals. The true value is about
  $0.746824$. Compare the two errors and check they are roughly in the ratio
  the error orders predict.
]
