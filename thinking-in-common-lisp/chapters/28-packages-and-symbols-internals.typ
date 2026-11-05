#import "../lib.typ": *

= Packages and Symbols Internals

Chapter 16 taught the working day: `defpackage`, `in-package`, `export`, and why the game's symbols live behind `:cave-of-noise:` prefixes. This chapter goes under the hood — the package system as data structures you can query and manipulate. You need this not to write exotic code but to read it: every `shadow`, `unintern` and double-colon in someone's source is a sentence about these structures, and the name-conflict errors that interrupt your loading are questions these tools answer.

== The symbol table, by hand

A package is, at bottom, a table from strings to symbols, with a list of exported names and a list of use-lists. Three functions are the whole API surface for one symbol:

- `find-symbol` — look up a string; two values: the symbol and its status (`:internal`, `:external`, `:inherited`, or `nil`).
- `intern` — look up or create; the reader's own operation.
- `unintern` — remove a symbol from the package (the symbol object itself survives wherever it's referenced; it's just no longer #emph[findable by name `here`]).

```lisp
(find-symbol "CAR" :cl)           ; => CAR, :EXTERNAL
(find-symbol "car" :cl)           ; => NIL, NIL — table is case-sensitive
(intern "THING")                  ; creates in *package* if absent
(multiple-value-bind (sym status)
    (find-symbol "LOOK" :cave-of-noise)
  (list sym status))              ; => (LOOK :EXTERNAL) if exported
```

`do-symbols`, `do-external-symbols` and `do-all-symbols` walk the tables:

```lisp
(defun external-names (package)
  "Sorted list of a package's external symbol names."
  (let ((names nil))
    (do-external-symbols (s package)
      (push (symbol-name s) names))
    (sort names #'string<)))
```

`do-external-symbols` walks just the exports; `do-symbols` walks everything interned (with each symbol visited #emph[twice] if the package both inherits and imports it — an implementation-dependent corner); `do-all-symbols` walks every package. The fourth macro, `with-package-iterator`, is the programmatic one you'll meet in library code that wants to produce a lazy stream of symbols rather than iterate.

== export, import, and the two-way door

`export` puts a symbol's name in the package's external list. What's less obvious: `export` on a symbol the package doesn't home first imports it — the machinery is about tables, not about "publishing". The round trip:

```lisp
(defpackage :demo (:use :cl))
(in-package :demo)

(intern "TOOL")            ; home, internal
(export 'tool)             ; now external
(unintern 'tool)           ; gone from the table entirely
(find-symbol "TOOL" :demo) ; => NIL, NIL
```

`import` puts an existing symbol `object` into another package's table — after which `(eq 'cl-user::tool 'demo::tool)` is true: one symbol, two addresses. This differs from `shadow`, which creates a #emph[new] symbol in the package, blank, replacing the inherited name. The distinction drives every name-conflict resolution you'll ever click through in the debugger.

== Name conflicts, resolved by hand

A conflict happens when a name becomes findable two ways in one package: `use-package` over a package that exports `foo` while you've also interned your own `foo`; or `import` of a symbol whose name is taken. The system signals a correctable error whose restarts offer the resolution — Chapter 19's restarts, working for you at load time. By hand, there are three `defpackage` options:

```lisp
(defpackage :mine (:use :cl) (:shadow :list))
;; :LIST now names MY package's fresh symbol, not CL:LIST

(defpackage :mine2 (:use :cl)
  (:shadowing-import-from :mylib :merge))
;; :MERGE resolves in favour of MYLIB's symbol for this name

(defpackage :mine3 (:use :cl)
  (:import-from :mylib :helper))
;; bring MYLIB:HELPER in; error if the name is taken
```

#table(
  columns: (1.4fr, 6.6fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Option], [Effect on the conflicting name]),
  [`:shadow`], [my package gets its own fresh symbol],
  [`:shadowing-import-from`], [the named package's symbol wins, and is #emph[shadowing] — later `use-package` conflicts with it resolve silently],
  [`:import-from`], [bring the named package's symbol in (error if the table already has the name)],
)

The shadowing concept: a package can hold a symbol that shadows an inherited one — `find-symbol` returns it, and future `use-package`'s that would conflict with it are legal, the shadowing symbol winning. That's what makes `:shadowing-import-from` the tool for deliberately overriding part of a used package.

The four `defpackage` options for bringing names in, summarised:

- `(:use pkg)` — import all of `pkg`'s exports, so they can be found by name, and any name conflict is an error at `use-package` time.
- `(:import-from pkg name...)` — import the specific `symbols` `name...`; error if the name is taken.
- `(:shadowing-import-from pkg name...)` — same, but the imported symbols override the current table's names; no error if the name is taken.
- `(:shadow name...)` — the package gets its own symbol for each name, deliberately unrelated to whatever that name meant elsewhere.

== Nicknames, renaming, deleting

`:nicknames` in `defpackage` gives short handles — `(defpackage :cave-of-noise (:nicknames #:con) ...)` makes `con:look` legal. `rename-package` renames or re-nicknames in place (data and compiled code referencing the old name keep working — they hold the package `object`, not the string). `delete-package` removes one that's empty (no other package uses it); symbols home in it become garbage unless referenced elsewhere.

Nicknames are for typing comfort at the REPL and in qualified names — code inside the package never uses them. Renaming is for a library that changed its name and wants to keep the old one working.

== Reading foreign symbols, and keyword reality

The remaining oddity is the bare `:sym` — that's not package syntax at all. `:sym` reads as the symbol named `SYM` #emph[in the KEYWORD package] — keywords are simply the symbols home in `:keyword`, all externally exported by definition, self-evaluating because their value slot holds themselves. The whole story:

```lisp
(eq :look (intern "LOOK" :keyword))   ; => T
(symbol-package :look)                ; => #<PACKAGE "KEYWORD">
:look                                 ; self-evaluating
```

And the inverse notations, rarely needed but met in macros and printouts: `#:sym` (uninterned, Chapter 23) and `cl-user::foo` with the `::` reaching internals.

== Designing a package layout for a system

Chapter 16 split the game into files; the deeper design question is #emph[packages per file vs one package]. The practical wisdom:

- One package per interface, not per file. `packages.lisp` defining one `:cave-of-noise` package is right for an application; a library exposing `:mylib` and `:mylib.driver` splits when the parts serve different readers.
- `(:use :cl)` always; `use` of your own other packages only where the dependency is real — every used package's exports become part of your package's unqualified namespace, which is coupling.
- Export deliberately: the export list is your API contract, and `find-symbol` can test it. A symbol exported by accident is a commitment to support it.

ASDF's `:package-inferred-system` (Chapter 20) takes the per-file-package style to its conclusion: one package per file, named after the file, used by explicit `:use` or `:import-from` lines at the top. You'll meet it reading modern libraries; the skill of #emph[reading] `:import-from` lists as a dependency declaration is what this chapter buys.

== Common mistakes

=== Fighting case in package names

`(find-symbol "car" :cl)` fails — tables hold upcased names. `(find-symbol (string-upcase "car") :cl)` is the working form; the same for `intern` and every package function taking a string designator. The reader upcases names; the table stores them upcased; string comparisons must too.

=== :use lists as decoration

Long `:use` lists invite conflicts and hide provenance: when you read `merge` in the code, which package's `merge` is it? The modern default is `(:use :cl)` plus explicit `:import-from` for the handful of foreign names you want unqualified — provenance readable at the top of the file.

=== unintern in live code

`unintern` of a symbol that functions still reference leaves those references holding a symbol findable nowhere by name — redefinitions then create a different symbol with the same name, and the old code silently diverges from the new. Unintern only in package-fiddling sessions, never in program logic.

=== Treating keywords as "just strings"

Keywords are symbols: they intern (a table grows with every `new` keyword), they never garbage-collect in practice, and building keyword names from user input and interning them leaks and invites conflicts. Fixed vocabularies only: keywords for options, not for data.

=== Confusing single vs double colon

`:pkg:sym` means "external symbol `sym` in `pkg`" — and signals a reader error if `sym` is internal (not exported). `:pkg::sym` means "any symbol `sym` in `pkg`, exported or not". The single colon is the strict form; the double colon is the escape hatch. Writing `:pkg::look` when `look` is exported works, but it's a lie: the reader can't tell you cared, and readers of the code can't tell the symbol's status without checking. `:pkg:look` documents "this is API"; `:pkg::look` documents "I'm reaching into internals".

== Project step: the game's API surface

The game exports whatever Chapter 16 felt like exporting. This step makes the export list deliberate and testable — an API you can verify.

The package definition, refined:

```lisp
(defpackage :cave-of-noise
  (:use :cl)
  (:shadow #:room)
  (:nicknames #:con)
  (:export :play
           :look :take :drop :inventory
           :save-game :load-game
           :run-command))
```

Nine exports, all functions a caller would reasonably want. Deliberately not exported: `*rooms*`, `*item-locations*`, `*commands*`, `find-room`, `call-command`, `describe-thing`, `*thing-registry*` — the machinery the exports rest on. Callers use the API; internals stay internal.

The query that turns "what does my package expose?" from memory into a REPL operation:

```lisp
(defun unexported-api ()
  "Symbols the package defines but does not export."
  (let ((internal nil))
    (do-symbols (s :cave-of-noise)
      (multiple-value-bind (found status)
          (find-symbol (symbol-name s) :cave-of-noise)
        (when (and found (eq status :internal))
          (pushnew s internal))))
    (sort internal #'string< :key #'symbol-name)))
```

Check:

```lisp
(in-package :cl-user)
(con:look)
;; => the current room's description — the nickname works

(length (unexported-api))   ; => a number, probably 30-something
(member 'run-command (unexported-api))   ; => NIL — it's exported
(member '*rooms* (unexported-api))       ; => (*ROOMS*) — internal
```

Running `unexported-api` after a long development session routinely surfaces three or four symbols you meant to keep private but accidentally exported, or symbols you've been referring to by `::` that should be part of the API. That's the audit: names that should be public are in `:export`; names that shouldn't be are internal and reachable only by `::`.

Two more tests worth adding to the audit habit:

```lisp
(defun export-documented-p ()
  "Exported symbols lacking documentation — an audit subset."
  (let ((undocumented nil))
    (do-external-symbols (s :cave-of-noise)
      (when (and (fboundp s)
                 (null (documentation s 'function)))
        (push s undocumented)))
    (nreverse undocumented)))
```

Every exported function should have a docstring — the export list is the promise, and the docstring is the promise's terms.

And one deliberate import, the shape modern packages prefer:

```lisp
;; hypothetical: a future cave-of-noise that uses cl-ppcre
;; for one helper
(defpackage :cave-of-noise
  (:use :cl)
  (:shadow #:room)
  (:import-from :cl-ppcre :scan-to-strings)
  (:nicknames #:con)
  (:export :play
           :look :take :drop :inventory
           :save-game :load-game
           :run-command))
```

One name imported, by name, at the top — readable as a dependency, not as a `:use` that would pull the whole of `cl-ppcre` into the namespace.

== Exercises

#exercise("28.1")[
  Predict, then check:

  ```text
  (find-symbol "LIST" :cl)
  (find-symbol "list" :cl)
  (eq 'cl:car (intern "CAR" :cl))
  (symbol-package 'cl:car)
  (symbol-package 'car)              ; evaluated in CL-USER
  (multiple-value-list (find-symbol "RUN-COMMAND" :con))
  ```

]

#exercise("28.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (defpackage :p1 (:use :cl) (:export :run))
  (in-package :p1)
  (defun run () :p1s)
  (in-package :cl-user)
  (use-package :p1)
  run

  (defpackage :p2 (:use :cl :p1))
  (in-package :p2)
  (defun run () :p2s)

  (intern "TEMP" :p1)
  (unintern 'temp :p1)
  p1::temp
  ```

]

#exercise("28.3")[
  Write `where-does-name-live`, which takes a string and a package and returns, as a keyword or `nil`: `:external`, `:internal`, `:inherited` or `:absent`. Then write `find-anywhere`, which searches a package #emph[and] its use-lists in precedence order and returns the first package in which the name is findable. What does the order tell you about how the reader resolves unqualified names?

]

#exercise("28.4")[
  Write `package-diff`, which takes two packages and returns three values: names external to both, names external to only the first, names external to only the second. Use it on `:cl` and `:sb-ext` (or another implementation package you have) and report the counts in a comment.

]

#exercise("28.5")[
  Write `with-temp-package`, a macro that creates a fresh package with a `gensym` name, evaluates a body with `*package*` bound to it, and deletes the package after — body forms intern there. Demonstrate with a body that defines a function and calls it. What does this exercise assume about `delete-package`'s requirements, and how does your macro satisfy them?

]

#exercise("28.6", project: true)[
  Split the game's single package into two: `:cave-of-noise.data` (for `*rooms*`, `*item-locations*`, `save-game`\/`load-game`) and `:cave-of-noise` (commands, `play`), with the main package `:use`-ing `:cl` and `:import-from`-ing only the data names it needs. Which names did the main package actually need, and what does the final `:import-from` list tell you about where the real coupling between the halves lies?

]

