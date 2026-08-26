#import "../lib.typ": *

= Exponentials and Logarithms

== Why this chapter matters more than it looks

Exponentials and logarithms are the two functions a programmer meets most
often and understands least. Complexity classes, information content, entropy,
learning rates, sigmoid and softmax, log-likelihood, decibels, floating-point
exponents, log-scale plots: all of it is this chapter.

The good news is that essentially everything follows from *one* rule, applied
carefully.

== Powers, built up from nothing

We define $a^n$ in stages, and at each stage the definition is *forced* by
insisting one law keeps holding.

#definition(title: "positive integer powers")[
  For $a in RR$ and $n in NN$ with $n >= 1$:
  $ a^n = underbrace(a times a times dots.c times a, n "copies"). $
]

From this, immediately:

$ a^m a^n = a^(m+n), quad (a^m)^n = a^(m n), quad (a b)^n = a^n b^n. $

The first is the important one; call it *the law*. Everything below is the
answer to "what must $a^x$ mean, if the law is to keep working?"

*Zero exponent.* The law demands $a^0 a^n = a^(0 + n) = a^n$. Dividing by
$a^n$ (assuming $a != 0$) gives $a^0 = 1$. Not a convention --- a consequence.

*Negative exponents.* The law demands $a^(-n) a^n = a^0 = 1$, so
$ a^(-n) = 1/(a^n). $

*Fractional exponents.* The law demands $(a^(1 slash n))^n = a^(n slash n) = a^1 = a$,
so $a^(1 slash n)$ must be an $n$-th root of $a$. For $a > 0$ there is exactly
one positive such root, and we take it. Then
$ a^(p slash q) = (a^(1 slash q))^p. $

*Irrational exponents.* Now we are stuck: there is no way to write $2^sqrt(2)$
as repeated anything. The definition is by *continuity*: $sqrt(2)$ is a limit
of rationals $1, 1.4, 1.41, 1.414, dots$, and we define $2^sqrt(2)$ to be the
limit of $2^1, 2^(1.4), 2^(1.41), dots$. That this limit exists, and does not
depend on which sequence of rationals you chose, is a genuine theorem requiring
the completeness of $RR$ from Chapter 1.

#intuition(title: "the pattern to notice")[
  This is how mathematics extends a definition, every single time: you have an
  operation that works on a small domain and a *law* it satisfies; you extend
  the domain in the unique way that preserves the law.

  It is exactly how you would extend an API without breaking callers. The same
  move appears again for $0! = 1$ (Chapter 9), for $x^0 = I$ on matrices
  (Chapter 20), and for the gamma function extending the factorial to
  non-integers.
]

#warning(title: "negative bases break everything")[
  $(-8)^(1 slash 3)$ looks like it should be $-2$, and over the reals that is
  a defensible convention. But then
  $(-8)^(2 slash 6)$ ought to equal $((-8)^2)^(1 slash 6) = 64^(1 slash 6) = 2$,
  a different answer for the same exponent written differently.

  The law and negative bases are incompatible. So $a^x$ for general real $x$ is
  defined *only for $a > 0$*. Every identity in this chapter carries that
  hypothesis, silently.
]

== The exponential function

Fix $a > 0$, $a != 1$. The function $f(x) = a^x$ is defined for all real $x$,
is strictly monotone (increasing if $a > 1$, decreasing if $a < 1$), is
everywhere positive, and has range $(0, infinity)$.

Being strictly monotone, it is injective (Chapter 3); onto $(0,infinity)$, it
is surjective. So it is a bijection $RR -> (0, infinity)$ and therefore has an
inverse. That inverse is the logarithm.

=== Where $e$ comes from

Among all the bases you could pick, one is special, and the reason is worth
seeing now even though the tools only arrive in Chapter 14.

Consider the growth rate of $a^x$ --- how fast the value changes per unit of
$x$. For any base,
$ (a^(x+h) - a^x)/h = a^x dot (a^h - 1)/h. $
The growth rate is *proportional to the current value*: that is the defining
feature of exponential growth, and it is why compound interest, population
models, and radioactive decay all produce exponentials.

