#import "../lib.typ": *

== Chapter 7 --- Logic and Proof

#soln("7.1")[
  Original: "If a graph is a tree then it has no cycles." *True* (by
  definition of a tree).

  *Contrapositive:* "If a graph has a cycle then it is not a tree." *True* ---
  it is the same statement.

  *Converse:* "If a graph has no cycles then it is a tree." *False.* Two
  disjoint edges form an acyclic graph that is not connected, hence not a
  tree. (Such a thing is a forest.)

  *Inverse:* "If a graph is not a tree then it has a cycle." *False*, with the
  same counterexample --- and necessarily so, since the inverse is the
  contrapositive of the converse and therefore has the same truth value.
]

#soln("7.2")[
  Flip each quantifier in turn and negate the innermost statement:
  $ exists epsilon > 0 thin forall N in NN thin exists n >= N : abs(a_n - L) >= epsilon. $

  In words: *there is some tolerance $epsilon$ that the sequence keeps
  violating* --- no matter how far out you go, you can always find a later term
  at least $epsilon$ away from $L$.

  Note the structure: convergence says the bad terms eventually stop; the
  negation says bad terms occur infinitely often. It does *not* say all terms
  are far from $L$.
]

#soln("7.3")[
  Contrapositive: if $n$ is odd, then $n^3 + 5$ is even.

  Let $n = 2k+1$. Then $n^3$ is a product of three odd numbers, hence odd ---
  or explicitly, $n^3 = 8k^3 + 12k^2 + 6k + 1 = 2(4k^3+6k^2+3k) + 1$.

  So $n^3 + 5 = (2m + 1) + 5 = 2(m+3)$, which is even.

  Since the contrapositive holds, so does the original.
]

#soln("7.4")[
  *Base case $n = 4$:* $4! = 24 > 16 = 2^4$. ✓

  *Inductive step.* Assume $k! > 2^k$ for some $k >= 4$. Then
  $ (k+1)! = (k+1) dot k! > (k+1) dot 2^k >= 5 dot 2^k > 2 dot 2^k = 2^(k+1), $
  using $k >= 4$ so $k + 1 >= 5 > 2$.

  *Where $n >= 4$ is needed.* The inductive step only requires $k + 1 > 2$,
  i.e. $k >= 2$. The real constraint is the *base case*: at $n = 3$,
  $3! = 6 < 8 = 2^3$, so the statement is false there and no induction can
  start earlier. The hypothesis $n >= 4$ is exactly the point at which the
  factorial overtakes the exponential.
]

#soln("7.5")[
  *Base case $n = 0$:* $0^3 - 0 = 0$, divisible by 6. ✓

  *Inductive step.* Assume $6 divides (k^3 - k)$. Then
  $
  (k+1)^3 - (k+1) &= k^3 + 3k^2 + 3k + 1 - k - 1 \
  &= (k^3 - k) + 3k^2 + 3k = (k^3-k) + 3k(k+1).
  $
  The first term is divisible by 6 by hypothesis. For the second: $k$ and
  $k+1$ are consecutive, so one is even, so $k(k+1)$ is even and
  $3k(k+1)$ is divisible by 6.

  A sum of two multiples of 6 is a multiple of 6.

  (Alternative without induction: $n^3 - n = (n-1)n(n+1)$, a product of three
  consecutive integers, which is divisible by 2 and by 3, hence by 6.)
]

#soln("7.6")[
  *Base cases.* $8 = 3 + 5$, $9 = 3 + 3 + 3$, $10 = 5 + 5$. ✓

  *Inductive step.* Let $n >= 11$ and assume every integer $m$ with
  $8 <= m < n$ is representable. Then $n - 3 >= 8$ and $n - 3 < n$, so by
  hypothesis $n - 3 = 3a + 5b$. Hence $n = 3(a+1) + 5b$.

  *Why three base cases.* The step reduces $n$ by 3, so it lands on $n-3$; to
  cover every residue class mod 3 you need the three consecutive values
  $8, 9, 10$ established directly. With only $8$ verified, the induction would
  reach $11, 14, 17, dots$ and nothing else.
]

