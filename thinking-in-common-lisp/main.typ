#import "lib.typ": *

// ============================================================
//  Thinking in Common Lisp
//  Generated from lisp.org by .edit-work/org2typst.py
// ============================================================

#set document(
  title: "Thinking in Common Lisp",
  author: "Written for Shaul Khayyat",
)

#set page(
  paper: "us-letter",
  margin: (x: 1.15in, y: 1.05in),
  numbering: "1",
  number-align: center,
)

#set text(
  font: ("New Computer Modern", "Libertinus Serif"),
  size: 10.5pt,
  lang: "en",
)

#set par(justify: true, leading: 0.68em, spacing: 1.05em, first-line-indent: 0em)

#set heading(numbering: none)

// Chapters are labelled CHAPTER, the appendices APPENDIX.
#let section-word = state("section-word", "CHAPTER")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  reset-counters
  block(above: 0pt, below: 20pt)[
    #set text(size: 20pt, weight: "bold", fill: accent)
    #if it.numbering != none [
      #context text(size: 13pt, fill: luma(120))[#section-word.get() #counter(heading).display()]
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

#show heading.where(level: 4): it => block(above: 12pt, below: 6pt)[
  #set text(size: 10.5pt, weight: "bold")
  #it
]

#show link: set text(fill: rgb("#0b4f9c"))

// Code: monospace, a shade smaller, on a tinted panel.
#show raw: set text(font: ("DejaVu Sans Mono", "Libertinus Mono"), size: 8.4pt)
#show raw.where(lang: "lisp-s"): set text(size: 7.2pt)
#show raw.where(lang: "text-s"): set text(size: 7.2pt)
#show raw.where(block: true): it => block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 2pt,
  fill: rgb("#f7f7f8"),
  stroke: 0.4pt + luma(205),
  it,
)

// ---------------- title page ----------------

#page(numbering: none, header: none)[
  #v(1.6in)
  #align(center)[
    #text(size: 15pt, tracking: 2pt, fill: luma(110))[A HAND-HELD GUIDE AND REFERENCE]
    #v(10pt)
    #text(size: 34pt, weight: "bold", fill: accent)[Thinking in Common Lisp]
    #v(20pt)
    #line(length: 45%, stroke: 0.8pt + luma(160))
    #v(20pt)
    #block(width: 74%)[
      #set par(justify: false)
      #set text(size: 11.5pt, fill: luma(60))
      From the REPL to a shipped executable: expressions, lists, functions,
      recursion, macros, conditions, CLOS and packages, then interop,
      generators, testing and a program you build one chapter at a time.
      Every example is code you run as you read it.
    ]
    #v(40pt)
    #text(size: 10.5pt, fill: luma(90))[No forward references. Nothing skipped.]
  ]
  #v(1fr)
  #align(center)[#text(size: 9.5pt, fill: luma(130))[Prepared for Shaul Khayyat #sym.dot.c August 2026]]
]

// ---------------- contents ----------------

#page(numbering: none, header: none)[
  #text(size: 18pt, weight: "bold", fill: accent)[Contents]
  #v(12pt)
  #outline(depth: 1, indent: 1.2em, title: none)
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
      align(left)[Thinking in Common Lisp],
      align(right)[#earlier.last().body],
    )
    v(-6pt)
    line(length: 100%, stroke: 0.4pt + luma(200))
  }
})

#include "chapters/00-front.typ"

#set heading(numbering: "1.")
#counter(heading).update(0)

#include "parts/part-1.typ"
#include "chapters/01-the-repl-and-the-edit-evaluate-loop.typ"
#include "chapters/02-expressions-atoms-and-lists.typ"
#include "chapters/03-numbers-characters-strings-and-symbols.typ"
#include "chapters/04-variables.typ"
#include "chapters/05-functions.typ"
#include "chapters/06-conditionals.typ"
#include "parts/part-1-review.typ"
#include "parts/part-2.typ"
#include "chapters/07-cons-cells-and-list-structure.typ"
#include "chapters/08-recursion.typ"
#include "chapters/09-functions-as-values.typ"
#include "chapters/10-working-with-sequences.typ"
#include "parts/part-2-review.typ"
#include "parts/part-3.typ"
#include "chapters/11-loops.typ"
#include "chapters/12-format.typ"
#include "chapters/13-structures-hash-tables-and-arrays.typ"
#include "chapters/14-macros.typ"
#include "chapters/15-conditions-and-the-debugger.typ"
#include "chapters/16-packages-files-and-asdf.typ"
#include "parts/part-3-review.typ"
#include "parts/part-4.typ"
#include "chapters/17-lexical-and-dynamic-variables.typ"
#include "chapters/18-the-reader.typ"
#include "chapters/19-conditions-ii-handler-bind-and-the-condition-hierarchy.typ"
#include "chapters/20-compilation-loading-and-eval-when.typ"
#include "chapters/21-type-declarations-and-performance.typ"
#include "chapters/22-the-repl-and-debugging-workflow.typ"
#include "chapters/23-symbols-and-the-property-list.typ"
#include "chapters/24-multiple-values.typ"
#include "chapters/25-closures-as-objects.typ"
#include "chapters/26-clos.typ"
#include "chapters/27-clos-deep-dive.typ"
#include "chapters/28-packages-and-symbols-internals.typ"
#include "parts/part-4-review.typ"
#include "parts/part-5.typ"
#include "chapters/29-interoperability.typ"
#include "chapters/30-iterators-and-generators.typ"
#include "chapters/31-reading-other-people-s-lisp.typ"
#include "chapters/32-building-executables.typ"
#include "chapters/33-testing.typ"
#include "chapters/34-the-bigger-picture.typ"
#include "parts/part-5-review.typ"
#set heading(numbering: "A.")
#counter(heading).update(0)
#section-word.update("APPENDIX")

#include "chapters/A-installing-sbcl.typ"
#include "chapters/B-setting-up-emacs-for-common-lisp.typ"
#include "chapters/C-emacs-survival-guide.typ"
#include "chapters/D-answers-to-exercises.typ"
#include "chapters/E-the-game-s-redefinitions.typ"
#include "chapters/F-sbcl-error-messages.typ"
#include "chapters/G-the-complete-game.typ"
#include "chapters/H-glossary.typ"
#include "chapters/I-concept-index.typ"

#set heading(numbering: none)
#include "chapters/Z-colophon.typ"
