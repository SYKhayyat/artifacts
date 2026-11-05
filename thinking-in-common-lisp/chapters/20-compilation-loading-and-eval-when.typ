#import "../lib.typ": *

= Compilation, Loading and eval-when

Everything you've run so far has gone straight from text to running code at the REPL. Behind the scenes SBCL has been compiling every form as it evaluates — but you haven't #emph[chosen] anything about compilation yet, and one kind of bug only appears when you compile a #emph[file]. This chapter closes that gap: the three times Lisp code lives in (compile time, load time, run time), what `eval-when` does about them, and why macros (Chapter 14) force the topic.

== The three times

A Lisp file leads three lives:

- #emph[Read and evaluated at compile time] — when `compile-file` processes it: macros expand here, `defconstant` names get their values, top-level `setq` of constants happens.
- #emph[Loaded] — when `load` reads the compiled `.fasl` file: `defun` bodies, `defparameter` forms and `defstruct` forms run here, installing functions, variables and structures.
- #emph[Run] — whenever the functions execute, days or years later.

Most code doesn't care. `defun` says "install this function when loaded, run it when called", and the times stay separate. The caring begins when a form must do something #emph[during compilation] — almost always because a macro needs it.

== compile-file and load

`compile-file` turns a source file into a compiled file:

```lisp
(compile-file "game.lisp")   ; => game.fasl (name varies)
```

The `.fasl` ("fast-load") file contains machine code plus the top-level forms that still need evaluation at load time. `load` handles either kind:

```lisp
(load "game.lisp")           ; reads and evaluates the source
(load "game.fasl")           ; loads the compiled form — faster
```

`load` binds two useful dynamic variables: `*load-pathname*` (the file being loaded) and `*load-truename*` (same, resolved to a full physical path). Code inside a file can find its own home:

```lisp
(defparameter *data-dir*
  (make-pathname :directory (pathname-directory *load-truename*)))
```

`(pathname-directory *load-truename*)` — the directory component alone — gives "the folder this file lives in", which is how Chapter 16's `*save-file*` can be anchored next to the source instead of wherever the process happened to start. (`uiop` calls this `uiop:pathname-directory-pathname`; the two-line version above is what it does.) The twin `*compile-file-truename*` is bound #emph[while compiling] — and the two being different at different times is exactly why `eval-when` exists.

== eval-when

Top-level forms in a file are processed at compile time and again at load time, but #emph[differently]: the compiler evaluates only forms it must (macro definitions, `defconstant`, and `progn` and `eval-when` forms), while everything else is merely compiled for later. `eval-when` takes control:

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  body...)
```

Three situations name the three times:

- `:compile-toplevel` — evaluate while #emph[compiling] this file.
- `:load-toplevel` — evaluate while #emph[loading] this file.
- `:execute` — evaluate when #emph[evaluated directly] (the REPL, or an enclosing `eval-when` running it).

Absent a situation, that time does nothing. Plain code is effectively `(:load-toplevel :execute)` — runs when loaded or evaluated, not at compile time. `eval-when` adds or removes the compile-time evaluation.

== Why macros need it

Chapter 14 defined macros with `defmacro` in the same file that used them, and it worked — at the REPL. Compile a file where the macro definition and its use sit in the usual order, and the compiler may not know the macro yet when it reaches the use: the use is #emph[compiled before the definition is loaded]. The fix is the standard prologue idiom:

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defpackage :cave-of-noise
    (:use :cl)
    (:shadow #:room)
    (:export :play)))
```

Three situations because: the compiler needs the package at compile time (to intern symbols); the loader needs it if the `.fasl` is loaded into a fresh image; and the REPL needs it when this form is evaluated directly. The same reasoning covers any support code a macro depends on:

```lisp
;; helpers the macro must call at EXPANSION time
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun expansion-helper (args) args))

(defmacro with-passthrough (&body body)
  `(progn ,@(expansion-helper body)))
```

The rule in one line: #emph[a macro's expansion-time world must be built before its first use, in every mode of processing the file.] `eval-when` is how you say it. (Many projects sidestep the fragility by putting macros in an earlier file and relying on `:serial t` in the `defsystem` — Chapter 16 — so the macro file loads before the file that uses it. Both are correct; `eval-when` within one file, `:serial` across files.)

== The standard idiom, demystified

You will meet this incantation in library source:

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %runtime-helper () 'ok))
```

Read it as one fixed unit meaning "define this so it's available at all three times" — available to macros at expansion time #emph[and] to normal code at run time. That's the whole content; writing it once you understand the three times, you'd choose the situations your case needs and know why.

A more honest example, from SBCL's own source — reading the package's exported symbol list when the reader compiles the `defpackage` form:

```lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :cave-of-noise)
    (make-package :cave-of-noise :use '(:cl))))
```

The `unless` guard means "safe in every situation": a second compile in the same image doesn't warn about redefining a package that's already there, and a first compile in a fresh image creates it. That's the shape `eval-when` is for — code that must run #emph[in all three modes] and is smart enough to be idempotent.

== Compilation units and compiler output

`compile-file` prints warnings — undefined functions, wrong argument counts, style notes — #emph[after] processing the file, grouped as one "compilation unit". `with-compilation-unit` gives the same grouping to interactive work:

```lisp
(with-compilation-unit ()
  (compile-file "packages.lisp")
  (compile-file "game.lisp"))
```

