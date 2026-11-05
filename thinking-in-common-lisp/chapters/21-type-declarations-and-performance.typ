#import "../lib.typ": *

= Type Declarations and Performance

Every value you've handled has had a type all along — integers, strings, lists, your own `room` structures — and Lisp has checked what it needed to, when it needed to. What Lisp #emph[doesn't] do is demand types up front. Declarations exist anyway, and this chapter explains what they're for: telling the compiler what it may assume, asking it to check, and — rarely, at measured spots — asking it to go fast. This is also the promised full treatment of `declare`, which you've met twice before (`(declare (ignore ...))` in the reader chapter, `(declare (type ...))` glancingly).

== Types are a property of values

In Java, a variable is declared with a type and can only hold that type. In Lisp, types belong to #emph[values]: the number 5 is of type `(integer 0 10)` and `fixnum` and `number` and `t` all at once, and one variable can hold values of different types at different moments. `typep` asks, `type-of` reports:

```lisp
(list (typep 5 'integer)          ; => T
      (typep 5 '(integer 0 10))   ; => T — a bounded type!
      (typep 5 'float)            ; => NIL
      (typep #'car 'function)     ; => T
      (type-of 5)                 ; => (INTEGER 0 4611686018427387903) on SBCL
      (type-of "hi"))             ; => (SIMPLE-ARRAY CHARACTER (2))
```

Type specifiers range from simple names (`integer`, `string`) to parameterised ones — `(integer 0 10)`, `(string 10)`, `(vector fixnum)`, `(member :on :off)`, `(or null room)`. `defstruct` (Chapter 13) and `defclass` (Chapter 24) each define new type specifiers too: `(typep r 'room)` has worked since you defined rooms.

`subtypep` asks the type-system questions:

```lisp
(subtypep 'fixnum 'integer)     ; => T, T
(subtypep 'integer 'fixnum)     ; => NIL, T — surely not a fixnum
(subtypep '(integer 0 10) 'fixnum)  ; => T, T
```

