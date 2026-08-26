#import "../lib.typ": *

= Functions

== The definition, and why it is so fussy

You already have a working notion of "function": something you call with an
argument and get a result. That intuition is right, and mathematics makes it
precise in a way that is worth absorbing, because the precision buys you
things later.

#definition(title: "function")[
  A *function* $f$ from a set $A$ to a set $B$, written $f : A -> B$, assigns
  to *each* element $a in A$ *exactly one* element $f(a) in B$.

  $A$ is the *domain*, $B$ is the *codomain*, and
  $ "range"(f) = { f(a) : a in A } subset.eq B $
  is the *range* (or image): the set of values actually attained.
]

Three clauses in there do real work.

*"Each".* $f$ must be defined on every element of $A$. A "function" that
throws on some inputs is not a function on that domain --- it is a function on
a smaller domain. This is why mathematicians fuss about domains: $f(x) = 1/x$
is not a function $RR -> RR$; it is a function $RR without {0} -> RR$.

*"Exactly one".* No multi-valued results. This is why $sqrt(x)$ is *defined*
to be the nonnegative root: if it returned both, it would not be a function.
It is why we write $x = plus.minus sqrt(c)$ rather than pretending the square
root is two-valued.

*Codomain versus range.* The codomain is declared; the range is discovered.
This is exactly the difference between a function's declared return type and
the set of values it can actually produce. `fn f(x: i32) -> i32 { x * x }` has
codomain `i32` and range "the perfect squares". The distinction is not
pedantry; whether a function is *onto* depends entirely on which codomain you
declared.

#intuition(title: "a function is a lookup table you may not be able to store")[
  The set-theoretic definition of a function is literally its table of pairs:
  $f$ *is* the set ${(a, f(a)) : a in A}$. That set is called the *graph*.

  So a function is not a formula. A formula is one way to *specify* a
  function, the way source code is one way to specify a behaviour. Two
  different formulas can define the same function (they are then equal, as
  functions), and plenty of functions have no formula at all.
]

#warning(title: "$f$ and $f(x)$ are different things")[
  $f$ is the function. $f(x)$ is the *value* of the function at $x$ --- a
  number, not a function. Writing "the function $f(x) = x^2$" is a universal
  and harmless abuse of notation, but when you get to Chapter 26 and start
  differentiating with respect to functions, the distinction stops being
  cosmetic. In programming terms: `f` versus `f(x)`.
]

== Composition

#definition(title: "composition")[
  Given $f : A -> B$ and $g : B -> C$, their *composition*
  $g compose f : A -> C$ is defined by
  $ (g compose f)(x) = g(f(x)). $
]

Note the order: $g compose f$ means "$f$ first". This reads backwards and
everyone finds it irritating; it is that way so that the notation
$g(f(x))$ matches.

#proposition(title: "composition is associative")[
  $(h compose g) compose f = h compose (g compose f)$, whenever the
  compositions are defined.
]

#proof[
  Two functions are equal iff they have the same domain and codomain and agree
  at every point. Both sides go $A -> D$. And for any $x in A$,
  $ ((h compose g) compose f)(x) = (h compose g)(f(x)) = h(g(f(x))), $
  $ (h compose (g compose f))(x) = h((g compose f)(x)) = h(g(f(x))). $
  They agree everywhere, so they are equal.
]

That proof looks trivial and is included on purpose: it is the template for
every "these two functions are the same" argument, and it is the reason
function composition forms a *monoid*, which is why you can pipeline
transformations in any grouping you like.

== Injective, surjective, bijective

These three words describe how a function can fail to be invertible, and they
are worth getting exactly right because they recur in linear algebra as
statements about matrices.

#definition(title: "injective, surjective, bijective")[
  $f : A -> B$ is

  - *injective* (one-to-one) if $f(a_1) = f(a_2)$ implies $a_1 = a_2$.
    Equivalently: distinct inputs give distinct outputs; no collisions.
  - *surjective* (onto) if for every $b in B$ there is some $a in A$ with
    $f(a) = b$. Equivalently: the range is the whole codomain.
  - *bijective* if both.
]

#example(title: "the four cases, concretely")[
  - $f : RR -> RR$, $f(x) = x^2$. Not injective ($f(2) = f(-2)$); not
    surjective (nothing maps to $-1$).
  - $f : RR -> RR$, $f(x) = x^3$. Both. Bijective.
  - $f : RR -> [0, infinity)$, $f(x) = x^2$. Surjective now, still not
    injective.
  - $f : [0,infinity) -> RR$, $f(x) = x^2$. Injective now, not surjective.

  Same formula, four different functions, because the domain and codomain are
  part of the function. This is exactly the point of declaring them.
]

#theorem(title: "invertibility")[
  $f : A -> B$ has a two-sided inverse $f^(-1) : B -> A$ (meaning
  $f^(-1) compose f = "id"_A$ and $f compose f^(-1) = "id"_B$) if and only if
  $f$ is bijective.
]

