#import "../lib.typ": *

== Chapter 11 --- Recurrences and Asymptotics

#soln("11.1")[
  *Upper bound.* For $n >= 1$, each of $n$ and $1$ is at most $n^2$, so
  $ 3n^2 + 100n + 7 <= 3n^2 + 100n^2 + 7n^2 = 110 n^2. $

  *Lower bound.* All terms are positive, so $3n^2 + 100n + 7 >= 3n^2$.

  So with $c = 3$, $C = 110$, $n_0 = 1$:
  $3 n^2 <= 3n^2 + 100n + 7 <= 110 n^2$ for all $n >= n_0$, which is the
  definition of $Theta(n^2)$.
]

#soln("11.2")[
  Two preliminary observations. $2^(log n) = n$ when the log is base 2 (and is
  a fixed power of $n$ for any other base). And $log(n!) = Theta(n log n)$ by
  Stirling.

  In increasing order:
  $ sqrt(n) prec 2^(log n) = n prec n log n asymp log(n!) prec n (log n)^2 prec n^(1.5) prec 2^n prec n! $

  Justifications for the non-obvious comparisons:

  - $n log n prec n(log n)^2$: divide by $n log n$, leaving $log n -> infinity$.
  - $n (log n)^2 prec n^(1.5)$: divide by $n$, compare $(log n)^2$ with
    $sqrt(n)$. Logs beat powers, and squaring a log does not change that
    (substitute $m = log n$ and compare $m^2$ with $2^(m slash 2)$).
  - $n^(1.5) prec 2^n$: every exponential beats every polynomial (Chapter 15).
  - $2^n prec n!$: the ratio $n! slash 2^n$ has each successive factor
    $k slash 2$, which exceeds 1 from $k = 3$ onwards and grows.
]

#soln("11.3")[
  Unrolling,
  $ T(n) = T(n-1) + 1/n = T(n-2) + 1/(n-1) + 1/n = dots.c = T(1) + sum_(k=2)^n 1/k. $
  With $T(1) = 1$ this is $sum_(k=1)^n 1 slash k = H_n$, the $n$-th harmonic
  number.

  By Chapter 17, $H_n = ln n + gamma + O(1 slash n)$, so
  $T(n) = Theta(log n)$.
]

#soln("11.4")[
  *(a) $T = 4T(n slash 2) + n$.* $c = log_2 4 = 2$. $f(n) = n = O(n^(2 - 1))$,
  so case (i): $Theta(n^2)$.

  *(b) $T = 4T(n slash 2) + n^2$.* $c = 2$, $f = Theta(n^2)$, case (ii):
  $Theta(n^2 log n)$.

  *(c) $T = 4T(n slash 2) + n^3$.* $c = 2$, $f = Omega(n^(2+1))$. Regularity:
  $4 f(n slash 2) = 4 n^3 slash 8 = n^3 slash 2 = (1 slash 2) f(n)$, so
  $k = 1 slash 2 < 1$. ✓ Case (iii): $Theta(n^3)$.

  *(d) $T = 2T(n slash 2) + n slash log n$.* $c = 1$. Here $f(n) = n slash log n$
  is smaller than $n^c = n$, but not *polynomially* smaller --- it is smaller
  only by a log factor, so $f != O(n^(1-epsilon))$ for any $epsilon > 0$. The
  Master Theorem does not apply.

  *Recursion tree.* At level $i$ there are $2^i$ subproblems of size
  $n slash 2^i$, contributing
  $ 2^i dot (n slash 2^i)/(log(n slash 2^i)) = n/(log n - i). $
  Summing over $i = 0$ to $log n - 1$:
  $ T(n) = n sum_(j=1)^(log n) 1/j = n H_(log n) = Theta(n log log n). $
]

