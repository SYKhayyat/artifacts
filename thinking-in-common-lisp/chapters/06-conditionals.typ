#import "../lib.typ": *

= Conditionals

Programs need to make choices: is the exit open, is the score high enough, did the player type a real command. This chapter covers every way Lisp makes a choice.

== True and false, again

From Chapter 2:

- `nil` means false.
- Every other value means true. `t` is the usual way to write "true", but `0`, `""` and `'(a)` are all true as well.

This is different from Python, where `0` and `""` are false. In Lisp, only `nil` (the empty list) is false.

== `if`

```lisp
(if (> 5 3)
    "bigger"
    "not bigger")      ; => "bigger"
```

The shape:

```text
(if test
    then-expression     ← evaluated when test is true
    else-expression)    ← evaluated when test is nil
```

`if` is a special operator. It does #strong[not] evaluate all its arguments like a function would. It evaluates the test first, then #strong[only one] of the other two. You can see this:

```lisp
(if t
    (print "then")
    (print "else"))
```

Only `"then"` is printed. The else part never runs.

`if` returns the value of whichever branch ran. That makes it an expression, like Java's `test ? a : b`, and you can use it anywhere a value goes:

```lisp
(defun describe-number (n)
  (concatenate 'string
               "The number is "
               (if (evenp n) "even" "odd")))

(describe-number 7)    ; => "The number is odd"
```

The else part can be left out. Then `if` returns `nil` when the test fails:

```lisp
(if (> 1 5) "yes")     ; => NIL
```

== `progn`: several expressions where one is expected

Each branch of `if` is a single expression. To do two things in a branch, wrap them in `progn`:

```lisp
(if (> 5 3)
    (progn
      (print "5 is bigger")
      (print "doing a second thing"))
    (print "not bigger"))
```

`progn` runs its expressions in order and returns the value of the last one. You've seen this behaviour before: the body of `let` and `defun` works the same way. `progn` gives you that behaviour anywhere.

== `when` and `unless`

When there is no else part, `when` is clearer than `if`, and its body can hold several expressions without `progn`:

```lisp
(when (> 5 3)
  (print "5 is bigger")
  (print "no progn needed"))
```

`unless` is the opposite: it runs its body when the test is `nil`.

```lisp
(unless (> 1 5)
  "1 is not bigger than 5")   ; => "1 is not bigger than 5"
```

Both return `nil` when the body doesn't run.

How to choose:

#[
  #set par(justify: false)
  #table(
    columns: (1.0fr, 7.0fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Use], [When]),
    [`if`], [You need both a "then" and an "else"],
    [`when`], [Only a "then", especially with several steps],
    [`unless`], [Only something to do when the test fails],
  )
]

== `not`, `and`, `or`

```lisp
(not nil)              ; => T
(not 5)                ; => NIL
(and (> 5 3) (< 1 2))  ; => T
(or (> 1 5) (< 1 2))   ; => T
```

`not` turns true into `nil` and `nil` into `t`. `and` and `or` take any number of arguments.

Two things make them more useful than Java's `&&` and `||`.

=== They stop early

`and` stops at the first `nil`. `or` stops at the first true value. The rest isn't evaluated:

```lisp
(or t (print "never printed"))
```

Nothing is printed. This lets you guard a test:

```lisp
(defun safe-divide-check (a b)
  (and (/= b 0) (> (/ a b) 1)))

(safe-divide-check 10 0)   ; => NIL  (no division by zero)
(safe-divide-check 10 2)   ; => T
```

When `b` is `0`, `and` stops before dividing.

=== They return real values

`or` returns the first true value itself, not just `t`. `and` returns the last value if all are true:

```lisp
(or nil 5 10)          ; => 5
(or nil nil)           ; => NIL
(and 1 2 3)            ; => 3
(and 1 nil 3)          ; => NIL
```

A common use of `or` is a fallback value:

```lisp
(defun display-name (name)
  (or name "stranger"))

(display-name "Ada")   ; => "Ada"
(display-name nil)     ; => "stranger"
```

== `cond`: many choices

When there are more than two choices, nested `if` gets hard to read. `cond` lists the choices one after another:

```lisp
(defun temperature-word (degrees)
  (cond ((< degrees 0)  "freezing")
        ((< degrees 15) "cold")
        ((< degrees 25) "mild")
        (t              "hot")))

(temperature-word -5)   ; => "freezing"
(temperature-word 20)   ; => "mild"
(temperature-word 31)   ; => "hot"
```

