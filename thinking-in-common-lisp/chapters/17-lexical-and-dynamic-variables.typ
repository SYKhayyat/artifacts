#import "../lib.typ": *

= Lexical and Dynamic Variables

Chapter 9 gave you closures: functions that remember the `let` variables around them. That memory works because of #emph[lexical scoping], and it is half of Lisp's binding story. The other half — #emph[dynamic scoping], the story behind the earmuffed names like `*print-readably*` and `*package*` — has been used quietly for chapters. This chapter makes both halves explicit and shows how they fit together.

== Lexical scope: where a name lives in the text

Lexical scope is scope by #emph[position in the source code]. When you write:

```lisp
(defun make-adder (n)
  (lambda (x) (+ x n)))
```

the `n` inside the lambda is meaningful because the lambda is written `inside` `make-adder`'s parameter list. Where a variable can be seen is determined by where it appears in the text — by the nesting of forms — not by anything that happens at run time.

That is the only kind of scope you've met so far, and it is the only kind Java and Python have. Two consequences worth stating plainly, because Chapter 9 used them without naming them:

- #emph[Closures close over the binding, not the value.] The lambda keeps a live reference to `n`'s binding; if the binding is later changed with `setf`, the closure sees the change (the `make-counter` example).
- #emph[Each call makes new bindings.] Calling `make-adder` twice gives two independent `n`s, each closed over by its own lambda. This is why closures can be used as private state.

== Dynamic scope: where a name lives in time

Now a second kind of binding. Every variable defined with `defvar` or `defparameter` is a #emph[dynamic variable] (also called a #emph[special variable] — the terms are interchangeable; `special` comes from `declare (special ...)`, below). You've made many of them for the game:

```lisp
(defparameter *current-room* nil)
(defparameter *item-locations* nil)
```

A dynamic variable has a #emph[global] value, but — and this is the part that takes getting used to — its meaning at any moment is #emph[whoever has most recently bound it while running]. A `let` on a dynamic variable doesn't make a private variable: it temporarily #emph[replaces] the global value for the duration of the `let` body, and restores it afterwards:

```lisp
(defparameter *noise-level* 0)

(defun shout ()
  (format t "noise level: ~D~%" *noise-level*))

(defun loudest ()
  (let ((*noise-level* 11))
    (shout)))

(defun example ()
  (shout)          ; prints: noise level: 0
  (loudest)        ; prints: noise level: 11
  (shout))         ; prints: noise level: 0  — restored
```

The `shout` function never takes an argument and never reads a lexical `*noise-level*`; it reads #emph[whatever binding is in force when it runs]. Inside `loudest`, the `let` has pushed a new binding onto `*noise-level*`, and everything `loudest` calls — however many functions deep — sees it. When `loudest` returns, the binding is popped and the old value is exactly as it was.

This is scope in #emph[time] rather than scope in #emph[text]: a dynamic variable's extent is the dynamic extent of the form that bound it. Chapter 15 said "the restart lives while the `restart-case` form runs — its dynamic extent". Same phrase, same idea; now you know it applies to variables too, and that `restart-case`'s visibility to `invoke-restart` is dynamic scoping in action.

== Why earmuffs: the naming rule

The asterisks — "earmuffs" — are not decoration; they are the community's marking for "this variable is dynamic". The rule they encode:

- A dynamic variable's name #emph[should] have earmuffs. Reading `*noise-level*`, you know its value depends on who called you.
- A lexical variable's name #emph[should not]. Reading `noise-level`, you know it's a local or parameter, entirely under your function's control.

The convention matters because the two kinds of variable fail in different ways, and the name tells you which failure mode to expect. A lexical can be shadowed by accident (Chapter 4); a dynamic can be #emph[rebound] by any caller up the stack. Several existing earmuffed names from the chapters — `*package*`, `*print-readably*`, `*error-output*` — are dynamic variables defined by the implementation, and their earmuffs are the same signal: "any code you call can change what this means to you, and the polite way to change it for your callees is to `let` it".

