#import "../lib.typ": *

= Conditions and the Debugger

You've landed in the debugger often enough by now: a wrong argument, a missing function, `sort` on a quoted list. In most languages an error means the program dies and you read a stack trace. Common Lisp does something different: an error is not the end of the program but an event other code can respond to, and the debugger is the place where #emph[you] are the handler. This chapter covers both sides.

== Signalling: `error`, `warn`, `signal`

`error` announces that something has gone wrong and unwinds the stack looking for a handler:

```lisp
(error "That room doesn't exist.")
;; Enters the debugger
```

The string is a #emph[format control] — `error` calls `format` on it (Chapter 12), so directives work, and following arguments feed them:

```lisp
(error "Can't take ~A: not here." 'key)
```

Never build the message with `concatenate` before calling `error`. Pass the parts and let `format` do it. That keeps the message machine-readable as well as human-readable, which handlers below depend on.

`warn` is `error`'s softer cousin. It prints a warning and continues; the stack is not unwound and the program carries on:

```lisp
(warn "Low on fuel: ~D litres left." 2)
(princ 'still-running)
```

```text
WARNING: Low on fuel: 2 litres left.
STILL-RUNNING
```

`signal` is the quietest: it announces an event and, if nobody handles it, returns `nil` instead of entering the debugger. It is for events that may or may not be anyone's business. Most code needs only `error` and `warn`.

== Conditions are objects

A #emph[condition] is the object that represents the problem. Every error signal creates one. The one you've met most often is `simple-error`, and its relatives cover the common cases: `type-error` when a value has the wrong type, `unbound-variable` when a name has no value, `undefined-function` when a function isn't defined, `division-by-zero`.

You can see one directly with `make-condition`, and read its fields without ever signalling it:

```lisp
(defparameter *c* (make-condition 'type-error
                                  :datum "abc"
                                  :expected-type 'integer))

(type-error-datum *c*)            ; => "abc"
(type-error-expected-type *c*)    ; => INTEGER

(princ *c*)    ; prints something like:
               ; The value "abc" is not of type INTEGER.
```

Each condition type has accessors for its facts: `type-error` knows the bad value and the type wanted. Handlers read these instead of parsing text — the reason `error` takes a format control rather than a finished string.

New condition types are defined with `define-condition`, which reads like `defstruct` with a report instead of a print function:

```lisp
(define-condition room-not-found (error)
  ((name :initarg :name :reader room-not-found-name))
  (:report (lambda (condition stream)
             (format stream "No room called ~(~A~)."
                     (room-not-found-name condition)))))

(make-condition 'room-not-found :name 'attic)
```

The parent class, `(error)`, decides how the condition is treated: inheriting from `error` makes it an error, inheriting from `warning` makes it a warning, inheriting from `condition` alone makes it a plain event. `:report` builds the message the debugger shows. `:initarg` and `:reader` are Chapter 13's slots again — conditions are CLOS objects under the hood, and Chapter 17 makes that explicit.

Signalling your own type:

```lisp
(error 'room-not-found :name 'attic)
```

== Handling: `handler-case`

`handler-case` runs a body with a rescue plan for each condition type. Its shape:

```lisp
(handler-case
    body-form
  (condition-type (c) recovery-form...))
```

If `body-form` runs cleanly, its value is the result. If it signals a matching condition, the stack unwinds to this point and the recovery forms run instead:

```lisp
(defun parse-count (text)
  "Return the integer in TEXT, or NIL."
  (handler-case (parse-integer text)
    (error (c) (declare (ignore c)) nil)))

(list (parse-count "42")
      (parse-count "  7 ")
      (parse-count "nope"))
;; => (42 7 NIL)
```

`parse-integer` is new here. It converts the digits in a string to a number, and #emph[signals an error] when there are none — it refuses to guess. It also returns two values: the number and where it stopped reading (Chapter 13's multiple values).

Compare this with other languages' try\/catch. The differences that matter:

- The #emph[condition type] decides which clause runs, and the clause can be as specific as your own condition type. Catching `error` catches everything, which is rarely what you want — write specific clauses.
- The stack has already unwound when the handler runs: the recovery code runs where `handler-case` sits, not where the error happened. That limits what a handler can do — it can substitute a value, but it cannot "fix things and continue from the middle". The next section is the feature that fills that gap.
- The condition object `c` is bound for the recovery forms, so the handler can ask questions: `(type-error-datum c)` and so on.

Several clauses, most specific first:

```lisp
(defun try-integer-divide (a b)
  "Return A divided by B, or a message when that can't work."
  (handler-case (/ a b)
    (division-by-zero () "Can't divide by zero.")
    (type-error (c) (format nil "Bad input: ~A." (type-error-datum c)))))

(list (try-integer-divide 10 2)
      (try-integer-divide 10 0)
      (try-integer-divide 10 'x))
```

Expected: `(5 "Can't divide by zero." "Bad input: X.")`

The clause with no parameter, `(division-by-zero () ...)`, is normal: the condition object is there if you want it, not if you don't. The clause form `(:no-error ...)` runs when the body succeeded, which is handy for functions that report either a result or a failure:

```lisp
(defun safe-parse-or-log (text)
  (handler-case (parse-integer text)
    (error (c) (format t "~&parse failed: ~A~%" c) nil)
    (:no-error (n) (format t "~&parsed ~D~%" n) n)))
```

`:no-error`'s variable list gets the body's #emph[values] — a multiple-value safe exit.

== Restarts: repair instead of rescue

`handler-case` substitutes an answer. A #emph[restart] offers the caller a #emph[choice of ways to continue], and this is what makes Lisp's system different. When the debugger opens, what you've been seeing is a menu of restarts — `ABORT`, and usually others such as `USE-VALUE` or `STORE-VALUE`.

You can define your own with `restart-case`:

```lisp
(defun read-temperature (text)
  "Return the temperature in TEXT, or 20 when unreadable."
  (restart-case (parse-integer text)
    (use-default ()
      :report "Use the default temperature of 20."
      20)))
```

If `parse-integer` signals, no handler catches it here — but the `restart-case` has registered a way out. In the debugger, the `USE-DEFAULT` restart appears in the menu, and choosing it returns `20` — execution resumes as `if` that value had been produced.

Invoking restarts programmatically is `invoke-restart`, but the everyday tool is `find-restart` with `invoke-restart` inside a handler, or better: associating them. The full pattern — a low-level function that signals, a middle layer that offers restarts, a high-level function that chooses — is the #emph[condition system idiom]:

```lisp
(defun move-towards (name)
  "Change room, signalling ROOM-NOT-FOUND on a bad name."
  (let ((room (find-room name)))
    (when (null room)
      (error 'room-not-found :name name))
    (setf *current-room* room)
    (look)))

(defun move-safely (name)
  "Like MOVE-TOWARDS, but offers recovery choices."
  (restart-case (move-towards name)
    (substitute-room (other)
      :report (lambda (stream)
                (format stream "Go to ~(~A~) instead." other))
      (move-towards other))
    (stay-put ()
      :report "Stay where you are."
      "You stay put.")))
```

That `:report` lambda is overcomplicated, and shows why restarts belong with simpler arguments: the report format string is the main readable part, and the lambda hides it. A cleaner version:

```lisp
(defun move-safely (name)
  "Like MOVE-TOWARDS, but offers recovery choices."
  (restart-case (move-towards name)
    (stay-put ()
      :report "Stay where you are."
      "You stay put.")))

(defun move-or-stay (name)
  "Move to NAME, or stay when no such room exists."
  (handler-case (move-towards name)
    (room-not-found ()
      (invoke-restart 'stay-put))))
```

Read the layers: `move-towards` knows nothing about recovery; it only announces facts. `move-safely` offers choices. `move-or-stay` decides. Any layer can be swapped without touching the others — the same separation Java's exception hierarchy aims at, but with the choice of #emph[continuing] built in, not just unwinding.

`(invoke-restart 'stay-put)` only works when a restart of that name is in scope — inside the `restart-case`. From outside, the debugger menu offers the restarts interactively; that's the same mechanism with you at the controls.

== Interactive restarts: the debugger as REPL

When an unhandled error opens the debugger in SLIME or SLY (Appendix C), you see:

