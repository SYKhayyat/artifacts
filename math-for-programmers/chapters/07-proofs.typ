#import "../lib.typ": *

= Logic and Proof

== The most important chapter in the book

Everything from here on is proved. If you can read a proof, the rest of this
book is a long but straightforward walk. If you cannot, every page will feel
like being shown conclusions by someone who will not say why.

You have an advantage. You already reason formally --- about invariants, about
termination, about whether a refactor preserves behaviour. What follows is
mostly *naming* things you do, plus a handful of moves that have no obvious
programming analogue.

== Propositions and connectives

#definition(title: "proposition")[
  A *proposition* is a statement that is definitely true or definitely false.

  "$7$ is prime" is a proposition (true). "$x > 3$" is not --- it depends on
  $x$; it is a *predicate*, a proposition-valued function. "This sentence is
  false" is not a proposition at all.
]

#definition(title: "connectives")[
  For propositions $P$ and $Q$:

  #set table(inset: 6pt, stroke: 0.4pt + luma(180))
  #align(center)[
    #table(
      columns: 4,
      align: (center, center, center, left),
      table.header([$P$], [$Q$], [$P arrow.r.double Q$], [others]),
      [T], [T], [T], [$not P$: negation, true iff $P$ is false],
      [T], [F], [*F*], [$P and Q$: true iff both],
      [F], [T], [T], [$P or Q$: true iff at least one (*inclusive*)],
      [F], [F], [T], [$P arrow.l.r.double Q$: true iff same truth value],
    )
  ]
]

Two of these need comment.

*Or is inclusive.* $P or Q$ is true when both are. Mathematical English never
means exclusive-or unless it says "exactly one of". This differs from ordinary
speech and matches every programming language you use.

*Implication is the strange one.* $P arrow.r.double Q$ is *false in exactly
one case*: $P$ true and $Q$ false. In particular, when $P$ is false the
implication is true regardless of $Q$.

#intuition(title: "why a false premise makes an implication true")[
  Read $P arrow.r.double Q$ as *a promise*: "if $P$ happens, I guarantee $Q$."
  The promise is broken only if $P$ happens and $Q$ does not. If $P$ never
  happens, the promise was never tested, so it was not broken --- and an
  unbroken promise counts as kept.

  "If $n$ is an integer with $n^2 = 2$, then I am the Pope" is *true*. The
  hypothesis is never satisfied, so nothing is ever claimed. This is called
  *vacuous truth* and it is not a loophole; it is what makes universally
  quantified statements about empty sets behave.

  The programmer's version: `all([])` returns `True` and `any([])` returns
  `False`, for exactly this reason. Every element of the empty list satisfies
  every predicate, vacuously.
]

#definition(title: "converse, inverse, contrapositive")[
  Given $P arrow.r.double Q$:

  - the *converse* is $Q arrow.r.double P$;
  - the *inverse* is $not P arrow.r.double not Q$;
  - the *contrapositive* is $not Q arrow.r.double not P$.
]

#theorem(title: "contraposition")[
  $P arrow.r.double Q$ and $not Q arrow.r.double not P$ are logically
  equivalent: they have the same truth value in every case.
]

#proof[
  Compare truth tables. $P arrow.r.double Q$ is false exactly when $P$ is true
  and $Q$ is false. $not Q arrow.r.double not P$ is false exactly when
  $not Q$ is true and $not P$ is false --- that is, when $Q$ is false and $P$
  is true. Same case. Since they are false in exactly the same situation, they
  are true in exactly the same situations.
]

#warning(title: "the converse is a different statement")[
  Confusing a statement with its converse is the single most common logical
  error, in mathematics and in life.

  "If it is a square, it is a rectangle" is true. Its converse is false. The
  contrapositive --- "if it is not a rectangle, it is not a square" --- is
  true, and it always is, because it is the same statement.

  Note the inverse is the contrapositive of the converse, so *inverse and
  converse stand or fall together*, and neither follows from the original.
]

== Quantifiers

#definition(title: "quantifiers")[
  $forall x in S : P(x)$ --- "for all $x$ in $S$, $P(x)$ holds."

  $exists x in S : P(x)$ --- "there exists $x$ in $S$ with $P(x)$."
]

