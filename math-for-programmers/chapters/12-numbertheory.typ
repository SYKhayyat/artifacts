#import "../lib.typ": *

= Number Theory and Modular Arithmetic

== Why this is a programmer's subject

Number theory was the standard example of beautiful, useless mathematics for
two thousand years. Then it turned out to be the foundation of cryptography,
hashing, error correction, and random number generation, and now it runs
underneath every secure connection you make.

It is also, quietly, the arithmetic your CPU actually does. Chapter 1 warned
that a 64-bit integer lives in $ZZ slash 2^64 ZZ$, not $ZZ$. This chapter is
the theory of $ZZ slash n ZZ$.

== Divisibility

#definition(title: "divides")[
  For integers $a, b$ with $a != 0$, we say $a divides b$ ("$a$ divides $b$")
  if there is an integer $k$ with $b = a k$.
]

Note this says nothing about remainders --- it is exact division. Immediate
consequences, all one-liners: if $a divides b$ and $a divides c$ then
$a divides (b x + c y)$ for any integers $x, y$; divisibility is transitive;
and $a divides b$ with $b != 0$ forces $abs(a) <= abs(b)$.

#theorem(title: "division algorithm")[
  For integers $a$ and $n > 0$ there exist *unique* integers $q$ and $r$ with
  $ a = q n + r, quad 0 <= r < n. $
]

#proof[
  *Existence.* Consider the set $S = {a - q n : q in ZZ, thin a - q n >= 0}$.
  It is nonempty (take $q$ very negative). By well-ordering (Chapter 7) it has
  a least element $r = a - q n >= 0$. If $r >= n$ then $r - n = a - (q+1)n$ is
  a smaller nonnegative member of $S$, contradicting minimality. So $r < n$.

  *Uniqueness.* Suppose $a = q_1 n + r_1 = q_2 n + r_2$ with both remainders
  in $[0,n)$. Subtracting, $n(q_1 - q_2) = r_2 - r_1$. The right side has
  absolute value less than $n$; the left is a multiple of $n$. The only
  multiple of $n$ with absolute value less than $n$ is $0$. So $r_1 = r_2$ and
  then $q_1 = q_2$.
]

#warning(title: "your language's % is probably not this $r$")[
  The theorem guarantees $0 <= r < n$. In C, C++, Java, Rust, and Go,
  `-7 % 3` is $-1$, not $2$ --- these languages *truncate* the quotient
  towards zero, so the remainder takes the sign of the dividend.

  Python and Haskell use floored division, so `-7 % 3` is $2$, matching the
  mathematics.

  This is a real bug source in hashing and cyclic indexing: `arr[i % n]` will
  index negatively if `i` can be negative. The portable fix is
  `((i % n) + n) % n`. Know which convention your language uses; there is no
  agreement.
]

== Greatest common divisors

#definition(title: "gcd")[
  $gcd(a,b)$ is the largest integer dividing both $a$ and $b$, with
  $gcd(0,0)$ left undefined. $a$ and $b$ are *coprime* if $gcd(a,b) = 1$.
]

#theorem(title: "Euclid's algorithm is correct")[
  For $b > 0$, $ gcd(a,b) = gcd(b, a mod b). $
]

#proof[
  Write $a = q b + r$. We show the two pairs have *exactly the same* set of
  common divisors, which makes their greatest elements equal.

  If $d divides a$ and $d divides b$, then $d divides (a - q b) = r$, so $d$
  divides $b$ and $r$.

  Conversely if $d divides b$ and $d divides r$, then $d divides (q b + r) = a$,
  so $d$ divides $a$ and $b$.
]

#algo(title: "Euclid's algorithm")[
```
function gcd(a, b):
    while b != 0:
        (a, b) := (b, a mod b)
    return a
```
]

Termination is well-ordering: $b$ strictly decreases and stays nonnegative.

#proposition(title: "Euclid is fast")[
  Euclid's algorithm on $(a,b)$ with $a > b$ terminates in $O(log b)$
  iterations.
]

