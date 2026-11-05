#import "../lib.typ": *

= Packages, Files and ASDF

Everything so far lived in one flat world: every symbol you made sat in the same bag, and the game's functions called each other by bare name. Small programs can live like that. This chapter adds the three tools Lisp uses to organise bigger ones: #emph[packages], which divide symbols into named groups; #emph[files and streams], which let a program read and write text on disk; and #emph[ASDF], which tells Lisp how to load a program spread over several files.

== Packages: bags of symbols

A package is a table of symbols. Every symbol belongs to exactly one package, and every read of Lisp code happens #emph[in] some package, which decides where each bare name goes. When you've been typing at the REPL, the prompt has been telling you this:

```text
CL-USER>
```

`CL-USER` is the default package, the playground. `*package*` holds the current one:

```lisp
*package*              ; => #<PACKAGE COMMON-LISP-USER>
(package-name *package*) ; => "COMMON-LISP-USER"
```

The symbols you've used come from two main packages: `CL`, the Common Lisp language itself (`car`, `defun`, `format`, several hundred of them), and `KEYWORD`, home of `:name` and friends. Symbol names are only strings, and two packages may both contain a symbol named `ROOM` without any confusion — the full name of a symbol is written `package:symbol`:

```lisp
(symbol-package 'car)          ; => #<PACKAGE COMMON-LISP>
(symbol-package :key)          ; => #<PACKAGE KEYWORD>
(symbol-package 'room-name)    ; => #<PACKAGE COMMON-LISP-USER>
```

=== `defpackage` and `in-package`

A new package is defined with `defpackage`, which is itself a macro from `CL`. A package for the game's engine:

```lisp
(defpackage :game
  (:use :cl)
  (:export :look
           :take
           :drop
           :inventory))

(in-package :game)
```

Read the parts:

- `(:use :cl)` says the `CL` package's exported symbols are visible here — otherwise you'd have to write `(cl:defun ...)` everywhere.
- `(:export ...)` lists the symbols other packages may use: the engine's #emph[public interface]. Everything else stays private.
- `(in-package :game)` makes `game` the current package. From here on, bare names resolve into `game`.

After `in-package`, defining things is ordinary:

```lisp
(defun internal-helper ()
  "Private to the GAME package."
  'shh)

(defun take (item)
  "Public: take ITEM."
  (format nil "taking ~(~A~) with ~A" item (internal-helper)))
```

Switch back and reach in through the interface:

```lisp
(in-package :cl-user)

(print (game:take 'key))
```

`game:take` works because `take` was exported. `game:internal-helper` (single colon) is a read error — the symbol isn't exported, and the reader refuses to resolve it. A double colon, `game::internal-helper`, does reach an unexported symbol, and that asymmetry is deliberate: double colon says "I know this is private and I want it anyway", which is useful when debugging your own code and rude between packages you don't own.

Symbols are shared, not copied: `game:take` #emph[is] the same symbol the `game` package calls `take`. Exporting is just permission to refer to it.

=== Name conflicts

Two packages may both export a symbol named `look`. A package that uses both must resolve the collision; if you `:use` a package whose export collides with `cl`'s, the reader complains as soon as a conflicting name is read. The everyday rules that keep this from happening:

- Use `:use :cl`, and for other packages prefer explicit listing: `(:use :cl :game.utils)` on packages whose exports you control.
- When a conflict appears, the honest fix is renaming one of the symbols, not twisting imports.

Two more bits of syntax you'll meet. `#:foo` is a symbol belonging to no package at all, made by `gensym` in Chapter 14 and used there for exactly this reason: it cannot collide with anything. And the keywords `:name` and `:key` belong to `keyword`, evaluate to themselves, and are the standard choice for names that are only names.

=== Packages and one session

One practical note. Everything you run shares one Lisp session, so an `in-package` in one listing affects all the others. When a chapter experiment switches packages, switch back with `(in-package :cl-user)` in the same listing, or your next game function will be defined in the wrong place. The listings below each switch back at the end.

== Files and streams

A #emph[stream] is a source or sink of characters (or bytes). You've used streams all along: `format t` writes to the standard output stream, the debugger reads from the input one. Files are streams attached to paths on disk.

=== Reading a file: `with-open-file`

```lisp
(with-open-file (in "/tmp/notes.txt")
  (loop for line = (read-line in nil)
        while line
        collect line))
```

`with-open-file` opens the file, binds `in` to the stream, runs the body, and closes the file however the body exits — it has an `unwind-protect` from Chapter 15 inside it. Never call `open` without a closing plan; `with-open-file` is the form to reach for.

`read-line` reads one line and returns it without the newline. Its second argument `nil` means "don't signal at end of file"; the #emph[second] value it returns then says whether the end was reached, but the `while line` test above handles the common case. For a file you didn't write, the robust walk uses the second value:

```lisp
(with-open-file (in "/tmp/notes.txt")
  (loop for (line found) = (multiple-value-list (read-line in nil))
        while found
        collect line))
```