#soln("7.7")[
  The step fails exactly at $k = 1$, i.e. going from 1 horse to 2.

  With $k+1 = 2$ horses ${h_1, h_2}$: removing $h_2$ leaves ${h_1}$, all one
  colour (trivially). Removing $h_1$ leaves ${h_2}$, all one colour. But the
  argument then needs these two conclusions to *chain* --- and chaining
  requires a horse present in both subsets, which transfers the colour from
  one to the other.

  For $k + 1 >= 3$ the two $k$-subsets overlap and the chaining works. For
  $k+1 = 2$ they are disjoint singletons and there is nothing to chain
  through.

  This is a genuinely useful lesson: an inductive step can be valid for all
  large $k$ and fail at the very bottom, which is precisely where nobody
  checks. When an induction proves something false, examine the step at the
  smallest $k$ where it is applied.
]

#soln("7.8")[
  *Invariant:* at the top of each iteration, $m = max(A[0..i-1])$.

  *Initialisation.* Before the loop, $i = 1$ and $m = A[0]$, and
  $max(A[0..0]) = A[0]$. Holds. (This is where nonemptiness is used: $A[0]$
  must exist.)

  *Maintenance.* Suppose the invariant holds with values $m, i$. The body sets
  $m' = max(m, A[i])$ --- either explicitly or by leaving $m$ alone --- and
  $i' = i+1$. Then
  $ m' = max(max(A[0..i-1]), A[i]) = max(A[0..i]) = max(A[0..i'-1]). $
  The invariant holds again.

  *Termination.* The loop exits when $i = n$, so
  $m = max(A[0..n-1])$, which is the maximum of the whole array. And the loop
  does terminate: $n - i$ is a nonnegative integer that strictly decreases
  each iteration (well-ordering).
]

== Chapter 8 --- Sets, Relations, and Structure

#soln("8.1")[
  *($subset.eq$)* Let $x in A without (B union C)$. Then $x in A$ and
  $x in.not B union C$. By De Morgan for logic, "not ($x in B$ or $x in C$)"
  means $x in.not B$ *and* $x in.not C$. So $x in A without B$ and
  $x in A without C$, i.e. $x in (A without B) inter (A without C)$.

  *($supset.eq$)* Let $x in (A without B) inter (A without C)$. Then $x in A$,
  $x in.not B$, and $x in.not C$. Hence $x in.not B union C$, so
  $x in A without (B union C)$.

  Every step is reversible, so a single chain of "iff"s would also have done
  it; the double inclusion is written out here because it is the form that
  always works even when steps are not reversible.
]

#soln("8.2")[
  $
  cal(P)({a,b,c}) = { emptyset, {a}, {b}, {c}, {a,b}, {a,c}, {b,c}, {a,b,c} },
  $
  which is 8 elements, $= 2^3$. ✓

  *The bijection to $0, dots, 7$.* Assign bit 0 to $a$, bit 1 to $b$, bit 2
  to $c$, setting the bit iff the element is present:
  $
  emptyset &-> 000_2 = 0, & {a} &-> 001_2 = 1, & {b} &-> 010_2 = 2, & {a,b} &-> 011_2 = 3, \
  {c} &-> 100_2 = 4, & {a,c} &-> 101_2 = 5, & {b,c} &-> 110_2 = 6, & {a,b,c} &-> 111_2 = 7.
  $
  This is exactly the bitmask representation, and it is a bijection because
  every 3-bit pattern occurs exactly once. Union becomes bitwise OR,
  intersection becomes AND, and complement becomes NOT --- which is the
  Boolean-algebra correspondence of the chapter, made executable.
]

