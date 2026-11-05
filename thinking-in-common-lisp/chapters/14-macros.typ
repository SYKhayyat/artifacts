#import "../lib.typ": *

= Macros

You've used macros all along without the name: `when`, `unless`, `cond`, `and`, `or`, `setf`, `incf`, `push`, `defun`, `defparameter`, `loop`, `dotimes` are all macros. Now you learn what they are and how to write them. This is Lisp's most famous feature: the code you write is data, and programs can write programs.

== Functions cannot do everything

The `if` from Chapter 6 evaluates only one of its two branches:

```lisp
(if t (print 'yes) (print 'no))
```

Only `YES` prints. Now try to write `my-if` as a function:

```lisp
(defun my-if (condition then-branch else-branch)
  (cond (condition then-branch)
    (t else-branch)))
```

Call it:

```lisp
(my-if t (print 'yes) (print 'no))
```

```text
YES
NO
YES
```

Both branches print. Lisp evaluated all three arguments #emph[before] `my-if` ran, because that's how functions work: arguments are evaluated first. No function can receive the two branches unrun.

`if` and `when` get around this because they are #emph[macros]: they receive their arguments as raw code and decide themselves which parts to evaluate. That's the whole idea. A macro is a function from code to code, run at compile time, whose result is the code that actually executes.

== The macro's point of view

A macro call hands the macro #emph[forms], not values. Write a macro with `defmacro`, whose shape matches `defun`, and you can see the raw forms by having the macro return them as data:

```lisp
(defmacro last-form (form)
  form)

(macroexpand-1 '(last-form (+ 1 2)))
```

`macroexpand-1` asks a macro what it would produce, without running the result:

```text
(+ 1 2)
```

A macro that #emph[does] something to its forms, building a new form:

```lisp
(defmacro twice (form)
  (list 'progn form form))

(macroexpand-1 '(twice (princ "hi")))
;; => (PROGN (PRINC "hi") (PRINC "hi"))
```

`twice` receives `(princ "hi")`, builds `(progn (princ "hi") (princ "hi"))`, and that's the code that runs. The body used ordinary list functions — `list`, quoting — because the arguments are lists, the data from Part II.

```lisp
(twice (princ "hi"))
```

```text
hihi
```

== Backquote: templates for code

Building lists by hand gets clumsy fast. The #emph[backquote] character  quotes a form the way `'` does, but inside it, a comma `,` unquotes — inserts the value of an expression:

