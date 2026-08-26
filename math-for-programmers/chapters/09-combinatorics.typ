#import "../lib.typ": *

= Counting

== Why counting is hard

Counting sounds like the easiest topic in mathematics and it is one of the
most error-prone, because the errors are silent. A wrong count looks exactly
like a right count. There is no type checker.

The discipline that saves you is always the same: *say precisely what you are
counting, and give a rule that pairs each thing you want to count with exactly
one of your count's terms.* When a combinatorial argument goes wrong it is
almost always because the pairing double-counts or misses.

== The two basic rules

#theorem(title: "sum rule and product rule")[
  If $A$ and $B$ are *disjoint* finite sets,
  $ abs(A union B) = abs(A) + abs(B). $
  For any finite sets,
  $ abs(A times B) = abs(A) dot abs(B). $
]

Restated as decisions --- which is how you will use them:

- If a thing can be built in one of several *mutually exclusive* ways, add the
  counts.
- If building a thing requires several *independent* choices in sequence,
  multiply the counts.

The word "disjoint" and the word "independent" are the whole game.

#example(title: "counting passwords")[
  How many strings of length exactly $8$ over a $62$-character alphabet, with
  at least one digit ($10$ of the characters are digits)?

  Direct counting means splitting by how many digits appear --- eight disjoint
  cases, all awkward. Instead count the complement:
  $ 62^8 - 52^8, $
  total strings minus those with no digit at all. This is
  *complementary counting*, and it is the first thing to try when the phrase
  "at least one" appears.
]

== Permutations

#definition(title: "factorial and falling factorial")[
  $ n! = n (n-1)(n-2) dots.c 2 dot 1, quad 0! = 1. $
  The number of ordered selections of $k$ items from $n$ distinct items,
  without repetition, is
  $ P(n,k) = n (n-1) dots.c (n - k + 1) = (n!)/((n-k)!). $
]

$n!$ counts the orderings of $n$ distinct objects: $n$ choices for the first
position, $n-1$ for the second (one is used up), and so on. That is the
product rule applied $n$ times.

#intuition(title: "why $0! = 1$")[
  Not a convention pulled from nowhere. Two reasons, both forcing it.

  *Combinatorial:* $n!$ counts arrangements of $n$ objects. There is exactly
  one way to arrange nothing --- the empty arrangement. So $0! = 1$.

  *Algebraic:* we want $n! = n dot (n-1)!$ to hold for all $n >= 1$. At
  $n = 1$: $1 = 1 dot 0!$, forcing $0! = 1$.

  Same pattern as $a^0 = 1$ in Chapter 4 and the empty sum being $0$: the
  edge-case value is whatever makes the general law hold without exceptions.
  Getting these right is why your recursive base cases work.
]

== Combinations

#definition(title: "binomial coefficient")[
  $ binom(n,k) = (n!)/(k! (n-k)!) $
  is the number of $k$-element *subsets* of an $n$-element set. Read "$n$
  choose $k$". It is $0$ when $k < 0$ or $k > n$.
]

#proof[
  Count ordered selections two ways. There are $P(n,k) = n! slash (n-k)!$ of
  them. On the other hand, every ordered selection is obtained by first
  choosing *which* $k$ elements (some number $C$ of ways) and then ordering
  them ($k!$ ways). By the product rule $P(n,k) = C dot k!$, so
  $C = n! slash (k!(n-k)!)$.
]

#intuition(title: "the difference between permutation and combination")[
  One question: *does order matter?*

  Podium finishes in a race: order matters, use $P(n,k)$. A hand of cards:
  order does not matter, use $binom(n,k)$. A committee: combination. A
  committee with named roles: permutation.

  If you can state your objects concretely enough to answer that one question,
  you have solved most counting problems.
]

Identities worth knowing, each with a *counting* proof rather than an
algebraic one --- counting proofs are shorter and they explain.

#proposition(title: "symmetry")[
  $binom(n,k) = binom(n, n-k)$.
]

#proof[
  Choosing the $k$ elements to include is the same act as choosing the $n-k$
  to exclude. The two sides count the same objects via that bijection.
]

#proposition(title: "Pascal's rule")[
  $binom(n,k) = binom(n-1, k-1) + binom(n-1, k)$.
]

#proof[
  Fix a particular element $x$ of the $n$-set. Every $k$-subset either
  contains $x$ or does not --- disjoint, exhaustive.

  Those containing $x$: choose the remaining $k-1$ from the other $n-1$
  elements, so $binom(n-1,k-1)$ of them.

  Those not containing $x$: choose all $k$ from the other $n-1$, so
  $binom(n-1,k)$.

  Add by the sum rule.
]

That is Pascal's triangle, and it is also the recurrence you would write for a
memoised `choose(n,k)` --- with the counting proof serving as the correctness
argument.

#theorem(title: "binomial theorem")[
  $ (x + y)^n = sum_(k=0)^n binom(n,k) x^k y^(n-k). $
]