Two values, because some type questions have no settled answer; the second value `T` means "the answer is certain". Compare `typep` (a #emph[value] against a type) with `subtypep` (a #emph[type] against a type).

== declare: the local promise

A `declare` is a #emph[declaration]: information for the compiler, placed at the head of a form that introduces bindings. It is not an executable form, and it changes no values:

```lisp
(defun add-fixnums (a b)
  (declare (type fixnum a b))
  (+ a b))
```

The declaration tells the compiler: `a` and `b` will always be fixnums — assume it. What the compiler #emph[does] with the assumption depends on the safety setting, coming below: at high safety it verifies and signals a `type-error` on violation; at high speed it trusts and optimises.

The declarations you'll actually use, collected:

```lisp
(defun example (x list fn)
  (declare (type fixnum x)            ; x is a fixnum
           (type list list)           ; redundant but legal
           (function fn)              ; fn is a function
           (ignore fn)                ; deliberately unused
           (ignorable list)           ; may be unused — fine, don't warn
           (dynamic-extent list))     ; list won't outlive this call
  (+ x (length list)))
```

- `ignore` — you used this in the Reader chapter; the parameter must be unused, and using it is an error.
- `ignorable` — softer: unused is fine, used is fine, never warn.
- `dynamic-extent` — a promise the object dies with the call, letting implementations stack-allocate it; advanced, and mostly useful in hot loops.
- `type` — the star of this chapter.
- `special`, `ftype`, `inline`, `notinline`, `optimize` — met here or below.

`the` is the inline cousin — a type assertion on an expression, no binding needed:

```lisp
(defun sum-vector (v)
  (let ((total 0))
    (declare (type fixnum total))
    (dotimes (i (the fixnum (length v)) total)
      (incf total (the fixnum (aref v i))))))
```

And `check-type` is the runtime twin — interactive checking:

```lisp
(defparameter *frequency* 440)

(defun set-frequency (hz)
  (check-type hz (integer 20 20000) "a frequency in hertz")
  (setf *frequency* hz))
```

Violations signal a `type-error` with a restart that lets you fix the variable and continue — the debugger as a live type checker.

== declaim and proclaim: global declarations

`declaim`, at the top level, declares globally — for the rest of the file or session:

```lisp
(declaim (type fixnum *moves*))
(declaim (inline square))
(defun square (x) (* x x))
```

`proclaim` is the functional twin (an ordinary call, so usually used dynamically); `declaim` is the compile-time-aware one and the one you'll see in source. Global type declarations on earmuffed variables are a common and cheap performance aid: the compiler knows `*moves*` is a fixnum everywhere below.

`declaim (inline ...)` is also how inlining is requested — a hint the compiler may take. Its opposite, `notinline`, forbids inlining and is how you #emph[stop] the compiler from optimising away a redefinition (the redefinition-loop discipline of Chapter 22 applies: after changing an inlined function, recompile its callers or the change won't appear).

== optimize: the quality dial

The `optimize` declaration sets compiler priorities:

```lisp
(defun hot-inner-loop (v)
  (declare (optimize (speed 3) (safety 1) (debug 1))
           (type (simple-array double-float (*)) v))
  (loop for x across v sum (the double-float x)))
```

Five qualities, each 0–3: `speed`, `safety`, `debug`, `compilation-speed`, `space`. Higher `safety` means more checking (type errors, array bounds); higher `speed` means trusting declarations and specialising; higher `debug` preserves the stack and variable names for the debugger (Chapter 22's backtraces are this setting in action). The qualities #emph[trade off]: `speed 3, safety 0` means the compiler will happily generate code that corrupts memory on a type violation — a wrong declaration at safety 0 is undefined behaviour, the one place Lisp resembles C.

The SBCL defaults are `safety 1, debug 1, speed 1, space 1` — a balanced profile that checks a good deal. The discipline this chapter teaches, stated once: #emph[profile first, then declare, then measure]. SBCL ships `sb-profile`; the `time` macro from Chapter 22 is the first instrument:

```lisp
(time (sum-vector (make-array 1000000
                :element-type 'twice-float
                :initial-element 1.0d0)))
```

== Why declarations matter to the compiler

The payoff, concretely. Without declarations, `(+ a b)` compiles to a generic addition: fixnums? bignums? ratios? floats? Check and dispatch at run time. With `(declare (type fixnum a b))`, it compiles to one machine add — plus an overflow check the compiler can often prove unnecessary. Arrays specialise the same way: `(aref v i)` on a `(simple-array double-float (*))` is a pointer read; on a plain `vector` it's a type dispatch per access. This is why numeric Lisp code that's fast declares heavily and uses typed arrays:

```lisp
(make-array 4 :element-type 'twice-float :initial-element 0.0d0)
```

The `:element-type` from Chapter 13's arrays chapter now has its performance meaning: an array that #emph[holds only doubles] is one the compiler can treat as raw memory.

== Common mistakes

=== Declaring wrong, at low safety

A wrong `type` declaration is not a checked annotation — under `(safety 0)` it's a lie the compiler believes, and the result is corruption, not an error. Keep `safety 1` or higher wherever declarations are new or unproven; SBCL's compiler notes will flag contradictions at compile time if you listen to them.

=== Declaring everything

Sprinkling `the` and `type` through ordinary code adds noise with no measurable gain. Declaring pays in tight numeric loops and hot data structures — profile, find the 5%, declare there.

=== Reading optimization qualities as switches

`(speed 3)` is a #emph[weighting], not a mode; implementations differ in what they do with it. And `(safety 0)` is not "less checking, more speed" — it's "no checking, possibly wrong answers". In application code, `(speed 3) (safety 1) (debug 1)` is the responsible hot-spot setting.

=== Forgetting declare placement

`declare` must come #emph[immediately after] the binding-introducing form's header — right after the variable list in `defun`, right after the bindings in `let`, right after `loop`'s keywords. A declaration after an executable form is an error, and the compiler will tell you.

== Project step: a fast item count

The game is pure symbol work — declarations buy it nothing, and this step says so honestly while adding one genuinely typed component: a heat map of room visits, as a fixnum vector indexed by room number.

```lisp
(defparameter *room-list* '(bedroom hallway kitchen garden cellar))

(defun room-index (name)
  (or (position name *room-list*)
      (error "No room ~(~A~) registered." name)))

(defparameter *visits*
  (make-array (length *room-list*)
              :element-type 'fixnum
              :initial-element 0))

(defun note-visit (name)
  "Count a visit to room NAME."
  (let ((i (room-index name)))
    (declare (type (integer 0 #.array-dimension-limit) i))
    (incf (aref *visits* i))))

(defun visit-report ()
  "Rooms by visit count, busiest first."
  (sort (loop for r in *room-list*
              for n across *visits*
              collect (list n r))
        #'> :key #'first))
```

`#.array-dimension-limit` — the sharp-dot read-time evaluation from the Reader chapter, giving the biggest legal array index as a type bound. Check:

```lisp
(setf *visits* (make-array 5 :element-type 'fixnum
                             :initial-element 0))
(note-visit 'kitchen)
(note-visit 'kitchen)
(note-visit 'cellar)
(visit-report)
;; => ((2 KITCHEN) (1 CELLAR) (0 BEDROOM) (0 HALLWAY) (0 GARDEN))
```

And one measured experiment, the chapter's real habit:

```lisp
(defun count-bits-undeclared (n)
  (loop for i below n count (evenp i)))

(defun count-bits-declared (n)
  (declare (type fixnum n) (optimize (speed 3) (safety 1)))
  (loop for i of-type fixnum below n count (evenp i)))

(time (count-bits-undeclared 10000000))
(time (count-bits-declared 10000000))
```

On a typical machine the declared version runs roughly twice as fast — `loop`'s `of-type` is a declaration shorthand. Your numbers will differ; that's the point of `time`.

== Exercises

#exercise("21.1")[
  Predict the results, then check:

  ```text
  (typep 3 '(integer 0 2))
  (typep 3 '(or null integer))
  (typep :red '(member :red :green :blue))
  (typep "abc" '(simple-array character (3)))
  (typep '(1 2) '(cons integer (cons integer null)))
  (subtypep 'null 'list)
  (subtypep 'null 'symbol)
  ```

]

#exercise("21.2")[
  Each snippet is wrong. Say what happens, then fix it.

  ```text
  (defun f (x)
    (format t "x is ~A~%" x)
    (declare (type fixnum x))
    (* x 2))

  (declaim (type string *player-name*))
  (defparameter *player-name* 'anon)

  (defun g (v)
    (declare (optimize (speed 3) (safety 0))
             (type fixnum v))
    (1+ v))
  (g "oops")
  ```

]

