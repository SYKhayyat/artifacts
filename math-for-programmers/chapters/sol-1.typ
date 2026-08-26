#import "../lib.typ": *

== Chapter 1 --- Numbers

#soln("1.1")[
  Suppose $sqrt(3) = p slash q$ in lowest terms. Then $p^2 = 3 q^2$, so
  $3 divides p^2$.

  *Claim:* $3 divides p^2$ implies $3 divides p$. Check the cases: if
  $p = 3k+1$ then $p^2 = 9k^2 + 6k + 1 equiv 1$; if $p = 3k+2$ then
  $p^2 = 9k^2 + 12k + 4 equiv 1 space (mod 3)$. So an integer not divisible by
  3 has a square not divisible by 3.

  Hence $p = 3m$, giving $9m^2 = 3q^2$, so $q^2 = 3m^2$ and by the same claim
  $3 divides q$. Both divisible by 3, contradicting lowest terms.

  *Where it breaks for $sqrt(4)$.* The claim fails: $4 divides p^2$ does *not*
  imply $4 divides p$. Take $p = 2$: $p^2 = 4$ is divisible by 4, $p$ is not.
  The claim needs the divisor to be *prime* (Euclid's lemma, Chapter 12), and
  4 is not. This is precisely why $sqrt(n)$ is irrational exactly when $n$ is
  not a perfect square.
]

#soln("1.2")[
  Let $r$ be rational and $x$ irrational, and suppose $r + x = s$ were
  rational. Then $x = s - r$ is a difference of two rationals, hence rational
  --- contradiction. So $r + x$ is irrational.

  Two irrationals can sum either way: $sqrt(2) + (-sqrt(2)) = 0$ is rational,
  while $sqrt(2) + sqrt(2) = 2 sqrt(2)$ is irrational (if it were rational,
  halving it would make $sqrt(2)$ rational).
]

#soln("1.3")[
  Let $x = 0.overline(142857)$, period 6. Then $10^6 x = 142857.overline(142857)$,
  so
  $ 10^6 x - x = 142857 quad arrow.r.double quad x = 142857/999999. $
  Both are divisible by $142857$: indeed $999999 = 7 times 142857$, so
  $x = 1 slash 7$.
]

#soln("1.4")[
  Write $x = (x - y) + y$ and apply the triangle inequality:
  $ abs(x) <= abs(x-y) + abs(y) quad arrow.r.double quad abs(x) - abs(y) <= abs(x-y). $
  Swapping the roles of $x$ and $y$ gives
  $abs(y) - abs(x) <= abs(y-x) = abs(x-y)$.

  So both $abs(x)-abs(y)$ and its negative are at most $abs(x-y)$, which is
  exactly $abs(abs(x)-abs(y)) <= abs(x-y)$.
]

#soln("1.5")[
  *Finite strings: countable.* There are $2^k$ strings of length $k$, finitely
  many. List all length-0 strings, then all length-1, then all length-2, and
  so on, alphabetically within each block. Every finite string has some finite
  length, so it appears in some block and therefore at some finite position.

  *Infinite strings: uncountable.* Suppose $s_1, s_2, dots$ were a complete
  list. Build $t$ whose $n$-th character is $a$ if the $n$-th character of
  $s_n$ is $b$, and $b$ otherwise. Then $t$ differs from every $s_n$ in
  position $n$, so it is not on the list. This is Cantor's diagonal argument
  verbatim; indeed infinite binary strings are in bijection with subsets of
  $NN$, and with $[0,1]$ up to the $0.overline(9)$ ambiguity.
]

#soln("1.6")[
  Take $a = 10^16$, $b = -10^16$, $c = 1$.

  $(a+b)+c$: the first sum is exactly $0$, so the result is $1$.

  $a+(b+c)$: near $10^16$ the spacing between doubles is $2$ (since
  $10^16 > 2^53 approx 9.007 times 10^15$). So $-10^16 + 1$ falls exactly
  halfway between two representable values and rounds to $-10^16$ under
  round-half-to-even. Then $a + (-10^16) = 0$.

  So the two groupings give $1$ and $0$. The mechanism: the addition $b + c$
  is *absorbed* --- $c$ is smaller than the representation gap at $b$'s
  magnitude, so it vanishes entirely.
]

