#import "../lib.typ": *

= Conditions II — handler-bind and the Condition Hierarchy

Chapter 15 taught the everyday condition system: `error` and `warn` to signal, `handler-case` to rescue, `restart-case` to offer choices. Two pieces were held back, and they are what separate using the system from understanding it. `handler-bind` runs handlers #emph[without unwinding the stack] — the form `handler-case` itself is built on. And the condition hierarchy — the family tree of condition types — is the map that tells you what you can catch and when.

== The problem with handler-case

`handler-case` unwinds. When a handler runs, the stack between the `handler-case` and the signal site is #emph[gone]: Chapter 15 called this out as a limitation. Mostly it's fine — but three genuinely useful behaviours need to run #emph[before] the unwinding:

- #emph[Logging or reporting an error, then letting it propagate.] `handler-case` can't do this: catching means the error is handled, and re-signalling from the handler is a new error at a new place, with the original stack lost.
- #emph[Silencing a warning.] `warn` prints unless someone handles it first. Suppressing it cleanly requires a handler that runs #emph[while the warning is being signalled], not after.
- #emph[Offering an interactive choice.] Your own code can behave like the debugger: catch everything passing by, ask, decide.

`handler-bind` is the form for all three:

```lisp
(handler-bind (condition-type handler-function)
  body-form...)
```

The syntax difference from `handler-case` is the tell. Handlers are #emph[functions] here, not clauses with recovery code. When a matching condition is signalled, the handler function is called #emph[with the condition] — and where is it called? #emph[At the signal site], with the whole stack still intact, in the dynamic context of the code that signalled. That is the entire difference:

- `handler-case`: unwind to here, then run recovery code.
- `handler-bind`: run this function #emph[there], at the signal site, right now.

After a `handler-bind` handler #emph[returns normally], the signal continues to propagate — the handler looked, didn't handle, and stepped aside. To actually #emph[handle] the condition and stop the propagation, the handler performs a #emph[non-local exit]: usually `invoke-restart`, or `return-from` out of a block around the `handler-bind`.

== handler-bind in action

The canonical example — log and repropagate:

```lisp
(defun log-errors (fn)
  "Run FN, logging any error, letting it propagate."
  (handler-bind
      ((error (lambda (c)
                (format *error-output* "LOG: ~A~%" c)
                ;; no exit: the error keeps going
                )))
    (funcall fn)))
```

The handler runs when the error is signalled — deep in `fn`, with its full context — writes the log line, returns, and the search for a handler continues upward exactly as if this handler weren't there. Layer several:

```lisp
(defun example ()
  (log-errors
   (lambda ()
     (handler-case (/ 1 0)
       (error (c) (format nil "caught: ~A" c))))))

(example)
;; prints: LOG: arithmetic error DIVISION-BY-ZERO signalled
;; returns: "caught: arithmetic error DIVISION-BY-ZERO signalled"
```