#proof[
  ($arrow.r.double$) Suppose $f^(-1)$ exists. If $f(a_1) = f(a_2)$, apply
  $f^(-1)$ to both sides: $a_1 = a_2$, so $f$ is injective. Given $b in B$,
  the element $a = f^(-1)(b)$ satisfies $f(a) = b$, so $f$ is surjective.

  ($arrow.l.double$) Suppose $f$ is bijective. For each $b in B$, surjectivity
  says there is at least one $a$ with $f(a) = b$, and injectivity says there
  is at most one. So there is exactly one; define $f^(-1)(b)$ to be it. That
  definition is legitimate precisely because "exactly one" holds, and the two
  composition identities are immediate.
]

#intuition(title: "the same three words in linear algebra")[
  Keep these. In Part IV, for a matrix $A$ viewed as a function
  $x arrow.bar A x$:

  - injective $arrow.l.r$ the null space is ${0}$ $arrow.l.r$ columns are
    linearly independent;
  - surjective $arrow.l.r$ the columns span the whole target space;
  - bijective $arrow.l.r$ $A$ is invertible $arrow.l.r$ $det A != 0$.

  Linear algebra is largely the study of what these three conditions look like
  when the function happens to be linear.
]

== Graphs and transformations

The *graph* of $f : RR -> RR$ is the set of points $(x, f(x))$ in the plane.
Reading a graph fluently is a genuine skill and it is mostly about knowing how
five modifications move it.

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 7pt,
    align: (left, left, left),
    stroke: 0.4pt + luma(180),
    table.header([*Expression*], [*Effect on the graph*], [*Watch out*]),
    [$f(x) + c$], [shift up by $c$], [outside the function: vertical],
    [$f(x + c)$], [shift *left* by $c$], [inside: horizontal, and backwards],
    [$a f(x)$], [stretch vertically by $a$], [$a < 0$ also flips over the $x$-axis],
    [$f(a x)$], [*compress* horizontally by $a$], [inside: backwards again],
    [$f(-x)$], [reflect in the $y$-axis], [],
    [$-f(x)$], [reflect in the $x$-axis], [],
  )
]

#intuition(title: "why inside-the-function transformations run backwards")[
  This trips up everyone once. Consider $g(x) = f(x - 3)$. To find $g$'s value
  at $x = 10$, you ask $f$ for its value at $7$. So whatever $f$ was doing at
  $7$ now happens at $10$: the picture has moved *right*, even though the
  formula says minus.

  The rule: transformations applied to the *output* do what they say;
  transformations applied to the *input* do the opposite, because you are
  changing where you have to stand to see the same value.
]

#definition(title: "even and odd")[
  $f$ is *even* if $f(-x) = f(x)$ for all $x$ (symmetric about the $y$-axis),
  and *odd* if $f(-x) = -f(x)$ (symmetric under a $180 degree$ rotation about
  the origin).
]

$cos$ and $x^2$ are even; $sin$ and $x^3$ are odd; $e^x$ is neither. Every
function on $RR$ splits uniquely into an even part and an odd part:
$ f(x) = underbrace((f(x) + f(-x))/2, "even") + underbrace((f(x) - f(-x))/2, "odd"). $
This decomposition is the baby version of a Fourier transform, and the reason
$integral_(-a)^(a)$ of an odd function is always $0$.

== Monotonicity and boundedness

#definition(title: "monotone")[
  $f$ is *increasing* on an interval if $x_1 < x_2$ implies
  $f(x_1) <= f(x_2)$, and *strictly increasing* if the conclusion is
  $f(x_1) < f(x_2)$. Decreasing is the mirror image. *Monotone* means one or
  the other.
]

#proposition[
  A strictly monotone function is injective.
]

#proof[
  Let $f$ be strictly increasing and suppose $a_1 != a_2$. Without loss of
  generality $a_1 < a_2$ (otherwise swap names). Then $f(a_1) < f(a_2)$, so in
  particular $f(a_1) != f(a_2)$. The decreasing case is identical with the
  inequality reversed.
]

This is the everyday test for invertibility, and it is why "apply a strictly
increasing function to both sides" was listed as a *safe* operation on
equations in Chapter 2: strictly increasing means injective means the step is
reversible.

#definition(title: "bounded")[
  $f$ is *bounded above* on $S$ if there is $M$ with $f(x) <= M$ for all
  $x in S$; bounded below similarly; *bounded* if both, equivalently if
  $abs(f(x)) <= M$ for some $M$.
]

== The functions you must know on sight

*Polynomials.* Defined in Chapter 2. Continuous and smooth everywhere. Degree
$n$ behaviour at large $abs(x)$ is dominated by the leading term $a_n x^n$;
this is the entire content of "big-O of a polynomial is its leading term".

