#import "../lib.typ": *

= Algebra as a Rewriting System

== What algebra actually is

School presents algebra as a bag of procedures: "move it to the other side and
flip the sign", "cross-multiply", "FOIL". Learned that way it is unmemorable
and, worse, unextendable --- the moment an expression does not match a
procedure you have seen, you are stuck.

There is a much better way to see it, and it is one you already have.

#intuition(title: "algebra is term rewriting")[
  An algebraic expression is a *syntax tree*. Algebra is a collection of
  *rewrite rules* that transform one tree into another tree denoting the same
  value. Solving an equation is a *search*: apply rewrites until the tree has
  the shape `x = <something with no x in it>`.

  That is all of it. "Moving to the other side" is not a rule; it is a derived
  shortcut for "apply the same operation to both sides, then simplify". If you
  keep the real rules in mind you can rederive every shortcut and you will
  never be stuck at an unfamiliar shape.
]

The rules are these. They are not theorems --- for the real numbers they are
axioms, the defining properties of a *field*.

#definition(title: "field axioms")[
  For all $a, b, c in RR$:

  #set enum(numbering: "(F1)", start: 1)
  + $a + b = b + a$ and $a b = b a$ #h(1fr) (commutativity)
  + $(a+b)+c = a+(b+c)$ and $(a b) c = a (b c)$ #h(1fr) (associativity)
  + $a + 0 = a$ and $a dot 1 = a$ #h(1fr) (identities)
  + $a + (-a) = 0$, and if $a != 0$, $a dot a^(-1) = 1$ #h(1fr) (inverses)
  + $a(b + c) = a b + a c$ #h(1fr) (distributivity)
]

Every manipulation you will ever perform on a real-number expression is a
finite composition of these five, plus substitution of equals for equals.

#example(title: "why a minus times a minus is a plus")[
  This is usually asserted. It is provable, and only from the axioms above.

  First, $a dot 0 = 0$ for every $a$. Why: $a dot 0 = a dot (0 + 0) = a dot 0 + a dot 0$
  by (F3) and (F5). Adding $-(a dot 0)$ to both sides gives $0 = a dot 0$.

  Next, $(-a) b = -(a b)$. Why: $a b + (-a) b = (a + (-a)) b = 0 dot b = 0$ by
  (F5) and the previous paragraph. So $(-a)b$ is *the* additive inverse of
  $a b$, which is what $-(a b)$ means.

  Finally, $(-a)(-b) = -(a(-b)) = -(-(a b)) = a b$, using the previous line
  twice and the fact that $-(-x) = x$.

  Nothing was assumed except the axioms. A negative times a negative is a
  positive *because it has to be* --- any other convention would break
  distributivity.
]

== Solving equations: which steps are safe

Here is the part that school genuinely gets wrong, and it costs people marks
and, later, correctness bugs.

An equation is a *predicate*: a statement that is true for some values of $x$
and false for others. Its *solution set* is the set of $x$ making it true.
When you rewrite an equation you are transforming one predicate into another,
and the only thing that matters is what happens to the solution set.

#definition(title: "equivalent, and one-way, transformations")[
  A transformation of an equation is *equivalent* (reversible) if the new
  equation has exactly the same solution set.

  It is *one-way* if the new solution set may be *larger* --- in which case
  you have introduced possible *extraneous solutions* and must check each
  candidate --- or *smaller*, in which case you have *lost* solutions, which
  is worse because nothing warns you.
]

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 7pt,
    align: (left, center, left),
    stroke: 0.4pt + luma(180),
    table.header(
      [*Operation*], [*Safe?*], [*Why / what to watch*],
    ),
    [Add or subtract anything from both sides], [safe], [Always reversible.],
    [Multiply both sides by a nonzero constant], [safe], [Reversible: divide back.],
    [Multiply both sides by an expression], [*danger*], [If the expression can be $0$, you gain roots.],
    [Divide both sides by an expression], [*danger*], [If it can be $0$, you *lose* roots.],
    [Square both sides], [*danger*], [Gains roots: $x = -2$ becomes $x^2 = 4$.],
    [Take square root of both sides], [*danger*], [Must write $plus.minus$, or you lose one.],
    [Apply a strictly increasing function], [safe], [E.g. $exp$, or $log$ on positives.],
    [Cancel a common factor], [*danger*], [Same as dividing. State the case where it is zero.],
  )
]

