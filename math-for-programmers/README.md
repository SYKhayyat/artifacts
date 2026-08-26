# Mathematics for the Working Programmer

A ~375-page mathematics text written from zero assumed knowledge up to the
derivation of backpropagation.

**Read this:** `Mathematics-for-the-Working-Programmer.pdf`

## What's in it

| Part | Chapters | Contents |
|---|---|---|
| I | 1–7 | Numbers, algebra, functions, exp/log, trigonometry, complex numbers, **logic and proof** |
| II | 8–12 | Sets & relations, counting, graphs, recurrences & asymptotics, number theory |
| III | 13–18 | Limits, derivatives, applications, integration, series, multivariable calculus |
| IV | 19–26 | Vectors, matrices, linear systems, determinants, eigenvalues, orthogonality/least squares, SVD, matrix calculus |
| V | 27–32 | Probability, random variables, joint distributions, limit theorems, inference, information theory |
| VI | 33–36 | Numerical computing, optimization, geometry for graphics, backpropagation & transformers |
| App. | A–D | Worked solutions to all 288 exercises, a library of free maths books, a notation reference, a study plan |

Every concept gets an intuition box before the formalism; every result that
matters gets a real proof; every chapter ends with exercises whose solutions
are fully worked in Appendix A.

Appendix D contains four study routes (ML, general maturity, code-reasoning,
graphics) with a dependency graph, so you can skip intelligently.

## Rebuilding the PDF

Typst is already installed at:

```
~/.local/typst/typst-x86_64-pc-windows-msvc/typst.exe
```

To rebuild:

```sh
TYPST=~/.local/typst/typst-x86_64-pc-windows-msvc/typst.exe
$TYPST compile main.typ "Mathematics-for-the-Working-Programmer.pdf"
```

Live preview while editing:

```sh
$TYPST watch main.typ
```

## Source layout

```
main.typ                 page setup, styles, part dividers, chapter includes
lib.typ                  theorem/definition/proof/intuition environments,
                         math shorthands (Var, EE, PP, argmin, …)
chapters/00-preface.typ  how to read the book
chapters/01..36-*.typ    the thirty-six chapters
chapters/A-solutions.typ solutions front matter; includes sol-1 … sol-7
chapters/sol-1..7.typ    worked solutions, grouped by chapter range
chapters/B-books.typ     free/open-licensed book list
chapters/C-notation.typ  notation reference
chapters/D-plan.typ      study plan and dependency graph
```

## Editing notes

A few Typst gotchas that bit during writing, recorded so they don't again:

- Intersection is `inter`, not `sect`. Partial derivative is `partial`, not
  `diff`. Hadamard product is `circle.small`. Angle brackets are the literal
  `⟨ ⟩` characters.
- Multi-letter tokens in math mode must be defined symbols — `2xy` is a
  parse error, write `2 x y`. Any new shorthand goes in `lib.typ` as
  `math.op(...)` so it resolves inside `$…$`.
- Inside `#algo[…]` always use a fenced code block; bare `<-` in markup
  starts a label and errors out.
