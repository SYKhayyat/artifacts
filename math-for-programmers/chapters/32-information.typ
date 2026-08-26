#import "../lib.typ": *

= Information Theory

== Measuring surprise

Shannon's question in 1948: how much information is in a message?

The answer turns out to be a single formula, derivable from a handful of
requirements, and it explains simultaneously why compression has a hard limit,
why decision trees split the way they do, and why the loss function in every
classifier is what it is.

#intuition(title: "information is surprise")[
  Start from what "information" ought to mean.

  Learning that something *certain* happened tells you nothing. Learning that
  something *unlikely* happened tells you a lot. So information should be a
  decreasing function of probability.

  And information from *independent* sources should add: learning two
  unrelated facts should give you the sum. But independent probabilities
  *multiply*.

  So we need a function turning multiplication into addition. Chapter 4 has
  exactly one: the logarithm.

  $ I(x) = -log p(x) = log 1/(p(x)). $

  The minus sign makes it positive (probabilities are at most 1, so their logs
  are at most 0). With base 2 the unit is the *bit*; with base $e$, the *nat*.

  Sanity check: an event of probability $1 slash 2$ carries 1 bit. An event of
  probability $1 slash 1024$ carries 10 bits. A certain event carries 0. Those
  are the right answers.
]

== Entropy

#definition(title: "entropy")[
  $ Hent(X) = -sum_x p(x) log p(x) = EE[-log p(X)]. $
  The *average* surprise. Convention: $0 log 0 = 0$, justified since
  $lim_(p->0) p log p = 0$.
]

#example(title: "a fair coin, a biased coin, a die")[
  Fair coin: $Hent = -2 times (1 slash 2) log_2 (1 slash 2) = 1$ bit.

  Biased coin, $p = 0.9$:
  $Hent = -0.9 log_2 0.9 - 0.1 log_2 0.1 approx 0.47$ bits. Less uncertain,
  so less information per flip.

  Certain coin, $p = 1$: $Hent = 0$. No information at all.

  Fair die: $Hent = log_2 6 approx 2.58$ bits.
]

#theorem(title: "entropy is maximised by the uniform distribution")[
  For a distribution on $n$ outcomes, $Hent(X) <= log n$, with equality iff
  the distribution is uniform.
]

#proof[
  By Jensen's inequality (Chapter 28) applied to the concave function $log$:
  $ Hent(X) = sum_x p(x) log 1/(p(x)) <= log ( sum_x p(x) dot 1/(p(x)) ) = log n. $
  Equality in Jensen for a strictly concave function requires the argument to
  be constant, i.e. all $p(x)$ equal.
]

#intuition(title: "entropy is the cost of a description")[
  The operational meaning, and the reason entropy is not just a formula.

  *Shannon's source coding theorem:* the average number of bits needed to
  encode symbols from a source with entropy $Hent$ is at least $Hent$ per
  symbol, and codes exist achieving arbitrarily close to it.

  So entropy is *the compression limit*. You cannot do better, and you can get
  as close as you like.

  This also explains Huffman coding: assign short codes to frequent symbols
  and long codes to rare ones, with length approximately $-log_2 p(x)$. The
  average length is then approximately $Hent$, which is optimal. Arithmetic
  coding does better still by removing the integer-length constraint.

  And it explains why random data does not compress: a uniform distribution
  over $2^n$ possibilities has entropy exactly $n$ bits, so an $n$-bit random
  string needs $n$ bits. The pigeonhole argument of Chapter 9 was the crude
  version of this; entropy is the quantitative version.
]

== Cross-entropy and KL divergence

#definition(title: "cross-entropy")[
  $ Hent(p, q) = -sum_x p(x) log q(x). $
  The average number of bits used if you encode data from $p$ using a code
  optimised for $q$.
]

#definition(title: "Kullback--Leibler divergence")[
  $ KL(p || q) = sum_x p(x) log (p(x))/(q(x)) = Hent(p,q) - Hent(p). $
  The *extra* bits wasted by using the wrong distribution.
]

#theorem(title: "Gibbs' inequality")[
  $KL(p || q) >= 0$, with equality iff $p = q$.
]

#proof[
  Apply Jensen to the concave $log$:
  $ -KL(p||q) = sum_x p(x) log (q(x))/(p(x)) <= log ( sum_x p(x) (q(x))/(p(x)) ) = log sum_x q(x) = log 1 = 0. $
  Equality requires $q(x) slash p(x)$ constant, and since both sum to 1 that
  constant is 1.
]