The constant of proportionality is $lim_(h->0) (a^h - 1) slash h$, which
depends on the base. For $a = 2$ it is about $0.693$; for $a = 3$, about
$1.099$. Somewhere in between there is a base making the constant exactly $1$.

#definition(title: "Euler's number")[
  $e$ is the unique base for which $lim_(h -> 0) (e^h - 1) slash h = 1$.
  Equivalently, and more usefully for computation,
  $ e = lim_(n -> infinity) (1 + 1/n)^n = sum_(k=0)^infinity 1/(k!) approx 2.71828182845905. $
]

The consequence, proved properly in Chapter 14, is
$ dif/(dif x) e^x = e^x. $
$e^x$ is the function that is its own derivative. That single property is why
$e$ appears everywhere: any time a quantity changes at a rate proportional to
itself --- and that is a great many quantities --- the solution is an
exponential in base $e$.

#example(title: "the compound interest reading")[
  Invest 1 unit at 100% annual interest, compounded $n$ times a year. Each
  period multiplies by $(1 + 1 slash n)$, and there are $n$ periods, so you
  finish with $(1 + 1 slash n)^n$. Compounding more often helps, but with
  sharply diminishing returns: $n = 1$ gives $2$, $n = 12$ gives $2.613$,
  $n = 365$ gives $2.7146$. The limit --- continuous compounding --- is $e$.
]

== Logarithms

#definition(title: "logarithm")[
  For $a > 0$, $a != 1$, and $x > 0$, $log_a x$ is the unique real number $y$
  with $a^y = x$. That is, $log_a$ is the inverse of $x arrow.bar a^x$:
  $ a^(log_a x) = x quad "and" quad log_a (a^y) = y. $
  Standard abbreviations: $ln x = log_e x$, $lg x = log_2 x$, and (in most
  mathematics, and in this book) an unadorned $log$ means $ln$. In computer
  science an unadorned $log$ usually means $lg$ --- and inside a big-O it does
  not matter, for a reason we will see in a moment.
]

#intuition(title: "a logarithm is a question")[
  $log_a x$ asks: *to what power must I raise $a$ to get $x$?*

  Read it that way and the values become obvious rather than memorised.
  $log_2 8 = 3$ because $2^3 = 8$. $log_2 (1 slash 4) = -2$ because
  $2^(-2) = 1 slash 4$. $log_a 1 = 0$ for every $a$, because anything to the
  zero is one.

  The second reading, equally useful: $lg x$ is *the number of bits you need
  to write $x$ down*, and $log_10 x$ is the number of decimal digits. A
  logarithm counts digits. That is why it grows so slowly, and why an
  $O(log n)$ algorithm is effectively free.
]

Every logarithm law is an exponent law wearing a disguise. Here they are, with
the disguise removed.

#theorem(title: "the logarithm laws")[
  For $x, y > 0$ and any real $r$:
  $
  log_a (x y) &= log_a x + log_a y \
  log_a (x/y) &= log_a x - log_a y \
  log_a (x^r) &= r log_a x \
  log_a x &= (log_b x)/(log_b a) quad "(change of base)"
  $
]

#proof[
  *Product.* Let $u = log_a x$ and $v = log_a y$, so $a^u = x$ and $a^v = y$.
  Then $x y = a^u a^v = a^(u + v)$ by the law. Taking $log_a$ of both ends,
  $log_a (x y) = u + v$.

  *Quotient.* Identical, with $a^u slash a^v = a^(u - v)$.

  *Power.* $x^r = (a^u)^r = a^(u r)$, so $log_a (x^r) = u r = r log_a x$.

  *Change of base.* Start from $a^(log_a x) = x$ and apply $log_b$ to both
  sides. The power law gives $(log_a x)(log_b a) = log_b x$. Divide by
  $log_b a$, which is nonzero since $a != 1$.
]