The shape:

```text
(cond (test1 expression ...)   ← a clause: a test, then a body
      (test2 expression ...)
      (t     expression ...))  ← t is always true: the "otherwise"
```

`cond` tries each test from the top. At the first test that is true, it runs that clause's body and returns its last value. It ignores every clause after it. That's why the order matters: `20` is also less than `25`, but the `"cold"` test failed first and the `"mild"` test matched.

The final `(t ...)` clause catches everything else. If no clause matches and there's no `t` clause, `cond` returns `nil`.

A clause body can hold several expressions, like `when`:

```lisp
(let ((n 7))
  (cond ((evenp n)
         (print "even")
         (print "divisible by two"))
        (t
         (print "odd"))))
```

Note the doubled parentheses at the start of each clause: one pair opens the clause, the next opens the test.

== `case`: choosing by exact value

When every test is "is this value equal to X?", `case` is shorter:

```lisp
(defun day-number (day)
  (case day
    (monday 1)
    (tuesday 2)
    (wednesday 3)
    (otherwise 0)))

(day-number 'tuesday)  ; => 2
(day-number 'sunday)   ; => 0
```

`case` evaluates `day` once, then compares it to the key at the start of each clause. The keys are #strong[not evaluated], so you don't quote them: write `monday`, not `'monday`. `otherwise` catches everything else. (`t` works too, but `otherwise` is clearer.)

A clause can match several keys if you put them in a list:

```lisp
(defun weekend-p (day)
  (case day
    ((saturday sunday) t)
    (otherwise nil)))

(weekend-p 'sunday)    ; => T
(weekend-p 'monday)    ; => NIL
```

`case` compares with the same test as `eq` for symbols, and it also works for numbers and characters:

```lisp
(defun vowel-p (letter)
  (case (char-downcase letter)
    ((#\a #\e #\i #\o #\u) t)
    (otherwise nil)))

(vowel-p #\E)          ; => T
```

`case` does #strong[not] work with strings. `"yes"` and `"yes"` are two separate string objects, and `case` doesn't look inside them. For strings, use `cond` with `string=`.

== `member`: is it in the list?

One more function belongs here, because it's the most common test in the project:

```lisp
(member 'b '(a b c))   ; => (B C)
(member 'z '(a b c))   ; => NIL
```

`member` looks for an element in a list. If it finds it, it returns the rest of the list starting from that element. If not, it returns `nil`. Since any non-`nil` value is true, you can use it as a yes\/no test:

```lisp
(if (member 'garden '(hallway garden))
    "you can go there"
    "no way through")  ; => "you can go there"
```

Like `case`, `member` works for symbols, numbers and characters, but not for strings. Part IV shows how to make it work with strings.

== Choosing the right tool

#[
  #set par(justify: false)
  #table(
    columns: (6.2fr, 1.8fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Situation], [Use]),
    [Two choices], [`if`],
    [Do something only when true], [`when`],
    [Do something only when false], [`unless`],
    [Three or more choices with different tests], [`cond`],
    [Three or more choices by exact value], [`case`],
    [Combine tests], [`and`, `or`, `not`],
    [A default value], [`or`],
  )
]

== Common mistakes

- #strong[Several expressions in an `if` branch:] `(if test (print "a") (print "b") (print "c"))` is an error: "too many elements". `if` takes exactly a test and up to two branches. Use `progn`, or `when` if there is no else part.
- #strong[Treating `0` or `""` as false:] `(if 0 "yes" "no")` gives `"yes"`. Use `(zerop n)` or `(string= s "")` to test for them.
- #strong[Forgetting the extra parentheses in `cond`:] `(cond (< x 0) "negative")` reads `<` as the test, which is a variable that doesn't exist. Each clause needs its own pair: `(cond ((< x 0) "negative"))`.
- #strong[Putting a general test before a specific one in `cond`:] the first matching clause wins. Test `(< n 0)` before `(< n 15)`, not after.
- #strong[Quoting `case` keys:] `(case day ('monday 1))`. The key becomes the list `(quote monday)`, and SBCL warns about a duplicate key. Write `(case day (monday 1))`.
- #strong[Using `case` with strings:] `(case "yes" ("yes" 1))` never matches. Use `cond` with `string=`.
- #strong[Forgetting the default:] a `cond` with no `t` clause, or a `case` with no `otherwise`, quietly returns `nil` when nothing matches. Add a default that returns something meaningful.
- #strong[Expecting `member` to return `T`:] it returns part of the list. That's still true. Don't compare its result with `t`.