`read-char` reads one character, `read` reads one Lisp #emph[object] — more on that below. All three accept the same `nil` second argument and return `nil` at the end.

=== Writing a file

`with-open-file` takes `:direction` and, for writing, whether to replace or append:

```lisp
(with-open-file (out "/tmp/notes.txt"
                     :direction :output
                     :if-exists :supersede)
  (format out "Line one.~%")
  (write-line "Line two." out))
```

#table(
  columns: (2.4fr, 5.6fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Argument], [Meaning]),
  [`:direction :output`], [Writing instead of the default `:input`],
  [`:if-exists :supersede`], [Replace an existing file],
  [`:if-exists :append`], [Add to the end of an existing file],
  [`:if-exists :error`], [The default: signal an error rather than clobber],
)

Without `:if-exists`, writing over an existing file is an error — Lisp refuses to destroy your data by accident.

`write-line` writes a string and a newline; `princ` and `print` work on streams too, taking the stream as their optional argument. `format`'s third destination kind from Chapter 12 is exactly this stream.

=== Saving Lisp data: `print` and `read`

Text meant for people and text meant for Lisp are different, and Chapter 12's `~A` versus `~S` distinction now gets its reason. To #emph[save] data, write it with `print`, which produces text Lisp can read back:

```lisp
(defparameter *save-state*
  '((key . kitchen) (letter . bedroom)))

(with-open-file (out "/tmp/save.lisp" :direction :output
                     :if-exists :supersede)
  (print *save-state* out)
  (print 'kitchen out))

(with-open-file (in "/tmp/save.lisp")
  (list (read in) (read in)))
;; => ((KEY . KITCHEN) (LETTER . BEDROOM)) and KITCHEN
```

Each `read` takes the next object from the stream: a list, a symbol, a number, a string — anything the reader can parse. The round trip through `print` and `read` is exact, which is why `print` writes the quotes on strings and the case of symbols. This #emph[readable data] style is one of Lisp's quiet strengths: configuration files, saved games and caches can be Lisp data, read back with no parser of your own.

`print` puts a newline before and a space after its output, so repeated `print` calls produce one object per line. `prin1` is `print` without the newlines, for packing several objects on one line.

== ASDF: another system definition facility

A #emph[system] is a program's files and how they fit together. ASDF is the standard tool that knows how to load one: which files, in what order, and what else must be loaded first.

A system is described by a `.asd` file. Suppose the game moves into a directory `~/src/game/` with two files, `packages.lisp` and `game.lisp`. The file `game.asd` sits alongside them:

```text
~/src/game/
├── game.asd
├── packages.lisp
└── game.lisp
```

```lisp
(asdf:defsystem "game"
  :description "A small adventure game"
  :serial t
  :components ((:file "packages")
               (:file "game")))
```

The parts:

- `:serial t` loads the components in the listed order, each one only after the previous — what you want nearly always at the start.
- `:components` lists the files, names without the `.lisp` ending.
- `packages.lisp` holds only the `defpackage` form, `game.lisp` everything else. Splitting the package definition into its own file is the convention, because other files' `in-package` lines need it loaded first.

To load it, ASDF must find the `.asd` file. With Quicklisp (Appendix A), the easy home is its local-projects folder; otherwise push the directory onto ASDF's registry:

```lisp
(push "/home/you/src/game/" asdf:*central-registry*)
(asdf:load-system "game")
```

`load-system` compiles and loads each file in order, and on the next call it reloads only what changed. From then on, other code reaches the game through its package:

```lisp
(in-package :cl-user)
(game:look)
```

ASDF scales up from here — dependencies between systems, tests, versioned releases — but the shape above is the shape everything else hangs off: one `.asd` file, files listed in order, one package per concern. Quicklisp and ASDF divide the work: Quicklisp #emph[finds and fetches] systems from the internet, ASDF #emph[builds] the ones you have.

== Common mistakes

=== Forgetting `(:use :cl)`

```text
(defpackage :game)
(in-package :game)
(defun take (x) x)

CL-USER> (game:take 1)
;; works, but in :game, even CAR is invisible:
;; (car '(1 2)) gives "The function CAR is undefined"
```

Without `:use :cl`, bare names resolve only inside the package, and the whole language vanishes. Always `(:use :cl)` unless you know why not.

=== Switching packages and forgetting to switch back

An `in-package` at the REPL is sticky. When `(in-package :game)` is run and the next thing you define is `take`, the game's `take` is silently replaced. The rule above: switch back before you move on.

=== The wrong path separators

