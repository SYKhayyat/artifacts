#import "../lib.typ": *

// Book tables read better ragged-right and unhyphenated.
#show table: set par(justify: false)
#show table: set text(hyphenate: false)

= A Library of Free Mathematics Books

== How this list is organised and what the labels mean

Everything here is legally free to read. That covers two different things and
the distinction matters if you want to redistribute, remix, or print:

#align(center)[
  #table(
    columns: 2, inset: 7pt, stroke: 0.4pt + luma(180), align: (left, left),
    table.header([*Label*], [*Meaning*]),
    [*OPEN*], [Released under an open licence (Creative Commons, GFDL, or public domain). Free to copy, print, and often to modify.],
    [*FREE*], [The author or publisher provides it at no cost, but the copyright is conventional. Read it, do not redistribute it.],
    [*BUY*], [Not free. Listed because it is the best book on its subject and you should know it exists.],
  )
]

#warning(title: "verify before you rely on a link")[
  URLs move and licences change. Everything below was accurate as far as I
  know, but I have not re-checked each one. If a link is dead, search the
  title and the author's name --- these are all well-known works and are
  usually one search away, frequently mirrored on the author's university
  page.

  Where a book is hosted on an author's personal or departmental page, that
  page is the canonical source. Prefer it to any aggregator.
]

A note on how to use a list like this: *do not collect books.* Pick one per
subject, work through it, and only then look at a second. The failure mode of
having a good list is treating acquisition as progress.

== Proof and mathematical maturity

Start here if Chapter 7 was the hardest part of this book. These are the
gentlest genuine on-ramps to proof that exist.

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Book of Proof* --- Richard Hammack], [The best free introduction to proof, full stop. Logic, sets, induction, relations, functions, cardinality. Clear, patient, well-exercised. Start here.], [OPEN],
    [*Mathematical Reasoning: Writing and Proof* --- Ted Sundstrom], [Similar territory, more emphasis on the *writing* of proofs. Good second opinion if Hammack does not land.], [OPEN],
    [*An Infinite Descent into Pure Mathematics* --- Clive Newstead], [More ambitious: proof plus a tour of number theory, combinatorics, and analysis. Good if you want momentum.], [OPEN],
    [*Mathematics for Computer Science* --- Lehman, Leighton, Meyer], [The MIT 6.042 text. Proof, induction, number theory, graphs, counting, probability, all aimed squarely at computer scientists. Enormous and excellent. Arguably the single best companion to this book.], [OPEN],
  )
]

== Foundations: algebra, precalculus, trigonometry

If Part I moved too fast, these fill in at a slower pace with far more
practice problems.

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*OpenStax Algebra and Trigonometry*], [Professionally produced, thorough, enormous exercise sets with answers. Unexciting and completely reliable.], [OPEN],
    [*OpenStax Precalculus*], [The same, aimed at the transition into calculus.], [OPEN],
    [*Precalculus* --- Stitz and Zeager], [A well-regarded free alternative with a slightly drier, more rigorous tone.], [OPEN],
    [*Khan Academy*], [Not a book, but the best resource in existence for drilling a specific gap. Use it surgically: identify the thing you cannot do, drill that, return.], [FREE],
  )
]

== Calculus

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*OpenStax Calculus, Volumes 1--3*], [Complete single- and multivariable calculus. Volume 1: limits and derivatives. Volume 2: integration and series. Volume 3: multivariable. Solid, conventional, thousands of exercises.], [OPEN],
    [*Active Calculus* --- Matt Boelkins], [Built around you doing the work rather than reading worked examples. Genuinely different pedagogy, and it suits a self-learner who has time.], [OPEN],
    [*APEX Calculus* --- Hartman et al.], [Clean, well-illustrated, good on the geometric side.], [OPEN],
    [*Calculus* --- Gilbert Strang], [Strang's own calculus text, free from MIT and OpenStax. Idiosyncratic, opinionated, full of insight about *why*. Best as a second read.], [OPEN],
    [*Paul's Online Math Notes* --- Paul Dawkins], [Not a textbook: a reference. When you need to remember how to do a specific integral at 2am, this is where you go. Complete worked examples for everything in calculus I--III and differential equations.], [FREE],
    [*MIT OCW 18.01, 18.02*], [Full lecture videos, problem sets, and exams with solutions.], [OPEN],
    [*Essence of Calculus* --- 3Blue1Brown], [Twelve videos. Will not teach you to compute anything, will completely rewire how you see the subject. Watch before or alongside a real text, never instead of one.], [FREE],
  )
]