#soln("11.5")[
  *Guess:* $T(n) <= C n lg n$ for suitable $C$ and all $n$ above a base.

  *Step.* Assume it for all smaller arguments:
  $
  T(n) &<= C (n/3) lg (n/3) + C (2n/3) lg (2n/3) + n \
  &= C n/3 (lg n - lg 3) + C (2n)/3 (lg n - lg(3 slash 2)) + n \
  &= C n lg n - C n [ 1/3 lg 3 + 2/3 lg(3 slash 2) ] + n.
  $
  The bracket evaluates to
  $ 1/3 (1.585) + 2/3 (0.585) = 0.528 + 0.390 = 0.918. $
  So $T(n) <= C n lg n - 0.918 C n + n$, and this is at most $C n lg n$
  provided $0.918 C >= 1$, i.e. $C >= 1.09$.

  Choose $C$ at least that and large enough to cover the base cases, and the
  induction closes. Hence $T(n) = O(n log n)$.

  This recurrence is the one for quicksort with a guaranteed
  one-third/two-thirds split, and the computation shows why an unbalanced but
  *constant-ratio* split is still $O(n log n)$ --- only the constant suffers.
]

#soln("11.6")[
  Characteristic equation $x^2 - 5x + 6 = 0$, factoring as $(x-2)(x-3) = 0$:
  roots $2$ and $3$, distinct.

  So $a_n = A dot 2^n + B dot 3^n$. From the initial conditions:
  $
  n = 0: quad A + B &= 1 \
  n = 1: quad 2A + 3B &= 4
  $
  Subtracting twice the first from the second: $B = 2$, hence $A = -1$.

  $ a_n = 2 dot 3^n - 2^n. $

  Check $n = 2$: $18 - 4 = 14$, and the recurrence gives
  $5(4) - 6(1) = 14$. ✓
]

#soln("11.7")[
  Characteristic equation $x^2 - 4x + 4 = (x-2)^2$: a *repeated* root $x = 2$.

  With multiplicity 2, the general solution is $a_n = (A + B n) 2^n$ --- the
  extra factor of $n$ is what the repeated-root case supplies (without it the
  solution space would have dimension 1, too small).

  $n = 0$: $A = 1$.
  $n = 1$: $(1 + B) dot 2 = 6$, so $B = 2$.

  $ a_n = (1 + 2n) 2^n. $

  Check $n = 2$: $(5)(4) = 20$, and $4(6) - 4(1) = 20$. ✓
]

#soln("11.8")[
  *Accounting method.* Charge each `push` 2 credits:

  - 1 pays for the push itself;
  - 1 is deposited *with the pushed item*, to pay for its eventual removal.

  `pop` costs 1 real unit, paid by the credit sitting on the item being
  removed. Amortised cost 0.

  `multipop(k)` removes $j = min(k, "size")$ items at real cost $j$, each paid
  by that item's own deposited credit. Amortised cost 0.

  *The bank never goes negative* because every item on the stack carries
  exactly one unit of credit, and you can only pop items that are on the
  stack.

  So the amortised costs are: push 2, pop 0, multipop 0 --- all $O(1)$ ---
  even though a single `multipop` can cost $Theta(n)$ in real time. The total
  over any sequence of $m$ operations is at most $2m$.
]

== Chapter 12 --- Number Theory and Modular Arithmetic

#soln("12.1")[
  *Euclid.*
  $
  1071 &= 2 times 462 + 147 \
  462 &= 3 times 147 + 21 \
  147 &= 7 times 21 + 0
  $
  So $gcd(1071, 462) = 21$.

  *Extended, by back-substitution.* From the second line,
  $21 = 462 - 3 times 147$. From the first, $147 = 1071 - 2 times 462$.
  Substituting:
  $ 21 = 462 - 3(1071 - 2 times 462) = 7 times 462 - 3 times 1071. $
  So $x = -3$, $y = 7$.

  Check: $-3(1071) + 7(462) = -3213 + 3234 = 21$. ✓
]

