#import "../lib.typ": *

= Loops

Part II taught you to think in lists: recursion, functions as values, and the sequence functions. This chapter opens the everyday tools with the other way to repeat work: loops.

Recursion and `mapcar` cover a lot, but some jobs read more naturally as "do this for each element" or "count from 1 to 10". Common Lisp has small loops for the simple cases (`dolist`, `dotimes`) and one large, flexible one (`loop`).

== `dolist`: once per element

```lisp
(dolist (x '(a b c))
  (print x))
```

```text
A
B
C
```

`(dolist (x list) body...)` binds `x` to each element in turn and runs the body. `x` is a local variable, like one made by `let`.

`dolist` returns `nil`. It's for effects, such as printing or changing a variable, not for building a result. To return something, add a third element, the #emph[result form], which is evaluated after the last pass:

```lisp
(let ((evens nil))
  (dolist (n '(1 2 3 4 5 6) (reverse evens))
    (when (evenp n)
      (push n evens))))
;; => (2 4 6)
```

`push` puts each number at the front, so the result form reverses the list at the end. That's the accumulator pattern from Chapter 8, with `dolist` doing the walk.

== `dotimes`: a number of times

```lisp
(dotimes (i 3)
  (print i))
```

```text
0
1
2
```

`(dotimes (i n) body...)` runs the body `n` times, with `i` going from `0` up to `n` minus one. It also accepts a result form:

```lisp
(let ((total 0))
  (dotimes (i 5 total)
    (incf total i)))
;; => 10, because 0 + 1 + 2 + 3 + 4
```

== Leaving early: `return` and `return-from`

`(return value)` leaves a `dolist` or `dotimes` at once, and the loop returns `value`:

```lisp
(dolist (x '(1 3 4 5 6))
  (when (evenp x)
    (return x)))
;; => 4
```

The loop stops at `4` and never looks at `5` or `6`.

`return` leaves only the innermost loop. To leave a whole function from inside nested loops, use `(return-from name value)`, where `name` is the function's name:

```lisp
(defun find-pair-sum (target lst)
  "Return the first two elements of LST that add up to TARGET."
  (dolist (a lst)
    (dolist (b lst)
      (when (= (+ a b) target)
        (return-from find-pair-sum (list a b))))))
```

```lisp
(list (find-pair-sum 10 '(1 4 6))
      (find-pair-sum 100 '(1 4 6)))
;; => ((4 6) NIL)
```

A plain `return` here would leave only the inner `dolist`, and the outer one would carry on with the next `a`. When nothing matches, both loops finish and return `nil`, so the function returns `nil`.

== `do`: the old general loop

You'll meet `do` in older code. It sets up variables, steps them, and stops when a test is true:

```lisp
(print
 (do ((i 0 (1+ i)))     ; variable, start value, step
     ((= i 3) 'done)    ; stop when true, then return DONE
   (print i)))          ; the body
```

```text
0
1
2
DONE
```

Each variable is written `(name start step)`. Before each pass, `do` checks the test. When it is true, `do` returns the value after it. Most programmers reach for `loop` instead, so you only need to be able to read `do`.

== `loop`: one macro, many clauses

`loop` reads almost like English. It is built from #emph[clauses]: words such as `for`, `collect` and `when`, each followed by its arguments.

```lisp
(loop for x in '(1 2 3)
      collect (* x 10))
;; => (10 20 30)
```

"For each `x` in the list, collect `x` times ten." `collect` builds the list in order, so no `reverse` is needed. The sections below go through the clauses one group at a time.

=== Counting with `for`

```lisp
(loop for i from 1 to 5 collect i)        ; => (1 2 3 4 5)
(loop for i from 0 below 5 collect i)     ; => (0 1 2 3 4)
(loop for i below 3 collect i)            ; => (0 1 2)
(loop for i from 10 downto 7 collect i)   ; => (10 9 8 7)
(loop for i from 0 to 10 by 5 collect i)  ; => (0 5 10)
```

