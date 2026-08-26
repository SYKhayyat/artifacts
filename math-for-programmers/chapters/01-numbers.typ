#import "../lib.typ": *

= Numbers

== Why start here

You might reasonably expect a book aimed at a programmer to open somewhere
more interesting than "what is a number". Here is why it does not.

Every hard thing later in this book is a statement about numbers that is not
obvious. "Every bounded increasing sequence converges." "A continuous function
on a closed interval attains its maximum." "The eigenvalues of a real
symmetric matrix are real." Each of those is *false* if you change which
numbers you are talking about. The first two are false over the rationals. The
third is only interesting because it is false in general over the complexes.

So the number systems are not throat-clearing. They are the place where the
later theorems get their teeth. And there is a second reason, closer to home:
the numbers in your computer are *not* the numbers in this book, and knowing
exactly where the two diverge is the difference between code that works and
code that silently produces garbage at scale.

#intuition(title: "each number system is a bug fix")[
  Do not think of $NN subset ZZ subset QQ subset RR subset CC$ as a hierarchy
  of increasing fanciness. Think of it as a changelog.

  Each system is the previous one, patched, because somebody tried to do a
  perfectly reasonable operation and the answer did not exist. Subtraction
  broke $NN$. Division broke $ZZ$. Taking limits broke $QQ$. Square roots of
  negatives broke $RR$. Each time, the fix was to add exactly the missing
  answers and nothing else.

  When you see it that way, the definitions stop being arbitrary. They are
  patch notes.
]

== The natural numbers

#definition(title: "natural numbers")[
  The *natural numbers* are
  $ NN = {0, 1, 2, 3, dots}. $
  Some authors start at $1$. This book starts at $0$, for the same reason your
  arrays do.
]

What actually characterises $NN$ is not the list --- lists trail off into
"$dots$", which is not a definition --- but the *rule for generating it*.
There is a starting element $0$, and there is a successor operation
$s(n) = n + 1$, and every natural number is reached from $0$ by applying $s$
some finite number of times.

That is a recursive data type, and you have declared it before:

#algo(title: "The naturals, as you would declare them")[
```
type Nat =
  | Zero
  | Succ of Nat
```
]

The mathematical name for the fact that this generates *everything* --- that
there are no stray naturals floating around that $0$ and $s$ never reach ---
is the *induction axiom*, and it is the reason proof by induction works. We
will use it constantly from Chapter 7 onwards. It is worth noticing now that
induction is not a clever trick somebody found; it is a restatement of what
$NN$ *is*.

#definition(title: "closure")[
  A set $S$ is *closed* under an operation if applying that operation to
  members of $S$ always lands you back inside $S$.
]

Closure is the organising idea of this chapter. $NN$ is closed under addition
and multiplication: add or multiply two naturals, get a natural. It is *not*
closed under subtraction: $3 - 5$ is not a natural number.

That is the first bug.

== The integers

#definition(title: "integers")[
  The *integers* are
  $ ZZ = {dots, -3, -2, -1, 0, 1, 2, 3, dots}, $
  the naturals together with a negative $-n$ for each $n$, where $-n$ is
  *defined* as the unique solution to $n + x = 0$.
]

The letter is $ZZ$ from the German *Zahlen*, numbers. Note the definition
carefully: we did not say "negative numbers are numbers less than zero" and
leave it at that. We said $-n$ is *the thing you add to $n$ to get $0$*. That
is a functional specification, and it is what makes negatives usable.

$ZZ$ is closed under $+$, $-$, and $times$. A set with those three operations
behaving sensibly is called a *ring*, and $ZZ$ is the ring everyone learns
first.

$ZZ$ is not closed under division: $1 slash 2$ is not an integer.

That is the second bug.

