#import "../lib.typ": *

= How to Read This Book

== What this is

This is a rebuild, not a refresher.

The assumption behind it is specific: you are a working programmer. You think
precisely for a living. You can hold an abstraction in your head, you can
follow a chain of reasoning ten steps long, and you have written code that had
to be *correct*, not merely plausible. What you do not have is the
mathematics, because high school was a while ago and high school was not very
good at this anyway.

That combination is unusual and it changes what the right book looks like.
Most "math for programmers" books assume you remember calculus and want a
quick tour. Most "start from scratch" books assume you are sixteen and need to
be coaxed. Neither is you. You need to start from genuinely low ground --- we
will define what a number is --- but you can be moved fast, and you can be
told the truth about why things work instead of being handed rules to obey.

So this is the deal the book makes:

- *Nothing is assumed.* Not logarithms, not trigonometry, not what a function
  is. Chapter 1 starts at the counting numbers.
- *Nothing is hand-waved either.* When a result matters, you get a proof. Not
  a gesture at a proof --- an actual argument you can check line by line.
- *The intuition comes first, always.* Before any definition there is a
  paragraph telling you what picture to have in your head and what problem the
  definition was invented to solve. Definitions in mathematics are not
  arbitrary. Every one of them is somebody else's solution to a difficulty,
  and you will be told what the difficulty was.
- *You already know how to compute.* So the book leans on that. Algorithms
  appear as pseudocode. Numerical behaviour --- overflow, cancellation,
  conditioning --- is treated as first-class mathematics, because for you it
  is.

== What is in it, and why

The six parts are ordered by dependency, not by tradition.

*Part I --- Rebuilding the Ground.* Numbers, algebra, functions, exponentials
and logarithms, trigonometry, complex numbers. Then proof technique. This part
exists because every later part will silently use it, and a shaky base here
shows up three hundred pages later as "I can follow each step but I have no
idea what is happening."

The proof chapter is the hinge of the whole book. You already know induction
from reasoning about recursion; that is a much better starting point than most
people have. We build outward from it.

*Part II --- Discrete Mathematics.* Sets, relations, counting, graphs,
recurrences and asymptotics, number theory. This is the mathematics already
inside your code whether or not you have named it. It is also the gentlest
place to practise proof, because the objects are finite and concrete.

*Part III --- Calculus.* Limits, derivatives, integrals, series, and then
multivariable calculus. The destination is the gradient. Everything in machine
learning that "learns" is doing one thing: computing a gradient and stepping
against it. You cannot understand that from the outside.

*Part IV --- Linear Algebra.* If you only had time for one part, it would be
this one. Matrices are not tables of numbers; they are functions, and the
whole subject becomes easy the moment that clicks. We go all the way to the
singular value decomposition and to matrix calculus, which is the notation ML
papers are actually written in.

*Part V --- Probability and Statistics.* From the axioms through to maximum
likelihood, Bayesian inference, hypothesis testing, and information theory.
Cross-entropy loss is not a magic formula somebody chose; it falls out of
information theory in about four lines, and you will see those four lines.

*Part VI --- Computation, Geometry, and Learning.* Floating point and
numerical stability, root-finding and quadrature, optimization, the geometry
of graphics and simulation, and then a complete from-scratch derivation of
backpropagation and of the mathematics inside a transformer.

The appendices contain worked solutions to every exercise, a curated list of
free and openly-licensed mathematics books, a notation reference, and a study
plan that puts the whole thing in order.

== How to actually use it

#intuition(title: "reading mathematics is not reading")[
  Prose is designed to be read at a steady speed. Mathematics is not. A single
  line can take twenty minutes and that is normal, not a failure. The correct
  reading speed for a definition is *slow enough to construct an example of it
  and an example of something that just fails it.* If you cannot do both, you
  have not read it yet.
]

Concretely:

+ *Read the intuition box, then look away and say it back.* If you cannot, read
  it again. This costs thirty seconds and saves an hour.

+ *When you meet a definition, build two things immediately:* one object that
  satisfies it, and one that nearly does but does not. The near-miss is where
  the understanding lives. A definition without a near-miss is a definition you
  have memorised, not understood.

+ *Read proofs twice.* First pass, ask only: is each step true? Second pass,
  ask: why would anyone have thought of this? The second question is the one
  that transfers to problems you have not seen.

+ *Do the exercises.* This is not a moral instruction, it is a mechanical one.
  Mathematics is a motor skill in a way that reading obscures. The solutions in
  Appendix A are fully worked, but a solution read before a genuine attempt
  teaches you close to nothing --- you get the pleasant feeling of
  understanding without acquiring any of it. Give each problem a real fifteen
  minutes first.

+ *Skipping is allowed; going backwards is mandatory.* If Part III is hard
  going, the fault is almost always in Part I. Go back. That is not a defeat,
  it is the only debugging technique that works here.

== On the proofs

A proof is not a ritual and it is not there to convince a grader. A proof is
the only technology anybody has ever found for being *sure*.

You already believe this, in a different vocabulary. You do not trust a
function because you ran it once; you trust it because you can argue about
what it does on every input --- the invariant holds on entry, the loop body
preserves it, therefore it holds on exit. That is a proof. You have been
writing them for years without the notation.

What this book adds is the notation, the standard moves (contradiction,
contraposition, construction, pigeonhole, induction in its stronger forms), and
the habit of noticing which move a situation is asking for.

#warning(title: "the two failure modes")[
  Beginners fail in exactly two ways, and they are opposites.

  The first is *hand-waving*: writing something that sounds like an argument
  but has a hole where the hard part should be. The word "clearly" is where
  this usually hides.

  The second is *ritual*: writing symbols in the shapes that proofs tend to
  have, without any of them meaning anything. This one is more common among
  people who have been graded a lot.

  The cure for both is the same. After every line, ask: *what exactly am I now
  entitled to assume, and what am I still trying to establish?* If you cannot
  answer both, stop and fix it before writing the next line.
]

== A note on notation

Mathematical notation is a terrible user interface with a very good excuse: it
was optimised for writing by hand, at speed, by people who already know what it
means. Much of what makes a page look impenetrable is not depth, it is
compression.

This book introduces every symbol at the moment it is first needed and never
before, and Appendix C collects all of them in one table you can keep open.
When something looks unreadable the problem is nearly always that one symbol is
unfamiliar --- not that the idea is hard. Look it up and try the line again.

== The honest promise

Working through this book will not make you a mathematician. It will make you
someone who can open a machine learning paper, a graphics textbook, or an
algorithms monograph and *read it* --- slowly, with effort, but without
bouncing off. It will make the mathematics in your own work visible to you
instead of invisible.

That is a real change and it does not take a decade. It takes a few hundred
hours of the specific kind of attention described above.

Start at the beginning. The beginning is genuinely the beginning.