#soln("8.3")[
  #table(
    columns: 5, inset: 6pt, stroke: 0.4pt + luma(180), align: (left, center, center, center, center),
    table.header([*Relation*], [refl.], [symm.], [antisymm.], [trans.]),
    [(a) $a <= b$], [yes], [no], [yes], [yes],
    [(b) $a divides b$ on $ZZ$], [yes], [no], [*no*], [yes],
    [(c) $a + b$ even], [yes], [yes], [no], [yes],
    [(d) $a != b$], [no], [yes], [no], [no],
  )

  *(a)* A total order.

  *(b)* The interesting one: divisibility is antisymmetric on $NN$ but *not*
  on $ZZ$, since $2 divides -2$ and $-2 divides 2$ while $2 != -2$. Sign is
  the obstruction.

  *(c)* An equivalence relation. Transitivity:
  $a + c = (a+b) + (b+c) - 2b$, a sum of even numbers. The two classes are the
  evens and the odds --- this is congruence mod 2.

  *(d)* Not reflexive ($a = a$, so $a R a$ fails) and not transitive:
  $1 != 2$ and $2 != 1$, but $1 = 1$.
]

#soln("8.4")[
  Write $a tilde b$ for "$a$ and $b$ have the same remainder mod 5", i.e.
  $5 divides (a - b)$.

  *Reflexive:* $5 divides 0$.
  *Symmetric:* if $5 divides (a-b)$ then $5 divides (b-a)$.
  *Transitive:* if $5 divides (a-b)$ and $5 divides (b-c)$ then $5$ divides
  their sum $(a-c)$.

  The classes are the five residue classes
  $
  [0] &= {dots, -5, 0, 5, 10, dots}, quad [1] = {dots, -4, 1, 6, 11, dots}, \
  [2] &= {dots, -3, 2, 7, dots}, quad [3] = {dots, -2, 3, 8, dots}, quad [4] = {dots, -1, 4, 9, dots},
  $
  and they partition $ZZ$ --- every integer is in exactly one, by the division
  algorithm (Chapter 12).
]

#soln("8.5")[
  *A strict example.* Take $f(x) = x^2$, $S = {1}$, $T = {-1}$. Then
  $S inter T = emptyset$ so $f(S inter T) = emptyset$, while
  $f(S) = f(T) = {1}$ so $f(S) inter f(T) = {1}$. Strict.

  *If $f$ is injective, equality holds.* The inclusion $subset.eq$ is always
  true: if $y = f(x)$ with $x in S inter T$, then $y in f(S)$ and $y in f(T)$.

  For $supset.eq$: let $y in f(S) inter f(T)$. Then $y = f(s)$ for some
  $s in S$ and $y = f(t)$ for some $t in T$. Injectivity forces $s = t$, so
  this common element lies in $S inter T$, and $y in f(S inter T)$.

  The failure without injectivity is exactly the collision: two *different*
  points, one from each set, landing on the same image.
]

#soln("8.6")[
  Let $M$ be the maths-takers and $P$ the physics-takers, inside a universe
  of all 100 students.
  $ abs(M union P) = abs(M) + abs(P) - abs(M inter P) = 60 + 45 - 20 = 85. $
  So the number taking neither is
  $ abs(overline(M union P)) = 100 - 85 = 15. $

  The universe being complemented against is the set of all 100 students ---
  which must be stated, because "neither" is meaningless without it.
]

#soln("8.7")[
  $(RR, -)$ is *not* a monoid, and it fails on more than one count.

  *Associativity fails*, which is the decisive one:
  $ (1 - 2) - 3 = -4, quad "but" quad 1 - (2 - 3) = 1 - (-1) = 2. $

  *Identity is one-sided.* $a - 0 = a$, so $0$ is a right identity. But
  $0 - a = -a != a$ in general, so it is not a left identity. A monoid
  requires a two-sided identity.

  Since associativity fails, subtraction cannot be safely parallelised or
  reassociated --- which is why `reduce(-)` over a list is a bug waiting to
  happen and `foldl` versus `foldr` give different answers.
]