#proof[
  Claim: after two iterations the smaller argument has at least halved. Let
  $a = q b + r$. If $r <= b slash 2$ we are done in one step. If
  $r > b slash 2$, then $q = 1$ (since $a - b = r < b$ would need $q=1$;
  more carefully, $r > b slash 2$ and $r < b$), and the next step computes
  $b mod r = b - r < b slash 2$.

  So the second argument halves every two steps, giving at most
  $2 lg b$ iterations.
]

The worst case is consecutive Fibonacci numbers --- which is Lamé's theorem,
and it is why $phi$ shows up in the analysis of an algorithm about divisors.

#theorem(title: "Bézout's identity")[
  For any integers $a, b$ not both zero, there exist integers $x, y$ with
  $ a x + b y = gcd(a,b). $
  Moreover $gcd(a,b)$ is the *smallest* positive integer expressible in that
  form.
]

#proof[
  Let $S = {a x + b y : x, y in ZZ} inter ZZ_(>0)$, which is nonempty (it
  contains $abs(a)$ or $abs(b)$). By well-ordering let $d = a x_0 + b y_0$ be
  its least element.

  *$d$ divides $a$.* Divide: $a = q d + r$ with $0 <= r < d$. Then
  $ r = a - q d = a - q(a x_0 + b y_0) = a(1 - q x_0) + b(-q y_0), $
  which is of the form $a x + b y$. If $r > 0$ it would be a member of $S$
  smaller than $d$ --- impossible. So $r = 0$ and $d divides a$. By symmetry
  $d divides b$.

  *$d$ is the greatest such.* Any common divisor $c$ of $a$ and $b$ divides
  $a x_0 + b y_0 = d$, hence $c <= d$.
]

The *extended* Euclidean algorithm computes $x$ and $y$ alongside the gcd, by
tracking the coefficients through each step. It is the workhorse: it gives
modular inverses, solves linear Diophantine equations, and implements RSA key
generation.

#algo(title: "Extended Euclid")[
```
function extgcd(a, b):
    if b == 0: return (a, 1, 0)          # gcd = a = a*1 + b*0
    (g, x, y) := extgcd(b, a mod b)
    return (g, y, x - (a div b) * y)
```
]

#proof[
  Correctness by strong induction on $b$. Base $b = 0$: $gcd = a$ and
  $a dot 1 + 0 dot 0 = a$. Otherwise, by hypothesis the recursive call returns
  $g = gcd(b, a mod b) = gcd(a,b)$ with $b x + (a mod b) y = g$. Substituting
  $a mod b = a - floor(a slash b) b$:
  $ g = b x + (a - floor(a/b) b) y = a y + b (x - floor(a/b) y), $
  which is exactly what the code returns.
]

== Primes

#definition(title: "prime")[
  An integer $p >= 2$ is *prime* if its only positive divisors are $1$ and
  $p$. Otherwise it is *composite*.
]

$1$ is deliberately excluded, for a reason that becomes visible in a moment.

#lemma(title: "Euclid's lemma")[
  If $p$ is prime and $p divides a b$, then $p divides a$ or $p divides b$.
]

#proof[
  Suppose $p divides a b$ and $p divides.not a$. Since $p$ is prime and does
  not divide $a$, $gcd(p,a) = 1$. By Bézout there are $x,y$ with
  $p x + a y = 1$. Multiply through by $b$:
  $ b = b p x + a b y. $
  $p$ divides the first term obviously, and divides the second because
  $p divides a b$. So $p divides b$.
]

Note that this fails for composite numbers: $6 divides (4 dot 9)$ but $6$
divides neither.

#theorem(title: "fundamental theorem of arithmetic")[
  Every integer $n >= 2$ factors into primes, and the factorisation is unique
  up to the order of the factors.
]

