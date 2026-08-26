#import "../lib.typ": *

= A Study Plan

== The dependency graph

Not everything depends on everything. Here is what actually needs what, so you
can skip intelligently rather than randomly.

#align(center)[
  #table(
    columns: (auto, 1fr), inset: 7pt, stroke: 0.4pt + luma(180), align: (left, left),
    table.header([*To read*], [*You genuinely need*]),
    [Part I (1--7)], [Nothing. This is the floor.],
    [Part II (8--12)], [Chapter 7 (proof), and Chapter 2 for Chapter 11.],
    [Part III (13--18)], [Chapters 1--5 solidly. Chapter 7 to follow the proofs.],
    [Part IV (19--26)], [Chapters 1--3. Chapter 5--6 for the geometry. Chapter 18 for Chapter 26 only.],
    [Part V (27--32)], [Chapter 9 (counting), Chapter 16 (integration), Chapter 4 (logs).],
    [Ch. 33 (numerical)], [Chapters 1, 14, 16, 21, 25.],
    [Ch. 34 (optimization)], [Chapters 15, 18, 23, 26.],
    [Ch. 35 (geometry)], [Chapters 5, 6, 19, 20, 22.],
    [Ch. 36 (backprop)], [Chapters 14, 18, 20, 26, 32, 34. This is the convergence point of the whole book.],
  )
]

Two things worth noting from that table. *Part IV does not depend on Part
III*, apart from Chapter 26 --- you can do linear algebra before calculus, and
many people find it easier. And *Chapter 7 is a prerequisite for everything*;
if you skip it you will be able to follow computations and not arguments.

== Four routes

Pick the one matching why you are here. Each assumes a few hours a week.

=== Route A --- "I want to read ML papers" (about 6 months)

The shortest path to the stated goal, skipping what does not serve it.

+ *Weeks 1--4.* Chapters 1--4. Foundations, and get logarithms genuinely
  automatic --- they are everywhere in ML.
+ *Weeks 5--6.* Chapter 7. Do not skip it. You will not be *writing* proofs,
  but every paper's appendix is one.
+ *Weeks 7--14.* Part IV, Chapters 19--26. This is the core. Spend the most
  time here. Chapter 26 is the notation papers are written in.
+ *Weeks 15--20.* Chapters 13--18. Calculus, aiming at the gradient. You can
  be lighter on Chapter 16 (integration techniques) than the others.
+ *Weeks 21--24.* Chapters 27--32. Probability through information theory.
  Chapter 32 explains your loss function.
+ *Weeks 25--26.* Chapters 34 and 36. Optimization and backpropagation.

*Skippable for this route:* Chapters 10 and 12, most of Chapter 16's
techniques, Chapter 35.

=== Route B --- "I want general mathematical maturity" (about 12 months)

Read it in order. All of it. Do every exercise.

The difference from Route A is not the content, it is the *depth*: for
maturity, the proofs are the point and the applications are the decoration.
Read every proof twice per the preface's instruction, and after each chapter,
close the book and try to reconstruct the two or three central arguments from
memory.

Add *Hammack's Book of Proof* (Appendix B) alongside Part I, and do its
exercises too. Proof is a motor skill and this book does not have enough
repetitions in it by itself.

=== Route C --- "I want to reason rigorously about my own code" (about 4 months)

+ *Weeks 1--3.* Chapters 1--2, then Chapter 7 in full.
+ *Weeks 4--10.* Part II entire: Chapters 8--12. This is your part. Sets,
  counting, graphs, recurrences, number theory.
+ *Weeks 11--14.* Chapters 27--30. Probability through the limit theorems ---
  enough to reason about randomised algorithms, hash collisions, load
  balancing, and A/B tests.
+ *Weeks 15--16.* Chapters 1 and 33 together. Floating point and conditioning.

*Skippable for this route:* most of Part III and Part IV, though Chapters 19
and 20 are worth an afternoon regardless.

=== Route D --- "I want graphics, geometry, and simulation" (about 6 months)

+ *Weeks 1--6.* Chapters 1--6. Trigonometry and complex numbers are load
  bearing here in a way they are not for the other routes.