#theorem(title: "negating quantifiers")[
  $
  not (forall x : P(x)) &quad "is equivalent to" quad exists x : not P(x) \
  not (exists x : P(x)) &quad "is equivalent to" quad forall x : not P(x)
  $
]

The rule in words: *push the negation inward and flip every quantifier.* To
deny "all swans are white" you do not assert "all swans are non-white"; you
exhibit one black swan.

#example(title: "negating something with three quantifiers")[
  Continuity of $f$ at $a$ (Chapter 13) is
  $ forall epsilon > 0 thin exists delta > 0 thin forall x : abs(x - a) < delta arrow.r.double abs(f(x) - f(a)) < epsilon. $

  To negate: flip each quantifier in turn, left to right, and negate the
  innermost statement. The negation of $A arrow.r.double B$ is $A and not B$
  (check the truth table). So:
  $ exists epsilon > 0 thin forall delta > 0 thin exists x : abs(x - a) < delta and abs(f(x) - f(a)) >= epsilon. $

  In words: there is a target tolerance $epsilon$ that you can never hit,
  however small you make $delta$ --- because for each $delta$ someone can find
  a nearby $x$ whose image is still far away.

  Being able to do this mechanically is worth a great deal. Most "I do not
  understand this definition" is really "I cannot state its negation."
]

#warning(title: "the order of quantifiers changes the meaning entirely")[
  $ forall x thin exists y : y > x quad "versus" quad exists y thin forall x : y > x. $

  Over the reals the first is *true* --- given any $x$, take $y = x + 1$; the
  $y$ is allowed to depend on the $x$. The second is *false*: it claims a
  single $y$ larger than every real number.

  The rule: *inner variables may depend on outer ones; outer ones may not
  depend on inner ones.* This is the difference between "every request gets
  some response" and "there is one response that serves every request", and it
  is the difference between pointwise and uniform continuity, and between
  pointwise and uniform convergence, both of which cause real trouble in
  analysis.
]

== The proof techniques

=== Direct proof

Assume the hypothesis, derive the conclusion by valid steps.

#proposition[
  If $n$ is odd then $n^2$ is odd.
]

#proof[
  $n$ odd means $n = 2k + 1$ for some integer $k$. Then
  $ n^2 = (2k+1)^2 = 4k^2 + 4k + 1 = 2(2k^2 + 2k) + 1, $
  which is $2m + 1$ with $m = 2k^2 + 2k$ an integer. So $n^2$ is odd.
]

Note the shape: *unpack the definition* of the hypothesis into an equation,
manipulate, *repack into the definition* of the conclusion. A large fraction
of all direct proofs are exactly that, and when you are stuck the first move
is always "write out what the words mean".

=== Proof by contraposition

Prove $not Q arrow.r.double not P$ instead. Use this when the negations are
easier to work with than the originals --- typically when $P$ or $Q$ contains
"not", or an existence claim.

#proposition[
  If $n^2$ is even then $n$ is even.
]

#proof[
  We prove the contrapositive: if $n$ is odd then $n^2$ is odd. That is the
  previous proposition.
]

A direct attack would start from "$n^2 = 2k$" and try to extract information
about $n$, which is awkward. Contraposition made it free. This is exactly the
step used inside the irrationality proof of Chapter 1.

=== Proof by contradiction

Assume the statement is false, derive something impossible.

#proposition[
  There are infinitely many primes.
]

#proof[
  Suppose not: suppose there are finitely many, say $p_1, p_2, dots, p_n$ is
  the complete list.

  Consider $N = p_1 p_2 dots.c p_n + 1$.

  $N > 1$, so it has a prime factor $p$ (every integer greater than 1 does ---
  see Chapter 12). That $p$ must be on our list, since the list is complete.
  So $p$ divides the product $p_1 dots.c p_n$. It also divides $N$. Therefore
  it divides their difference, which is $1$.

  No prime divides $1$. Contradiction. So the list cannot have been complete,
  and there are infinitely many primes.
]