#proof[
  Expand $(x+y)(x+y) dots.c (x+y)$ with $n$ factors by distributing
  completely. Every term of the expansion is formed by picking either $x$ or
  $y$ from each factor and multiplying. A term ends up as $x^k y^(n-k)$
  precisely when you picked $x$ from exactly $k$ of the $n$ factors --- and
  the number of ways to choose *which* $k$ factors is $binom(n,k)$.

  Collecting like terms gives the stated sum.
]

Setting $x = y = 1$ gives $sum_k binom(n,k) = 2^n$: the total number of
subsets, agreeing with Chapter 8. Setting $x = -1$, $y = 1$ gives
$sum_k (-1)^k binom(n,k) = 0$ for $n >= 1$: a set has equally many
even-sized and odd-sized subsets.

== Counting with repetition

Four cases, and the whole subject of elementary counting is knowing which one
you are in.

#align(center)[
  #table(
    columns: 3,
    inset: 8pt,
    align: (left, center, center),
    stroke: 0.4pt + luma(180),
    table.header([], [*Order matters*], [*Order does not*]),
    [*Repetition allowed*], [$n^k$], [$binom(n + k - 1, k)$],
    [*No repetition*], [$(n!)/((n-k)!)$], [$binom(n,k)$],
  )
]

The top-left is the product rule: $k$ independent choices from $n$ options
each --- strings of length $k$ over an alphabet of size $n$.

The top-right is the only non-obvious one.

#theorem(title: "stars and bars")[
  The number of ways to choose $k$ items from $n$ types, with repetition
  allowed and order irrelevant --- equivalently, the number of nonnegative
  integer solutions of $x_1 + x_2 + dots.c + x_n = k$ --- is
  $ binom(n + k - 1, k). $
]

#proof[
  Represent a selection as a row of $k$ stars separated into $n$ groups by
  $n - 1$ bars. For example with $n = 4$ types and $k = 6$ items,
  $ star.op star.op | thin | star.op star.op star.op | star.op $
  means two of type 1, none of type 2, three of type 3, one of type 4.

  Every such arrangement of $k$ stars and $n-1$ bars corresponds to exactly one
  selection, and every selection to exactly one arrangement. So we need to
  count the arrangements: there are $k + n - 1$ positions, and we choose which
  $k$ of them hold stars. That is $binom(n+k-1, k)$.
]

#intuition(title: "why stars and bars is worth remembering")[
  It is the answer to "how many ways to distribute $k$ identical things into
  $n$ distinct bins", which is an astonishingly common question in disguise:
  how many monomials of degree $k$ in $n$ variables; how many ways to split a
  budget into integer amounts; how many multisets of size $k$; how many
  compositions of an integer.

  The proof technique --- *find a bijection to something you already know how
  to count* --- is the single most powerful move in combinatorics.
]

== Pigeonhole

#theorem(title: "pigeonhole principle")[
  If $n$ items are placed into $m$ boxes and $n > m$, some box contains at
  least two items.

  More generally, some box contains at least $ceil(n slash m)$ items.
]

#proof[
  Suppose every box contained at most $ceil(n slash m) - 1$ items. Then the
  total is at most $m(ceil(n slash m) - 1) < m dot (n slash m + 1) - m = n$,
  a contradiction, using $ceil(x) < x + 1$.
]

Trivially obvious and startlingly powerful, because it produces existence
proofs out of nothing.

#example(title: "three pigeonhole arguments you have already relied on")[
  *Hash collisions are unavoidable.* Any hash function from a domain of size
  $> 2^64$ into 64-bit outputs has collisions. No cleverness helps; there are
  more inputs than outputs. This is why "collision-free" hashing means
  "collisions are hard to *find*", never "there are none".

  *Lossless compression cannot always compress.* A lossless compressor is
  injective. There are $2^n$ strings of length $n$ and only $2^n - 1$ strings
  strictly shorter, so some length-$n$ string does not shrink. Every
  compression scheme expands some inputs.

  *Every rational has a repeating decimal.* Chapter 1's proof: long division
  by $q$ has at most $q$ possible remainders, so a remainder must repeat
  within $q$ steps. In general, a deterministic machine with $m$ states run for
  more than $m$ steps must revisit a state --- which is also how cycle
  detection works.
]

== Inclusion--exclusion, in general

#theorem(title: "inclusion--exclusion")[
  For finite sets $A_1, dots, A_n$,
  $ abs(union.big_(i=1)^n A_i) = sum_(emptyset != S subset.eq [n]) (-1)^(abs(S)+1) abs(inter.big_(i in S) A_i). $
]

#proof[
  Take an element lying in exactly $k >= 1$ of the sets. On the left it is
  counted once. On the right, it is counted by every subset $S$ of those $k$
  sets, contributing $(-1)^(abs(S)+1)$ for each. So its total contribution is
  $ sum_(j=1)^k (-1)^(j+1) binom(k,j) = -sum_(j=1)^k (-1)^(j) binom(k,j) = -[ (1-1)^k - binom(k,0) ] = 1, $
  using the binomial theorem with $x = -1$, $y = 1$. Elements in none of the
  sets contribute $0$ to both sides.
]