Why did Chapter 4 use `defparameter` for game state? Because the game's state #emph[is] dynamic by nature: `look`, `take` and `inventory` all read `*current-room*` and `*item-locations*` without them being passed, and the whole program is a family of functions sharing that state. This is the honest use of dynamic variables: #emph[global configuration and state that many functions share], especially when you sometimes want to change it for a whole subtree of calls — which is exactly what Chapter 23's `let ((*save-file* ...))` around a test will do.

== defvar vs defparameter, properly

Chapter 4 noted the mechanical difference; the real difference is about #emph[initialisation intent]:

- `defparameter` assigns the value #emph[every time the form runs]. Loading the file twice, or C-c C-c on the line, resets the variable. Right for values you're actively developing — the game's state, whose reset-on-reload is a feature while you iterate.
- `defvar` assigns #emph[only if the variable is unbound]. Reloading the file leaves an existing value alone. Right for values the #emph[user] of your code might have changed — configuration like `*save-file*` that should survive a reload, and values a library defines but expects callers to customise.

This is why libraries use `defvar` for their knobs:

```lisp
(defvar *default-save-file* "/tmp/game-save.lisp"
  "Overridden by callers who want a different path.")

(defun save-to-default ()
  (with-open-file (out *default-save-file*
                       :direction :output
                       :if-exists :supersede)
    (print (game-state) out)))
```

A caller redefining `*default-save-file*` with `defparameter` in their own file keeps their setting across reloads of the library. With `defparameter` in the library, every reload would trample it.

One subtlety worth knowing: `defvar` also #emph[declares the name special] — this is how a variable becomes dynamic. The declaration sticks to the name globally, for good. That leads to the trap below.

== Binding vs assignment

The distinction that untangles most dynamic-variable confusion:

- #emph[Binding] creates a new place for the name: `let`, `defparameter`, function parameters all bind.
- #emph[Assignment] changes an existing place: `setf` assigns.

On a #emph[lexical] variable, the difference is barely visible: `let` binds, `setf` assigns, and nothing else can see either from outside. On a #emph[dynamic] variable, the difference is everything:

```lisp
(defparameter *x* 1)

(defun reader ()
  *x*)

(defun assigner ()
  (setf *x* 2))

(defun binder ()
  (let ((*x* 3))
    (reader)))

(list (reader)      ; => 1
      (progn (assigner) (reader))  ; => 2  — assignment changed the global
      (binder))     ; => 3  — binding shadowed it, only during the let
```

The `binder` case is the one to internalise: `let` on a dynamic variable is not "make a local `*x*`" but "temporarily change `*x*` for everyone I call". Chapter 18's exercise used exactly this to redirect warnings: `(let ((*error-output* ...)) ...)` — a binding, not an assignment, so the rest of the program was unaffected after the `let` ended.

== The dynamic variable toolkit

The remaining pieces, for completeness and for the rare times you need them:

`symbol-value` reads a dynamic variable's current value when you have the #emph[name] as an object rather than in code:

```lisp
(symbol-value '*x*)          ; the same as (the value of *x*)
(setf (symbol-value '*x*) 9) ; assignment by name
```

This is how code can work on variables as data — a configuration system can look up `*default-save-file*` from a string in a file. It only works for dynamic variables: lexical variables have no symbol home to look up, which is precisely what makes them unreachable from `symbol-value`.

`set` is the ancestor of `setf`: it assigns a dynamic variable by name, `(set '*x* 5)`. Old code uses it; new code uses `setf` on `symbol-value` if it means this. Know it when you read it.