+ *Weeks 7--16.* Part IV, Chapters 19--25. Transformations, determinants,
  eigenvalues.
+ *Weeks 17--22.* Chapters 13--18. Calculus, with real attention to Chapter
  18 (vector calculus, multiple integrals).
+ *Weeks 23--26.* Chapters 33 and 35. Numerical stability and the geometry
  chapter.

== How to study, mechanically

The instructions from the preface, restated as a procedure you can follow
without thinking about it.

#algo(title: "Working through one chapter")[
```
1. Read the intuition boxes only.  Ten minutes.  Get the shape.
2. Read the chapter properly, slowly.  For each definition:
     - construct one example that satisfies it
     - construct one near-miss that does not
   If you cannot do both, reread.
3. For each proof:
     - pass 1: is every step true?
     - pass 2: why would anyone have thought of this?
4. Close the book.  Write down, from memory:
     - the two or three main results
     - what each is for
   Compare with the chapter.  The gaps are what you actually missed.
5. Do the exercises.  Fifteen real minutes each before looking.
6. Check against Appendix A.  For anything you got wrong, find the
   specific sentence in the chapter you failed to use.
```
]

Step 4 is the one people skip and the one that does the work. Recall is what
builds memory; rereading builds only the feeling of familiarity, which is
worse than useless because it is indistinguishable from knowing.

== On pace and on getting stuck

*A chapter a week is a good pace.* Faster than that and it will not stick.
Much slower and you will lose the thread between chapters.

*Twenty minutes a day beats three hours on Sunday.* The consolidation happens
between sessions, not during them. This is not motivational advice, it is how
memory works.

*When you are stuck, the problem is upstream.* Nine times out of ten,
confusion in Chapter 23 is an unresolved gap in Chapter 20. Go back. Every
time you go back you will find the gap was real.

*Being stuck for twenty minutes is normal and productive.* Being stuck for two
hours is not; at that point you are missing a prerequisite, not thinking
insufficiently hard. Identify what you would need to know, go and learn that,
come back.

*Write things down by hand.* Not for any mystical reason: it is slow enough
to force you to actually process each symbol, and typing is not.

*Compute things.* You are a programmer. When a theorem says the eigenvalues of
a symmetric matrix are real, generate a hundred random symmetric matrices and
check. When Chapter 30 says the sample mean is approximately normal, simulate
it and plot the histogram. This is a form of understanding available to you
that is not available to most students, and it is worth using.

== What to do after

You will finish this book able to read most technical mathematics slowly. The
next step depends on where you want depth:

- *Analysis* (Lebl, then Rudin) if you want to actually understand why
  calculus works.
- *Linear algebra again, harder* (Axler, or Trefethen and Bau for the
  numerical side). Nobody learns linear algebra properly the first time.
- *Probability again, harder* (Blitzstein, then Durrett for measure-theoretic
  probability) if you go deep into statistics or stochastic processes.
- *Abstract algebra* (Judson's free *Abstract Algebra: Theory and
  Applications*) if the group and field remarks in Chapter 8 interested you.
  It is the right next step for cryptography and coding theory.
- *Convex optimization* (Boyd) if you do anything with fitting or resource
  allocation.
- *Information theory* (MacKay) if Chapter 32 was the best chapter.

All of those are free, and all of them are in Appendix B.

== A last word

The reason to learn this material is not that it makes you better at any
particular task, although it does. It is that a large amount of what currently
looks to you like magic --- why this optimiser works, why that estimate is
biased, why the numbers went wrong at scale --- turns out to be a small number
of ideas applied repeatedly.

There are fewer ideas in mathematics than there appear to be. The dot product
turns up as similarity, as projection, as correlation, and as covariance. The
chain rule turns up as sensitivity, as backpropagation, and as change of
variables. Orthogonality turns up as independence, as uncorrelatedness, and as
the optimality condition for every least-squares problem in existence.

Once you have seen an idea in four costumes you stop being surprised by the
fifth. That is what mathematical maturity actually is, and it is entirely
achievable in a couple of years of unhurried work.