#example(title: "derangements: nobody gets their own hat")[
  How many permutations of $n$ items leave *no* item in its original position?

  Let $A_i$ be the set of permutations fixing item $i$. We want
  $n! - abs(union A_i)$. An intersection of $j$ of the $A_i$ fixes $j$
  specified items and permutes the rest freely: $(n-j)!$ permutations. There
  are $binom(n,j)$ such intersections. So
  $ D_n = sum_(j=0)^n (-1)^j binom(n,j) (n-j)! = n! sum_(j=0)^n ((-1)^j)/(j!). $

  The sum converges to $e^(-1)$ (Chapter 17), so $D_n approx n! slash e$:
  *about $36.8%$ of all permutations are derangements*, essentially
  independently of $n$. Shuffle a deck against another deck and the chance no
  card lines up is about $1 slash e$, whether the decks have 5 cards or 5
  million.
]

== Counting proofs of identities

#definition(title: "double counting")[
  Count one set in two different ways; the two answers must be equal. This
  proves an identity, and the proof explains *why* the identity is true rather
  than merely verifying it.
]

#proposition(title: "Vandermonde's identity")[
  $ binom(m+n, k) = sum_(j=0)^k binom(m,j) binom(n, k-j). $
]

#proof[
  Count $k$-member committees drawn from a group of $m$ women and $n$ men.

  Ignoring the split: $binom(m+n,k)$.

  Splitting by how many women are chosen: if exactly $j$ women, there are
  $binom(m,j)$ ways to pick them and $binom(n,k-j)$ ways to pick the remaining
  $k - j$ men. Sum over $j$, since the cases are disjoint and exhaustive.
]

#proposition(title: "hockey stick")[
  $ sum_(i=r)^n binom(i, r) = binom(n+1, r+1). $
]

#proof[
  Count $(r+1)$-subsets of ${1, dots, n+1}$, classified by their *largest*
  element. If the largest is $i+1$, the remaining $r$ elements come from
  ${1,dots,i}$, giving $binom(i,r)$ subsets. Summing over the possible
  largest elements $i+1 = r+1, dots, n+1$ gives the left side; the right side
  counts the same subsets without the classification.
]

== Basic probability, foreshadowed

Counting and probability are the same subject when outcomes are equally
likely.

#definition[
  If a finite sample space $Omega$ has all outcomes equally likely, then for
  an event $A subset.eq Omega$,
  $ PP(A) = abs(A) / abs(Omega). $
]

That is the whole bridge; Part V generalises it to the case where outcomes are
not equally likely.

#example(title: "the birthday problem")[
  With $k$ people and $365$ equally likely birthdays, the probability that all
  are distinct is
  $ (365 dot 364 dots.c (365 - k + 1))/(365^k) = (P(365,k))/(365^k). $

  At $k = 23$ this drops below $1 slash 2$. The reason it is so small is that
  there are $binom(23,2) = 253$ *pairs*, not $23$ people --- collisions are
  about pairs, and pairs grow quadratically.

  Same mathematics: a hash function with $N$ possible outputs starts producing
  collisions after about $sqrt(N)$ insertions, not $N$. For a 64-bit hash that
  is $2^32 approx 4$ billion --- which is why 64-bit hashes are not safe
  against accidental collision at large scale, and why content-addressed
  stores use 256 bits.
]

== Exercises

#exercise[
  How many 5-card hands from a standard 52-card deck contain exactly two
  pairs (two cards of one rank, two of another, one of a third)? Show your
  decision sequence explicitly and say where you are careful not to
  double-count the two pairs.
]

#exercise[
  How many strings of length $10$ over ${A,B,C\}$ contain at least one $A$?
  Use complementary counting.
]

#exercise[
  Give a double-counting proof of $sum_(k=0)^n binom(n,k) = 2^n$ by counting
  the subsets of an $n$-set in two ways.
]

#exercise[
  How many nonnegative integer solutions does $x_1 + x_2 + x_3 + x_4 = 15$
  have? How many *positive* integer solutions? (For the second, substitute
  $y_i = x_i - 1$.)
]

#exercise[
  Prove that among any $n+1$ integers chosen from ${1, 2, dots, 2n}$, some
  one of them divides another. Hint: write each as $2^a m$ with $m$ odd, and
  pigeonhole on $m$.
]

#exercise[
  Use inclusion--exclusion to count the integers from $1$ to $1000$ divisible
  by none of $2$, $3$, or $5$.
]

#exercise[
  Prove $binom(n,k) = (n/k) binom(n-1, k-1)$ by a double-counting argument
  (count pairs consisting of a $k$-subset together with a distinguished
  element of it).
]

#exercise[
  A hash table has $m$ buckets and receives $n$ keys uniformly at random.
  Write an exact expression for the probability of no collision, then use the
  approximation $1 - x approx e^(-x)$ to show that collisions become likely
  once $n$ is around $sqrt(m)$.
]
