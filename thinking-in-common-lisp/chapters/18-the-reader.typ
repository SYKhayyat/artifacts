#import "../lib.typ": *

= The Reader

Every block of Lisp you've run has passed through two stages on its way to becoming a running program: first the #emph[reader] turned your typed characters into Lisp objects, then `eval` (or `compile`) made those objects do things. You've known this dimly since Chapter 2 — `quote` stops evaluation of a #emph[list object] — but the reader itself has been invisible. This chapter makes it visible, because reader syntax is Lisp's parser, and a surprising amount of "the language" is actually just reader notation.

== The reader's job

The reader takes a stream of characters and produces #emph[data]: one Lisp object per form. That's all it does — it knows nothing about functions, variables or evaluation. When you type:

```lisp
(+ 1 2)
```

the reader produces a three-element list containing the symbol `+`, the integer `1` and the integer `2`. Evaluation is a separate later step. This separation — data first, meaning later — is the property behind macros (Chapter 14) and behind this chapter: you can get at the data, change the reader, and add notation.

`read` is the reader's front door (met in Chapter 16 for files): it reads one object from any stream. `read-from-string` reads one object from a string:

```lisp
(read-from-string "(a b (c 1))")
;; => (A B (C 1)), and a second value: 12, where reading stopped

(read-from-string "42")
;; => 42
```

Everything you type at the REPL, everything in your `.lisp` files, everything `read` pulls from a save file — all of it goes through the same machinery.

== The standard read syntax, collected

Most of this you know; the point is to see it as one table, one system. The reader's notations:

#[
  #set par(justify: false)
  #table(
    columns: (1.9fr, 5.2fr, 0.9fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Syntax], [Produces], [Met in]),
    [`123`, `-1.5`], [numbers], [3],
    [`1/3`], [a ratio], [3],
    [`1.0d0`], [a double float], [3],
    [`"text"`], [a string (`\` escapes inside)], [3],
    [`#\a`, `#\Space`], [a character], [3],
    [`foo`, `Foo`], [a symbol (upper-cased by default)], [3],
    [`:key`], [a keyword], [3],
    [`'x`], [`(quote x)`], [2],
    [`(a ,b ,@c)`], [quasiquote], [14],
    [`(a . b)`], [a cons cell], [7],
    [`nil`, `t`], [the two constants], [2],
    [`#'fn`], [`(function fn)`], [9],
    [`#:sym`], [an uninterned symbol], [14],
  )
]

The `#` (sharp-sign) dispatch family deserves its own look, because each following character is a different notation:

#[
  #set par(justify: false)
  #table(
    columns: (2.0fr, 5.1fr, 0.8fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Syntax], [Produces], [Met in]),
    [`#'foo`], [the function `foo`], [9],
    [`'(1 2)`], [`(quote (1 2))`], [2],
    [`#x1F`, `#o17`, `#b1010`], [hex \/ octal \/ binary numbers], [new],
    [`#c(1 2)`], [the complex number 1+2i], [new],
    [`#p"/tmp/x"`], [a pathname object], [new],
    [`#.expr`], [#emph[evaluate expr while reading]], [new],
    [`#+feature`, `#-feature`], [read the next form only if a feature is (not) present], [new],
    [`#\Newline`], [named characters], [3],
    [\#], [...], [`#`],
    [`#;`], [comment out the next #emph[form]], [new],
    [`#:sym`], [uninterned symbol], [14],
    [`#S(room ...)`], [a structure literal], [new],
    [`#(...)`], [a vector literal], [new],
    [`#n`, `#n#`], [label and reference (circular structure)], [new],
  )
]

The new ones, in action:

```lisp
(list #xff            ; => 255 — hex
      #b1010          ; => 10  — binary
      #c(3 4)         ; => #C(3 4) — complex
      #p"/tmp/")      ; => #P"/tmp/" — a pathname object
```

Pathnames are Lisp's file-name objects — Chapter 16 used strings where `(merge-pathnames #p"saves/" (user-homedir-pathname))` would be the portable spelling. Complex numbers you may never need; that the reader handles them in one notation is the illustration that #emph[numbers are data the reader knows].

`#.` — sharp-dot — is the startling one: the reader itself evaluates the expression, and the result becomes the object being read:

```lisp
(list #.(+ 2 3)          ; => (5)
      #.*package*)       ; the current package object, read in as data
```

Used with restraint, it embeds computed constants in source. Used recklessly, it makes source unreadable. The respectable uses are small: `#.(get-internal-run-time)` stamped at compile time, or references to constant tables defined earlier in the same file.

`#+` and `#-` read a form only when a #emph[feature] is present or absent. Features are symbols on the dynamic variable `*features*` (the earmuff from the variables chapter, and now you see it used):

```lisp
#+sbcl (defparameter *implementation* :sbcl)
#+ccl  (defparameter *implementation* :ccl)
#+(or) (defparameter *never-read* t)   ; (or) = no features = never

(defun implementation-name ()
  #+sbcl "Steel Bank Common Lisp"
  #+ccl "Clozure Common Lisp")
```

This is how portable code handles implementation differences — including the `sb-ext:` calls in the executables chapter, which a truly portable library would guard this way. It is read-time conditionalisation: the unselected forms never even become objects.

`#S` and \#( are literal syntax for structures (Chapter 13) and vectors:

```lisp
(defstruct point x y)
```

```lisp
(list #S(point :x 1 :y 2)      ; a point, no make-instance call
      #(1 2 3))                ; a literal vector
```

Careful with these as #emph[literal data in source]: like quoted lists (Chapter 10's warning), literals are constants — don't `setf` into them. Two calls to the same function that returns `#(0 0 0)` return the #strong[same] vector, which is exactly what you don't want if either call's result is mutated.

`#n` \/ `#n#` solve circular structure, which no other syntax can express:

```lisp
(let ((l (list 1 2 3)))
  (setf (cdddr l) l)     ; make it circular
  l)                     ; printing this needs *print-circle*
```

```lisp
(let ((*print-circle* t))
  (prin1-to-string (let ((l (list 1 2)))
                     (setf (cdr (last l)) l)
                     l)))
;; => "#1=(1 2 . #1#)" — readable back, circularity intact
```

`#|` is the other comment notation beyond `;`. It can span lines, and it nests:

```lisp
#| This comment
   spans lines
   #| and nests |# |#

'(a b)   ; => (A B)
```

The standard has no notation that comments out #emph[one form] inside a list. To disable a single expression without disturbing the parentheses, either delete it or wrap it in `#| ... |#`. The older trick is `#+nil`, a feature test on a feature that is never present, so the reader skips the form entirely:

```lisp
'(a #+nil commented-out-element b)   ; => (A B)
```

== Case: what the reader does to your names

Chapter 3 mentioned symbols arrive upper-cased; here's the rule. The reader upcases unquoted symbol and keyword names, unless they contain escapes:

```lisp
(list 'room '|room| 'Room)   ; => (ROOM room ROOM)
```

The `|` bars escape case (and any characters). You've seen the consequences all along: keywords like `:name` work in any case you type, `(defun take ...)` defines `TAKE`, and the ( ) `format` directive exists to downcase them for display. Strings, of course, are untouched: `"room"` keeps its case.

The reader variable `*print-case*` controls the #emph[other] direction — how `prin1` and friends write symbols out:

```lisp
(let ((*print-case* :downcase))
  (prin1-to-string 'make-adder))   ; => "make-adder"
```

== The readtable: the reader's configuration

Like the printer, the reader is driven by a dynamic-variable-held object: `*readtable*`. A readtable maps each character to its reading behaviour. `get-macro-character` and `set-macro-character` read and change that mapping:

```lisp
(get-macro-character #\')   ; a function — ' is a macro character
(get-macro-character #\a)   ; NIL — ordinary constituents read as symbols
```

A #emph[macro character] is a character that triggers a reader function instead of being ordinary syntax — that is what `'`, `#`, , `,` are. You can add your own. A classic first example, making `{...}` read as a list (a notation some other Lisps have):

```lisp
(defun read-curly (stream char)
  (declare (ignore char))
  (do ((result nil)
       (obj (read stream t nil t) (read stream t nil t)))
      ((char= (peek-char #\} stream) #\})
       (read-char stream)          ; consume the }
       (nreverse result))
    (push obj result)))

(set-macro-character #\{ #'read-curly)
(set-macro-character #\} (lambda (stream char)
                           (declare (ignore stream char))
                           (error "Unmatched }")))
```

`(declare (ignore ...))` — the declaration you've seen once and never had explained — tells the compiler a parameter is deliberately unused, silencing warnings. The variables chapter's `declare` family gets its own treatment in the types chapter; this is its commonest use.

With the readtable changed:

```lisp
(read-from-string "{1 2 3}")
;; => (1 2 3) — the braces vanished; they were pure syntax
```

Now the payoff of understanding all this: #emph[macros are not special]. The `'` you use every chapter is a reader macro; `#'name` is a reader macro; the backquote that Chapter 14's macros are built on is a reader macro. Lisp's syntax is programmable at the character level, and `set-macro-character` is the mechanism. In practice, most Lisp programmers add one or two reader macros in their careers; the value of knowing this is mostly #emph[reading] — when you see strange notation in someone's source, there is no hidden grammar to learn, only a readtable change to find.

== `with-standard-io-syntax` and the read-only rules

Because `*readtable*`, `*package*`, `*read-base*` and the print variables are dynamic, code that writes or reads data meant for elsewhere should pin them all at once:

```lisp
(with-standard-io-syntax
  (prin1-to-string *item-locations*))
```

It binds every I\/O variable to its standard value — packages, case, bases, print settings — so the output is independent of whatever your session has been set to. Chapter 16's save files want this wrapping in a finished program.

Two safety variables round out the family: `*read-eval*` controls whether `#.` is honoured (it should be `nil` when reading data you didn't write — `#.` is arbitrary code execution by design), and `*read-suppress*` `t` makes the reader skip forms instead of building them, which is how tools skim source.

== Common mistakes

=== Fighting case instead of using it

Writing `|makeAdder|` or fighting upcasing with string comparisons is almost always a sign you wanted a string, not a symbol. Symbols are `eql`-comparable names; their case is a display matter, handled by ( ) in output.

=== Literals in source that get mutated

```text
(defun bag ()
  #(0 0 0))          ; a literal vector — shared, constant
(setf (aref (bag) 0) 1)  ; undefined behaviour
```

Return `(make-array 3 :initial-element 0)` instead. Same rule as Chapter 10's "never sort quoted": literals are constants.

=== Custom reader macros in shared code

A readtable change is invisible until it bites: your `{...}` means one thing in your session and a reader error in everyone else's. Libraries that need notation use named functions or macros, and reader macros only in applications, documented loudly.

=== Forgetting that \#. runs at read time

`#.(load-configuration)` executes while #emph[reading], before any compile or load logic — with whatever state the reading image has. Keep `#.` forms constant and side-effect-free, and bind `*read-eval*` to `nil` when reading untrusted data.

== Project step: a save file you can diff

Chapter 16's saves print one state object per line, in whatever case and settings the session had. This step pins the I\/O environment and adds a header line the loader checks — the small discipline that makes save files robust and version-traceable:

```lisp
(defparameter *save-format* 1)

(defun save-game ()
  "Write the game state to the save file, canonically."
  (with-open-file (out *save-file*
                       :direction :output
                       :if-exists :supersede)
    (with-standard-io-syntax
      (format out "cave-of-noise v~D~%" *save-format*)
      (print (game-state) out)))
  (format nil "Saved to ~A." *save-file*))

(defun load-game ()
  "Restore from the save file, checking the header."
  (handler-case
      (with-open-file (in *save-file*)
        (let ((header (read-line in)))
          (unless (search "cave-of-noise" header)
            (error "Not a Cave of Noise save file: ~S" header))
          (with-standard-io-syntax
            (restore-state (read in))))
        (look))
    (file-error () "No saved game found.")
    (end-of-file () "Save file is truncated.")
    (error (c) (format nil "Save file unreadable: ~A" c))))
```

Check:

```lisp
(setf *current-room* (find-room 'kitchen))
(setf *item-locations* '((key . kitchen)))
(setf *history* nil)
(save-game)

(setf *item-locations* nil)
(load-game)
*item-locations*     ; => ((KEY . KITCHEN))
```

And the diff-friendliness: open the save file. Symbols print in whatever case `*print-case*` is set to (`:upcase` is the default, which the `with-standard-io-syntax` enforces), one object per file after the header, stable across sessions and implementations because every variable that could have varied is pinned.

Two things the header buys. First, detection: a save written by some other program — or a save from a future version whose state format has changed — is refused with a legible message, not a cryptic `read` error. Second, migration: when a version change adds or renames a field, the loader can read the version integer and convert old state to new shape. Bump `*save-format*`, add a `convert-save-vN` function, and old saves keep loading. The header costs one line; the migration path it enables is worth months of not breaking players' saves.

== Exercises

#exercise("18.1")[
  Predict what each reads to, then check with `read-from-string`:

  ```text
  #b-101
  #xdeadbeef
  #c(0 -1)
  'sym
  '|Two Words|
  #(a b c)
  #:fresh
  ```

]

#exercise("18.2")[
  Predict, then check:

  ```text
  (read-from-string "(1 2 3) (4)")
  (read-from-string "1 2 3")
  ```

  What is the second return value telling you, and how would you write a `read-all` that returns every object in a string as a list?

]