#warning(title: "your integers are not these integers")[
  A 64-bit signed integer in your language of choice is not an element of
  $ZZ$. It is an element of $ZZ slash 2^64 ZZ$ --- the integers modulo
  $2^64$ --- which is a genuinely different mathematical object, and one we
  will study properly in Chapter 12.

  The practical difference: in $ZZ$, if $a > 0$ and $b > 0$ then $a + b > a$.
  In 64-bit arithmetic that is false, and the counterexample is called
  overflow. Every binary-search bug of the form `(lo + hi) / 2` is this
  theorem failing.
]

== The rationals

#definition(title: "rational numbers")[
  The *rational numbers* are
  $ QQ = { p / q : p in ZZ, q in ZZ, q != 0 }, $
  where $p slash q$ and $r slash s$ are regarded as *the same number* exactly
  when $p s = q r$.
]

That last clause is the whole content of the definition and it is worth
pausing on. A rational number is not a pair of integers. It is an
*equivalence class* of pairs of integers: $1 slash 2$, $2 slash 4$ and
$(-3) slash (-6)$ are three names for one object.

This is a pattern you know. It is the difference between a value and its
representation, and between structural and reference equality. Writing
`Fraction(1,2) == Fraction(2,4)` requires you to *define* what equality means
for the type, and cross-multiplication is that definition.

#example(title: "why cross-multiplication is the right rule")[
  We want $p slash q$ to mean "the number $x$ with $q x = p$". If
  $q x = p$ and $s x = r$ describe the same $x$, multiply the first by $s$ and
  the second by $q$: $q s x = p s$ and $q s x = q r$. Hence $p s = q r$.

  So the rule is not a convention. It is forced by what a fraction is
  supposed to mean.
]

$QQ$ is closed under $+$, $-$, $times$, and $div$ by anything nonzero. A set
with all four is a *field*, and fields are the natural home of linear algebra
(Part IV).

So $QQ$ has all four arithmetic operations. Why is it not enough?

== The gap in the rationals

Here is the first genuine theorem in this book, and it is one of the oldest
in mathematics. Read the proof slowly; it is the model for a great deal of
what follows.

#theorem(title: "irrationality of the square root of 2")[
  There is no rational number $x$ with $x^2 = 2$.
]

#proof[
  Suppose, for contradiction, that there is one. Then we can write it as
  $x = p slash q$ with $p, q in ZZ$, $q != 0$, and --- this is the move that
  makes the proof work --- with $p$ and $q$ having *no common factor*. We may
  always assume this, because if they had a common factor we could cancel it
  and rename.

  From $x^2 = 2$ we get
  $ p^2 / q^2 = 2, quad "so" quad p^2 = 2 q^2. $

  So $p^2$ is even. Now, if $p$ were odd, say $p = 2k+1$, then
  $p^2 = 4k^2 + 4k + 1$, which is odd. So $p$ cannot be odd: $p$ is even.
  Write $p = 2m$.

  Substituting: $(2m)^2 = 2q^2$, that is $4m^2 = 2q^2$, that is
  $q^2 = 2m^2$.

  By the identical argument, $q$ is even.

  But now $p$ and $q$ are both even, so they share the common factor $2$ ---
  contradicting the assumption that they had none.

  The assumption that a rational square root of $2$ exists leads to a
  contradiction, so no such rational exists.
]

#intuition(title: "what just happened")[
  Three techniques appeared, and you will use all three for the rest of your
  life.

  *Proof by contradiction.* Assume the thing you want to disprove, derive
  something impossible, conclude the assumption was wrong.

  *Choosing a good representative.* "In lowest terms" was not decoration; the
  contradiction was manufactured entirely out of it. Picking the right
  representative of an equivalence class is a recurring, powerful move.

  *Descent.* Notice the shape: from a solution we built a *smaller* solution
  ($p slash 2, q slash 2$ also works). An infinite chain of strictly smaller
  positive integers is impossible. That is the same well-foundedness argument
  you use to prove a recursion terminates.
]

So the rationals have holes. The diagonal of a unit square has a length, and
that length is not a rational number. Worse, this is not a rare defect: we
will see in Chapter 17 that in a precise sense *almost every* number is
irrational.