#soln("1.7")[
  $S = {0, 1 slash 2, 2 slash 3, 3 slash 4, dots}$. Every element is less than
  $1$, so $1$ is an upper bound. And no smaller number is: given any $b < 1$,
  choose $n > 1 slash (1-b)$, and then $1 - 1 slash n > b$. So $sup S = 1$.

  But $1 in.not S$, since $1 - 1 slash n = 1$ would need $1 slash n = 0$.

  This is exactly the difference between a supremum and a maximum: the maximum
  is a supremum that happens to be *attained*. Every nonempty bounded-above
  set has a supremum (completeness); not every one has a maximum. The Extreme
  Value Theorem of Chapter 13 is precisely a statement that in certain
  circumstances the supremum *is* attained.
]

== Chapter 2 --- Algebra as a Rewriting System

#soln("2.1")[
  Suppose $a + z = a$ for every $a$. Apply it with $a = 0$: $0 + z = 0$.

  But by commutativity (F1) and the identity axiom (F3),
  $0 + z = z + 0 = z$.

  So $z = 0$. Note the shape of the argument: a claim about *all* $a$ is
  pinned down by choosing one convenient $a$.
]

#soln("2.2")[
  $sqrt(2x+3) = x$. Squaring gives $2x + 3 = x^2$, so $x^2 - 2x - 3 = 0$,
  factoring as $(x-3)(x+1) = 0$: candidates $x = 3$ and $x = -1$.

  *Squaring is the one-way step* --- it is not injective, so it can gain
  solutions. Both candidates must be checked in the original equation.

  $x = 3$: $sqrt(9) = 3$. Valid.
  $x = -1$: $sqrt(1) = 1 != -1$. Rejected.

  There is also a structural reason $x = -1$ cannot work: $sqrt(dot)$ is
  nonnegative by definition, so the equation forces $x >= 0$ before any
  algebra happens. Answer: $x = 3$.
]

#soln("2.3")[
  $
  2x^2 - 12x + 7 = 2(x^2 - 6x) + 7 = 2[(x-3)^2 - 9] + 7 = 2(x-3)^2 - 11.
  $
  Since $(x-3)^2 >= 0$ with equality only at $x = 3$, the minimum value is
  $-11$, attained at $x = 3$.

  No calculus needed: a square is nonnegative, so the expression is minimised
  when the square vanishes.
]

#soln("2.4")[
  Telescope $sum_(i=1)^n [(i+1)^4 - i^4] = (n+1)^4 - 1$.

  Expanding, $(i+1)^4 - i^4 = 4i^3 + 6i^2 + 4i + 1$, so
  $ 4 sum i^3 + 6 sum i^2 + 4 sum i + n = (n+1)^4 - 1. $

  Substituting the known sums $sum i = n(n+1) slash 2$ and
  $sum i^2 = n(n+1)(2n+1) slash 6$:
  $ 4 sum i^3 = (n+1)^4 - 1 - n - 2n(n+1) - n(n+1)(2n+1). $

  Expanding the right side: $(n+1)^4 - 1 - n = n^4 + 4n^3 + 6n^2 + 3n$, and
  $2n(n+1) + n(n+1)(2n+1) = 2n^3 + 5n^2 + 3n$. Subtracting,
  $4 sum i^3 = n^4 + 2n^3 + n^2 = n^2 (n+1)^2$, so
  $ sum_(i=1)^n i^3 = ( (n(n+1))/2 )^2. $

  Check at $n = 3$: $1 + 8 + 27 = 36 = 6^2$. ✓
]

