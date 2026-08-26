#import "../lib.typ": *

= Probability

== What probability is a theory of

Probability is the mathematics of *not knowing*. That is a broader remit than
gambling, and the two standard interpretations of what a probability *means*
disagree about how broad.

*Frequentist:* a probability is a long-run frequency. "This coin has
$PP("heads") = 0.5$" means that in many tosses, about half come up heads.
Clean, but it says nothing about one-off events.

*Bayesian:* a probability is a degree of belief. "There is a 30% chance this
service fails today" is meaningful even though today happens once. Beliefs
update as evidence arrives (Bayes' theorem, below).

The *mathematics* is identical under both readings --- the axioms are the same
--- and the disagreement is about interpretation and about which statistical
procedures follow. Chapter 31 returns to it. Until then, nothing depends on
which camp you sit in.

== The axioms

#definition(title: "probability space")[
  A *probability space* is a triple $(Omega, cal(F), PP)$:

  - $Omega$, the *sample space*: the set of all possible outcomes.
  - $cal(F)$, a collection of subsets of $Omega$ called *events*, closed
    under complement and countable union.
  - $PP : cal(F) -> [0,1]$, satisfying Kolmogorov's axioms:
    #set enum(numbering: "(P1)")
    + $PP(A) >= 0$ for every event $A$;
    + $PP(Omega) = 1$;
    + if $A_1, A_2, dots$ are pairwise *disjoint*, then
      $PP(union.big_i A_i) = sum_i PP(A_i)$.
]

That is the whole foundation. Three axioms.

#intuition(title: "why events are sets, and why that is useful")[
  An *outcome* is a single result: this die shows 4. An *event* is a *set* of
  outcomes: "the die shows an even number" is ${2,4,6\}$.

  Making events sets means the logic of Chapter 7 and the set operations of
  Chapter 8 transfer directly:

  #align(center)[
    #table(
      columns: 2, inset: 6pt, stroke: 0.4pt + luma(180),
      align: (left, left),
      table.header([*English*], [*Set operation*]),
      [$A$ or $B$], [$A union B$],
      [$A$ and $B$], [$A inter B$],
      [not $A$], [$overline(A)$],
      [$A$ but not $B$], [$A without B$],
      [$A$ and $B$ cannot both happen], [$A inter B = emptyset$],
    )
  ]

  So probability inherits an entire algebra for free, and De Morgan's laws are
  as useful here as they were there.
]

#proposition(title: "immediate consequences")[
  #set enum(numbering: "(a)")
  + $PP(overline(A)) = 1 - PP(A)$.
  + $PP(emptyset) = 0$.
  + If $A subset.eq B$ then $PP(A) <= PP(B)$.
  + $PP(A union B) = PP(A) + PP(B) - PP(A inter B)$.
]

#proof[
  *(a)* $A$ and $overline(A)$ are disjoint with union $Omega$, so by (P3) and
  (P2), $PP(A) + PP(overline(A)) = 1$.

  *(c)* Write $B = A union (B without A)$, a disjoint union, so
  $PP(B) = PP(A) + PP(B without A) >= PP(A)$ by (P1).

  *(d)* Write $A union B = A union (B without A)$, disjoint, and
  $B = (A inter B) union (B without A)$, also disjoint. Then
  $ PP(A union B) = PP(A) + PP(B without A) = PP(A) + PP(B) - PP(A inter B). $
]

Item (d) is Chapter 8's inclusion--exclusion, now for probabilities. The
general $n$-set version holds verbatim.

#definition(title: "uniform probability on a finite space")[
  If $Omega$ is finite and all outcomes are equally likely,
  $ PP(A) = abs(A) / abs(Omega). $
]

This is the bridge to Chapter 9: under the equally-likely assumption, every
probability question is a counting question. Most introductory probability is
combinatorics wearing a different hat.

#warning(title: "'equally likely' is an assumption, not a default")[
  It has to be justified, and it is often wrong.

  Two dice: the sums $2$ through $12$ are *not* equally likely, because the
  underlying equally-likely objects are the 36 ordered pairs, and more of them
  sum to 7 than to 2.

  Similarly, "the next request either hits cache or misses, so it is 50/50" is
  nonsense. Symmetry is what justifies uniformity, and you must be able to
  point to the symmetry.
]

== Conditional probability

#definition(title: "conditional probability")[
  For $PP(B) > 0$,
  $ PP(A | B) = (PP(A inter B))/(PP(B)). $
]

#intuition(title: "conditioning is zooming in")[
  Learning that $B$ happened means the sample space is no longer $Omega$; it
  is $B$. So you renormalise: the probability of $A$ is now the share of $B$
  that also lies in $A$.

  The division by $PP(B)$ is exactly that renormalisation --- it makes the
  probabilities within $B$ sum to 1 again. Conditioning is restricting your
  universe and rescaling.

  It is also, incidentally, a perfectly good probability measure in its own
  right: $PP(dot | B)$ satisfies all three Kolmogorov axioms. So everything
  you know about probability applies inside a conditional world, and you can
  condition on more things without any new theory.
]