== Real analysis

The rigorous version of calculus --- where the $epsilon$-$delta$ arguments of
Chapter 13 get taken seriously. Optional for most programmers; essential if
you want to read theory papers.

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Basic Analysis* --- Jiří Lebl], [Two volumes, free, well-paced, widely used as a course text. The most approachable free option.], [OPEN],
    [*Introduction to Real Analysis* --- William Trench], [More traditional and more demanding. Complete and careful.], [OPEN],
    [*Mathematical Analysis I* --- Elias Zakon], [Free from the Trillia Group. Terse, thorough, old-school.], [OPEN],
    [*Principles of Mathematical Analysis* --- Walter Rudin], ["Baby Rudin". The canonical text, famously austere. Not a first book, and not for everyone --- but if you can work through it, you can read anything.], [BUY],
  )
]

== Linear algebra

The most important part of this book, and correspondingly well served.

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Introduction to Applied Linear Algebra (VMLS)* --- Boyd and Vandenberghe], [Free PDF from Stanford. Written for exactly this audience: applications-first, no determinants until late, everything motivated by data fitting and least squares. Companion Julia and Python material. If you read one, read this.], [FREE],
    [*Linear Algebra Done Wrong* --- Sergei Treil], [The title is a joke about Axler's *Linear Algebra Done Right*. Rigorous, coordinate-light, free. Excellent second book.], [FREE],
    [*A First Course in Linear Algebra* --- Rob Beezer], [Very complete, very free, with an unusual emphasis on getting every proof written out.], [OPEN],
    [*Linear Algebra* --- Jim Hefferon], [Free, with a full solutions manual --- rare and valuable for self-study.], [OPEN],
    [*MIT 18.06* --- Gilbert Strang], [The famous course. Video lectures, problem sets, exams. Strang's four-fundamental-subspaces framing is the one used in Chapter 24 of this book. The accompanying textbook is BUY, the course is free.], [FREE],
    [*Essence of Linear Algebra* --- 3Blue1Brown], [Fifteen short videos that make the geometric content of Part IV visible. The single highest-value hour of video on this list.], [FREE],
    [*Immersive Linear Algebra* --- Ström, Åström, Akenine-Möller], [A linear algebra book with fully interactive figures. Worth an afternoon for the visualisations alone.], [FREE],
    [*The Matrix Cookbook* --- Petersen and Pedersen], [Not a textbook: a 70-page reference of matrix identities and derivatives. Keep it open when reading ML papers. Chapter 26 of this book is a curated subset.], [FREE],
    [*Numerical Linear Algebra* --- Trefethen and Bau], [The best book on how linear algebra behaves on actual computers. Twenty-page "lectures", beautifully written. If Chapter 33 interested you, this is the follow-up.], [BUY],
  )
]

== Discrete mathematics and combinatorics

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Discrete Mathematics: An Open Introduction* --- Oscar Levin], [Friendly, well-scoped, good exercises. The standard free choice.], [OPEN],
    [*Mathematics for Computer Science* --- Lehman, Leighton, Meyer], [Listed above and worth listing twice. The definitive free discrete text for programmers.], [OPEN],
    [*Applied Combinatorics* --- Keller and Trotter], [Deeper on counting, generating functions, and graph theory.], [OPEN],
    [*generatingfunctionology* --- Herbert Wilf], [Free from the author. The book on generating functions --- the technique gestured at in Chapter 17. Short, witty, brilliant.], [FREE],
    [*A = B* --- Petkovšek, Wilf, Zeilberger], [Free. How to make a computer prove combinatorial identities. Delightful, and genuinely useful if you ever need one proved.], [FREE],
    [*Concrete Mathematics* --- Graham, Knuth, Patashnik], [Not free. The best book on the mathematics of algorithm analysis, written partly by Knuth for exactly that purpose. Sums, recurrences, generating functions, asymptotics. Buy it eventually.], [BUY],
  )
]