#warning(title: "contradiction is over-used")[
  Beginners reach for contradiction reflexively, and it often adds nothing:
  they assume $not Q$, never use it, prove $Q$ directly, and then announce a
  contradiction. That is a direct proof wearing a costume.

  Use contradiction when the assumption $not Q$ gives you *something concrete
  to work with* --- as above, where "the list is finite and complete" is a real
  handle. If you never use the negated assumption, delete it.
]

=== Proof by cases

Split into exhaustive possibilities and handle each. The only requirement is
that the cases genuinely cover everything --- say so explicitly.

#proposition[
  For every integer $n$, $n^2 + n$ is even.
]

#proof[
  Every integer is even or odd; these cases are exhaustive.

  *Case 1: $n = 2k$.* Then $n^2 + n = 4k^2 + 2k = 2(2k^2 + k)$, even.

  *Case 2: $n = 2k+1$.* Then
  $n^2 + n = (4k^2+4k+1) + (2k+1) = 4k^2 + 6k + 2 = 2(2k^2+3k+1)$, even.

  Both cases give an even number, so the claim holds for all $n$.
]

=== Existence proofs, constructive and not

To prove $exists x : P(x)$, the honest way is to exhibit an $x$ and verify
$P(x)$. That is a *constructive* proof, and it doubles as an algorithm.

A *non-constructive* proof shows something must exist without producing it.
These feel like cheating and are not.

#proposition[
  There exist irrational $a, b$ with $a^b$ rational.
]

#proof[
  Consider $s = sqrt(2)^sqrt(2)$. Either $s$ is rational or it is not.

  If $s$ is rational, take $a = b = sqrt(2)$ and we are done.

  If $s$ is irrational, take $a = s$ and $b = sqrt(2)$; then
  $ a^b = (sqrt(2)^sqrt(2))^sqrt(2) = sqrt(2)^(sqrt(2) dot sqrt(2)) = sqrt(2)^2 = 2, $
  which is rational, and we are done.

  Either way such $a, b$ exist.
]

We have proved existence without knowing which case holds --- the proof never
tells us which pair works. A constructivist rejects this argument; everyone
else accepts it. The programmer's reading: this is a proof that a value exists
with no way to compute it, which is precisely why constructive logic and type
theory care about the distinction.

=== Uniqueness

To prove "there is exactly one $x$ with $P(x)$", do two things: exhibit one
(existence), then assume $x_1$ and $x_2$ both work and show $x_1 = x_2$.

#proposition[
  A nonzero real $a$ has exactly one multiplicative inverse.
]

#proof[
  *Existence:* $1 slash a$ works.

  *Uniqueness:* suppose $a b = 1$ and $a c = 1$. Then
  $ b = b dot 1 = b(a c) = (b a) c = 1 dot c = c. $
]

=== Disproof by counterexample

To disprove $forall x : P(x)$, exhibit a single $x$ with $not P(x)$. One is
enough, and no amount of confirming instances substitutes for checking.

#example[
  "Every $n^2 + n + 41$ is prime for $n in NN$." True for
  $n = 0, 1, dots, 39$ --- forty consecutive confirmations. False at $n = 40$,
  where the value is $41^2$.

  Testing is not proving. You knew that.
]

== Induction

Now the technique you already half-own.

#theorem(title: "principle of mathematical induction")[
  Let $P(n)$ be a predicate on $NN$. If

  #set enum(numbering: "(i)")
  + $P(0)$ holds *(base case)*, and
  + for every $k$, $P(k) arrow.r.double P(k+1)$ *(inductive step)*,

  then $P(n)$ holds for every $n in NN$.
]

This is not a trick; it is a restatement of what $NN$ *is* (Chapter 1). Every
natural number is reachable from $0$ by finitely many successor steps, so if
truth survives each step and holds at the start, it holds everywhere.