#soln("12.2")[
  Run Euclid on $43$ and $17$:
  $
  43 &= 2 times 17 + 9 \
  17 &= 1 times 9 + 8 \
  9 &= 1 times 8 + 1
  $
  Back-substitute:
  $
  1 &= 9 - 8 \
  &= 9 - (17 - 9) = 2 times 9 - 17 \
  &= 2(43 - 2 times 17) - 17 = 2 times 43 - 5 times 17.
  $
  So $-5 times 17 equiv 1 space (mod 43)$, giving
  $17^(-1) equiv -5 equiv 38 space (mod 43)$.

  Check: $17 times 38 = 646 = 15 times 43 + 1 = 645 + 1$. ✓
]

#soln("12.3")[
  $N = 3 times 5 times 7 = 105$.

  $
  N_1 &= 35, quad 35 equiv 2 space (mod 3), quad 2 times 2 = 4 equiv 1, quad M_1 = 2 \
  N_2 &= 21, quad 21 equiv 1 space (mod 5), quad M_2 = 1 \
  N_3 &= 15, quad 15 equiv 1 space (mod 7), quad M_3 = 1
  $

  $ x = 2(35)(2) + 3(21)(1) + 2(15)(1) = 140 + 63 + 30 = 233. $

  Reducing mod 105: $233 - 210 = 23$.

  Check: $23 = 7 times 3 + 2$ ✓; $23 = 4 times 5 + 3$ ✓;
  $23 = 3 times 7 + 2$ ✓.
]

#soln("12.4")[
  *By Fermat.* $11$ is prime and $11 divides.not 7$, so $7^10 equiv 1$.
  Writing $222 = 22 times 10 + 2$:
  $ 7^222 = (7^10)^22 dot 7^2 equiv 1^22 dot 49 equiv 49 - 44 = 5 space (mod 11). $

  *By square-and-multiply.* $7^2 = 49 equiv 5$; $7^4 equiv 5^2 = 25 equiv 3$;
  $7^8 equiv 9$; $7^16 equiv 81 equiv 4$; $7^32 equiv 16 equiv 5$;
  $7^64 equiv 25 equiv 3$; $7^128 equiv 9$.
  Now $222 = 128 + 64 + 16 + 8 + 4 + 2$, so
  $ 7^222 equiv 9 times 3 times 4 times 9 times 3 times 5 space (mod 11). $
  Reducing as we go: $9 times 3 = 27 equiv 5$; $5 times 4 = 20 equiv 9$;
  $9 times 9 = 81 equiv 4$; $4 times 3 = 12 equiv 1$; $1 times 5 = 5$.

  Both give $5$. ✓ Fermat's route is dramatically shorter, which is the
  point: reduce the exponent modulo $p - 1$ before doing anything else.
]

#soln("12.5")[
  Suppose $gcd(a,n) = d > 1$ and that $a x equiv 1 space (mod n)$ had a
  solution. Then $a x - 1 = k n$ for some integer $k$, so
  $ a x - k n = 1. $
  Now $d divides a$ and $d divides n$, so $d$ divides the left-hand side ---
  hence $d divides 1$.

  But $d > 1$, and no integer greater than 1 divides 1. Contradiction. So no
  inverse exists.

  Note the structure: this is the Bézout argument run backwards. Bézout says
  the *smallest* positive value of $a x + n y$ is $gcd(a,n)$; getting the value
  1 therefore requires the gcd to be 1.
]

#soln("12.6")[
  *Squares mod 4.* If $n = 2k$ then $n^2 = 4k^2 equiv 0$. If $n = 2k+1$ then
  $n^2 = 4k^2 + 4k + 1 = 4(k^2+k) + 1 equiv 1$. So every square is $0$ or
  $1$ mod 4.

  *Sums of two squares.* Adding two values each in ${0,1}$ gives
  $0, 1$, or $2$ modulo 4. Never $3$.

  An integer of the form $4k+3$ is congruent to $3$ mod 4, so it cannot be a
  sum of two squares.

  This is a small instance of a much more general theorem (a positive integer
  is a sum of two squares iff every prime $equiv 3 space (mod 4)$ occurs to an
  even power in its factorisation), but the mod-4 obstruction is the whole
  content of this case, and it is two lines.
]

