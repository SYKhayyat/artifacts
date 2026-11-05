# Thinking in Common Lisp

A 447-page Common Lisp text written from zero assumed knowledge up to a
shipped executable: expressions, lists, functions, recursion, macros,
conditions, CLOS, packages, then interop, generators, testing and the build.

**Read this:** `Thinking-in-Common-Lisp.pdf`

## What's in it

| Part | Chapters | Contents |
|---|---|---|
| I | 1–6 | The REPL, expressions and lists, numbers/characters/strings/symbols, variables, functions, conditionals |
| II | 7–10 | Cons cells and list structure, recursion, functions as values, the sequence functions |
| III | 11–16 | Loops, `format`, structures/hash tables/arrays, macros, conditions and the debugger, packages/files/ASDF |
| IV | 17–28 | Lexical vs dynamic scope, the reader, `handler-bind`, compilation and `eval-when`, declarations and performance, the debugging REPL, symbols and plists, multiple values, closures as objects, CLOS, CLOS deep dive, package internals |
| V | 29–34 | Interoperability (JSON, CSV, `run-program`, CFFI), iterators and generators, reading other people's Lisp, building executables, testing, the bigger picture |
| App. | A–I | Installing SBCL, Emacs setup, an Emacs survival guide, answers to all 258 exercises, the game's redefinitions, SBCL error messages, the complete game source, a glossary, a concept index |

Every chapter ends with a project step that grows one program, then exercises
whose answers are worked in Appendix D. Code blocks are Org Babel blocks that
run inside `lisp.org`; the printed book shows each block with its result.

## Rebuilding the PDF

`lisp.org` is the source of truth. `main.typ`, `lib.typ`, `chapters/`,
`parts/` and `includes.txt` are generated from it — edit `lisp.org`, not them.

```sh
python3 org2typst.py                      # regenerate the Typst tree
typst compile main.typ Thinking-in-Common-Lisp.pdf
```

`org2typst.py` needs nothing but Python 3 and a `typst` on `PATH`.