#soln("2.5")[
  $x^2 - x - 6 = (x-3)(x+2)$, so write
  $ (5x-4)/((x-3)(x+2)) = A/(x-3) + B/(x+2), quad 5x - 4 = A(x+2) + B(x-3). $
  Put $x = 3$: $11 = 5A$, so $A = 11 slash 5$.
  Put $x = -2$: $-14 = -5B$, so $B = 14 slash 5$.
  $ (5x-4)/(x^2-x-6) = (11 slash 5)/(x-3) + (14 slash 5)/(x+2). $
]

#soln("2.6")[
  Move everything to one side rather than cross-multiplying:
  $ (x-1)/(x+2) - 1 >= 0 quad arrow.r.double quad ((x-1)-(x+2))/(x+2) >= 0 quad arrow.r.double quad (-3)/(x+2) >= 0. $
  The numerator is the negative constant $-3$, so the fraction is nonnegative
  exactly when the denominator is negative: $x + 2 < 0$, i.e. $x < -2$. (It is
  never zero, so the inequality is strict in effect.)

  Solution set: $(-infinity, -2)$.

  *What goes wrong with cross-multiplication.* Multiplying both sides by
  $x+2$ gives $x - 1 >= x + 2$, i.e. $-1 >= 2$, which is false --- so you would
  conclude there are no solutions. The error is that $x + 2$ may be negative,
  in which case the inequality must flip. The sign of the multiplier is
  unknown, so the step is illegal.
]

#soln("2.7")[
  $(x-y)^2 >= 0$ for all real $x,y$, since squares of reals are nonnegative.
  Expanding: $x^2 - 2x y + y^2 >= 0$, so $x^2 + y^2 >= 2x y$. Equality holds iff
  $x - y = 0$, i.e. $x = y$.

  Now substitute $x = sqrt(a)$, $y = sqrt(b)$ for $a, b >= 0$:
  $ a + b >= 2 sqrt(a) sqrt(b) = 2 sqrt(a b), $
  which rearranges to $(a+b) slash 2 >= sqrt(a b)$: AM--GM, with equality iff
  $sqrt(a) = sqrt(b)$, i.e. $a = b$.
]

#soln("2.8")[
  $p$ has degree 3 and four distinct roots $0,1,2,3$.

  By the corollary to the factor theorem, a *nonzero* polynomial of degree $n$
  has at most $n$ roots. Four roots exceed the bound for degree 3, so $p$
  cannot be a nonzero polynomial of degree 3.

  The only resolution is that $p$ is the zero polynomial --- which has every
  number as a root and no well-defined degree. (Strictly, the hypothesis "$p$
  has degree 3" is inconsistent with the four roots; the exercise's point is
  that you should notice the inconsistency rather than hunt for a cubic.)
]

== Chapter 3 --- Functions

#soln("3.1")[
  *(a) $f : ZZ -> ZZ$, $f(n) = 2n$.* Injective: $2a = 2b$ gives $a = b$. Not
  surjective: no integer maps to $1$.

  *(b) $f : ZZ -> ZZ$, $f(n) = floor(n slash 2)$.* Not injective:
  $f(0) = f(1) = 0$. Surjective: $f(2k) = k$ for every $k$.

  *(c) $f : RR -> RR$, $f(x) = x^3 - x$.* Not injective:
  $f(-1) = f(0) = f(1) = 0$. Surjective: it is a continuous odd-degree
  polynomial, so it takes arbitrarily large positive and negative values and
  by the Intermediate Value Theorem hits everything between.

  *(d) $f : RR -> (0,infinity)$, $f(x) = e^x$.* Injective (strictly
  increasing) and surjective onto the stated codomain. Bijective.
]