#example(title: "why the base does not matter inside big-O")[
  Change of base says $log_2 n = (ln n) slash (ln 2) = 1.4427 dots times ln n$.
  The two logarithms differ by a *constant factor*, and big-O discards constant
  factors. So $O(log_2 n) = O(ln n) = O(log_10 n)$, and writing "$O(log n)$"
  without a base is not sloppiness --- it is the observation that the base is
  not part of the information.

  Contrast $2^n$ and $3^n$: those differ by a factor of $(3 slash 2)^n$, which
  is not constant. Bases matter in exponents and do not matter in logarithms.
]

== Growth rates: the hierarchy you must have memorised

For large $x$, and for any constants $epsilon > 0$, $k > 0$, $b > 1$:

$ log x quad lt.double quad x^epsilon quad lt.double quad x^k quad lt.double quad b^x quad lt.double quad x! quad lt.double quad x^x $

where $f lt.double g$ means $f(x) slash g(x) -> 0$. Each of these gaps is
enormous and each one gets proved in Chapter 15 once we have L'Hôpital's rule.

The two facts that surprise people:

*Logarithms beat every power of $x$, no matter how small the power.*
$log x$ grows more slowly than $x^(0.001)$. Eventually. (The crossover is
astronomically far out, which is why this is surprising.)

*Every exponential beats every polynomial.* $1.0001^x$ eventually dwarfs
$x^(1000)$. This is the entire reason exponential-time algorithms are
considered intractable and polynomial ones are not.

#example(title: "Stirling, and why it is everywhere")[
  $n!$ sits awkwardly between $b^n$ and $n^n$. *Stirling's approximation*
  pins it down:
  $ n! approx sqrt(2 pi n) (n/e)^n, quad "so" quad ln(n!) approx n ln n - n. $

  The logarithmic form is the one you will actually use. It is why
  comparison-based sorting needs $Omega(n log n)$ comparisons: there are $n!$
  possible orderings, a comparison tree of depth $d$ distinguishes at most
  $2^d$ of them, so $2^d >= n!$, giving $d >= lg(n!) approx n lg n - n slash ln 2$.

  The entire lower bound is one application of the logarithm laws to
  Stirling's formula.
]

== The functions built out of $exp$ and $log$

=== The logistic (sigmoid) function

$ sigma(x) = 1/(1 + e^(-x)). $

It maps $RR$ bijectively onto $(0,1)$, is strictly increasing, and satisfies
$sigma(-x) = 1 - sigma(x)$. Its inverse is the *logit* or *log-odds*:
$ sigma^(-1)(p) = ln (p/(1 - p)). $

#proof[
  Set $p = 1 slash (1 + e^(-x))$ and solve for $x$. Then
  $1 + e^(-x) = 1 slash p$, so $e^(-x) = (1 - p) slash p$, so
  $-x = ln((1-p) slash p)$, so $x = ln(p slash (1-p))$.
]

That is why logistic regression is called that: it models the *log-odds* as a
linear function, and $sigma$ is the map back to probabilities. It is not an
arbitrary squashing function; it is the inverse of the natural parameter of
the Bernoulli distribution, which Chapter 31 makes precise.

=== Softmax

$ softmax(z)_i = e^(z_i) / (sum_j e^(z_j)). $

The output is a probability vector: every entry is positive and they sum to
$1$. Note that adding a constant $c$ to every $z_i$ changes nothing --- the
$e^c$ factors cancel top and bottom. That invariance is not a curiosity; it is
the fix for the following disaster.