Rearranging gives the *multiplication rule*
$ PP(A inter B) = PP(A | B) PP(B) = PP(B | A) PP(A), $
and by induction the *chain rule*
$ PP(A_1 inter dots.c inter A_n) = PP(A_1) PP(A_2 | A_1) PP(A_3 | A_1 inter A_2) dots.c $
which is the identity underneath every autoregressive language model: the
probability of a sequence is the product of the conditional probabilities of
each token given its predecessors.

#definition(title: "independence")[
  $A$ and $B$ are *independent* if
  $ PP(A inter B) = PP(A) PP(B), $
  equivalently (when $PP(B) > 0$) if $PP(A | B) = PP(A)$: knowing $B$ tells
  you nothing about $A$.
]

#warning(title: "independent is not the same as disjoint")[
  They are almost opposites, and the words get confused constantly.

  *Disjoint* means $A inter B = emptyset$: they cannot both happen. So if $A$
  happens, $B$ definitely did not --- which is a very strong dependence. Two
  disjoint events with positive probability are *never* independent.

  *Independent* means they do not inform each other. Independent events with
  positive probability *must* overlap, since $PP(A inter B) = PP(A)PP(B) > 0$.
]

Also worth knowing: *pairwise* independence does not imply *mutual*
independence. Toss two fair coins and let $A$ = first is heads, $B$ = second
is heads, $C$ = the two agree. Any two of these are independent; but
$PP(A inter B inter C) = 1 slash 4 != 1 slash 8$. Knowing any two determines
the third.

== Total probability and Bayes

#theorem(title: "law of total probability")[
  If $B_1, dots, B_n$ partition $Omega$ (disjoint, union is everything, each
  with positive probability), then for any $A$:
  $ PP(A) = sum_(i=1)^n PP(A | B_i) PP(B_i). $
]

#proof[
  The sets $A inter B_i$ are disjoint and their union is $A$, so by (P3)
  $PP(A) = sum_i PP(A inter B_i)$. Apply the multiplication rule to each
  term.
]

This is *case analysis for probabilities* --- split on which $B_i$ happened,
work out the probability in each case, and average with the case probabilities
as weights.

#theorem(title: "Bayes' theorem")[
  $ PP(B | A) = (PP(A | B) PP(B))/(PP(A)), $
  and expanding the denominator by total probability over a partition
  ${B_i}$:
  $ PP(B_j | A) = (PP(A | B_j) PP(B_j))/(sum_i PP(A|B_i) PP(B_i)). $
]

#proof[
  Both $PP(A|B)PP(B)$ and $PP(B|A)PP(A)$ equal $PP(A inter B)$. Equate and
  divide.
]

The proof is one line. The importance is entirely in what it lets you do.

#intuition(title: "Bayes reverses the direction of a conditional")[
  You usually know $PP("evidence" | "hypothesis")$ --- that is what a test, a
  model, or a physical process gives you. You want
  $PP("hypothesis" | "evidence")$ --- that is what you actually need to decide
  anything.

  Bayes converts one into the other, at the cost of requiring a *prior*
  $PP("hypothesis")$.

  The vocabulary:
  $ underbrace(PP(H|E), "posterior") = (overbrace(PP(E|H), "likelihood") dot overbrace(PP(H), "prior"))/(underbrace(PP(E), "evidence")). $

  And the reason the prior cannot be dropped is the single most important
  practical lesson in probability, which is the next example.
]

#example(title: "the medical test, and why base rates dominate")[
  A disease affects 1 in 10,000. A test has 99% sensitivity
  ($PP("positive" | "disease") = 0.99$) and 99% specificity
  ($PP("negative" | "no disease") = 0.99$).

  You test positive. What is the probability you have the disease?

  The intuitive answer is 99%. The correct answer:
  $
  PP(D | +) &= (PP(+|D) PP(D))/(PP(+|D)PP(D) + PP(+|overline(D))PP(overline(D))) \
  &= (0.99 times 0.0001)/(0.99 times 0.0001 + 0.01 times 0.9999) \
  &= (0.000099)/(0.000099 + 0.009999) approx 0.0098.
  $

  *About 1%.* Not 99%.

  The reason: out of a million people, 100 have the disease and 99 test
  positive; 999,900 are healthy and 9,999 of them *also* test positive. False
  positives outnumber true positives 100 to 1, because there are so many more
  healthy people. The test is good; the base rate is brutal.

  This is *base rate neglect*, and it is not a curiosity. It is why:

  - a rare-event alert with a 1% false positive rate is mostly false alarms,
    and your on-call engineers will learn to ignore it;
  - a fraud detector with excellent accuracy still floods review queues;
  - a "99.9% accurate" screening test for anything rare is nearly useless
    alone.

  The fix in every case is the same: compute the posterior, not the accuracy.
]