#example(title: "losing a root by cancelling")[
  Solve $x^2 = 5x$.

  The tempting move is to divide both sides by $x$, giving $x = 5$. That is
  *wrong*: it silently assumed $x != 0$, and $x = 0$ is a genuine solution.

  The correct move is to never divide by something that might vanish. Instead
  bring everything to one side and factor:
  $ x^2 - 5x = 0 quad arrow.r.double quad x(x - 5) = 0 quad arrow.r.double quad x = 0 "or" x = 5. $
  The step from a product being zero to a factor being zero is legitimate and
  has a name.
]

#theorem(title: "zero product property")[
  In $RR$ (indeed in any field), if $a b = 0$ then $a = 0$ or $b = 0$.
]

#proof[
  Suppose $a b = 0$ and $a != 0$. Then $a^(-1)$ exists, and
  $ b = 1 dot b = (a^(-1) a) b = a^(-1) (a b) = a^(-1) dot 0 = 0. $
]

#warning(title: "this fails in the integers modulo n")[
  In arithmetic mod $12$, $3 times 4 = 0$ but neither factor is zero. Such
  elements are called *zero divisors*, and their presence is exactly why
  $ZZ slash 12 ZZ$ is not a field. Since your machine integers live in
  $ZZ slash 2^64 ZZ$, factoring-based reasoning about them is not
  automatically valid. Chapter 12 sorts out when it is.
]

#example(title: "gaining a root by squaring")[
  Solve $sqrt(x + 6) = x$.

  Square both sides: $x + 6 = x^2$, so $x^2 - x - 6 = 0$, so
  $(x-3)(x+2) = 0$, so $x = 3$ or $x = -2$.

  Now *check*, because squaring was one-way. $x = 3$: $sqrt(9) = 3$. Good.
  $x = -2$: $sqrt(4) = 2 != -2$. Rejected.

  The extraneous root appeared because squaring cannot distinguish $2$ from
  $-2$; it is not injective. Any time you apply a non-injective function to
  both sides, you must check.
]

== Expanding and factoring

Expanding is mechanical: apply distributivity until no products of sums
remain. Factoring is the reverse and is genuinely a search, which is why it is
harder. These identities are the ones worth having in memory, because they are
the patterns the search looks for.

$
a^2 - b^2 &= (a-b)(a+b) \
(a plus.minus b)^2 &= a^2 plus.minus 2 a b + b^2 \
a^3 - b^3 &= (a - b)(a^2 + a b + b^2) \
a^3 + b^3 &= (a + b)(a^2 - a b + b^2) \
a^n - b^n &= (a - b)(a^(n-1) + a^(n-2) b + dots.c + a b^(n-2) + b^(n-1))
$

The last one contains the others and is worth understanding rather than
memorising.

#proposition(title: "the general difference of powers")[
  For every integer $n >= 1$,
  $ a^n - b^n = (a - b) sum_(k=0)^(n-1) a^(n-1-k) b^k. $
]

#proof[
  Expand the product. Distributing $a$ over the sum gives
  $sum_(k=0)^(n-1) a^(n-k) b^k$, and distributing $-b$ gives
  $-sum_(k=0)^(n-1) a^(n-1-k) b^(k+1)$. Reindex the second sum with
  $j = k+1$, so it runs $j = 1$ to $n$ and equals
  $-sum_(j=1)^(n) a^(n-j) b^j$.

  Now subtract. The two sums have identical terms $a^(n-k)b^k$ for
  $k = 1, dots, n-1$, which cancel in pairs. What survives is the $k=0$ term
  of the first sum, $a^n$, and the $j = n$ term of the second, $-b^n$.
]

#intuition(title: "telescoping")[
  That proof is a *telescoping sum*: almost everything cancels with its
  neighbour and only the two ends survive. Telescoping is one of the three or
  four genuinely reusable summation techniques; you will see it again for
  series (Chapter 17) and for the fundamental theorem of calculus (Chapter
  16), which is, in essence, one enormous telescoping sum.
]

Setting $b = 1$ gives the geometric-sum identity, which you will use
constantly for complexity analysis:

$ 1 + a + a^2 + dots.c + a^(n-1) = (a^n - 1)/(a - 1) quad (a != 1). $