- The condition and its message.
- The menu of restarts, numbered.
- The stack of calls, each inspectable.

The restarts you'll actually use:

#table(
  columns: (1.8fr, 6.2fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Restart], [Meaning]),
  [`ABORT`], [Give up this attempt, back to the REPL (`q`)],
  [`USE-VALUE v`], [Pretend the failing expression produced `v`],
  [`STORE-VALUE v`], [Like `USE-VALUE`, for places rather than values],
  [`RETRY`], [Run the failing form again],
)

`USE-VALUE` is the one worth knowing by name. When a lookup fails deep in a long computation, you don't restart the computation: you supply the missing value and continue. In your own code, you can offer exactly that restart with `restart-case` and `:report "Use a replacement value."`, and the debugger menu grows a choice tailored to the problem.

== `ignore-errors` and `unwind-protect`

Two small forms cover the everyday cases.

`ignore-errors` returns `nil` when its body signals any error, and the body's value otherwise. It's `handler-case` with one catch-all clause and no access to the condition:

```lisp
(list (ignore-errors (/ 1 0))
      (ignore-errors (/ 10 2)))
;; => (NIL 5)
```

It's quick and blunt. For anything where you'd like to know #emph[what] went wrong, use `handler-case`.

`unwind-protect` isn't about errors at all, but about cleanup: its second form runs no matter how the first form exits — normally, by error, by a jump:

```lisp
(defparameter *log* nil)

(defun careful-change (f)
  (unwind-protect
      (progn (push 'start *log*)
             (funcall f)
             (push 'end *log*))
    (push 'cleanup *log*)))

(careful-change (lambda () (error "boom")))
(reverse *log*)   ; => (START CLEANUP)
```

The `end` never ran, because `error` unwound the stack, but `cleanup` did. Any resource you open — a file (Chapter 16), a socket, a temporary state — should be closed in an `unwind-protect`. The `with-open-file` macro you'll meet next chapter has exactly that inside it.

== Common mistakes

=== Catching `error` when you mean something specific

`(handler-case body (error (c) ...))` recovers from #emph[everything], including the typos and bugs you wanted to see. Catch the narrowest condition type that covers the case.

=== Building the message before signalling

```text
(error (concatenate 'string "Can't take " (symbol-name item) "."))
```

Pass a format control: `(error "Can't take ~A." item)`. The condition keeps the pieces, and handlers can read them.

=== Invoking a restart that isn't in scope

`(invoke-restart 'stay-put)` outside the `restart-case` that defined it gives "The restart STAY-PUT is not active". The restart lives while the `restart-case` form runs; the handler must sit inside that dynamic extent.

=== Confusing `warn` with `error`

`warn` continues; `error` unwinds. If your program keeps running after something you thought was fatal, you signalled a warning.

=== Forgetting that the stack has unwound

A `handler-case` handler cannot "go back" into the failed code. It chooses a value from where it stands. Continuation-from-the-middle is the restarts' job, offered at the failing site.

== Project step: failsafe commands

The command runner from Chapter 9 crashes the session on a malformed command: `(look kitchen)` calls `look` with an argument, `(take)` calls `take` with none, `(go)` likewise. This step makes `run-command` answer politely instead, and adds a `count-letters` command built on the condition system.

First, a safe runner. The current `run-command` (Chapter 9) looks up the command and applies it; the failure happens inside `apply`. Separate that into two pieces so the error-catching layer has a smaller target:

```lisp
(defun call-command (command)
  "Call the function that handles COMMAND."
  (let ((entry (assoc (first command) *commands*)))
    (if (null entry)
        "I don't know how to do that."
        (apply (cdr entry) (rest command)))))

(defun run-command (command)
  "Run COMMAND, a list such as (TAKE KEY), and return the reply."
  (restart-case (handler-case (call-command command)
                  (program-error ()
                    "Wrong number of arguments for that command."))
    (retry-with (fixed)
      :report "Run a corrected command instead."
      (run-command fixed))))
```

`program-error` covers wrong argument counts. The `retry-with` restart isn't used by the handler — it's there for you: when this fires in the debugger, you can supply a corrected command and the session continues. That's a debugging affordance, built in four lines.