#soln("3.2")[
  Suppose $g compose f$ is injective and $f(a_1) = f(a_2)$. Applying $g$,
  $g(f(a_1)) = g(f(a_2))$, so $(g compose f)(a_1) = (g compose f)(a_2)$, and
  injectivity of the composite gives $a_1 = a_2$. So $f$ is injective.

  *$g$ need not be.* Take $f : RR -> RR$, $f(x) = e^x$ (whose image is
  $(0,infinity)$) and $g : RR -> RR$, $g(x) = x^2$. Then
  $(g compose f)(x) = e^(2x)$, which is injective, while $g$ is not
  ($g(1) = g(-1)$).

  The reason: $g$ only needs to be injective *on the image of $f$*, and it can
  misbehave freely outside it.
]

#soln("3.3")[
  $(f compose g)(x) = f(x^2) = 2x^2 + 3$.
  $(g compose f)(x) = g(2x+3) = (2x+3)^2 = 4x^2 + 12x + 9$.

  These differ, confirming composition is not commutative. They agree when
  $ 2x^2 + 3 = 4x^2 + 12x + 9 quad arrow.r.double quad 2x^2 + 12x + 6 = 0 quad arrow.r.double quad x^2 + 6x + 3 = 0, $
  so $x = -3 plus.minus sqrt(6)$.
]

#soln("3.4")[
  Rewrite the inside first: $-3 f(2x - 4) + 1 = -3 f(2(x-2)) + 1$.

  *Horizontal (inside the function, so backwards):*
  + compress horizontally by a factor of 2 (from the $2x$);
  + shift right by 2 (from the $x - 2$).

  Writing it as $2(x-2)$ makes the order unambiguous. If you instead read
  $2x - 4$ literally, the equivalent order is *shift right by 4, then compress
  by 2* --- the same final picture reached differently, which is exactly why
  factoring the inside out first is the safe habit.

  *Vertical (outside, so as written):*
  + stretch vertically by 3;
  + reflect in the $x$-axis (the minus sign);
  + shift up by 1.
]

#soln("3.5")[
  $
  "even part" &= (e^x + e^(-x))/2 = cosh x, \
  "odd part" &= (e^x - e^(-x))/2 = sinh x.
  $
  And indeed $cosh x + sinh x = e^x$, as the decomposition requires. Checking
  the parity: $cosh(-x) = cosh(x)$ and $sinh(-x) = -sinh(x)$, directly from
  swapping the two exponentials.
]

#soln("3.6")[
  *Total.* A function $A -> B$ is a choice of an output for each of the $m$
  elements of $A$, with $n$ options each and the choices independent. By the
  product rule that is $n^m$ functions. (This is why the notation $B^A$ is
  used for the set of such functions.)

  *Injective.* Now the choices are not independent: each element of $A$ must
  get a *distinct* output. There are $n$ options for the first element, $n-1$
  for the second, and so on:
  $ n(n-1)(n-2) dots.c (n - m + 1) = (n!)/((n-m)!), $
  which is $0$ when $m > n$ --- correctly, since you cannot inject a bigger set
  into a smaller one (pigeonhole, Chapter 9).
]

#soln("3.7")[
  $f(x) = (2x^2 - 3) slash (x^2 - 4)$.

  *Domain.* The denominator vanishes at $x = plus.minus 2$, so the domain is
  $RR without {-2, 2}$.

  *Vertical asymptotes.* At $x = 2$ and $x = -2$: the numerator is nonzero
  there ($2(4) - 3 = 5$), so the function blows up rather than having a
  removable hole.

  *Behaviour at infinity.* Numerator and denominator have equal degree, so
  divide through by $x^2$:
  $ f(x) = (2 - 3 slash x^2)/(1 - 4 slash x^2) arrow.r.long 2 $
  as $x -> plus.minus infinity$. Horizontal asymptote $y = 2$.
]

== Chapter 4 --- Exponentials and Logarithms