#example(title: "why doubling arrays is amortised O(1)")[
  Growing an array by doubling, from size $1$ to size $n = 2^k$, copies
  $ 1 + 2 + 4 + dots.c + 2^(k-1) = (2^k - 1)/(2-1) = n - 1 $
  elements in total. Spread over $n$ insertions that is under one copy each.
  The geometric sum is the entire content of the amortised analysis.
]

== Quadratics, properly

#theorem(title: "the quadratic formula")[
  Let $a != 0$. The solutions of $a x^2 + b x + c = 0$ are
  $ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a). $
]

#proof[
  This is *completing the square*, and the technique matters more than the
  formula.

  Divide by $a$ (legal, $a != 0$):
  $ x^2 + b/a x + c/a = 0. $

  We want to recognise $x^2 + b/a x$ as the start of a perfect square. Since
  $(x + t)^2 = x^2 + 2 t x + t^2$, matching the linear terms forces
  $2t = b/a$, so $t = b/(2a)$. Add and subtract $t^2$:
  $ underbrace(x^2 + b/a x + b^2/(4a^2), (x + b/(2a))^2) - b^2/(4a^2) + c/a = 0. $

  Rearranging,
  $ (x + b/(2a))^2 = b^2/(4a^2) - c/a = (b^2 - 4 a c)/(4 a^2). $

  Now take square roots --- remembering the $plus.minus$, since this step is
  one-way:
  $ x + b/(2a) = plus.minus sqrt(b^2 - 4 a c)/(2 a), $
  and subtract $b/(2a)$.
]

#definition(title: "discriminant")[
  $Delta = b^2 - 4 a c$. If $Delta > 0$ there are two distinct real roots; if
  $Delta = 0$ one repeated real root; if $Delta < 0$ no real roots (but two
  complex ones --- Chapter 6).
]

Completing the square is not a one-off trick for quadratics. It reappears as:
the derivation of the Gaussian integral (Chapter 27), the reason the normal
distribution has the density it does, the standard proof that a positive
definite quadratic form has a unique minimiser (Chapter 34), and the algebraic
core of the Cholesky decomposition. Learn the move, not the formula.

#warning(title: "the quadratic formula is numerically unstable")[
  If $b^2 gt.double 4 a c$ then $sqrt(b^2 - 4 a c) approx abs(b)$, and one of
  the two numerator terms is a difference of nearly equal numbers ---
  *catastrophic cancellation*. You lose most of your significant digits.

  The fix uses the fact that the product of the roots is $c slash a$. Compute
  the well-conditioned root
  $ x_1 = (-b - sgn(b) sqrt(b^2 - 4 a c)) / (2 a) $
  (both numerator terms have the same sign, so no cancellation), then get the
  other from $x_2 = c slash (a x_1)$. Chapter 33 explains the general
  principle.
]

== Polynomials

#definition(title: "polynomial")[
  A *polynomial* in $x$ is an expression
  $ p(x) = a_n x^n + a_(n-1) x^(n-1) + dots.c + a_1 x + a_0 $
  with the $a_i$ constants and $a_n != 0$; $n$ is the *degree*. A *root* of
  $p$ is a value $r$ with $p(r) = 0$.
]

#theorem(title: "factor theorem")[
  $r$ is a root of $p$ if and only if $(x - r)$ divides $p(x)$ exactly.
]

#proof[
  ($arrow.l.double$) If $p(x) = (x-r) q(x)$ then $p(r) = 0 dot q(r) = 0$.

  ($arrow.r.double$) Divide $p$ by $(x - r)$ with remainder. Because the
  divisor has degree $1$, the remainder has degree $0$ --- it is a constant
  $c$:
  $ p(x) = (x - r) q(x) + c. $
  Substituting $x = r$ gives $p(r) = c$. So if $p(r) = 0$ then $c = 0$ and the
  division is exact.
]

#corollary[
  A polynomial of degree $n$ has at most $n$ roots.
]

#proof[
  Induction on $n$. Degree $0$: a nonzero constant has no roots. Suppose the
  claim holds for degree $n-1$, and let $p$ have degree $n$. If $p$ has no
  root we are done. Otherwise let $r$ be a root; by the factor theorem
  $p(x) = (x-r)q(x)$ with $deg q = n-1$. Any root $s != r$ of $p$ satisfies
  $(s - r) q(s) = 0$ with $s - r != 0$, so $q(s) = 0$ by the zero product
  property. By hypothesis $q$ has at most $n-1$ roots, so $p$ has at most $n$.
]