#exercise("18.3")[
  Each snippet below is wrong or surprising. Say what happens, then fix it.

  ```text
  (defun defaults ()
    #S(point :x 0 :y 0))
  (setf (point-x (defaults)) 5)

  #+sbcl (defun fast-path () ...)
  #+ccl  (defun fast-path () ...)

  (read-from-string "#.(delete-file \"/home/you/notes.txt\")")
  ```

]

#exercise("18.4")[
  Write `feature-list`, which returns the features from `*features*` as downcased strings, sorted. Then write `implementation-p`, which takes a keyword such as `:sbcl` and answers whether `#+` would select that branch. What feature symbols does your SBCL report?

]

#exercise("18.5")[
  Add a reader macro: make `$ff` read as the number the hex digits denote, so `$ff` reads as `255` and `$a` as `10`. Use `set-macro-character` and `read` digits until a non-digit. Test with `read-from-string`, then undo it with a fresh readtable: `(setq *readtable* (copy-readtable nil))` — and say in a comment what copying a readtable means.

]

#exercise("18.6", project: true)[
  The save header from the project step only warns about foreign files. Extend `load-game` to parse the version number from the header and, when it sees version `0`, call a `convert-save-v0` function (write it: it should wrap the old bare-state list into today's shape, whatever "today's shape" is by the time you get here). What makes the header line — read with `read-line`, parsed with `parse-integer` — easier to evolve than the Lisp object that follows it?

]