#soln("4.1")[
  *(a)* $log_2 32 = 5$, since $2^5 = 32$.
  *(b)* $log_9 3 = 1 slash 2$, since $9^(1 slash 2) = 3$.
  *(c)* $log_5 (1 slash 125) = -3$, since $5^(-3) = 1 slash 125$.
  *(d)* $log_a (a^7) = 7$, by the definition of the logarithm as the inverse.
  *(e)* $2^(log_2 11) = 11$, likewise.
]

#soln("4.2")[
  By definition, $2^(log_2 n) = n$. Take the natural logarithm of both sides:
  $ ln (2^(log_2 n)) = ln n. $
  By the power law, the left side is $(log_2 n)(ln 2)$. Dividing by
  $ln 2 != 0$:
  $ log_2 n = (ln n)/(ln 2). $
  Note $1 slash ln 2 approx 1.4427$, so $log_2 n$ and $ln n$ differ by a
  constant factor --- which is the whole reason bases are invisible inside
  big-O.
]

#soln("4.3")[
  *(a)* $3^(2x-1) = 27 = 3^3$. Since $x arrow.bar 3^x$ is injective,
  $2x - 1 = 3$, so $x = 2$.

  *(b)* $ln x + ln(x-3) = ln 10$ gives $ln(x(x-3)) = ln 10$, so
  $x^2 - 3x - 10 = 0$, factoring as $(x-5)(x+2) = 0$. Candidates $5$ and
  $-2$.

  *Check the domain*: both $x > 0$ and $x - 3 > 0$ are required, so $x > 3$.
  $x = -2$ is rejected (and would have made both logs undefined). Answer
  $x = 5$.

  *(c)* Substitute $u = e^x > 0$: $u^2 - 5u + 6 = 0$, so $u = 2$ or $u = 3$,
  both positive. Hence $x = ln 2$ or $x = ln 3$.
]

#soln("4.4")[
  $ sigma(-x) = 1/(1 + e^(x)) = (e^(-x))/(e^(-x) + 1) = ((1 + e^(-x)) - 1)/(1 + e^(-x)) = 1 - sigma(x). $

  Consequence for classification: a binary classifier must output
  $PP("class 1")$ and $PP("class 0")$, which sum to 1. The identity says
  $sigma$ applied to the negated logit gives exactly the complementary
  probability, so one number $sigma(z)$ determines both. Emitting two logits
  and applying softmax gives the same thing with a redundant degree of freedom
  --- which is why binary classifiers use a single output and
  `binary_cross_entropy`.
]

#soln("4.5")[
  *Shift invariance.*
  $ (e^(z_i + c))/(sum_j e^(z_j + c)) = (e^c e^(z_i))/(e^c sum_j e^(z_j)) = (e^(z_i))/(sum_j e^(z_j)). $
  The $e^c$ cancels top and bottom.

  *Log-sum-exp.* With $m = max_j z_j$,
  $ ln sum_j e^(z_j) = ln ( e^m sum_j e^(z_j - m) ) = m + ln sum_j e^(z_j - m), $
  using $log(a b) = log a + log b$. In exact arithmetic this is an identity.
  In floating point it is far better behaved: every exponent $z_j - m$ is
  $<= 0$, so no term exceeds 1 and nothing overflows, while the largest term
  is exactly $e^0 = 1$ so the sum cannot underflow to zero either.
]

#soln("4.6")[
  Set $n lg n = n^2 slash 2$. Dividing by $n$ (valid for $n > 0$):
  $ lg n = n/2. $
  By inspection $n = 2$ works ($1 = 1$) and $n = 4$ works ($2 = 2$). Between
  them the logarithm is larger (at $n = 3$: $1.585 > 1.5$), and beyond $n = 4$
  the line wins and grows away.

  So mathematically the two costs cross at $n = 2$ and $n = 4$.

  *Numerically, and more usefully:* the real question is where
  $c_1 n lg n = c_2 n^2 slash 2$ with the implementations' actual constants,
  since $c_2 lt.double c_1$ in practice. Measure both at a range of $n$, plot
  on log-log axes, and find the intersection --- which is empirically around
  $n = 10$ to $50$ for real sort implementations, and is exactly why library
  sorts switch to insertion sort for small subarrays.
]