```lisp
(defparameter name 'ada)

`(hello ,name)
;; => (HELLO ADA)
```

Everything stays as written, except `,name`, which is replaced by its value. With a plain quote there are no holes at all — the whole form is data, so `name` stays the symbol:

```lisp
'(hello name) ; => (HELLO NAME)
```

A comma outside a backquote is not syntax at all: the reader stops with "Comma not inside a backquote". That error is worth recognising, because it usually means a missing backquote rather than a stray comma.

Inside a macro, backquote is how you write the expansion as a template, with commas marking the holes:

```lisp
(defmacro twice (form)
  `(progn ,form ,form))

(macroexpand-1 '(twice (princ "hi")))
;; => (PROGN (PRINC "hi") (PRINC "hi"))
```

Same expansion, but the code reads as the code it produces.

`,@` (comma-at) splices: it inserts a #emph[list's elements] rather than the list itself. It's `append` where `,` is `cons`:

```lisp
(defparameter extra '(c d))

`(a ,extra e)   ; => (A (C D) E)
`(a ,@extra e)  ; => (A C D E)
```

Now macros that earn their keep. `when` is close to:

```lisp
(defmacro my-when (test &body body)
`(if ,test (progn ,@body) nil))
```

`&body` is `&rest` for macro bodies: same behaviour, a signal to readers and to editors that the forms are a body of code. Check it:

```lisp
(macroexpand-1 '(my-when (plusp 5) (princ "big") (princ "!")))
;; => (IF (PLUSP 5) (PROGN (PRINC "big") (PRINC "!")) NIL)
```

And `my-unless`, the same shape with the branches swapped:

```lisp
(defmacro my-unless (test &body body)
`(if ,test nil (progn ,@body)))
```

== A macro the functions couldn't do: `while`

Here is a control structure Common Lisp doesn't have built in — a `while` loop that repeats until its test goes false. No function could write it, because the body must run many times, and a function receives its body once:

```lisp
(defmacro while (test &body body)
  `(loop while ,test
    do ,@body))
```

```lisp
(defparameter count 0)
(while (< count 3)
(print count)
(incf count))
```

```text
0
1
2
```

The expansion is ordinary `loop` code:

```lisp
(macroexpand-1 '(while (< n 10) (princ n)))
;; => (LOOP WHILE (< N 10) DO (PRINC N))
```

You defined syntax. Users of `while` can't tell it from something built into the language. Java gained lambdas and streams over the years, but no Java program can add new syntax to Java; the language grows only when its committee grows it. In Lisp, `defmacro` is part of the language for every programmer, and much of the standard library is itself macros written this way.

== Expansion, not evaluation

`macroexpand-1` shows one step. `macroexpand` expands repeatedly, until the result is no longer a macro call — useful because your macros often expand into other macros:

```lisp
(macroexpand '(my-when t (my-unless nil (princ "ok"))))
```

```text
(IF T (PROGN (IF NIL NIL (PROGN (PRINC "ok")))) NIL)
```

`when` and `unless` expanded into `if` and `progn` here, because `my-when` and `my-unless` are macros too.

Two facts to keep straight:

The macro's parameters are #emph[forms], so inside the macro you call list functions (Chapter 7) and, in the template, `,` and `,@`.

Watch the difference in this macro, which counts how many forms are in its body:

```lisp
(defmacro body-size (&body body)
  `(quote ,body))

(body-size (princ 1) (princ 2) (princ 3))
;; => ((PRINC 1) (PRINC 2) (PRINC 3))
```

The three `princ` calls never ran. The macro saw them as data and returned them as data.

== Variables in macros: the hygiene trap

Macros that introduce variable names can collide with the names the caller uses. Here is a broken macro:

```lisp
(defmacro swap-bad (a b)
  `(let ((temp ,a))
    (setf ,a ,b)
    (setf ,b temp)))
```

It looks right:

```lisp
(defparameter *x* 1)
(defparameter *y* 2)
(swap-bad *x* *y*)
(list *x* *y*) ; => (2 1)
```

But pass a variable literally named `temp`:

```lisp
(defparameter temp 'kept)
(swap-bad temp *x*)
temp ; => 2, not KEPT
```

The expansion was `(let ((temp temp)) ...)`, and the macro's `temp` shadowed the caller's. The caller's variable was clobbered — a bug that only shows up for certain callers, the worst kind.

The fix: use `gensym`, which generates a symbol guaranteed never to have been used before:

```lisp
(gensym) ; => #:G1234
(gensym) ; => #:G1235
```

The `#:` shows an uninterned symbol: a symbol no package owns (packages are Chapter 16). Build the expansion so the temporary name comes from `gensym` at expansion time:

```lisp
(defmacro swap (a b)
  (let ((temp (gensym)))
    `(let ((,temp ,a))
      (setf ,a ,b)
      (setf ,b ,temp))))
```

Notice the two levels: `let` (plain) runs at expansion time and makes `temp` name the fresh symbol; backquote with `,temp` inserts that symbol into the template.

```lisp
(defparameter temp 'kept)
(defparameter *x* 1)
(swap temp *x*)
(list temp *x*) ; => (1 KEPT)
```

Now no caller can break it. The rule: #emph[any variable a macro introduces in code that runs more than once should be a gensym]. Code that runs once, such as a `let` binding evaluated a single time in the expansion, is safe with an ordinary name.

The same trap exists for arguments evaluated repeatedly:

```lisp
(defmacro square-bad (n)
  `(* ,n ,n))

(square-bad (progn (princ "evaluated ") 5))
;; prints "evaluated " twice, then 25
```

`,n` appears twice, so the form is evaluated twice. The fix binds the form once:

```lisp
(defmacro square (n)
  (let ((v (gensym)))
    `(let ((,v ,n))
      (* ,v ,v))))
```

== Destructuring in defmacro

A macro's parameter list can take lists apart, like `loop`'s patterns in Chapter 11:

```lisp
(defmacro do-pair ((a b) list &body body)
  `(dolist (pair ,list)
    (let ((,a (first pair))
        (,b (second pair)))
      ,@body)))
```

```lisp
(do-pair (name price) '((key 5) (lamp 10))
(format t "~A costs ~A~%" name price))
```

```text
KEY costs 5
LAMP costs 10
```

The parameter `(a b)` destructures the first argument of every call, and `,@body` splices the caller's body into the `let`.

== When to write a macro

Macros are powerful, and power wants restraint. The test: #emph[could a function do it?] If yes, write a function — functions compose better, can be passed with `#'`, and debug more simply. Write a macro when you need one of these:

Control flow: evaluate some arguments and not others (`when`, `and`), or evaluate them more than once (`while`).

New binding forms: introduce variables the body can use (`do-pair`'s `a` and `b`, `with-*` style macros).

Access to forms: you need the code itself, as `setf` needs the place and `trace` needs the function name.

Everything else is a function, and Chapter 9's higher-order functions cover much of what another language would reach for macros to do.

== Common mistakes

=== Calling the macro where you wanted the expansion

`macroexpand` takes a #emph[form], quoted:

```text
(macroexpand (my-when t 1))
;; expands the literal call, then macroexpand receives 1
```

Write `(macroexpand '(my-when t 1))`, with a quote.

=== Forgetting the comma

```text
(defmacro double-expr (x)
`(+ x x)) ; wrong: uses the symbol X

(macroexpand-1 '(double-expr (+ 2 3)))
;; => (+ X X) — the argument vanished
```

The comma in `(+ ,x ,x)` is what inserts the caller's form.

=== The reverse: comma outside backquote

```text
(defmacro bad (x)
(+ ,x 1))
;; reader error: comma is not inside a backquote
```

A comma only means "insert" inside a backquoted form.

=== Splicing a non-list

```text
(defmacro wrap (form)
`(progn ,@form))

(wrap (princ "hi"))
;; works: (princ "hi") is a form

(wrap 5)
;; error: 5 is not a list, and ,@ needs one
```

`,@` requires a list. When the argument may be one form or many, decide in the macro body.

=== A gensym that evaluates at the wrong time

```text
(defmacro swap-broken (a b)
`(let ((,(gensym) ,a))
(setf ,a ,b)
(setf ,b ,(gensym))))
```

Two different `gensym` calls run at #emph[two different moments], and the second `gensym` here runs when the expanded code runs, not when the macro expands. Compute the fresh symbol once, in a plain `let` around the backquote, and bind it in the expansion.

=== Writing a macro where a function fits

If your macro just computes a value from its arguments' values, delete it and write a function. `defmacro` is for syntax, and the project step shows the difference on the game.

== Project step: an undo macro and a command with syntax

The game gets two things from this chapter: an #emph[undo] command, and a macro that cleans up a repeated pattern.

Undo needs a history of item alists. Each move pushes a copy of `item-locations` onto a stack; undo pops and restores:

```lisp
(defparameter history nil)

(defun snapshot ()
  "Record the current item locations for undo."
  (push (copy-alist item-locations) history))

(defun undo ()
  "Restore the item locations from before the last move."
  (if (null history)
    "Nothing to undo."
    (progn
      (setf item-locations (pop history))
      "Undone.")))
```

`copy-alist` copies both levels of the alist, so the snapshot survives later changes to the live one (Chapter 7's sharing structure). Then every mutating command saves state first. The pattern "snapshot, then act" repeats in `take`, `drop` and `go-to` — a macro's job:

```lisp
(defmacro with-undo (&body body)
  `(progn
    (snapshot)
    ,@body))
```

Redefine `take` to use it:

```lisp
(defun take (item)
  "Pick up ITEM if it is in the current room."
  (cond ((eq (item-location item) 'player)
      (format nil "You already have the ~(~A~)." item))
    ((eq (item-location item) (room-name current-room))
      (with-undo
        (setf item-locations
          (set-location item-locations item 'player)))
      (format nil "You take the ~(~A~)." item))
    (t
      "You don't see that here.")))
```

Here `with-undo` is a macro only because of where the `snapshot` sits: it must run #emph[before] the caller's forms, interleaved with them, and the caller's forms must splice into the same `progn`. A function `(with-undo (setf ...))` couldn't do that — it would receive the `setf` already evaluated.

Now the command table. Add undo to it (if Exercise 14.7 has you add `drop` too, do that after):

```lisp
(push '(undo . undo) commands)
```

Check the undo. This block resets everything, so run it whole:

```lisp
(defparameter item-locations
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf history nil)
(setf current-room (find-room 'kitchen))

(list (run-command '(take key))
  (run-command '(undo))
  (items-in item-locations 'kitchen)
  (run-command '(take key)))
```

Expected: the take message, `"Undone."`, `(KEY)` back in the kitchen alist, and the take message again. The undo restored not just the items but the #emph[possibility]: the second `take` succeeds because the first one's effect was erased.

Second, a macro that reads better at the call site. Several game replies depend on the player carrying something:

```lisp
(defun open-chest ()
  "Open the chest if the player carries the key."
  (if (member 'key (items-here 'player))
    "The chest opens."
    "The chest is locked."))
```

One of these is fine. When a dozen checks pile up, a macro names the concept:

```lisp
(defmacro if-carrying (item then &body else)
  `(if (member ,item (items-here 'player))
    ,then
    (progn ,@else)))

(defun open-chest ()
  "Open the chest if the player carries the key."
  (if-carrying 'key
    "The chest opens."
    "The chest is locked."))
```

Note `then` is a single form (no `&body`), and `else` is a body. The indentation convention — the lone then on its own line, the else body indented under it — is what makes the call read like `if`.

Both macros expand into code you could have written by hand; check with `macroexpand` to see it. That's the healthy shape of most macros in real programs: small, readable expansions of repetitive patterns, not clever machinery.

== Exercises

#exercise("14.1")[
  Predict each expansion, then check with `macroexpand-1`:

  ```text
  (twice (princ 'x))
  (my-when (> 2 1) (princ 'a))
  (swap p q)
  (square (+ 1 2))
  ```

  Then run each form on suitable variables and say what happens and why.

]

#exercise("14.2")[
  Write `my-or2`, a two-argument `or`: evaluate the first; if it is true, return it without evaluating the second; otherwise evaluate and return the second. No function can do this — say why in one comment line inside your test block.

]

#exercise("14.3")[
  Write `repeat`, a macro `(repeat n &body body)` that runs the body `n` times, where `n` is a form evaluated once. `(repeat (+ 1 2) (princ 'x))` prints `XXX` — and prints `"evaluated"` only once if `n` is `(progn (princ "evaluated ") 3)`.

]

#exercise("14.4")[
  Each macro below is broken. Say what breaks, for which caller, then fix it with `gensym` or a different shape.

  ```text
  (defmacro first-of (lst)
  `(let ((head ,lst))
  (first head)))

  (defmacro inc-twice (x)
  `(incf ,x ,x))

  (defmacro unless-bad (test &body body)
  `(if ,test nil ,body))
  ```

]

#exercise("14.5")[
  Write `benchmark`, a macro `(benchmark form)` that returns the result of `form`, but prints a line before and after, so the expansion is `(progn (princ "start") <form-run> (princ "end") ...)` with the result threaded through. Then explain in one comment why `benchmark` must be a macro and not a function. (Real timing needs `get-internal-run-time`, which is beyond this chapter.)

]

#exercise("14.6")[
  Write `for-each`, a macro `(for-each (x lst) &body body)` that works like `dolist`. Check its expansion with `macroexpand-1`, then use it to print the rooms' names.

]

#exercise("14.7", project: true)[
  Add `(drop . drop)` and `(undo . undo)` to `commands`, and write a `rewind` command that undoes repeatedly while `history` is non-empty, returning how many steps it rolled back. Use `loop with`.

]

#exercise("14.8", project: true)[
  Write `if-room`, a macro `(if-room name then &body else)` that evaluates `then` with the variable `it` bound to the room found by `find-room`, or the `else` body when no room has that name:

  ```text
  (if-room kitchen
  (format nil "~A is found" (room-name it))
  "No such room.")
  ```

  This is Lisp's `if-let` pattern, and it shows a macro introducing a binding — impossible for a function.

]