== The real numbers

The fix is $RR$: fill in the holes. Making that precise took mathematicians
about two thousand years, and there are two standard constructions (Dedekind
cuts and Cauchy sequences). We will not build $RR$ from scratch --- that is a
real analysis course --- but we must state the property that distinguishes it,
because every theorem in calculus rests on it.

#definition(title: "upper bound and supremum")[
  Let $S subset.eq RR$ be nonempty. A number $b$ is an *upper bound* for $S$
  if $x <= b$ for every $x in S$.

  A number $b$ is the *least upper bound*, or *supremum*, written $sup S$, if
  it is an upper bound and no smaller number is an upper bound.
]

#theorem(title: "completeness of the reals")[
  Every nonempty subset of $RR$ that has an upper bound has a least upper
  bound in $RR$.
]

This is an axiom rather than something we prove --- it is part of what "the
real numbers" means. Its importance is best seen by watching it fail.

#example(title: "completeness fails over the rationals")[
  Let $S = {x in QQ : x^2 < 2}$. Inside $QQ$, $S$ is nonempty and bounded
  above (by $2$, say). But it has no least upper bound *in $QQ$*: for any
  rational upper bound you propose, there is a smaller rational one, because
  the only candidate for the least is $sqrt(2)$ and that is not available.

  Concretely, this is why the bisection root-finder of Chapter 33 works.
  Bisection on $f(x) = x^2 - 2$ produces a sequence of ever-tighter intervals
  whose endpoints are rational. Over $QQ$ the process converges to nothing at
  all. Over $RR$ it converges, and completeness is precisely the guarantee
  that it does.
]

#intuition(title: "completeness in one sentence")[
  Completeness says: *if a sequence of numbers is closing in on something,
  there is something there for it to close in on.* Every convergence theorem
  in calculus is a cash-out of that single promise.
]

=== Decimal expansions

Every real number has a decimal expansion, and rationals are exactly the ones
whose expansion eventually repeats.

#proposition[
  A real number is rational if and only if its decimal expansion is eventually
  periodic.
]

#proof[
  ($arrow.r.double$) Compute $p slash q$ by long division. At each step the
  state of the algorithm is the current remainder, which is one of the $q$
  values $0, 1, dots, q-1$. After at most $q$ steps a remainder must repeat
  --- there are only finitely many states --- and from that point the digits
  repeat with the same period. This is the pigeonhole principle (Chapter 9),
  and it is also just the observation that a finite-state machine must
  eventually cycle.

  ($arrow.l.double$) Suppose the expansion repeats with period $k$ from some
  point on. Let $x$ be the number and shift the decimal point: $10^m x$ and
  $10^(m+k) x$ have *identical* tails. Subtract, and the infinite tails cancel
  exactly, leaving
  $ (10^(m+k) - 10^m) x = "some integer", $
  so $x$ is that integer divided by the integer $10^(m+k) - 10^m$, hence
  rational.
]

#example(title: "the 0.999... business")[
  Apply the second half of that proof to $x = 0.overline(9)$. Here $m = 0$,
  $k = 1$, so $10x - x = 9$, giving $9x = 9$ and $x = 1$.

  This is not a trick or an approximation. $0.overline(9)$ and $1$ are two
  decimal strings naming the same real number, the same way `1.0` and `1.00`
  name the same value. The map from decimal strings to reals is surjective but
  not injective, and this is the only way it fails to be injective.
]

== How many numbers are there?

Here is a result that has no business being as surprising as it is, and it is
directly relevant to computation.

#definition(title: "countable")[
  A set is *countable* if its elements can be listed in a sequence
  $a_1, a_2, a_3, dots$ such that every element appears exactly once. Equivalently,
  it can be put in one-to-one correspondence with $NN$.
]

$ZZ$ is countable: list it as $0, 1, -1, 2, -2, 3, -3, dots$. Nothing is
missed, nothing is repeated.