#warning(title: "KL is not a distance")[
  $KL(p||q) != KL(q||p)$ in general --- it is not symmetric --- and it does
  not satisfy the triangle inequality. Calling it a "distance" will mislead
  you, which is why the literature says *divergence*.

  The asymmetry is not a defect; it is meaningful, and choosing the direction
  is a real modelling decision.

  $KL(p || q)$ with $p$ the truth is *mean-seeking*: it is enormous wherever
  $p$ has mass and $q$ does not, so a $q$ minimising it must cover all of
  $p$'s support. Fitting by maximum likelihood does this, and it is why an
  over-simple model fitted by MLE spreads itself thin to cover everything.

  $KL(q || p)$ is *mode-seeking*: it punishes $q$ for putting mass where $p$
  has none, so $q$ prefers to hug one mode and ignore the others. Variational
  inference minimises this direction, which is why variational approximations
  are notoriously over-confident and under-dispersed.

  If you need a symmetric measure, use the Jensen--Shannon divergence
  $"JS"(p,q) = 1/2 KL(p||m) + 1/2 KL(q||m)$ with $m = (p+q) slash 2$, whose
  square root *is* a metric.
]

#intuition(title: "why cross-entropy is the loss function")[
  Here is the four-line derivation promised in the preface.

  A classifier outputs a distribution $q$ over labels; the truth is a
  distribution $p$ (usually one-hot). You want $q$ close to $p$, so minimise
  $KL(p || q)$.

  But $KL(p||q) = Hent(p,q) - Hent(p)$, and $Hent(p)$ does not depend on your
  model at all --- it is a property of the data. So minimising KL is
  *identical* to minimising the cross-entropy $Hent(p,q)$.

  With one-hot $p$, all but one term vanishes and
  $ Hent(p,q) = -log q("true label"). $

  That is the cross-entropy loss, exactly as implemented. It is not an
  arbitrary choice; it is the KL divergence with a constant dropped.

  And one more equivalence: minimising $-log q("true label")$ summed over the
  dataset is *maximising the log-likelihood* (Chapter 31). Maximum likelihood,
  minimum cross-entropy, and minimum KL divergence are three names for one
  optimisation problem.
]

== Mutual information

#definition(title: "mutual information")[
  $ I(X;Y) = KL(p(x,y) || p(x)p(y)) = sum_(x,y) p(x,y) log (p(x,y))/(p(x)p(y)). $
  Equivalently,
  $ I(X;Y) = Hent(X) - Hent(X|Y) = Hent(Y) - Hent(Y|X) = Hent(X) + Hent(Y) - Hent(X,Y). $
]

#intuition(title: "mutual information is dependence of any kind")[
  Read the first form: it is the KL divergence between the true joint and what
  the joint *would* be if $X$ and $Y$ were independent. So it measures exactly
  how far from independent they are.

  By Gibbs, $I(X;Y) >= 0$ always, and $I(X;Y) = 0$ *if and only if $X$ and $Y$
  are independent*.

  That "if and only if" is the crucial difference from correlation. Chapter
  29's example --- $Y = X^2$ with $X$ symmetric --- has zero correlation and
  *positive* mutual information, correctly reporting that the variables are
  dependent. Correlation sees only linear structure; mutual information sees
  all of it.

  The second form reads: *the reduction in uncertainty about $X$ from learning
  $Y$*. That is the reading used in feature selection and in decision trees.
]

#example(title: "decision trees are greedy entropy reduction")[
  A decision tree chooses each split to maximise *information gain*:
  $ "IG" = Hent("parent") - sum_"children" (n_c)/n Hent("child"), $
  which is exactly $I(Y ; "split")$ --- the mutual information between the
  label and the split decision.

  So the tree greedily asks, at each node, "which question tells me the most
  about the label?" That is a direct application of this chapter, and it is
  why the algorithm is called ID3/C4.5 information gain.

  (Many implementations use Gini impurity instead, which is a computationally
  cheaper proxy behaving similarly --- it is the second-order Taylor expansion
  of entropy about the uniform distribution.)
]

== Continuous entropy, briefly

#definition(title: "differential entropy")[
  $ h(X) = -integral f(x) log f(x) dif x. $
]