`makunbound` removes a dynamic variable's global value — Chapter 9 met it as a debugging tool. Afterwards the variable is #emph[unbound], not `nil`: reading it signals `unbound-variable`, and `(boundp '*x*)` asks before reading.

`progv` binds dynamic variables by name at run time — the deepest end of this toolkit, and rare:

```lisp
(progv (list '*x*) (list 42)
  *x*)    ; => 42, with *x* dynamically bound for the body
```

You'll meet it in code that interprets other Lisp code. Note what it can do that `let` cannot: the variable names don't have to be written in your source; they can be computed.

`(declare (special x))` is the manual switch that makes a name dynamic where no `defvar` has run. You should #emph[not] need it — if you find yourself writing it, what you almost certainly want is a `defvar`. It exists for reading other people's code and for rare binding tricks; the habit to avoid is defining ordinary-looking variables with it, because the declaration leaks past lexical boundaries in confusing ways.

== The standard dynamic variables you'll actually use

A short list, since you've used half of these already and knowing them as a family helps:

#[
  #set par(justify: false)
  #table(
    columns: (1.7fr, 5.2fr, 1.0fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Variable], [Meaning], [Used in]),
    [`*package*`], [the current package — affects how names are read], [16],
    [`*standard-output*`], [where `format t`, `princ` and friends write], [12],
    [`*error-output*`], [where `warn` writes], [18],
    [`*print-readably*`], [print output that `read` can rebuild], [18],
    [`*print-length*`], [cap on list length printed (nil = unlimited)], [this ch.],
    [`*print-level*`], [cap on nesting depth printed], [this ch.],
    [`*read-base*`], [what number base `read` assumes], [this ch.],
    [`*features*`], [the list of implementation feature symbols], [App. A],
    [`*load-pathname*`], [the file being `load`ed, if any], [this ch.],
    [`*debugger-hook*`], [a function to call instead of the debugger], [this ch.],
  )
]

Two examples of the `let` pattern in daily use. Printing large data without flooding the screen:

```lisp
(defparameter *big-list* (loop for i below 100 collect i))
(let ((*print-length* 10)
      (*print-level* 3))
  (print *big-list*))
;; (0 1 2 3 4 5 6 7 8 9 ...) — ten elements, then ellipsis
```

And sending one function's output to a string instead of the terminal (Chapter 18's `with-output-to-string` is this pattern, prepackaged):

```lisp
(with-output-to-string (s)
  (princ *noise-level* s))
;; => "0"
```

== Lexical and dynamic together: which one wins

When a name could be both — say a `let` on a name that happens to be `defvar`'d — #emph[dynamic wins]: the `defvar` makes every binding of that name dynamic, even `let` bindings and even function parameters. That is the trap:

```lisp
(defvar *acc* nil)

(defun process (list)
  ;; DANGER: *acc* is dynamic, so this let is a global
  ;; temporary change, and nested/reentrant calls share it!
  (let ((*acc* nil))
    (dolist (x list)
      (push x *acc*))
    (nreverse *acc*)))
```

For this function it happens to work — but if two calls to `process` nest (because something in the `dolist` calls `process` again), they #emph[share the same binding], and the inner call's `pops` wreck the outer's accumulator. A lexical `let` would have given each call its own. The rule:

- Loop accumulators, temporary results, anything private to one call: #emph[lexical] names without earmuffs.
- Shared state and configuration deliberately spanning calls: #emph[dynamic] names with earmuffs.

The earmuff convention isn't just style; it's how you keep the two categories from colliding in the same name.

== Common mistakes

=== Earmuffs without defvar\/defparameter

```text
(setf *result* 42)   ; *result* was never defined
```

This works — `setf` on an undefined name creates a global — but the variable is not declared special, so it is a plain global, and warnings about it appear. Worse, if some other file later runs `(defvar *result*)`, the name becomes dynamic and #emph[every existing `let` on it changes meaning]. Always create dynamic variables with `defvar` or `defparameter`, never bare `setf`.

=== Rebinding a special by parameter

```text
(defun draw-room (*current-room*) ...)
```

Since `*current-room*` is special, this parameter doesn't shadow it lexically — it dynamically #emph[rebinds] it for the duration of the call, and everything the function calls sees the new room. That may even be what you want, but it is never what it looks like to a Java-trained eye. Keep parameters unearmuffed.

=== Assuming let restores after setf

`(let ((*x* 1)) (setf *x* 2))` leaves the #emph[global] `*x*` as it was — the `let` bound it, `setf` assigned to the binding, and the binding dies at the `let`'s end. But `(progn (setf *x* 2) ...)` with no `let` changed the global for good. If your test suite changes a knob with `setf` and doesn't restore it, later tests run with the changed value: bind with `let` around each test instead of assigning.

=== Reading #strong[print-length] as a bug

When a printed list shows `(a b c ...)`, that's `*print-length*` abbreviating, not data missing. Check whether something bound the print variables.

== Project step: configurable output

The game's messages go to the terminal by `format t`. Making the game testable and scriptable means sending them #emph[somewhere else] — a string, a file — without touching the message functions. Dynamic variables are the tool:

```lisp
(defparameter *game-output* t
  "Where game messages go: t for the terminal, or a stream.")

(defun say (control &rest args)
  "The game's single output function."
  (apply #'format *game-output* control args))

(defun sayln (control &rest args)
  "Like SAY, with a newline."
  (apply #'format *game-output*
         (concatenate 'string control "~%") args))
```

Now every message function calls `say` instead of `format t`, and capturing a whole session of play is one `let`:

```lisp
(defun play-to-string (commands)
  "Run COMMANDS, capture all game output in a string."
  (with-output-to-string (s)
    (let ((*game-output* s))
      (dolist (c commands)
        (sayln "~A" (run-command c))))))
```

Check:

```lisp
(setf *current-room* (find-room 'kitchen))
(setf *item-locations* '((key . kitchen)))

(play-to-string '((look) (take key)))
```

Expected: one string holding the look text and the take text — with nothing printed to the terminal, because `*game-output*` was dynamically bound to the string stream for the duration. Note the shape: `say` and the message functions needed no changes; the #emph[configuration] was rebound from outside. That is the dynamic variable's whole job description.

And the test-suite payoff (Chapter 23's harness gets stronger):

```lisp
(defun look-mentions-room-p ()
  "Does the look command's output name the current room?"
  (search "kitchen"
          (string-downcase
           (with-output-to-string (s)
             (let ((*game-output* s))
               (run-command '(look)))))))
```

== Exercises

#exercise("17.1")[
  Predict the three printed lines, then check:

  ```text
  (defparameter *depth* 0)

  (defun show () (format t "~D " *depth*))

  (defun nest (n)
    (let ((*depth* (1+ n)))
      (show)
      (when (< n 2) (nest (1+ n)))
      (show)))

  (nest 0)
  ```

]

#exercise("17.2")[
  Write `with-temp-room`, a function taking a room name and a function, which runs the function with `*current-room*` dynamically bound to that room, restoring the room afterwards even if the function signals. (Two chapters' tools combine here: `let` plus `unwind-protect` — or explain why plain `let` already restores it.)

]

#exercise("17.3")[
  Each snippet below is wrong or misleading. Say what actually happens, then fix it.

  ```text
  (setf *counter* 0)
  (defun bump () (incf *counter*))

  (defun loud-say (text)
    (setf *game-output* (make-string-output-stream))
    (format *game-output* "LOUD: ~A" text))

  (defvar name nil)   ; intended as a per-call local
  ```

]

#exercise("17.4")[
  Write `symbol-value` based lookup: `config-value` takes a string like `"*SAVE-FILE*"` and returns the current value of the dynamic variable it names, or `:unknown` when no such variable is bound. Use `intern`, `boundp` and `symbol-value`. What does your function return for `"CAR"`, and why?

]

#exercise("17.5")[
  Predict, then check:

  ```text
  (defvar *log* '())

  (defun log-it (x) (push x *log*))

  (defun phase-one ()
    (let ((*log* nil))
      (log-it 'a)
      (log-it 'b)))

  (phase-one)
  *log*
  ```

  Where did `a` and `b` go? What name change makes the two `log-it` calls write to the global log instead?

]

#exercise("17.6")[
  Using `*print-length*` and `*print-level*`, write `terse`, which takes any object and returns its printed form capped at 5 elements and 2 levels of nesting. Test it on a deeply nested list.

]

#exercise("17.7", project: true)[
  Add a `verbosity` knob: `defparameter *verbose* nil`, and make `take` and `drop` emit extra `say` messages only when `*verbose*` is true. Write `play-quietly`, which runs a command list with verbosity off no matter what it was outside, and `play-loudly`, which forces it on. Then explain in a comment why `say` needed to exist as a wrapper before this exercise could be done cleanly.

]