The `log-errors` handler saw the error first (it's #emph[below] in the dynamic sense — closer to the signal), logged it, stepped aside, and `handler-case` caught it after the unwind. This is the logging-middleware pattern, and it's only writable with `handler-bind`.

== Muffling warnings

`warn`'s full story, now writable. When `warn` signals, it first looks for handlers of the condition type (usually `warning`). If one #emph[handles] the condition — performs a non-local exit named `muffle-warning` — the warning is never printed:

```lisp
(defun quietly (fn)
  "Run FN with warnings silenced."
  (handler-bind
      ((warning (lambda (c)
                  (declare (ignore c))
                  (muffle-warning))))
    (funcall fn)))

(quietly (lambda () (warn "noise")))
;; returns nil, prints nothing
```

`muffle-warning` is a #emph[restart-invoking function]: it finds the `muffle-warning` restart that `warn` established and invokes it. The warning's own code, `warn`, arranged for this exit route; your handler chose to take it. Chapter 17's `with-quiet-warnings` exercise redirected `*error-output*` instead — a blunt pipe-swap that works but still #emph[signals] and still costs the printing machinery. `handler-bind` with `muffle-warning` is the correct, surgical form: the warning never happens as far as the printer is concerned.

Note the shape of the idiom, because it recurs:

```lisp
(handler-bind ((type (lambda (c) <exit>)))
  body)
```

The handler #emph[must not return] if it means to handle. A handler that falls off the end is abstaining. The exit is the vote.

== The restart functions

Chapter 15 used `invoke-restart` by name. The complete toolkit:

`find-restart` looks up a restart by name, returning it as an object — or `nil` when none is active:

```lisp
(defun restart-active-p (name)
  "Is a restart called NAME active right now?"
  (not (null (find-restart name))))
```

`compute-restarts` returns #emph[all] active restarts — this is literally the list the debugger prints as a menu:

```lisp
(compute-restarts)
;; at the top-level REPL, usually just ABORT-like entries
```

Restart #emph[objects] matter because names alone can be ambiguous: two nested `restart-case` forms can both offer a restart called `retry`, and `find-restart` returns the innermost. Code that means "the restart #emph[I] offered" should hold onto the object:

```lisp
(defun nested-retry-demo (text)
  "Two restart cases, both offering RETRY; show which wins."
  (restart-case
      (restart-case (parse-integer text)
        (retry () :report "Inner retry." :inner))
    (retry () :report "Outer retry." :outer)))
```

`(find-restart 'retry)` from inside `parse-integer`'s signalling dynamic extent sees the #emph[inner] one, because `find-restart` walks the restart stack from the most recently established outward. The debugger's menu shows both; the function call sees one. The full pattern, done cleanly — offer a restart, find it, invoke it by object:

```lisp
(defun parse-with-retry (text)
  "Parse TEXT; a USE-ALIAS restart offers a replacement."
  (restart-case (parse-integer text)
    (use-alias (v)
      :report "Use a substitute value."
      v)))

(defun parse-or (text default)
  "Parse TEXT, or DEFAULT when unparseable — via the restart."
  (handler-bind
      ((parse-error
        (lambda (c)
          (declare (ignore c))
          (let ((r (find-restart 'use-alias)))
            (when r (invoke-restart r default))))))
    (parse-with-retry text)))

(parse-or "42" 0)   ; => 42
(parse-or "nope" 0) ; => 0 — handler invoked the restart
```

Read the division of labour once more, because this chapter's point is that it's now complete: `parse-with-retry` #emph[offers]; the `handler-bind` #emph[decides]; `parse-or`'s caller needs to know nothing. And because the handler ran at the signal site, the restart it invoked was still in scope — a `handler-case` here would have unwound #emph[past] the `restart-case` and lost it. That is the rule of thumb the two chapters add up to:

- Handler needs the #emph[stack below it] (restarts, state, the failing call's context): `handler-bind`.
- Handler only needs to produce a value from `here`: `handler-case`.

== cerror, continue, and the standard restarts

`cerror` is `error` with a built-in `CONTINUE` restart:

```lisp
(defun check-overwrite (path)
  (when (probe-file path)
    (cerror "Overwrite it anyway."
            "File ~A already exists." path)))

(check-overwrite "/tmp/notes.txt")
;; debugger offers CONTINUE; choosing it resumes after the cerror
```

If nobody handles the error, the debugger shows `CONTINUE` with the report string you gave. If a handler catches it, the `continue` function invokes that restart from code:

```lisp
(defun force-lookup (path)
  (handler-bind ((error (lambda (c)
                          (declare (ignore c))
                          (continue))))
    (check-overwrite path)))
```

`continue`, `abort`, `muffle-warning`, `use-value` and `store-value` are functions #emph[and] restart names — the standard vocabulary. Each function invokes the restart of the same name if it exists:

#table(
  columns: (2.0fr, 2.2fr, 3.8fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Function], [Invokes restart], [Established by]),
  [`continue`], [`CONTINUE`], [`cerror`],
  [`abort`], [`ABORT`], [the implementation, always],
  [`muffle-warning`], [`MUFFLE-WARNING`], [`warn`],
  [`use-value`], [`USE-VALUE`], [`restart-case`, your code],
  [`store-value`], [`STORE-VALUE`], [`restart-case`, your code],
)

`with-simple-restart` is the lightweight `restart-case` — one restart, no condition machinery in the common case:

```lisp
(defun load-optional (path)
  (with-simple-restart (skip "Skip loading ~A." path)
    (with-open-file (in path)
      (load in))))

;; A caller can catch a "skip" as a normal nil return:
(handler-case (load-optional "/tmp/absent.lisp")
  (error () "couldn't load"))
;; ...or interactively choose SKIP when the error opens the debugger.
```

When the body fails, the error opens the debugger with `SKIP` among the restarts; choosing it makes `load-optional` return `nil` instead. The function degrades gracefully by construction, and its caller decides interactively.

