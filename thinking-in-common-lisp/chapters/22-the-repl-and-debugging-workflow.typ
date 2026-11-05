#import "../lib.typ": *

= The REPL and Debugging Workflow

You've met the debugger as a thing that interrupts you. This chapter turns it around: the debugger, the inspector, the backtrace and the REPL are one connected toolkit, and using it well is what "thinking in Lisp" feels like in practice — you don't write programs so much as #emph[grow] them, with the program running the whole time.

== The REPL as a workbench

The REPL is not a toy console for trying one-liners. It is a window onto a running program, and the running program is where your work happens. The habits that make it a workbench:

- Keep the #emph[image] alive. Unlike the write-compile-run cycle, a Lisp session holds state across edits: the game you're debugging stays loaded while you fix a function and try it again.
- Define things where you'll call them. A `defparameter` typed at the REPL is test data; the same line in a file is part of the program. Both are legitimate — but know which one you're doing.
- `*`, `**` and `***` are the last three #emph[values] the REPL printed; `+`, `++` and `+++` are the last three #emph[forms] you typed:

```lisp
(+ 1 2)      ; => 3
(* * 10)     ; => 30   — ten times the last value
(+ * 1)      ; => 31   — three times the last form's value
```

Useful in the moment, dangerous as a habit: the next expression you evaluate silently changes what `*` means. For anything worth keeping, `defparameter` it with a real name.

- `describe` prints what Lisp knows about anything — a function's signature and documentation, a symbol's package, a variable's value:

```lisp
(describe #'run-command)
(describe *current-room*)
```

- `documentation` reads just the docstring: `(documentation 'take 'function)`. This is why Chapter 5 insisted on docstrings: they are queryable at runtime, by you and by tools.

== The inspector

`inspect` opens an interactive view of any object — in SLIME or SLY, an Emacs buffer with one line per slot:

```lisp
(inspect *current-room*)
```

You see the structure, each slot with its name and value, and for the game's `room` structures that's exactly the view you want: name, description, exits, locked, items. From there you can descend: follow a slot into another object, evaluate expressions #emph[in the context of the object], and walk back out. The inspector is how you answer "what does this room actually contain right now?" without writing printing code — Chapter 13's `:print-function` makes the top-level view readable, and the inspector makes it navigable.

Use it on: an alist whose shape looks wrong, a condition object caught in a handler, a structure whose slots hold surprises. In SLIME\/SLY, `C-c C-v C-o` (or `M-x slime-inspect`) inspects the expression at point.

== `break`, `error`, and deliberate stops

`error` says something is wrong. `break` says #emph[stop here so I can look around] — it enters the debugger without signalling an error, and `continue` from there resumes as if nothing happened:

```lisp
(defun suspicious-part (lst)
  (when (and lst (null (rest lst)))
    (break "Suspicious: one-element list ~S" lst))
  (reverse lst))
```

The difference is intent and recovery: an error unwinds looking for handlers; a break just opens the debugger with a `CONTINUE` restart that puts everything back. Use `break` while hunting, then delete it — or turn it into `warn` if the condition is worth reporting in the finished program.

`trace` (Chapter 8) shows calls and returns; `step` walks a form one subform at a time, in SLIME\/SLY showing each step in Emacs with keys to descend, skip or evaluate. Stepping is slow but exact — when you can't see why a function returns what it returns, `step` shows the path; when you can't see what its inputs were, `trace` shows the calls.

== Reading a backtrace

When an unhandled error opens the debugger, below the condition and the restarts is the stack: one frame per call in progress, most recent first. Reading it is a skill with three steps:

+ #emph[Read the condition first.] The message usually names the trouble: "The value KEY is not of type LIST" already tells you a list was expected and a symbol arrived. The stack only says where.
+ #emph[Find the first frame that's yours.] Below it are implementation internals; above it, your callers. The boundary — the topmost frame whose name you recognise — is where your code and the failure meet.
+ #emph[Look at the frame's arguments.] In SLIME\/SLY, pressing `v` on a frame jumps to its source line; pressing `t` or clicking expands its arguments. "The function got the wrong thing" plus "here is the wrong thing" plus "here is the line" is most bugs solved.

A worked example. `(length 5)` gives:

```text
The value 5 is not of type LIST
   [Condition of type TYPE-ERROR]
...
0: (LENGTH 5)
1: (SOME-SUMMARY-FUNCTION 'KEY ...)
2: (RUN-COMMAND (INVENTORY))
```

Read from the top: `length` was given `5`. Frame 1 shows your function passed a symbol where a list was expected — the bug is in frame 1's own call to `length`. Frame 2 tells you who was running. You didn't need to guess any of it; the stack said it.

== Editing running code: redefinition

Chapter 16 showed the file-to-session loop; here's its debugging form. When the game misbehaves:

+ Try the failing command at the REPL with the same arguments the game gave it. The debugger you get is #emph[your] debugger, with the arguments in front of you.
+ Find and fix the definition. `C-c C-c` it — the running game now calls the new version; nothing restarts.
+ Try the command again. If it works, done — and the fix is already in the file.

This loop is seconds long, and its speed changes how you debug: instead of reasoning your way to the answer before touching anything, you can test hypotheses directly — change one thing, push it live, try again. Keep the loop honest by changing #emph[one thing] at a time; a session where five definitions were redefined since the last success is a session you can't reason about.

Two safety nets:

```lisp
(time (loop for i below 1000000 sum i))
```

Reports bytes allocated and milliseconds spent. Reach for `time` when something feels slow, not before.

== When the image is sick