Two warnings. Differential entropy can be *negative* (a distribution
concentrated in a small interval has density greater than 1 there), and it is
*not* invariant under change of variables --- rescaling $X$ shifts $h$ by
$log$ of the scale factor. So it is not "the amount of information in a
continuous variable" in any absolute sense.

What *is* well behaved is KL divergence and mutual information between
continuous variables: the offending terms cancel, and both remain invariant
under invertible reparameterisation. Use those.

#theorem(title: "the normal maximises entropy for a given variance")[
  Among all distributions on $RR$ with variance $sigma^2$, the one maximising
  differential entropy is $cal(N)(0, sigma^2)$, with
  $h = 1/2 log(2 pi e sigma^2)$.
]

This is the second of the three reasons for the normal distribution's
ubiquity, promised in Chapter 28. If all you know is a mean and a variance,
the normal is the distribution that assumes nothing further --- the
*maximum-entropy* choice.

The pattern generalises: fix the mean of a positive variable and you get the
exponential; fix the support only and you get the uniform; fix
$EE[log X]$ and $EE[X]$ and you get the gamma. Every distribution in the
exponential family is the maximum-entropy distribution subject to some set of
moment constraints, which is a satisfying explanation for why that particular
family keeps appearing.

== Where else this shows up

*Coding and compression.* Huffman, arithmetic coding, and Lempel--Ziv are all
attempts to reach the entropy bound. Modern neural compressors are literally
language models plus arithmetic coding: a better model means a lower
cross-entropy means fewer bits.

*Perplexity.* Language models report $2^Hent$ (or $e^Hent$) rather than
cross-entropy. It is the same number on a different scale, interpretable as
"the model is as confused as if it were choosing uniformly among this many
options". A perplexity of 20 means the model is effectively picking from 20
equally likely words.

*Channel capacity.* Shannon's other theorem: a noisy channel has a maximum
reliable rate $C = max_(p(x)) I(X;Y)$, and error-correcting codes can approach
it. This is why your modem, your disk, and your phone all work.

*The information bottleneck.* One theoretical account of representation
learning: a good hidden representation $T$ maximises $I(T; Y)$ (predictive of
the label) while minimising $I(T; X)$ (compressed away from the input).
Whether this explains deep learning is contested; it is at least a clean way
to state what a representation is for.

*Kolmogorov complexity.* An alternative definition of information: the length
of the shortest program that outputs the string. It is uncomputable (by a
diagonal argument descended from Chapter 1) but it connects to Shannon
entropy --- for a random string from a known source, the expected Kolmogorov
complexity is approximately its Shannon entropy. It is also the formal
grounding of Occam's razor and of the minimum description length principle.

== Exercises

#exercise[
  Compute the entropy in bits of: (a) a fair 8-sided die; (b) a distribution
  with probabilities $(0.5, 0.25, 0.125, 0.125)$; (c) a distribution with
  probabilities $(0.97, 0.01, 0.01, 0.01)$. Comment on the relationship
  between entropy and how compressible each source is.
]

#exercise[
  For (b) above, construct a Huffman code and verify its average codeword
  length equals the entropy exactly. Then determine whether (a) achieves
  equality, and explain why (c) cannot.
]

#exercise[
  Show that $Hent(X,Y) = Hent(X) + Hent(Y)$ if and only if $X$ and $Y$ are
  independent.
]

#exercise[
  Compute $KL(p||q)$ and $KL(q||p)$ for $p = (0.5, 0.5)$ and
  $q = (0.9, 0.1)$, and confirm they differ. Which is larger, and can you say
  why in terms of the mean-seeking versus mode-seeking discussion?
]

#exercise[
  Prove that cross-entropy loss with a one-hot target reduces to
  $-log q_(y)$, and show that its gradient with respect to the logits is
  $p - y$ (you may quote the softmax Jacobian from Chapter 26).
]

#exercise[
  A dataset has 60 positive and 40 negative examples. A candidate split sends
  50 examples one way (45 positive, 5 negative) and 50 the other. Compute the
  information gain of this split in bits.
]

#exercise[
  Show that $I(X;Y) = Hent(X) - Hent(X|Y)$ follows from the definition, and
  use it to explain why mutual information is symmetric even though
  conditional entropy is not.
]

#exercise[
  A language model achieves a cross-entropy of 3.2 nats per token on a test
  set. What is its perplexity? If a better model reaches 2.9 nats, by what
  factor has the perplexity improved, and roughly how much smaller would the
  compressed text be?
]