#soln("8.8")[
  *An example.* On ${1,2,3}$, let $R = {(1,1),(1,2),(2,1),(2,2)}$.

  Symmetric: yes, every pair's reverse is present. Transitive: yes, check the
  four compositions among ${1,2}$. Reflexive: *no* --- $(3,3) in.not R$.

  (The simplest example of all is $R = emptyset$ on a nonempty set: vacuously
  symmetric and transitive, not reflexive.)

  *Why the "obvious" argument is wrong.* The bogus reasoning is: "$a R b$
  implies $b R a$ by symmetry, and then $a R b$ with $b R a$ implies $a R a$
  by transitivity."

  The flaw: that derivation assumes there *exists* some $b$ with $a R b$. If
  $a$ is related to nothing at all --- as $3$ is above --- the chain never
  starts, and reflexivity at $a$ is never forced.

  The argument does prove something weaker and true: in a symmetric transitive
  relation, every element that is related to *anything* is related to itself.
]

== Chapter 9 --- Counting

#soln("9.1")[
  Build the hand by an ordered sequence of independent decisions.

  + *Choose the two ranks that will be paired:* $binom(13,2) = 78$. Using
    $binom(13,2)$ rather than $13 times 12$ is exactly where the
    double-counting is avoided --- "a pair of aces and a pair of kings" is one
    hand, not two.
  + *Choose two suits for the first paired rank:* $binom(4,2) = 6$.
  + *Choose two suits for the second:* $binom(4,2) = 6$.
  + *Choose the fifth card,* from a rank not already used: $11$ ranks
    $times 4$ suits $= 44$.

  $ 78 times 6 times 6 times 44 = 123,!552. $

  (Out of $binom(52,5) = 2,!598,!960$ hands, about $4.75%$.)
]

#soln("9.2")[
  Complementary counting. Total strings of length 10 over a 3-letter alphabet:
  $3^10 = 59,!049$. Strings with *no* $A$ --- so built from ${B,C}$ only:
  $2^10 = 1,!024$.

  $ 59,!049 - 1,!024 = 58,!025. $

  Doing it directly would mean summing over the number of $A$s,
  $sum_(k=1)^10 binom(10,k) 2^(10-k)$ --- which is correct, much more work, and
  by the binomial theorem equals the same thing.
]

#soln("9.3")[
  Count the subsets of an $n$-element set, two ways.

  *Way 1.* A subset is a yes/no decision per element: $2^n$.

  *Way 2.* Classify by size. There are $binom(n,k)$ subsets of size $k$, and
  every subset has exactly one size, so the classes are disjoint and
  exhaustive: $sum_(k=0)^n binom(n,k)$.

  Two counts of the same set must agree:
  $ sum_(k=0)^n binom(n,k) = 2^n. $
]

#soln("9.4")[
  *Nonnegative.* Stars and bars with $k = 15$ stars and $n = 4$ bins:
  $ binom(15 + 4 - 1, 15) = binom(18,15) = binom(18,3) = (18 dot 17 dot 16)/6 = 816. $

  *Positive.* Substitute $y_i = x_i - 1 >= 0$. Then
  $y_1 + y_2 + y_3 + y_4 = 15 - 4 = 11$, and
  $ binom(11 + 3, 11) = binom(14,3) = (14 dot 13 dot 12)/6 = 364. $

  The substitution is the standard move: hand out the mandatory minimum first,
  then distribute the remainder freely.
]

#soln("9.5")[
  Write each of the chosen integers uniquely as $2^a m$ with $m$ odd
  (repeatedly divide out 2s).

  Every such $m$ is an odd number in ${1, 2, dots, 2n}$, and there are exactly
  $n$ of those: $1, 3, 5, dots, 2n-1$.

  We have $n+1$ integers and $n$ possible odd parts, so by pigeonhole two of
  them share the same $m$: say $2^a m$ and $2^b m$ with $a < b$.

  Then $2^b m = 2^(b-a) dot (2^a m)$, so the first divides the second.

  The whole difficulty was finding the right pigeonholes; once "odd part" is
  the classifier, the argument is two lines.
]