== Number theory and cryptography

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*A Computational Introduction to Number Theory and Algebra* --- Victor Shoup], [Free from the author. Rigorous, algorithm-centred, and the right book if you want to actually implement cryptographic primitives.], [FREE],
    [*Elementary Number Theory: Primes, Congruences, and Secrets* --- William Stein], [Free, computational, uses Sage throughout.], [FREE],
    [*An Introductory Course in Elementary Number Theory* --- Wissam Raji], [Shorter and gentler than the above.], [OPEN],
    [*A Graduate Course in Applied Cryptography* --- Boneh and Shoup], [Free draft. The modern reference on the cryptography side. Demanding.], [FREE],
  )
]

== Probability and statistics

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Introduction to Probability* --- Grinstead and Snell], [Free, classic, thorough. Released by the AMS under an open licence. A safe default.], [OPEN],
    [*Introduction to Probability, Statistics, and Random Processes* --- Hossein Pishro-Nik], [Free online with an excellent set of worked solutions and interactive tools. Covers more ground than Grinstead and Snell.], [FREE],
    [*Harvard Stat 110* --- Joe Blitzstein], [Free lecture videos, problem sets, and a superb "cheat sheet". Blitzstein is one of the best probability teachers alive. The accompanying book (*Introduction to Probability*) is BUY and is worth it.], [FREE],
    [*Think Stats* and *Think Bayes* --- Allen Downey], [Free, CC-licensed, Python-first. Statistics taught by writing code rather than by manipulating formulas. Excellent for a programmer, and a useful counterweight to formula-heavy treatments.], [OPEN],
    [*Seeing Theory* --- Brown University], [Interactive visual introduction to probability. Half an hour well spent before reading anything else.], [FREE],
    [*All of Statistics* --- Larry Wasserman], [Not free. A fast, dense survey for people who want the whole subject in one volume and can handle the pace.], [BUY],
    [*Statistical Rethinking* --- Richard McElreath], [Not free, but the lecture series is on YouTube and is outstanding. The best introduction to Bayesian thinking for people who learn by doing.], [BUY],
  )
]

== Information theory

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Information Theory, Inference, and Learning Algorithms* --- David MacKay], [Free PDF, legally, from the author's page. One of the great textbooks of the last thirty years: information theory, Bayesian inference, coding theory, and neural networks in one coherent story. Idiosyncratic and wonderful. If Chapter 32 caught your interest, read this.], [FREE],
    [*Elements of Information Theory* --- Cover and Thomas], [The standard reference. Not free.], [BUY],
  )
]

== Numerical computing

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Fundamentals of Numerical Computation* --- Driscoll and Braun], [Free online (fncbook). Modern, Julia-based, covers everything in Chapter 33 properly.], [FREE],
    [*What Every Computer Scientist Should Know About Floating-Point Arithmetic* --- David Goldberg], [Free, 70 pages, and the title is not an exaggeration. Read it once properly.], [FREE],
    [*Numerical Recipes* --- Press et al.], [Older editions readable free online. Encyclopaedic and opinionated; the code is dated and the explanations are still good.], [FREE],
    [*Accuracy and Stability of Numerical Algorithms* --- Nicholas Higham], [Not free. The definitive treatment of the conditioning-versus-stability distinction of Chapter 33.], [BUY],
  )
]

== Optimization

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Convex Optimization* --- Boyd and Vandenberghe], [Free PDF from Stanford, and the canonical text. Chapter 34 is a compressed sketch of its first half. The accompanying EE364a lectures are also free.], [FREE],
    [*Algorithms for Decision Making* --- Kochenderfer, Wheeler, Wray], [Free from MIT Press. Decision theory, MDPs, and planning under uncertainty. Well written, Julia-based.], [OPEN],
    [*Numerical Optimization* --- Nocedal and Wright], [Not free. The reference for what optimisation solvers actually do.], [BUY],
  )
]