#[
  #set par(justify: false)
  #table(
    columns: (1.8fr, 6.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Words], [Meaning]),
    [`from n`], [Start at `n` (`0` if left out)],
    [`to n`], [Stop after `n`: `n` is included],
    [`below n`], [Stop before `n`: `n` is left out],
    [`downto n`], [Count down, `n` included],
    [`by n`], [Step by `n` instead of `1`],
  )
]

=== Walking lists and strings

```lisp
(loop for x in '(a b c) collect (list x))     ; => ((A) (B) (C))
(loop for tail on '(a b c) collect tail)      ; => ((A B C) (B C) (C))
(loop for c across "abc" collect c)           ; => (#\a #\b #\c)
```

`in` gives each element. `on` gives each tail of the list: the whole list, then its `rest`, then the `rest` of that. `across` walks a string, one character at a time.

`by` works on lists too. It takes the function used to move forward, `cdr` by default:

```lisp
(loop for x in '(a 1 b 2 c 3) by #'cddr collect x)   ; => (A B C)
```

=== Taking elements apart

The variable after `for` can be a pattern. Each element is split up to fit it:

```lisp
(loop for (name . score) in '((ada . 90) (alan . 72))
      collect name)
;; => (ADA ALAN)

(loop for (a b) in '((1 2) (3 4))
      collect (+ a b))
;; => (3 7)
```

The first pattern matches dotted pairs, the shape of an alist. The second matches two-element lists. This is the cleanest way to walk an alist.

=== Several `for` clauses

With two `for` clauses, both step together, and the loop stops when either one runs out:

```lisp
(loop for x in '(a b c)
      for i from 1
      collect (cons i x))
;; => ((1 . A) (2 . B) (3 . C))
```

`for i from 1` has no end, so the list decides when to stop.

=== `for` with `=`: computed values

`for var = start then next` starts with one value and computes each later value from the previous one:

```lisp
(loop for n = 1 then (* n 2)
      repeat 5
      collect n)
;; => (1 2 4 8 16)
```

`repeat 5` stops the loop after five passes. Without `then`, the expression after `=` is evaluated again on every pass:

```lisp
(loop for x in '(1 2 3)
      for square = (* x x)
      collect square)
;; => (1 4 9)
```

=== Collecting results

#[
  #set par(justify: false)
  #table(
    columns: (1.9fr, 6.1fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Clause], [Result]),
    [`collect x`], [A list of every `x`, in order],
    [`append x`], [The lists `x` joined into one list],
    [`sum x`], [The total],
    [`count x`], [How many times `x` was true],
    [`maximize x`], [The largest `x`],
    [`minimize x`], [The smallest `x`],
  )
]

```lisp
(loop for x in '(1 2 3) sum x)                ; => 6
(loop for x in '(1 2 3 4) count (evenp x))    ; => 2
(loop for x in '(3 9 2) maximize x)           ; => 9
(loop for x in '((a b) (c)) append x)         ; => (A B C)
```

`maximize` and `minimize` on an empty list give a result the standard leaves open, so check for an empty list first.

=== Choosing elements: `when`, `unless`, `if`

```lisp
(loop for x in '(1 2 3 4 5)
      when (evenp x) collect x)
;; => (2 4)
```

A `when` clause controls only the clause right after it. To control two, join them with `and`:

```lisp
(print
 (loop for x in '(1 2 3 4)
       when (evenp x) collect x and do (print x)))
```

```text
2
4
(2 4)
```

`if` has an `else`. With `into`, each `collect` fills its own named list:

```lisp
(loop for x in '(1 2 3 4)
      if (evenp x) collect x into evens
      else collect x into odds
      finally (return (list evens odds)))
;; => ((2 4) (1 3))
```

With `into`, `loop` no longer returns the list by itself. The `finally` clause runs once after the last pass, and `(return ...)` inside it sets the value of the whole `loop`.

=== Running code: `do`

`do` inside a `loop` runs ordinary Lisp forms on every pass. It may be followed by several forms:

```lisp
(loop for x in '(1 2)
      do (princ "item: ")
         (princ x)
         (print 'done))
```

```text
item: 1
DONE item: 2
DONE 
```

`print` starts with a newline and ends with a space, which explains the odd layout. A `loop` with only `do` returns `nil`.

=== Local variables: `with`