#theorem(title: "the rationals are countable")[
  $QQ$ is countable.
]

#proof[
  Every positive rational in lowest terms is a pair $(p, q)$ of positive
  integers with no common factor. Order these pairs by $p + q$ (finitely many
  pairs for each value of the sum), and within each group by $p$. This
  enumerates every positive rational exactly once:
  $ 1/1, quad 1/2, 2/1, quad 1/3, 3/1, quad 1/4, 2/3, 3/2, 4/1, quad dots $
  Then interleave with the negatives and $0$ as we did for $ZZ$.
]

#theorem(title: "the reals are not countable")[
  $RR$ is not countable.
]

#proof[
  It suffices to show the interval $(0,1)$ is not countable. Suppose it were,
  and let
  $ a_1, a_2, a_3, dots $
  be a complete list, each written as a decimal $a_n = 0.d_(n 1) d_(n 2) d_(n 3) dots$
  (to avoid the $0.overline(9)$ ambiguity above, always choose the expansion
  that does not end in all nines).

  Now construct a new number $b = 0.b_1 b_2 b_3 dots$ by the rule
  $ b_n = cases(5 quad &"if" d_(n n) != 5, 4 quad &"if" d_(n n) = 5). $

  Then $b in (0,1)$, and $b$ differs from $a_n$ in its $n$-th digit, for every
  $n$. So $b$ is not on the list. But the list was supposed to contain every
  number in $(0,1)$ --- contradiction.
]

#intuition(title: "why a programmer should care about the diagonal")[
  That proof is the ancestor of the halting problem, of Gödel's incompleteness
  theorems, and of Russell's paradox. The shape is always the same: you are
  handed an enumeration that claims to be complete, and you build the one
  object that is deliberately different from the $n$-th entry in the $n$-th
  place.

  There is also a blunt computational corollary. There are only countably many
  finite programs (a program is a finite string over a finite alphabet, and
  those are countable). There are uncountably many real numbers. Therefore
  *almost every real number is not computable* --- no program produces its
  digits. The numbers you can actually name --- $pi$, $e$, $sqrt(2)$, every
  number in every paper ever written --- form a set of measure zero inside the
  reals.
]

== Order, absolute value, intervals

#definition(title: "absolute value")[
  For $x in RR$,
  $ abs(x) = cases(x quad &"if" x >= 0, -x quad &"if" x < 0). $
  It is the distance from $x$ to $0$; and $abs(x - y)$ is the distance between
  $x$ and $y$.
]

Reading $abs(x-y)$ as *distance* rather than as a case-split is the single
most useful reflex in analysis. Almost every $epsilon$ in Chapter 13 is a
statement about distances.

#theorem(title: "triangle inequality")[
  For all $x, y in RR$: $ abs(x + y) <= abs(x) + abs(y). $
]

#proof[
  For any real $t$ we have $-abs(t) <= t <= abs(t)$, directly from the
  definition. Applying this to $x$ and to $y$ and adding the two chains:
  $ -(abs(x) + abs(y)) <= x + y <= abs(x) + abs(y). $
  A number $u$ satisfying $-c <= u <= c$ with $c >= 0$ satisfies
  $abs(u) <= c$: if $u >= 0$ then $abs(u) = u <= c$, and if $u < 0$ then
  $abs(u) = -u <= c$ from the left inequality. Apply that with $u = x+y$ and
  $c = abs(x) + abs(y)$.
]

The name comes from the geometric version: the direct route from $A$ to $C$ is
no longer than going via $B$. In the form $abs(x - z) <= abs(x-y) + abs(y-z)$
that reading is literal, and this is the version you will use.

#definition(title: "intervals")[
  For $a < b$:
  $ (a,b) = {x : a < x < b}, quad [a,b] = {x : a <= x <= b}, $
  and the half-open $[a,b)$, $(a,b]$ analogously. A square bracket includes
  the endpoint, a round bracket excludes it. We also allow
  $(a, infinity) = {x : x > a}$ and similar; $infinity$ is never an endpoint
  that gets included, because it is not a number.
]

