#import "../lib.typ": *

= Reading Other People's Lisp

You can now write everything this guide has covered — but a great deal of your Lisp life will be #emph[reading]: Quicklisp libraries, other people's systems, your own code from eight months ago. Library source has conventions this guide hasn't named, and a shape that's invisible until you've seen it once. This chapter is the guided tour: how real systems are laid out, what the comment conventions mean, what that `declaim` prologue is doing, and how to evaluate an unfamiliar library before trusting it.

== Get a real library and open it

The tour needs a specimen. Pick a small, well-regarded one:

```lisp
(ql:quickload :split-sequence)
(asdf:system-source-directory :split-sequence)
```

That last call returns the directory where Quicklisp unpacked the library. Open it in Emacs (#box[`C-x C-f`] then the path, or `C-x d` for dired — Appendix C covers both). Reading source in Emacs, #box[`M-.`] on any symbol jumps to its definition (with `slime` or `sly` running, and it works across the whole image — library code included); #box[`M-,`] jumps back. This one key is most of "reading Lisp in Emacs".

The reason this works: the Lisp image holds the #emph[definitions] of every function, not just the text. #box[`M-.`] asks the running Lisp where `split-sequence` was defined, and the answer points at the file and line. That's a completely different lookup from Emacs's tag-based systems in other languages — the image is the authority.

== The shape of a system

Most Quicklisp libraries look like this on disk:

```text
split-sequence/
├── README.md
├── LICENSE
├── split-sequence.asd
├── package.lisp
├── split-sequence.lisp
└── tests/
└── split-sequence-tests.lisp
```

The conventions, top to bottom:

#emph[README] — one screen: what it does, a usage example. If the README has no example, the tests are the example.

#emph[.asd] — the `defsystem` from Chapter 16. Read it first: the `:components` list #emph[is] the table of contents, and `:depends-on` #emph[is] what you're pulling in.

#emph[package.lisp] — the API contract: one `defpackage`, and the `(:export ...)` list is literally every name the library promises you.

#emph[one to three source files] — most libraries are small. split-sequence is one file of 150 lines. cl-ppcre is large; most are not.

The proportion to internalise: #emph[a Common Lisp library is often smaller than its documentation]. A feature you'd schedule a sprint for in Java is frequently 200 readable lines here.

== Comment conventions: the four (and five) semicolons

The comment heading conventions, standardised by tradition and used across Quicklisp:

```lisp
;;;; split-sequence.lisp
;;;
;;; Chapter-level banner: file title and purpose. Four
;;; semicolons, alone at the top (and section separations).

;;; Section heading — three semicolons, for a group of
;;; definitions that belong together.

(defun split-sequence (delimiter seq &key #| ... |#)
  ;; Two semicolons: comment on the code at the same
  ;; indentation as the form it describes.
  (let ((start 0))
    ;; ... sometimes a paragraph of rationale here
    (do ((i 0 (1+ i)))
      (#| ... |#)
      ;; One semicolon: a note on one line, running text,
      ;; often at the end of the line it explains. ; like this
      #| ... |#)))
```

So: `;;;;` file banners, `;;;` section headings, `;;` block comments beside code, `;` end-of-line asides. Emacs's auto-fill indents them by count; that's why the counts matter — `M-;` inserts the right one at point. Docstrings (Chapter 5) carry the #emph[interface] documentation; comments carry the #emph[why], and the four-level convention tells you how deep in the structure you are.

== The typical file prologue

Open a random library file and the first twenty lines are usually a prologue you can now read completely:

```lisp
;;;; package.lisp
(defpackage :split-sequence
  (:use :cl)
  (:export :split-sequence :split-sequence-if
    :split-sequence-if-not))

;;;; split-sequence.lisp
(in-package :split-sequence)

(declaim (inline split-sequence-from-end))
(defun split-sequence-from-end (#| ... |#)
  #| ... |#)

(declaim (ftype (function (t t &key (:start index)
        (:test function))
      list)
    split-sequence))
```

Reading it with this guide's chapters: the `defpackage` contract (Ch 28), `in-package` (Ch 16), `declaim (inline)` (Ch 21), `declaim (ftype ...)` declaring a function's #emph[type] — the `ftype` declaration you saw listed in Chapter 21 and have now met in the wild: it tells the compiler and the reader the function's signature; the compiler checks calls below against it. None of it is exotic anymore — that is the point of the tour.

Also common in prologues, now readable:

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  #| ... |#) ; Ch 20

(setf (documentation 'split-sequence 'function)
  "The real docstring, set programmatically.") ; Ch 22
```

== Docstring and naming idioms

Library code follows habits you can adopt:

#emph[Exported symbols all have docstrings], written as complete sentences: `"Return a list of subsequences..."`. `(documentation 'split-sequence 'function)` reads them.

Internal names carry a `marker`: `%compute-table`, `%parse`, or `nread-` — the percent prefix is the community's spelling of "private, don't call". You'll also see `package-name-` prefixes on internals from older code.

#emph[Predicates end in `-p` or `-p` of one `word` (`emptyp`, `boundary-p`); destructive] functions are `n`-prefixed or warned in the docstring ("may destroy LIST").

#emph[Keywords for options], `&key` for everything tweakable, defaults in the signature — the interface style this guide's `&key` chapter became.

== Reading macros you'll meet

Chapter 14 covered `defmacro`, but libraries use a small set of established macro names. Recognising them on sight is the reading skill:

`with-...` — a dynamic-scope resource or context (Ch 15's `unwind-protect` pattern). `with-open-file` is the model; `with-standard-io-syntax` (Ch 18), and every library's `with-connection`, `with-database` — same shape.

`do-...` — an iteration protocol walking something (`do-symbols` Ch 28, `do-hash-table` in libraries).

`define-...` — adds definitions to the system (`define-condition`, and libraries' `define-command`, `define-hook`) — usually a macro writing `defun` or `defmethod` calls for you.

`assert` family and `check-type` (Ch 21) inline.

`loop` keywords you haven't used: `minimize`, `maximize`, `sum`, `count`, `thereis`, `never`, `always` — Chapter 11's `loop` clause set, extended; all one vocabulary.

When a library macro is unfamiliar, the reflex is now mechanical: `macroexpand-1` it at the REPL with sample arguments (Ch 14) — the expansion is usually plain code you can read straight.

== Evaluating a library before trusting it

A checklist, in order of cheapness:

#emph[License] — usable in your context?

#emph[Dependencies] — `:depends-on` in the `.asd`. Each is something you also trust and ship. (uiop and alexandria are nearly universal and effectively standard.)

#emph[Tests] — does `tests/` exist? Can you run them? `(asdf:test-system :split-sequence)` works for systems that define an `:test-operation`.

#emph[Maintenance] — the dists directory's dates, or the repo: stale is not dead in Lisp (stable standard, stable code), but a decade of silent issues is a signal.

#emph[Read the source] — the final and most Lisp-native step. 150 lines, the whole story, and #box[`M-.`] makes it walkable.

The cultural note to carry: in Lisp, #emph[the source is the documentation of last resort, and reading it is normal]. Hyperspec lookup (Appendix B) for the standard, #box[`M-.`] for the library — the reading loop is the same skill at both layers.

== Common mistakes

=== Calling internal symbols

Reaching `(library::%parse ...)` because it does what you need couples you to an implementation detail the author may rearrange. If the function is genuinely useful, it's a missing export — fork, patch and ask upstream, or wrap defensively, but don't `::` in committed code.

=== Copying library code as if it were yours

The LICENSE file governs; MIT\/BSD need the copyright notice preserved in copies. Beyond law: a small copied function becomes #emph[your] maintenance burden; a dependency stays the upstream's.

=== Assuming stasis means abandonment

A library unchanged for years on a stable standard is often #emph[done], not dead. The signal to fear isn't silence — it's a tracker full of ignored runtime bugs.

== Project step: reading the game as a stranger

The discipline of this chapter, applied to your own system: open `cave-of-noise` as if you'd never seen it, and audit it against the tour's checklist:

Does the `.asd` read as a table of contents?

Does `packages.lisp` hold the full API contract, and does every exported symbol have a docstring?

Are the comment conventions used consistently — `;;;;` file banners present?

Are internals marked (`%` prefix or naming convention) and reachable only via `::`?

Does `(asdf:test-system :cave-of-noise)` exist? If the guide's project has no tests file yet, write the first one:

```lisp
;;;; tests.lisp
(defpackage :cave-of-noise/tests
  (:use :cl :cave-of-noise)
  (:import-from :cave-of-noise
                ;; state the tests read and rebind
                #:*item-locations* #:*current-room* #:*history*
                #:*save-file* #:*game-output*
                ;; functions and classes they call
                #:find-room #:item-location #:register-thing
                #:describe-thing #:make-history #:save-game
                #:load-game #:restore-state #:price #:treasure #:thing
                ;; command and data symbols: identity matters
                #:undo #:key #:kitchen #:player)
  (:export :run-tests))

(in-package :cave-of-noise/tests)

(defun run-tests ()
  "A handful of invariants, reported as a list of (name . ok)."
  (let ((results nil))
    (flet ((check (name got want)
          (push (cons name (equal got want)) results)))
      (check "item-location-roundtrip"
        (progn
          (setf item-locations '((key . kitchen)))
          (set-location item-locations 'key 'hallway)
          (item-location 'key))
        'hallway)
      (check "empty-history-safe"
        (progn (funcall history :clear)
          (funcall history :recent))
        nil))
    (nreverse results)))
```

And wire it into the `.asd`:

```lisp
(defsystem :cave-of-noise
  #| ... |#)

(defsystem :cave-of-noise/tests
  :depends-on (:cave-of-noise)
  :components ((:file "tests")))
```

Check:

```lisp
(load (merge-pathnames "tests.lisp"
    (asdf:system-source-directory :cave-of-noise)))
(cave-of-noise/tests::run-tests)
;; => (("item-location-roundtrip" . T)
;; ("empty-history-safe" . T))
```

The audit's real deliverable is the habit: after this chapter, you can't unsee a missing file banner or an undocumented export — in anyone's code, including the person who wrote it eight months ago.

== Exercises

#exercise("31.1")[
  Load a small library from Quicklisp and, from the source directory alone, answer: how many source files, what does the `:components` list order, and what does the export list promise? Write three sentences — the library's contract — without reading any implementation file.

]

#exercise("31.2")[
  Each of these prologue lines is met in the wild. Say what each does and which chapter's machinery it is:

  ```text
  (declaim (ftype (function (string) list) parse-header))
  (eval-when (:compile-toplevel) (pushnew :mylib features))
  (declaim (declaration my-pragma))
  (setf (documentation 'run 'function) "Run it.")
  (in-package :cl-user)
  ```

]

#exercise("31.3")[
  Write `system-report`, which takes an ASDF system name and returns an alist: `:directory`, `:files` (source component names in order), `:depends-on`, `:license` if the system object carries it. Which of these does `asdf:system-source-directory` give you directly, and which does `asdf:system-registered-p` vs `asdf:find-system` distinguish?

]

#exercise("31.4")[
  Pick three exported functions from the library of Exercise 31.1 and read their docstrings with `documentation`. Rate each: example present? argument roles named? failure mode stated? Then write the docstring your `run-command` #emph[should] have had, and compare with what it has.

]

#exercise("31.5")[
  Find one macro in the library you don't know. `macroexpand-1` it with plausible arguments, and read the expansion. Write three sentences on what it does, and say whether the expansion used machinery you already know (with-style cleanup, gensym, ecase dispatch) — and which.

]

#exercise("31.6", project: true)[
  Finish the audit: list every symbol the game defines with neither a docstring nor an internal-name marker. For each, either write the docstring or rename to the `%` convention. Then write `undocumented-exports`, which walks the game's package and returns the exported symbols lacking function or variable documentation — the audit as a reusable query, in the spirit of Chapter 28's `unexported-api`.

]