```lisp
(loop with total = 0
      for x in '(1 2 3)
      do (incf total x)
      finally (return total))
;; => 6
```

`with` makes a variable once, before the first pass. Here `sum` would be shorter, but `with` helps when the work doesn't fit one of the collecting clauses.

=== Stopping: `while`, `until`, `return`

```lisp
(loop for x in '(1 2 3 -1 4)
      while (plusp x)
      collect x)
;; => (1 2 3)

(loop for x in '(1 3 4 5)
      when (evenp x) return x)
;; => 4
```

`while` stops as soon as its test is false, `until` as soon as its test is true. `return` as a clause leaves the loop with a value. You can also write the Lisp form `(return x)` inside a `do`.

=== Yes-or-no questions: `always`, `never`, `thereis`

```lisp
(loop for x in '(1 2 3) always (plusp x))               ; => T
(loop for x in '(1 2 3) never (> x 5))                  ; => T
(loop for x in '(a 7 b) thereis (and (numberp x) x))    ; => 7
```

These are `every`, `notany` and `some` from Chapter 10, as clauses. `thereis` returns the first true value, like `some`.

=== Clause order

Put `with` and `for` clauses first, then everything else: `repeat`, `while`, `when`, `collect`, `do` and the rest. The Common Lisp standard requires this order, and some implementations complain if you break it.

== Which one to use

#[
  #set par(justify: false)
  #table(
    columns: (6.5fr, 1.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Job], [Use]),
    [A result for every element], [`mapcar`],
    [Keep, find, count with one predicate], [Chapter 10's functions],
    [Effects for each element, such as printing], [`dolist`],
    [Something `n` times], [`dotimes`],
    [Counting ranges, several lists at once, filtering and collecting together, early exit with a result], [`loop`],
    [Trees, nested structure], [Recursion (Chapter 8)],
  )
]

These overlap. `(mapcar #'twice lst)` and `(loop for x in lst collect (twice x))` do the same job. Pick the one that reads most clearly.

== Common mistakes

=== Expecting `dolist` to return results

```text
(dolist (x '(1 2 3)) (* x 2))   ; => NIL
```

The body's values are thrown away. Use `mapcar`, or `(loop for x in lst collect (* x 2))`.

=== `to` versus `below`

`(loop for i from 0 to 3 collect i)` gives four numbers, `(0 1 2 3)`. To match `nth` positions in a three-element list, use `below 3`.

=== `in` on a string

```text
(loop for c in "abc" collect c)
;; error: The value "abc" is not of type LIST
```

`in` walks lists. Strings need `across`.

=== Forgetting `do`

```text
(loop for x in '(1 2 3) (print x))
;; error: (PRINT X) found where a LOOP keyword was expected
```

Plain Lisp forms inside a `loop` go after `do`.

=== `finally` without `return`

```text
(loop with total = 0
      for x in '(1 2 3)
      do (incf total x)
      finally total)    ; => NIL
```

`finally` runs its forms, but their value is thrown away. Write `finally (return total)`.

=== `return` inside nested loops

`return` leaves only the innermost loop. To leave the function, use `return-from` with the function's name.

=== `when` controlling one clause only

In `when (evenp x) collect x do (print x)`, the `print` runs for every `x`, even or odd. Join the clauses with `and` when both belong to the `when`.

== Project step: a transcript and a shorter report

`play` from Chapter 9 returns a list of replies. A real game prints each command and its reply as it goes. That's a job for `dolist`, because the work is printing, not building a list.

`terpri` prints a newline. Its name is an old abbreviation of "terminate print line".

```lisp
(defun transcript (commands)
  "Run each command in COMMANDS, printing it and its reply."
  (dolist (command commands)
    (princ "> ")
    (princ command)
    (terpri)
    (princ (run-command command))
    (terpri)))
```

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))