#exercise("21.3")[
  Write `safe-elt`, which takes a sequence and an index, uses `check-type` to confirm the index is a non-negative fixnum before touching the sequence, and returns the element. Then write `fast-elt`, identical but with `(safety 0)` and a fixnum declaration instead of `check-type`. In a comment: which one belongs in the game, and why is the answer "safe-elt almost everywhere"?

]

#exercise("21.4")[
  Using `subtypep`, write `type-chain-p`, which takes a value and a list of types and answers whether the value's `type-of` is a subtype of #emph[every] listed type. What does `(type-chain-p 5 '(integer fixnum number))` return, and what does that tell you about how types overlap?

]

#exercise("21.5")[
  Time three versions of summing a million-element double-float array: (a) plain `loop` with `sum`, no declarations; (b) with `(the double-float ...)` on the element and a declared accumulator; (c) with the array declared `(simple-array double-float (*))` as well and `(speed 3)`. Report your three timings in a comment and say which declaration bought the most.

]

#exercise("21.6", project: true)[
  Add `(declaim (type fixnum *moves*))` globally with `declaim`, make `*moves*` start as a fixnum, and run the game's `play` reliably with a fresh save. Then write `drift-check`, which walks every earmuffed game variable, `check-type`s it against a small table of expected types (alist: variable name to type specifier), and returns the list of variables that fail. What kind of bug does `drift-check` catch that a wrong `declaim` would turn into corruption at `(safety 0)`?

  The chapter covers:

  The REPL as a workbench (`*, =`, `*`, `+`, `++`, `+++`, describe, documentation)

  That's honest about what the game's data supports at this point.

]