#example(title: "this corollary is a real tool")[
  Two polynomials of degree at most $n$ that agree at $n+1$ distinct points are
  *identical*. (Subtract them; the difference has degree at most $n$ and more
  than $n$ roots, so it is the zero polynomial.)

  That single fact underwrites polynomial interpolation, Reed--Solomon error
  correction, Shamir secret sharing, and the Schwartz--Zippel lemma behind
  randomised polynomial identity testing.
]

=== Vieta and coefficient relations

If $p(x) = x^2 + b x + c$ has roots $r_1, r_2$ then
$p(x) = (x - r_1)(x - r_2) = x^2 - (r_1 + r_2) x + r_1 r_2$, so

$ r_1 + r_2 = -b, quad r_1 r_2 = c. $

In general, for a monic degree-$n$ polynomial, the coefficient of $x^(n-1)$ is
minus the sum of the roots and the constant term is $(-1)^n$ times their
product. These will resurface in Chapter 23: the trace of a matrix is the sum
of its eigenvalues and the determinant is their product, and that is *this
identity*, applied to the characteristic polynomial.

== Rational expressions and partial fractions

A *rational function* is a quotient $p(x) slash q(x)$ of polynomials. Adding
them requires a common denominator; the operation you will need far more often
is the reverse.

#definition(title: "partial fraction decomposition")[
  Given $p slash q$ with $deg p < deg q$ and $q$ factored into distinct linear
  factors $q(x) = (x - r_1) dots.c (x - r_n)$, there are unique constants
  $A_i$ with
  $ p(x)/q(x) = A_1/(x - r_1) + A_2/(x - r_2) + dots.c + A_n/(x - r_n). $
]

#example(title: "doing one")[
  Decompose $ (3x + 1) / (x^2 - x - 2) $.

  Factor the bottom: $x^2 - x - 2 = (x-2)(x+1)$. Write
  $ (3x+1)/((x-2)(x+1)) = A/(x-2) + B/(x+1). $
  Multiply through by $(x-2)(x+1)$:
  $ 3x + 1 = A(x+1) + B(x-2). $
  This must hold for *all* $x$, so we may choose convenient values. Put
  $x = 2$: $7 = 3A$, so $A = 7 slash 3$. Put $x = -1$: $-2 = -3B$, so
  $B = 2 slash 3$. Hence
  $ (3x+1)/(x^2-x-2) = (7 slash 3)/(x-2) + (2 slash 3)/(x+1). $
]

The reason to care: Chapter 16 will show that $integral (dif x) slash (x - r) = ln abs(x - r)$,
so decomposing a rational function turns an impossible-looking integral into a
sum of logarithms. The same decomposition is how generating functions are
solved for closed-form recurrences (Chapter 11).

== Inequalities

Inequalities obey the field axioms with one crucial exception.

#definition(title: "order axioms")[
  For all $a,b,c in RR$:
  #set enum(numbering: "(O1)", start: 1)
  + Exactly one of $a < b$, $a = b$, $a > b$ holds.
  + If $a < b$ and $b < c$ then $a < c$.
  + If $a < b$ then $a + c < b + c$.
  + If $a < b$ and $c > 0$ then $a c < b c$.
]

#proposition(title: "multiplying by a negative flips the inequality")[
  If $a < b$ and $c < 0$ then $a c > b c$.
]

#proof[
  $c < 0$ means $-c > 0$ (add $-c$ to both sides of $c < 0$ using (O3)). By
  (O4), $a(-c) < b(-c)$, i.e. $-a c < -b c$. Adding $a c + b c$ to both sides
  gives $b c < a c$.
]

That is the exception, and it is where nearly all inequality errors come from.
The other common trap:

#warning(title: "never cross-multiply an inequality blindly")[
  From $1/x < 2$ you may *not* conclude $1 < 2x$. That step multiplies by $x$,
  whose sign is unknown. If $x > 0$ it is valid and gives $x > 1 slash 2$; if
  $x < 0$ the inequality flips and $1 slash x$ is negative, hence automatically
  less than $2$, so every negative $x$ works. The true solution set is
  $(-infinity, 0) union (1 slash 2, infinity)$ --- and the naive answer misses
  half of it.

  The reliable method is *sign analysis*: move everything to one side, factor,
  find where each factor changes sign, and tabulate.
]

#theorem(title: "AM--GM for two terms")[
  For $a, b >= 0$: $ (a + b)/2 >= sqrt(a b), $ with equality iff $a = b$.
]