Windows paths work in Lisp with forward slashes: `"C:/Users/you/save.lisp"`. Backslashes need doubling, since `\` is an escape character in strings (Chapter 3). Forward slashes work everywhere and are the habit to keep.

=== Reading with `read` what wasn't written with `print`

`read` parses Lisp syntax, so feeding it prose gives reader errors about stray parentheses and unknown symbols. Human-readable files want `read-line`; Lisp-readable files want `print` and `read`.

=== Opening for output without :if-exists

```text
(with-open-file (out "/tmp/notes.txt" :direction :output) ...)
;; the second run fails: "File exists"
```

Decide deliberately: `:supersede` to replace, `:append` to add, `:error` to refuse.

=== Streams used after the file is closed

The stream `in` exists only inside the `with-open-file` body. Saving it in a variable and reading from it later gives "stream is closed". Do all the reading in the body, or keep the #emph[data] rather than the stream.

== Project step: save and load the game

The game gains two commands, `save-game` and `load-game`, that write and restore the whole state: the item alist and the current room's name.

The state to save, gathered into one list:

```lisp
(defun game-state ()
  "Return a single list describing the whole game state."
  (list *item-locations*
        (room-name *current-room*)))

(defun restore-state (state)
  "Set the game state from the list STATE."
  (setf *item-locations* (first state))
  (setf *current-room* (find-room (second state))))

(defparameter *save-file* "/tmp/game-save.lisp")
```

The two commands:

```lisp
(defun save-game ()
  "Write the game state to the save file."
  (with-open-file (out *save-file*
                       :direction :output
                       :if-exists :supersede)
    (print (game-state) out))
  (format nil "Saved to ~A." *save-file*))

(defun load-game ()
  "Restore the game state from the save file."
  (handler-case
      (with-open-file (in *save-file*)
        (restore-state (read in))
        (look))
    (file-error ()
      "No saved game found.")))
```

`save-game` writes one object — the state list — and `load-game` reads one object back. The `handler-case` turns a missing file into a polite reply instead of a debugger: `file-error` is the condition type for exactly that.

Check the round trip. Walk to the kitchen, take the key, save, wreck the state, load:

```lisp
(defparameter *item-locations*
  '((lamp . cellar) (key . kitchen) (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))

(list (run-command '(take key))
      (save-game))
```

```lisp
;; Wreck the state, as if the session had restarted:
(setf *item-locations* nil)
(setf *current-room* (find-room 'bedroom))

(load-game)
;; => the kitchen's description

(inventory)
;; => "You are carrying: key."
```

What was destroyed is restored, because the state went to disk as readable Lisp and came back the same. Add the commands to the table:

```lisp
(push '(save . save-game) *commands*)
(push '(load . load-game) *commands*)
```

One design point worth noticing: `game-state` and `restore-state` are the whole save format, written down as functions. When the game grows a new piece of state, those two functions change together and nothing else knows how the save file is laid out.

== Exercises

#exercise("16.1")[
  Predict the result of each line, then check:

  ```text
  (symbol-package 'defun)
  (symbol-package 'game:take)
  (keywordp :look)
  (symbol-package (first '(a b)))
  ```

]

#exercise("16.2")[
  Write a file `"/tmp/haiku.txt"` with three lines of any text using `with-open-file` and `write-line`, then read it back into a list of three strings with `read-line`.

]

#exercise("16.3")[
  Write `append-note`, which takes a string and adds it to the end of `"/tmp/notes.txt"`, creating the file if it doesn't exist. The `:if-does-not-exist` argument of `with-open-file` controls that; `:create` is its usual value.

]

#exercise("16.4")[
  Predict the result, then check:

  ```text
  (with-open-file (out "/tmp/num.lisp" :direction :output
                       :if-exists :supersede)
    (print '(1 (2 3) "four") out))
  (with-open-file (in "/tmp/num.lisp")
    (read in))
  ```

  Why does the list come back with the string's quotes intact?

]

#exercise("16.5")[
  Each snippet below is wrong. Say what's wrong, then fix it.

  ```text
  (with-open-file (in "/tmp/notes.txt")
    (setf *saved-lines* in))
  ; later:
  (read-line *saved-lines*)

  (with-open-file (out "/tmp/notes.txt" :direction :output)
    (write-line "overwrite?" out))
  ; second run

  (read-line (open "/tmp/notes.txt"))
  ```

]

#exercise("16.6")[
  Write `count-lines`, which returns the number of lines in a file, using `with-open-file` and `loop`. `(count-lines "/tmp/haiku.txt")` gives `3` after Exercise 16.2.

]

#exercise("16.7")[
  Define a package `:shop` that uses `cl` and exports `sell` and `buy`. Inside it, define a private function `price` and the two exported functions using it. Then, from `cl-user`, show that `shop:sell` works, `shop:price` fails, and `shop::price` works.

]

#exercise("16.8", project: true)[
  Extend `game-state` and `restore-state` to include `*history*`, so that undo survives a save and load. Check that after `save`, `take`, `load`, an `undo` restores the key — and say in a comment what had to change and what didn't.

]

#exercise("16.9", project: true)[
  Write `save-report`, which writes the text of `describe-all` (from Exercise 11.11) to `"~/game-report.txt"`, one line per room, and returns the number of lines written. Where does `~` as a path start from, and does it work on Windows? Check with your implementation's documentation, and make the path a `defparameter` so it's easy to change.

]

