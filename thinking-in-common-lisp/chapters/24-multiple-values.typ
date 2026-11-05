#import "../lib.typ": *

= Multiple Values

A handful of functions you've already met have been returning #emph[two] things, and the code has been quietly catching only one: `floor` returned a quotient and a remainder, `gethash` returned a value and a found-flag, `parse-integer` returned a number and where reading stopped, `read-from-string` returned an object and a position, `get-properties` returned a key, a value and a tail. Lisp has #emph[multiple values] — a function result can be several objects at once — and this chapter explains the mechanism properly, because it is not what you'd guess coming from other languages, and the guessing causes real bugs.

== Values are not lists

The instinct — return a list of two things — is wrong twice over. A list must be allocated, deconstructed and (for `nil` and false values) made ambiguous: a list of `(nil nil)` can't distinguish "two nils" from "a list whose car is nil" without care. Multiple values are none of that: several objects handed over in one result, with no structure built and no ambiguity. The rule that makes them work:

#emph[In any context that expects one value, extra values vanish.]

```lisp
(floor 7 2)            ; two values: 3 and 1
(+ (floor 7 2) 10)     ; => 13 — + saw only the 3; the 1 vanished
(* 2 (floor 7 2))      ; => 6 — same
(list (floor 7 2))     ; => (3) — the remainder dropped
```

This is why ordinary code can call `floor` inside arithmetic without dismantling anything: the primary value — the first one — is what every ordinary context sees. The extra values exist only for the forms that ask for them.

`values` produces multiple values:

```lisp
(defun divide (a b)
  "Return the quotient and remainder of A divided by B."
  (values (floor a b) (mod a b)))

(divide 7 2)        ; REPL shows both: 3, 1
(+ (divide 7 2) 0)  ; => 3 — the mod vanished
```

The REPL, which wants to show you everything, prints all the values, each on its own line. Other contexts see one.

The truncation isn't a bug in your code; it's the #emph[contract] of "function call arguments are single-valued". `(list (floor 7 2))` doesn't fail to catch `1`; it deliberately discards it, because `list`'s arguments are single-valued slots. Only the forms designed for values catch them all, and the rest of this chapter names those forms.

== Receiving values

`multiple-value-bind` catches values into variables:

```lisp
(multiple-value-bind (q r)
    (floor 7 2)
  (list q r))          ; => (3 1)
```

The syntax mirrors `let`: a list of variables, a form, a body. You don't have to name the values you don't want — bind only the first:

```lisp
(multiple-value-bind (q)
    (floor 7 2)
  q)                   ; => 3
```

`multiple-value-list` collects #emph[everything] into a list — the general-purpose net:

```lisp
(multiple-value-list (floor 7 2))  ; => (3 1)
(multiple-value-list (+ 1 2))      ; => (3) — one value, one-element list
(multiple-value-list (values))     ; => NIL — zero values, empty list
(multiple-value-list (values nil)) ; => (NIL) — one nil value, one-element
```

That last pair is the distinction to keep straight. `(values)` produces #emph[zero] values; `(values nil)` produces #emph[one] value, which happens to be nil. Both look like `nil` in a single-value context, but `multiple-value-list` tells them apart — nil (empty) versus `(nil)` (one element). The exercise section puts this to work; for now, notice that "no value" and "the value nil" are different things, and the empty list is the signal for "no value."

Chapter 13 used `multiple-value-list` for `gethash` without explaining it; now it's explained — the found-flag was kept because the function returns two values:

```lisp
(defparameter *visited* (make-hash-table))

(multiple-value-bind (value found-p)
    (gethash 'kitchen *visited*)
  (if found-p
      value
      "first visit"))
```

The found-flag is the single most useful extra value in Common Lisp, because it resolves the ambiguity `gethash` would otherwise have: a stored `nil` and an absent key both read as `nil` without it.

There's also `nth-value`, which extracts a specific value without binding the others:

```lisp
(nth-value 0 (floor 7 2))   ; => 3
(nth-value 1 (floor 7 2))   ; => 1
(nth-value 2 (floor 7 2))   ; => NIL — no third value
```

It's useful when you know exactly which value you want and the others would just clutter the binding. `(nth-value 1 (gethash k table))` is "just the found-flag, please."

`values-list` is `values` turned inside out — a list in, values out:

```lisp
(values-list '(3 1))                          ; same as (values 3 1)
(multiple-value-list (values-list '(1 2 3)))  ; => (1 2 3)
(multiple-value-list (values-list nil))       ; => NIL — zero values
```

