// ============================================================
//  lib.typ -- shared styling and environments
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

// ---------- counters -------------------------------------------------

#let thm-counter = counter("theorem")
#let ex-counter  = counter("exercise")

// Reset the shared numbering at every chapter (level-1 heading).
#let reset-counters = {
  thm-counter.update(0)
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
  numbered: true,
) = {
  block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 3pt,
    fill: fill,
    stroke: (left: 2.5pt + stroke-col),
    breakable: true,
    {
      if numbered {
        thm-counter.step()
      }
      set text(size: 10pt)
      let head = {
        kind
        if numbered {
          [ ]
          context {
            let c = counter(heading).get()
            let ch = if c.len() > 0 { c.at(0) } else { 0 }
            [#ch.#thm-counter.display()]
          }
        }
        if title != none and title != "" { [ (#title)] }
        [.]
      }
      block(spacing: 6pt, text(weight: "bold", fill: label-col, head))
      body
    },
  )
}

// ---------- the environments -----------------------------------------

#let definition(title: "", body) = admon(
  "Definition", title, body,
  fill: accent-soft, stroke-col: accent, label-col: accent,
)

#let theorem(title: "", body) = admon(
  "Theorem", title, body,
  fill: warm-soft, stroke-col: warm, label-col: warm,
)

#let lemma(title: "", body) = admon(
  "Lemma", title, body,
  fill: warm-soft, stroke-col: warm, label-col: warm,
)

#let proposition(title: "", body) = admon(
  "Proposition", title, body,
  fill: warm-soft, stroke-col: warm, label-col: warm,
)

#let corollary(title: "", body) = admon(
  "Corollary", title, body,
  fill: warm-soft, stroke-col: warm, label-col: warm,
)

#let example(title: "", body) = admon(
  "Example", title, body,
  fill: grey-soft, stroke-col: luma(140), label-col: luma(60),
)

// Proof: no number, no fill, just a rule and a tombstone.
#let proof(body) = block(
  width: 100%,
  inset: (left: 10pt, top: 4pt, bottom: 4pt),
  stroke: (left: 1pt + luma(190)),
  breakable: true,
  {
    set text(size: 10pt)
    [#text(style: "italic", weight: "medium")[Proof.] #h(3pt)]
    body
    h(1fr)
    box(width: 6pt, height: 6pt, fill: luma(30))
  },
)

// A short "here's the picture in your head" aside.
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
      #text(weight: "bold", fill: green, {[The idea]; if title != "" { [: #title] }; [.]})
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
      #text(weight: "bold", fill: red, {[Trap]; if title != "" { [: #title] }; [.]})
    ]
    body
  },
)

// ---------- exercises -------------------------------------------------
//
// Exercises are numbered <chapter>.<n> with their own counter, and the
// solutions appendix restates them, so the numbers must agree.

#let exercise(body) = {
  ex-counter.step()
  block(width: 100%, spacing: 9pt, breakable: true)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 7pt,
      text(weight: "bold", fill: accent)[
        #context {
          let c = counter(heading).get()
          let ch = if c.len() > 0 { c.at(0) } else { 0 }
          [#ch.#ex-counter.display()]
        }
      ],
      body,
    )
  ]
}

// Used inside the solutions appendix.
#let soln(num, body) = block(width: 100%, spacing: 11pt, breakable: true)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 7pt,
    text(weight: "bold", fill: accent)[#num],
    body,
  )
]

// ---------- pseudocode -------------------------------------------------

#let algo(title: "", body) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 3pt,
  fill: luma(248),
  stroke: 0.5pt + luma(190),
  breakable: true,
  {
    if title != "" {
      block(spacing: 7pt, text(weight: "bold", size: 10pt)[#title])
    }
    set text(size: 9pt)
    body
  },
)

// ---------- math shorthands used in the text ---------------------------
//
// Typst math mode resolves plain identifiers from the surrounding scope,
// so these can be written bare inside $...$ -- e.g. $Var(X)$, $argmin_x$.
// RR NN ZZ QQ CC are built in already.

#let EE     = math.bb("E")
#let PP     = math.bb("P")
#let Var    = math.op("Var")
#let Cov    = math.op("Cov")
#let Corr   = math.op("Corr")
#let tr     = math.op("tr")
#let rank   = math.op("rank")
#let nullity = math.op("nullity")
#let diag   = math.op("diag")
#let sgn    = math.op("sgn")
#let span   = math.op("span")
#let proj   = math.op("proj")
#let softmax = math.op("softmax")
#let relu   = math.op("ReLU")
#let KL     = math.op("KL")
#let Hent   = math.op("H")
#let Img    = math.op("Im")
#let Ker    = math.op("Ker")
#let argmin = math.op("arg min", limits: true)
#let argmax = math.op("arg max", limits: true)
#let Bern   = math.op("Bernoulli")
#let Bin    = math.op("Binomial")
#let Pois   = math.op("Poisson")
#let Unif   = math.op("Uniform")
#let Norml  = math.op("Normal")
