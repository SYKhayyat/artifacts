#import "../lib.typ": *

= Iterators and Generators

Chapter 25 built closures with private state. Chapter 24 made functions return several values. Put the two together and you get an idea Lisp handles without any library: a #emph[generator] — a function that produces a stream of values one at a time, remembering where it left off. This chapter builds them by hand, uses them for lazy processing, and looks at the one widespread library approach (`series`) — with an honest word about when ordinary eager lists remain the right answer.

== Why generators exist

Chapter 10's sequence functions all build complete results. `mapcar` over a million-element list allocates a million-element list before returning. `remove-if` walks the whole input before returning. `reduce` is better — it collapses to one value — but it still needs the input to exist.

For many problems that's fine: the data is already in memory, the collection fits, and eager processing reads clearly. But for three categories of problem, eager processing either doesn't fit or wastes work:

The generator pattern is the closure-based answer. It isn't the only answer (SBCL has full call\/cc via `cl-cont`, and the `series` library compiles generator chains to loops), but it's the one you can build with Chapters 24 and 25 and the one every Lisp programmer should be able to write from memory.

== A generator from closures and values

The simplest generator counts:

```lisp
(defun make-counter-gen (start)
  "A generator of successive integers, starting at START."
  (let ((n start))
    (lambda ()
      (values (incf n) t))))
```

```lisp
(defparameter next (make-counter-gen 0))
(multiple-value-list (funcall next)) ; => (1 T)
(multiple-value-list (funcall next)) ; => (2 T)
(multiple-value-list (funcall next)) ; => (3 T)
```

Two values, following Chapter 24's flag pattern: the item, and "there is one". The flag is always `t` here — this generator is infinite — but the protocol requires it, because generators can end, and the caller must be able to tell.

The protocol, stated precisely:

Calling it returns #emph[two values]: the next item, and a flag.

Flag `t` means "an item was produced".

