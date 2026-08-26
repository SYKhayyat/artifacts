#import "../lib.typ": *

= Notation Reference

Keep this page open. Nearly every "I cannot read this" is one unfamiliar
symbol, not a hard idea.

== Sets and logic

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$in$, $in.not$], [is / is not an element of], [8],
    [$subset.eq$, $subset.neq$], [subset; proper subset], [8],
    [$union$, $inter$], [union; intersection], [8],
    [$without$], [set difference], [8],
    [$overline(A)$, $A^c$], [complement], [8],
    [$emptyset$], [the empty set], [8],
    [$cal(P)(S)$], [power set: all subsets of $S$], [8],
    [$abs(S)$], [cardinality (number of elements)], [8],
    [$A times B$], [Cartesian product: set of ordered pairs], [8],
    [${x : P(x)}$], [set-builder: all $x$ such that $P(x)$], [8],
    [$forall$, $exists$], [for all; there exists], [7],
    [$not$, $and$, $or$], [not; and; or (inclusive)], [7],
    [$arrow.r.double$], [implies], [7],
    [$arrow.l.r.double$], [if and only if], [7],
    [$tilde$], [is distributed as; or an equivalence relation], [8, 28],
  )
]

== Number systems

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$NN$], [natural numbers ${0,1,2,dots}$], [1],
    [$ZZ$], [integers], [1],
    [$QQ$], [rationals], [1],
    [$RR$], [real numbers], [1],
    [$CC$], [complex numbers], [6],
    [$RR^n$], [$n$-tuples of reals; $n$-dimensional space], [19],
    [$RR^(m times n)$], [$m$-by-$n$ real matrices], [20],
    [$ZZ slash n ZZ$, $FF_p$], [integers mod $n$; the field of $p$ elements], [12],
    [$[a,b]$, $(a,b)$], [closed / open interval], [1],
    [$abs(x)$], [absolute value], [1],
    [$floor(x)$, $ceil(x)$], [floor; ceiling], [3],
    [$i$], [the imaginary unit, $i^2 = -1$], [6],
    [$overline(z)$], [complex conjugate], [6],
  )
]

== Sums, products, and operators

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$sum_(i=m)^n$], [sum from $i = m$ to $n$; empty sum is $0$], [2],
    [$product_(i=m)^n$], [product; empty product is $1$], [2],
    [$n!$], [factorial; $0! = 1$], [9],
    [$binom(n,k)$], ["$n$ choose $k$"], [9],
    [$gcd(a,b)$], [greatest common divisor], [12],
    [$a divides b$], [$a$ divides $b$ exactly], [12],
    [$a equiv b space (mod n)$], [congruent modulo $n$], [12],
    [$phi(n)$], [Euler's totient], [12],
  )
]

== Functions and calculus

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$f : A -> B$], [function from $A$ to $B$], [3],
    [$x arrow.bar f(x)$], [maps to (defines the rule)], [3],
    [$g compose f$], [composition; $f$ applied first], [3],
    [$f^(-1)$], [inverse function, or preimage of a set], [3, 8],
    [$exp$, $ln$, $log_a$], [exponential; natural log; log base $a$], [4],
    [$lg$], [$log_2$], [4],
    [$sigma(x)$], [logistic / sigmoid function], [4],
    [$lim_(x->a)$], [limit as $x$ approaches $a$], [13],
    [$epsilon$, $delta$], [tolerance and neighbourhood in a limit proof], [13],
    [$f'$, $f''$, $f^((n))$], [first, second, $n$-th derivative], [14],
    [$(dif y)/(dif x)$], [Leibniz notation for the derivative], [14],
    [$(partial f)/(partial x)$], [partial derivative], [18],
    [$dif x$], [differential; the variable of integration], [16],
    [$integral_a^b f(x) dif x$], [definite integral], [16],
    [$nabla f$], [gradient (column vector of partials)], [18],
    [$nabla^2 f$], [Laplacian (or sometimes the Hessian --- check)], [18],
    [$J$], [Jacobian matrix], [18],
    [$H$], [Hessian matrix], [18],
    [$O$, $Omega$, $Theta$, $o$], [asymptotic upper / lower / tight / strict bounds], [11],
    [$f tilde g$], [$f slash g -> 1$ (asymptotic equality)], [11],
  )
]