#soln("12.7")[
  Let $n > 2$ and pair each $a$ coprime to $n$ with $n - a$.

  *The partner is also coprime:* $gcd(n - a, n) = gcd(-a, n) = gcd(a,n) = 1$.

  *The pairing has no fixed point:* $a = n - a$ would force $n = 2a$, and then
  $a divides n$ with $a > 1$ (since $n > 2$), contradicting $gcd(a,n) = 1$.
  The only escape would be $a = 1$ and $n = 2$, excluded by hypothesis.

  *And it is an involution:* $n - (n - a) = a$.

  So the $phi(n)$ coprime residues split into disjoint pairs, and $phi(n)$ is
  even.
]

#soln("12.8")[
  *Truncated division* (C, C++, Java, Rust, Go): the quotient is truncated
  towards zero, $"trunc"(-17 slash 5) = "trunc"(-3.4) = -3$, so the remainder
  is
  $ -17 - 5(-3) = -17 + 15 = -2. $

  *Floored division* (Python, Haskell): the quotient is
  $floor(-3.4) = -4$, so the remainder is
  $ -17 - 5(-4) = -17 + 20 = 3. $

  The mathematically correct residue in $[0,5)$ is $3$.

  *A portable expression:*
  #algo[
  ```
  ((x % m) + m) % m
  ```
  ]
  Under floored division the inner `%` is already in $[0,m)$, so adding $m$
  and reducing again is a no-op. Under truncated division the inner `%` lies
  in $(-m, m)$, so adding $m$ makes it positive and the outer `%` brings it
  back into range. Either way the result is correct, at the cost of one extra
  modulo.
]

== Chapter 13 --- Limits and Continuity

#soln("13.1")[
  *Scratch.* $abs((3x - 2) - 1) = abs(3x - 3) = 3 abs(x-1)$, which is less
  than $epsilon$ when $abs(x-1) < epsilon slash 3$.

  *Proof.* Let $epsilon > 0$ be given. Choose $delta = epsilon slash 3$.
  Suppose $0 < abs(x - 1) < delta$. Then
  $ abs((3x-2) - 1) = 3 abs(x-1) < 3 delta = epsilon. $
  Since $epsilon$ was arbitrary, $lim_(x->1)(3x-2) = 1$.
]

#soln("13.2")[
  *Scratch.* $abs(x^2 - 4) = abs(x-2) abs(x+2)$. The first factor is what we
  control; the second must be *bounded*. Restricting to $delta <= 1$ gives
  $1 < x < 3$, hence $abs(x+2) < 5$. Then $abs(x^2-4) < 5 abs(x-2)$, which is
  under $epsilon$ when $abs(x-2) < epsilon slash 5$.

  *Proof.* Let $epsilon > 0$. Choose $delta = min(1, epsilon slash 5)$.
  Suppose $0 < abs(x-2) < delta$. Since $delta <= 1$ we have $abs(x+2) < 5$,
  and since $delta <= epsilon slash 5$,
  $ abs(x^2 - 4) = abs(x-2) abs(x+2) < (epsilon/5)(5) = epsilon. $

  The $min$ with 1 is the standard device: one part of $delta$ bounds the
  nuisance factor, the other delivers the tolerance.
]

#soln("13.3")[
  *(a)* $(x^2-9) slash (x-3) = x + 3$ for $x != 3$, so the limit is $6$.

  *(b)* Multiply by the conjugate:
  $ (sqrt(1+x)-1)/x dot (sqrt(1+x)+1)/(sqrt(1+x)+1) = ((1+x) - 1)/(x(sqrt(1+x)+1)) = 1/(sqrt(1+x)+1) -> 1/2. $

  *(c)* $ (sin 5x)/x = 5 dot (sin 5x)/(5x) -> 5 dot 1 = 5, $ using the
  fundamental trigonometric limit with argument $5x$.

  *(d)* Divide top and bottom by $x^3$:
  $ (4 - 1 slash x^2)/(2 + 7 slash x^3) -> 4/2 = 2. $
]