Flag `nil` means "the generator is exhausted" — the item value is undefined (usually `nil`, but callers shouldn't read it).

Once exhausted, a generator stays exhausted — calling it again returns `(nil nil)`.

A generator over a list:

```lisp
(defun make-list-gen (list)
  (lambda ()
    (if list
      (values (pop list) t)
      (values nil nil))))
```

```lisp
(defparameter *g* (make-list-gen '(a b c)))
(multiple-value-list (funcall *g*)) ; => (A T)
(multiple-value-list (funcall *g*)) ; => (B T)
(multiple-value-list (funcall *g*)) ; => (C T)
(multiple-value-list (funcall *g*)) ; => (NIL NIL) — exhausted
(multiple-value-list (funcall *g*)) ; => (NIL NIL) — stays exhausted
```

`pop` on the captured binding — the generator #emph[consumes] the list it holds, one `funcall` per step, state held nowhere but in the closure (Chapter 25's encapsulation, again). The fifth call is the protocol's stickiness: exhausted generators don't come back to life.

== map-gen: processing lazily

Chapter 10's `mapcar` builds the whole result list before you look at any of it. A generator version transforms one step at a time:

```lisp
(defun map-gen (fn gen)
  "A generator of (FUNCALL FN item) for each item of GEN."
  (lambda ()
    (multiple-value-bind (item ok)
      (funcall gen)
      (if ok
        (values (funcall fn item) t)
        (values nil nil)))))
```

```lisp
(defparameter *g*
  (map-gen #'1+ (make-list-gen '(1 2 3))))
(multiple-value-list (funcall *g*)) ; => (2 T)
(multiple-value-list (funcall *g*)) ; => (3 T)
(multiple-value-list (funcall *g*)) ; => (4 T)
(multiple-value-list (funcall *g*)) ; => (NIL NIL) — exhausted
```

Composition works because generators are functions returning functions — the closure-composition habit of Chapter 25, now with a stream flowing through. Filter too:

```lisp
(defun filter-gen (pred gen)
  "A generator of the items of GEN satisfying PRED."
  (lambda ()
    (loop
      (multiple-value-bind (item ok)
        (funcall gen)
        (cond ((not ok) (return (values nil nil)))
          ((funcall pred item) (return (values item t))))))))
```

The `loop` inside `filter-gen` keeps pulling until it finds a match or the source runs dry — laziness needs this "pull until satisfied" shape, and it's the first generator that consumes #emph[variable] amounts of its source per step. A source of 1000 odd numbers produces zero output from this filter, and one call to the filter is 1000 calls to the source.

```lisp
(defparameter evens
  (filter-gen #'evenp (make-counter-gen 0)))
(multiple-value-list (funcall evens)) ; => (2 T)
(multiple-value-list (funcall evens)) ; => (4 T)
```

Note the counter starts at 0, `incf` makes the first value 1, 1 is odd (filtered), 2 is even (kept) — so the first `funcall` on `evens` walks the counter through 1 and 2 before returning. If the counter were a million-element loop, that first `funcall` would do two steps. It's doing exactly the work asked.

== The consumer side: for-each and collect

A generator is useless without consumers. Three, and that's the complete vocabulary:

```lisp
(defun for-each (fn gen)
  "Call FN on every remaining item of GEN; return the count."
  (let ((n 0))
    (loop
      (multiple-value-bind (item ok)
        (funcall gen)
        (if (not ok)
          (return n)
          (progn (funcall fn item) (incf n)))))))

(defun collect-gen (gen)
  "Every remaining item of GEN, as a fresh list."
  (let ((items nil))
    (for-each (lambda (item) (push item items)) gen)
    (nreverse items)))

(defun take-gen (n gen)
  "A generator of at most N items of GEN, then exhausted."
  (lambda ()
    (if (<= n 0)
      (values nil nil)
      (multiple-value-bind (item ok)
        (funcall gen)
        (if ok
          (progn (decf n) (values item t))
          (values nil nil))))))
```

`for-each` consumes the whole generator, calling `fn` on each item. `collect-gen` is the bridge back to eager lists — process lazily through a pipeline of `map-gen`\/`filter-gen`, then `collect-gen` at the end when you genuinely want everything. `take-gen` is the opposite of `filter-gen`'s "consume until satisfied" — it stops asking after `n` items, closing the pipeline from the consumer side.

The pipeline:

```lisp
(collect-gen
  (filter-gen (lambda (c) (member c '(#\a #\e #\i #\o #\u)))
    (map-gen #'identity
      (make-list-gen
        (coerce "caveofnoise" 'list)))))
;; => (#\a #\e #\o #\o #\i #\e)
```

Nothing but one element ever exists at a time between the stages — for a 12-character string that's a nicety; for a stream of a million lines it's the whole design.

== Generators from thin air: infinite sources

`make-counter-gen` is already infinite. The point of lazy processing is that infinite sources are usable when consumers can stop early:

```lisp
(defun first-few (gen n)
  (collect-gen (take-gen n gen)))

(first-few (filter-gen #'evenp (make-counter-gen 0)) 5)
;; => (2 4 6 8 10) — from an infinite stream, finite work
```

The `take-gen` closure shares `n` with itself only — a private countdown. Combined, these small functions give you #emph[streams] in the full sense: sources (from lists, counters, or eventually I\/O), transformers, takers, collectors.

The test of understanding: trace `(first-few ... 5)`. `take-gen` produces up to 5. Each `funcall` on `take-gen` `funcall`'s `filter-gen`, which walks `make-counter-gen` until it finds an even number. The counter goes 1 (skip), 2 (keep), 3 (skip), 4 (keep), ..., through 10. Ten `funcall`'s on the counter, five on the take, one `collect-gen` at the end. No more work is done than the answer requires.

== Generators over the game: a file source

The natural game source is the transcript — Chapter 11's command log — processed as a stream rather than held as a list. And the natural extension is a generator over a #emph[file], streaming lines without holding the file in memory:

```lisp
(defun make-line-gen (path)
  "A generator of lines from the file at PATH, with :close."
  (let ((in (open path :if-does-not-exist nil)))
    (lambda (message)
      (ecase message
        (:next
          (if (null in)
            (values nil nil)
            (multiple-value-bind (line eof-p)
              (read-line in nil nil)
              (if eof-p
                (progn (close in) (setf in nil)
                  (values nil nil))
                (values line t)))))
        (:close
          (when in (close in) (setf in nil)))))))
```

The generator takes a message — `:next` or `:close` — instead of zero arguments. That's a protocol extension: most generators are zero-arg, but resource-owning generators need an explicit cleanup path. The `:next` message returns the protocol's two values; `:close` returns nothing useful, but it frees the resource.

The weakness of the zero-arg version is now visible: a generator that opened a file and was never driven to exhaustion would leak its stream until the image died. The `:close` message is the fix — callers who abandon a generator should `:close` it. The discipline is the same as `with-open-file`'s (`unwind-protect` guarantees), stated in protocol form instead of macro form.

The consumer that uses it:

```lisp
(defun replay-streamed (path)
  "Replay a transcript, stopping at the first unknown command."
  (let ((gen (make-line-gen path)))
    (unwind-protect
      (loop
        (multiple-value-bind (line ok)
          (funcall gen :next)
          (if (not ok)
            (return t)
            (let ((cmd (read-from-string line)))
              (multiple-value-bind (reply known-p)
                (run-command cmd)
                (unless known-p
                  (error "Unknown command: ~A" cmd))
                (format t "~&~A" reply))))))
      (funcall gen :close))))
```

`unwind-protect` (Chapter 15) guarantees the `:close` on any exit, error included. The consumer stops early on unknown commands, and the `:close` still runs. That's the whole resource discipline in one function.

== series, briefly

The `series` library (installable via Quicklisp: `(ql:quickload "series")`) is the compiled-to-eager alternative: you write #emph[series expressions] that look like lazy pipelines, and a code-writing macro phase fuses them into a single loop with no intermediate structures at all:

```lisp
(ql:quickload "series")
(use-package :series)

(collect
  (choose-if #'evenp (scan '(1 2 3 4 5 6))))
;; => (2 4 6) — compiled into one loop, zero intermediate lists
```

`scan` turns a sequence into a series, `choose-if` is `filter`, `collect` is the eager sink; the remarkable part is that `(collect (choose-if ... (scan ...)))` is a single loop after macroexpansion — the compiler never sees an intermediate allocation. Series is elegant, standards-adjacent (an appendix to the standard's process, never ratified), and — honestly — not where a newcomer should start.

The hand-built generators above teach the model; series optimises it; ordinary `loop` with `for ... being the elements of` covers most eager needs. Reach for series when profiling shows intermediate-list allocation mattering, or when the pipeline is complex enough that the fused-loop performance matters. Reach for hand-built generators when the source is genuinely streaming (files, sockets, incremental computation) and the pipeline is small enough to reason about directly.

== Common mistakes

=== funcalling a generator expecting one value

```text
(mapcar #'funcall (list g1 g2)) ; keeps primaries only
;; any exhaustion flags are dropped — and worse, one funcall
;; per generator advances it once, hidden inside mapcar
```

Generators have #emph[effect]: every call consumes. Call them in contexts where the two values are caught, and never "innocently" (for instance inside `mapcar` over a list of them).

=== Abandoned generators holding resources

The `make-line-gen` warning restated: a generator that opened a file and is never driven to exhaustion never closes it. Either design exhaustion-guaranteed use, add an explicit `:close` message, or keep the `with-open-file` outside and generate from an in-memory chunk.

=== Laziness as decoration

Wrapping a 12-element list in `make-list-gen` then `collect-gen` adds machinery for zero benefit. Lazy processing pays when: the source is unbounded or expensive, the consumer may stop early, or intermediate allocation is measured to matter. Otherwise eager lists are the simpler, correct tool — and Chapter 10's sequence functions remain the default vocabulary.

=== Shared generators

One generator handed to two consumers `takes turns` — each `funcall` advances the single cursor. Two independent views need two generators (re-call the constructor), or an explicit `tee` that buffers — which is a real design task, not a freebie.

=== Mixing the flag into the value

A consumer that ignores the flag — `(let ((item (funcall gen))) ...)` — sees `nil` when the generator is exhausted, and treats that as "an item whose value is nil". The bug shows up as `nil` leaking into data that should have ended the stream. #emph[Every] `funcall` on a generator should be inside a `multiple-value-bind` with the flag checked, or inside one of the standard consumers (`for-each`, `collect-gen`, `take-gen`).

== Project step: a streaming transcript replay

Chapter 11's `transcript` ran a fixed command list eagerly. This step streams the log file: read the saved transcript (one command per line), execute lazily, stop at the first unknown command — so a long replay can be aborted without running everything.

First write a transcript file to replay:

```lisp
(defun write-transcript (path commands)
  "Write COMMANDS to PATH as a replayable transcript."
  (with-open-file (out path :direction :output
      :if-exists :supersede)
    (dolist (cmd commands)
      (with-standard-io-syntax
        (print cmd out)))))
```

Then the source:

```lisp
(defun make-transcript-gen (path)
  "A generator of commands from the transcript at PATH."
  (let ((in (open path :if-does-not-exist nil)))
    (lambda (message)
      (ecase message
        (:next
          (if (null in)
            (values nil nil)
            (multiple-value-bind (line eof-p)
              (read-line in nil nil)
              (if (or eof-p (zerop (length line)))
                (progn (close in) (setf in nil)
                  (values nil nil))
                (values (read-from-string line) t)))))
        (:close
          (when in (close in) (setf in nil)))))))
```

And the consumer:

```lisp
(defun replay-streamed (path)
  "Replay a transcript, stopping at the first unknown command."
  (let ((gen (make-transcript-gen path)))
    (unwind-protect
      (loop
        (multiple-value-bind (cmd ok)
          (funcall gen :next)
          (if (not ok)
            (return t)
            (multiple-value-bind (reply known-p)
              (run-command cmd)
              (unless known-p
                (error "Unknown command in transcript: ~A"
                  cmd))
              (format t "~&~A" reply)))))
      (funcall gen :close))))
```

Check:

```lisp
(write-transcript "/tmp/cave-replay.lisp"
  '((look) (take key) (inventory)))
(replay-streamed "/tmp/cave-replay.lisp")
```

Expected: three replies printed, and the `:close` runs at the end (whether via the loop's natural exit, an error, or an interrupt).

The design point the step teaches: once a source is a generator, #emph[stopping early is free] — a loop that returns before exhaustion costs nothing for the unread remainder, and adding a "replay only the first N" option is a `take-gen` away. Chapter 11's eager `transcript` had to run every command because it took a list; the streaming version has no such obligation.

== Exercises

#exercise("30.1")[
  Predict, then check:

  ```text
  (defparameter *g* (make-list-gen '(a b)))
  (multiple-value-list (funcall *g*))
  (multiple-value-list (funcall *g*))
  (multiple-value-list (funcall *g*))
  (multiple-value-list (funcall *g*))

  (collect-gen (take-gen 3 (map-gen #'* (make-counter-gen 1))))

  (collect-gen (filter-gen (lambda (x) (> x 3))
  (take-gen 2 (make-counter-gen 0))))
  ```

]

#exercise("30.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (defparameter src (make-list-gen '(1 2 3 4)))
  (list (collect-gen src) (collect-gen src))

  (defun lazy-all-p (pred gen)
  (loop
  (multiple-value-bind (item ok) (funcall gen)
  (if (not ok) (return t)
  (unless (funcall pred item) (return nil))))))
  ;; caller wants to keep checking gen afterwards

  (let ((g (make-line-gen "/tmp/big.txt")))
  (funcall g)) ; one line read, then g abandoned
  ```

]

#exercise("30.3")[
  Write `gen-take-while`, which yields items while `pred` holds and stops (exhausted) at the first failure — the lazy cousin of Chapter 10's `remove-if-not` truncation. Then write `gen-append`, which yields all of one generator, then all of another. What does `gen-append` of two infinite generators produce, and what does that tell you about where laziness ends?

]

#exercise("30.4")[
  Write `zip-gens`, which takes two generators and yields, as three values per call, their next items together with the ok flag — the protocol stretch for two-item zips. Then use it with `zip-gens` over two counters to generate the squares 1, 4, 9, 16, ... #emph[without] computing each square directly. (That's the diagonal of a multiplication table.)

]

#exercise("30.5")[
  Write `make-fib-gen`, an infinite generator of Fibonacci numbers, using two closure bindings and no recursion. Then write `fib-sum-below`, which sums Fibonacci numbers below a limit #emph[without collecting any list] — the sum accumulated inside a loop that stops early. Which side of the protocol does the stopping belong to, and why?

]

#exercise("30.6", project: true)[
  Write `make-room-viz-gen`: a generator that yields each room reachable from the current one, breadth-first, without repeats, using the closure-owned visited list. Walk it with `for-each` to print a map — stopping after five rooms with `take-gen`. In a comment: what does the generator version buy over Chapter 8's recursive traversal, and what does the visited state being closure-private make #emph[hard] (a later caller wanting to know how far the walk went)?

]

