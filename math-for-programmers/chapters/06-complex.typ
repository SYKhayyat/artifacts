#import "../lib.typ": *

= Complex Numbers

== The last bug fix

Chapter 1 described the number systems as a changelog: each one patches an
operation the previous one could not perform. One patch remains.

Over $RR$, the equation $x^2 + 1 = 0$ has no solution, because squares are
never negative. More generally, Chapter 2's discriminant told us a quadratic
with $Delta < 0$ has no real roots. That is unsatisfying in the same way that
$3 - 5$ having no natural-number answer was unsatisfying, and the fix is the
same: add the missing answer and see what else you are forced to add with it.

#definition(title: "the imaginary unit")[
  $i$ is a symbol satisfying $i^2 = -1$.
]

#warning(title: "$i$ is not 'imaginary' in any useful sense")[
  The name is a seventeenth-century insult that stuck. There is nothing less
  real about $i$ than about $-1$ (also once considered absurd) or $sqrt(2)$
  (which got a man killed, allegedly).

  A complex number is an ordered pair of reals with a particular multiplication
  rule. That is a completely concrete object --- you can store one in a struct
  --- and it models rotation in the plane exactly. Nothing mystical is
  happening.
]

#definition(title: "complex numbers")[
  $ CC = { a + b i : a, b in RR }, $
  with $a + b i = c + d i$ meaning $a = c$ and $b = d$. We call $a = "Re"(z)$
  the *real part* and $b = "Im"(z)$ the *imaginary part* (note: $"Im"(z)$ is a
  real number, not an imaginary one).

  Arithmetic is what you get by treating $i$ as a variable and reducing
  $i^2 -> -1$:
  $
  (a + b i) + (c + d i) &= (a + c) + (b + d) i \
  (a + b i)(c + d i) &= (a c - b d) + (a d + b c) i.
  $
]

Multiplication deserves a look: expanding gives
$a c + a d i + b c i + b d i^2$, and the last term is $-b d$ because
$i^2 = -1$. That single substitution is the entire difference from ordinary
polynomial arithmetic.

#proposition[
  $CC$ is a field: it is closed under $+, -, times$, and division by any
  nonzero element.
]

#proof[
  Closure under $+, -, times$ is visible in the formulas. For division, the
  question is whether $1 slash (a + b i)$ can be written in the form
  $c + d i$. Multiply top and bottom by $a - b i$:
  $ 1/(a + b i) = (a - b i)/((a + b i)(a - b i)) = (a - b i)/(a^2 + b^2) = a/(a^2+b^2) - b/(a^2+b^2) i. $
  The denominator $a^2 + b^2$ is a real number, and it is nonzero exactly when
  $a + b i != 0$. So the inverse exists and has the required form.
]

#definition(title: "conjugate and modulus")[
  The *conjugate* of $z = a + b i$ is $overline(z) = a - b i$.
  The *modulus* is $abs(z) = sqrt(a^2 + b^2)$.
]

The identity used in that proof, $z overline(z) = abs(z)^2$, is the workhorse.
It is how you divide, how you rationalise, and how you convert a complex
condition into a real one.

Useful and easily checked: $overline(z + w) = overline(z) + overline(w)$,
$overline(z w) = overline(z) dot overline(w)$, $abs(z w) = abs(z) abs(w)$,
and $z$ is real iff $z = overline(z)$.

== The complex plane

Plot $z = a + b i$ at the point $(a, b)$. Now:

- Addition is *vector addition*. Identical to Chapter 19's picture.
- $abs(z)$ is the distance from the origin.
- $overline(z)$ is reflection in the real axis.
- And multiplication is... what, geometrically?

That question has a beautiful answer, and it is the reason complex numbers are
useful rather than merely consistent.

#definition(title: "polar form")[
  Any nonzero $z$ can be written
  $ z = r(cos theta + i sin theta) $
  where $r = abs(z) > 0$ and $theta = arg(z)$ is the angle from the positive
  real axis, computed as `atan2(b, a)` (Chapter 5). $theta$ is determined only
  up to adding multiples of $2 pi$.
]

#theorem(title: "multiplication is rotation and scaling")[
  If $z = r(cos alpha + i sin alpha)$ and $w = s(cos beta + i sin beta)$ then
  $ z w = r s (cos(alpha + beta) + i sin(alpha + beta)). $
  That is: *moduli multiply, arguments add.*
]

#proof[
  Multiply out:
  $
  z w = r s [(cos alpha cos beta - sin alpha sin beta) + i(sin alpha cos beta + cos alpha sin beta)].
  $
  The two bracketed expressions are exactly $cos(alpha + beta)$ and
  $sin(alpha+beta)$ by the angle addition formulas of Chapter 5.
]