#soln("13.4")[
  $abs(cos(1 slash x^2)) <= 1$ for every $x != 0$, so
  $ -abs(x) <= x cos(1/x^2) <= abs(x). $
  Both bounds tend to $0$ as $x -> 0$, so by the squeeze theorem the middle
  does too:
  $ lim_(x->0) x cos(1/x^2) = 0. $
  Note that $cos(1 slash x^2)$ itself has no limit at $0$ --- it oscillates
  ever faster --- so the product law is unavailable and the squeeze is
  genuinely needed.
]

#soln("13.5")[
  Take $f(x) = sgn(x)$ and $g(x) = -sgn(x)$.

  Neither has a limit at $0$: the one-sided limits are $+1$ and $-1$ for $f$,
  and the reverse for $g$.

  But $f + g$ is identically $0$, so $lim_(x->0)(f+g) = 0$ exists.

  *No contradiction.* The sum law states: *if* both limits exist, *then* the
  limit of the sum exists and equals their sum. It is an implication in one
  direction. It says nothing about the case where the hypotheses fail, and in
  particular does not claim the converse.

  Confusing a theorem with its converse --- Chapter 7 --- in its natural
  habitat.
]

#soln("13.6")[
  For $x != 1$,
  $ (x^2-1)/(x-1) = ((x-1)(x+1))/(x-1) = x + 1, $
  so $lim_(x->1) f(x) = 2$.

  Continuity at $1$ requires $f(1) = lim_(x->1) f(x)$, so $c = 2$.

  This is a *removable* discontinuity: the function had a hole, and defining
  the value at the point to be the limit fills it.
]

#soln("13.7")[
  Let $f(x) = x^3 - x - 1$, continuous everywhere (a polynomial).

  $f(1) = 1 - 1 - 1 = -1 < 0$ and $f(2) = 8 - 2 - 1 = 5 > 0$.

  Since $0$ lies between $f(1)$ and $f(2)$, the Intermediate Value Theorem
  gives $c in (1,2)$ with $f(c) = 0$.

  *Bisection steps.* After $k$ bisections the bracket has width
  $1 slash 2^k$. Requiring $1 slash 2^k < 10^(-6)$ gives $2^k > 10^6$, so
  $k >= 20$ (since $2^20 = 1,!048,!576$).
]

#soln("13.8")[
  Let $p(x) = a_n x^n + dots.c + a_0$ with $n$ odd and $a_n != 0$; assume
  $a_n > 0$ (otherwise apply the argument to $-p$, which has the same roots).

  For large $abs(x)$ the leading term dominates: dividing by $x^n$,
  $ (p(x))/(x^n) = a_n + (a_(n-1))/x + dots.c + (a_0)/(x^n) -> a_n > 0. $
  So for sufficiently large $x$, $p(x)$ has the same sign as $x^n$.

  Since $n$ is odd, $x^n -> +infinity$ as $x -> +infinity$ and
  $x^n -> -infinity$ as $x -> -infinity$. So there exist $a$ with $p(a) < 0$
  and $b$ with $p(b) > 0$.

  $p$ is continuous, so by the IVT it takes the value $0$ somewhere between
  $a$ and $b$.

  (Even-degree polynomials can fail: $x^2 + 1$ has no real root, because both
  ends go the same way.)
]

== Chapter 14 --- Derivatives

#soln("14.1")[
  $
  (f(x+h) - f(x))/h &= (1/(x+h) - 1/x)/h = ((x - (x+h))/(x(x+h)))/h \
  &= (-h)/(h thin x (x+h)) = (-1)/(x(x+h)).
  $
  The cancellation of $h$ is legal because the limit never evaluates at
  $h = 0$. Letting $h -> 0$:
  $ f'(x) = -1/(x^2). $
  Consistent with the power rule applied to $x^(-1)$.
]