== The condition hierarchy

Every condition type you've signalled or caught sits in one tree. The spine:

```text
condition
├── serious-condition
│   └── error
│       ├── simple-error
│       ├── type-error
│       ├── program-error
│       ├── control-error
│       ├── parse-error
│       ├── stream-error
│       │   ├── end-of-file
│       │   └── reader-error
│       ├── file-error
│       ├── package-error
│       ├── cell-error
│       │   ├── unbound-variable
│       │   ├── unbound-slot
│       │   └── undefined-function
│       ├── arithmetic-error
│       │   ├── division-by-zero
│       │   ├── floating-point-overflow
│       │   └── floating-point-underflow
│       └── print-not-readable
├── warning
│   └── simple-warning
└── storage-condition
```

Reading the tree as catching rules:

- Catching `error` catches everything on the error branch — which is why Chapter 15 called it a blunt instrument.
- Catching `serious-condition` additionally catches `storage-condition` (memory exhaustion) — almost never what you want; a program out of memory should usually be allowed to die.
- Catching `condition` catches #emph[warnings too] — which you almost never want either: a handler for `condition` with no exit #emph[abstains] on warnings harmlessly, but one with `muffle-warning` would silence everything.
- `cell-error` is the parent of "the name didn't resolve" errors, and its `cell-error-name` slot holds the offending symbol — useful: `(cell-error-name c)` in an `unbound-variable` handler tells you #emph[which] variable.

The `simple-` conditions are the ones `error` and `warn` build when given a format string; their `:format-control` and `:format-arguments` slots were used in Chapter 15's Exercise 15.8.

Signalling a `warning` subtype means `warn`; signalling anything under `error` means `error`; `signal` takes anything under `condition`. Your own `define-condition` types should inherit from `error` (or `warning`) — Chapter 15's `room-not-found` did — so that catch-alls upstream work as expected.

== Common mistakes

=== A handler-bind handler that returns, meaning to handle

```text
(handler-bind ((error (lambda (c)
                        (format t "caught ~A" c))))
  (error "test"))   ; still signals! the handler only observed it
```

Returning is abstaining. To handle, exit: `invoke-restart`, `abort`, `return-from` from an enclosing `block`, or `muffle-warning` for warnings.

=== handler-case where the restart is out of reach

`(handler-case (restart-case (error ...) (r () 1)) (error () (invoke-restart 'r)))` fails: the `error` clause runs #emph[after] the unwind, when the `restart-case` is gone. Invert — `handler-bind` outside the `restart-case` — or restructure so the decision happens inside.

=== Catching storage-condition or condition

A `storage-condition` handler that tries to log or free things is running in a nearly dead image; let it terminate. And a `condition` catch-all silently changes warning semantics. Catch `error` when you must catch broadly, and narrowly above that.

=== Confusing muffle-warning with redirecting #strong[error-output]

Redirecting the stream still pays for formatting and still lets the signal propagate as an event; `muffle-warning` stops both. For silencing, the restart is the right tool; for #emph[capturing], the stream is.

== Project step: a warning layer for the game

The game's `doctor` command (Chapter 19's own predecessor — the diagnostics command you'll meet again in Part V) reports problems on demand. This step adds #emph[passive] diagnostics: functions in the game warn (not error) when they notice drift, and the top-level runner can silence or capture them.

```lisp
(define-condition game-drift (warning)
  ((what :initarg :what :reader game-drift-what))
  (:report (lambda (c stream)
             (format stream "Game drift: ~A" (game-drift-what c)))))

(defun note-drift (what)
  "Announce a consistency problem without stopping play."
  (warn 'game-drift :what what))
```

A check inside `go-to`: when the player tries to move to a room that the current room's exits mention but `find-room` can't find, the room list has drifted from the exits lists:

```lisp
(defun go-to (name)
  "Move the player to the room called NAME, if it is an exit."
  (cond ((eq name (room-name *current-room*))
         "You are already there.")
        ((not (member name (room-exits *current-room*)))
         "You can't go there from here.")
        ((null (find-room name))
         (note-drift
          (format nil "exit ~(~A~) from ~(~A~) names no room"
                  name (room-name *current-room*)))
         "You can't go there from here.")
        ((room-locked (find-room name))
         (format nil "The ~(~A~) is locked." name))
        (t
         (setf *current-room* (find-room name))
         (look))))
```