== Project step: moving between rooms

The player should only walk through real exits. To move, the game needs two things: a way to get from a room's #emph[name] to its #emph[list], and a check that the name is one of the current room's exits.

First, the lookup. `case` matches the name to the right variable:

```lisp
(defun find-room (name)
  "Return the room whose name is NAME, or NIL if there is none."
  (case name
    (bedroom *bedroom*)
    (hallway *hallway*)
    (kitchen *kitchen*)
    (garden *garden*)
    (otherwise nil)))
```

```lisp
(room-description (find-room 'hallway))
;; => "A narrow hallway with creaky floorboards."
```

Now the move. `cond` handles the three possible situations:

```lisp
(defun go-to (name)
  "Move the player to the room called NAME, if it is an exit."
  (cond ((eq name (room-name *current-room*))
         "You are already there.")
        ((member name (room-exits *current-room*))
         (setf *current-room* (find-room name))
         (look))
        (t
         "You can't go there from here.")))
```

The second clause has two expressions: it changes the room, then returns the new description.

Play a few moves:

```lisp
(setf *current-room* *bedroom*)
(list (go-to 'garden)
      (go-to 'hallway)
      (go-to 'kitchen)
      (go-to 'kitchen))
```

The result is a list of four answers:

```text
("You can't go there from here."
 "You are in the Hallway. A narrow hallway with creaky floorboards."
 "You are in the Kitchen. A warm kitchen that smells of bread."
 "You are already there.")
```

The bedroom has no exit to the garden, so the first move fails. Each later move starts from where the last one left the player.

The game now has rules. In Part II you'll learn how lists are really built, and the rooms will move out of separate variables into one list the game can search.

== Exercises

#exercise("6.1")[
  Write a function `sign` that returns the symbol `negative`, `zero` or `positive` for a number.

]

#exercise("6.2")[
  Predict the result of each line, then check:

  ```text
  (if nil 1 2)
  (if 0 1 2)
  (when (> 1 2) 'yes)
  (unless (> 1 2) 'yes)
  (if (member 3 '(1 2 3)) 'found 'missing)
  ```

]

#exercise("6.3")[
  Write `my-abs`, which returns the absolute value of a number, using `if` and without using `abs`.

]

#exercise("6.4")[
  Write `grade`, which takes a score from 0 to 100 and returns the symbol `a` for 90 and above, `b` for 80 to 89, `c` for 70 to 79 and `f` for anything lower.

]

#exercise("6.5")[
  Write `day-type` using `case`. It returns `weekend` for `saturday` and `sunday`, `weekday` for `monday` to `friday`, and `unknown` for anything else.

]

#exercise("6.6")[
  Each listing has a mistake. Run it, read the error or the wrong result, and fix it.

  ```text
  (let ((x 5))
    (if (> x 0)
        (print "positive")
        (print "big")
        (print "negative")))

  (cond (> 5 0) 'yes)

  (let ((answer "yes"))
    (case answer
      ("yes" 1)
      (otherwise 0)))
  ```

  In the first listing, the intent is: when `x` is positive, print both `"positive"` and `"big"`. Otherwise print `"negative"`.

  In the third listing, the intent is to return `1` when `answer` is `"yes"`.

]

#exercise("6.7")[
  Predict the result of each line:

  ```text
  (or nil "" 5)
  (and 1 0 nil)
  (or (member 'x '(a b)) 'none)
  (and 'a 'b)
  (not 0)
  ```

]

#exercise("6.8")[
  Write `fizzbuzz-word`, which takes a number and returns:

  - `"FizzBuzz"` if it divides by both 3 and 5,
  - `"Fizz"` if it divides by 3,
  - `"Buzz"` if it divides by 5,
  - otherwise, the number as a string, such as `"7"`.

  Hint: a number divides by 3 when `(mod n 3)` is zero.

]

#exercise("6.9", project: true)[
  Write `can-go-p`, which takes a room name and returns exactly `T` if it is an exit of the current room, and `NIL` if not. It must not return a piece of the exit list the way `member` does.

]

#exercise("6.10", project: true)[
  The garden door is locked. Make a global variable `*garden-unlocked*` that starts as `nil`. Then write a new `go-to` that answers `"The garden door is locked."` when the player tries to enter the garden while it is still locked. Every other move must work as before.

]

