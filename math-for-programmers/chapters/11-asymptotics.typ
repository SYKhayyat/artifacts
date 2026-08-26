#import "../lib.typ": *

= Recurrences and Asymptotics

== Two halves of one subject

You want to know how long a program takes. That question splits into two
mathematical questions.

First, *set up*: express the cost of size-$n$ input in terms of the cost of
smaller inputs. That is a *recurrence*.

Second, *solve and simplify*: turn the recurrence into a growth rate, and
throw away the detail that does not matter. That is *asymptotics*.

This chapter does both, properly. Most treatments give you the Master Theorem
as a lookup table; here we will prove it, because the proof tells you what to
do when the table does not apply.

== Asymptotic notation

#definition(title: "big-O, big-Omega, big-Theta")[
  For functions $f, g : NN -> RR_(>=0)$:

  $ f(n) = O(g(n)) $ means there exist constants $C > 0$ and $n_0$ such that
  $f(n) <= C g(n)$ for all $n >= n_0$.

  $ f(n) = Omega(g(n)) $ means $f(n) >= c g(n)$ for some $c > 0$ and all large
  $n$. (Equivalently, $g(n) = O(f(n))$.)

  $ f(n) = Theta(g(n)) $ means both: $c g(n) <= f(n) <= C g(n)$ for large $n$.
]

#warning(title: "the equals sign is a lie")[
  $f(n) = O(g(n))$ is not an equation. $O(g(n))$ denotes a *set* of functions,
  and the honest notation is $f in O(g)$. The traditional abuse means:

  - it is not symmetric. $n = O(n^2)$ is true; $n^2 = O(n)$ is false. You
    cannot read it backwards.
  - it is not transitive in the way an equation would be. From
    $n = O(n^2)$ and $n^2 = O(n^2)$ you may not conclude $n = n^2$.
  - $O(n) + O(n) = O(n)$ is a true statement in which the same symbol denotes
    different things on the two sides.

  Read $=$ as "is" throughout, in the sense of set membership, and no harm
  comes of it.
]

#intuition(title: "what each one is for")[
  $O$ is an *upper bound*: it will take no longer than this. Use it for
  guarantees.

  $Omega$ is a *lower bound*: it will take at least this long. Use it for
  impossibility results --- "no comparison sort beats $Omega(n log n)$".

  $Theta$ is *both*: the growth rate is exactly this. Use it when you actually
  know.

  Most people write $O$ when they mean $Theta$. Saying quicksort is
  $O(n^2)$ is true and useless; saying it is $Theta(n log n)$ on average and
  $Theta(n^2)$ in the worst case is informative. Be precise about which you
  mean and you will think more clearly.
]

There are also the strict versions: $f = o(g)$ means $f(n) slash g(n) -> 0$
("strictly smaller order"), and $f = omega(g)$ the reverse. And
$f tilde g$ means $f(n) slash g(n) -> 1$ --- asymptotic equality, which keeps
the constant. Stirling's formula $n! tilde sqrt(2 pi n)(n slash e)^n$ is a
$tilde$ statement, and it would be much weaker as a $Theta$ statement.

=== Working with it

#proposition(title: "the rules you will use")[
  #set enum(numbering: "(a)")
  + $O(f) + O(g) = O(max(f,g))$.
  + $O(f) dot O(g) = O(f g)$.
  + $c dot O(f) = O(f)$ for constant $c > 0$.
  + A polynomial of degree $d$ is $Theta(n^d)$.
  + $log_a n = Theta(log_b n)$ for any bases (Chapter 4).
]

#proof[
  We do (a) and (d); the rest are similar.

  *(a)* Suppose $f_1 <= C_1 f$ and $g_1 <= C_2 g$ for large $n$. Then
  $f_1 + g_1 <= C_1 f + C_2 g <= (C_1 + C_2) max(f,g)$.

  *(d)* Let $p(n) = a_d n^d + dots.c + a_0$ with $a_d > 0$. For the upper
  bound, $p(n) <= (abs(a_d) + dots.c + abs(a_0)) n^d$ for $n >= 1$, since
  each $n^k <= n^d$. For the lower bound, note
  $p(n) slash n^d -> a_d$, so for large enough $n$ it exceeds $a_d slash 2$,
  giving $p(n) >= (a_d slash 2) n^d$.
]