#intuition(title: "this is the whole point")[
  *Multiplying by a complex number is a rotation combined with a scaling.*

  Multiplying by $i$ (modulus $1$, argument $pi slash 2$) rotates by a quarter
  turn. Do it twice and you have rotated by half a turn, which is
  multiplication by $-1$. So $i^2 = -1$ is not an arbitrary stipulation; it is
  the statement that *two quarter turns make a half turn*.

  Once you see it, the entire theory of complex numbers becomes the theory of
  plane rotations, and the algebra and the geometry stop being separate
  subjects.
]

== Euler's formula

#theorem(title: "Euler's formula")[
  For all real $theta$,
  $ e^(i theta) = cos theta + i sin theta. $
]

The proof needs power series and appears in Chapter 17. But the *reason* it is
true can be stated now, and it is the more valuable half.

#intuition(title: "why $e^(i theta)$ has to be a rotation")[
  Chapter 4 said $e^x$ is characterised by growing at a rate equal to its own
  value. Formally, $f(t) = e^(k t)$ is the solution of $f' = k f$ with
  $f(0) = 1$.

  Now take $k = i$. The equation $f' = i f$ says: the velocity of the point
  $f(t)$ is its position, rotated a quarter turn.

  A velocity always perpendicular to the position vector is precisely
  *circular motion at constant speed*. Starting at $f(0) = 1$ on the unit
  circle, moving always perpendicular at unit speed, after time $theta$ you
  have travelled arc length $theta$ --- and by the definition of Chapter 5, you
  are at $(cos theta, sin theta)$.

  So $e^(i theta) = cos theta + i sin theta$ is not a coincidence between
  unrelated functions. It is the statement that *the exponential of an
  imaginary number is a rotation*, and it holds because perpendicular velocity
  means circular motion.
]

Setting $theta = pi$: $e^(i pi) = cos pi + i sin pi = -1$, so
$ e^(i pi) + 1 = 0, $
which is famous and is really just "half a turn takes you to $-1$."

Euler's formula collapses Chapter 5 into algebra. Polar form becomes
$z = r e^(i theta)$, and then the multiplication theorem is nothing but the
exponent law:
$ (r e^(i alpha))(s e^(i beta)) = r s e^(i(alpha + beta)). $
The angle addition formulas *are* $e^(i alpha) e^(i beta) = e^(i(alpha+beta))$,
with real and imaginary parts read off separately. Two identities anyone would
struggle to memorise, replaced by one they already know.

#theorem(title: "De Moivre's theorem")[
  For every integer $n$,
  $ (cos theta + i sin theta)^n = cos(n theta) + i sin(n theta). $
]

#proof[
  $(e^(i theta))^n = e^(i n theta)$ by the exponent law. Apply Euler's formula
  to both sides.
]

#example(title: "deriving a triple-angle formula in ten seconds")[
  Take $n = 3$ and expand the left side of De Moivre with the binomial
  theorem, writing $c = cos theta$, $s = sin theta$:
  $ (c + i s)^3 = c^3 + 3 c^2 (i s) + 3 c (i s)^2 + (i s)^3 = (c^3 - 3 c s^2) + i(3 c^2 s - s^3). $
  Equating real parts with $cos 3 theta$:
  $ cos 3 theta = cos^3 theta - 3 cos theta sin^2 theta = 4 cos^3 theta - 3 cos theta, $
  using $s^2 = 1 - c^2$. The imaginary parts give $sin 3 theta$ free of charge.

  Doing this with trigonometric identities alone is genuinely unpleasant. This
  is what complex numbers are *for*: they make trigonometric manipulation into
  routine algebra.
]

== Roots of unity

#definition(title: "$n$-th roots of unity")[
  The solutions of $z^n = 1$ in $CC$. There are exactly $n$ of them:
  $ omega_k = e^(2 pi i k slash n), quad k = 0, 1, dots, n-1. $
]

#proof[
  Write $z = r e^(i theta)$. Then $z^n = r^n e^(i n theta)$, and this equals
  $1 = 1 dot e^(i dot 0)$ iff $r^n = 1$ and $n theta$ is a multiple of
  $2 pi$. Since $r > 0$ is real, $r = 1$; and
  $theta = 2 pi k slash n$ for integer $k$. Values of $k$ differing by $n$ give
  the same $z$, so there are exactly $n$ distinct roots.
]

Geometrically these are $n$ equally spaced points on the unit circle, one of
them at $1$ --- the vertices of a regular $n$-gon.

#example(title: "the roots of unity are the FFT")[
  The discrete Fourier transform of a length-$n$ signal is
  $ X_k = sum_(j=0)^(n-1) x_j omega_n^(-j k), quad omega_n = e^(2 pi i slash n). $

  The Fast Fourier Transform is fast because of one algebraic property of
  these roots: $omega_n^2 = omega_(n slash 2)$. Squaring an $n$-th root of
  unity gives an $(n slash 2)$-th root of unity, so the length-$n$ problem
  splits into two length-$n slash 2$ problems over the same kind of object.
  That is the divide-and-conquer, and it is the reason the algorithm is
  $O(n log n)$ instead of $O(n^2)$.

  The whole of the FFT is this chapter plus a recursion.
]