#soln("4.7")[
  Assume cost $= C n^k$. Taking the ratio of the two measurements eliminates
  $C$:
  $ 16/2 = (4000/1000)^k quad arrow.r.double quad 8 = 4^k. $
  Taking logs: $k = ln 8 slash ln 4 = 3 slash 2$. So the routine is
  $Theta(n^(1.5))$.

  If the second measurement were $8$ ms instead: $4 = 4^k$ gives $k = 1$ ---
  linear.

  Note how little data this needs: two points and a logarithm. This is the
  practical content of the log-log plot remark in the chapter.
]

#soln("4.8")[
  $
  2 sigma(2x) - 1 = 2/(1 + e^(-2x)) - 1 = (2 - (1 + e^(-2x)))/(1+e^(-2x)) = (1 - e^(-2x))/(1 + e^(-2x)).
  $
  Multiply numerator and denominator by $e^(2x)$:
  $ = (e^(2x) - 1)/(e^(2x) + 1) = tanh x, $
  matching the definition given in the chapter. So $tanh$ is a sigmoid
  rescaled to output $(-1,1)$ and horizontally compressed by 2 --- which is why
  the two activations behave so similarly and why $tanh$ was generally
  preferred (its output is centred at zero, which conditions the next layer
  better).
]

== Chapter 5 --- Trigonometry

#soln("5.1")[
  *$sin(7 pi slash 6)$.* $7pi slash 6 = pi + pi slash 6$, so it is in the
  third quadrant with reference angle $pi slash 6$. In the third quadrant both
  coordinates are negative, so $sin$ is negative: $-1 slash 2$.

  *$cos(3 pi slash 4)$.* Second quadrant, reference angle $pi slash 4$. There
  $x < 0$, so $cos$ is negative: $-sqrt(2) slash 2$.

  *$tan(5 pi slash 3)$.* Fourth quadrant, reference $pi slash 3$. There
  $x > 0$ and $y < 0$, so $tan$ is negative: $-sqrt(3)$.
]

#soln("5.2")[
  Write $sin(alpha - beta) = sin(alpha + (-beta))$ and apply the addition
  formula:
  $ = sin alpha cos(-beta) + cos alpha sin(-beta). $
  Now $cos$ is even so $cos(-beta) = cos beta$, and $sin$ is odd so
  $sin(-beta) = -sin beta$. Substituting:
  $ sin(alpha - beta) = sin alpha cos beta - cos alpha sin beta. $
]

#soln("5.3")[
  Matching $3 cos t + 4 sin t = R cos(t - phi) = R cos phi cos t + R sin phi sin t$
  requires $R cos phi = 3$ and $R sin phi = 4$.

  Squaring and adding: $R^2 = 9 + 16 = 25$, so $R = 5$.

  Dividing: $tan phi = 4 slash 3$, and since both $R cos phi$ and
  $R sin phi$ are positive, $phi$ is in the first quadrant. Hence
  $phi = "atan2"(4,3) = arctan(4 slash 3) approx 0.927$ radians.

  $ 3 cos t + 4 sin t = 5 cos(t - arctan(4 slash 3)). $
]

#soln("5.4")[
  $
  tan(alpha+beta) = (sin(alpha+beta))/(cos(alpha+beta)) = (sin alpha cos beta + cos alpha sin beta)/(cos alpha cos beta - sin alpha sin beta).
  $
  Divide numerator and denominator by $cos alpha cos beta$:
  $ = (tan alpha + tan beta)/(1 - tan alpha tan beta). $

  *Validity.* The division requires $cos alpha != 0$ and $cos beta != 0$, and
  the original quotient requires $cos(alpha+beta) != 0$. So the identity fails
  when any of $alpha$, $beta$, $alpha+beta$ is an odd multiple of
  $pi slash 2$ --- which is where the tangents are undefined anyway.
]