#warning(title: "naive softmax overflows, and log-sum-exp is the cure")[
  $e^(1000)$ overflows a double, which caps out near $e^(709)$. Meanwhile
  $e^(-1000)$ underflows to exactly zero. So computing softmax by the formula
  above fails on perfectly ordinary logits.

  Use the shift invariance: subtract $m = max_j z_j$ from every entry first.
  Then the largest exponent is $e^0 = 1$, nothing overflows, and the smallest
  terms underflow harmlessly to zero.

  The same trick for the *log* of a sum of exponentials --- which is what you
  need for log-likelihoods --- is called *log-sum-exp*:
  $ ln sum_j e^(z_j) = m + ln sum_j e^(z_j - m), quad m = max_j z_j. $

  Every serious numerical library implements this. Now you know why it exists,
  and it is one line of algebra.
]

=== The hyperbolic functions

$ cosh x = (e^x + e^(-x))/2, quad sinh x = (e^x - e^(-x))/2, quad tanh x = (sinh x)/(cosh x) = (e^(2x) - 1)/(e^(2x)+1). $

These are the even and odd parts of $e^x$ from Chapter 3. They satisfy
$cosh^2 x - sinh^2 x = 1$ --- a hyperbola, hence the name, against the circle
$cos^2 + sin^2 = 1$ of Chapter 5. And $tanh x = 2 sigma(2x) - 1$, so it is the
sigmoid rescaled to $(-1, 1)$, which is the whole reason it was the default
activation function for twenty years.

== Working in log space

A practical technique that is really a change of coordinates.

Products of many small probabilities underflow: $0.001^300$ is zero in a
double. Sums of logarithms do not. So the standard move throughout machine
learning and statistics is to work with $ln p$ instead of $p$:

$ ln product_i p_i = sum_i ln p_i. $

This converts an underflowing product into a well-behaved sum, converts
multiplication into addition (cheaper), and turns the likelihood function into
the *log-likelihood*, whose maximiser is the same because $ln$ is strictly
increasing --- a fact you now know is exactly the "safe transformation" of
Chapter 2.

#example(title: "reading a log-log plot")[
  If $y = C x^k$ then $ln y = ln C + k ln x$. So on axes where both variables
  are plotted logarithmically, a *power law appears as a straight line with
  slope $k$*.

  If instead $y = C b^x$ then $ln y = ln C + x ln b$: on a *semi*-log plot
  (log on $y$ only) an *exponential* appears as a straight line.

  So a glance at which kind of plot straightens your data tells you which
  model it obeys. This is the most useful five seconds of mathematics in
  performance engineering.
]

== Exercises

#exercise[
  Without a calculator, evaluate: (a) $log_2 32$, (b) $log_9 3$, (c)
  $log_5 (1 slash 125)$, (d) $log_a (a^7)$, (e) $2^(log_2 11)$.
]

#exercise[
  Prove the change-of-base formula in the specific form
  $log_2 n = ln n slash ln 2$, starting from the definition of the logarithm
  and using only the power law.
]

#exercise[
  Solve for $x$: (a) $3^(2x - 1) = 27$, (b) $ln(x) + ln(x - 3) = ln(10)$
  (careful --- check for extraneous roots), (c) $e^(2x) - 5 e^x + 6 = 0$
  (hint: substitute $u = e^x$).
]

#exercise[
  Show that $sigma(-x) = 1 - sigma(x)$ for the logistic function, and use it
  to explain why a binary classifier only needs to output one number rather
  than two.
]

#exercise[
  Show directly from the definition that softmax is invariant under adding a
  constant to every input, and then verify that log-sum-exp with the max shift
  gives the same value as the naive formula, in exact arithmetic.
]

#exercise[
  A merge sort on $n$ items does about $n lg n$ comparisons. A quadratic sort
  does about $n^2 slash 2$. At what $n$ do they cross over? Solve as far as you
  can by hand and then describe how you would finish it numerically.
]

#exercise[
  You measure a routine at $n = 1000$ taking $2$ ms and at $n = 4000$ taking
  $16$ ms. Assuming the cost is $C n^k$, find $k$ using logarithms. Then say
  what you would have concluded if the second measurement were $8$ ms instead.
]

#exercise[
  Prove that $tanh x = 2 sigma(2x) - 1$ directly from the definitions.
]