The growth hierarchy from Chapter 4 in this notation:
$ 1 lt.double log log n lt.double log n lt.double n^epsilon lt.double n lt.double n log n lt.double n^2 lt.double 2^n lt.double n! lt.double n^n $
where $lt.double$ now means $o(dot)$.

#warning(title: "asymptotics is a statement about the limit, not about your data")[
  $O$ hides constants and only describes behaviour for large $n$. Both caveats
  bite in practice.

  Matrix multiplication has an $O(n^(2.37))$ algorithm. Nobody uses it: the
  constant is astronomical and the crossover with the $O(n^3)$ method is
  beyond any matrix that will ever be multiplied.

  Insertion sort is $Theta(n^2)$ and merge sort is $Theta(n log n)$, and every
  serious sort implementation switches to insertion sort below about $n = 16$,
  because the constants dominate there.

  Asymptotics answers "how does the cost scale?", which is a genuinely
  important question and is not the same question as "how long does it take?"
]

== Solving recurrences

=== Method 1: unrolling

Expand the recurrence a few times, spot the pattern, sum the series, verify by
induction.

#example(title: "unrolling a linear recurrence")[
  $T(n) = T(n-1) + n$, $T(0) = 0$.

  $
  T(n) &= T(n-1) + n \
       &= T(n-2) + (n-1) + n \
       &= T(n-3) + (n-2) + (n-1) + n \
       &= dots.c = T(0) + 1 + 2 + dots.c + n = (n(n+1))/2 = Theta(n^2).
  $

  The pattern after $k$ steps is $T(n) = T(n-k) + sum_(i=n-k+1)^n i$; setting
  $k = n$ terminates it. This is the cost of insertion sort and of the naive
  quicksort worst case.
]

#example(title: "unrolling a divide-and-conquer recurrence")[
  $T(n) = 2 T(n slash 2) + n$, $T(1) = 1$. Take $n = 2^k$.

  $
  T(n) &= 2 T(n/2) + n \
       &= 2[2 T(n/4) + n/2] + n = 4 T(n/4) + 2n \
       &= 8 T(n/8) + 3n = dots.c = 2^k T(n slash 2^k) + k n.
  $

  With $k = lg n$: $T(n) = n T(1) + n lg n = Theta(n log n)$.

  Read the structure: at every level of the recursion the total work is $n$,
  and there are $lg n$ levels. That picture --- *work per level, times number
  of levels* --- is the whole content of the Master Theorem.
]

=== Method 2: the recursion tree

Draw the recursion as a tree. Each node is a subproblem, labelled with the
work done *at that node* excluding recursive calls. The total is the sum over
all nodes, and the useful way to sum is level by level.

For $T(n) = a T(n slash b) + f(n)$:

- level $0$: one node, work $f(n)$;
- level $1$: $a$ nodes, work $a f(n slash b)$;
- level $i$: $a^i$ nodes, work $a^i f(n slash b^i)$;
- the tree has depth $log_b n$, and $a^(log_b n) = n^(log_b a)$ leaves.

Total: $ T(n) = sum_(i=0)^(log_b n - 1) a^i f(n/b^i) + Theta(n^(log_b a)). $

The behaviour depends entirely on whether that geometric-ish sum is dominated
by its first term, its last term, or spread evenly. That trichotomy is the
Master Theorem.

=== Method 3: the Master Theorem