#soln("5.5")[
  Apply the half-angle formula twice.
  $
  sin^4 theta = (sin^2 theta)^2 = ( (1 - cos 2 theta)/2 )^2 = (1 - 2 cos 2theta + cos^2 2 theta)/4.
  $
  Now $cos^2 2theta = (1 + cos 4 theta) slash 2$, so
  $
  sin^4 theta = 1/4 ( 1 - 2 cos 2theta + (1 + cos 4theta)/2 ) = 3/8 - 1/2 cos 2theta + 1/8 cos 4theta.
  $

  Check at $theta = 0$: $3 slash 8 - 1 slash 2 + 1 slash 8 = 0$. ✓
  At $theta = pi slash 2$: $3 slash 8 + 1 slash 2 + 1 slash 8 = 1$. ✓

  Every term is now a cosine of a multiple angle, so integrating is
  immediate --- which is the point of the manipulation.
]

#soln("5.6")[
  $r = sqrt(9 + 16) = 5$ --- distance from the origin.

  The point $(-3,-4)$ is in the *third* quadrant. Its angle is
  $ theta = "atan2"(-4,-3) = -(pi - arctan(4 slash 3)) approx -(3.1416 - 0.9273) = -2.214 "rad", $
  equivalently $approx -126.9 degree$, which lies in $(-pi, pi]$ as required.

  *What $arctan(y slash x)$ would give.* $y slash x = (-4) slash (-3) = 4 slash 3$,
  and $arctan(4 slash 3) approx 0.927$ rad --- a *first-quadrant* angle. The
  two negatives cancelled in the ratio, so $arctan$ cannot tell $(-3,-4)$ from
  $(3,4)$ and returns the wrong answer by exactly $pi$.
]

#soln("5.7")[
  Consider triangle $A B C$ with the usual labelling, and drop a perpendicular
  from $C$ to side $A B$, of length $h$.

  In the right triangle containing angle $A$, the hypotenuse is $b$ (the side
  $A C$), so $h = b sin A$.

  In the right triangle containing angle $B$, the hypotenuse is $a$, so
  $h = a sin B$.

  Equating: $b sin A = a sin B$, hence
  $ (sin A)/a = (sin B)/b. $
  Dropping a perpendicular from a different vertex gives the third ratio.

  (If the foot of the perpendicular falls outside the segment --- an obtuse
  triangle --- the same computation works with the supplementary angle, whose
  sine is the same.)
]

== Chapter 6 --- Complex Numbers

#soln("6.1")[
  *(a)* $(3+2i)(1-4i) = 3 - 12i + 2i - 8i^2 = 3 - 10i + 8 = 11 - 10i$.

  *(b)* Multiply by the conjugate of the denominator:
  $ (2+i)/(3-i) = ((2+i)(3+i))/((3-i)(3+i)) = (6 + 2i + 3i + i^2)/(9+1) = (5 + 5i)/10 = 1/2 + 1/2 i. $

  *(c)* Powers of $i$ cycle with period 4. $2027 = 4 times 506 + 3$, so
  $i^2027 = i^3 = -i$.

  *(d)* $abs(3 - 4i) = sqrt(9+16) = 5$.
]

#soln("6.2")[
  $z = -1 + i$: $r = abs(z) = sqrt(2)$, and the point is in the second
  quadrant, so $theta = 3 pi slash 4$. Hence
  $z = sqrt(2) thin e^(i 3 pi slash 4)$.

  By De Moivre,
  $ z^8 = (sqrt(2))^8 e^(i dot 8 dot 3 pi slash 4) = 16 thin e^(i 6 pi) = 16, $
  since $6 pi$ is a whole number of full turns.

  Sanity check: $z^2 = (-1+i)^2 = 1 - 2i + i^2 = -2i$, so
  $z^4 = (-2i)^2 = -4$, so $z^8 = 16$. ✓
]