Check the graceful replies:

```lisp
(list (run-command '(look kitchen))
      (run-command '(take))
      (run-command '(dance)))
```

Expected: the wrong-arguments message twice, and the unknown-command message. No debugger.

Second, a command that counts the letters in an item's name and demonstrates `restart-case` with a real recovery:

```lisp
(defun letter-count (item)
  "Return the number of letters in ITEM's name, or offer zero."
  (restart-case
      (let ((entry (assoc item *item-locations*)))
        (when (null entry)
          (error 'room-not-found :name item))
        (format nil "~(~A~) has ~D letters."
                item (length (symbol-name (first entry)))))
    (guess-zero ()
      :report "Treat it as zero letters."
      (format nil "~(~A~) has 0 letters." item))))

(defun count-letters (command)
  "Handle (COUNT-LETTERS ITEM)."
  (handler-case (letter-count (second command))
    (room-not-found ()
      (invoke-restart 'guess-zero))))
```

Read the flow carefully, because this is the condition system's round trip: `letter-count` runs inside `count-letters`'s `handler-case` body. When the item isn't in the alist, `letter-count` signals `room-not-found` from inside its own `restart-case`. The handler in `count-letters` runs — #emph[and it sits inside] the `restart-case`'s dynamic extent, because `letter-count` is the function that established the `restart-case`. So the handler can invoke the `guess-zero` restart, which resumes `letter-count` from the `restart-case` — not from `count-letters`'s point, but from `letter-count`'s. That's the whole condition system in one example: the signalling function offers choices, the caller decides, and neither needs to know the other's code.

Add the command:

```lisp
(push '(count-letters . count-letters) *commands*)

(defparameter *item-locations*
  '((key . kitchen) (letter . bedroom)))
(list (run-command '(count-letters key))
      (run-command '(count-letters sword)))
```

Expected: `"key has 3 letters."` and `"sword has 0 letters."` — the second through the restart path.

== Exercises

#exercise("15.1")[
  Predict what each listing returns or prints, then check:

  ```text
  (ignore-errors (+ 1 2))
  (ignore-errors (nth 5 '(a b)))
  (handler-case (/ 4 0) (division-by-zero () 'nope))
  (handler-case (car 'sym) (type-error (c) (type-error-datum c)))
  (warn "test") ; what does this return?
  ```

]

#exercise("15.2")[
  Write `safe-nth`, which takes an index and a list and returns the element, or `nil` when the index is out of range — using `handler-case` and `nth`'s error, not `length`.

]

#exercise("15.3")[
  Define a condition `invalid-move` with a `:reason` slot and a `:report`, then write `check-move`, which signals it for a direction the current room doesn't have, and `try-move`, which catches it and returns the reason.

]

#exercise("15.4")[
  Each snippet below is wrong. Say what's wrong, then fix it.

  ```text
  (error (format nil "Bad value: ~A" v))

  (handler-case (parse-integer s)
    (error () "bad")
    (parse-error () "unparseable"))

  (handler-case body
    (error (c) (invoke-restart 'my-restart)))
  ```

]

#exercise("15.5")[
  Write `to-integer`, which returns the integer in a string, or `0` with a warning when the string holds no integer. Use `parse-integer`, `handler-case` and `warn`, and make sure the warning text includes the bad string via a format directive.

]

#exercise("15.6")[
  Write `collect-results`, which takes a list of strings and returns a list of the `parse-integer` results of the parseable ones, skipping the rest. Use `loop`, `handler-case` and `push`, then `nreverse` it at the end — or explain in a comment why `append` in a `collect` position would also work.

]

#exercise("15.7", project: true)[
  Write `run-session`, which takes a list of commands and runs them all with `run-command`, collecting replies, so that one malformed command cannot stop the session. Compare its `handler-case` with `run-command`'s: why do both need one?

]

#exercise("15.8", project: true)[
  Add a `repair` restart to `call-command` for unknown commands, whose `:report` explains it substitutes `(look)`, and make `run-command` use it via `handler-case` and `invoke-restart` so that `(run-command '(dance))` runs `look` and returns its text.

]