#proof[
  *Existence* is the strong induction of Chapter 7.

  *Uniqueness.* Suppose some integer has two distinct factorisations; by
  well-ordering take the smallest such $n$, say
  $ n = p_1 p_2 dots.c p_r = q_1 q_2 dots.c q_s. $
  $p_1$ divides the right-hand product, so by Euclid's lemma (applied
  repeatedly) $p_1$ divides some $q_j$. Both are prime, so $p_1 = q_j$.
  Cancel it from both sides. The result is a smaller integer with two distinct
  factorisations --- contradicting minimality, unless the two factorisations
  were the same all along.
]

#intuition(title: "why 1 is not prime")[
  If $1$ were prime, $12 = 2 dot 2 dot 3 = 1 dot 2 dot 2 dot 3 = 1 dot 1 dot 2 dot 2 dot 3$
  and uniqueness would be destroyed.

  This is the same "choose the definition that makes the theorem clean"
  instinct as $0! = 1$ and $a^0 = 1$. The definitions are downstream of the
  theorems, not the other way round.
]

== Modular arithmetic

#definition(title: "congruence")[
  For $n >= 1$, we write $ a equiv b space (mod n) $ to mean $n divides (a - b)$.
]

By Chapter 8's vocabulary this is an equivalence relation --- reflexive,
symmetric, transitive --- so it partitions $ZZ$ into $n$ classes, the
*residues* $[0], [1], dots, [n-1]$. The set of classes is written
$ZZ slash n ZZ$, and it is exactly the integer type of width $n$.

#proposition(title: "congruence respects arithmetic")[
  If $a equiv b$ and $c equiv d$ (mod $n$), then
  $ a + c equiv b + d, quad a - c equiv b - d, quad a c equiv b d quad (mod n). $
]

#proof[
  Write $a = b + k n$ and $c = d + ell n$. Then $a + c = (b+d) + (k+ell)n$,
  and
  $ a c = (b + k n)(d + ell n) = b d + n(b ell + d k + k ell n), $
  so both differ from the claimed value by a multiple of $n$.
]

This is what makes modular arithmetic usable: you may reduce mod $n$ at *any
point* in a chain of additions and multiplications without changing the
answer. That is why you can compute a hash incrementally, and why you can keep
intermediate values small in modular exponentiation.

#warning(title: "division is the exception")[
  Cancellation fails. $2 dot 3 equiv 2 dot 8 space (mod 10)$, since both
  sides are $6$ and $16 equiv 6$. But $3 equiv.not 8 space (mod 10)$. You may
  not cancel the $2$.

  The reason is Chapter 2's zero divisors: $2 dot 5 equiv 0 space (mod 10)$
  with neither factor zero. $ZZ slash 10 ZZ$ is a ring but not a field, so not
  everything is invertible.
]

#theorem(title: "modular inverses")[
  $a$ has a multiplicative inverse mod $n$ --- an $x$ with $a x equiv 1$ ---
  if and only if $gcd(a,n) = 1$. When it exists it is unique mod $n$.
]

#proof[
  ($arrow.l.double$) If $gcd(a,n) = 1$, Bézout gives $a x + n y = 1$, so
  $a x equiv 1 space (mod n)$. The extended Euclidean algorithm computes $x$.

  ($arrow.r.double$) If $a x equiv 1$ then $a x - 1 = k n$, so
  $a x - k n = 1$, and any common divisor of $a$ and $n$ divides $1$.

  *Uniqueness:* if $a x equiv a x' equiv 1$ then
  $x equiv x (a x') equiv (x a) x' equiv x'$.
]

#corollary[
  $ZZ slash p ZZ$ is a field exactly when $p$ is prime.
]

#proof[
  If $p$ is prime, every $a in {1, dots, p-1}$ has $gcd(a,p) = 1$, so all
  nonzero elements are invertible. If $n$ is composite, $n = a b$ with
  $1 < a,b < n$, and then $a$ is a zero divisor, hence not invertible.
]

This field is written $FF_p$, and it is where error-correcting codes, secret
sharing, and elliptic-curve cryptography live.

== Fermat, Euler, and fast exponentiation