#theorem(title: "Master Theorem")[
  Let $T(n) = a T(n slash b) + f(n)$ with $a >= 1$, $b > 1$. Write
  $c = log_b a$ (so $n^c$ is the number of leaves).

  #set enum(numbering: "(i)")
  + If $f(n) = O(n^(c - epsilon))$ for some $epsilon > 0$, then
    $T(n) = Theta(n^c)$. *(Leaves dominate.)*
  + If $f(n) = Theta(n^c)$, then $T(n) = Theta(n^c log n)$.
    *(Every level costs the same.)*
  + If $f(n) = Omega(n^(c + epsilon))$ for some $epsilon > 0$, and
    $a f(n slash b) <= k f(n)$ for some $k < 1$ and large $n$ (a regularity
    condition), then $T(n) = Theta(f(n))$. *(The root dominates.)*
]

#proof[
  From the recursion tree, $T(n) = Theta(n^c) + sum_(i=0)^(log_b n - 1) a^i f(n slash b^i)$.
  Call the sum $S$.

  *Case (ii).* $f(n) = Theta(n^c)$ gives
  $a^i f(n slash b^i) = Theta(a^i (n slash b^i)^c) = Theta(n^c a^i slash b^(i c))$.
  But $b^c = b^(log_b a) = a$, so $a^i slash b^(i c) = 1$: every level
  contributes $Theta(n^c)$. There are $log_b n$ levels, so
  $S = Theta(n^c log n)$, which dominates the $Theta(n^c)$ leaf term.

  *Case (i).* $f(n) = O(n^(c-epsilon))$ gives
  $a^i f(n slash b^i) = O(n^(c - epsilon) a^i slash b^(i(c - epsilon))) = O(n^(c-epsilon) b^(i epsilon))$,
  using $a^i slash b^(i c) = 1$ again. Summing the geometric series in
  $b^epsilon > 1$:
  $ S = O( n^(c-epsilon) (b^(epsilon log_b n) - 1)/(b^epsilon - 1) ) = O(n^(c - epsilon) dot n^epsilon) = O(n^c). $
  So $S$ does not exceed the leaf term, and $T(n) = Theta(n^c)$.

  *Case (iii).* The regularity condition says each level is at most $k$ times
  the previous, with $k < 1$. So $S <= f(n) sum_(i>=0) k^i = f(n) slash (1-k) = O(f(n))$,
  and $S >= f(n)$ trivially from the $i=0$ term. Hence $S = Theta(f(n))$, and
  one checks this dominates $n^c$ under the case hypothesis.
]

#example(title: "the standard applications")[
  #align(center)[
    #table(
      columns: 5,
      inset: 7pt,
      align: (left, center, center, center, left),
      stroke: 0.4pt + luma(180),
      table.header([*Algorithm*], [$a$], [$b$], [$f(n)$], [*Result*]),
      [Binary search], [1], [2], [$Theta(1)$], [$c=0$, case (ii): $Theta(log n)$],
      [Merge sort], [2], [2], [$Theta(n)$], [$c=1$, case (ii): $Theta(n log n)$],
      [Naive matrix mult.], [8], [2], [$Theta(n^2)$], [$c=3$, case (i): $Theta(n^3)$],
      [Strassen], [7], [2], [$Theta(n^2)$], [$c=lg 7$, case (i): $Theta(n^(2.807))$],
      [Karatsuba], [3], [2], [$Theta(n)$], [$c=lg 3$, case (i): $Theta(n^(1.585))$],
    )
  ]

  Strassen's algorithm is the Master Theorem applied as a *design* tool: the
  naive method has $a = 8$, and reducing $a$ to $7$ at the cost of extra
  additions (which stay in $f$) lowers the exponent, because the exponent is
  $log_2 a$ and nothing else.
]

#warning(title: "the Master Theorem does not always apply")[
  There is a gap between the cases: if $f(n)$ is larger than $n^c$ but not
  *polynomially* larger, none of the three cases fires. The standard example
  is $T(n) = 2T(n slash 2) + n log n$, where $c = 1$ and $f(n) = n log n$ ---
  bigger than $n$ by only a logarithmic factor.

  Here the recursion tree still works: every level costs $Theta(n log n)$
  near the top and there are $log n$ levels, giving $Theta(n log^2 n)$. When
  the theorem fails, go back to the tree.
]

=== Method 4: substitution

Guess the answer, prove it by induction. Unglamorous and always available.