(transcript '((take key) (take key) (inventory)))
```

```text
> (TAKE KEY)
You take the key.
> (TAKE KEY)
You already have that.
> (INVENTORY)
You are carrying: key.
```

`princ` prints the command list in upper case, because that's how Lisp stores the symbols (Chapter 3). The reply strings print as written.

Next, `item-report` from Exercise 8.10 walked the alist by hand and used `caar` and `cdar` to reach inside each pair. A destructuring `loop` names the two halves directly:

```lisp
(defun item-report (pairs)
  "Return one string per item in PAIRS, saying where it is."
  (loop for (item . place) in pairs
        collect (if (eq place 'player)
                    (concatenate 'string (item-name item) " is carried")
                    (concatenate 'string
                                 (item-name item)
                                 " is in the "
                                 (string-downcase (symbol-name place))))))
```

If you skipped Exercise 8.10, this definition is complete on its own.

```lisp
(defparameter *item-locations*
  '((coin . player)
    (lamp . cellar)
    (key . kitchen)))
(item-report *item-locations*)
;; => ("coin is carried" "lamp is in the cellar" "key is in the kitchen")
```

== Exercises

#exercise("11.1")[
  Predict the result of each line, then check:

  ```text
  (loop for i from 1 to 4 collect (* i i))
  (loop for i below 4 sum i)
  (loop for x in '(a b c) for i from 0 collect (list i x))
  (loop for tail on '(1 2 3) collect (length tail))
  (dolist (x '(1 2 3)) x)
  (loop for x in '(5 8 2 9) count (> x 4))
  (loop for c across "hello" count (char= c #\l))
  ```

]

#exercise("11.2")[
  Write `sum-to`, which adds the numbers from 1 to `n` using `dotimes`. `(sum-to 10)` gives `55` and `(sum-to 0)` gives `0`.

]

#exercise("11.3")[
  Rewrite `count-vowels` from Exercise 10.6 with `loop` and `across`.

]

#exercise("11.4")[
  Write `range`, which returns the integers from `start` up to, but not including, `end`. `(range 2 5)` gives `(2 3 4)`.

]

#exercise("11.5")[
  Write `first-repeat`, which returns the first element of a list that appears again later in the list, or `nil` if there is none. `(first-repeat '(a b c b a))` gives `A`. Hint: `for tail on`.

]

#exercise("11.6")[
  Write `split`, which returns a list of two lists: the numbers in a list, then everything else. `(split '(a 1 b 2 3))` gives `((1 2 3) (A B))`.

]

#exercise("11.7")[
  Each expression below is wrong. Say what's wrong, then fix it.

  ```text
  (loop for i from 1 to 3 (print i))

  (dolist (x '(1 2 3)) (* x 2))   ; meant to return (2 4 6)

  (loop for c in "abc" collect (char-upcase c))

  (loop with total = 0
        for x in '(1 2 3)
        do (incf total x)
        finally total)
  ```

]

#exercise("11.8")[
  Write `take-while`, which returns the elements at the front of a list that a predicate says yes to, and stops at the first one it says no to. `(take-while #'plusp '(1 3 -1 2))` gives `(1 3)`. Use `loop` with `while`.

]

#exercise("11.9")[
  Use `loop` with a destructuring pattern to build the alist `((ADA . 90) (ALAN . 72))` from the two lists `'(ada alan)` and `'(90 72)`, in one expression.

]

#exercise("11.10")[
  Predict `T` or `NIL`, or the value, for each, then check:

  ```text
  (loop for x in '(2 4 6) always (evenp x))
  (loop for x in '(1 2 3) never (minusp x))
  (loop for x in '(a b 3 c) thereis (numberp x))
  (loop for x in '(2 4) always (evenp x) finally (return 'checked))
  ```

  Careful with the last one: does `finally` run after `always` stops the loop early?

]

#exercise("11.11", project: true)[
  Write `describe-all`, which prints one line per room in `*rooms*`, saying which items lie there, using `dolist` and `items-here`. Lines for empty rooms should say so:

  ```text
  BEDROOM: letter
  KITCHEN: key
  HALLWAY: nothing
  GARDEN: nothing
  ```

]

#exercise("11.12", project: true)[
  Change `transcript` so that it prints a header line `"You are in the kitchen."` before the commands, and a footer line `"Game over."` after them, using a `let` around the `dolist`. Then write `count-unknown`, which takes a list of commands and returns how many of them `run-command` doesn't recognise. `run-command` returns a string for every command, so compare each reply with the unknown message using `string`.

]