The warning fires #emph[and] play continues — that's the point of using `warn` instead of `error` for a data-integrity check: the player sees "can't go there" and play goes on; the developer sees the drift warning and knows to fix `*rooms*`.

Now a runner that logs every drift, play continuing regardless — the `handler-bind` logging pattern, applied:

```lisp
(defun play-logged (commands)
  "Run COMMANDS; return (VALUES replies drifts)."
  (let ((drifts nil))
    (handler-bind
        ((game-drift
          (lambda (c)
            (push (game-drift-what c) drifts)
            (muffle-warning))))
      (let ((replies (mapcar #'run-command commands)))
        (values replies (nreverse drifts))))))
```

The handler does two things — it captures the drift text into a list, then muffles the warning so `warn` doesn't also print it. Both actions are deliberate: capture for the caller, muffle for quiet. Without the `muffle-warning`, the warning would print after the handler ran, and the whole point of `play-logged` (no noise on the terminal) would be lost. This is the capture-and-silence idiom — the common case for "log the warning but don't show it".

Check:

```lisp
(defparameter *rooms*
  (list
   (make-room :name 'kitchen
              :exits '(hallway nowhere)
              :description "Pots and pans.")
   (make-room :name 'hallway
              :exits '(kitchen)
              :description "A long corridor.")))
(setf *current-room* (find-room 'kitchen))

(multiple-value-bind (replies drifts)
    (play-logged '((look) (go nowhere) (go hallway)))
  (list replies drifts))
```

Expected:

```text
(("Pots and pans."
  "You can't go there from here."
  "You are in the Hallway. A long corridor.")
 ("exit nowhere from kitchen names no room"))
```

The middle command triggered the drift warning; the replies list carries its player-facing "can't go there"; the drifts list carries the developer-facing note. Both survived, the terminal showed nothing, and the third command confirmed play went on.

Notice what the game's state looks like at the end of this step: `*rooms*` holds a room whose exits point at `nowhere`, and nothing broke. That's the difference between a `warn`-driven check and an `error`-driven one: with `error`, `(go nowhere)` would have opened the debugger and stopped the session, and the design of `go-to` would have to catch and translate that. With `warn` and a handler that muffles, the diagnosis is captured and the game keeps playing. The next chapter, on the reader, will use the same pattern for file-integrity checks — the same `game-drift` shape, applied to reads.

== Exercises

#exercise("19.1")[
  Predict, then check, and explain the difference in one sentence:

  ```text
  (handler-case (error "boom") (error (c) 'caught))

  (block out
    (handler-bind ((error (lambda (c) (return-from out 'caught))))
      (error "boom")))
  ```

]

#exercise("19.2")[
  Write `with-suppressed-warnings`, a function taking a thunk, that runs it with all warnings muffled — using `handler-bind` and `muffle-warning`. Then a variant `with-captured-warnings` that returns the list of warning #emph[texts] alongside the thunk's values.

]

#exercise("19.3")[
  Each snippet is wrong. Say what happens, then fix it.

  ```text
  (handler-bind ((error (lambda (c) (format t "~A" c))))
    (error "propagate?"))

  (handler-case (restart-case (error 'room-not-found :name 'attic)
                  (substitute-room () 'kitchen))
    (room-not-found () (invoke-restart 'substitute-room)))

  (warn "quiet") ; caller wants silence, wrote:
  (handler-case (warn "quiet") (warning (c) nil))
  ```

]

#exercise("19.4")[
  Using the hierarchy table: name the narrowest condition type to catch for each situation, and say what slot or accessor gives the useful detail.

  ```text
  a) A user-typed number failed to parse.
  b) A file the config mentions may not exist.
  c) A symbol name from a save file has no value bound.
  d) Reading a save file ran past the end.
  e) The game called a function with the wrong argument count.
  ```

]

#exercise("19.5")[
  Write `invoke-if-found`, which takes a restart name and optional arguments, and invokes the restart if it's active — returning :inactive otherwise, without signalling. What makes `find-restart` + `invoke-restart` two steps instead of one, and when does the gap matter?

]

#exercise("19.6", project: true)[
  The `cerror` pattern fits the game's `take`: taking an item that's not here is currently a polite string. Change `take` to `cerror` on a missing item with a "Take it anyway" restart that adds the item regardless, and write `cheat-take`, which catches the error and invokes `continue`. Then defend in a comment: why is a restart better here than a `:force` keyword argument?

]

