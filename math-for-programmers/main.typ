#import "lib.typ": *

// ============================================================
//  Mathematics for the Working Programmer
// ============================================================

#set document(
  title: "Mathematics for the Working Programmer",
  author: "Written for Shaul Khayyat",
)

#set page(
  paper: "us-letter",
  margin: (x: 1.15in, y: 1.05in),
  numbering: "1",
  number-align: center,
)

#set text(
  font: ("New Computer Modern", "Libertinus Serif", "Georgia"),
  size: 10.5pt,
  lang: "en",
)

#set par(justify: true, leading: 0.68em, spacing: 1.05em, first-line-indent: 0em)

#show raw: set text(font: ("DejaVu Sans Mono", "Consolas", "Courier New"), size: 9pt)

#set heading(numbering: none)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  reset-counters
  block(above: 0pt, below: 20pt)[
    #set text(size: 20pt, weight: "bold", fill: accent)
    #if it.numbering != none [
      #text(size: 13pt, fill: luma(120))[CHAPTER #counter(heading).display()]
      #linebreak()
    ]
    #it.body
  ]
}

#show heading.where(level: 2): it => block(above: 20pt, below: 9pt)[
  #set text(size: 13.5pt, weight: "bold", fill: accent)
  #it
]

#show heading.where(level: 3): it => block(above: 14pt, below: 7pt)[
  #set text(size: 11.5pt, weight: "bold", style: "italic")
  #it
]

#show link: set text(fill: rgb("#0b4f9c"))

// A part divider page.
#let part(num, title, blurb) = {
  pagebreak(to: "odd", weak: true)
  set page(numbering: none, header: none)
  v(3.2in)
  align(center)[
    #text(size: 12pt, tracking: 3pt, fill: luma(120))[PART #num]
    #v(10pt)
    #text(size: 26pt, weight: "bold", fill: accent)[#title]
    #v(16pt)
    #block(width: 78%)[
      #set text(size: 10.5pt, style: "italic", fill: luma(70))
      #set par(justify: false)
      #blurb
    ]
  ]
  pagebreak(weak: true)
}

// ---------------- title page ----------------

#page(numbering: none, header: none)[
  #v(1.6in)
  #align(center)[
    #text(size: 15pt, tracking: 2pt, fill: luma(110))[MATHEMATICS FOR THE]
    #v(6pt)
    #text(size: 34pt, weight: "bold", fill: accent)[Working Programmer]
    #v(20pt)
    #line(length: 45%, stroke: 0.8pt + luma(160))
    #v(20pt)
    #block(width: 74%)[
      #set par(justify: false)
      #set text(size: 11.5pt, fill: luma(60))
      A complete rebuild of the mathematics you were never properly taught ---
      from what a number is, through calculus, linear algebra, probability and
      statistics, to the derivation of backpropagation --- written for someone
      who already knows how to think precisely, because they write code.
    ]
    #v(40pt)
    #text(size: 10.5pt, fill: luma(90))[Intuition first. Proofs shown. Exercises worked.]
    #v(4pt)
    #text(size: 10.5pt, fill: luma(90))[No step skipped.]
  ]
  #v(1fr)
  #align(center)[#text(size: 9.5pt, fill: luma(130))[Prepared for Shaul Khayyat #sym.dot.c August 2026]]
]

// ---------------- contents ----------------

#page(numbering: none, header: none)[
  #text(size: 18pt, weight: "bold", fill: accent)[Contents]
  #v(12pt)
  #outline(depth: 2, indent: 1.2em, title: none)
]

#counter(page).update(1)
#set page(header: context {
  let cur = here().page()
  let all = query(heading.where(level: 1))
  let opens-here = all.filter(h => h.location().page() == cur)
  let earlier = all.filter(h => h.location().page() < cur)
  // No running head on a page that opens a chapter, or before the first one.
  if opens-here.len() == 0 and earlier.len() > 0 {
    set text(size: 8.5pt, fill: luma(130))
    grid(
      columns: (1fr, auto),
      align(left)[Mathematics for the Working Programmer],
      align(right)[#earlier.last().body],
    )
    v(-6pt)
    line(length: 100%, stroke: 0.4pt + luma(200))
  }
})

#include "chapters/00-preface.typ"

#set heading(numbering: "1.")
#counter(heading).update(0)

#part("I", "Rebuilding the Ground", [
  Everything below calculus, done properly this time. Numbers, algebra as a
  rewriting system, functions, exponentials, trigonometry, complex numbers ---
  and then the single most important skill in the book: how to read and write
  a proof.
])

#include "chapters/01-numbers.typ"
#include "chapters/02-algebra.typ"
#include "chapters/03-functions.typ"
#include "chapters/04-explog.typ"
#include "chapters/05-trig.typ"
#include "chapters/06-complex.typ"
#include "chapters/07-proofs.typ"

#part("II", "Discrete Mathematics", [
  The mathematics that is already secretly inside your code: sets and
  relations, counting, graphs, recurrences and asymptotics, and the number
  theory that runs every hash table and every key exchange.
])

#include "chapters/08-sets.typ"
#include "chapters/09-combinatorics.typ"
#include "chapters/10-graphs.typ"
#include "chapters/11-asymptotics.typ"
#include "chapters/12-numbertheory.typ"

#part("III", "Calculus", [
  What happens to a quantity when you nudge it. Limits, derivatives,
  integrals, infinite series, and then the same ideas in many variables ---
  which is where the gradient comes from, and therefore where all of machine
  learning comes from.
])

#include "chapters/13-limits.typ"
#include "chapters/14-derivatives.typ"
#include "chapters/15-applications.typ"
#include "chapters/16-integrals.typ"
#include "chapters/17-series.typ"
#include "chapters/18-multivariable.typ"

#part("IV", "Linear Algebra", [
  The most useful mathematics ever invented for a programmer. Vectors,
  matrices as functions, solving systems, determinants, eigenvalues,
  orthogonality and least squares, the singular value decomposition, and
  matrix calculus.
])

#include "chapters/19-vectors.typ"
#include "chapters/20-matrices.typ"
#include "chapters/21-solving.typ"
#include "chapters/22-determinants.typ"
#include "chapters/23-eigen.typ"
#include "chapters/24-orthogonality.typ"
#include "chapters/25-svd.typ"
#include "chapters/26-matrixcalc.typ"

#part("V", "Probability and Statistics", [
  Reasoning under uncertainty, from the axioms up: sample spaces, random
  variables, distributions, expectation, the limit theorems that make
  statistics possible, estimation and inference, and information theory.
])

#include "chapters/27-probability.typ"
#include "chapters/28-randomvars.typ"
#include "chapters/29-joint.typ"
#include "chapters/30-limittheorems.typ"
#include "chapters/31-inference.typ"
#include "chapters/32-information.typ"

#part("VI", "Computation, Geometry, and Learning", [
  Where the mathematics meets the machine. Floating point and numerical
  stability, root finding and quadrature, optimization, the geometry behind
  graphics and simulation, and finally a full derivation of backpropagation
  and the mathematics of a transformer.
])

#include "chapters/33-numerical.typ"
#include "chapters/34-optimization.typ"
#include "chapters/35-geometry.typ"
#include "chapters/36-backprop.typ"

#part("VII", "Appendices", [
  Worked solutions to every exercise, a curated library of free and
  open-licensed mathematics books, a notation reference, and a study plan
  that puts the whole thing in order.
])

#set heading(numbering: "A.1.")
#counter(heading).update(0)

#include "chapters/A-solutions.typ"
#include "chapters/B-books.typ"
#include "chapters/C-notation.typ"
#include "chapters/D-plan.typ"
