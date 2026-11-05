// ============================================================
//  lib.typ -- shared styling and environments
//  Thinking in Common Lisp
// ============================================================

#let accent      = rgb("#1f4e79")
#let accent-soft = rgb("#e8f0f7")
#let warm        = rgb("#8a4b08")
#let warm-soft   = rgb("#fdf1e3")
#let green       = rgb("#1e6f3c")
#let green-soft  = rgb("#e9f5ed")
#let grey-soft   = rgb("#f4f4f5")
#let red         = rgb("#8b1a1a")
#let red-soft    = rgb("#fbeaea")
#let code-bg     = rgb("#f7f7f8")

// ---------- counters -------------------------------------------------

#let ex-counter  = counter("exercise")

// Reset the shared numbering at every chapter (level-1 heading).
// (Headings carry their own counter; this one numbers exercises that
// arrive without a label of their own.)
#let reset-counters = {
  ex-counter.update(0)
}

// ---------- generic titled block -------------------------------------

#let admon(
  kind,
  title,
  body,
  fill: grey-soft,
  stroke-col: luma(160),
  label-col: black,
) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 3pt,
  fill: fill,
  stroke: (left: 2.5pt + stroke-col),
  breakable: true,
  {
    set text(size: 10pt)
    let head = {
      kind
      if title != none and title != "" { [ (#title)] }
      [.]
    }
    block(spacing: 6pt, text(weight: "bold", fill: label-col, head))
    body
  },
)

// ---------- the environments -----------------------------------------

#let definition(title: "", body) = admon(
  "Definition", title, body,
  fill: accent-soft, stroke-col: accent, label-col: accent,
)

#let example(title: "", body) = admon(
  "Example", title, body,
  fill: grey-soft, stroke-col: luma(140), label-col: luma(60),
)

// A short "how to think about this" aside.
#let intuition(title: "", body) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 3pt,
  fill: green-soft,
  stroke: (left: 2.5pt + green),
  breakable: true,
  {
    set text(size: 10pt)
    block(spacing: 6pt)[
      #text(weight: "bold", fill: green, { [The idea]; if title != "" { [: #title] }; [.] })
    ]
    body
  },
)

#let warning(title: "", body) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 3pt,
  fill: red-soft,
  stroke: (left: 2.5pt + red),
  breakable: true,
  {
    set text(size: 10pt)
    block(spacing: 6pt)[
      #text(weight: "bold", fill: red, { [Trap]; if title != "" { [: #title] }; [.] })
    ]
    body
  },
)

#let aside(title: "", body) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 3pt,
  fill: warm-soft,
  stroke: (left: 2.5pt + warm),
  breakable: true,
  {
    set text(size: 10pt)
    block(spacing: 6pt, text(weight: "bold", fill: warm, [#title.]))
    body
  },
)

// ---------- exercises -------------------------------------------------
//
// The book numbers its own exercises (<chapter>.<n>) and Appendix D
// refers back to those numbers, so the label is carried through
// verbatim rather than generated.

#let exercise(label, project: false, body) = block(
  width: 100%,
  spacing: 10pt,
  breakable: true,
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 8pt,
    text(weight: "bold", fill: accent)[
      #label
      #if project [ #text(weight: "regular", size: 9pt, fill: luma(110))[project]]
    ],
    body,
  )
]

// Used inside the answers appendix.
#let soln(label, body) = block(width: 100%, spacing: 11pt, breakable: true)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 8pt,
    text(weight: "bold", fill: accent)[#label],
    body,
  )
]

// ---------- part divider ---------------------------------------------

#let part(num, title) = {
  pagebreak(to: "odd", weak: true)
  set page(numbering: none, header: none)
  v(3.1in)
  align(center)[
    #text(size: 12pt, tracking: 3pt, fill: luma(120))[PART #num]
    #v(10pt)
    #text(size: 26pt, weight: "bold", fill: accent)[#title]
  ]
  pagebreak(weak: true)
}

// The prose that introduces a part, set apart from the chapters.
#let part-intro(body) = block(
  width: 100%,
  inset: (x: 14pt, y: 10pt),
  stroke: (left: 2pt + luma(200)),
  breakable: true,
)[
  #set text(size: 10.5pt, fill: luma(55))
  #set par(justify: true)
  #body
]

// ---------- code ------------------------------------------------------

// Fenced blocks carry the language tag; the tag is dropped on the page
// but keeps the source readable.
#let codeblock(lang: none, body) = block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 2pt,
  fill: code-bg,
  stroke: 0.4pt + luma(205),
  breakable: true,
  body,
)