*Rational functions* $p(x) slash q(x)$. Undefined where $q = 0$. Near such a
point the graph typically shoots off to $plus.minus infinity$ --- a *vertical
asymptote*. As $abs(x) -> infinity$, the behaviour is governed by comparing
$deg p$ and $deg q$:
$
deg p < deg q &quad arrow.r.double quad y -> 0, \
deg p = deg q &quad arrow.r.double quad y -> a_n slash b_m "(horizontal asymptote)", \
deg p > deg q &quad arrow.r.double quad abs(y) -> infinity.
$

*Piecewise functions*, including $abs(x)$, $floor(x)$, $ceil(x)$ and the
sign function. These are where continuity and differentiability go to die, and
therefore where the interesting counterexamples live. $abs(x)$ is continuous
everywhere but not differentiable at $0$ --- which is exactly why ReLU
networks need a subgradient convention (Chapter 36).

*The exponential and logarithm*, Chapter 4. *The trigonometric functions*,
Chapter 5.

== Sequences are functions too

#definition(title: "sequence")[
  A *sequence* of real numbers is a function $a : NN -> RR$. We write $a_n$
  rather than $a(n)$, and denote the whole sequence by $(a_n)_(n=0)^infinity$
  or just $(a_n)$.
]

That is not a reframing for its own sake. Once a sequence is a function, all
the vocabulary transfers: a sequence can be increasing, bounded, injective. And
the central theorem of Chapter 13 --- every bounded monotone sequence
converges --- becomes a statement about functions on $NN$, provable directly
from the completeness axiom of Chapter 1.

#example(title: "a recurrence is a recursively defined function")[
  The Fibonacci sequence $F_0 = 0$, $F_1 = 1$, $F_n = F_(n-1) + F_(n-2)$ is a
  function $NN -> NN$ specified by recursion rather than by a formula. That it
  *is* a well-defined function --- that the recursion determines exactly one
  value at each $n$ --- is itself a theorem, and its proof is strong induction
  (Chapter 7). Chapter 11 finds the closed form.
]

== Functions as values

One place where your instincts are *ahead* of a standard maths course.

In mathematics, functions are objects. You can form sets of them, add them,
compose them, and --- crucially --- feed them to other functions. The set of
all functions $A -> B$ is written $B^A$, and that notation is not a joke: if
$abs(A) = m$ and $abs(B) = n$ then there are exactly $n^m$ such functions
(Chapter 9).

An *operator* is a function whose input is a function. You know several:

- differentiation, $D(f) = f'$, takes a function and returns a function
  (Chapter 14);
- definite integration, $I(f) = integral_a^b f$, takes a function and returns
  a number (Chapter 16);
- in linear algebra, a matrix *is* a function, and matrix multiplication *is*
  composition (Chapter 20).

#intuition(title: "the punchline of Part IV, stated early")[
  Here is the whole of linear algebra in one sentence, so it is in your head
  before you get there.

  The set of functions $RR^n -> RR^m$ is unmanageably huge. Restrict to those
  satisfying $f(x + y) = f(x) + f(y)$ and $f(c x) = c f(x)$ --- the *linear*
  ones --- and something remarkable happens: every such function is completely
  determined by what it does to $n$ basis vectors, so it can be written down
  as an $m times n$ grid of numbers. That grid is a matrix.

  Matrices are not tables of data that happen to have a weird multiplication
  rule. They are a *finite encoding of a function*, and the multiplication
  rule is composition. Everything else in Part IV follows from that.
]

== Exercises

#exercise[
  For each function, state whether it is injective, surjective, both, or
  neither, *as declared*: (a) $f : ZZ -> ZZ$, $f(n) = 2n$; (b)
  $f : ZZ -> ZZ$, $f(n) = floor(n slash 2)$; (c) $f : RR -> RR$,
  $f(x) = x^3 - x$; (d) $f : RR -> (0, infinity)$, $f(x) = e^x$ (take the
  usual properties of $e^x$ for granted).
]

#exercise[
  Prove: if $g compose f$ is injective, then $f$ is injective. Then give an
  example showing $g$ need not be.
]

#exercise[
  Let $f(x) = 2x + 3$ and $g(x) = x^2$. Compute $f compose g$ and
  $g compose f$ and confirm they differ. Find every $x$ at which they agree.
]

#exercise[
  Describe, in words and in order, the sequence of transformations taking the
  graph of $y = f(x)$ to the graph of $y = -3 f(2x - 4) + 1$. Be careful about
  the order of the horizontal ones.
]

#exercise[
  Decompose $f(x) = e^x$ into its even and odd parts using the formula in the
  text. (The two pieces have names: they are $cosh x$ and $sinh x$.)
]

#exercise[
  Let $A$ be a set with $m$ elements and $B$ a set with $n$ elements. Explain
  carefully why there are exactly $n^m$ functions $A -> B$, and determine how
  many of them are injective (your answer will be a product).
]

#exercise[
  Find the domain, any vertical asymptotes, and the behaviour as
  $x -> plus.minus infinity$ of
  $ f(x) = (2x^2 - 3)/(x^2 - 4). $
]