Rarely, the session itself is the problem: a variable redefined to something mad, a package switched and forgotten, a method that breaks printing (so even `print` errors — a nasty loop). The ladder out, mildest first:

- `(in-package :cl-user)` fixes forgotten package switches.
- `makunbound` (Chapter 9) unbinds a variable you've broken.
- `fmakunbound` does it for functions; redefine afterwards.
- `(untrace)` removes all traces; `trace` with no arguments lists them.
- As a last resort, quit and `asdf:load-system` again — Chapter 16's design exists so this costs seconds, not work. Losing REPL scratch state is the price; that's why real findings get written to files.

== Common mistakes

=== Debugging in the file instead of the session

Reading code and reasoning is slow and often wrong. The session is right there: call the function with the failing input, `inspect` the value, `trace` the calls. Reasoning confirms; the REPL discovers.

=== Trusting `*` across other evaluations

`*` means "last value printed", and anything evaluated since — a test, a stray Enter — changed it. Bind results to names the moment they matter.

=== Fixing five things between tests

The redefinition loop's power comes from its granularity. One change, one try. If you must change several, write them all in the file first, then `C-c C-c` them one at a time in dependency order — classes, then methods, then callers.

=== Leaving `break` and `trace` in finished code

`break` in shipped code stops the program for the user, not for you. Trace output pollutes logs. Remove them when the hunt is over, or convert `break` to `warn` where a report is genuinely useful.

=== Reading the stack bottom-up

The bottom frame is the program's start; the top is where it broke. Reading bottom-up is reading history before the crime. Read the condition, then the top frames, downward only until you find yourself.

== Project step: a debug command for the game

The game gets a `debug` command that opens the inspector on the current state — because the toolkit should be reachable from inside the game too, and because writing it exercises the chapter's pieces:

```lisp
(defun debug-state ()
  "Enter the inspector on the game state."
  (inspect *current-room*))

(push '(debug . debug-state) *commands*)
```

Check it: `(run-command '(debug))` opens the inspector buffer in Emacs (or the text inspector at the REPL), showing the current room's slots. Quitting the inspector returns to where you were — the `inspect` call simply returns.

And one that exercises the condition system and the backtrace together, a self-diagnosis command:

```lisp
(defun doctor ()
  "Report on the game's internal consistency."
  (let ((problems nil))
    (dolist (pair *item-locations*)
      (unless (find-room (cdr pair))
        (push (format nil "~(~A~) is in unknown room ~(~A~)"
                      (car pair) (cdr pair))
              problems)))
    (unless (or (null *current-room*)
                (member *current-room* *rooms* :test #'eq))
      (push "Current room is not in *rooms*" problems))
    (if problems
        (format nil "~{~A~^; ~}." problems)
        "All clear.")))

(push '(doctor . doctor) *commands*)
```

Check both:

```lisp
(defparameter *item-locations*
  '((key . kitchen) (sword . ballroom)))
(doctor)
```

Expected: a report naming `sword`'s unknown room — one check catching one kind of drift. The `*current-room*` check catches the other kind: a room symbol the game's state still references after the room was removed from `*rooms*`. Two predicates, two failure modes, one sentence of output.

This is the pattern for all debugging aids: cheap to write (it's just the predicates you already have), and they turn "the game feels wrong" into a sentence.

== Exercises

#exercise("22.1")[
  Predict, then check each in a fresh order to prove to yourself how `*` works:

  ```text
  (+ 2 3)
  (* * 4)
  (list * ** ***)
  ```

  What are the three elements? Evaluate one harmless form (like `nil`) between the second and third lines and re-run: what changes?

]

#exercise("22.2")[
  Use `describe` on `#'append` and on `*commands*`. From the output only (cover your memory of the chapter): what arguments does `append` take, and what kind of structure is `*commands*`?

]

#exercise("22.3")[
  Evaluate `(inspect (make-condition 'type-error :datum 5 :expected-type 'list))` and report, from what you see: what slots does a `type-error` have, and what are their values here? Then write a `handler-case` that catches a `type-error` and returns a string built from those two slots.

]

#exercise("22.4")[
  Each of these debugging situations has a best tool. Name it — `trace`, `step`, `break`, `inspect`, `apropos`, `time`, `describe` — and say in one sentence why the others fit worse.

  ```text
  a) A function returns the right shape but wrong contents.
  b) You remember "a function about prices" but not its name.
  c) The game runs, but a command takes visibly half a second.
  d) An alist has the right keys but one value is NIL, and you
     want to see the whole thing at once.
  e) A loop seems to never end, and you want to watch each
     subexpression evaluate.
  f) A predicate is firing when it shouldn't, and you want the
     program to stop right there with the data in front of you.
  ```

]

#exercise("22.5")[
  Write `safe-run`, which takes a function and returns either `(list :ok value)` when it returns, or `(list :error message)` when it signals — using `handler-case`, and using `princ-to-string` on the condition for the message. Check it with `#'` and a lambda that divides by zero.

]

#exercise("22.6", project: true)[
  Add a `whereis` command: `(whereis key)` prints every room the item has ever been seen in, using `*history*` (Chapter 14's undo snapshots). What condition does it need to handle when the item is unknown, and where should that handling go — in the command function or in `run-command`? Defend your answer in a comment.

]

#exercise("22.7", project: true)[
  Break the game on purpose, three ways: redefine `item-names` to return `nil`; rebind `*current-room*` to a room symbol not in `*rooms*`; delete a room from `*rooms*` while items are in it. For each, run `(doctor)` and `inventory`, note what breaks and what merely misbehaves, then repair with the redefinition loop. Write the three symptoms as comments — this is your personal bug catalogue for this codebase.

]