`values` and `values-list` are duals: (values-list (multiple- value-list form)) reconstructs `form`'s values, and `(multiple-value-list (values-list list))` reconstructs `list`. They don't round-trip through any intermediate — each produces what the other consumes, in the appropriate context.

== Single-value and multiple-value contexts

The vocabulary for the vanishing rule: a #emph[single-value context] keeps the primary value; a #emph[multiple-value context] keeps all. The full table, which is the reference to come back to:

#table(
  columns: (6.2fr, 1.8fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Context], [Values kept]),
  [Argument of a function call], [1 (primary)],
  [`let`\/`let*` binding value form], [1 (primary)],
  [`if`\/`when`\/`cond` test form], [1 (primary)],
  [`progn` non-final form (value discarded)], [1 (primary)],
  [Inner `(values ...)` in `values`' args], [1 (primary)],
  [Body's last form of `defun`\/`let`\/`progn`], [all],
  [`multiple-value-bind`'s form], [all],
  [`multiple-value-list`'s form], [all],
  [`multiple-value-call`'s argument forms], [all (each)],
  [`multiple-value-prog1`'s first form], [all],
  [`return`\/`return-from` value form], [all],
)

The table's shape is the lesson: #emph[default behavior is truncation]. Any form that uses its argument's values all does so by explicit design, and the design is visible in the name (`multiple-value-...`) or the position (a body's last form, an exit form).

Two corners worth pointing at:

#strong[The body's last form.] `(defun f () (values 1 2))` returns two values, because the function body's last form is a multiple-value context. Every function you write returns #emph[all values of its last expression], whether you thought about multiple values or not. That's why `(defun g () (f))` passes both values through — `(f)` is the body's last form, hence multiple-value.

`return-from`. `(return-from block (values 1 2))` exits the block with #emph[both] values, and `(multiple-value-bind (a b) (block ...) ...)` catches them. `return` uses the same mechanism (it's `return-from nil`), and `dolist`, `dotimes` and `loop` all establish `nil` blocks, so a `return` with a values form delivers them all:

```lisp
(multiple-value-bind (a b)
    (dolist (x '(1 2 3) (values :done 'three))
      (declare (ignore x)))
  (list a b))    ; => (:DONE THREE)
```

And with `return` mid-loop:

```lisp
(multiple-value-bind (a b)
    (dolist (x '(1 2 3))
      (when (= x 2) (return (values :found x))))
  (list a b))    ; => (:FOUND 2)
```

The `(declare (ignore x))` in the first example is Chapter 21's declaration — the body is empty, `x` is unused, silence the warning.

== `multiple-value-call` and `multiple-value-prog1`

`multiple-value-call` calls a function with #emph[all] values of every argument form appended together:

```lisp
(multiple-value-call #'+ (values 1 2) 3 (values 4 5))
;; => 15 — arguments were 1, 2, 3, 4, 5
```

It is the only ordinary way to #emph[combine] values instead of truncating them, and its commonest use is passing a multiple-valued result onward untouched:

```lisp
(multiple-value-call #'list (floor 7 2))
;; => (3 1) — same as (multiple-value-list (floor 7 2))
```

That identity is worth stating: `(multiple-value-list form)` is equivalent to `(multiple-value-call #'list form)`. Once you see it, "what does `multiple-value-call` do" stops needing a special explanation.

`multiple-value-prog1` evaluates forms and returns the #emph[first one's] values — all of them — unlike `prog1`, which truncates:

```lisp
(defparameter *trace* nil)

(defun floor-and-log (a b)
  "Return FLOOR's two values, logging a trace entry."
  (multiple-value-prog1
      (floor a b)                       ; all its values preserved
    (push (list 'floor a b) *trace*)))  ; side effect only

(multiple-value-list (floor-and-log 7 2))
;; => (3 1)
*trace*   ; => ((FLOOR 7 2))
```

`prog1` would have kept only `floor`'s primary value 3; the remainder would be lost, and the caller catching both values would see `nil` for the second. When the first form might return multiple values and the result matters, `multiple-value-prog1` is the correct spelling.

The pattern `multiple-value-prog1` serves: #emph[do something before returning a multi-valued result, without touching the result]. Logging, tracing, snapshotting — the side effect runs, the values come through untouched.

== Writing functions that return values

Two styles, and choosing well is most of the craft here:

#emph[Values for cheap secondary information.] `floor`'s remainder, `gethash`'s flag, `read-from-string`'s position: things the caller #emph[sometimes] wants, cheap to ignore otherwise. If the caller almost always wants it, make it a primary value or a structure; if almost never, print it or store it.

#emph[Values instead of ambiguity.] The strongest use: `(gethash key table)` distinguishes "stored nil" from "absent", and your own functions can too:

```lisp
(defun lookup-room (name)
  "Two values: the room, and whether it was found."
  (let ((r (find name *rooms* :key #'room-name)))
    (values r (not (null r)))))
```

Callers who don't care about `found-p` write `(lookup-room 'kitchen)` and use the room; careful callers bind both. The function serves both without a keyword argument.

Note what `values` #emph[doesn't] do: it isn't a tuple type. `(values 1 2)` is not an object — there is no way to store "the two values" in a variable; you can only catch them immediately (`multiple-value-bind`) or solidify them (`multiple-value-list`). Passing values through intermediate functions needs the multiple-value forms:

```lisp
(defun floor-with-log (a b)
  (multiple-value-prog1 (floor a b)
    (format *trace-output* "floor ~D ~D~%" a b)))

(defun twice-remainder (a b)
  (multiple-value-bind (q r)
      (floor a b)
    (declare (ignore q))
    (values q (* 2 r))))
```

The first function preserves `floor`'s two values while logging. The second catches both values and emits two of its own, the remainder doubled.

== Common mistakes

=== Assuming (values a b) returns a list

```text
(length (values 1 2))       ; error: 1 is not a list
(append (values 1 2) '(3))  ; error: 1 is not a list
```

Values aren't a datum; `multiple-value-list` is the bridge when you actually want the list. The error message tells you the primary value escaped (as a number) and the list operation got confused — the diagnosis, once you know values exist.

=== Losing values through innocuous forms

`(let ((q (floor 7 2))) ...)` — `q` gets 3; the remainder is gone, silently. Any single-value binding truncates. The fix is `multiple-value-bind` at the point of the call, and the discipline is knowing where values live: only in the form that produced them, until caught or dropped. Once caught into a list or bound into variables, they're ordinary data.

=== return inside dolist that you meant as a single value

```text
(multiple-value-bind (a b)
    (dolist (x '(1 2))
      (return x))
  (list a b))   ; => (1 NIL)
```

The trap isn't the truncation — that's expected, `return`' delivers `x`'s one value, and `b` gets nil. The trap is believing the opposite: some readers think `return` truncates, and test `(return (values 1 2))`, expecting `(1 NIL)`, and are surprised by `(1 2)`. In fact `return` preserves multiple values (as `return-from` does). Knowing this #emph[prevents] a class of bug where you avoid `return` because you think it truncates, when it doesn't.

The genuine trap: `let` binding value forms truncate, and they're common in the code that catches `return`:

```text
(let ((pair (return-from some-block (values 1 2))))
  pair)   ; pair binds 1, not (1 2)
```

`return-from` delivers both values, but `let` keeps one. Use `multiple-value-bind` if you want both.

=== Ignoring the found-flag where it matters

`(gethash 'key table)` returning `nil` means #emph[either] absent #emph[or] stored-nil. Code that treats it as "absent" corrupts tables that legitimately store `nil` values. Wherever `nil` is a meaningful stored value, the two-valued call is not optional.

=== Confusing (values) with (values nil)

```text
(if (multiple-value-list (values)) :present :absent)      ; => :ABSENT
(if (multiple-value-list (values nil)) :present :absent)  ; => :PRESENT
```

Both look like "nothing" in a single-value context — both are `nil` when passed to a function that expects one value. But in a multiple-value context, one returns zero values, the other returns one. The difference is only detectable by the forms designed to detect it — `multiple-value-list`, the count of a bind, and so on.

=== Expecting a toplevel to catch two values

`(defun f () (floor 7 2))`. At the REPL, `(f)` shows 3, 1. But `(mapcar #'f ...)` sees only `3` per call. `mapcar`'s function-call arguments (and results) are single-valued. If you want a mapcar-shaped operation that preserves values, you have to write it (`multiple-value-call` with careful argument plumbing) — there's no "mapcar for values" in the standard.

== Project step: two-valued command dispatch

Chapter 15's `run-command` returns one value: the reply string. When the player types a real command, the reply is "you take the key"; when they type nonsense, the reply is "I don't know how to do that". A caller can't tell those cases apart from the string alone without matching on the text. Multiple values fix this cleanly — every command returns two things: the reply, and whether the command was recognised.

First `call-command`, which knows the difference:

```lisp
(defun call-command (command)
  "Call COMMAND's handler.  Two values: reply, known-p."
  (let ((entry (assoc (first command) *commands*)))
    (if (null entry)
        (values (format nil "No such command: ~(~A~)."
                        (first command))
                nil)
        (values (apply (cdr entry) (rest command))
                t))))
```

Then `run-command`, which wraps it with the failsafe from Chapter 15:

```lisp
(defun run-command (command)
  "Execute COMMAND.  Two values: reply, known-p."
  (restart-case
      (handler-case (call-command command)
        (program-error ()
          (values "Wrong number of arguments for that command." t)))
    (retry-with (fixed)
      :report "Run a corrected command instead."
      (run-command fixed))))
```

The `restart-case` preserves the two values — when the body returns normally, `restart-case` returns all of its values. When `program-error` is caught, the handler returns `(values "..." t)`: the command was known, but the arguments were wrong, so it's flagged as known. That distinction is genuinely useful: "known but failed" and "unknown command" are different failures, and the caller can distinguish them by the second value.

Now `play`, which was `(mapcar #'run-command commands)` returning a list of replies. Updated for two values:

```lisp
(defun play (commands)
  "Run COMMANDS.  Two values: replies, unknown-command list."
  (let ((replies nil)
        (unknown nil))
    (dolist (c commands (values (nreverse replies)
                                (nreverse unknown)))
      (multiple-value-bind (reply known-p)
          (run-command c)
        (push reply replies)
        (unless known-p (push (first c) unknown))))))
```

`dolist`'s result form is `(values ...)`, which returns both lists. Inside the body, `multiple-value-bind` catches each command's two values; the `unless` decides where to file the unknown ones. The `nreverse` preserves order, as usual.

Check it:

```lisp
(setf *current-room* (find-room 'kitchen))
(setf *item-locations* '((key . kitchen)))

(multiple-value-bind (replies unknown)
    (play '((take key) (dance) (look)))
  (list replies unknown))
```

Expected:

```text
(("You take the key."
  "No such command: DANCE."
  "You are in the Kitchen. A warm kitchen that smells of bread. You can see: key.")
 (DANCE))
```

The reply list carries the "No such command: DANCE." string (the player sees it); the unknown list carries `DANCE` (the developer audits it). Both come from the same command, and `play`'s single function call returns both.

Now Exercise 11.12's `count-unknown`, which compared reply strings with `string=` to detect unknowns, becomes honest:

```lisp
(defun count-unknown (commands)
  "How many commands are unknown?"
  (multiple-value-bind (replies unknown)
      (play commands)
    (declare (ignore replies))
    (length unknown)))
```

The string-matching was always a hack — if you changed the message text, the count broke. The two-value contract is what the game meant all along: "was this command known?" is a question the dispatcher can answer, and now it does.

The `(declare (ignore replies))` is Chapter 21's declaration doing its job: the binding exists to consume a value the function doesn't need, and the declaration documents that the non-use is deliberate.

== Exercises

#exercise("24.1")[
  Predict, then check:

  ```text
  (multiple-value-list (values))
  (multiple-value-list (values 1))
  (multiple-value-list (values 1 2 3))
  (+ (values 1 2) (values 3 4))
  (list (values 1 2) (values 3 4))
  (values (values 1 2) (values 3 4))
  ```

]

#exercise("24.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (defun two-things () (values :a :b))
  (let ((x (two-things))) x)

  (multiple-value-bind (a b)
      (loop for i below 3
            finally (return (values :done i)))
    (list a b))

  (let ((table (make-hash-table)))
    (setf (gethash :k table) nil)
    (gethash :k table))

  (defun pass-through (form-values)
    form-values)
  (multiple-value-list (pass-through (values 1 2)))
  ```

]

#exercise("24.3")[
  Write `safe-divide`, which returns two values — the quotient, and `nil` on success or `:division-by-zero` when the divisor is zero (primary value `nil` in that case) — and `safe-sum`, which sums a list of (numerator denominator) pairs using `safe-divide`, and returns `nil` and `t` as two values when any division failed. No conditions: the exercise is doing `gethash`'s flag trick by hand.

]

#exercise("24.4")[
  Write `compose-values`, which takes two functions `f` and `g` (`f` runs first, then `g` gets all of `f`'s values), and returns the composed function. `(funcall (compose-values #'floor #'list) 7 2)` should give `(3 1)`. Which primitive is `compose-values` just `multiple-value-call` for?

]

#exercise("24.5")[
  Write `first-or-default`, which takes a thunk and a default, calls the thunk, and returns its primary value or the default when it returned #emph[zero] values. What does `(multiple-value-list (values))` return, and how does your function detect that case?

]

#exercise("24.6", project: true)[
  The `save-game`\/`load-game` pair (Chapters 16 and 18) currently return one value. Make both two-valued: `save-game` returns `t` and the pathname written (or `nil` and an error description on failure); `load-game` returns the state and a loaded-p flag. Then update the game's `save` and `load` commands to use the second value — no string matching on the error message.

]