#soln("9.6")[
  Let $A_d$ be the multiples of $d$ in $1..1000$, so
  $abs(A_d) = floor(1000 slash d)$.
  $
  abs(A_2) &= 500, quad abs(A_3) = 333, quad abs(A_5) = 200, \
  abs(A_6) &= 166, quad abs(A_10) = 100, quad abs(A_15) = 66, quad abs(A_30) = 33.
  $
  By inclusion--exclusion,
  $ abs(A_2 union A_3 union A_5) = 500 + 333 + 200 - 166 - 100 - 66 + 33 = 734. $
  So the count divisible by none of them is $1000 - 734 = 266$.
]

#soln("9.7")[
  Count pairs $(S, x)$ where $S$ is a $k$-subset and $x in S$ is a
  distinguished element.

  *By choosing $S$ first:* $binom(n,k)$ subsets, then $k$ choices of $x$
  within it: $k binom(n,k)$.

  *By choosing $x$ first:* $n$ choices of $x$, then the remaining $k-1$
  members from the other $n-1$ elements: $n binom(n-1,k-1)$.

  Equating and dividing by $k$:
  $ binom(n,k) = n/k binom(n-1,k-1). $
]

#soln("9.8")[
  *Exact.* Insert the keys one at a time. The $i$-th key (0-indexed) avoids
  collision iff it lands in one of the $m - i$ still-empty buckets, so
  $ PP("no collision") = product_(i=0)^(n-1) (m - i)/m = product_(i=0)^(n-1) (1 - i/m). $

  *Approximation.* Using $1 - x approx e^(-x)$ for small $x$:
  $ PP approx product_(i=0)^(n-1) e^(-i slash m) = exp( - 1/m sum_(i=0)^(n-1) i ) = exp( -(n(n-1))/(2m) ). $

  This drops to $1 slash 2$ when $n(n-1) slash (2m) approx ln 2$, i.e.
  $ n approx sqrt(2 m ln 2) approx 1.18 sqrt(m). $

  So collisions become likely at around $sqrt(m)$ insertions, not $m$ --- the
  birthday phenomenon. It is quadratic because collisions are about *pairs*,
  and there are $binom(n,2) approx n^2 slash 2$ of those.
]

== Chapter 10 --- Graphs

#soln("10.1")[
  The sum of the degrees would be $7 times 3 = 21$, which is odd.

  But by the handshake lemma the sum of all degrees equals $2 abs(E)$, which
  is even. Contradiction, so no such graph exists.

  Equivalently by the corollary: all seven vertices have odd degree, and the
  number of odd-degree vertices must be even.
]

#soln("10.2")[
  Let $T$ be a tree with at least two vertices, and let
  $P = v_0 v_1 dots v_k$ be a *longest* path in $T$ (one exists since $T$ is
  finite). Since $T$ is connected with $>= 2$ vertices, $k >= 1$.

  *Claim: $v_0$ has degree 1.* Suppose $v_0$ had another neighbour $w != v_1$.
  If $w$ is on $P$, say $w = v_j$ with $j >= 2$, then
  $v_0 v_1 dots v_j v_0$ is a cycle --- impossible in a tree. If $w$ is not on
  $P$, then $w v_0 v_1 dots v_k$ is a longer path --- contradicting
  maximality.

  So $v_0$ is a leaf, and by the identical argument so is $v_k$. They are
  distinct because $k >= 1$. Hence at least two leaves.
]

#soln("10.3")[
  Let $P = v_0 v_1 dots v_k$ be a longest path in $G$.

  $v_k$ has degree at least 2, so it has a neighbour $w$ other than
  $v_(k-1)$.

  $w$ cannot be off the path: $v_0 dots v_k w$ would be longer.

  So $w = v_i$ for some $i <= k - 2$. Then
  $ v_i v_(i+1) dots v_k v_i $
  is a closed walk of length at least 3 with no repeated vertex except the
  endpoints --- a cycle.
]