#soln("6.3")[
  $z^3 = 8$. Write $z = r e^(i theta)$: then $r^3 = 8$ so $r = 2$, and
  $3 theta$ must be a multiple of $2 pi$, so
  $theta = 0, 2pi slash 3, 4 pi slash 3$.

  $
  z_1 &= 2 e^(i 0) = 2, \
  z_2 &= 2 e^(i 2pi slash 3) = 2(-1/2 + i sqrt(3)/2) = -1 + i sqrt(3), \
  z_3 &= 2 e^(i 4pi slash 3) = -1 - i sqrt(3).
  $

  Geometrically they are three points equally spaced around the circle of
  radius 2, one of them on the positive real axis --- the vertices of an
  equilateral triangle. Note $z_2$ and $z_3$ are conjugates, as they must be
  since $z^3 - 8$ has real coefficients.
]

#soln("6.4")[
  *By computation.* With $z = a + b i$, $w = c + d i$:
  $ z w = (a c - b d) + (a d + b c) i, $
  so
  $
  abs(z w)^2 &= (a c - b d)^2 + (a d + b c)^2 \
  &= a^2 c^2 - 2 a b c d + b^2 d^2 + a^2 d^2 + 2 a b c d + b^2 c^2 \
  &= a^2 c^2 + b^2 d^2 + a^2 d^2 + b^2 c^2 = (a^2+b^2)(c^2+d^2) = abs(z)^2 abs(w)^2.
  $
  The cross terms cancelling is the entire content.

  *In polar form.* $z w = (r e^(i alpha))(s e^(i beta)) = r s thin e^(i(alpha+beta))$,
  whose modulus is $r s = abs(z) abs(w)$. One line.
]

#soln("6.5")[
  Write each cosine as an average of exponentials:
  $ cos alpha cos beta = ((e^(i alpha) + e^(-i alpha))/2)((e^(i beta) + e^(-i beta))/2). $
  Multiplying out gives four terms:
  $ = 1/4 ( e^(i(alpha+beta)) + e^(i(alpha - beta)) + e^(-i(alpha-beta)) + e^(-i(alpha+beta)) ). $
  Pair the first with the last and the middle two:
  $ = 1/4 ( 2 cos(alpha+beta) + 2 cos(alpha - beta) ) = 1/2 [ cos(alpha-beta) + cos(alpha+beta) ]. $
]

#soln("6.6")[
  With $omega = e^(2 pi i slash 5)$, the sum
  $1 + omega + omega^2 + omega^3 + omega^4$ is geometric with ratio
  $omega != 1$:
  $ sum_(k=0)^4 omega^k = (omega^5 - 1)/(omega - 1) = (1 - 1)/(omega - 1) = 0. $

  *Geometrically:* the five fifth-roots of unity are five unit vectors equally
  spaced around the circle at $72 degree$ intervals. That configuration is
  symmetric under rotation by $72 degree$, and the only vector unchanged by a
  nontrivial rotation is the zero vector --- so the sum must be zero.
]

#soln("6.7")[
  Let $U = {z in CC : abs(z) = 1}$.

  *Closed under multiplication:* if $abs(z) = abs(w) = 1$ then
  $abs(z w) = abs(z) abs(w) = 1$ by the previous exercise, so $z w in U$.

  *Closed under inverses:* if $abs(z) = 1$ then $z != 0$, so $z^(-1)$ exists,
  and $abs(z^(-1)) = 1 slash abs(z) = 1$. (Indeed $z^(-1) = overline(z)$ when
  $abs(z) = 1$, since $z overline(z) = abs(z)^2 = 1$.)

  Together with associativity (inherited from $CC$) and the identity $1 in U$,
  this makes $U$ a group. Writing $z = e^(i theta)$, multiplication adds
  angles, so $U$ is precisely the group of rotations of the plane --- which is
  why it is called the circle group and why it is the same object as
  $"SO"(2)$.
]