#proof[
  $(sqrt(a) - sqrt(b))^2 >= 0$ because squares of reals are nonnegative.
  Expanding: $a - 2 sqrt(a b) + b >= 0$, so $a + b >= 2 sqrt(a b)$. Equality
  holds exactly when $sqrt(a) - sqrt(b) = 0$, i.e. $a = b$.
]

The "prove it is a square" move is the most common way to establish an
inequality, and it generalises: in Chapter 24 the Cauchy--Schwarz inequality
is proved by observing that a certain quadratic is a square and therefore has
non-positive discriminant.

== Summation notation

#definition(title: "sigma notation")[
  $ sum_(i = m)^(n) f(i) = f(m) + f(m+1) + dots.c + f(n). $
  If $n < m$ the sum is *empty* and equals $0$ by convention. The analogous
  product $product$ has empty value $1$.
]

This is a `for` loop with an accumulator, and the conventions match the ones
you would choose. The empty-sum convention exists so that
$sum_(i=m)^(n) + sum_(i=n+1)^(p) = sum_(i=m)^(p)$ holds without special cases
--- exactly the reason your slice indices are half-open.

Three identities, each proved once and used forever:

#theorem(title: "the three standard sums")[
  For $n >= 1$ and $r != 1$:
  $
  sum_(i=1)^n i &= (n(n+1))/2 \
  sum_(i=1)^n i^2 &= (n(n+1)(2n+1))/6 \
  sum_(i=0)^(n-1) r^i &= (r^n - 1)/(r - 1)
  $
]

#proof[
  *First.* Write the sum forwards and backwards and add termwise:
  $
  S &= 1 + 2 + dots.c + n \
  S &= n + (n-1) + dots.c + 1
  $
  Each of the $n$ columns sums to $n+1$, so $2S = n(n+1)$.

  *Second.* Telescope $sum_(i=1)^n [(i+1)^3 - i^3]$. On the one hand it
  collapses to $(n+1)^3 - 1$. On the other, expanding the bracket gives
  $3i^2 + 3i + 1$, so the sum is $3 sum i^2 + 3 sum i + n$. Equate:
  $ 3 sum i^2 = (n+1)^3 - 1 - 3 (n(n+1))/2 - n, $
  and simplifying the right side gives $n(n+1)(2n+1) slash 2$. Divide by 3.

  *Third.* This is the difference-of-powers proposition with $a = r$, $b = 1$.
]

#intuition(title: "the perturbation trick")[
  The second proof is worth internalising as a general method. To find
  $sum i^k$, telescope $sum [(i+1)^(k+1) - i^(k+1)]$: the left side collapses,
  the right side expands into $sum i^k$ plus lower-order sums you already know.
  That gives every power sum by recursion, and it is the discrete ancestor of
  integration by parts.
]

== Exercises

#exercise[
  Using only the field axioms (F1)--(F5), prove that the additive identity is
  unique: if $a + z = a$ for every $a$, then $z = 0$.
]

#exercise[
  Solve $sqrt(2x + 3) = x$, being explicit about which step is one-way and
  which candidate roots must be checked and why.
]

#exercise[
  Complete the square on $2x^2 - 12 x + 7$ to write it in the form
  $a(x - h)^2 + k$. Read off the minimum value of the expression and the $x$
  at which it occurs, without using calculus.
]

#exercise[
  Prove that $sum_(i=1)^n i^3 = ( (n(n+1))/2 )^2$ --- that is, the sum of the
  first $n$ cubes is the square of the sum of the first $n$ integers. Use the
  perturbation trick.
]

#exercise[
  Decompose $ (5x - 4)/(x^2 - x - 6) $ into partial fractions.
]

#exercise[
  Solve the inequality $ (x - 1)/(x + 2) >= 1 $ by sign analysis. State the
  solution set as a union of intervals, and say explicitly what goes wrong if
  you instead multiply both sides by $x + 2$.
]

#exercise[
  Prove that for all real $x$ and $y$, $x^2 + y^2 >= 2 x y$, and identify when
  equality holds. Then deduce AM--GM for two nonnegative numbers from it by a
  substitution.
]

#exercise[
  A polynomial $p$ of degree $3$ satisfies $p(0) = p(1) = p(2) = p(3) = 0$.
  What is $p$? Justify your answer with the corollary to the factor theorem.
]