#proposition[
  The $n$-th roots of unity sum to zero, for $n >= 2$.
]

#proof[
  They are $1, omega, omega^2, dots, omega^(n-1)$ for $omega = e^(2 pi i slash n)$,
  a geometric series. By the formula in Chapter 2,
  $ sum_(k=0)^(n-1) omega^k = (omega^n - 1)/(omega - 1) = (1 - 1)/(omega - 1) = 0, $
  legitimate since $omega != 1$ when $n >= 2$.

  Geometrically: $n$ equally spaced unit vectors are symmetric about the
  origin, so they cancel.
]

== The fundamental theorem of algebra

#theorem(title: "fundamental theorem of algebra")[
  Every non-constant polynomial with complex coefficients has at least one
  complex root. Consequently, a polynomial of degree $n$ factors completely:
  $ p(z) = a_n (z - r_1)(z - r_2) dots.c (z - r_n) $
  for some complex $r_1, dots, r_n$, not necessarily distinct.
]

The proof requires complex analysis and is beyond this book; the *consequence*
is what you need.

#intuition(title: "why this closes the changelog")[
  $NN$ was not closed under subtraction. $ZZ$ was not closed under division.
  $QQ$ was not closed under limits. $RR$ was not closed under taking roots.

  $CC$ is closed under *everything algebraic*. You cannot escape it by solving
  polynomial equations, no matter how you try. That property is called being
  *algebraically closed*, and it is why $CC$ is where the number-system
  changelog ends.
]

#corollary(title: "complex roots of real polynomials come in pairs")[
  If $p$ has real coefficients and $p(z) = 0$, then $p(overline(z)) = 0$.
]

#proof[
  Conjugation preserves sums and products, and fixes real numbers. So
  $ 0 = overline(0) = overline(p(z)) = overline(sum a_k z^k) = sum overline(a_k) thin overline(z)^k = sum a_k overline(z)^k = p(overline(z)), $
  where $overline(a_k) = a_k$ because the coefficients are real.
]

That is why a cubic with real coefficients always has at least one real root:
the three roots either are all real, or one is real and the other two are a
conjugate pair. Non-real roots cannot appear alone.

== Where complex numbers show up in your work

*Eigenvalues.* A real matrix can have complex eigenvalues (Chapter 23), and
when it does they come in conjugate pairs and encode a *rotation* in an
invariant plane. A rotation matrix in $RR^2$ has eigenvalues $e^(plus.minus i theta)$
--- the angle of rotation is sitting right there in the eigenvalue.

*Signal processing.* Every frequency-domain method is complex arithmetic. A
complex number carries amplitude (modulus) and phase (argument) in one object,
which is exactly what a sinusoid needs.

*Stability analysis.* A linear recurrence or differential equation is stable
iff certain roots lie inside the unit circle, or in the left half-plane. That
is a statement about complex numbers, and it is what a control engineer means
by "the poles".

*Quaternions.* Chapter 35. The 3D rotation representation used in every game
engine is a four-dimensional cousin of $CC$, built for the same reason: to
make rotation into multiplication.

== Exercises

#exercise[
  Compute, in the form $a + b i$: (a) $(3 + 2i)(1 - 4i)$, (b)
  $(2 + i) slash (3 - i)$, (c) $i^(2027)$, (d) $abs(3 - 4i)$.
]

#exercise[
  Write $z = -1 + i$ in polar form $r e^(i theta)$ with $theta in (-pi, pi]$,
  and then use De Moivre to compute $z^8$.
]

#exercise[
  Find all three solutions of $z^3 = 8$, in both polar and $a + b i$ form.
  Sketch where they sit in the plane.
]

#exercise[
  Prove that $abs(z w) = abs(z) abs(w)$ two ways: once by direct computation
  with $z = a + b i$, $w = c + d i$, and once in one line using polar form.
]

#exercise[
  Use Euler's formula to prove the identity
  $ cos alpha cos beta = 1/2 [cos(alpha - beta) + cos(alpha + beta)] $
  by writing each cosine as $(e^(i x) + e^(-i x)) slash 2$ and multiplying out.
]

#exercise[
  Let $omega = e^(2 pi i slash 5)$. Compute
  $1 + omega + omega^2 + omega^3 + omega^4$ and explain the answer both
  algebraically and geometrically.
]

#exercise[
  Show that the set of complex numbers with $abs(z) = 1$ is closed under
  multiplication and under taking inverses. (This makes it a *group* --- the
  circle group --- and it is the same group as 2D rotations.)
]
