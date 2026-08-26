#import "../lib.typ": *

= Sets, Relations, and Structure

== Sets

#definition(title: "set")[
  A *set* is an unordered collection of distinct objects, called its
  *elements*. We write $x in S$ for "$x$ is an element of $S$" and
  $x in.not S$ otherwise.

  Two sets are equal exactly when they have the same elements:
  $ S = T quad "iff" quad forall x : (x in S arrow.l.r.double x in T). $
]

Unordered and distinct. ${1,2,3} = {3,1,2} = {1,1,2,3}$ --- all the same set.
This is a `HashSet`, not a `Vec`, and equality is by contents.

Ways to write a set down:

- *Roster:* ${2, 3, 5, 7}$.
- *Set-builder:* ${x in ZZ : x^2 < 10}$, read "the $x$ in $ZZ$ such that...".
  Some authors use $|$ instead of $:$.
- *Image:* ${x^2 : x in NN}$, the set of all values of an expression.

The empty set is $emptyset = {}$. Note ${emptyset}$ is *not* empty --- it is a
set containing one element, which happens to be the empty set. The distinction
between a box and an empty box is exactly the distinction between `None` and
`Some(None)`.

#definition(title: "subset")[
  $S subset.eq T$ means every element of $S$ is in $T$. If additionally
  $S != T$ we write $S subset.neq T$ and say *proper subset*.
]

#intuition(title: "how to prove two sets are equal")[
  Almost always by *double inclusion*: show $S subset.eq T$ and
  $T subset.eq S$.

  And to show $S subset.eq T$, the ritual is fixed: *let $x in S$ be
  arbitrary; ... ; therefore $x in T$*. If you find yourself stuck on a set
  identity, write that first line down and the rest usually follows.
]

=== Operations

$
S union T &= {x : x in S or x in T} &quad& "(union)" \
S inter T &= {x : x in S and x in T} &quad& "(intersection)" \
S without T &= {x : x in S and x in.not T} &quad& "(difference)" \
overline(S) &= U without S &quad& "(complement, relative to a universe " U ")" \
S times T &= {(s,t) : s in S, t in T} &quad& "(Cartesian product)"
$

Note $S times T$ is a set of *ordered pairs*, and ordered pairs are ordered:
$(1,2) != (2,1)$. The Cartesian product is where tuples come from, and
$RR^n = RR times dots.c times RR$ is where Part IV lives.

#theorem(title: "De Morgan's laws")[
  $ overline(S union T) = overline(S) inter overline(T), quad overline(S inter T) = overline(S) union overline(T). $
]

#proof[
  We prove the first by double inclusion.

  ($subset.eq$) Let $x in overline(S union T)$. Then $x in.not S union T$, so
  it is not the case that ($x in S$ or $x in T$). By the logical De Morgan law
  of Chapter 7, $x in.not S$ and $x in.not T$. Hence
  $x in overline(S)$ and $x in overline(T)$, i.e. $x in overline(S) inter overline(T)$.

  ($supset.eq$) Every step above is an "iff", so reading them upwards gives
  the reverse inclusion.

  The second law follows by applying the first to $overline(S)$ and
  $overline(T)$ and complementing.
]

You know this law as `!(a || b) == !a && !b`. It is the same theorem; sets and
booleans are two faces of the same algebra (a *Boolean algebra*), with
$union$ as `or`, $inter$ as `and`, and complement as `not`.

#definition(title: "power set")[
  $cal(P)(S)$ is the set of all subsets of $S$.
]

#proposition[
  If $abs(S) = n$ then $abs(cal(P)(S)) = 2^n$.
]

#proof[
  A subset is determined by a yes/no decision for each of the $n$ elements:
  in or out. That is a function from $S$ to ${0,1\}$, and there are $2^n$ of
  them (Chapter 3).

  Concretely, subsets of an $n$-element set correspond exactly to $n$-bit
  bitmasks --- which is how you should implement them when $n <= 64$.
]

Cantor's theorem says $abs(cal(P)(S)) > abs(S)$ for *every* set, finite or
not, and its proof is the diagonal argument of Chapter 1 in general form. So
there is no largest infinity.

== Relations

#definition(title: "relation")[
  A *binary relation* from $A$ to $B$ is a subset $R subset.eq A times B$. We
  write $a R b$ for $(a,b) in R$. A relation *on* $A$ is a relation from $A$
  to $A$.
]

That is deliberately minimal: a relation is just a set of pairs, i.e. a table
of which things are related to which. Equality, $<$, "divides", "is reachable
from", and every foreign key in your database are relations.

#definition(title: "properties a relation on $A$ may have")[
  - *Reflexive:* $a R a$ for all $a$.
  - *Symmetric:* $a R b$ implies $b R a$.
  - *Antisymmetric:* $a R b$ and $b R a$ together imply $a = b$.
  - *Transitive:* $a R b$ and $b R c$ imply $a R c$.
]