#example[
  Show $T(n) = 2T(floor(n slash 2)) + n$ is $O(n log n)$.

  *Guess:* $T(n) <= C n lg n$ for $n >= 2$ and some constant $C$.

  *Step:* assume it for all smaller arguments. Then
  $
  T(n) &<= 2 C floor(n/2) lg floor(n/2) + n \
       &<= 2 C (n/2) lg (n/2) + n \
       &= C n (lg n - 1) + n = C n lg n - C n + n.
  $
  This is at most $C n lg n$ provided $-C n + n <= 0$, i.e. $C >= 1$. Choose
  $C$ large enough to also cover the base case, and the induction goes
  through.
]

#warning(title: "the classic substitution error")[
  Do not "prove" $T(n) = O(n)$ for $T(n) = 2T(n slash 2) + n$ by writing
  $T(n) <= 2 C(n slash 2) + n = C n + n = O(n)$.

  The final step is wrong: you needed to establish $T(n) <= C n$, and you
  established $T(n) <= C n + n$, which is bigger. The inductive hypothesis
  must be reproduced *exactly*, with the same constant, not merely up to
  big-O. Sloppiness here proves false statements, and this particular false
  statement is a rite of passage.
]

== Linear recurrences with constant coefficients

A different family, and one with a complete closed-form theory.

#definition[
  A *linear homogeneous recurrence with constant coefficients* has the form
  $ a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots.c + c_k a_(n-k). $
]

#theorem(title: "solution by characteristic roots")[
  Form the *characteristic polynomial*
  $ x^k - c_1 x^(k-1) - c_2 x^(k-2) - dots.c - c_k. $
  If it has $k$ distinct roots $r_1, dots, r_k$, then every solution has the
  form
  $ a_n = A_1 r_1^n + A_2 r_2^n + dots.c + A_k r_k^n, $
  with the constants $A_i$ determined by the initial conditions. A root of
  multiplicity $m$ contributes $ (A_0 + A_1 n + dots.c + A_(m-1) n^(m-1)) r^n. $
]

#proof[
  *Why the form works:* substitute $a_n = r^n$ into the recurrence. Dividing
  through by $r^(n-k)$ turns it into exactly the characteristic equation. So
  $r^n$ solves the recurrence precisely when $r$ is a characteristic root.

  *Why any combination works:* the recurrence is linear, so a linear
  combination of solutions is a solution (check by substituting).

  *Why every solution has this form:* a solution is determined by its first
  $k$ values, so the solution space has dimension $k$ (Chapter 21). The $k$
  functions $r_i^n$ are linearly independent when the $r_i$ are distinct, so
  they span it.
]

#example(title: "Fibonacci in closed form")[
  $F_n = F_(n-1) + F_(n-2)$, $F_0 = 0$, $F_1 = 1$.

  Characteristic polynomial: $x^2 - x - 1$, with roots
  $ phi = (1 + sqrt(5))/2 approx 1.618, quad psi = (1 - sqrt(5))/2 approx -0.618. $

  So $F_n = A phi^n + B psi^n$. From $F_0 = 0$: $A + B = 0$. From $F_1 = 1$:
  $A phi + B psi = 1$, so $A(phi - psi) = 1$ and $phi - psi = sqrt(5)$. Hence
  $A = 1 slash sqrt(5)$, $B = -1 slash sqrt(5)$, giving *Binet's formula*:
  $ F_n = (phi^n - psi^n)/sqrt(5). $

  Since $abs(psi) < 1$, the second term vanishes fast: $F_n$ is the nearest
  integer to $phi^n slash sqrt(5)$ for every $n >= 0$. So Fibonacci grows
  exponentially with base $phi$ --- which is why naive recursive `fib` is
  $Theta(phi^n)$, not $Theta(2^n)$ as people often say.
]

