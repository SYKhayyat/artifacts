#import "../lib.typ": *

= Closures as Objects

Chapter 9 introduced closures with `make-adder` and `make-counter`: functions that remember the `let` variables they were born next to. That was a first pass, enough to use `lambdas` as callbacks. This chapter develops closures into what they really are — #emph[Lisp's objects, before CLOS objects] — with three new ideas: what exactly is captured, how several closures can share one environment, and where closure state beats `defparameter` state.

== What is captured, precisely

When a `lambda` references a variable from an enclosing scope, it captures the #emph[binding] — the variable itself, not the value at creation time:

```lisp
(defun make-counter ()
  (let ((count 0))
    (lambda ()
      (incf count))))

(defparameter *c* (make-counter))
(funcall *c*) ; => 1
(funcall *c*) ; => 2
(funcall *c*) ; => 3
```

The counter keeps counting because `count` is a live binding that outlived the `let` that created it. This is the defining property of lexical closures: the binding's extent extends as long as any closure can reach it. Contrast the value-capture instinct:

```lisp
(defun make-counters-wrong ()
  (let ((count 0))
    (list (lambda () count)
      (lambda () (incf count)))))

(defparameter pair (make-counters-wrong))
(funcall (first pair)) ; => 1 — sees the increment...
(funcall (second pair)) ; => 2
(funcall (first pair)) ; => 2 — the SAME binding
```

Both closures share one `count`, so the "reader" sees every increment. If you wanted independent copies, each closure needs its own binding — which is the next section's subject.

== Constructors: closures born in a loop

`dotimes` and `dolist` introduce fresh bindings #emph[per iteration], so closures created inside a loop each capture their own variable:

```lisp
(defun make-bumpers (limit)
  "A list of closures; the i-th adds i."
  (loop for i from 1 to limit
    collect (lambda (x) (+ x i))))

(defparameter bumpers (make-bumpers 3))
(mapcar #'funcall bumpers (list 100 100 100))
;; => (101 102 103) — three separate bindings
```

No capture-in-a-loop bug in Common Lisp's case here — each iteration binds a new `i`. (In languages with per-function variable binding, this example is the classic trap; in Lisp the loop's binding is per-iteration by specification, and `loop`'s `for` clauses too.) The corresponding #emph[real] trap in Lisp is different, and covered in Common mistakes below: capturing the #emph[loop variable of a surrounding function] instead of the loop's own binding.

== Shared environments: objects from closures

The step beyond `make-counter`: return #emph[several] closures that share one set of bindings. That shared set is private state with no name anyone else can touch — in one word, #emph[encapsulation], achieved with nothing but `let` and `lambda`:

```lisp
(defun make-account (balance)
  "A bank account as three closures over one binding."
  (values
    (lambda (amount) ; deposit
      (setf balance (+ balance amount)))
    (lambda (amount) ; withdraw
      (if (> amount balance)
        (error "Insufficient funds: ~A < ~A" amount balance)
        (setf balance (- balance amount))))
    (lambda () balance))) ; balance

(multiple-value-bind (deposit withdraw balance)
  (make-account 100)
  (funcall deposit 50)
  (funcall withdraw 30)
  (funcall balance)) ; => 120
```

Nothing outside the three closures can read or write `balance` — not by `symbol-value`, not by any accessor, because it isn't a slot anywhere; it's a variable that exists only in their shared lexical world. Compare the CLOS version you'll write in Chapter 26: a class with a `balance` slot is the same design, with the closures replaced by methods and the `let` replaced by the instance. Neither is better; the closure version has no class to define, the class version has `print-object`, inheritance and redefinition support. For small, fixed, use-and-forget state, closures are lighter.

A dispatch-table variant — one closure, behaviour chosen by message — is the style that grew into "generic functions" in other languages:

```lisp
(defun make-registry ()
  (let ((table (make-hash-table)))
    (lambda (message &optional key value)
      (ecase message
        (:put (setf (gethash key table) value))
        (:get (gethash key table))
        (:keys (loop for k being the hash-keys of table
            collect k))))))

(defparameter reg (make-registry))
(funcall reg :put 'key "brass")
(funcall reg :get 'key) ; => "brass"
(funcall reg :keys) ; => (KEY)
```

The hash table is invisible to callers; the closure is the only door. Add a `:count` message later and no caller changes.

== Closures vs defparameter state

The earmuffed globals you've used since Chapter 4 are #emph[process-wide] state. Closure state is #emph[instance] state: call `make-counter` twice and you have two independent counters, whereas two uses of a `defparameter` counter are one counter.

The rule of thumb:

One of something for the whole program (the game's `rooms`, `commands`): a `defparameter`. Global by intent.

A third use, small and constant in real code: closures as #emph[parameterised behaviour]. Chapter 9's `make-adder` is the seed; `remove-if` takes a predicate, and building that predicate on the fly is the daily use:

```lisp
(defun name-matcher (target)
  (lambda (room) (eq (room-name room) target)))

(remove-if (name-matcher 'kitchen) rooms)
```

The `lambda` captures `target`; the predicate is data and behaviour in one argument. No class, no global, no coupling.

== Common mistakes

=== Capturing the wrong variable in a loop

```text
(let ((fns nil))
(dolist (x '(a b c) (nreverse fns))
(push (lambda () x) fns)))

(mapcar #'funcall **) ; => (A B C) — fine, dolist binds per iteration
```

The genuine trap is when the `lambda` references an #emph[outer] function's parameter instead of the loop's variable — then every closure sees the same (final or only) argument value. When closures over loop variables misbehave, check which binding each free variable names.

=== Closure state and save files

Closure bindings are invisible to `print`, `read` and `save-game`: there is no object to serialise. State that must survive belongs in structures, alists and hash tables reachable from named variables. Closures for #emph[session-lifetime] state — counters, iterators, per-connection handles.

=== funcall amnesia

A closure is a function object; `(make-counter)` alone creates it and throws it away. `setf` it, pass it, store it in a table — but if nobody holds it, its bindings die with it. The `make-account` example only works because `multiple-value-bind` kept all three closures; keeping one and dropping the others orphaned their shared world.

=== Overusing closures for big state

Once a closure-based "object" grows past four or five messages, or needs `print-object`, inheritance, or redefinition during development (Chapter 22's workflow), move it to `defclass`. Closures excel small; classes scale.

== Project step: a command-history object

Chapter 14's `history` is a plain list of alist snapshots, managed by the global `snapshot` and `undo` functions. This step wraps history in a closure object — private state, three operations, no global except the single handle.

```lisp
(defun make-history ()
  "A bounded command history: :add, :recent, :clear, :undo-to."
  (let ((snapshots nil)
      (limit 20))
    (lambda (message &optional arg)
      (ecase message
        (:add
          (push arg snapshots)
          (when (> (length snapshots) limit)
            (setf snapshots (subseq snapshots 0 limit)))
          t)
        (:recent
          (subseq snapshots 0 (min (or arg limit)
              (length snapshots))))
        (:undo-to
          (when snapshots
            (let ((s (first snapshots)))
              (pop snapshots)
              s)))
        (:clear
          (setf snapshots nil)
          t)))))
```

Replace the global-history versions from Chapter 14:

```lisp
(defparameter history (make-history))

(defun snapshot ()
  "Record the current item locations for undo."
  (funcall history :add (copy-alist item-locations)))

(defun undo ()
  "Restore the item locations from before the last move."
  (let ((s (funcall history :undo-to)))
    (if s
      (progn
        (setf item-locations s)
        "Undone.")
      "Nothing to undo.")))
```

The signatures of `snapshot` and `undo` are unchanged from Chapter 14 — callers of these functions don't need to know that the storage moved from a global list to a closure. That is the #emph[encapsulation] the chapter promised: private state, public interface, no change to the interface.

Check:

```lisp
(setf current-room (find-room 'kitchen))
(setf item-locations '((key . kitchen)))

(snapshot)
(setf item-locations (set-location item-locations 'key 'player))
(undo)
(item-location 'key) ; => KITCHEN
```

The `limit` trimming keeps the history bounded without any caller knowing. Note what the design avoids: `history` entries never reach `save-game` (they're closure state, by design — a fresh session starts with empty history), and no other code can reach in and mangle the list, because there is no list to reach — only the four messages. If a future chapter wants history to #emph[survive] saves, that's the signal to convert this object to a `defclass` with a serialisable slot — and the class version's save-game support would need to expose the snapshots list, which is exactly the trade the chapter warned about.

== Exercises

#exercise("25.1")[
  Predict, then check:

  ```text
  (let ((fns (loop for i from 1 to 3
  collect (lambda () i))))
  (mapcar #'funcall fns))

  (defun make-two ()
  (let ((n 0))
  (values (lambda () (incf n))
  (lambda () (decf n)))))
  (multiple-value-bind (up down) (make-two)
  (list (funcall up) (funcall up) (funcall down) (funcall up)))

  (let ((x 10))
  (let ((f (lambda () x)))
  (setf x 99)
  (funcall f)))
  ```

]

#exercise("25.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (defun make-accumulator ()
  (lambda (n) (setf total (+ total n))))
  (funcall (make-accumulator) 5)

  (defparameter counters
  (loop for name in '(a b c)
  collect (list name (let ((count 0))
  (lambda () (incf count))))))
  (funcall (second (first counters)))

  (let ((fns nil))
  (dotimes (i 3)
  (push (lambda () i) fns))
  (mapcar #'funcall fns))
  ```

]

#exercise("25.3")[
  Write `make-average`, returning a single closure that takes a number and returns, as two values, the running average and the running count. Then extend `make-registry` (from the chapter) with a `:count` message — how many keys it holds — without changing any existing caller.

]

#exercise("25.4")[
  Write `make-stack`, returning four closures (`push!`, `pop!`, `empty-p`, `contents`) sharing one list binding. `pop!` should signal an error on underflow, and `contents` should return a copy of the list. What does returning a copy teach about encapsulation vs leaking?

]

#exercise("25.5")[
  Chapter 10's `remove-duplicates` uses `eql` by default. Write `make-key-matcher`, which takes a `:key` function and a target value and returns a predicate suitable for `find-if`. Then use it to find a room by name without writing an inline `lambda`. Compare with the chapter's `name-matcher`: which one generalises, and why?

]

#exercise("25.6", project: true)[
  Wrap the game's item-taking in a closure-based #emph[cooldown]: a `make-cooldown` object with `:block` (records a command and answers whether the same command came within the last two calls) and `:reset`. Wire it into `run-command` so repeated identical commands get the reply "Not again." instead of executing. In a comment: is cooldown state (a) session state like history, or (b) persistent state like item locations — and what decides the answer?

]