#theorem(title: "Fermat's little theorem")[
  If $p$ is prime and $p divides.not a$, then $ a^(p-1) equiv 1 space (mod p). $
]

#proof[
  Consider the $p-1$ numbers $a, 2a, 3a, dots, (p-1)a$ reduced mod $p$.

  None is $0$, since $p$ divides neither $a$ nor any of $1, dots, p-1$
  (Euclid's lemma). They are pairwise distinct: if $i a equiv j a$ then
  multiplying by $a^(-1)$ (which exists) gives $i equiv j$.

  So they are $p-1$ distinct nonzero residues --- that is, a permutation of
  $1, 2, dots, p-1$. Multiply them all together:
  $ a^(p-1) (p-1)! equiv (p-1)! space (mod p). $
  $(p-1)!$ is coprime to $p$, so it is invertible and cancels, leaving
  $a^(p-1) equiv 1$.
]

#definition(title: "Euler's totient")[
  $phi(n)$ is the number of integers in ${1, dots, n}$ coprime to $n$.
  For $p$ prime, $phi(p) = p-1$ and $phi(p^k) = p^k - p^(k-1)$. $phi$ is
  *multiplicative*: $phi(m n) = phi(m) phi(n)$ when $gcd(m,n) = 1$.
]

#theorem(title: "Euler's theorem")[
  If $gcd(a,n) = 1$ then $a^(phi(n)) equiv 1 space (mod n)$.
]

The proof is the same permutation argument, run over the $phi(n)$ invertible
residues instead of all of them. Fermat is the case $n = p$.

#algo(title: "Fast modular exponentiation (square and multiply)")[
```
function powmod(base, exp, m):
    result := 1
    base   := base mod m
    while exp > 0:
        if exp is odd:
            result := (result * base) mod m
        base := (base * base) mod m
        exp  := exp div 2
    return result
```
]

#proof[
  The loop invariant is: $"result" times "base"^"exp" equiv b^e space (mod m)$
  for the original $b, e$.

  *Initialisation:* result is 1, base is $b$, exp is $e$. Holds.

  *Maintenance:* if exp is even, $"base"^"exp" = ("base"^2)^("exp" slash 2)$,
  and the body replaces base by $"base"^2$ and exp by $"exp" slash 2$ --- the
  product is unchanged. If exp is odd, one factor of base is peeled off into
  result first, then the even case applies.

  *Termination:* exp reaches $0$, so the invariant reads
  $"result" equiv b^e$.
]

The running time is $O(log e)$ multiplications, since exp halves each
iteration. Computing $b^e$ naively would take $e$ multiplications and produce
astronomically large intermediate values; reducing mod $m$ at every step keeps
everything bounded. Both facts are essential and both are one-liners once you
have the theory.

#theorem(title: "Chinese remainder theorem")[
  Let $n_1, dots, n_k$ be pairwise coprime and $N = n_1 dots.c n_k$. Then the
  system
  $ x equiv a_1 space (mod n_1), quad dots, quad x equiv a_k space (mod n_k) $
  has a unique solution mod $N$.
]

#proof[
  *Existence, constructively.* For each $i$ let $N_i = N slash n_i$. Then
  $gcd(N_i, n_i) = 1$ (every prime factor of $N_i$ divides some $n_j$ with
  $j != i$, and those are coprime to $n_i$), so $N_i$ has an inverse $M_i$ mod
  $n_i$. Set
  $ x = sum_(i=1)^k a_i N_i M_i. $
  Modulo $n_j$, every term with $i != j$ vanishes (since $n_j divides N_i$),
  leaving $x equiv a_j N_j M_j equiv a_j space (mod n_j)$.

  *Uniqueness.* If $x$ and $x'$ both work, then $n_i divides (x - x')$ for
  every $i$; since the $n_i$ are pairwise coprime, $N divides (x - x')$.
]

CRT is why RSA decryption can be done about four times faster by working mod
$p$ and mod $q$ separately, and it is the basis of residue number systems for
fast big-integer arithmetic.