== Linear algebra

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$u dot v$, $u^T v$], [dot product / inner product], [19],
    [$norm(v)$], [Euclidean ($ell_2$) norm], [19],
    [$norm(v)_1$, $norm(v)_infinity$], [taxicab norm; max norm], [19],
    [$u times v$], [cross product (three dimensions only)], [19],
    [$span{dots}$], [set of all linear combinations], [19],
    [$dim V$], [dimension], [19],
    [$A^T$], [transpose], [20],
    [$A^(-1)$], [inverse], [20],
    [$A^+$], [Moore--Penrose pseudoinverse], [25],
    [$I$, $I_n$], [identity matrix], [20],
    [$tr(A)$], [trace: sum of the diagonal], [20],
    [$det A$, $abs(A)$], [determinant], [22],
    [$rank(A)$], [rank], [21],
    [$"Col"(A)$, $"Null"(A)$], [column space; null space (kernel)], [20],
    [$W^perp$], [orthogonal complement], [24],
    [$proj_v (u)$], [projection of $u$ onto $v$], [19],
    [$lambda$, $v$], [eigenvalue and eigenvector], [23],
    [$rho(A)$], [spectral radius: largest $abs(lambda)$], [23],
    [$sigma_i$], [singular values], [25],
    [$kappa(A)$], [condition number], [21, 25],
    [$norm(A)_2$, $norm(A)_F$], [spectral norm; Frobenius norm], [25],
    [$circle.small$], [elementwise (Hadamard) product], [26],
    [$mat(dots.down)$], [a matrix], [20],
  )
]

== Probability and statistics

#align(center)[
  #table(
    columns: (6.5em, 1fr, 2.6em), inset: 5pt, stroke: 0.4pt + luma(180), align: (center, left, center),
    table.header([*Symbol*], [*Meaning*], [*Ch.*]),
    [$Omega$], [sample space], [27],
    [$PP(A)$], [probability of event $A$], [27],
    [$PP(A | B)$], [conditional probability], [27],
    [$X$, $Y$], [random variables (capital letters, by convention)], [28],
    [$p(x)$, $f(x)$], [probability mass function; probability density], [28],
    [$F(x)$], [cumulative distribution function], [28],
    [$EE[X]$], [expectation], [28],
    [$Var(X)$, $sigma^2$], [variance], [28],
    [$sigma$], [standard deviation], [28],
    [$Cov(X,Y)$], [covariance], [29],
    [$rho$, $Corr$], [correlation], [29],
    [$Sigma$], [covariance matrix], [29],
    [$X tilde cal(N)(mu, sigma^2)$], [$X$ is normally distributed], [28],
    [$Bin$, $Pois$, $Unif$], [binomial, Poisson, uniform distributions], [28],
    [$overline(X)$], [sample mean], [30],
    [$hat(theta)$], [an estimator of $theta$ (hats mean estimates)], [31],
    [$cal(L)(theta)$], [likelihood], [31],
    [$ell(theta)$], [log-likelihood], [31],
    [$argmax$, $argmin$], [the argument achieving the max / min], [31],
    [$Hent(X)$], [entropy], [32],
    [$KL(p||q)$], [Kullback--Leibler divergence], [32],
    [$I(X;Y)$], [mutual information], [32],
    [i.i.d.], [independent and identically distributed], [30],
  )
]

== Conventions that trip people up

*Capitalisation.* Random variables are capital ($X$), their realised values
lowercase ($x$). Matrices are capital ($A$), vectors lowercase bold or plain
($v$), scalars lowercase. Not universal, but usual.

*Hats and bars.* $hat(theta)$ is an estimate; $overline(x)$ is an average;
$tilde(x)$ is usually "modified"; $x^*$ is usually "optimal" (or, in complex
analysis, a conjugate --- context decides).

*Vectors are columns.* Unless stated otherwise, $v in RR^n$ is $n times 1$.
So $u^T v$ is a scalar (inner product) and $u v^T$ is an $n times n$ matrix
(outer product). Getting these two backwards is the most common notational
error in matrix calculus.

*Subscripts versus superscripts in ML.* $W^((ell))$ with a parenthesised
superscript is layer $ell$, not a power. $x_i$ is usually the $i$-th sample or
the $i$-th component --- and which one is rarely stated. Infer from context and
from dimensions.

*$log$ without a base.* Base $e$ in mathematics, base 2 in computer science
and information theory, base 10 in engineering. Inside a big-O it does not
matter (Chapter 4). Elsewhere it does; check.

*"Iff".* Standard mathematical abbreviation for "if and only if". Not a typo.

*"WLOG".* "Without loss of generality" --- meaning a case has been assumed
that can be reduced to from the others by symmetry. A legitimate move that is
sometimes used to paper over a case the author did not check. When you see it,
verify the reduction actually works.

*The colon and the vertical bar.* In set-builder notation ${x : P(x)}$ and
${x | P(x)}$ mean the same thing. In probability, $|$ means "given". In
number theory, $|$ means "divides". Three unrelated meanings for one glyph;
context is all you have.