== Mathematics specifically for machine learning

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Mathematics for Machine Learning* --- Deisenroth, Faisal, Ong], [Free PDF. The closest published book to what this one is trying to do, aimed slightly higher. Linear algebra, analytic geometry, matrix decompositions, vector calculus, probability, optimisation, then four ML applications. Read it after this book.], [FREE],
    [*Probabilistic Machine Learning: An Introduction* and *Advanced Topics* --- Kevin Murphy], [Free draft PDFs. Enormous, current, and the best single reference on the probabilistic view of ML.], [FREE],
    [*An Introduction to Statistical Learning* --- James, Witten, Hastie, Tibshirani], [Free PDF. The gentlest good introduction to statistical learning, with R and Python editions.], [FREE],
    [*The Elements of Statistical Learning* --- Hastie, Tibshirani, Friedman], [Free PDF. The harder, deeper sibling of the above. A classic.], [FREE],
    [*Understanding Deep Learning* --- Simon Prince], [Free PDF from MIT Press. Current, unusually clear, excellent figures. The best modern deep learning text.], [FREE],
    [*Dive into Deep Learning* --- Zhang, Lipton, Li, Smola], [Free, interactive, runnable. Every concept comes with working code in multiple frameworks.], [OPEN],
    [*Deep Learning* --- Goodfellow, Bengio, Courville], [Free HTML. Now somewhat dated on architectures, and Part I remains a good compact treatment of the mathematical background.], [FREE],
  )
]

== Graphics, geometry, and simulation

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Title*], [*Why*], [*Lic.*]),
    [*Physically Based Rendering* --- Pharr, Jakob, Humphreys], [Free online. A complete renderer explained line by line, with the mathematics done properly. Won an Academy Award, which is not a sentence you write about many textbooks.], [FREE],
    [*Ray Tracing in One Weekend* --- Peter Shirley], [Free three-book series. The fastest possible path from nothing to a working ray tracer. Start here if graphics interests you at all.], [OPEN],
    [*Scratchapixel*], [Free online course covering the mathematics of rendering from scratch. Uneven but often exactly what you need.], [FREE],
    [*3D Math Primer for Graphics and Game Development* --- Dunn and Parberry], [Not free. The friendliest treatment of quaternions and 3D transforms.], [BUY],
  )
]

== Reference and tools

#align(center)[
  #table(
    columns: (10em, 1fr, 4.2em), inset: 6pt, stroke: 0.4pt + luma(180), align: (left, left, center),
    table.header([*Resource*], [*Why*], [*Lic.*]),
    [*The Matrix Cookbook*], [Matrix identities and derivatives. Keep it open.], [FREE],
    [*OEIS* --- Online Encyclopedia of Integer Sequences], [Type in the first six terms of a sequence you found; it tells you what it is, with formulas and references. Astonishingly useful.], [FREE],
    [*SymPy*], [Python computer algebra. Check your symbolic work, expand messy expressions, compute derivatives you do not trust yourself with.], [OPEN],
    [*Wolfram Alpha*], [Fast checking for integrals, series, and equations. Free tier shows answers without steps.], [FREE],
    [*Desmos* and *GeoGebra*], [Instant graphing. Plot the function before reasoning about it --- half of Chapter 15 is easier with a picture.], [FREE],
    [*Math Stack Exchange*], [The archive is the value, not asking. Almost every confusion you will have has been asked and answered well.], [FREE],
  )
]

== A suggested route through the list

If you want a single path rather than a menu:

+ *Hammack, Book of Proof.* Cover to cover, doing the exercises. This is the
  highest-leverage thing on the list.
+ *Boyd and Vandenberghe, VMLS.* Linear algebra as you will actually use it.
+ *OpenStax Calculus Volume 1*, plus 3Blue1Brown's *Essence of Calculus*
  alongside it.
+ *Lehman, Leighton and Meyer, Mathematics for Computer Science.* Discrete
  mathematics and a great deal of proof practice.
+ *Blitzstein, Stat 110.* Probability, properly.
+ *Deisenroth, Faisal and Ong, Mathematics for Machine Learning.* The
  consolidation pass.
+ Then specialise: MacKay for information theory, Boyd for optimisation,
  Trefethen and Bau for numerical linear algebra, Prince for deep learning.

That is perhaps two years of part-time work, and it is a genuine
undergraduate mathematics education for a working programmer. Nothing on it
costs money.