== A worked application: RSA in outline

Enough theory has accumulated to see the whole thing.

+ Pick large primes $p, q$; set $N = p q$ and $phi(N) = (p-1)(q-1)$.
+ Pick $e$ coprime to $phi(N)$ --- commonly $65537$.
+ Compute $d equiv e^(-1) space (mod phi(N))$ by extended Euclid.
+ Public key $(N, e)$; private key $d$.
+ Encrypt: $c = m^e mod N$. Decrypt: $m = c^d mod N$.

#proof[
  Why decryption inverts encryption. By construction $e d = 1 + k phi(N)$ for
  some integer $k$. So, for $m$ coprime to $N$,
  $ c^d equiv m^(e d) = m^(1 + k phi(N)) = m dot (m^(phi(N)))^k equiv m dot 1^k = m space (mod N) $
  by Euler's theorem. (The case where $m$ shares a factor with $N$ is handled
  by CRT and also works out.)
]

The security rests on the belief that recovering $d$ requires knowing
$phi(N)$, which requires factoring $N$ --- and that factoring large integers
is hard. Note that this is a *belief*, not a theorem: nobody has proved
factoring is hard, and Shor's algorithm factors in polynomial time on a
quantum computer.

== Primes in practice

*Density.* The prime number theorem says the number of primes below $x$ is
approximately $x slash ln x$. So a random 2048-bit number is prime with
probability about $1 slash ln(2^2048) approx 1 slash 1420$ --- and about
twice that if you skip evens. Generating an RSA prime is: pick at random, test,
repeat a few hundred times.

*Testing.* Deterministic primality testing is polynomial (the AKS algorithm)
but slow. In practice, Miller--Rabin: a randomised test that uses Fermat's
little theorem as a *necessary* condition. If $a^(n-1) equiv.not 1 space (mod n)$
for some $a$, then $n$ is definitely composite. The converse is not quite true
--- the *Carmichael numbers* fool the naive Fermat test for every $a$ --- and
Miller--Rabin patches the hole by also checking for nontrivial square roots of
$1$.

*Hash tables.* Using a prime modulus spreads keys better when the keys have
structure. If your table size is $2^k$, then `h % size` keeps only the low $k$
bits, so any pattern in the low bits of your hash becomes a pattern in your
bucket distribution. A prime modulus mixes all the bits into the result. The
modern alternative is to keep a power-of-two size, which allows a cheap mask
instead of a division, and fix the hash function instead --- but then the hash
function had better actually mix.

== Exercises

#exercise[
  Compute $gcd(1071, 462)$ by hand with Euclid's algorithm, showing each step,
  and then run the extended version to find $x, y$ with
  $1071 x + 462 y = gcd$.
]

#exercise[
  Find the multiplicative inverse of $17$ modulo $43$, and verify it.
]

#exercise[
  Solve the system $x equiv 2 space (mod 3)$, $x equiv 3 space (mod 5)$,
  $x equiv 2 space (mod 7)$, using the CRT construction. Give the unique
  solution mod $105$.
]

#exercise[
  Compute $7^(222) mod 11$ two ways: by Fermat's little theorem, and by
  square-and-multiply. Confirm they agree.
]

#exercise[
  Prove that if $gcd(a, n) = d > 1$ then the congruence $a x equiv 1 space (mod n)$
  has no solution. (This is half of the modular-inverse theorem; write it out
  yourself.)
]

#exercise[
  Prove that $n^2 equiv 0$ or $1 space (mod 4)$ for every integer $n$, and use
  this to show that no integer of the form $4k + 3$ is a sum of two squares.
]

#exercise[
  Show that $phi(n)$ is even for every $n > 2$. Hint: pair each $a$ coprime to
  $n$ with $n - a$.
]

#exercise[
  Your language computes `-17 % 5`. Give the value under truncated division
  and under floored division, and write a one-line expression that returns the
  mathematically correct residue in $[0, 5)$ under either convention.
]