#example(title: "a first induction, in full")[
  *Claim:* $sum_(i=1)^n i = n(n+1) slash 2$ for all $n >= 1$.

  *Base case ($n = 1$).* The left side is $1$; the right side is
  $1 dot 2 slash 2 = 1$. They agree.

  *Inductive step.* Assume the claim for some $k >= 1$; that is, assume
  $ sum_(i=1)^k i = (k(k+1))/2. quad (star) $
  We must prove it for $k+1$. Compute:
  $
  sum_(i=1)^(k+1) i = underbrace(sum_(i=1)^k i, "use" (star)) + (k+1)
  = (k(k+1))/2 + (k+1)
  = (k+1) ( k/2 + 1 )
  = ((k+1)(k+2))/2,
  $
  which is the claimed formula with $n = k+1$.

  By induction, the claim holds for every $n >= 1$.
]

#intuition(title: "the shape of every induction, and where the work is")[
  The inductive step always looks like this: take the expression for $k+1$,
  *carve out the part that looks like the case $k$*, replace it using the
  hypothesis, and simplify.

  The single most common failure is not carving anything out --- writing down
  the $k+1$ case and staring at it. If you have not used the inductive
  hypothesis, you have not done an induction.

  The second most common failure is proving $P(k) arrow.r.double P(k+1)$
  correctly and forgetting the base case. Then you have a chain with nothing
  attached to the ground. "$n = n+1$ for all $n$" has a perfectly valid
  inductive step.
]

=== Strong induction

Sometimes $P(k)$ alone is not enough and you need every earlier case.

#theorem(title: "strong induction")[
  If for every $n$, [$P(m)$ holds for all $m < n$] implies $P(n)$, then $P(n)$
  holds for all $n$.
]

Note there is no separate base case: at $n = 0$ the hypothesis is vacuously
true (nothing is less than $0$), so the step must prove $P(0)$ outright. In
practice you handle the small cases explicitly anyway.

#proposition[
  Every integer $n >= 2$ is a product of primes.
]

#proof[
  Strong induction on $n$. Let $n >= 2$ and suppose every integer $m$ with
  $2 <= m < n$ is a product of primes.

  If $n$ is prime, it is a product of one prime. Done.

  Otherwise $n$ is composite: $n = a b$ with $2 <= a, b < n$. By the inductive
  hypothesis both $a$ and $b$ are products of primes, so $n$ is the
  concatenation of those two products.
]

Ordinary induction fails here: knowing about $n - 1$ tells you nothing about
the factors of $n$. This is the same reason your recursion on a tree calls
itself on *both* subtrees rather than on "the previous node".

=== Well-ordering, and why it is the same thing

#theorem(title: "well-ordering principle")[
  Every nonempty subset of $NN$ has a least element.
]

Well-ordering, ordinary induction, and strong induction are all equivalent ---
each can be proved from either of the others. Well-ordering is the most
convenient form for "minimal counterexample" arguments:

#proposition[
  Every integer $n >= 2$ has a prime divisor.
]

#proof[
  Suppose not. Then the set $S$ of integers $n >= 2$ with no prime divisor is
  nonempty, so by well-ordering it has a least element $n_0$.

  $n_0$ cannot be prime (it would divide itself). So $n_0 = a b$ with
  $2 <= a < n_0$. Since $n_0$ is the *least* member of $S$, $a in.not S$, so
  $a$ has a prime divisor $p$. But $p divides a$ and $a divides n_0$, so
  $p divides n_0$ --- contradicting $n_0 in S$.
]

#intuition(title: "well-ordering is termination")[
  You have used this principle every time you argued that a loop terminates.
  You exhibit a quantity that is a natural number and strictly decreases each
  iteration; since there is no infinite strictly decreasing sequence of
  naturals, the loop must stop. That is well-ordering, and the quantity has a
  name: a *variant*, or *ranking function*.

  Likewise, the descent argument in Chapter 1's irrationality proof was
  well-ordering: no infinite chain of ever-smaller positive integers.
]

=== Structural induction

Induction is not really about numbers; it is about anything built up from
constructors by finitely many steps. To prove a property of every element of a
recursively defined type, prove it for the base constructors and prove each
recursive constructor preserves it.