#soln("10.4")[
  The graph is the 6-cycle with edges $12, 23, 34, 45, 56, 61$.

  It is bipartite, with parts ${1,3,5}$ and ${2,4,6}$: every edge joins an odd
  vertex to an even one. (Equivalently, every cycle --- there is only one, of
  length 6 --- is even.)

  *Adding edge $1 4$: still bipartite.* Vertex 1 is in the first part and
  vertex 4 is in the second, so the new edge respects the same 2-colouring. It
  creates two new cycles, $1 2 3 4 1$ and $1 4 5 6 1$, both of length 4 ---
  even, as König's theorem requires.

  Worth noting what *would* break it: adding an edge between two
  same-parity vertices, say $1 3$, creates the odd cycle $1 2 3 1$ of length 3
  and destroys bipartiteness immediately.
]

#soln("10.5")[
  The four landmasses have degrees $3, 3, 3, 5$ --- all odd.

  *No circuit.* Euler's theorem requires *every* vertex to have even degree
  for a closed circuit using each edge once. Four odd vertices, so no.

  *No open path either.* An Euler *path* (using every edge once, allowed to
  finish somewhere else) exists in a connected graph iff there are exactly
  $0$ or $2$ vertices of odd degree --- the start and the end are the only
  places where the enter/leave pairing can fail. Königsberg has four odd
  vertices, so no such walk exists either.

  This is the problem Euler solved in 1736, generally regarded as the
  beginning of graph theory.
]

#soln("10.6")[
  *Minimum degree at most 5.* Suppose every vertex had degree $>= 6$. Then
  $ 2 abs(E) = sum_v deg(v) >= 6V quad arrow.r.double quad abs(E) >= 3V > 3V - 6, $
  contradicting $abs(E) <= 3V - 6$. So some vertex has degree $<= 5$.

  *Six-colourability, by induction on $V$.* For $V <= 6$, colour every vertex
  differently.

  For larger $V$: pick a vertex $v$ of degree at most 5 (which exists by the
  above; note every subgraph of a planar graph is planar, so the bound keeps
  applying). Delete $v$; the rest is planar with fewer vertices, so by
  hypothesis it is 6-colourable. Restore $v$: it has at most 5 neighbours, so
  at most 5 of the 6 colours are excluded, and at least one remains. Assign it.
]

#soln("10.7")[
  *$(A^2)_(i i)$* counts walks of length 2 from $i$ back to $i$: go to a
  neighbour and come back. There is exactly one such walk per neighbour, so
  $(A^2)_(i i) = deg(i)$.

  *$(A^3)_(i i)$* counts closed walks of length 3 from $i$. In a simple graph
  such a walk must visit three distinct vertices --- a triangle through $i$ ---
  and each triangle can be traversed in 2 directions. So
  $(A^3)_(i i) = 2 t_i$, where $t_i$ is the number of triangles containing
  $i$.

  *$tr(A^3) slash 6$.* Summing, $tr(A^3) = 2 sum_i t_i$. Each triangle is
  counted once at each of its 3 vertices, so $sum_i t_i = 3 T$ where $T$ is
  the total number of triangles. Hence $tr(A^3) = 6 T$, and
  $ T = (tr(A^3))/6. $
  A genuinely usable algorithm: cube the adjacency matrix and read off the
  triangle count.
]

#soln("10.8")[
  Let $u <= v$ mean "there is a directed path from $u$ to $v$" in a DAG.

  *Reflexive:* the empty path from $u$ to itself.

  *Transitive:* concatenate a path $u arrow.squiggly v$ with
  $v arrow.squiggly w$.

  *Antisymmetric:* suppose $u <= v$ and $v <= u$ with $u != v$. Concatenating
  the two paths gives a closed directed walk through two distinct vertices,
  which contains a directed cycle --- contradicting acyclicity. So $u = v$.

  *What fails with a cycle:* exactly antisymmetry. On a directed cycle every
  vertex reaches every other, so all of them are mutually $<=$ without being
  equal. Reflexivity and transitivity survive; it becomes a *preorder* rather
  than a partial order, and the standard repair is to collapse each strongly
  connected component to a point --- giving the condensation, which is a DAG
  and therefore a genuine partial order again.
]