The distinction between $[a,b]$ and $(a,b)$ looks pedantic and is not. The
Extreme Value Theorem (Chapter 13) is true on $[0,1]$ and false on $(0,1)$:
the function $f(x) = x$ has no maximum on the open interval, because for any
candidate there is a larger $x$ still inside. Half-open intervals are also
exactly the convention behind Python slicing and C++ iterator ranges, for the
same reason: $[a,b)$ concatenates cleanly with $[b,c)$.

== The numbers in your machine

Everything above is mathematics. Here is what your CPU actually has.

#definition(title: "floating point, informally")[
  An IEEE-754 double is a number of the form
  $ plus.minus m times 2^e $
  where the *significand* $m$ has 53 bits of precision and the exponent $e$ is
  an integer in a bounded range. There are finitely many of them --- about
  $2^64$ --- and they are not evenly spaced: they are dense near zero and
  sparse far from it.
]

Three consequences, each of which is a mathematical statement failing:

*Floats are not closed under arithmetic.* The sum of two doubles is generally
not a double, so it is rounded. Therefore addition is *not associative*:
$(a + b) + c$ and $a + (b + c)$ can differ. Every parallel reduction in your
codebase is nondeterministic for this reason.

*Floats are not dense.* Between any two distinct reals there is another real.
Between two adjacent doubles there is nothing. Near $1$, the gap is about
$2.2 times 10^(-16)$ (this is *machine epsilon*); near $10^16$, the gap
exceeds $1$, so incrementing does nothing at all.

*Floats are not the rationals either.* $0.1$ is a perfectly good rational and
is *not* representable, because $1 slash 10$ in binary is a repeating
expansion --- exactly the phenomenon of the proposition above, in base 2.
Hence the famous `0.1 + 0.2 != 0.3`.

#warning(title: "the practical rule")[
  Never test floating-point values with `==`. Test $abs(x - y) < epsilon$ for
  a tolerance $epsilon$ chosen with reference to the *magnitude* of $x$ and
  $y$, not an absolute constant --- because the spacing scales with magnitude.
  Chapter 33 makes this quantitative and gives the correct relative-error
  form.
]

None of this makes the mathematics useless; it makes it *necessary*. You
cannot reason about the error of a computation without first knowing what the
exact answer would have been.

== Exercises

#exercise[
  Prove that $sqrt(3)$ is irrational. Then explain exactly where the same
  argument breaks down if you try to run it on $sqrt(4)$ --- it must break
  down somewhere, since $sqrt(4) = 2$ is rational.
]

#exercise[
  Show that the sum of a rational and an irrational number is always
  irrational. Then show, by giving examples, that the sum of two irrationals
  can be either rational or irrational.
]

#exercise[
  Convert $0.overline(142857)$ to a fraction using the shift-and-subtract
  technique from the proposition on decimal expansions.
]

#exercise[
  Prove the *reverse triangle inequality*:
  $ abs( abs(x) - abs(y) ) <= abs(x - y). $
  Hint: write $x = (x - y) + y$ and apply the ordinary triangle inequality.
]

#exercise[
  Is the set of all finite-length strings over the alphabet ${a, b}$
  countable? Is the set of all *infinite* strings over ${a,b}$ countable?
  Justify both answers.
]

#exercise[
  In IEEE-754 double precision, find a concrete triple $a, b, c$ for which
  $(a+b)+c != a+(b+c)$, and explain in terms of rounding why your example
  works. You may reason about it on paper; you do not need to run it.
]

#exercise[
  Let $S = {1 - 1/n : n in NN, n >= 1}$. Write down $sup S$. Is $sup S$ an
  element of $S$? Explain what this shows about the difference between a
  supremum and a maximum.
]