#example(title: "structural induction on a binary tree")[
  *Claim:* a binary tree with $n$ internal nodes has $n + 1$ leaves.

  *Base case:* a tree that is a single leaf has $n = 0$ internal nodes and
  $1 = 0 + 1$ leaf.

  *Step:* a tree formed as an internal node with subtrees $L$ and $R$. Suppose
  $L$ has $ell$ internal nodes and $ell + 1$ leaves, and $R$ has $r$ internal
  nodes and $r+1$ leaves. The combined tree has $ell + r + 1$ internal nodes
  (the two subtrees plus the new root) and $(ell+1) + (r+1) = (ell + r + 1) + 1$
  leaves. Which is the claim.

  Note this is *strong* induction in disguise: we assumed the result for two
  smaller trees, not for "the previous tree".
]

=== Loop invariants are induction

Making the correspondence explicit, because it is the bridge from what you
know to what this chapter is teaching.

#algo(title: "Sum of an array")[
```
function sum(A[0..n-1]):
    s := 0
    i := 0
    while i < n:
        s := s + A[i]
        i := i + 1
    return s
```
]

*Invariant:* at the top of each iteration, $s = sum_(j=0)^(i-1) A[j]$.

*Initialisation (base case).* Before the loop, $i = 0$ and $s = 0$, and the
empty sum is $0$. Holds.

*Maintenance (inductive step).* Suppose it holds with values $s, i$. The body
sets $s' = s + A[i]$ and $i' = i + 1$. Then
$ s' = sum_(j=0)^(i-1) A[j] + A[i] = sum_(j=0)^(i'-1) A[j]. $
Holds again.

*Termination.* The loop exits with $i = n$, so $s = sum_(j=0)^(n-1) A[j]$,
which is what we wanted.

That is induction on the iteration count, verbatim. When you write a loop
invariant you are writing $P(k)$; when you argue the body preserves it you are
proving $P(k) arrow.r.double P(k+1)$.

== A checklist for reading and writing proofs

*Reading:*

+ What exactly is being claimed? Write the statement in symbols with all
  quantifiers explicit.
+ What is assumed and what must be shown?
+ For each line: which earlier fact or definition licenses it?
+ Where is the hypothesis actually used? If a hypothesis is never used, either
  the theorem is stronger than stated or the proof is wrong.

*Writing:*

+ State what you are proving and what technique you are using. "We proceed by
  induction on $n$." "We prove the contrapositive."
+ Unpack every definition into a formula before manipulating.
+ Say where each assumption is discharged.
+ Never write "clearly", "obviously", or "it is easy to see". Those words mark
  the exact place where proofs are wrong. If it really is immediate, the
  sentence explaining why is short --- write it.
+ End by observing that you have arrived at the claim.

== Exercises

#exercise[
  Write the contrapositive, the converse, and the inverse of: "If a graph is a
  tree then it has no cycles." State which of the four statements are true.
]

#exercise[
  Negate, pushing the negation all the way in:
  $ forall epsilon > 0 thin exists N in NN thin forall n >= N : abs(a_n - L) < epsilon. $
  Then say in plain English what your negation asserts.
]

#exercise[
  Prove by contraposition: if $n^3 + 5$ is odd, then $n$ is even.
]

#exercise[
  Prove by induction that $n! > 2^n$ for all integers $n >= 4$. Note carefully
  where the hypothesis $n >= 4$ is needed.
]

#exercise[
  Prove by induction that $n^3 - n$ is divisible by $6$ for every $n in NN$.
]

#exercise[
  Prove by strong induction that every integer $n >= 8$ can be written as
  $3a + 5b$ with $a, b$ nonnegative integers. (You will need several base
  cases --- work out how many and why.)
]

#exercise[
  Find the flaw in this "proof" that all horses are the same colour.

  *Claim:* in any set of $n$ horses, all have the same colour.
  *Base:* $n = 1$, trivially true.
  *Step:* given a set of $k+1$ horses, remove one to get $k$ horses, which by
  hypothesis are all the same colour. Put it back and remove a different one;
  again all $k$ are the same colour. So all $k+1$ agree.

  Identify the exact value of $k$ at which the step fails, and explain why.
]

#exercise[
  Write a loop invariant for the following, and use it to prove the routine
  returns the maximum of a nonempty array.
  #algo[
  ```
  function max(A[0..n-1]):
      m := A[0]
      i := 1
      while i < n:
          if A[i] > m: m := A[i]
          i := i + 1
      return m
  ```
  ]
]