All warnings collect and print at the end — which matters when warnings cascade (an early undefined function causes a dozen follow-on ones). SBCL's warnings deserve respect: they catch, at compile time, errors other implementations let through to run time. A Lisp file that compiles silently is a real achievement, and the redefinition-loop discipline of Chapter 22 is what gets you there.

== Common mistakes

=== Trusting the REPL to predict file compilation

Code that works line by line at the REPL can fail to compile as a file: macro definitions after use, `defconstant` values computed by functions not yet available, top-level code assuming a package another file makes. The fix is always the same thought: what does this form need #emph[at compile time], and is it there?

=== eval-when as a magic spell

Sprinkling `(:compile-toplevel :load-toplevel :execute)` on everything "to be safe" wraps ordinary functions in pointless complexity and can cause double evaluation surprises. The situation list should be a #emph[decision]: which times does this form need, and why?

=== Load-time values baked as constants

```text
(defconstant *save-dir* (merge-pathnames "saves/"))
```

`defconstant` demands the same value every evaluation; a pathname with a defaulted host may differ across images or platforms, redefining a constant signals a warning, and the right form is `defparameter` (recomputable, rebindable) or a plain `defun` computing it on demand. Constants are for mathematical truths, not for environment facts.

=== Forgetting #strong[load-pathname] vs #strong[default-pathname-defaults]

Code that opens `"saves/game.sav"` relative to the #emph[current directory] works in your session and breaks when loaded from elsewhere. Anchor file access on `*load-truename*`, not on the process's accidental working directory.

== Project step: a make-like loader

The game's files (Chapter 16) load in order by hand. This step adds a tiny build step: compile the system's files and load the compiled versions, with compile-time warnings grouped and the load anchored on true pathnames.

The list of files matches Chapter 16's `.asd` for the game. If you haven't split the game into files yet, do Chapter 16's Exercise 16.7 first — the `:shop` package exercise is enough to give you two files to work with.

```lisp
(defparameter *game-files*
  '("packages.lisp" "classes.lisp" "commands.lisp" "main.lisp"))

(defun build-game ()
  "Compile each file, then load the compiled result."
  (with-compilation-unit ()
    (dolist (src *game-files*)
      (let ((fasl (compile-file src)))
        (when fasl (load fasl))))))
```

`compile-file` returns the fasl pathname, or `nil` if compilation failed hard — the `when` guards loading a failure. Check:

```lisp
(build-game)
(play)
```

And one `eval-when` in the real code: `packages.lisp` now declares itself compile-time-available:

```lisp
;; packages.lisp — now safe to compile as part of the batch
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :cave-of-noise)
    (make-package :cave-of-noise :use '(:cl))))
```

Without it, compiling `classes.lisp` (whose `:cave-of-noise` symbols need the package at compile time) warns "package CAVE-OF-NOISE not found" the first time; with it, `build-game` runs silent. That one form is the chapter in miniature: a compile-time need, named and satisfied.

One refinement worth having before you move on: `build-game` recompiles everything every time. A load-if-stale check makes it a real make:

```lisp
(defun fasl-for (src)
  (compile-file-pathname src))

(defun stale-p (src)
  (let ((fasl (fasl-for src)))
    (or (null (probe-file fasl))
        (> (file-write-date src)
           (file-write-date fasl)))))

(defun load-compile-if-stale ()
  (with-compilation-unit ()
    (dolist (src *game-files*)
      (when (stale-p src)
        (compile-file src))
      (load (fasl-for src)))))
```

This is a toy dependency check, and it lies in interesting ways — see Exercise 20.6 — but for a single-file project with no intra-file dependency tangles, it's the right amount of machinery. When the system grows real dependencies, ASDF is where the lying stops.

== Exercises

#exercise("20.1")[
  For each form, say at which times it is evaluated when its file is (a) compiled, (b) loaded, (c) evaluated at the REPL:

  ```text
  (defparameter *x* (compute-x))
  (defconstant +limit+ 10)
  (defun f () (compute-y))
  (eval-when (:compile-toplevel) (format t "hi"))
  (eval-when (:load-toplevel :execute) (defun g () 1))
  ```

]

#exercise("20.2")[
  A file contains, in this order: `(defmacro twice (x) (list ,x ,x))`, then `(defun f (a) (twice a))`. Explain what can go wrong when this file is compiled fresh, in a fresh image, and fix it two ways: once with `eval-when`, once with file ordering and `:serial t`.

]

#exercise("20.3")[
  Each snippet is wrong. Say what happens, then fix it.

  ```text
  (defconstant *home* (user-homedir-pathname))

  (defun self-path ()
    *default-pathname-defaults*)

  (eval-when (:execute)
    (defmacro always (val) val))
  (always 5)   ; used later in the same compiled file
  ```

]

#exercise("20.4")[
  Write `compile-and-report`, which takes a list of filenames, compiles each inside one `with-compilation-unit`, and returns an alist mapping each source name to its fasl pathname — with `nil` for files that failed to compile. What does grouping buy that per-file compilation doesn't?

]

#exercise("20.5")[
  Write `file-form-count`, a macro that expands to a constant integer: the number of top-level forms in the file being compiled — computed at compile time by reading the file with `read` (Chapter 16 and Chapter 18). Why must the counting happen at compile time, and what does the macro expand to at load time?

]

#exercise("20.6", project: true)[
  `load-compile-if-stale` from the project step recompiles `classes.lisp` when its source changes but not `main.lisp`, which uses it. Add a naive "recompile everything after the first stale file" rule: once any file in `*game-files*` is stale, recompile all subsequent files too. Then say in a comment what the rule still gets wrong that ASDF gets right.

]