#soln("14.2")[
  *(a)* Product rule: $3x^2 e^x + x^3 e^x = x^2 e^x (3 + x)$.

  *(b)* Quotient rule:
  $ (2(x^2-3) - (2x+1)(2x))/((x^2-3)^2) = (2x^2 - 6 - 4x^2 - 2x)/((x^2-3)^2) = (-2x^2 - 2x - 6)/((x^2-3)^2). $

  *(c)* Chain rule: $cos(x^2+1) dot 2x = 2x cos(x^2+1)$.

  *(d)* Chain rule: $e^(cos x) dot (-sin x) = -sin x thin e^(cos x)$.

  *(e)* Chain rule: $ dif/(dif x) ln(ln x) = 1/(ln x) dot 1/x = 1/(x ln x). $

  *(f)* Chain rule twice:
  $ dif/(dif x) (1 + tan x)^(1 slash 2) = 1/2 (1+tan x)^(-1 slash 2) dot sec^2 x = (sec^2 x)/(2 sqrt(1 + tan x)). $
]

#soln("14.3")[
  $
  (f/g)(x+h) - (f/g)(x) = (f(x+h))/(g(x+h)) - (f(x))/(g(x)) = (f(x+h)g(x) - f(x)g(x+h))/(g(x+h)g(x)).
  $
  Add and subtract $f(x) g(x)$ in the numerator:
  $
  &= (f(x+h)g(x) - f(x)g(x) + f(x)g(x) - f(x)g(x+h))/(g(x+h)g(x)) \
  &= (g(x)[f(x+h)-f(x)] - f(x)[g(x+h)-g(x)])/(g(x+h)g(x)).
  $
  Divide by $h$ and let $h -> 0$. The bracketed differences become
  $h f'(x)$ and $h g'(x)$ in the limit, and $g(x+h) -> g(x)$ by continuity:
  $ (f/g)'(x) = (f'(x)g(x) - f(x)g'(x))/(g(x)^2). $

  The add-and-subtract trick is exactly the one from the product rule ---
  which is not a coincidence, since the quotient rule is the product rule in
  disguise.
]

#soln("14.4")[
  Differentiate $x^3 + y^3 = 6x y$ with respect to $x$, treating $y$ as a
  function of $x$:
  $ 3x^2 + 3y^2 y' = 6y + 6x y'. $
  Collecting:
  $ y'(3y^2 - 6x) = 6y - 3x^2 quad arrow.r.double quad y' = (2y - x^2)/(y^2 - 2x). $

  *Horizontal tangent* requires $y' = 0$, so $2y = x^2$, i.e.
  $y = x^2 slash 2$ (with the denominator nonzero). Substituting into the
  curve:
  $ x^3 + (x^6)/8 = 6x dot (x^2)/2 = 3x^3 quad arrow.r.double quad (x^6)/8 = 2x^3 quad arrow.r.double quad x^3 (x^3 - 16) = 0. $

  $x = 0$ gives $y = 0$, but there the denominator $y^2 - 2x$ also vanishes:
  the origin is a singular point of the curve (it self-intersects), not a
  horizontal tangent.

  The genuine solution is $x^3 = 16$, so $x = 2 dot 2^(1 slash 3) approx 2.52$
  and $y = x^2 slash 2 = 2^(5 slash 3) approx 3.17$.
]