#intuition(title: "characteristic roots are eigenvalues")[
  Write the recurrence as a matrix acting on the state vector:
  $ vec(F_n, F_(n-1)) = mat(1,1;1,0) vec(F_(n-1), F_(n-2)). $
  Then $F_n$ is read off from $M^n$ applied to the initial state. Chapter 23
  will show that computing $M^n$ amounts to diagonalising $M$, and its
  eigenvalues are the roots of $det(M - lambda I) = lambda^2 - lambda - 1$ ---
  the characteristic polynomial, appearing under its proper name.

  So "solving a linear recurrence" and "diagonalising a matrix" are the same
  operation. It is also the reason you can compute $F_n$ in $O(log n)$ time by
  fast matrix exponentiation.
]

== Amortised analysis, briefly

#definition(title: "amortised cost")[
  The *amortised* cost of an operation is the total cost of a worst-case
  sequence of $m$ operations, divided by $m$. It is a statement about
  sequences, not about single calls.
]

Three standard techniques: *aggregate* (count the total directly), *accounting*
(overcharge cheap operations to bank credit for expensive ones), and
*potential* (define a function of the data structure state whose drop pays for
expensive operations).

#example(title: "dynamic array doubling, three ways")[
  *Aggregate.* Chapter 2 already did it: $n$ insertions cost
  $n + (1 + 2 + 4 + dots.c) < n + 2n = 3n$, so $O(1)$ amortised.

  *Accounting.* Charge 3 units per insertion. One pays for the insert itself;
  one is banked to pay for copying this element at the next resize; one is
  banked to pay for copying an element from the first half, which had already
  spent its own credit at the previous resize. The bank never goes negative,
  so 3 units per operation suffices.

  *Potential.* Let $Phi = 2 dot ("size") - ("capacity")$. A non-resizing
  insert raises $Phi$ by 2, so its amortised cost is $1 + 2 = 3$. A resizing
  insert copies $s$ elements at real cost $s+1$, while $Phi$ falls from
  $2s - s = s$ to $2(s+1) - 2s = 2$, a drop of $s - 2$; amortised cost
  $(s+1) - (s-2) = 3$. Uniformly 3.

  Amortised $O(1)$ is genuinely weaker than worst-case $O(1)$: individual
  operations still take $Theta(n)$, which matters for latency and is why
  real-time systems use incremental resizing instead.
]

== Exercises

#exercise[
  Prove directly from the definition that $3n^2 + 100 n + 7 = Theta(n^2)$, by
  exhibiting explicit constants $c$, $C$, and $n_0$.
]

#exercise[
  Order these by growth rate, and justify each comparison:
  $n log n$, $2^(log n)$, $n^(1.5)$, $n (log n)^2$, $2^n$, $n!$, $log(n!)$,
  $sqrt(n)$.
]

#exercise[
  Solve $T(n) = T(n-1) + 1 slash n$, $T(1) = 1$, by unrolling. (Your answer
  will involve the harmonic numbers; state the asymptotic growth.)
]

#exercise[
  Apply the Master Theorem where possible: (a) $T(n) = 4T(n slash 2) + n$;
  (b) $T(n) = 4T(n slash 2) + n^2$; (c) $T(n) = 4T(n slash 2) + n^3$;
  (d) $T(n) = 2T(n slash 2) + n slash log n$. For any case where it does not
  apply, say why and solve it with a recursion tree.
]

#exercise[
  Prove by substitution that $T(n) = T(n slash 3) + T(2n slash 3) + n$ is
  $O(n log n)$. (Note the two subproblems have different sizes, so the Master
  Theorem does not apply.)
]

#exercise[
  Solve $a_n = 5 a_(n-1) - 6 a_(n-2)$ with $a_0 = 1$, $a_1 = 4$, using
  characteristic roots.
]

#exercise[
  Solve $a_n = 4a_(n-1) - 4a_(n-2)$ with $a_0 = 1$, $a_1 = 6$. Note the
  repeated root and use the correct form.
]

#exercise[
  A stack supports `push`, `pop`, and `multipop(k)` which pops $\min(k, "size")$
  items. Show by the accounting method that all three have amortised cost
  $O(1)$, even though a single `multipop` can cost $Theta(n)$.
]