#example(title: "Monty Hall")[
  Three doors, a car behind one. You pick door 1. The host --- who *knows*
  where the car is and always opens a different, empty door --- opens door 3.
  Switch to door 2, or stay?

  Let $C_i$ be "car behind door $i$", each with prior $1 slash 3$, and let $H_3$
  be "host opens door 3".

  $PP(H_3 | C_1) = 1 slash 2$ (the host may open 2 or 3 freely).
  $PP(H_3 | C_2) = 1$ (the host must avoid your door and the car).
  $PP(H_3 | C_3) = 0$.

  By Bayes,
  $ PP(C_1 | H_3) = ((1 slash 2)(1 slash 3))/((1 slash 2)(1 slash 3) + 1 dot (1 slash 3) + 0) = (1 slash 6)/(1 slash 2) = 1/3, $
  and $PP(C_2 | H_3) = 2 slash 3$. *Switch.*

  Where the intuition fails: the host's action is not random. He is
  constrained by knowledge, so his choice carries information. If a
  *bystander* opened door 3 at random and happened to reveal a goat, then
  $PP(H_3|C_1) = PP(H_3|C_2) = 1 slash 2$ and the posterior really is
  $1 slash 2$ each --- switching gains nothing.

  Same observed outcome, different probability, because the *process* that
  generated the observation differs. Getting that right is most of applied
  probability.
]

== Simulation, and how to think about randomness in code

Two practical notes that belong here rather than in a footnote.

*Pseudorandom generators are deterministic.* `rand()` is a deterministic
function of hidden state. That is a feature: seeding makes experiments
reproducible. It is also a hazard: linear congruential generators have
detectable structure, and using one for anything security-related is a
vulnerability. Use a cryptographic generator when an adversary is involved and
a well-tested one (PCG, xoshiro, Mersenne Twister) otherwise.

*Sampling from a distribution.* If $U tilde Unif(0,1)$ and $F$ is a
cumulative distribution function (Chapter 28), then $F^(-1)(U)$ has
distribution $F$. This is *inverse transform sampling*, and it is why a single
uniform generator suffices for everything --- when $F^(-1)$ is available. When
it is not (the normal distribution, for one), you use rejection sampling or a
special-purpose method like Box--Muller.

#example(title: "estimating $pi$ by Monte Carlo")[
  Sample points uniformly in $[0,1]^2$ and count the fraction landing inside
  the quarter disc $x^2 + y^2 <= 1$. That fraction estimates the area,
  $pi slash 4$.

  With $n$ samples the standard error is $O(1 slash sqrt(n))$ --- Chapter 30
  proves this. So $100 times$ more samples buys $10 times$ more accuracy: four
  digits costs about $10^8$ samples. Monte Carlo is a *terrible* way to
  compute $pi$.

  Its virtue is that the $O(1 slash sqrt(n))$ rate is *independent of
  dimension*. Deterministic quadrature (Chapter 16) in $d$ dimensions needs
  $n^d$ grid points for comparable accuracy --- the curse of dimensionality.
  So in high dimensions Monte Carlo wins by an enormous margin, which is why
  it dominates in finance, rendering, and Bayesian inference, and why nobody
  uses Simpson's rule on a 50-dimensional integral.
]

== Exercises

#exercise[
  Two fair dice are rolled. Find the probability that (a) the sum is 7,
  (b) the sum is 7 given that the first die shows 3, (c) at least one die
  shows 6, (d) the sum is 7 and at least one die shows 6. Are the events in
  (a) and (c) independent?
]

#exercise[
  Prove that if $A$ and $B$ are independent, then so are $A$ and
  $overline(B)$.
]

#exercise[
  A bag has 5 red and 3 blue balls. Two are drawn without replacement. Find
  the probability that (a) both are red, (b) the second is red, (c) the first
  is red given the second is red. Comment on why (b) has the answer it does.
]

#exercise[
  A spam filter flags 95% of spam and misflags 2% of legitimate mail. If 40%
  of incoming mail is spam, what is the probability that a flagged message is
  actually spam? Redo the calculation for a 1% spam rate and comment on the
  difference.
]

#exercise[
  Three events $A$, $B$, $C$ are pairwise independent but not mutually
  independent. Construct an explicit example on a sample space of size 4 and
  verify both claims.
]

#exercise[
  In a room of $n$ people, use the birthday calculation of Chapter 9 to find
  the smallest $n$ for which the probability of a shared birthday exceeds
  $1 slash 2$. Then find the $n$ at which it exceeds $0.99$.
]

#exercise[
  You have two coins: one fair, one double-headed. You pick one at random and
  flip it three times, getting three heads. What is the probability you picked
  the double-headed coin?
]

#exercise[
  Prove the law of total probability implies Bayes' theorem in the expanded
  form given, and explain in one sentence what the denominator represents.
]