#soln("14.5")[
  Take logs first:
  $ ln y = 3 ln(x^2+1) + 1/2 ln(x-1) - 5 ln(x+4). $
  Differentiate both sides (implicitly on the left):
  $ (y')/y = (6x)/(x^2+1) + 1/(2(x-1)) - 5/(x+4). $
  Multiply through by $y$:
  $ y' = ((x^2+1)^3 sqrt(x-1))/((x+4)^5) [ (6x)/(x^2+1) + 1/(2(x-1)) - 5/(x+4) ]. $

  Doing this with the product and quotient rules directly is possible and
  substantially worse. Taking logs turned a product of four factors into a sum
  of four terms --- the same reason log-likelihood is what gets differentiated
  in statistics.
]

#soln("14.6")[
  $tanh = sinh slash cosh$, so by the quotient rule and
  $sinh' = cosh$, $cosh' = sinh$:
  $ tanh'(x) = (cosh^2 x - sinh^2 x)/(cosh^2 x) = 1/(cosh^2 x), $
  using $cosh^2 - sinh^2 = 1$. And
  $ 1/(cosh^2 x) = (cosh^2 x - sinh^2 x)/(cosh^2 x) = 1 - tanh^2 x. $

  *Computational significance.* The forward pass already computed
  $a = tanh(x)$ and stored it. The backward pass needs $tanh'(x)$, and the
  identity says that is $1 - a^2$ --- one multiplication and one subtraction,
  using a value already in memory. The *input* $x$ never has to be retained.

  For a network with millions of activations, not having to store the
  pre-activation values is a real memory saving, and it is why activations
  whose derivative is expressible in terms of their output were preferred.
]

#soln("14.7")[
  *$f'(0)$ exists.* From the definition,
  $ f'(0) = lim_(h->0) (h^2 sin(1 slash h) - 0)/h = lim_(h->0) h sin(1/h) = 0, $
  by the squeeze theorem, since $abs(h sin(1 slash h)) <= abs(h)$.

  *$f'$ away from zero.* By the product and chain rules, for $x != 0$:
  $ f'(x) = 2x sin(1/x) + x^2 cos(1/x) dot (-1/x^2) = 2x sin(1/x) - cos(1/x). $

  *$f'$ is not continuous at $0$.* As $x -> 0$ the first term tends to $0$
  (squeeze again), but $cos(1 slash x)$ oscillates between $-1$ and $1$
  without settling. So $lim_(x->0) f'(x)$ does not exist, and in particular
  does not equal $f'(0) = 0$.

  So $f$ is differentiable everywhere and $f'$ is not continuous: the class of
  differentiable functions is strictly larger than the class of continuously
  differentiable ($C^1$) ones. This is why theorems often say "continuously
  differentiable" rather than just "differentiable".
]

#soln("14.8")[
  With $C = e slash 2 approx 1.359$ and
  $epsilon_"mach" = 2.2 times 10^(-16)$, the error model is
  $E(h) approx C h + epsilon_"mach" abs(f(x)) slash h$; taking
  $abs(f(1)) = e approx 2.718$:

  #table(
    columns: 4, inset: 6pt, stroke: 0.4pt + luma(180), align: (center, center, center, center),
    table.header([$h$], [truncation $C h$], [roundoff $epsilon e slash h$], [total]),
    [$10^(-3)$], [$1.36 times 10^(-3)$], [$6.0 times 10^(-13)$], [$1.4 times 10^(-3)$],
    [$10^(-8)$], [$1.36 times 10^(-8)$], [$6.0 times 10^(-8)$], [$7.4 times 10^(-8)$],
    [$10^(-14)$], [$1.36 times 10^(-14)$], [$6.0 times 10^(-2)$], [$6.0 times 10^(-2)$],
  )

  $h = 10^(-8)$ wins by a wide margin.

  The theoretical optimum is
  $h^* = sqrt(epsilon_"mach" abs(f) slash C) approx sqrt(4.4 times 10^(-16)) approx 2 times 10^(-8)$,
  confirming the rule of thumb $h approx sqrt(epsilon_"mach")$.

  Note the last row: making $h$ *smaller* made the answer catastrophically
  worse. This is the single most counter-intuitive fact in numerical
  differentiation and the reason automatic differentiation is preferred.
]
