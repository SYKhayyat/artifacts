#import "../lib.typ": *

= Testing

A program you can't test is a program you can't change. The game has grown for thirty-two chapters — features added, bugs fixed, structures converted from alists to structs to closures — and every one of those changes was an opportunity for a regression. This chapter is about catching them before your players do.

Lisp's testing story is unusually simple, and unusually native. Tests are functions; assertions are conditions; running tests is calling functions. No JUnit-style framework ceremony, no annotations, no build-tool integration needed to start. The two most-used libraries — `fiveam` and `prove` — add structure for large test suites, but the hand-rolled version from Chapter 31's project step is already a test framework in miniature, and for the game's size it's enough to build on.

== Why test at all

The question a beginner asks — "why write a test when I can just run the code?" — has a clear answer once the program grows past a page: #emph[you can run the code once, but not a thousand times]. Tests are the answer to "does this still work?" asked without re-running everything manually.

The game has three specific reasons to test:

- #emph[State transitions.] `take` modifies #strong[item-locations]; `undo` restores from history. Every change to either could break the other. A test that takes an item, undoes, and checks the item is back in the room is cheap and catches a whole class of regressions.

- #emph[Format round-trips.] `save-game` and `load-game` are inverse operations; `game-state-json` and `import-state-json` are another pair. Testing that round trip in isolation catches most persistence bugs.

- #emph[Cross-chapter invariants.] The `thing-registry` from Chapter 26 holds descriptions; the `item-locations` from Chapter 7 holds positions. A regression in one — an item registered but not tracked, or tracked but not registered — is the kind of bug that passes casual play but shows up in-game eventually. A test that lists registered things and asserts each has a location is a one-line check of the invariant.

The three reasons have a common shape: #emph[any invariant you can state in a sentence is a test waiting to be written].

== The minimal test framework

Chapter 31's `run-tests` is already the pattern:

```lisp
(defun run-tests ()
  "A handful of invariants, reported as a list of (name . ok)."
  (let ((results nil))
    (flet ((check (name got want)
             (push (cons name (equal got want)) results)))
      (check "item-location-roundtrip"
             (progn
               (setf *item-locations* '((key . kitchen)))
               (set-location *item-locations* 'key 'hallway)
               (item-location 'key))
             'hallway)
      (check "empty-history-safe"
             (progn (funcall *history* :clear)
                    (funcall *history* :recent))
             nil))
    (nreverse results)))
```

Two design choices in the `check` helper are worth unpacking, because they determine what the suite can do:

Checks return `(name . ok)` pairs, not signalling `errors.` A failing check is data, not an exception. That lets `run-tests` run every check regardless of failures and report them all, instead of stopping at the first — the behaviour you want when a change broke three things at once and you want to see the whole list.

The `check` helper is a `flet` local, not a `global.` Test assertions are local to the test function; making them global means test code and library code share a namespace, and a bad test helper can shadow the very functions it's testing. `flet` keeps the scope tight.

Both choices scale: `fiveam` adds assertion types (`is-true`, `is-false`, `is-equal`, `is-error`), assertion messages, fixtures, and a runner, but the underlying model — a test is a function; a check is a comparison; results are collected — is exactly what the hand-rolled version shows.

== What to test

The first discipline: #emph[test behaviour through the public interface, not internals]. Tests that call `items-here` directly are testing the machinery; tests that call run-command '`(take key)` and check the reply are testing the behaviour players see. The two kinds of tests have different stability profiles:

- Internal tests (call `items-here`, `set-location`) break when the internals change. They're cheap to write, useful during development of one function, and should be discarded or moved into a "unit test" file when the function stabilises.
- Behaviour tests (call run-command '`(take key)`, `save-game`, `look`) are what players exercise. They break when the contract changes, which is exactly when you want to be notified.

For the game, the behaviour test set is short:

```lisp
;; Behaviour: taking an item moves it from the room to the player.
;; Behaviour: undo restores the item to the room.
;; Behaviour: save/load round-trips the state.
;; Behaviour: unknown commands return a reply without signalling.
;; Behaviour: examine of a registered thing returns its description.
;; Behaviour: examine of an unregistered thing returns a generic line.
;; Behaviour: price of a treasure returns its value.
;; Behaviour: inventory lists carried items alphabetically.
```

Eight tests, each one a sentence. Run them after every change; if all eight pass, the game's basics are intact. That's the #emph[regression gate] — not the full specification of the game, but the subset of it whose breakage would surprise you.

== The flag-vs-condition rule applied to tests

The flag-vs-condition distinction from Chapters 24 and 19 determines which behaviours #emph[can] be tested cleanly and which need special handling:

- #emph[Flag-returning functions] — `run-command` (two values: reply, known-p), `save-game` (success-p, path), `load-game` (state, loaded-p) — are tested by checking both values. `(multiple-value-bind (reply known-p) (run-command '(dance)) ...)` lets the test assert "reply is a string, known-p is nil" in one go.

- #emph[Condition-signalling functions] — `safe-divide` (if you wired the Chapter 19 version), `class-change-drops-slots` — are tested with `handler-case` inside the test:

```lisp
(defun expect-condition (condition-type thunk)
  "Run THUNK, expecting CONDITION-TYPE.  Returns T if signalled."
  (handler-case (progn (funcall thunk) nil)
    (condition-type (c) (declare (ignore c)) t)))
```

The `(progn ... nil)` is the trick: if the thunk returns normally, the `progn` returns `nil` and the test fails because the expected condition never fired. If the thunk signals the expected type, the handler runs and returns `t`. If the thunk signals a different type, the handler doesn't match, and the condition propagates — the test fails with the wrong condition visible, not with a misleading "expected condition, got value".

- #emph[Value-returning functions] — `item-names`, `item-phrase`, `comma-list` — are the easy case: call with an input, compare with `equal`.

The rule the three cases encode: #emph[test the function's own contract, not what a caller does with it]. A flag-tester asserts the flag; a condition-tester asserts the condition; a value-tester asserts the value. The mismatch — testing a flag-returning function by expecting a condition — is a common beginner error, and the test's diagnostic is baffling when it fires.

== Test doubles: closures over state

Some tests need to control what a function sees without changing the game's actual state. The #strong[game-output] variable from Chapter 17 is exactly this kind of seam:

```lisp
(defun run-command-output (command)
  "Run COMMAND with output captured; return the string."
  (with-output-to-string (s)
    (let ((*game-output* s))
      (run-command command))))
```

`run-command-output` is a test helper — not part of the game's API, just a convenience for tests that care about what was `printed` rather than what was `returned`. Testing `look` through it:

```lisp
(check "look-mentions-room"
       (search "kitchen"
               (string-downcase
                (run-command-output '(look))))
       0)   ; SEARCH returns 0 when the substring is at the start
```

The `search` check is interesting: it returns the index of the match, so any result other than `nil` means "found". The test asserts `0` specifically because `look` should start with the room name; a `search` returning 5 would mean the name appears but not where the player expects. The assertion is stricter than "contains", which is the point — tests can encode formatting expectations that a `stringp` check can't.

The general pattern: closures (Chapter 25) make test doubles free. A function that reads from #strong[game-output] can be tested by binding it to a string stream; a function that reads from #strong[save-file] can be tested by binding it to `/tmp/test-save`. No mocking framework needed; the dynamic variables are the seams, and `let` is the tool.

== Wiring tests into the build

Chapter 31's project step wired a small suite into the game's ASDF system. This chapter strengthens it to a real gate:

```lisp
;; tests.asd
(defsystem "cave-of-noise/tests"
  :depends-on ("cave-of-noise")
  :components ((:file "tests"))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (unless (every #'cdr (cave-of-noise/tests::run-tests))
               (error "Test suite failed."))))
```

The `:perform` clause on `asdf:test-op` is what `asdf:test-system` calls. Running it:

```lisp
(asdf:test-system "cave-of-noise/tests")
;; => either silent success, or an error naming the failed tests
```

The build script's test step becomes:

```text
sbcl --noinform --non-interactive \
     --eval "(asdf:test-system \"cave-of-noise/tests\")" \
     --eval "(asdf:load-system \"cave-of-noise\")" \
     --eval "(cave-of-noise::build-executable ...)"
```

Three `--eval` forms: test, load, build. A failed test signals from `test-system`, SBCL's `--non-interactive` mode propagates the error as a non-zero exit, and `set -e` in the shell stops the script before the build runs. Three layers of gate, one intent: #emph[no release with a red test].

The three-layer structure is worth noting as a pattern. Each layer is independent (the shell's `set -e` doesn't know about the tests; the tests don't know about the build), and each is necessary — take any one away and the whole sequence can ship a broken binary. That's the normal shape for build automation: many small checks, each doing its part.

== Growing the suite across chapters

The natural discipline is #emph[one test per bug fixed]. When play reveals a bug — a command that returns the wrong string, a save that loses a field, an undo that leaves state half-restored — the fix is two changes:

+ Fix the code.
+ Add a test that would have caught the bug.

The second change is what makes the test suite grow into something useful. It's also the hardest habit to form, because the bug is already fixed and the test feels like afterthought. But the test's purpose isn't to prove the bug exists #emph[now] — it's to ensure the bug #emph[doesn't exist again], after some future change. And every future change to that part of the code is now protected.

The game's test suite grows the same way. If Chapter 24's two-valued `run-command` broke something that a caller relied on, the test that catches it would be added then. The suite isn't a chapter's deliverable; it's the shape the codebase takes as it grows.

== When to reach for fiveam

The hand-rolled framework from Chapter 31 is enough for under about thirty tests. Beyond that, three things start to matter:

- #emph[Better assertion messages]. `fiveam`'s `is-equal` prints a diff when it fails; the `check` helper above prints "got vs want" only if you wrote it that way. The ergonomics of failure matter when a test suite has fifty tests and you're reading the failing one.

- #emph[Test discovery and organisation]. `fiveam` groups tests into suites, runs subsets (`run! 'my-suite`), and reports summaries. The hand-rolled version is one list of `(name . ok)` pairs; you organise manually.

- #emph[Fixtures]. "Set up this state before every test in this suite" is a common need once tests start sharing setup code. `fiveam` has fixtures; the hand-rolled version would grow a macro for it, which is the sign you're building fiveam badly.

The transition point is when the test suite has its own structure — multiple files, shared setup, several suites. For the game at thirty-two tests, hand-rolled is fine. For the game at fifty, reach for the library.

The `run-tests` shape survives the transition: `fiveam`'s `run!` returns a similar result, and the build script's check is the same. The framework is a tool; the discipline (test the contract, one test per bug, green before shipping) is the habit, and it transfers.

== Common mistakes

=== Testing internals

A test that calls `(items-here 'kitchen)` directly is testing `items-here`; a test that calls run-command '`(look)` and searches the reply is testing `look`. The second survives `items-here` being renamed, rewritten, or moved to another package. The first breaks every time. Test through the interface; save internal tests for during the development of one function, then delete them.

=== Tests that depend on order

```text
(check "take-key" ...)     ; mutates *item-locations*
(check "undo-take" ...)    ; assumes the previous check ran
```

If `take-key` is skipped or `undo-take` is run alone, `undo-take` fails. The fix is to set up the state each test needs at the start of each check — a `let` or `setf` reset — so each check is independent. Tests that depend on order are tests that pass in the suite and fail when debugged individually, which is the worst kind of debugging.

=== Silent test failures

A check that returns `(name . t)` when the value is wrong — because the comparison used `eq` where `equal` was needed, or because the "value" was a side-effect-producing form that always returns `t` — is worse than no test. The symptom: the suite says "green" and the bug ships anyway. `check`'s `(equal got want)` is doing the right comparison; using `eq` on strings or lists is the classic mistake (Chapter 10's four equalities, in a test context).

The disproof: deliberately break the code a test covers, run the test, watch it fail. If it doesn't fail, the test isn't testing what you thought. Every test suite should have at least one deliberate-break session where the developer sees the tests do their job.

=== Trusting the debugger during tests

Running a test in the REPL, watching it enter the debugger on failure, and manually inspecting state — that's normal during test development. But the suite as run by `asdf:test-system` must not enter the debugger. A test that signals an error should be caught by the framework or by an explicit `handler-case` in the test; letting the debugger open turns "test suite" into "interactive test session", and the build script hangs waiting for input.

The `check`-based framework is debugger-safe: assertions compare values and return pairs, no error signalling. Tests that use `expect-condition` are debugger-safe for the expected condition; an unexpected condition is the problem the framework must catch. Wiring `run-tests` into a `handler-case` in `test-op`:

```lisp
(defun run-tests-safely ()
  "Run the test suite; signal on any unexpected condition."
  (handler-case (run-tests)
    (error (c)
      (list (cons "test-runner-error"
                  (format nil "Test runner crashed: ~A" c))))))
```

— so the framework catches its own failures and reports them as `(name . nil)` pairs, the same as test failures.

=== Over-testing

Tests have a cost: writing them, maintaining them, waiting for them. A test that asserts "string-upcase of "a" is "A"" is testing the language, not your code. A test that asserts `(1+ 2)` is `3` is testing SBCL. Tests are for your decisions — the invariants you chose — not for the language's. Delete any test you can't imagine ever failing.

=== Over-mocking

The game's tests use the game's actual functions with `let`-bound variables. That's the right amount of substitution: the functions are the game; the variables are the configuration. A test that replaces `run-command` with a stub to test `play` isn't testing `play` — it's testing the stub. Replace configuration (variables) when you need control; never replace the code under test.

== Project step: the game's test suite

Write the eight behaviour tests, wire them into the ASDF system, and make the build script refuse to ship without them. The whole file:

```lisp
;;;; tests.lisp
;;;;
;;;; The game's behaviour test suite.  Eight tests, each
;;;; asserting one sentence of the game's contract.

(defpackage :cave-of-noise/tests
  (:use :cl :cave-of-noise)
  (:import-from :cave-of-noise
                ;; state the tests read and rebind
                #:*item-locations* #:*current-room* #:*history*
                #:*save-file* #:*game-output*
                ;; functions and classes they call
                #:find-room #:item-location #:register-thing
                #:describe-thing #:make-history #:save-game
                #:load-game #:restore-state #:price #:treasure #:thing
                ;; command and data symbols: identity matters
                #:undo #:key #:kitchen #:player)
  (:export :run-tests))

(in-package :cave-of-noise/tests)

(defun run-tests ()
  "Run every check.  Returns (name . ok) pairs."
  (let ((results nil))
    (flet ((check (name got want)
             (push (cons name (equal got want)) results)))

      (check "take-moves-item"
             (progn
               (setf *item-locations* '((key . kitchen)))
               (setf *current-room*
                     (find-room 'kitchen))
               (let ((*game-output* (make-string-output-stream)))
                 (run-command '(take key))
                 (item-location 'key)))
             'player)

      (check "undo-restores-item"
             (progn
               (setf *item-locations* '((key . kitchen)))
               (setf *current-room*
                     (find-room 'kitchen))
               (let ((*history* (make-history)))
                 (run-command '(take key))
                 (run-command '(undo))
                 (item-location 'key)))
             'kitchen)

      (check "save-load-roundtrip"
             (let ((*save-file* "/tmp/test-roundtrip.lisp")
                   (*item-locations*
                    '((key . kitchen))))
               (setf *current-room*
                     (find-room 'kitchen))
               (save-game)
               (setf *item-locations* nil)
               (multiple-value-bind (state loaded-p)
                   (load-game)
                 (and loaded-p
                      (progn
                        (restore-state state)
                        (equal *item-locations*
                               '((key . kitchen)))))))
             t)

      (check "unknown-command-returns"
             (multiple-value-bind (reply known-p)
                 (run-command '(xyzzy))
               (declare (ignore reply))
               known-p)
             nil)

      (check "examine-registered-thing"
             (progn
               (register-thing
                'probe (make-instance 'thing
                                      :name 'probe
                                      :description "a test probe"))
               (search "test probe"
                       (multiple-value-bind (reply known-p)
                           (run-command '(examine probe))
                         (declare (ignore known-p))
                         reply)))
             (search "test probe"
                     (describe-thing
                      (make-instance 'thing
                                     :name 'probe
                                     :description "a test probe"))))

      (check "examine-unregistered-thing"
             (multiple-value-bind (reply known-p)
                 (run-command '(examine nonexistent))
               (declare (ignore known-p))
               (not (null (search "nothing special"
                                  (string-downcase reply)))))
             t)

      (check "price-of-treasure"
             ;; 42 from the treasure method, plus 1 from thing's
             (price (make-instance 'treasure
                                   :name 'test
                                   :value 42))
             43)

      (check "inventory-alphabetical"
             (progn
               (setf *item-locations*
                     '((zebra . player)
                       (apple . player)
                       (mango . player)))
               (multiple-value-bind (reply known-p)
                   (run-command '(inventory))
                 (declare (ignore known-p))
                 (not (null (search "apple, mango and zebra"
                                    (string-downcase reply))))))
             t))

    (nreverse results)))
```

Check:

```lisp
(cave-of-noise/tests::run-tests)
;; => (("take-moves-item" . T)
;;     ("undo-restores-item" . T)
;;     ("save-load-roundtrip" . T)
;;     ("unknown-command-returns" . T)
;;     ("examine-registered-thing" . T)
;;     ("examine-unregistered-thing" . T)
;;     ("price-of-treasure" . T)
;;     ("inventory-alphabetical" . T))
```

The eight checks, and what each is doing:

- `take-moves-item` — Chapter 7's invariant, tested through Chapter 9's command dispatch.
- `undo-restores-item` — Chapter 14's invariant, using the Chapter 25 closure-based history.
- `save-load-roundtrip` — Chapters 16\/18\/24's round trip, tested with the Chapter 24 two-valued `load-game`.
- `unknown-command-returns` — Chapter 24's contract: the second value is `nil` for unknown commands.
- `examine-registered-thing` — Chapter 26's CLOS dispatch, tested through Chapter 9's command interface.
- `examine-unregistered-thing` — the fallback path in `examine`.
- `price-of-treasure` — Chapter 27's method combination, tested directly at the generic function.
- `inventory-alphabetical` — Chapter 10's sort, tested at the player-visible output.

Each `progn` inside the check sets `up` the state the check needs, so no check depends on another. That's the "independent tests" discipline from the common mistakes list, applied.

The ASDF system:

```lisp
(defsystem "cave-of-noise/tests"
  :depends-on ("cave-of-noise")
  :components ((:file "tests"))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (let ((results
                     (cave-of-noise/tests::run-tests)))
               (unless (every #'cdr results)
                 (error "Test suite failed: ~{~A~^, ~}"
                        (remove-if #'cdr results))))))
```

The `:perform` clause on `test-op` is what `asdf:test-system` invokes. The check: if any `cdr` is nil, the failure message lists which tests failed — same shape as `check`'s `(name . ok)` pairs, one line of code, and the caller sees the failure names, not just "tests failed".

And the build script (already shown in Chapter 32's Exercise 32.4, but for completeness):

```text
#!/bin/sh
set -e
sbcl --noinform --non-interactive \
     --eval "(asdf:test-system \"cave-of-noise/tests\")" \
     --eval "(asdf:load-system \"cave-of-noise\")" \
     --eval "(cave-of-noise::build-executable \
              \"game\" #'cave-of-noise:main)"
```

Test, load, build. Every step is a gate; the script stops on the first failure. That's the release discipline: a build that can't fail the test suite isn't a build you can trust.

== Exercises

#exercise("33.1")[
  Add three more checks to `run-tests`, one per category from the chapter: a state transition (`drop`), a format round-trip (`game-state-json` \/ `import-state-json`, if you did Chapter 29's project step), and a cross-chapter invariant (every registered thing is also in #strong[item-locations] somewhere, OR carried OR both, OR is a 'defunct' thing kept for later — pick the invariant that holds for your game, and defend the choice in a comment).

]

#exercise("33.2")[
  Each of these tests is broken. Say what's wrong, then fix it.

  ```text
  (defun check (name got want)
    (push (cons name (eq got want)) results))

  (defun run-tests ()
    (let ((results nil))
      (flet ((check (name got want)
               (push (cons name (equal got want)) results)))
        (check "string-upcase-of-a"
               (string-upcase "a") "A")
        (check "plus-is-associative"
               (+ 1 (+ 2 3)) (+ (+ 1 2) 3))
        (check "test-failure-detected"
               (handler-case (error "should fail")
                 (error () :caught))
               :caught))))

  (check "test-failure-detected" (error "should fail") nil)
  ```

]

#exercise("33.3")[
  Write `fiveam`-style `is-equal`, `is-true`, `is-error`, and `is-values` macros (or functions, for the first two) that a `fiveam`-style test can call. The macro versions add assertion messages; the function versions just return (name . ok) pairs. What does the macro version buy, and what does it cost?

]

#exercise("33.4")[
  Write `run-tests-with-filter`, which takes a list of test names and runs only those. What does this let you do that the full suite doesn't, and when does the answer change (as the suite grows, as the code matures)?

]

#exercise("33.5")[
  Take one of the game's bugs — either a real one you've found, or the deliberate `item-names` bug from Chapter 22's Exercise 22.7 — and add a test that catches it. Deliberately break the code, run the test, confirm it fails. Then fix the code, run again, confirm it passes. That's the discipline the chapter describes: #emph[the test proves itself by failing].

]

#exercise("33.6", project: true)[
  Convert the game's test suite to `fiveam` (or `rove`, or `prove` — pick one). The conversion should be mechanical: each `check` becomes an `is`\/`is-equal` form, each test becomes a `(test NAME "docstring" ...)` form, and the `test-op` calls `(fiveam:run! 'cave-of-noise/tests)` instead of `run-tests`. What did the framework buy you — be honest: if the answer is "nothing" for a suite this small, that's a useful finding too.

]