Two combinations of these matter enormously.

=== Equivalence relations

#definition(title: "equivalence relation")[
  Reflexive, symmetric, and transitive. Written $tilde$. The *equivalence
  class* of $a$ is
  $ [a] = {x in A : x tilde a}. $
]

#theorem(title: "equivalence classes partition the set")[
  Let $tilde$ be an equivalence relation on $A$. Then the equivalence classes
  are nonempty, they cover $A$, and any two of them are either identical or
  disjoint.
]

#proof[
  *Nonempty and covering:* $a in [a]$ by reflexivity, so every element is in
  its own class.

  *Identical or disjoint:* suppose $[a] inter [b] != emptyset$; take
  $c$ in both. Then $c tilde a$ and $c tilde b$. Let $x in [a]$ be arbitrary,
  so $x tilde a$. By symmetry $a tilde c$, and by transitivity (twice)
  $x tilde c$ then $x tilde b$. So $x in [b]$, giving $[a] subset.eq [b]$. By
  the same argument with $a$ and $b$ swapped, $[b] subset.eq [a]$. Hence
  $[a] = [b]$.
]

#intuition(title: "equivalence relations are 'equal for my purposes'")[
  An equivalence relation is a coarser notion of sameness than identity. It
  says: *these objects differ, but not in any way I care about right now.*

  You have implemented this repeatedly:

  - Case-insensitive string comparison. The classes are ${"Cat", "CAT", "cat", dots}$.
  - `equals()` and `hashCode()` in Java --- and the contract between them is
    exactly "equal objects land in the same class".
  - Modular arithmetic: $a tilde b$ iff $n divides (a - b)$. The classes are
    the residues mod $n$ (Chapter 12).
  - Fractions: $(p,q) tilde (r,s)$ iff $p s = q r$. The classes are the
    rational numbers (Chapter 1).

  The general move --- *pass to the quotient* --- is: build the set whose
  elements are the classes, and now the things you did not care about are
  literally gone. That is what $QQ$ and $ZZ slash n ZZ$ are.
]

=== Partial and total orders

#definition(title: "partial order")[
  Reflexive, *antisymmetric*, and transitive. Written $<=$. A set with a
  partial order is a *poset*.

  If additionally any two elements are comparable ($a <= b$ or $b <= a$ for
  all $a, b$), it is a *total order*.
]

$<=$ on $RR$ is total. Subset inclusion on $cal(P)(S)$ is partial and not
total: ${1}$ and ${2}$ are incomparable. Divisibility on $NN$ is partial: $3$
and $5$ are incomparable.

#example(title: "topological sort is exactly this")[
  A dependency graph defines a partial order: task $a <= b$ if $a$ must finish
  before $b$. Building the project requires a *total* order compatible with
  it --- a linear sequence in which to run the tasks.

  The theorem that this is always possible for a finite poset is called
  *linear extension*, and the algorithm that produces it is topological sort.
  A cycle in the dependency graph means antisymmetry fails, so you never had a
  partial order, and the sort correctly reports failure.
]

== Functions, revisited

Chapter 3 defined a function informally. Now we can say it exactly.

#definition(title: "function, formally")[
  A function $f : A -> B$ is a relation $f subset.eq A times B$ such that for
  every $a in A$ there is *exactly one* $b in B$ with $(a,b) in f$.
]

So a function is a special kind of relation --- one that is total (defined
everywhere) and single-valued. The graph of Chapter 3 was not a picture of the
function; it *was* the function.

#definition(title: "image and preimage")[
  For $f : A -> B$, $S subset.eq A$, $T subset.eq B$:
  $ f(S) = {f(x) : x in S}, quad f^(-1)(T) = {x in A : f(x) in T}. $
]

#warning(title: "$f^(-1)$ is overloaded and the two meanings differ")[
  $f^(-1)(T)$ --- the *preimage* of a set --- always exists, for any function
  whatsoever. $f^(-1)(b)$ --- the *inverse function* applied to a point ---
  exists only when $f$ is bijective.

  Notation being reused for two different things is a real hazard here. The
  preimage of a set is the more general notion; think of it as a database
  query ("all rows whose `f` column lies in $T$"), which always makes sense
  even when the mapping is many-to-one.
]

Preimages behave better than images. For any $f$:
$ f^(-1)(S union T) = f^(-1)(S) union f^(-1)(T), quad f^(-1)(S inter T) = f^(-1)(S) inter f^(-1)(T). $
But images only satisfy $f(S inter T) subset.eq f(S) inter f(T)$, and the
inclusion can be strict --- take $f(x) = x^2$, $S = {1}$, $T = {-1}$: the left
side is empty, the right side is ${1}$. Equality for all $S,T$ holds precisely
when $f$ is injective.

== Cardinality

#definition(title: "same size")[
  $abs(A) = abs(B)$ means there exists a bijection $A -> B$.
]

For finite sets this is the ordinary notion. For infinite sets it produces the
results of Chapter 1: $abs(NN) = abs(ZZ) = abs(QQ)$, but $abs(RR) > abs(NN)$.

#theorem(title: "inclusion--exclusion, two and three sets")[
  $
  abs(A union B) &= abs(A) + abs(B) - abs(A inter B) \
  abs(A union B union C) &= abs(A) + abs(B) + abs(C) - abs(A inter B) - abs(A inter C) - abs(B inter C) + abs(A inter B inter C)
  $
]

#proof[
  For the first: adding $abs(A)$ and $abs(B)$ counts every element of
  $A union B$ once, except those in both, which are counted twice. Subtracting
  $abs(A inter B)$ corrects each of those by one.

  For the second, track an element in exactly $k$ of the three sets. It is
  counted $binom(k,1)$ times by the singles, $binom(k,2)$ by the pairs, and
  $binom(k,3)$ by the triple, for a net count of
  $binom(k,1) - binom(k,2) + binom(k,3)$. This is $1$ for $k = 1, 2, 3$
  (check: $1$; $2-1 = 1$; $3-3+1 = 1$) and $0$ for $k = 0$. So each element of
  the union is counted exactly once.
]

The general form, for $n$ sets, alternates signs over all $2^n - 1$ nonempty
intersections. Chapter 9 uses it to count derangements.

== Algebraic structures, briefly

You will meet these names. They are worth five minutes now so they are not
frightening later.

#definition(title: "a small zoo")[
  A set $G$ with an operation $star$ is a:

  - *Monoid* if $star$ is associative and there is an identity element.
  - *Group* if additionally every element has an inverse.
  - *Abelian group* if additionally $star$ is commutative.

  A set with two operations $(+, times)$ is a:

  - *Ring* if it is an abelian group under $+$, a monoid under $times$, and
    $times$ distributes over $+$.
  - *Field* if additionally every nonzero element has a multiplicative
    inverse.
]

#example(title: "you already use monoids")[
  Every `reduce`/`fold` with an identity is a monoid: `(+, 0)` on numbers,
  `(*, 1)`, `(concat, "")` on strings, `(max, -infinity)`, `(union, {})`.

  Associativity is exactly the condition that lets you split the reduction
  across threads and combine the partial results in any grouping. The identity
  is what you seed an empty partition with. When a library requires your
  combiner to be "associative with an identity", it is requiring a monoid, and
  the failure mode when you lie about it is nondeterministic output.

  Chapter 1's warning about floating-point addition now has a crisp statement:
  `(float, +, 0.0)` is *not* a monoid, because $+$ is not associative on
  floats. That is why parallel float reductions are not reproducible.
]

Where the others show up: $ZZ$ is a ring; $QQ$, $RR$, $CC$ are fields;
invertible $n times n$ matrices form a group under multiplication (non-abelian
--- Chapter 20); rotations form a group; $ZZ slash n ZZ$ is a ring, and a
field exactly when $n$ is prime (Chapter 12).

== Exercises

#exercise[
  Prove by double inclusion that $A without (B union C) = (A without B) inter (A without C)$.
]

#exercise[
  List all elements of $cal(P)({a,b,c})$ and verify there are $2^3$ of them.
  Then describe the natural bijection between these subsets and the integers
  $0$ through $7$.
]

#exercise[
  For each relation on $ZZ$, determine which of reflexive, symmetric,
  antisymmetric, transitive it has: (a) $a R b$ iff $a <= b$; (b) $a R b$ iff
  $a divides b$; (c) $a R b$ iff $a + b$ is even; (d) $a R b$ iff $a != b$.
]

#exercise[
  Show that "has the same remainder mod $5$" is an equivalence relation on
  $ZZ$, and describe its equivalence classes explicitly.
]

#exercise[
  Give a function $f$ and sets $S, T$ for which $f(S inter T)$ is a proper
  subset of $f(S) inter f(T)$. Then prove that if $f$ is injective, equality
  always holds.
]

#exercise[
  In a class of $100$ students, $60$ take mathematics, $45$ take physics, and
  $20$ take both. How many take neither? Use inclusion--exclusion and state
  what universe you are complementing against.
]

#exercise[
  Is $(RR, -)$ (the reals under subtraction) a monoid? Check each axiom and
  say precisely which one fails, if any.
]

#exercise[
  Prove that a relation which is symmetric and transitive, but not reflexive,
  is possible --- give an example --- and explain why the "obvious" argument
  that symmetry plus transitivity implies reflexivity is wrong.
]
