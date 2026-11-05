#import "../lib.typ": *

= Answers to Exercises

Each answer has a solution, test lines to paste under your own answer, and the result you should see.

== How to use these answers

Each answer gives a solution, a #strong[check] to run, and the #strong[expected] result. To check your own answer:

+ Run your answer block.
+ Make a new block under it, paste the check lines, and run it.
+ Compare with the expected result.

For exercises where the answer is a single expression, the check is simply running your expression. Your code may look different from the solution and still be right. Only the result has to match.

== Chapter 1

#soln("1.1")[
  ```lisp
  (* 7 24 60)
  ```

  Expected: `10080`

  `*` takes any number of arguments, so you don't need to nest `(* 7 (* 24 60))`. That version works too.

]

#soln("1.2")[
  ```lisp
  (* (- 10 4) (+ 3 2))
  ```

  Expected: `30`

]

#soln("1.3")[
  ```lisp
  (- (/ 100 (* 2 5)) 3)
  ```

  Expected: `7`

  Work from the inside out: `(* 2 5)` is `10`, `(/ 100 10)` is `10`, and `(- 10 3)` is `7`.

]

#soln("1.4")[
  ```lisp
  (princ "Welcome, traveller.")
  ```

  Expected: `Welcome, traveller.`

  You need `:results output`. Without it, the block shows the value that `princ` returns, which is the string with quotes.

]

#soln("1.5")[
  #table(
    columns: (1.4fr, 5.1fr, 1.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Wrong], [Problem], [Fixed]),
    [`(5 * 3)`], [The operator must come first], [`(* 5 3)`],
    [`(+2 3)`], [`+2` reads as the number 2. A space is needed], [`(+ 2 3)`],
    [(+ 1 `(* 2 3)`], [Missing a closing parenthesis], [`(+ 1 (* 2 3))`],
    [`(* 2, 4)`], [Commas don't separate arguments], [`(* 2 4)`],
  )

]

== Chapter 2

#soln("2.1")[
  #table(
    columns: (1.6fr, 0.9fr, 5.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`'(+ 2 3)`], [`(+ 2 3)`], [Quoted, so not evaluated],
    [`(list '+ 2 3)`], [`(+ 2 3)`], [`list` builds the same list from its arguments],
    [`(+ 2 3)`], [`5`], [A normal call],
  )

  The first two give the same list in two different ways. This is the point of the exercise: code and data look the same in Lisp.

]

#soln("2.2")[
  ```lisp
  (list (third '(a b c d))
        (nth 2 '(a b c d))
        (first (rest (rest '(a b c d)))))
  ```

  Expected: `(C C C)`

  Any three working ways are fine. `(second (rest '(a b c d)))` is another.

]

#soln("2.3")[
  ```lisp
  (first (last '(red green blue)))
  ```

  Expected: `BLUE`

  `(third '(red green blue))` also works. `(last ...)` alone gives `(BLUE)`, a list, which is the trap this exercise sets.

]

#soln("2.4")[
  ```lisp
  (reverse (append '(1 2 3) '(4 5 6)))
  ```

  Expected: `(6 5 4 3 2 1)`

  Another way: `(append (reverse '(4 5 6)) (reverse '(1 2 3)))`.

]

#soln("2.5")[
  #table(
    columns: (2.9fr, 0.7fr, 4.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(listp nil)`], [`T`], [`nil` is the empty list],
    [`(null '(nil))`], [`NIL`], [A list holding one element is not empty],
    [`(length '((a b) (c d e)))`], [`2`], [Two elements, each of which is a list],
    [`(rest '(only))`], [`NIL`], [Nothing after the first element],
  )

  The second one catches many people. `(nil)` is a list with one element, which happens to be `nil`. It isn't empty.

]

#soln("2.6")[
  ```lisp
  (second (second '(garden (kitchen shed))))
  ```

  Expected: `SHED`

  The inner `second` gives the exits, `(KITCHEN SHED)`. The outer one picks the second exit.

]

== Chapter 3

#soln("3.1")[
  ```lisp
  (+ 2/3 1/4)
  ```

  Expected: `11/12`

  ```lisp
  (float (+ 2/3 1/4))
  ```

  Expected: `0.9166667`

]

#soln("3.2")[
  #table(
    columns: (1.2fr, 0.7fr, 6.0fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(/ 10 4)`], [`5/2`], [Integer division is exact and reduces 10\/4 to 5\/2],
    [`(/ 10 4.0)`], [`2.5`], [One float makes the result a float],
    [`(mod 10 4)`], [`2`], [10 = 2 × 4 + 2],
    [`(isqrt 50)`], [`7`], [7 × 7 = 49 fits in 50. 8 × 8 = 64 doesn't],
  )

]

#soln("3.3")[
  ```lisp
  (subseq "I love Lisp" 7)
  ```

  Expected: `"Lisp"`

  Count from zero: `I` is 0, the space is 1, `love` is 2 to 5, the second space is 6, and `L` is 7. `(subseq "I love Lisp" 7 11)` also works.

]

#soln("3.4")[
  ```lisp
  (concatenate 'string
               (string-upcase "hello")
               ", "
               (string-upcase "world")
               "!")
  ```

  Expected: `"HELLO, WORLD!"`

  This is shorter: upper-case once, after joining.

  ```lisp
  (string-upcase (concatenate 'string "hello" ", " "world" "!"))
  ```

]

#soln("3.5")[
  ```lisp
  (list (digit-char-p #\7)
        (char-code (char-upcase #\b)))
  ```

  Expected: `(7 66)`

  `(char-upcase #\b)` gives `#\B`, and the code of `B` is `66`, one more than `A` (65).

]

#soln("3.6")[
  #table(
    columns: (3.1fr, 0.7fr, 4.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(eq 'Apple 'APPLE)`], [`T`], [Symbol names become upper case when read],
    [`(string= "Apple" "APPLE")`], [`NIL`], [Strings keep their case. `string=` checks it],
    [`(string-equal "Apple" "APPLE")`], [`T`], [`string-equal` ignores case],
    [`(symbol-name :north)`], [`"NORTH"`], [The colon isn't part of the name],
  )

]

#soln("3.7")[
  ```lisp
  (concatenate 'string
               "You are in the "
               (string-capitalize
                (symbol-name
                 (first '(garden "An overgrown garden." (kitchen shed)))))
               ". "
               (second '(garden "An overgrown garden." (kitchen shed))))
  ```

  Expected: "You are in the Garden. An overgrown garden."

  It's the same shape as the kitchen example in the chapter, with the garden list in place of the kitchen list. Typing the room twice is still clumsy. Chapter 4 fixes that.

]

== Chapter 4

#soln("4.1")[
  ```lisp
  (defparameter *apples* 12)
  (defparameter *pears* 8)
  (+ *apples* *pears*)
  ```

  Expected: `20`

  ```lisp
  (setf *pears* 20)
  (+ *apples* *pears*)
  ```

  Expected: `32`

]

#soln("4.2")[
  Expected: `NORMAL`

  #table(
    columns: (2.9fr, 1.5fr, 3.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Line], [`*mode*` after it], [Why]),
    [`(defvar *mode* 'easy)`], [`EASY`], [First definition],
    [`(setf *mode* 'hard)`], [`HARD`], [`setf` changes it],
    [`(defvar *mode* 'easy)`], [`HARD`], [Already defined, so `defvar` skips it],
    [`(defparameter *mode* 'normal)`], [`NORMAL`], [`defparameter` always sets it],
    [`(defvar *mode* 'easy)`], [`NORMAL`], [Already defined again],
  )

  If you ran these in a session where `*mode*` already existed, the first line also does nothing. Restart Lisp to see the table exactly.

]

#soln("4.3")[
  ```lisp
  (let ((width 8)
        (height 5))
    (list (* width height)
          (* 2 (+ width height))))
  ```

  Expected: `(40 26)`

]

#soln("4.4")[
  ```lisp
  (let* ((celsius 30)
         (fahrenheit (+ (* celsius 9/5) 32)))
    (list celsius fahrenheit))
  ```

  Expected: `(30 86)`

  `9/5` is a ratio, so the result stays exact: 30 × 9\/5 is 54, plus 32 is 86. A plain `let` fails here, because `fahrenheit` uses `celsius`.

]

#soln("4.5")[
  ```lisp
  (defparameter *steps* 0)
  (incf *steps*)
  (incf *steps*)
  (incf *steps*)
  (incf *steps* 10)
  ```

  Expected: `13`

  The last `incf` returns the new value, so the block shows it. Adding `*steps*` as a final line gives the same result.

]

#soln("4.6")[
  #table(
    columns: (2.3fr, 3.3fr, 2.4fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Wrong], [Problem], [Fixed]),
    [`(let (total 10) total)`], [Each binding needs its own parentheses], [`(let ((total 10)) total)`],
    [`(let ((a 3) (b (* a a))) b)`], [`b` uses `a` from the same `let`], [`(let* ((a 3) (b (* a a))) b)`],
    [`(* '*apples* 2)`], [The quote gives the name, not the value], [`(* *apples* 2)`],
  )

  Check the fixed versions:

  ```lisp
  (list (let ((total 10)) total)
        (let* ((a 3) (b (* a a))) b)
        (* *apples* 2))
  ```

  Expected: `(10 9 24)` (with `*apples*` at 12 from Exercise 4.1)

]

#soln("4.7")[
  Expected: `11`

  The outer `x` is 5. The inner `let` binds a new `x` to 5 × 2 = 10. `setf` changes the inner `x` to 11, and the body returns it.

  With `(list x)` after the inner `let`:

  ```lisp
  (let ((x 5))
    (let ((x (* x 2)))
      (setf x (+ x 1)))
    (list x))
  ```

  Expected: `(5)`

  The `setf` changed only the inner `x`. Once the inner `let` ends, the outer `x` is visible again, and it was never touched. It is still `5`.

]

#soln("4.8")[
  ```lisp
  (setf *current-room* *kitchen*)

  (let ((name (first *current-room*))
        (exits (third *current-room*)))
    (list name (length exits)))
  ```

  Expected: `(KITCHEN 2)`

  The exits are the third element of a room, `(HALLWAY GARDEN)`, and `length` counts them.

]

== Chapter 5

#soln("5.1")[
  ```lisp
  (defun square (n)
    (* n n))
  ```

  Check:

  ```lisp
  (list (square 4) (square -3) (square 1/2))
  ```

  Expected: `(16 9 1/4)`

]

#soln("5.2")[
  ```lisp
  (defun average3 (a b c)
    "Return the average of A, B and C."
    (/ (+ a b c) 3))
  ```

  Check:

  ```lisp
  (list (average3 1 2 3) (average3 1 2 4) (float (average3 1 2 4)))
  ```

  Expected: `(2 7/3 2.3333333)`

  The result is exact. 7\/3 isn't an error, it's the true average.

]

#soln("5.3")[
  ```lisp
  (defun greet (name)
    (concatenate 'string "Hello, " (string-upcase name) "!"))
  ```

  Check:

  ```lisp
  (greet "ada")
  ```

  Expected: `"Hello, ADA!"`

]

#soln("5.4")[
  ```lisp
  (defun power-of (base &optional (exponent 2))
    (expt base exponent))
  ```

  Check:

  ```lisp
  (list (power-of 5) (power-of 2 10) (power-of 3 0))
  ```

  Expected: `(25 1024 1)`

]

#soln("5.5")[
  ```lisp
  (defun make-greeting (name &key (greeting "Hello") (punctuation "!"))
    (concatenate 'string greeting ", " name punctuation))
  ```

  Check:

  ```lisp
  (list (make-greeting "Ada")
        (make-greeting "Ada" :greeting "Welcome")
        (make-greeting "Ada" :punctuation "?" :greeting "Ready"))
  ```

  Expected: `("Hello, Ada!" "Welcome, Ada!" "Ready, Ada?")`

  The keywords can come in any order. The third call gives `:punctuation` first and still works.

]

#soln("5.6")[
  ```lisp
  (defun count-args (&rest things)
    (length things))
  ```

  Check:

  ```lisp
  (list (count-args) (count-args 'a) (count-args 1 2 3 4 5))
  ```

  Expected: `(0 1 5)`

  With no arguments, `things` is the empty list, so its length is 0.

]

#soln("5.7")[
  #table(
    columns: (2.0fr, 4.2fr, 1.8fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Wrong], [Problem], [Fixed]),
    [`(defun add (a b) (+ a b c))`], [`c` isn't a parameter. SBCL warns "undefined variable: C"], [`(defun add (a b) (+ a b))`],
    [`(defun (twice n) (* 2 n))`], [The name and the parameter list are separate parts], [`(defun twice (n) (* 2 n))`],
    [`(add 1)`], [`add` needs two arguments: "invalid number of arguments: 1"], [`(add 1 2)`],
  )

  Check the fixed versions:

  ```lisp
  (defun add (a b) (+ a b))
  (defun twice (n) (* 2 n))
  (list (add 1 2) (twice 21))
  ```

  Expected: `(3 42)`

]

#soln("5.8")[
  ```lisp
  (defun exit-count (place)
    (length (room-exits place)))

  (defun room-title (place)
    (string-capitalize (symbol-name (room-name place))))
  ```

  Check (run the project blocks from Chapter 5 first):

  ```lisp
  (list (exit-count *hallway*)
        (exit-count *garden*)
        (room-title *kitchen*))
  ```

  Expected: `(2 1 "Kitchen")`

  You can now use `room-title` inside `describe-room`, which makes it shorter:

  ```lisp
  (defun describe-room (place)
    "Return the text shown when the player is in PLACE."
    (concatenate 'string
                 "You are in the " (room-title place) ". "
                 (room-description place)))
  ```

  Small functions that each do one thing, built on each other, are how Lisp programs are written.

]

== Chapter 6

#soln("6.1")[
  ```lisp
  (defun sign (n)
    (cond ((< n 0) 'negative)
          ((= n 0) 'zero)
          (t 'positive)))
  ```

  Check:

  ```lisp
  (list (sign -4) (sign 0) (sign 9))
  ```

  Expected: `(NEGATIVE ZERO POSITIVE)`

  `(zerop n)` works in place of `(= n 0)`.

]

#soln("6.2")[
  #table(
    columns: (3.8fr, 0.6fr, 3.7fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(if nil 1 2)`], [`2`], [`nil` is false],
    [`(if 0 1 2)`], [`1`], [`0` is not `nil`, so it's true],
    [`(when (> 1 2) 'yes)`], [`NIL`], [The test fails, so the body doesn't run],
    [`(unless (> 1 2) 'yes)`], [`YES`], [`unless` runs when the test fails],
    [`(if (member 3 '(1 2 3)) 'found 'missing)`], [`FOUND`], [`member` returns `(3)`, which is true],
  )

]

#soln("6.3")[
  ```lisp
  (defun my-abs (n)
    (if (< n 0)
        (- n)
        n))
  ```

  Check:

  ```lisp
  (list (my-abs -7) (my-abs 0) (my-abs 3/2))
  ```

  Expected: `(7 0 3/2)`

  `(- n)` with one argument negates, as in the Chapter 3 table.

]

#soln("6.4")[
  ```lisp
  (defun grade (score)
    (cond ((>= score 90) 'a)
          ((>= score 80) 'b)
          ((>= score 70) 'c)
          (t 'f)))
  ```

  Check:

  ```lisp
  (list (grade 95) (grade 90) (grade 85) (grade 72) (grade 40))
  ```

  Expected: `(A A B C F)`

  The order does the work. A score of 85 fails the first test and passes the second, so you never need to write "between 80 and 89".

]

#soln("6.5")[
  ```lisp
  (defun day-type (day)
    (case day
      ((saturday sunday) 'weekend)
      ((monday tuesday wednesday thursday friday) 'weekday)
      (otherwise 'unknown)))
  ```

  Check:

  ```lisp
  (list (day-type 'sunday) (day-type 'wednesday) (day-type 'funday))
  ```

  Expected: `(WEEKEND WEEKDAY UNKNOWN)`

]

#soln("6.6")[
  First block. `if` got four arguments after the test, so SBCL complains that there are too many. Group the two prints with `progn`:

  ```lisp
  (let ((x 5))
    (if (> x 0)
        (progn
          (print "positive")
          (print "big"))
        (print "negative")))
  ```

  Expected output:

  ```text
  "positive" 
  "big" 
  ```

  Second block. Without the extra parentheses, `cond` takes `>` as the test and tries to look up a variable called `>`: "The variable \> is unbound". Each clause needs its own pair:

  ```lisp
  (cond ((> 5 0) 'yes))
  ```

  Expected: `YES`

  Third block. It returns `0`, not an error. `case` can't match strings, so the `"yes"` clause never matches. Use `cond` with `string=`:

  ```lisp
  (let ((answer "yes"))
    (cond ((string= answer "yes") 1)
          (t 0)))
  ```

  Expected: `1`

]

#soln("6.7")[
  Check all five at once:

  ```lisp
  (list (or nil "" 5)
        (and 1 0 nil)
        (or (member 'x '(a b)) 'none)
        (and 'a 'b)
        (not 0))
  ```

  Expected: `("" NIL NONE B NIL)`

  #table(
    columns: (2.9fr, 0.6fr, 4.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(or nil "" 5)`], [`""`], [`""` is the first true value, so `or` stops there],
    [`(and 1 0 nil)`], [`NIL`], [One argument is `nil`],
    [`(or (member 'x '(a b)) 'none)`], [`NONE`], [`member` gives `nil`, so `or` moves on],
    [`(and 'a 'b)`], [`B`], [All true, so `and` returns the last value],
    [`(not 0)`], [`NIL`], [`0` is true, so `not` gives `nil`],
  )

]

#soln("6.8")[
  ```lisp
  (defun fizzbuzz-word (n)
    (cond ((zerop (mod n 15)) "FizzBuzz")
          ((zerop (mod n 3)) "Fizz")
          ((zerop (mod n 5)) "Buzz")
          (t (princ-to-string n))))
  ```

  Check:

  ```lisp
  (list (fizzbuzz-word 1)
        (fizzbuzz-word 3)
        (fizzbuzz-word 5)
        (fizzbuzz-word 15)
        (fizzbuzz-word 7))
  ```

  Expected: `("1" "Fizz" "Buzz" "FizzBuzz" "7")`

  The test for 15 must come first. If the test for 3 came first, 15 would give `"Fizz"`. `(and (zerop (mod n 3)) (zerop (mod n 5)))` also works as the first test.

]

#soln("6.9")[
  ```lisp
  (defun can-go-p (name)
    "Return T if NAME is an exit of the current room, NIL otherwise."
    (if (member name (room-exits *current-room*))
        t
        nil))
  ```

  Check (run the Chapter 4 to 6 project blocks first):

  ```lisp
  (setf *current-room* *hallway*)
  (list (can-go-p 'kitchen) (can-go-p 'garden))
  ```

  Expected: `(T NIL)`

  A shorter version is `(not (null (member ...)))`: `null` turns the result into `t` or `nil` the wrong way round, and `not` flips it back.

]

#soln("6.10")[
  ```lisp
  (defparameter *garden-unlocked* nil)

  (defun go-to (name)
    "Move the player to the room called NAME, if it is an exit."
    (cond ((eq name (room-name *current-room*))
           "You are already there.")
          ((and (eq name 'garden) (not *garden-unlocked*))
           "The garden door is locked.")
          ((member name (room-exits *current-room*))
           (setf *current-room* (find-room name))
           (look))
          (t
           "You can't go there from here.")))
  ```

  Check:

  ```lisp
  (setf *current-room* *kitchen*)
  (setf *garden-unlocked* nil)
  (list (go-to 'garden)
        (progn
          (setf *garden-unlocked* t)
          (go-to 'garden)))
  ```

  Expected:

  ```text
  ("The garden door is locked."
   "You are in the Garden. An overgrown garden.")
  ```

  The new clause goes #strong[before] the `member` clause. If it came after, the `member` clause would match first and the lock would never be checked.

  Arguments to `list` are evaluated left to right, so the first `go-to` runs while the door is still locked, and the `progn` unlocks it before the second one.

  Part II rebuilds `go-to` from scratch, so it doesn't matter whether you keep this version or the chapter's.

]

== Chapter 7

#soln("7.1")[
  ```lisp
  (list (cons 1 (cons 2 (cons 3 nil)))
        (cons 'a (cons (cons 'b (cons 'c nil)) nil)))
  ```

  Expected: `((1 2 3) (A (B C)))`

  The diagram for `(A (B C))`:

  ```text
  +---+---+   +---+---+
  | A | *-+-->| * |NIL|
  +---+---+   +-+-+---+
                |
                v
              +---+---+   +---+---+
              | B | *-+-->| C |NIL|
              +---+---+   +---+---+
  ```

  The outer list has two conses, so two elements. The car of the second one points to the inner list `(B C)`.

]

#soln("7.2")[
  ```lisp
  (list (cons 'a 'b)
        (cons '(a) '(b))
        (cons nil nil)
        (cdr '(a))
        (car '((x y) z)))
  ```

  Expected: `((A . B) ((A) B) (NIL) NIL (X Y))`

  #table(
    columns: (1.9fr, 0.8fr, 5.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(cons 'a 'b)`], [`(A . B)`], [The cdr isn't a list, so it's a dotted pair],
    [`(cons '(a) '(b))`], [`((A) B)`], [The element `(A)` goes on the front of `(B)`],
    [`(cons nil nil)`], [`(NIL)`], [A one-element list whose element is `nil`],
    [`(cdr '(a))`], [`NIL`], [Only one cons, and its cdr is the end],
    [`(car '((x y) z))`], [`(X Y)`], [The first element is itself a list],
  )

]

#soln("7.3")[
  ```lisp
  (list (caddr '(a b c d))
        (cddr '(a b c d))
        (cdar '((a . 1) (b . 2))))
  ```

  Expected: `(C (C D) 1)`

  Read `cdar` right to left: the car gives `(A . 1)`, and its cdr is `1`.

]

#soln("7.4")[
  ```lisp
  (defun swap-pair (pair)
    (cons (cdr pair) (car pair)))
  ```

  Check:

  ```lisp
  (list (swap-pair '(1 . 2)) (swap-pair '(key . kitchen)))
  ```

  Expected: `((2 . 1) (KITCHEN . KEY))`

]

#soln("7.5")[
  ```lisp
  (defparameter *s* '(x))
  (push 'y *s*)
  (push 'z *s*)
  (list (pop *s*) *s*)
  ```

  Expected: `(Z (Y X))`

  After both pushes, `*s*` is `(Z Y X)`. `pop` returns `Z` and leaves `(Y X)`. The arguments of `list` run left to right, so `*s*` is read after the `pop`.

]

#soln("7.6")[
  ```lisp
  (defparameter *capitals*
    '((tunisia . tunis)
      (france . paris)
      (japan . tokyo)))

  (defun capital-of (country)
    (or (cdr (assoc country *capitals*))
        'unknown))
  ```

  Check:

  ```lisp
  (list (capital-of 'japan) (capital-of 'tunisia) (capital-of 'peru))
  ```

  Expected: `(TOKYO TUNIS UNKNOWN)`

]

#soln("7.7")[
  #table(
    columns: (2.8fr, 2.8fr, 2.4fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Wrong], [Problem], [Fixed]),
    [`(cons '(1 2) '(3 4))`], [`cons` adds `(1 2)` as one element], [`(append '(1 2) '(3 4))`],
    [`(cdr (assoc "b" '(("a" . 1) ("b" . 2))))`], [`assoc` can't compare strings], [`(cdr (assoc 'b '((a . 1) (b . 2))))`],
    [`(push 'x '(a b))`], [`push` needs a variable to store the result], [`(cons 'x '(a b))`],
  )

  Check the fixed versions:

  ```lisp
  (list (append '(1 2) '(3 4))
        (cdr (assoc 'b '((a . 1) (b . 2))))
        (cons 'x '(a b)))
  ```

  Expected: `((1 2 3 4) 2 (X A B))`

  If you really want `push`, put the list in a variable first: `(let ((l '(a b))) (push 'x l))` also gives `(X A B)`.

]

#soln("7.8")[
  ```lisp
  (defun drop (item)
    "Put down ITEM in the current room, if the player carries it."
    (if (eq (item-location item) 'player)
        (progn
          (push (cons item (room-name *current-room*)) *item-locations*)
          (concatenate 'string "You drop the " (item-name item) "."))
        "You don't have that."))
  ```

  Check. This resets the items, so run it as one block:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (setf *current-room* (find-room 'kitchen))
  (list (drop 'key)
        (take 'key)
        (progn
          (go-to 'hallway)
          (drop 'key))
        (item-location 'key))
  ```

  Expected:

  ```text
  ("You don't have that." "You take the key." "You drop the key." HALLWAY)
  ```

  The key was taken in the kitchen and dropped in the hallway. The `progn` moves the player first, then drops the key, and returns the drop message.

]

#soln("7.9")[
  ```lisp
  (push '(shed "A wooden shed full of old tools." (garden)) *rooms*)
  (push '(garden "An overgrown garden." (kitchen shed)) *rooms*)
  ```

  Check:

  ```lisp
  (setf *current-room* (find-room 'garden))
  (go-to 'shed)
  ```

  Expected: `"You are in the Shed. A wooden shed full of old tools."`

  The new garden replaces the old one because `assoc` returns the #emph[first] pair with a matching key. The new garden is at the front of `*rooms*`, so `find-room` finds it before the old one. The old garden is still in the list, hidden.

  The `setf` must come #emph[after] the pushes. If `*current-room*` was set to the garden earlier, it still holds the old garden list, whose exits don't include the shed, and `go-to` answers "You can't go there from here."

  Each push adds to `*rooms*` again, so running this block twice puts two copies at the front. That's harmless, because only the first one is ever found. Re-run the `defparameter` for `*rooms*` from the project step to start clean.

]

== Chapter 8

#soln("8.1")[
  ```lisp
  (defun my-length (lst)
    "Return the number of elements in LST."
    (if (null lst)
        0
        (+ 1 (my-length (rest lst)))))
  ```

  Check:

  ```lisp
  (list (my-length nil) (my-length '(a)) (my-length '(a b c d)))
  ```

  Expected: `(0 1 4)`

  The empty list is the base case: zero elements. Otherwise, one for the first element plus the length of the rest.

]

#soln("8.2")[
  ```lisp
  (defun my-sum (lst)
    "Return the sum of the numbers in LST."
    (if (null lst)
        0
        (+ (first lst) (my-sum (rest lst)))))
  ```

  Check:

  ```lisp
  (list (my-sum nil) (my-sum '(5)) (my-sum '(1 2 3 4)))
  ```

  Expected: `(0 5 10)`

  The base case is `0`, because adding nothing gives zero. Compare that with `my-length`: the same shape, a different "nothing" value.

]

#soln("8.3")[
  ```lisp
  (list (count-atoms '(a (b) c))
        (countdown 3)
        (factorial 4)
        (items-in '((lamp . cellar) (key . kitchen)) 'kitchen)
        (double-all-into '(1 2) nil))
  ```

  Expected: `(3 (3 2 1) 24 (KEY) (4 2))`

  #table(
    columns: (2.5fr, 0.6fr, 4.9fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(count-atoms '(a (b) c))`], [`3`], [`a`, `b` and `c`: three atoms, at any depth],
    [`(countdown 3)`], [`(3 2 1)`], [Counts down and stops at zero],
    [`(factorial 4)`], [`24`], [4 × 3 × 2 × 1],
    [`(items-in ... 'kitchen)`], [`(KEY)`], [Only the pair whose value is `kitchen`],
    [`(double-all-into '(1 2) nil)`], [`(4 2)`], [The accumulator is built backwards, so no `reverse` here],
  )

  The last one is the accumulator pattern without its `reverse`. Running `double-all` instead gives `(2 4)`, because `double-all` reverses the result of the helper.

]

#soln("8.4")[
  ```lisp
  (defun my-reverse-into (lst result)
    "Cons each element of LST onto RESULT."
    (if (null lst)
        result
        (my-reverse-into (rest lst)
                         (cons (first lst) result))))

  (defun my-reverse (lst)
    "Return LST in the opposite order."
    (my-reverse-into lst nil))
  ```

  Check:

  ```lisp
  (list (my-reverse nil) (my-reverse '(1 2 3)) (my-reverse '(a)))
  ```

  Expected: `(NIL (3 2 1) (A))`

  No `reverse` is needed at the end, because walking from the front and consing onto the accumulator already reverses the list. That's the whole job here, so the helper's result #strong[is] the answer.

]

#soln("8.5")[
  ```lisp
  (defun my-find (item lst)
    "Return ITEM if it is in LST, NIL otherwise."
    (cond ((null lst) nil)
          ((eq (first lst) item) item)
          (t (my-find item (rest lst)))))
  ```

  Check:

  ```lisp
  (list (my-find 'b '(a b c))
        (my-find 'a '(a b c))
        (my-find 'z '(a b c))
        (my-find 'x nil))
  ```

  Expected: `(B A NIL NIL)`

  Compare this with the built-in `member` from Chapter 6: `member` returns the rest of the list from the match onward, and `my-find` returns just the item. Both are useful.

]

#soln("8.6")[
  ```lisp
  (defun count-symbol (sym tree)
    "Return how often SYM appears in TREE, at any depth."
    (cond ((null tree) 0)
          ((consp tree) (+ (count-symbol sym (car tree))
                           (count-symbol sym (cdr tree))))
          ((eq tree sym) 1)
          (t 0)))
  ```

  Check:

  ```lisp
  (list (count-symbol 'a '(a (b a) c a))
        (count-symbol 'a '(x y))
        (count-symbol 'a 'a)
        (count-symbol 'a nil))
  ```

  Expected: `(3 0 1 0)`

]

#soln("8.7")[
  ```lisp
  (defun flatten (tree)
    "Return the atoms of TREE as one flat list."
    (cond ((null tree) nil)
          ((consp tree) (append (flatten (car tree))
                                (flatten (cdr tree))))
          (t (list tree))))
  ```

  Check:

  ```lisp
  (list (flatten '(a (b (c)) d))
        (flatten '())
        (flatten '(1 (2 (3 (4))))))
  ```

  Expected: `((A B C D) NIL (1 2 3 4))`

  Two recursive calls again, one for each half of the cons. The last clause wraps the atom in a list, because the answer must always be a list: `(flatten 'a)` would otherwise return the atom `A`, and `append` would refuse it.

  `append` copies every cons of the lists it is given (Chapter 7), so this version is fine for the sizes in this guide, and slow on very large trees.

]

#soln("8.8")[
  #strong[Wrong:] `bad-length` throws away the recursive result, so it returns `0` for every list. The recursive call has to add one:

  ```lisp
  (defun fix-length (lst)
    (if (null lst)
        0
        (+ 1 (fix-length (rest lst)))))
  ```

  #strong[Wrong:] `bad-sum` has the wrong base case. Adding a number to `nil` gives "The value NIL is not a NUMBER" as soon as the recursion ends:

  ```lisp
  (defun fix-sum (lst)
    (if (null lst)
        0
        (+ (first lst) (fix-sum (rest lst)))))
  ```

  #strong[Wrong:] `bad-countdown` uses `(1+ n)`, so it walks away from zero and never reaches the base case. SBCL prints "Control stack exhausted". The input must get smaller:

  ```lisp
  (defun fix-countdown (n)
    (if (zerop n)
        nil
        (cons n (fix-countdown (1- n)))))
  ```

  Check all three:

  ```lisp
  (list (fix-length '(a b c))
        (fix-sum '(1 2 3))
        (fix-countdown 3))
  ```

  Expected: `(3 6 (3 2 1))`

  With `(1- n)` in place, the third one walks down from `3` to `0`, which is four calls. The broken version needs a million calls to fill the stack, so never run it to see what happens.

]

#soln("8.9")[
  ```lisp
  (defun count-conses (tree)
    "Return the number of cons cells in TREE."
    (cond ((null tree) 0)
          ((consp tree) (+ 1 (count-conses (car tree))
                            (count-conses (cdr tree))))
          (t 0)))
  ```

  Check:

  ```lisp
  (list (count-conses '(a b))
        (count-conses '((a) b))
        (count-conses 5)
        (count-conses nil))
  ```

  Expected: `(2 3 0 0)`

  `(a b)` is two conses, as Chapter 7's box diagram shows. `((a) b)` has one cons for the outer pair, one for the inner `(a)`, and one for the chain `(b)`: three. An atom has none, and `nil` isn't a cons either.

]

#soln("8.10")[
  ```lisp
  (defun item-report (pairs)
    "Return one string per item in PAIRS, saying where it is."
    (cond ((null pairs) nil)
          ((eq (cdar pairs) 'player)
           (cons (concatenate 'string
                              (item-name (caar pairs))
                              " is carried")
                 (item-report (cdr pairs))))
          (t
           (cons (concatenate 'string
                              (item-name (caar pairs))
                              " is in the "
                              (string-downcase
                               (symbol-name (cdar pairs))))
                 (item-report (cdr pairs))))))
  ```

  Check. This resets the items and marks one as carried, so run it as one block:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (push '(coin . player) *item-locations*)
  (item-report *item-locations*)
  ```

  Expected:

  ```text
  ("coin is carried"
   "lamp is in the cellar"
   "key is in the kitchen"
   "letter is in the bedroom")
  ```

  Three clauses, three jobs: stop at the end, one wording for items the player carries, another for items in a room. The order of the result follows the order of the alist, because the recursion walks it from the front.

]

#soln("8.11")[
  ```lisp
  (defun item-names (items)
    "Return a string listing ITEMS by name."
    (cond ((null items) "")
          ((null (cdr items))
           (item-name (first items)))
          ((null (cddr items))
           (concatenate 'string
                        (item-name (first items))
                        " and "
                        (item-name (second items))))
          (t
           (concatenate 'string
                        (item-name (first items))
                        ", "
                        (item-names (rest items))))))
  ```

  Check:

  ```lisp
  (list (item-names nil)
        (item-names '(key))
        (item-names '(key lamp))
        (item-names '(key lamp coin))
        (item-names '(key lamp coin box)))
  ```

  Expected:

  ```text
  ("" "key" "key and lamp" "key, lamp and coin" "key, lamp, coin and box")
  ```

  `cddr` is "the rest of the rest", from Chapter 7. When it is `nil`, the list has exactly two elements left, and that's the moment to write "and" instead of a comma. The last two elements are always handled by that clause, whichever call reaches them.

]

#soln("8.12")[
  ```lisp
  (defun take-all (items)
    "Take every item in ITEMS."
    (cond ((null items) nil)
          (t (take (first items))
             (take-all (rest items)))))

  (defun loot ()
    "Take everything lying in the current room."
    (let ((found (items-here (room-name *current-room*))))
      (if (null found)
          "There is nothing here to take."
          (progn
            (take-all found)
            (concatenate 'string
                         "You take "
                         (item-names found)
                         ".")))))
  ```

  Check. Reset the items and walk to the kitchen first:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (setf *current-room* (find-room 'kitchen))
  (list (loot) (loot) (inventory))
  ```

  Expected:

  ```text
  ("You take key."
   "There is nothing here to take."
   "You are carrying: key.")
  ```

  The second `loot` finds nothing, because the first one moved the key into the player's hands.

  `take-all` walks `found`, the list that `items-here` built before anything was taken. `take` replaces `*item-locations*` with a new list, but `found` is a separate list, so the walk isn't affected.

  This answer needs the fixed `take` from the end of the Chapter 8 project step. With the old `take`, the second `loot` still finds the hidden `(KEY . KITCHEN)` pair and says "You take key." again.

]

== Chapter 9

#soln("9.1")[
  ```lisp
  (list (funcall #'list 1 2)
        (apply #'* 2 '(3 4))
        (mapcar #'length '((a) (b c) ()))
        (mapcar (lambda (x) (cons x x)) '(a b))
        (apply-twice (lambda (s) (concatenate 'string s "!")) "hi"))
  ```

  Expected: `((1 2) 24 (1 2 0) ((A . A) (B . B)) "hi!!")`

  #table(
    columns: (3.1fr, 1.8fr, 3.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(funcall #'list 1 2)`], [`(1 2)`], [Same as `(list 1 2)`],
    [`(apply #'* 2 '(3 4))`], [`24`], [Same as `(* 2 3 4)`],
    [`(mapcar #'length ...)`], [`(1 2 0)`], [One length per inner list],
    [`(mapcar (lambda (x) ...) ...)`], [`((A . A) (B . B))`], [Each symbol consed onto itself],
    [`(apply-twice ...)`], [`"hi!!"`], [One `"!"` per call, two calls],
  )

]

#soln("9.2")[
  ```lisp
  (defun my-mapcar (f lst)
    "Return a list of the results of calling F on each element of LST."
    (if (null lst)
        nil
        (cons (funcall f (first lst))
              (my-mapcar f (rest lst)))))
  ```

  Check:

  ```lisp
  (list (my-mapcar #'twice '(1 2 3))
        (my-mapcar #'first '((a 1) (b 2)))
        (my-mapcar #'twice nil))
  ```

  Expected: `((2 4 6) (A B) NIL)`

  This is `double-all` from Chapter 8 with `(twice (first lst))` replaced by `(funcall f (first lst))`. Notice that the recursive call passes `f` along unchanged.

]

#soln("9.3")[
  ```lisp
  (mapcar (lambda (name)
            (concatenate 'string "Hello, " (string-capitalize name)))
          '("ada" "alan" "grace"))
  ```

  Expected: `("Hello, Ada" "Hello, Alan" "Hello, Grace")`

]

#soln("9.4")[
  ```lisp
  (defun make-multiplier (factor)
    "Return a function that multiplies its argument by FACTOR."
    (lambda (n) (* n factor)))
  ```

  Check:

  ```lisp
  (list (funcall (make-multiplier 3) 7)
        (mapcar (make-multiplier 10) '(1 2 3)))
  ```

  Expected: `(21 (10 20 30))`

  The same shape as `make-adder`: the returned `lambda` remembers `factor`.

]

#soln("9.5")[
  ```lisp
  (defun compose (f g)
    "Return a function that calls G on its argument, then F on the result."
    (lambda (x) (funcall f (funcall g x))))
  ```

  Check:

  ```lisp
  (list (funcall (compose #'twice #'1+) 5)
        (funcall (compose #'first #'rest) '(a b c)))
  ```

  Expected: `(12 B)`

  `(1+ 5)` is `6`, doubled is `12`. The second one builds `second` out of `first` and `rest`.

]

#soln("9.6")[
  #strong[Wrong:] `twice` without `#'` is read as a variable, and there is no such variable. Write `(mapcar #'twice '(1 2))`.

  #strong[Wrong:] `(f 10)` looks for a function named `f`. `f` is a variable holding a function, so call it with `funcall`:

  ```lisp
  (defun call-with-ten (f)
    (funcall f 10))
  ```

  #strong[Wrong:] the quote turns the `lambda` into a plain list. Remove it: `(funcall (lambda (x) (+ x 1)) 5)`.

  #strong[Wrong:] the last argument of `apply` must be a list. Either `(apply #'max '(3 7))` or `(funcall #'max 3 7)`.

  Check the fixes:

  ```lisp
  (list (mapcar #'twice '(1 2))
        (call-with-ten #'twice)
        (funcall (lambda (x) (+ x 1)) 5)
        (apply #'max '(3 7)))
  ```

  Expected: `((2 4) 20 6 7)`

]

#soln("9.7")[
  ```lisp
  (defun make-stepper (start step)
    "Return a function that returns START, then START+STEP, and so on."
    (let ((next start))
      (lambda ()
        (let ((current next))
          (incf next step)
          current))))
  ```

  Check:

  ```lisp
  (let ((s (make-stepper 10 5)))
    (list (funcall s) (funcall s) (funcall s)))
  ```

  Expected: `(10 15 20)`

  The inner `let` saves the value to return before `incf` moves `next` forward. Without it, the first call would return `15`.

]

#soln("9.8")[
  ```lisp
  (mapcar #'cons '(a b c) '(1 2 3))
  ```

  Expected: `((A . 1) (B . 2) (C . 3))`

  With two lists, `mapcar` passes one element from each to `cons`, which builds one dotted pair per position.

]

#soln("9.9")[
  Expected: `("HEY" "HEY!")`

  `*table-a*` stored the function object from the first definition, and redefining `shout` doesn't touch it. `*table-b*` stored the name, so `funcall` finds the new definition at the moment of the call. That's why the game's `*commands*` table stores names.

]

#soln("9.10")[
  ```lisp
  (push '(l . look) *commands*)
  (push '(i . inventory) *commands*)
  ```

  Check:

  ```lisp
  (equal (run-command '(i)) (run-command '(inventory)))
  ```

  Expected: `T`

  Both short forms point at existing functions, so `run-command` needs no change. Run the `push` lines once only: running them again adds duplicate pairs. They do no harm here, because `assoc` stops at the first match, but the `help` command of the next exercise would list them twice. To start clean, rerun the `defparameter` of `*commands*` from the project step.

]

#soln("9.11")[
  ```lisp
  (defun help ()
    "List the command words."
    (concatenate 'string
                 "Commands: "
                 (item-names (mapcar #'car *commands*))
                 "."))

  (defparameter *commands*
    '((help . help)
      (look . look)
      (inventory . inventory)
      (take . take)
      (go . go-to)
      (loot . loot))
    "Map each command word to the function that handles it.")
  ```

  Check:

  ```lisp
  (run-command '(help))
  ```

  Expected: `"Commands: help, look, inventory, take, go and loot."`

  `(mapcar #'car *commands*)` gives the list of command words, and `item-names` turns any list of symbols into a string, so it works on commands as well as on items. If you added `drop` or the short forms from Exercise 9.10, they appear in the list too.

  The table is rebuilt with `defparameter` here so that `help` appears first. A `push` would also work.

]

== Chapter 10

#soln("10.1")[
  ```lisp
  (list (remove-if-not #'evenp '(5 6 7 8))
        (find-if #'numberp '(a b 3 c 4))
        (count-if #'symbolp '(a 1 b 2 c))
        (position #\n "banana")
        (reduce #'* '(1 2 3 4))
        (every #'symbolp '())
        (remove-duplicates '(1 2 1 3 2)))
  ```

  Expected: `((6 8) 3 3 2 24 T (1 3 2))`

  #table(
    columns: (3.0fr, 0.8fr, 4.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`(remove-if-not #'evenp ...)`], [`(6 8)`], [Keeps the even numbers],
    [`(find-if #'numberp ...)`], [`3`], [The first number, not all of them],
    [`(count-if #'symbolp ...)`], [`3`], [`a`, `b` and `c`],
    [`(position #\n "banana")`], [`2`], [Counting from zero: b, a, n],
    [`(reduce #'* ...)`], [`24`], [1 × 2 × 3 × 4],
    [`(every #'symbolp '())`], [`T`], [No element says no],
    [`(remove-duplicates ...)`], [`(1 3 2)`], [Keeps the last copy of each by default],
  )

]

#soln("10.2")[
  ```lisp
  (defun sum2 (lst)
    (reduce #'+ lst))

  (defun find2 (item lst)
    (find item lst))

  (defun all-positive2-p (lst)
    (every #'plusp lst))

  (defun reverse2 (lst)
    (reduce (lambda (acc x) (cons x acc)) lst :initial-value nil))
  ```

  Check:

  ```lisp
  (list (sum2 '(1 2 3 4)) (sum2 nil)
        (find2 'b '(a b c))
        (all-positive2-p '(1 2 3)) (all-positive2-p '(1 -2))
        (reverse2 '(1 2 3)))
  ```

  Expected: `(10 0 B T NIL (3 2 1))`

  `sum2` handles the empty list because `(+)` is `0`. `find2` is `find` under a new name, which tells you `my-find` was a hand-written `find`.

]

#soln("10.3")[
  ```lisp
  (remove-if (lambda (w) (< (length w) 4))
             '("a" "lisp" "is" "great"))
  ```

  Expected: `("lisp" "great")`

]

#soln("10.4")[
  ```lisp
  (defparameter *scores* '((ada . 90) (alan . 72) (grace . 85)))

  (list (sort (copy-list *scores*) #'> :key #'cdr)
        (find-if (lambda (s) (< s 80)) *scores* :key #'cdr)
        (reduce #'+ *scores* :key #'cdr)
        *scores*)
  ```

  Expected:

  ```text
  (((ADA . 90) (GRACE . 85) (ALAN . 72))
   (ALAN . 72)
   247
   ((ADA . 90) (ALAN . 72) (GRACE . 85)))
  ```

  The last line shows `*scores*` unchanged, thanks to `copy-list`. Sorting `*scores*` directly would also modify a quoted constant.

]

#soln("10.5")[
  ```lisp
  (defun my-remove-if (pred lst)
    "Return LST without the elements PRED says yes to."
    (cond ((null lst) nil)
          ((funcall pred (first lst))
           (my-remove-if pred (rest lst)))
          (t
           (cons (first lst) (my-remove-if pred (rest lst))))))
  ```

  Check:

  ```lisp
  (list (my-remove-if #'evenp '(1 2 3 4 5))
        (my-remove-if #'evenp nil))
  ```

  Expected: `((1 3 5) NIL)`

  Compare it with `items-in` from Chapter 8: the same three clauses, with a predicate in place of the `eq` test.

]

#soln("10.6")[
  ```lisp
  (defun count-vowels (s)
    "Return the number of vowels in the string S."
    (count-if (lambda (c) (find c "aeiou"))
              (string-downcase s)))
  ```

  Check:

  ```lisp
  (list (count-vowels "Common Lisp")
        (count-vowels "AEIOU")
        (count-vowels "xyz"))
  ```

  Expected: `(3 5 0)`

  `string-downcase` deals with upper case once, so the list of vowels needs only lower-case letters. `find` returns the character when it is a vowel and `nil` otherwise, which is all `count-if` needs.

]

#soln("10.7")[
  ```lisp
  (list (eql 2 2)
        (eql 2 2.0)
        (equal "a" "a")
        (equal '(1 (2)) '(1 (2)))
        (equalp "Lisp" "LISP")
        (eql (list 1) (list 1)))
  ```

  Expected: `(T NIL T T T NIL)`

  `(eql 2 2.0)` is `NIL` because one is an integer and the other a float. The last one is `NIL` because each `list` call builds its own cons, and `eql` asks whether they are the same object.

]

#soln("10.8")[
  #strong[Wrong:] `sort` modifies the quoted constant `'(3 1 2)`. Write `(sort (list 3 1 2) #'<)`.

  #strong[Wrong:] `reduce` on an empty list calls `(max)`, which needs at least one argument. Give a starting value: `(reduce #'max '() :initial-value 0)`.

  #strong[Wrong:] `find` compares with `eql`, and two strings are different objects. Write `(find "b" '("a" "b") :test #'string=)`.

  #strong[Wrong:] `remove-if` returns a new list and leaves `*numbers*` alone. Store the result: `(setf *numbers* (remove-if #'evenp *numbers*))`.

  Check the fixes:

  ```lisp
  (defparameter *numbers* (list 1 2 3 4))
  (list (sort (list 3 1 2) #'<)
        (reduce #'max '() :initial-value 0)
        (find "b" '("a" "b") :test #'string=)
        (setf *numbers* (remove-if #'evenp *numbers*))
        *numbers*)
  ```

  Expected: `((1 2 3) 0 "b" (1 3) (1 3))`

]

#soln("10.9")[
  ```lisp
  (reduce (lambda (a b)
            (if (> (length b) (length a)) b a))
          '("hi" "hello" "hey"))
  ```

  Expected: `"hello"`

  `a` is the longest string so far, `b` the next one. The `lambda` keeps whichever is longer. With `>`, a tie keeps the earlier string.

]

#soln("10.10")[
  ```lisp
  (defun my-every (pred lst)
    "Return T if PRED says yes to every element of LST."
    (not (some (complement pred) lst)))
  ```

  Check:

  ```lisp
  (list (my-every #'plusp '(1 2 3))
        (my-every #'plusp '(1 -2 3))
        (my-every #'plusp '()))
  ```

  Expected: `(T NIL T)`

  "Every element says yes" means "no element says no". `(complement pred)` is the "says no" test, `some` looks for one, and `not` flips the answer. The empty list gives `T`, as `every` does.

]

#soln("10.11")[
  ```lisp
  (defun empty-rooms ()
    "Return the names of the rooms with no items lying in them."
    (remove-if (lambda (name) (items-here name))
               (mapcar #'car *rooms*)))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (empty-rooms)
  ```

  Expected: `(HALLWAY GARDEN)`, with the rooms in the order your `*rooms*` lists them.

  `(mapcar #'car *rooms*)` gives the room names, and `items-here` returns `nil` for an empty room, so `remove-if` drops every room that has something in it. The lamp is in the cellar, which isn't one of the rooms, so it doesn't count.

]

#soln("10.12")[
  ```lisp
  (defun help ()
    "List the command words in alphabetical order."
    (concatenate 'string
                 "Commands: "
                 (item-names
                  (sort (remove-duplicates (mapcar #'car *commands*))
                        #'string<
                        :key #'symbol-name))
                 "."))
  ```

  Check:

  ```lisp
  (run-command '(help))
  ```

  Expected, with the table from Exercise 9.11:

  ```text
  "Commands: go, help, inventory, look, loot and take."
  ```

  If you added the short forms or `drop`, they appear in their alphabetical places. `mapcar` and `remove-duplicates` both build new lists, so `sort` can rearrange the result without touching `*commands*`.

]

== Chapter 11

#soln("11.1")[
  ```lisp
  (list (loop for i from 1 to 4 collect (* i i))
        (loop for i below 4 sum i)
        (loop for x in '(a b c) for i from 0 collect (list i x))
        (loop for tail on '(1 2 3) collect (length tail))
        (dolist (x '(1 2 3)) x)
        (loop for x in '(5 8 2 9) count (> x 4))
        (loop for c across "hello" count (char= c #\l)))
  ```

  Expected: `((1 4 9 16) 6 ((0 A) (1 B) (2 C)) (3 2 1) NIL 3 2)`

  #table(
    columns: (1.6fr, 2.1fr, 4.3fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [Squares, 1 to 4], [`(1 4 9 16)`], [`to` includes 4],
    [`sum` below 4], [`6`], [0 + 1 + 2 + 3],
    [Two `for` clauses], [`((0 A) (1 B) (2 C))`], [Both step together],
    [`for tail on`], [`(3 2 1)`], [Tails of lengths 3, 2, 1],
    [`dolist`], [`NIL`], [`dolist` returns `nil` without a result form],
    [`count`], [`3`], [`5`, `8` and `9` are above `4`],
    [`across` + `count`], [`2`], [Two `l` in "hello"],
  )

]

#soln("11.2")[
  ```lisp
  (defun sum-to (n)
    "Return the sum of the integers from 1 to N."
    (let ((total 0))
      (dotimes (i (1+ n) total)
        (incf total i))))
  ```

  Check:

  ```lisp
  (list (sum-to 10) (sum-to 0))
  ```

  Expected: `(55 0)`

  `dotimes` counts from `0`, so the loop must run `n` plus one times to include `n` itself: `(1+ n)`. The sum starts at `0`, and the first pass adds `0`, which changes nothing. With `loop` the same job is `(loop for i from 0 to n sum i)`, or from 1, since adding 0 is idle work.

]

#soln("11.3")[
  ```lisp
  (defun count-vowels (s)
    "Return the number of vowels in the string S."
    (loop for c across (string-downcase s)
          count (find c "aeiou")))
  ```

  Check:

  ```lisp
  (list (count-vowels "Common Lisp") (count-vowels "xyz"))
  ```

  Expected: `(3 0)`

  `across` walks the string one character at a time, and `count` adds one for every character that `find` locates in `"aeiou"`. The `loop` version is shorter than the `count-if` version and does the same work.

]

#soln("11.4")[
  ```lisp
  (defun range (start end)
    "Return the integers from START up to, not including, END."
    (loop for i from start below end
          collect i))
  ```

  Check:

  ```lisp
  (list (range 2 5) (range 0 3) (range 5 5))
  ```

  Expected: `((2 3 4) (0 1 2) NIL)`

  `below end` is the whole job: it stops before `end`, which is what "up to, but not including" means. When `start` is not below `end`, the loop runs no passes and `collect` builds an empty list. `(range 5 5)` shows that: no error, just `nil`.

]

#soln("11.5")[
  ```lisp
  (defun first-repeat (lst)
    "Return the first element of LST that appears again later."
    (loop for tail on lst
          when (member (first tail) (rest tail))
            return (first tail)))
  ```

  Check:

  ```lisp
  (list (first-repeat '(a b c b a))
        (first-repeat '(a b c))
        (first-repeat '(x x y)))
  ```

  Expected: `(A NIL X)`

  Walking the tails, the question for each tail is "does the rest of the list hold another copy of my first element?" `member` answers that, returning the rest of the list from the match, and `return` as a clause leaves the loop with the element itself.

  The second test is worth reading closely. `(first-repeat '(a b c))` checks `a` against `(b c)`, then `b` against `(c)`, then `c` against `nil`. None match, the loop ends, and a `loop` with no `return` gives `nil`.

]

#soln("11.6")[
  ```lisp
  (defun split (lst)
    "Return two lists: the numbers in LST, then everything else."
    (loop for x in lst
          if (numberp x) collect x into numbers
          else collect x into others
          finally (return (list numbers others))))
  ```

  Check:

  ```lisp
  (list (split '(a 1 b 2 3)) (split '(1 2)) (split nil))
  ```

  Expected: `(((1 2 3) (A B)) ((1 2)) (NIL))`

  With `into`, the two lists are named variables that `finally` hands back. Elements that fail `numberp` go to `others` through the `else`.

]

#soln("11.7")[
  #strong[Wrong:] plain forms after `for` need `do`: `(loop for i from 1 to 3 do (print i))`.

  #strong[Wrong:] `dolist` throws its body's values away. Either `(mapcar (lambda (x) (* x 2)) '(1 2 3))` or `(loop for x in '(1 2 3) collect (* x 2))`.

  #strong[Wrong:] `in` walks lists, and `"abc"` is a string. Use `across`: `(loop for c across "abc" collect (char-upcase c))`.

  #strong[Wrong:] `finally` without `return` gives `nil`. Write `finally (return total)`.

  Check the fixes:

  ```lisp
  (print (loop for i from 1 to 3 do (print i)))
  (print (loop for x in '(1 2 3) collect (* x 2)))
  (print (loop for c across "abc" collect (char-upcase c)))
  (print (loop with total = 0
               for x in '(1 2 3)
               do (incf total x)
               finally (return total)))
  ```

  Expected output:

  ```text
  1
  2
  3
  (1 2 3) 
  (A B C) 
  6 
  ```

  Each `print` of a result ends with a space and no newline, which is why the last three lines sit where they do.

]

#soln("11.8")[
  ```lisp
  (defun take-while (pred lst)
    "Return the front elements of LST that PRED says yes to."
    (loop for x in lst
          while (funcall pred x)
          collect x))
  ```

  Check:

  ```lisp
  (list (take-while #'plusp '(1 3 -1 2))
        (take-while #'plusp '(-1 1))
        (take-while #'plusp '(1 2 3)))
  ```

  Expected: `((1 3) NIL (1 2 3))`

  `while` tests before each pass. When it fails at `-1`, the loop stops and never collects `2`, even though `2` is positive. That is what distinguishes `take-while` from `remove-if-not`: one keeps the front run, the other keeps everything that matches.

]

#soln("11.9")[
  ```lisp
  (loop for name in '(ada alan)
        for score in '(90 72)
        collect (cons name score))
  ```

  Expected: `((ADA . 90) (ALAN . 72))`

  Two `for` clauses step in step, `cons` builds each pair, and `collect` gathers them. The destructuring pattern of Exercise 11.9's question goes the other way: it takes an alist apart, this one builds one.

]

#soln("11.10")[
  ```lisp
  (list (loop for x in '(2 4 6) always (evenp x))
        (loop for x in '(1 2 3) never (minusp x))
        (loop for x in '(a b 3 c) thereis (numberp x))
        (loop for x in '(2 4) always (evenp x) finally (return 'checked)))
  ```

  Expected: `(T T 3 CHECKED)`

  #table(
    columns: (1.6fr, 0.9fr, 5.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`always`], [`T`], [Every element is even],
    [`never`], [`T`], [No element is negative],
    [`thereis`], [`3`], [Returns the value, not just `T`],
    [The last one], [`CHECKED`], [The list ran out, so `always` never said no],
  )

  The last one is the subtle case. On `'(2 4)`, `always` never fails, the list ends, and `finally` runs as usual, returning `CHECKED`. On a list containing an odd number, `always` leaves the loop early and returns `nil` without running `finally`. So `finally` after `always` only runs when the loop survived to the end.

]

#soln("11.11")[
  ```lisp
  (defun describe-all ()
    "Print one line per room, saying what lies in it."
    (dolist (entry *rooms*)
      (let ((name (room-name entry))
            (here (items-here (room-name entry))))
        (princ name)
        (princ ": ")
        (if (null here)
            (princ "nothing")
            (princ (item-names here)))
        (terpri))))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((key . kitchen)
      (letter . bedroom)))
  (describe-all)
  ```

  Expected output, in the order `*rooms*` lists them:

  ```text
  BEDROOM: letter
  HALLWAY: nothing
  KITCHEN: key
  GARDEN: nothing
  CELLAR: nothing
  ```

  `(room-name entry)` is the function from Chapter 5, which pulls the name out of a room entry, so `dolist` walks `*rooms*` and the `let` names the two things each pass needs. `princ` prints the symbols in upper case and the strings as written, exactly as in `transcript`.

  Five lines, not four: `*rooms*` as defined in Chapter 7's project step lists bedroom, hallway, kitchen, garden, and cellar, in that order. If your output has a different order or a missing line, check what your `*rooms*` holds. Exercise 7.9 pushed a shed onto it, if you did that exercise; re-run the Chapter 7 project step's `defparameter` to restore the original five-room list.

]

#soln("11.12")[
  ```lisp
  (defun transcript (commands)
    "Print a header, run each command in COMMANDS, then a footer."
    (princ "You are in the ")
    (princ (room-name *current-room*))
    (princ ".")
    (terpri)
    (dolist (command commands)
      (princ "> ")
      (princ command)
      (terpri)
      (princ (run-command command))
      (terpri))
    (princ "Game over.")
    (terpri))

  (defun count-unknown (commands)
    "Return how many commands in COMMANDS are not recognised."
    (loop for command in commands
          count (string= (run-command command)
                         "I don't know how to do that.")))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (setf *current-room* (find-room 'kitchen))
  (transcript '((take key) (dance)))
  ```

  Expected output:

  ```text
  You are in the kitchen.
  > (TAKE KEY)
  You take the key.
  > (DANCE)
  I don't know how to do that.
  Game over.
  ```

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (setf *current-room* (find-room 'kitchen))
  (count-unknown '((dance) (take key) (fly)))
  ```

  Expected: `2`

  `count-unknown` compares each reply with the exact unknown message using `string`, which is why that message must be spelled the same way in both places. A cleaner design would return a distinctive value for unknown commands, and Chapter 13's `case` or a condition (Chapter 15) would carry that idea further.

]

== Chapter 12

#soln("12.1")[
  ```lisp
  (list (format nil "~A!" 'done)
        (format nil "~S" "hi")
        (format nil "~3D" 7)
        (format nil "~,1F" 2.25)
        (format nil "~A~A" 'a 'b)
        (format nil "a~2%b"))
  ```

  Expected: ("DONE!" "\\"hi\\"" "  7" "2.2" "AB" "a

  b")

  #table(
    columns: (0.7fr, 1.8fr, 5.6fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`~A!`], [`"DONE!"`], [Symbols print in upper case],
    [`~S` on "hi"], [`"\"hi\""`], [The string with its quotes; the backslashes are how the quotes show inside another string],
    [`~3D` on 7], [`"  7"`], [Width 3, padded on the left],
    [`~,1F` on 2.25], [`"2.2"`], [One digit after the point, rounded],
    [`~A~A`], [`"AB"`], [Two arguments, no space unless you type it],
    [`a~2%b`], [Two newlines between a and b], [],
  )

  The second result printed as `"\"hi\""` is worth a second look: the string `format` built contains a quote character, and when the REPL shows that string, it shows its own quotes and escapes.

]

#soln("12.2")[
  ```lisp
  (defun comma-list (symbols)
    "Return SYMBOLS as a lower-case string, separated by commas."
    (format nil "~{~(~A~)~^, ~}" (mapcar #'symbol-name symbols)))
  ```

  Check:

  ```lisp
  (list (comma-list '(a b c)) (comma-list '(x)) (comma-list nil))
  ```

  Expected: `("a, b, c" "x" "")`

  `~{~}` walks the list, `~(~A~)` lower-cases each element, and `~^` puts the separator only between elements. The `mapcar` is there because `symbol-name` must run before the walk; a `:key` style shortcut doesn't exist inside `format`.

]

#soln("12.3")[
  ```lisp
  (format nil "~{~D: ~A~^, ~}" '((1 "one") (2 "two") (3 "three")))
  ```

  Expected: `"1: one, 2: two, 3: three"`

  The walk gives one inner list per pass, and `~D` and `~A` take the two halves apart in order — the same trick the destructuring `loop` did in Chapter 11, expressed inside the control string. `~^` keeps the commas off the last pass.

]

#soln("12.4")[
  ```lisp
  (defun price-line (name price)
    "Return NAME and PRICE as padded columns."
    (format nil "~12A~8,2F" name price))
  ```

  Check:

  ```lisp
  (list (price-line 'coffee 3.5) (price-line 'tea 12))
  ```

  Expected: `("coffee         3.50" "tea            12.00")`

  `~12A` pads the name on the right to width 12, and `~8,2F` shows the price with two decimals in a field of at least 8. The directive reads "width, digits F": the 2 after the comma is the number of decimals from earlier in this chapter, and the 8 before it is the width.

]

#soln("12.5")[
  ```lisp
  (list (format nil "You have ~[no keys~;one key~:;~D keys~]." 0)
        (format nil "You have ~[no keys~;one key~:;~D keys~]." 1)
        (format nil "You have ~[no keys~;one key~:;~D keys~]." 5))
  ```

  Expected:

  ```text
  ("You have no keys." "You have one key." "You have 5 keys.")
  ```

  Clause 0 is `"no keys"`, clause 1 is `"one key"`, and the `:;` clause catches everything else, where `~D` prints the number.

]

#soln("12.6")[
  ```lisp
  (defun pluralise (n noun)
    "Return N and NOUN as a lower-case phrase with the right plural."
    (format nil "~D ~[~(~A~)~:;~(~A~)s~]" n (if (= n 1) 0 1) noun))
  ```

  Check:

  ```lisp
  (list (pluralise 0 'coin) (pluralise 1 'coin) (pluralise 7 'coin))
  ```

  Expected: `("0 coins" "1 coin" "7 coins")`

  `~[` chooses by an integer, but the argument is a number of any size, not an index. The `if` turns it into an index: `0` means "singular clause", `1` means "default (plural) clause". This is the standard way to collapse any count into a yes-or-no choice for `~[`. The `~(~A~)` around the noun lower-cases it, since `COIN` would otherwise print in capitals.

]

#soln("12.7")[
  #strong[Wrong:] two placeholders, one argument. Add an argument or drop an `~A`.

  #strong[Wrong:] the `%` starts a directive. Write `(format nil "50~~ off")`.

  #strong[Wrong:] `~D` takes an integer, and `"three"` is a string. Either pass `3` or use `~A`.

  #strong[Wrong:] `~(= is never closed with =~)`. Also, a case directive doesn't take an argument, so `'world` would be left over. What was meant is `(format nil "~(HELLO~)")`, giving `"hello"`.

]

#soln("12.8")[
  ```lisp
  (defun bar (n)
    "Return a health bar of N filled segments out of 10."
    (format nil "[~A~A]"
            (make-string n :initial-element #\#)
            (make-string (- 10 n) :initial-element #\-)))
  ```

  Check:

  ```lisp
  (list (bar 7) (bar 0) (bar 10))
  ```

  Expected: `("[#######---]" "[----------]" "[##########]")`

  `make-string` builds a string of `n` copies of a character. The tempting one-liner, `(format nil "[~10@A]" (make-string n :initial-element #\#))`, does #emph[not] work: `format`'s padding is always spaces, and there is no directive to change the fill character. Padding with anything else means building the second piece yourself, which the version above does. The exercise's real lesson is that `format` is not a do-everything; when the padding character matters, you write the pieces and let `format` join them.

]

#soln("12.9")[
  ```lisp
  (defun help ()
    "List the command words in alphabetical order."
    (format nil "Commands: ~{~(~A~)~^, ~}."
            (sort (remove-duplicates (mapcar #'car *commands*))
                  #'string< :key #'symbol-name)))
  ```

  Check:

  ```lisp
  (run-command '(help))
  ```

  Expected, with the table from Exercise 9.11:

  ```text
  "Commands: go, help, inventory, look, loot, take."
  ```

  The period after the walk comes from the control string. This reply doesn't use "and" — one walk, one separator, as `item-list-string` explained in the project step. The `item-names` version from Exercise 10.12 remains the better reply for people; this one is the cheaper one to maintain. If you added the short forms or `drop`, they appear in their alphabetical places.

]

#soln("12.10")[
  ```lisp
  (defun item-phrase (items)
    "Return ITEMS as a sentence fragment: \"Key and Letter\" and so on."
    (cond ((null (cddr items))
           (format nil "~{~:(~A~)~^ and ~}" (mapcar #'symbol-name items)))
          (t
           (format nil "~{~:(~A~)~^, ~} and ~:(~A~)"
                   (mapcar #'symbol-name (butlast items))
                   (first (last items))))))

  (defun describe-room-text (room)
    "Return a sentence describing ROOM and what lies there."
    (let ((here (items-here room)))
      (format nil "You are in the ~(~A~). ~:[There is nothing here.~;You see ~A.~]~&"
              room
              here
              (if here (item-phrase here) ""))))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((key . kitchen)
      (letter . bedroom)
      (coin . hallway)))
  (push '(lamp . cellar) *item-locations*)
  (list (describe-room-text 'garden)
        (describe-room-text 'kitchen)
        (describe-room-text 'cellar))
  ```

  Expected:

  ```text
  ("You are in the garden. There is nothing here."
   "You are in the kitchen. You see Key."
   "You are in the cellar. You see Lamp and Coin.")
  ```

  Two new functions appear here, both old friends under other names: `butlast` returns the list without its last element, and `last` returns the last element as a list, which is why `(first (last ...))` takes the element itself. The two-item case has no comma, the three-item case gets `"Key, Letter and Coin"`, and the walk in `item-phrase` handles any longer list the same way.

  Note the split of duties: `item-phrase` decides the wording, `describe-room-text` decides the sentence. That's the same shape as `item-names` and `inventory` from earlier chapters, and it keeps each function small enough to check on its own.

]

== Chapter 13

#soln("13.1")[
  ```lisp
  (defstruct book
    title
    author
    (year nil))

  (defparameter my-book
    (make-book :title "Paradises Lost" :author "Ursula K. Le Guin"))

  (list (book-title my-book)
    (book-year my-book))
  ;; => ("Paradises Lost" NIL)

  (setf (book-year my-book) 1974)

  (list (book-year my-book)
    (book-p my-book)
    (book-p 'book))
  ;; => (1974 T NIL)
  ```

  The `year` field defaults to `nil` because of the slot option, and `book-p` knows the difference between a real book and the symbol named `book`.

]

#soln("13.2")[
  ```lisp
  (list (aref (vector 10 20 30) 2)
    (length (vector 'a 'b))
    (aref "lisp" 0)
    (multiple-value-list (floor 17 5))
    (multiple-value-list (gethash 'x (make-hash-table))))
  ```

  Expected: `(30 2 #\l (3 2) (NIL NIL))`

  #table(
    columns: (2.1fr, 1.2fr, 4.8fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Why]),
    [`aref` on 2], [`30`], [Indexes count from zero],
    [`length` of vector], [`2`], [`length` works on any sequence],
    [`aref` on "lisp"], [`#\l`], [Strings are vectors of characters],
    [`floor`], [`(3 2)`], [Two values: 17 = 5×3 + 2],
    [`gethash` on empty], [`(NIL NIL)`], [No value, and the key was never there],
  )

]

#soln("13.3")[
  ```lisp
  (defparameter prices (make-hash-table :test #'equal))

  (setf (gethash "lamp" prices) 10.0)
  (setf (gethash "key" prices) 2.5)
  (setf (gethash "letter" prices) 0.5)

  (defun total (names)
    "Return the total price of the items named in NAMES."
    (reduce (lambda (sum name)
        (+ sum (gethash name prices 0)))
      names
      :initial-value 0))
  ```

  Check:

  ```lisp
  (total '("lamp" "key"))
  ```

  Expected: `12.5`

  The `:initial-value 0` makes the empty list safe, as Chapter 10 recommended. A `reduce` walks the names and asks the hash table for each price; the hash table's speed doesn't matter at three entries and matters at thirty thousand.

]

#soln("13.4")[
  ```lisp
  (defun hash-keys (table)
    "Return the keys of TABLE as a list."
    (loop for key being the hash-keys of table
      collect key))

  (sort (hash-keys caps) #'string< :key #'symbol-name)
  ```

  `collect` gathers whatever order `maphash`-style walking produces, and `sort` imposes one afterwards. Without the sort, two runs might print the keys differently.

]

#soln("13.5")[
  Wrong: `assoc` walks lists; `caps` is a hash table. Use `(gethash 'one caps)`.

  Wrong: `aref` needs a vector. `(nth 1 '(a b c))` for the list, or `(aref (vector 'a 'b 'c) 1)` for the array.

  Wrong: the default test is `eq`, and two `"a"` strings are different objects. Either `(make-hash-table :test #'equal)` or use symbol keys.

  Wrong: `make-room` takes keyword arguments: `(make-room :name 'kitchen :description "desc" :exits '(west))`.

  Check the fixes:

  ```lisp
  (defparameter caps (make-hash-table))
  (setf (gethash 'one caps) 1)
  (defparameter ages (make-hash-table :test #'equal))
  (setf (gethash "a" ages) 1)

  (list (gethash 'one caps)
    (nth 1 '(a b c))
    (aref (vector 'a 'b 'c) 1)
    (gethash "a" ages)
    (room-name (make-room :name 'kitchen)))
  ```

  Expected: `(1 B B 1 KITCHEN)`

]

#soln("13.6")[
  ```lisp
  (defun oldest (ages)
    "Return the name of the oldest person in the hash table AGES."
    (let ((best-name nil)
        (best-age -1))
      (maphash (lambda (name age)
          (when (> age best-age)
            (setf best-name name)
            (setf best-age age)))
        ages)
      best-name))
  ```

  Check:

  ```lisp
  (defparameter ages (make-hash-table))
  (setf (gethash 'ada ages) 36)
  (setf (gethash 'alan ages) 41)
  (setf (gethash 'grace ages) 45)
  (oldest ages)
  ```

  Expected: `GRACE`

  `maphash` visits entries in unspecified order, so the answer can't depend on the walk finding the biggest first: the `let` variables keep the best seen so far, and ties go to whoever was seen first. This is the accumulator pattern on a hash table.

]

#soln("13.7")[
  ```lisp
  (list (equalp (make-room :name 'a :exits '(n))
      (make-room :name 'a :exits '(n)))
    (eq (make-room :name 'a) (make-room :name 'a))
    (room-p (make-room))
    (eql 1.0 1))
  ```

  Expected: `(T NIL T NIL)`

  `equalp` compares structures field by field, `eq` asks for the same object and each `make-room` builds a fresh one, `room-p` accepts any room even with every field `nil`, and `eql` still refuses to mix integers with floats.

]

#soln("13.8")[
  ```lisp
  (defun invert (table)
    "Return a new hash table with TABLE's keys and values swapped."
    (let ((result (make-hash-table)))
      (maphash (lambda (k v) (setf (gethash v result) k)) table)
      result))
  ```

  Check:

  ```lisp
  (defparameter caps (make-hash-table))
  (setf (gethash 'one caps) 1)
  (setf (gethash 'two caps) 2)

  (list (gethash 1 (invert caps))
    (gethash 2 (invert caps)))
  ```

  Expected: `(ONE TWO)`

  A fresh table, one `maphash` to fill it, and the assumption that no value appears twice holds. If two keys shared a value, one of them would be lost in the swap — the same warning as `remove-duplicates` keeping one copy.

]

#soln("13.9")[
  ```lisp
  (defun go-to (name)
    "Move the player to the room called NAME, if it is an exit."
    (cond ((eq name (room-name current-room))
        "You are already there.")
      ((not (member name (room-exits current-room)))
        "You can't go there from here.")
      ((room-locked (find-room name))
        (format nil "The ~(~A~) is locked." name))
      (t
        (setf current-room (find-room name))
        (look))))
  ```

  Check:

  ```lisp
  (setf current-room (find-room 'kitchen))
  (list (go-to 'garden)
    (setf (room-locked (find-room 'garden)) nil)
    (go-to 'garden)
    (go-to 'hallway))
  ```

  Expected:

  ```text
  ("The garden is locked."
  NIL
  "You are in the Garden. An overgrown garden."
  "You can't go there from here.")
  ```

  The third `go-to` unlocks the garden before trying again; the fourth asks to walk from the garden to the hallway, which isn't an exit. Notice the order of clauses: the "not an exit" check comes before the locked check, so unlocking a room the player can't reach (like a hypothetical locked cellar from the bedroom) still answers "can't go there", not "locked". The chapter 6 hard-coded `eq name 'garden` test is gone; the knowledge lives in the room's slot now.

]

#soln("13.10")[
  ```lisp
  (defun locked-rooms ()
    "Return the names of the locked rooms."
    (mapcar #'room-name
      (remove-if-not #'room-locked rooms)))
  ```

  Check, with the garden locked again:

  ```lisp
  (setf (room-locked (find-room 'garden)) t)
  (locked-rooms)
  ```

  Expected: `(GARDEN)`

  `remove-if-not` keeps the rooms whose `room-locked` is true, and `mapcar` reduces them to names. `room-locked` works directly as a predicate because `nil` is false and `t` is true (Chapter 6).

]

#soln("13.11")[
  The natural way to give rooms an `items` field is to add it to the existing structure, one more redefinition:

  ```lisp
  (defstruct (room (:print-function print-room))
    name
    description
    exits
    (locked nil)
    (items nil))
  ```

  Now the two commands, with the game's alist-based state replaced by a plain list `carrying` and the room's own `items` field:

  ```lisp
  (defparameter carrying nil)

  (defun take-struct (item)
    "Take ITEM from the current room's items field."
    (if (member item (room-items current-room))
      (progn
        (setf (room-items current-room)
          (remove item (room-items current-room)))
        (push item carrying)
        (format nil "You take the ~(~A~)." item))
      "You don't see that here."))

  (defun drop-struct (item)
    "Put ITEM down in the current room."
    (if (member item carrying)
      (progn
        (setf carrying (remove item carrying))
        (push item (room-items current-room))
        (format nil "You drop the ~(~A~)." item))
      "You don't have that."))
  ```

  Check:

  ```lisp
  (setf (room-items (find-room 'kitchen)) '(key lamp))
  (setf current-room (find-room 'kitchen))

  (list (take-struct 'key)
    (take-struct 'key)
    (drop-struct 'key)
    (room-items (find-room 'kitchen))
    carrying)
  ```

  Expected: `("You take the key." "You don't see that here." "You drop the key." (KEY LAMP) NIL)`

  The prose answer is yours to write, but here is what the comparison shows. `take` and `drop` became shorter: each one edits one room's field, and the whole `set-location` copying dance from Chapter 8 disappears, because a structure's field is one mutable slot instead of a shared list that must be rebuilt. What got longer is the data side: rooms must be built with `make-room`, and they can no longer be written as a quoted alist in one line. The general trade: mutable fields simplify the functions that change things and complicate the places where data is created and read back.

  Write your own paragraph here if the comparison sparked other thoughts — that's the point of the exercise. The connection to Chapter 27's plist advice is worth noticing: the items live on the room because the room is a named, owned structure; putting them on the symbol `kitchen` via `setf (get 'kitchen 'items)` would be a plist mistake for the same reasons there discussed.

]

== Chapter 14

#soln("14.1")[
  Expansions:

  ```text
  (twice (princ 'x))
  ;; => (PROGN (PRINC 'X) (PRINC 'X))

  (my-when (> 2 1) (princ 'a))
  ;; => (IF (> 2 1) (PROGN (PRINC 'A)) NIL)

  (swap p q)
  ;; => (LET ((#:G1234 P)) (SETF P Q) (SETF Q #:G1234))

  (square (+ 1 2))
  ;; => (LET ((#:G1235 (+ 1 2))) (* #:G1235 #:G1235))
  ```

  The gensym numbers differ on every run; that's the point.

  Running them, with `(defparameter p 1)` and `(defparameter q 2)` set first: `twice` prints `XX` and returns `X` (the value of `princ`'s last argument); `my-when` prints `A` and returns `A` — the `if`'s then branch is the `progn`'s value, which is `princ`'s return, which is the argument; `swap` exchanges `p` and `q` to `2` and `1`; and `square` evaluates `(+ 1 2)` once and returns `9`.

  ```lisp
  (defparameter p 1)
  (defparameter q 2)
  (swap p q)
  (list p q)
  ```

  Expected: `(2 1)`

  ```lisp
  (twice (princ 'x))
  (terpri)
  (princ (my-when (> 2 1) (princ 'a)))
  ```

  Expected output:

  ```text
  XX
  A
  ```

  The first line is the two `princ` calls from the expansion; the second is the value `my-when` returned, which the REPL did not print because `:results output` shows only what was printed. If you want the return values, drop `:results output` and wrap each form in `list`.

]

#soln("14.2")[
  ```lisp
  (defmacro my-or2 (a b)
    "Return A if true, otherwise B — without evaluating B unless needed."
    (let ((v (gensym)))
      `(let ((,v ,a))
         (if ,v ,v ,b))))
  ```

  Check:

  ```lisp
  (list (my-or2 nil 7)
        (my-or2 3 7)
        (my-or2 nil nil))
  ```

  Expected: `(7 3 NIL)`

  The comment the exercise asks for:

  No function can do this: a function receives both arguments already evaluated, so (my-or-fn (expensive-a) (expensive-b)) would run expensive-b even when expensive-a was true. It also couldn't return a's value as the answer — it can only return what its body chose to return, and by then a's form has already been run to produce the argument.

  The `gensym` stops a caller variable named `v` from colliding, and also evaluates `a` only once — the two purposes, in one binding.

]

#soln("14.3")[
  ```lisp
  (defmacro repeat (n &body body)
    (let ((count (gensym))
          (limit (gensym)))
      `(let ((,limit ,n))
         (dotimes (,count ,limit)
           ,@body))))
  ```

  Check:

  ```lisp
  (repeat (+ 1 2) (princ 'x))
  (terpri)
  (repeat (progn (princ "evaluated ") 3) (princ 'y))
  ```

  Expected output:

  ```text
  XXX
  evaluated YYY
  ```

  The limit form is bound to `,limit` once, in the outer `let` — the `dotimes` then reads a variable, not the form. That's what makes the "evaluated " appear once, not three times. A `loop` version could use `below ,n` directly, which also evaluates once (a `loop` clause evaluates its bound form once, at loop setup), but the `dotimes` version with the explicit `let` makes the once-ness visible in the expansion — which is the teaching point.

]

#soln("14.4")[
  #strong[`first-of`] — the `let` binding `head` collides with a caller variable named `head`. A caller's `(first-of head)` would read its own `head` inside the macro's binding, not the outer one, and the result would be wrong in a way that depends on the caller's local names. Fix:

  ```lisp
  (defmacro first-of (lst)
    (let ((v (gensym)))
      `(let ((,v ,lst))
         (first ,v))))
  ```

  #strong[`inc-twice`] — `,x` appears twice, so the form is evaluated twice. Worse, the expansion's #emph[meaning] shifts with the argument: passing a variable is fine, but passing `(incf n)` increments `n` by one and then adds the result of that to itself; passing an array reference like `(aref *a* 0)` evaluates the access twice. Fix — bind once, then incf the binding:

  ```lisp
  (defmacro inc-twice (x)
    (let ((v (gensym)))
      `(let ((,v ,x))
         (incf ,v ,v)
         ,v)))
  ```

  Note `incf` on `,v` is safe because `v` is a gensym the caller can never pass in. What `inc-twice` means is "add twice the value of `x` to some variable"? No — as written it adds `x` to itself, which is only meaningful when `x` is a place (a `setf`-able expression). The fix above preserves the `place` semantics by evaluating `x` once and then setting it. If the intent was purely "double the value, no side effect", a function would be correct and simpler.

  #strong[`unless-bad`] — `,body` without the `@` inserts the body as #emph[one list], so `(if test nil ((princ 1) (princ 2)))` compiles the body as a function call whose head is `(princ 1)`. Fix:

  ```lisp
  (defmacro unless-fixed (test &body body)
    `(if ,test nil (progn ,@body)))
  ```

]

#soln("14.5")[
  ```lisp
  (defmacro benchmark (form)
    `(progn
       (princ "start ")
       (let ((result ,form))
         (princ "end ")
         result)))
  ```

  Check:

  ```lisp
  (benchmark (+ 1 2))
  ```

  Expected: `3`, with `"start end "` printed to the REPL window (add `:results output` and call `princ` on the result to see both together, since the block otherwise shows only the value `3`).

  The comment the exercise asks for:

  benchmark must be a macro because it needs to wrap the form — put code before and after it, in the same lexical scope — without evaluating the form to pass it in. A function (benchmark (heavy-computation)) would run heavy-computation before benchmark was called; its "start" line would print after the work had already been done. The macro's expansion is what runs, in the caller's environment.

]

#soln("14.6")[
  ```lisp
  (defmacro for-each ((x lst) &body body)
    `(dolist (,x ,lst)
       ,@body))
  ```

  Expansion:

  ```lisp
  (macroexpand-1 '(for-each (r *rooms*) (princ (room-name r))))
  ```

  Expected:

  ```text
  (DOLIST (R *ROOMS*) (PRINC (ROOM-NAME R)))
  ```

  `R` is the pattern variable's name, inserted directly. No gensym is needed here — `dolist` binds `r` as its own local, so a caller's `r` is #emph[shadowed] by the loop binding, not clobbered. The macro-hygiene rule from the chapter is about macros that introduce bindings around the caller's body (like `swap`); a macro that delegates to a standard looping form inherits that form's already-correct scoping.

  Usage:

  ```lisp
  (for-each (room *rooms*)
    (princ (room-name room))
    (terpri))
  ```

  Expected output (with the five-room topology from Chapter 13):

  ```text
  BEDROOM
  HALLWAY
  KITCHEN
  GARDEN
  CELLAR
  ```

]

#soln("14.7")[
  ```lisp
  (defun rewind ()
    "Undo until the history is empty; return a summary message."
    (loop with steps = 0
          while *history*
          do (undo)
             (incf steps)
          finally (return
                   (format nil "Rewound ~D step~:p." steps))))

  (defparameter *commands*
    '((look . look)
      (inventory . inventory)
      (take . take)
      (go . go-to)
      (loot . loot)
      (drop . drop)
      (undo . undo)
      (rewind . rewind)))
  ```

  The `:p` in `~:p` is `format`'s plural directive: it prints `"s"` for any number but `1`, and nothing for `1`. Check:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar) (key . kitchen) (letter . bedroom)))
  (setf *history* nil)
  (setf *current-room* (find-room 'kitchen))

  (list (run-command '(take key))
        (run-command '(take lamp))
        (rewind))
  ```

  Expected: two take messages and `"Rewound 2 steps."` — the rewind rolled back both moves. Run `rewind` on an empty history and it says `"Rewound 0 steps."` — `~:p` prints no `s` there, because 0 isn't 1, but the message reads naturally either way.

  Note what the `while *history*` test does: it stops when the history is empty, so `undo`'s "Nothing to undo." branch is never taken inside the loop. The count reflects moves actually rolled back.

]

#soln("14.8")[
  ```lisp
  (defmacro if-room (name then &body else)
    "If (find-room NAME) succeeds, evaluate THEN with IT bound to it."
    (let ((room-var (gensym)))
      `(let ((,room-var (find-room ,name)))
         (if ,room-var
             (let ((it ,room-var))
               ,then)
             (progn ,@else)))))
  ```

  Check:

  ```lisp
  (list (if-room kitchen
            (format nil "~A is found" (room-name it))
          "No such room.")
        (if-room attic
            "Found"
          "No such room."))
  ```

  Expected: `("KITCHEN is found" "No such room.")`

  The `gensym` hides the room from the caller. `it` is deliberately a readable name, introduced #emph[for] the caller in `then` — a caller with its own variable named `it` is shadowed by the macro's binding, which is the caller's own doing, since `it` is the macro's contract. This is the standard `if-let` shape, and it's exactly the kind of form — a new binding visible in one branch — that no function can create.

]

== Chapter 15

#soln("15.1")[
  ```lisp
  (list (ignore-errors (+ 1 2))
        (ignore-errors (nth 5 '(a b)))
        (handler-case (/ 4 0) (division-by-zero () 'nope))
        (handler-case (car 'sym) (type-error (c) (type-error-datum c))))
  ```

  Expected: `(3 NIL NOPE SYM)`

  `(ignore-errors (+ 1 2))` has no error to ignore, so it returns `3`. `(ignore-errors (nth 5 '(a b)))` — `nth` tolerates an index past the end (it walks to `nil` and returns `nil`), so there's no error to ignore and the answer is just `nil`. `(car 'sym)` is a type error, and the handler pulls the datum out of the condition — `SYM`, the thing that wasn't a list.

  The `warn` form: `(warn "test")` prints a warning line and returns `nil`. The return value is `nil`, not the printed text; `warn`'s job is the message, not the value.

]

#soln("15.2")[
  ```lisp
  (defun safe-nth (index lst)
    "Return the INDEX-th element of LST, or NIL when out of range."
    (handler-case (nth index lst)
      (type-error () nil)))
  ```

  Check:

  ```lisp
  (list (safe-nth 1 '(a b c))
        (safe-nth 5 '(a b c))
        (safe-nth 0 nil)
        (safe-nth -1 '(a b c)))
  ```

  Expected: `(B NIL NIL NIL)`

  `nth` tolerates indexes past the end — it walks until the list runs out and returns `nil` — but a #emph[negative] index is rejected with a `type-error` saying the index is not of type `(UNSIGNED-BYTE ...)`. The handler catches that and returns `nil`, which is the right answer for "I want `nil` when the index doesn't point at an element". If your implementation answers `A` for a negative index, it is not following the standard — SBCL and CCL both signal.

  Which means the exercise is really testing whether you noticed that "out of range" has two senses: too big (silently `nil`) and negative (signals). `safe-nth` catches only the signal, so it answers `nil` for both.

]

#soln("15.3")[
  ```lisp
  (define-condition invalid-move (error)
    ((reason :initarg :reason :reader invalid-move-reason))
    (:report (lambda (condition stream)
               (format stream "You can't do that: ~A."
                       (invalid-move-reason condition)))))

  (defun check-move (direction)
    "Signal INVALID-MOVE unless DIRECTION is an exit."
    (unless (member direction (room-exits *current-room*))
      (error 'invalid-move
             :reason (format nil "no exit ~(~A~)" direction)))
    direction)

  (defun try-move (direction)
    "Return DIRECTION when it works, else the reason it doesn't."
    (handler-case (check-move direction)
      (invalid-move (c) (invalid-move-reason c))))
  ```

  Check:

  ```lisp
  (setf *current-room* (find-room 'kitchen))
  (list (try-move 'hallway) (try-move 'north))
  ```

  Expected: `(HALLWAY "no exit north")`

  The condition carries its facts in slots, and the handler reads them through the reader — never by parsing the report text, which exists only for people.

]

#soln("15.4")[
  #strong[Wrong:] `format` already ran, so `error` receives a finished string and treats it as a format control containing no directives — it works by accident, but the condition loses the pieces. Write `(error "Bad value: ~A" v)`.

  #strong[Wrong:] clause order. `error` catches everything, so the specific `parse-error` clause can never run. Most specific first:

  ```lisp
  (handler-case (parse-integer s)
    (parse-error () "unparseable")
    (error () "bad"))
  ```

  #strong[Wrong:] `invoke-restart` reaches restarts in scope #emph[where the error was signalled]. With no `restart-case` inside `body`'s code, the restart isn't active, and the handler fails with "restart MY-RESTART is not active". Wrap the body:

  ```lisp
  (handler-case (restart-case body
                  (my-restart () 'fell-back))
    (error (c) (declare (ignore c)) (invoke-restart 'my-restart)))
  ```

]

#soln("15.5")[
  ```lisp
  (defun to-integer (text)
    "Return the integer in TEXT, or 0 with a warning."
    (handler-case (parse-integer text)
      (parse-error ()
        (warn "No integer in ~S." text)
        0)))
  ```

  Check:

  ```lisp
  (list (to-integer "42") (to-integer "nope"))
  ```

  Expected output and value:

  ```text
  WARNING: No integer in "nope".
  (42 0)
  ```

  `~S` prints the bad string with quotes, which distinguishes `"7"` from `7` in the warning — the reason `~S` exists next to `~A`.

]

#soln("15.6")[
  ```lisp
  (defun collect-results (strings)
    "Return the integers parsed from the parseable strings."
    (let ((found nil))
      (loop for s in strings
            do (handler-case (push (parse-integer s) found)
                 (parse-error () nil)))
      (nreverse found)))
  ```

  Check:

  ```lisp
  (collect-results '("1" "no" "2" "3x" "3"))
  ```

  Expected: `(1 2 3)`

  `push` builds backwards, `nreverse` puts it straight without copying. `parse-integer` on `"3x"` stops after `3` by default and returns `3` with a second value of `1` — it doesn't signal unless #emph[nothing] is there. The `append` alternative the exercise hints at: `(setf found (append found (list value)))` keeps order without the final reverse, at the cost of copying every time — fine here, slow on long lists.

]

#soln("15.7")[
  ```lisp
  (defun run-session (commands)
    "Run every command, collecting replies."
    (loop for command in commands
          collect (handler-case (run-command command)
                    (error () "That command failed."))))
  ```

  Check:

  ```lisp
  (defparameter *commands*
    '((look . look) (take . take) (go . go-to)))
  (setf *current-room* (find-room 'kitchen))
  (defparameter *item-locations* '((key . kitchen)))

  (run-session '((look) (take) (dance)))
  ```

  Expected: the look text, "Wrong number of arguments for that command.", and "I don't know how to do that."

  Why those three: `(look)` returns the description; `(take)` signals `program-error` (wrong argument count) inside `apply`, and `run-command`'s own `handler-case` catches it and returns the "wrong number of arguments" string; `(dance)` is an unknown command, so `call-command` returns "I don't know how to do that." as a plain string, no signal at all.

  So in this example, `run-session`'s `handler-case` never fires. What it's for is the case `run-command`'s own handler misses — a bug in the command table itself, or a command function that signals a condition of a type `run-command`'s handler doesn't name. Both layers need a handler because they protect different things:

  - `run-command`'s `handler-case` knows about command-shaped problems (wrong argument counts) and answers specifically.
  - `run-session`'s is the safety net at the top: one bad command must not end the session, whatever the shape of the failure.

  Catch-all at the top, narrow catches inside — the same discipline `move-or-stay` showed in the chapter.

]

#soln("15.8")[
  ```lisp
  (defun call-command (command)
    "Call the function that handles COMMAND, offering repair."
    (let ((entry (assoc (first command) *commands*)))
      (restart-case
          (if (null entry)
              (error 'simple-error
                     :format-control "Unknown command: ~(~A~)."
                     :format-arguments (list (first command)))
              (apply (cdr entry) (rest command)))
        (repair ()
          :report "Run LOOK instead."
          (look)))))

  (defun run-command (command)
    "Run COMMAND, repairing unknown commands as LOOK."
    (handler-case (call-command command)
      (program-error ()
        "Wrong number of arguments for that command.")
      (simple-error ()
        (invoke-restart 'repair))))
  ```

  Check:

  ```lisp
  (defparameter *commands*
    '((look . look) (take . take) (go . go-to)))
  (setf *current-room* (find-room 'kitchen))
  (run-command '(dance))
  ```

  Expected: the kitchen's description — `look`'s reply.

  `error` with a symbol names your own condition type; with a string it builds a `simple-error`, and the directives ride along as `:format-control` and `:format-arguments`. The handler catches it and invokes `repair`, whose restart body runs `look`. From the debugger menu, the same `repair` restart appears by its `:report` text — one mechanism, two ways to choose.

]

== Chapter 16

#soln("16.1")[
  ```lisp
  (defpackage :game
    (:use :cl)
    (:export :look :take))
  (in-package :game)
  (defun take (item) (format nil "taking ~A" item))
  (in-package :cl-user)

  (list (symbol-package 'defun)
        (symbol-package 'game:take)
        (keywordp :look)
        (symbol-package (first '(a b))))
  ```

  Expected: the `COMMON-LISP` package, the `GAME` package, `T`, and `COMMON-LISP-USER`.

  `(first '(a b))` is `a`, read in whichever package was current when you ran the block — `cl-user` here. Symbols land in the package that was current #emph[when they were read], which is why the same name can exist in two packages as two different symbols.

]

#soln("16.2")[
  ```lisp
  (with-open-file (out "/tmp/haiku.txt"
                       :direction :output
                       :if-exists :supersede)
    (write-line "An old silent pond" out)
    (write-line "a frog jumps into the pond" out)
    (write-line "splash, silence again" out))

  (with-open-file (in "/tmp/haiku.txt")
    (loop for line = (read-line in nil)
          while line
          collect line))
  ```

  Expected: `("An old silent pond" "a frog jumps into the pond" "splash, silence again")`

  One stream, two trips: write with `:direction :output`, then read with the default `:input`. `read-line` strips the newlines, so the list holds the three lines as bare strings.

]

#soln("16.3")[
  ```lisp
  (defun append-note (text)
    "Add TEXT to the end of /tmp/notes.txt."
    (with-open-file (out "/tmp/notes.txt"
                         :direction :output
                         :if-exists :append
                         :if-does-not-exist :create)
      (write-line text out)))
  ```

  Check:

  ```lisp
  (append-note "first note")
  (append-note "second note")

  (with-open-file (in "/tmp/notes.txt")
    (loop for line = (read-line in nil)
          while line
          collect line))
  ```

  Expected: `("first note" "second note")` — and running the `append-note` lines again grows the file, which is what `:append` means.

]

#soln("16.4")[
  The result of the `read` is `(1 (2 3) "four")`.

  `print` writes Lisp-readable text: it puts the quotes on the string, because without them, `read` would see the symbols `four` and the round trip would lose the type. This is the `print` \/ `princ` distinction from Chapter 1 doing real work: `princ` writes for people, `print` writes for `read`.

]

#soln("16.5")[
  #strong[Wrong:] the stream is saved in `*saved-lines*`, but `with-open-file` closes it when the body ends. The later `read-line` fails with a closed-stream error. Read everything inside the body, and store the #emph[lines]:

  ```lisp
  (with-open-file (in "/tmp/notes.txt")
    (setf *saved-lines*
          (loop for line = (read-line in nil)
                while line
                collect line)))
  ```

  #strong[Wrong:] no `:if-exists`. The second run signals `file-error`, because the file exists and Lisp won't clobber it without permission. Add `:if-exists :supersede` (replace) or `:append` (add).

  #strong[Wrong:] `open` with no one to close it. The stream leaks: on Linux it stays open until the Lisp image exits, on Windows a leaked writer can block other programs from the file. Wrap it:

  ```lisp
  (with-open-file (in "/tmp/notes.txt")
    (read-line in))
  ```

]

#soln("16.6")[
  ```lisp
  (defun count-lines (path)
    "Return the number of lines in the file at PATH."
    (with-open-file (in path)
      (loop for line = (read-line in nil)
            while line
            count line)))
  ```

  Check:

  ```lisp
  (count-lines "/tmp/haiku.txt")
  ```

  Expected: `3`

  The `count` clause adds one for every non-`nil` line, doing the counting the `collect` version's `length` would do. One caveat: a file whose last line has no trailing newline still counts, because `read-line` returns that final text; a file ending in a newline doesn't gain a phantom empty line, since `read-line` returns `nil` after the last real one.

]

#soln("16.7")[
  ```lisp
  (defpackage :shop
    (:use :cl)
    (:export :sell :buy))
  (in-package :shop)

  (defun price (item)
    "Private: the price of ITEM."
    (if (eq item 'key) 5 10))

  (defun sell (item)
    (format nil "Selling ~A for ~D coins." item (price item)))

  (defun buy (item)
    (format nil "Buying ~A for ~D coins." item (price item)))

  (in-package :cl-user)

  (list (shop:sell 'key)
        (ignore-errors (shop:price 'key))
        (shop::price 'key))
  ```

  Expected: `"Selling KEY for 5 coins."`, `NIL`, and `5`.

  `shop:price` fails because `price` was never exported: the single colon demands a public symbol. The double colon in `shop::price` means "reach in anyway", and works — handy for your own debugging, bad manners between strangers' packages.

]

#soln("16.8")[
  ```lisp
  (defun game-state ()
    "Return a single list describing the whole game state."
    (list *item-locations*
          (room-name *current-room*)
          *history*))

  (defun restore-state (state)
    "Set the game state from the list STATE."
    (setf *item-locations* (first state))
    (setf *current-room* (find-room (second state)))
    (setf *history* (third state)))
  ```

  Check. Take the key, save, wreck everything, load, undo:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar) (key . kitchen) (letter . bedroom)))
  (setf *history* nil)
  (setf *current-room* (find-room 'kitchen))
  (snapshot)
  (run-command '(take key))
  (save-game)

  (setf *item-locations* nil)
  (setf *history* nil)
  (setf *current-room* (find-room 'bedroom))

  (load-game)
  (undo)
  (item-location 'key)
  ```

  Expected: `KITCHEN` — the key is back in the kitchen, because `undo` restored the snapshot that had travelled through the save file too.

  What changed: one element in `game-state`, one `setf` in `restore-state`. What didn't: `save-game`, `load-game` and every other function, because they pass the whole state around as one opaque object. That's the payoff of writing the format as functions rather than spreading `print` calls through the code.

  The subtle point: `*history*` is a list of alists, and `print` writes each one as Lisp data. When the save file is read back, the history list and each of its alist snapshots come back fresh, distinct objects — `equal` to the originals but not `eq` to them. That's exactly what you want from a save file: independent copies, not shared structure that would be corrupted by later play.

]

#soln("16.9")[
  ```lisp
  (defparameter *report-path* "/tmp/game-report.txt")

  (defun save-report ()
    "Write the room report to *REPORT-PATH*; return lines written."
    (let ((lines nil))
      (dolist (entry *rooms*)
        (let ((here (items-here (room-name entry))))
          (push (format nil "~(~A~): ~A"
                        (room-name entry)
                        (if here (item-names here) "nothing"))
                lines)))
      (setf lines (nreverse lines))
      (with-open-file (out *report-path*
                           :direction :output
                           :if-exists :supersede)
        (dolist (line lines)
          (write-line line out)))
      (length lines)))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((key . kitchen) (letter . bedroom)))
  (save-report)

  (with-open-file (in *report-path*)
    (loop for line = (read-line in nil)
          while line
          collect line))
  ```

  Expected: `5` from `save-report`, and the five lines back from the file, in room order.

  The lines are collected first and written second, so the count and the file always agree — writing and counting in one pass would need a counter threaded through the writing loop, and the split is simpler to read.

  On the tilde: on Linux and macOS, many Lisps expand a leading `~/` to your home directory. On Windows, what `~` means varies between implementations, and the honest habit is the one this exercise forced: put the path in a `defparameter` at the top of your program, so the one place it lives is easy to find and change.

]

== Chapter 17

#soln("17.1")[
  The lines print: `1 2 3 3 2` — five numbers on one line, since each level prints on entry and on exit.

  ```lisp
  (defparameter *depth* 0)

  (defun show () (format t "~D " *depth*))

  (defun nest (n)
    (let ((*depth* (1+ n)))
      (show)
      (when (< n 2) (nest (1+ n)))
      (show)))

  (nest 0)
  ```

  Walking it: `n=0` binds `*depth*` to 1, prints `1`, calls `nest 1` which binds to 2 and prints `2`, calls `nest 2` which binds to 3 and prints `3`, doesn't recurse, prints `3` on exit; back in `nest 1`, its binding is in force again, so `2` prints; back in `nest 0`, `1`. Each `let` pushes a binding and each return pops it — the stack of bindings mirrors the call stack, which is exactly what "dynamic extent" means. Notice that `show` takes no argument and needs none: the same function prints 1, 2, 3, 3, 2 because its caller rebound the variable it reads.

]

#soln("17.2")[
  ```lisp
  (defun with-temp-room (room-name fn)
    "Run FN with *CURRENT-ROOM* bound to ROOM-NAME; restore after."
    (let ((*current-room* (find-room room-name)))
      (funcall fn)))
  ```

  The comment the exercise asks for:

  Plain let already restores #strong[current-room] even if fn signals — that is what dynamic extent means. The binding is unwound by the same machinery that unwinds the stack for an error (Chapter 15's unwind-protect semantics are built into every binding form). The temptation to add unwind-protect is a category error in the useful direction: unwind-protect is needed for actions (closing files), not for bindings, which the language restores for you.

  Check:

  ```lisp
  (setf *current-room* (find-room 'bedroom))

  (with-temp-room 'cellar
    (lambda () (princ (room-name *current-room*))))
  ;; prints: CELLAR

  (room-name *current-room*)   ; => BEDROOM — restored
  ```

  And with a signalling body, to confirm the restore survives it:

  ```lisp
  (ignore-errors
    (with-temp-room 'garden
      (lambda () (error "boom"))))
  (room-name *current-room*)   ; => BEDROOM — still restored
  ```

  That second check is the point: `ignore-errors` catches the error, the `let` has unwound, and `*current-room*` is back to what it was before the call. No `unwind-protect` needed.

]

#soln("17.3")[
  #strong[Wrong:] `*counter*` is created by a bare `setf`, so it's a plain global with a misleading earmuffed name. SBCL warns; more importantly, nothing marks the name as special, so any later `defvar` on the same name would silently change its behaviour. Fix:

  ```lisp
  (defparameter *counter* 0)
  (defun bump () (incf *counter*))
  ```

  #strong[Wrong:] `loud-say` #emph[assigns] `*game-output*`, so after the call every later message in the whole program goes to a stream nobody can read — the change is permanent, not scoped. And the stream is never drained. The fix is a binding, not an assignment:

  ```lisp
  (defun loud-say (text)
    "Return TEXT, shouted, as a string."
    (with-output-to-string (s)
      (let ((*game-output* s))
        (format *game-output* "LOUD: ~A" text))))
  ```

  The output is the return value; `*game-output*` is untouched after the call returns.

  #strong[Wrong:] `name` has no earmuffs but is `defvar`'d — it #emph[is] dynamic despite the name, and every `let` on `name` anywhere in the program is now a global temporary change. The comment "intended as a per-call local" names the confusion directly: per-call locals are lexical `let` bindings or parameters, never `defvar`. Fix: delete the `defvar` and use a parameter or plain `let`:

  ```lisp
  (defun name-of (room)
    (let ((name (room-name room)))
      (string-capitalize (symbol-name name))))
  ```

]

#soln("17.4")[
  ```lisp
  (defun config-value (name-string)
    "Return the value of the dynamic variable named by NAME-STRING."
    (let ((sym (intern name-string)))
      (if (boundp sym)
          (symbol-value sym)
          :unknown)))
  ```

  Check:

  ```lisp
  (defparameter *save-file* "/tmp/game-save.lisp")
  (list (config-value "*SAVE-FILE*")
        (config-value "*NOTHING-LIKE-THIS*")
        (config-value "CAR"))
  ```

  Expected: the save path, `:unknown`, and `:unknown` — no error.

  The `"CAR"` result is the subtle one. `car` is a function, not a variable, so `boundp` returns `nil` and the function returns `:unknown`. That's the triple from Chapter 9 made concrete: a symbol has a value slot, a function slot, and a plist, and the three are queried by different functions. `boundp` and `symbol-value` concern only the value slot, so a symbol whose function slot is occupied can still be unbound as a variable — and vice versa.

  The `intern` call is the reader's own machinery, used by hand: `intern` looks the string up in a package's table, creating the symbol if absent. Passing `"*SAVE-FILE*"` with its asterisks matters — the string must be the symbol's exact (upcased) name, case and punctuation included.

]

#soln("17.5")[
  ```lisp
  (defvar *log* '())

  (defun log-it (x) (push x *log*))

  (defun phase-one ()
    (let ((*log* nil))
      (log-it 'a)
      (log-it 'b)))

  (phase-one)
  *log*    ; => NIL — empty!
  ```

  `a` and `b` went into the `let`'s binding, which vanished when `phase-one` returned. The global `*log*` was never touched. That's the sandbox reading of a dynamic `let`: whatever is written inside is written into a temporary world, and the temporary world is discarded at the end.

  The fix depends on intent, and there are two honest answers:

  #strong[Intent 1 — entries should survive the call.] Don't rebind `*log*`; write to the global directly:

  ```lisp
  (defun phase-one ()
    (log-it 'a)
    (log-it 'b))
  ```

  Then `*log*` accumulates `a` and `b` across calls, in reverse order of insertion because `push` prepends.

  #strong[Intent 2 — entries should be collected per phase and returned.] Read `*log*` before the `let` ends:

  ```lisp
  (defun phase-one ()
    (let ((*log* nil))
      (log-it 'a)
      (log-it 'b)
      (reverse *log*)))    ; => (A B)
  ```

  The sandbox was exactly right; what was missing was a way to #emph[empty] it back out. Chapter 23's tests will do this deliberately, binding `*save-file*` with `let` so a test can't corrupt the player's real save — the same mechanism, used for isolation this time.

  The name change the question asks about: if the function's intent was "collect locally and return", the natural name for the local is a plain `log` (no earmuffs), and a lexical `let` — not the global `*log*`. Rebinding the earmuffed name #strong[inside] the function is only right when callers of `log-it` from within `phase-one` are the point.

]

#soln("17.6")[
  ```lisp
  (defun terse (object)
    "The printed form of OBJECT, capped at 5 elements, 2 levels."
    (let ((*print-length* 5)
          (*print-level* 2))
      (format nil "~S" object)))
  ```

  Check:

  ```lisp
  (terse '(1 2 3 4 5 6 7))
  ;; => "(1 2 3 4 5 ...)"

  (terse '(1 (2 (3 (4))) 5))
  ;; => "(1 (2 #) 5)"
  ```

  Truncated elements show as `...`, truncated levels as `#`. Using `~S` rather than `~A` keeps it #emph[readable] — quotes on strings — which for logs is usually what you want to see. The two variables are independent dials: `*print-length*` caps width, `*print-level*` caps depth, and both default to `nil` (unlimited) — why printing everything has worked all book.

]

#soln("17.7")[
  ```lisp
  (defparameter *verbose* nil
    "When true, TAKE and DROP narrate their internal steps.")

  (defun take (item)
    "Pick up ITEM if it is in the current room."
    (cond ((eq (item-location item) 'player)
           (format nil "You already have the ~(~A~)." item))
          ((eq (item-location item) (room-name *current-room*))
           (when *verbose*
             (sayln "~&(debug) picking up ~(~A~)" item))
           (setf *item-locations*
                 (set-location *item-locations* item 'player))
           (format nil "You take the ~(~A~)." item))
          (t
           "You don't see that here.")))

  (defun drop (item)
    "Put down ITEM in the current room, if the player carries it."
    (if (eq (item-location item) 'player)
        (progn
          (when *verbose*
            (sayln "~&(debug) dropping ~(~A~)" item))
          (setf *item-locations*
                (set-location *item-locations* item
                              (room-name *current-room*)))
          (format nil "You drop the ~(~A~)." item))
        "You don't have that."))

  (defun play-quietly (commands)
    "Run COMMANDS with verbosity forced off."
    (let ((*verbose* nil))
      (play-to-string commands)))

  (defun play-loudly (commands)
    "Run COMMANDS with verbosity forced on."
    (let ((*verbose* t))
      (play-to-string commands)))
  ```

  The comment the exercise asks for:

  play-quietly and play-loudly call run-command through code that was never told about verbosity — the flag is read deep inside take, by whichever #strong[verbose] binding is in force at the moment. That only works because #strong[verbose] is dynamic: the let at the top rebinds it for the whole subtree of calls. Had take taken a :verbose keyword instead, every caller between play-quietly and take — run-command, call-command, transcript, the whole chain — would have to accept :verbose and pass it along. That is the "threading the argument" problem, and dynamic variables are the answer to "a setting that distant code needs but no intermediate caller should care about" — which is precisely why the standard's #strong[print-] variables are dynamic too.

  The clean-`-say` point the comment closes on: before this chapter, the game's messages went to `format t` — there was no single seam where `*verbose*` could choose between "print" and "don't print". `say` and `sayln` created that seam. The wrapper existed before the knob needed it, and the knob is what made the wrapper worthwhile.

]

== Chapter 18

#soln("18.1")[
  ```lisp
  (list #b-101        ; => -5
        #xdeadbeef    ; => 3735928559
        #c(0 -1)      ; => #C(0 -1) — the imaginary number -i
        ''sym         ; note two quotes: (QUOTE SYM)
        '|Two Words|  ; => |Two Words| — one symbol, case preserved
        #(a b c)      ; => #(A B C) — a vector
        '#:fresh)     ; => #:FRESH — uninterned, prints with #:
  ```

  The `''sym` row is the sleeper: `read-from-string "'sym"` gives the two-element list `(QUOTE SYM)`, because `'` itself reads as the `quote` form. Nested twice, you get `quote` wrapped in `quote` — which evaluates to the list `(quote sym)`, not to `sym`. Most "why does my quote do nothing" bugs are one quote deep.

  `#b-101` is `-(#b101)`, so `-5`. The sign goes before the digits; the reader accepts it because `read` delegates to `parse-integer` internally, and `parse-integer` allows a leading minus.

]

#soln("18.2")[
  `(read-from-string "(1 2 3) (4)")` reads #emph[one] object, `(1 2 3)`, and returns `12` as its second value — the index where the next read would continue. `(read-from-string "1 2 3")` reads `1` with second value `2`. The reader is always one-object-per- call; the second value is how you walk a string of many.

  ```lisp
  (defun read-all (string)
    "Every object in STRING, as a list."
    (loop with pos = 0
          for (obj next) = (multiple-value-list
                            (read-from-string string nil nil
                                              :start pos))
          while obj
          collect obj
          do (setf pos next)))

  (read-all "(a) 42 \"x\"")
  ;; => ((A) 42 "x")
  ```

  The `:start` argument moves the window; `nil` as the eof-value makes the walk stop on empty input. This is the skeleton of every Lisp source-processing tool — `read`, `read-from-string`, and the `:start`\/`:end` keywords, repeated until the stream runs out.

  Two corners worth a comment. First, `while obj` stops at the first `nil`-valued object, so `read-all "nil 1 2"` returns `nil` rather than `(nil 1 2)`. If that matters, test the `next` position against the string's length instead. Second, when the reader hits a genuine syntax error (unbalanced parenthesis, stray comma), it #emph[signals] — a bare `read-from-string` loop will hit the debugger, not return a partial list. Production code wants a `handler-case` around each `read-from-string`, treating a reader error as "stop here" — Chapter 19's `reader-error` condition, caught and translated. The example above leaves that out because the exercise is about the position mechanism, not about error handling — Chapter 19 comes next.

]

#soln("18.3")[
  #strong[Surprising:] `#S(point ...)` in a `defun` is a #emph[literal] — the same point object every call, and mutating it is undefined behaviour, so `(point-x (defaults))` may be `5` on the next call too. Fix: return a fresh structure:

  ```lisp
  (defun defaults ()
    (make-point :x 0 :y 0))
  ```

  #strong[Surprising:] the two `defun` forms are #emph[both selected] if your implementation reports both features — `#+` is read-time conditional per form, and nothing makes the branches mutually exclusive. SBCL reports `:sbcl` and not `:ccl`, so under SBCL the second form is skipped; under an implementation reporting both, you'd get two definitions and a redefinition warning. The intent — one function with implementation-specific bodies — wants the conditional #emph[inside] the body, one `defun` with `#+` lines:

  ```lisp
  (defun fast-path ()
    #+sbcl (sbcl-specific-thing)
    #+ccl  (ccl-specific-thing))
  ```

  #strong[Surprising:] the `#.` form runs `delete-file` #emph[while reading] — the moment `read-from-string` sees it, the file is gone, before any evaluation you planned. This is why `*read-eval*` exists to be turned off:

  ```lisp
  (let ((*read-eval* nil))
    (read-from-string "#.(delete-file \"/home/you/notes.txt\")"))
  ;; => reader error: #. is not allowed in this context
  ```

  The fix, for reading untrusted data, is a binding of `*read-eval*` to `nil` around the `read`. The lesson the exercise teaches: `#.` is code execution from text, and it fires at read time, not at eval time.

]

#soln("18.4")[
  ```lisp
  (defun feature-list ()
    "All feature symbols, as sorted downcased strings."
    (sort (mapcar (lambda (f) (string-downcase (symbol-name f)))
                  *features*)
          #'string<))

  (defun implementation-p (name)
    "Would #+NAME select code on this implementation?"
    (member name *features*))
  ```

  Check:

  ```lisp
  (implementation-p :sbcl)                    ; => T on SBCL
  (member "sbcl" (feature-list) :test #'string=)  ; => same answer
  ```

  The two tests answer the same question by different doors. The second asks "is there a feature whose #emph[name] is 'sbcl'"; the first asks "is `:sbcl` one of the symbols in the list". They agree because both are looking at the same symbol `:sbcl` — the second just converted it to a string for the comparison. `implementation-p` is the right spelling for feature-conditional #emph[decisions]; `feature-list` is the right spelling for #emph[inspection] at the REPL.

  A typical SBCL reports `:sbcl`, `:sb-core-compression` or similar, `:unix` (or `:win32`), `:x86-64` (or `:arm64`), `:64-bit`, `:little-endian`, `:ansi-cl`, `:common-lisp`, and more. The features are how one source tree covers every implementation and platform — and how Appendix A's install instructions can say "on your platform" in Lisp itself.

]

#soln("18.5")[
  ```lisp
  (defun read-hex (stream char)
    "Reader macro: $hex reads as the hexadecimal number."
    (declare (ignore char))
    (let ((chars nil))
      (loop for c = (peek-char nil stream nil nil)
            while (and c (digit-char-p c 16))
            do (push (read-char stream) chars))
      (parse-integer (coerce (nreverse chars) 'string)
                     :radix 16)))

  (set-macro-character #\$ #'read-hex)

  (read-from-string "$ff")   ; => 255
  (read-from-string "$a")    ; => 10
  (read-from-string "$10")   ; => 16
  ```

  `digit-char-p` with radix `16` accepts the hex digits — the same predicate `parse-integer` uses internally, which is why the loop and the conversion agree on what a hex digit is. `(coerce ... 'string)` turns the list of characters back into a string, which is what `parse-integer` wants.

  Undo, and the comment the exercise asks for:

  ```lisp
  (setq *readtable* (copy-readtable nil))
  ```

  copy-readtable with argument nil returns a copy of the standard readtable — nil means "the standard one, not the current one". It is a fresh object: the session's readtable was mutated by set-macro-character, and the fresh copy is not. Assigning #strong[readtable] to it reverts every macro character at once, back to what the standard defines. In source, you would wrap the customisation in (let ((#strong[readtable] (copy-readtable nil))) ...) so the change has dynamic extent — same mechanism as every other earmuffed knob (Chapter 17), applied to the reader instead of to output.

  The subtle bit: `(copy-readtable)` with no arguments copies the #emph[current] readtable, which is what you want for "restore after my change" when you saved the old one. `(copy-readtable nil)` copies the standard, which is what you want for "revert all the way". Exercise 18.5 uses the standard-copy form because it means "undo everything a previous exercise or session might have changed", which is the honest hygiene between REPL experiments.

]

#soln("18.6")[
  ```lisp
  (defun header-version (header)
    "The version integer from a save file header line, or 0."
    (let ((v-pos (search " v" header)))
      (if v-pos
          (parse-integer header :start (+ v-pos 2)
                                :junk-allowed t)
          0)))

  (defun convert-save-v0 (state)
    "Old saves were (item-locations room); today's add history."
    (if (and (= 3 (length state))
             (listp (third state)))
        state                     ; already today's shape
        (list (first state)       ; item locations
              (second state)      ; room name
              nil)))              ; history didn't exist in v0

  (defun load-game ()
    "Restore from the save file, converting old versions."
    (handler-case
        (with-open-file (in *save-file*)
          (let* ((header (read-line in))
                 (version (header-version header)))
            (unless (search "cave-of-noise" header)
              (error "Not a Cave of Noise save file: ~S" header))
            (let ((state (with-standard-io-syntax (read in))))
              (when (= 0 version)
                (setf state (convert-save-v0 state)))
              (restore-state state)))
          (look))
      (file-error () "No saved game found.")
      (end-of-file () "Save file is truncated.")
      (error (c) (format nil "Save file unreadable: ~A" c))))
  ```

  Check the v0 path:

  ```lisp
  (with-open-file (out *save-file* :direction :output
                                   :if-exists :supersede)
    (format out "cave-of-noise v0~%")
    (with-standard-io-syntax
      (print '((key . kitchen) kitchen) out)))
  (load-game)
  ;; history becomes nil; items and room restored
  (item-location 'key)   ; => KITCHEN
  ```

  The comment the exercise asks for:

  The header is a string line, read with read-line and inspected with string tools. It can carry any text, be extended with more fields, and be parsed defensively — the reader never touches it as Lisp syntax. The Lisp object after it, by contrast, is all or nothing: read either builds a valid object or signals, and there is no partial read to salvage a broken file. A string envelope around a Lisp payload is the standard shape for versioned data formats in Lisp — the same layering JSON files use, with Lisp data inside. The header's job is to say what the payload #emph[is] so a version mismatch is a legible error rather than a confusing reader failure; the payload's job is to be data.

  The `:junk-allowed t` in `header-version` is what makes it forgiving: `(parse-integer "1 extra text" :junk-allowed t)` returns `1` and ignores the rest. For a header, forgiving is right — the version is the leading digits, anything after is for humans.

]

== Chapter 19

#soln("19.1")[
  The `handler-case` form returns `CAUGHT`. The `handler-bind` form `/also` returns `CAUGHT` — but by a different route:

  ```lisp
  (handler-case (error "boom")
    (error (c) (declare (ignore c)) 'caught))
  ;; => CAUGHT — unwound to the handler-case, recovery code ran

  (block out
    (handler-bind ((error (lambda (c)
                            (declare (ignore c))
                            (return-from out 'caught))))
      (error "boom")))
  ;; => CAUGHT — the handler ran at the signal site, and
  ;;    return-from performed the exit
  ```

  The sentence the exercise wants: both handle the error, but `handler-case` exits #emph[by unwinding first], while `handler-bind`'s handler is called #emph[in place] and must perform its own exit — here a `return-from` through the `block` standing where the unwind would have landed. Same observable result, different mechanism; the mechanism is what matters when the handler needs the stack below it, as Exercise 19.3's second snippet shows.

]

#soln("19.2")[
  ```lisp
  (defun with-suppressed-warnings (thunk)
    "Run THUNK with warnings silenced; return its values."
    (handler-bind
        ((warning (lambda (c)
                    (declare (ignore c))
                    (muffle-warning))))
      (funcall thunk)))

  (defun with-captured-warnings (thunk)
    "Run THUNK; return (VALUES result warning-texts)."
    (let ((texts nil))
      (handler-bind
          ((warning
            (lambda (c)
              (push (princ-to-string c) texts)
              (muffle-warning))))
        (values (funcall thunk) (nreverse texts)))))
  ```

  Check, using Chapter 15's `to-integer`:

  ```lisp
  (with-suppressed-warnings (lambda () (to-integer "nope")))
  ;; => 0, nothing printed

  (multiple-value-bind (v ws)
      (with-captured-warnings
        (lambda () (list (to-integer "42") (to-integer "nope"))))
    (list v ws))
  ```

  Expected: `((42 0) ("WARNING: No integer in \"nope\"."))`

  The capture must happen #emph[inside] the handler, before `muffle-warning` — because `muffle-warning` performs a non-local exit that ends the handler immediately. After `muffle-warning`, there is no "after" in the handler to run. If you tried to capture after muffling, the capture line would never execute. The order in the snippet — push, then muffle — is the only correct one.

  A second subtlety: the warnings from Chapter 15's `to-integer` are raised by `warn`, and `warn` itself establishes the `muffle-warning` restart. The handler's `muffle-warning` call finds that restart and invokes it, which is why the warning is suppressed rather than printing and then being seen.

]

#soln("19.3")[
  #strong[Wrong:] the handler prints and returns — which abstains — so the error #emph[does] propagate, opening the debugger. If the intent was "print and stop", the handler needs an exit. Fix:

  ```lisp
  (block out
    (handler-bind ((error (lambda (c)
                            (format t "~A" c)
                            (return-from out nil))))
      (error "propagate?")))
  ;; prints the message, returns NIL, no debugger
  ```

  #strong[Wrong:] the `room-not-found` handler runs after the unwind — the `restart-case` is #emph[inside] the failing form, so it's gone by the time the handler runs, and `invoke-restart` signals "restart SUBSTITUTE-ROOM is not active". Fix: put `handler-bind` outside the `restart-case`:

  ```lisp
  (handler-bind ((room-not-found
                  (lambda (c)
                    (declare (ignore c))
                    (invoke-restart 'substitute-room))))
    (restart-case (error 'room-not-found :name 'attic)
      (substitute-room () 'kitchen)))
  ;; => KITCHEN
  ```

  #strong[Wrong:] `handler-case` on a warning catches it #emph[after printing] — `warn` prints when no handler muffled it, then the condition propagates, and the `handler-case` returns `nil`. The warning already appeared, which is the opposite of the caller's intent. Fix: `handler-bind` with `muffle-warning`, as in Exercise 19.2:

  ```lisp
  (handler-bind ((warning #'muffle-warning))
    (warn "quiet"))
  ;; prints nothing
  ```

  The general shape the three snippets teach: `handler-case` is for "catch and substitute" — it works only when the handler's job is to produce a value at the `handler-case`'s location, with the stack already unwound. `handler-bind` is for everything else: log, muffle, invoke a restart, or perform any action while the stack is still around. When in doubt, `handler-bind` is the tool that will do the job; `handler-case` is the one that won't.

]

#soln("19.4")[
  a) `parse-error` — `parse-integer` signals it. The useful detail is the string you passed in, which you already have as the argument; `parse-error` itself has no standard slot for it. Some implementations add one via `simple-condition`'s `:format-control` and `:format-arguments`, but portable code catches the condition and uses its own argument.

  b) `file-error` — `file-error-pathname` names the file that couldn't be opened. Chapter 16's `load-game` already uses this shape; the save-file loading is the canonical example.

  c) `unbound-variable` — one of the `cell-error` subtypes. `cell-error-name` gives the symbol that had no value, which is the useful detail. `cell-error` covers three siblings: the variable (`unbound-variable`), the slot (`unbound-slot`), and the function (`undefined-function`).

  d) `end-of-file` — one of the `stream-error` subtypes. `stream-error-stream` names the stream. In practice this rarely needs catching: reading with `read-line`'s `nil` second argument returns `nil` at end-of-file instead of signalling, and that's the pattern Chapter 16 teaches. Catch `end-of-file` only for files where a premature end is itself a problem — a truncated save, for instance.

  e) `program-error` — it has no useful standard slot; the argument-count story lives in the message. Catch it for control (the failsafe `run-command`), not for data.

  The pattern across all five: `condition type` decides #emph[whether] to catch; `condition slots` decide #emph[what to do] about it. The narrowest type you can name is the one you should name — the broader the type, the less you can say about the condition when the handler runs.

]

#soln("19.5")[
  ```lisp
  (defun invoke-if-found (name &rest args)
    "Invoke the restart called NAME, or return :inactive."
    (let ((restart (find-restart name)))
      (if restart
          (apply #'invoke-restart restart args)
          :inactive)))
  ```

  The gap matters #emph[between] the two steps: `find-restart` can fail (name misspelled, restart out of scope) and return `nil` quietly, while `invoke-restart` on a missing name #emph[signals an error]. Two steps let the caller decide which failure mode it wants — lookup-then-test for optional restarts, direct `invoke-restart` for restarts whose absence is a bug.

  One more subtlety: between `find-restart` and `invoke-restart` the restart set could in principle change, if some code ran between the calls. In `invoke-if-found` as written, nothing does — `apply` is the very next form. So the two-step pattern is race-free in practice. In a loop that calls `invoke-if-found` repeatedly on a changing restart set, the check would fire on stale data; but restarts don't come and go that fast, and callers who need to reason about restart scope know it's a dynamic-extent question, not a mutation question.

]

#soln("19.6")[
  ```lisp
  (defun take (item)
    "Take ITEM; a CONTINUE restart takes it from nowhere."
    (let ((entry (assoc item *item-locations*)))
      (cond
        ((eq (cdr entry) 'player)
         (format nil "You already have the ~(~A~)." item))
        ((eq (cdr entry) (room-name *current-room*))
         (setf *item-locations*
               (set-location *item-locations* item 'player))
         (format nil "You take the ~(~A~)." item))
        (t
         (cerror "Take it anyway."
                 "There is no ~(~A~) here." item)
         (setf *item-locations*
               (set-location *item-locations* item 'player))
         (format nil "You take the ~(~A~) from nowhere." item)))))

  (defun cheat-take (item)
    "Take ITEM regardless of where it is."
    (handler-bind
        ((error (lambda (c)
                  (declare (ignore c))
                  (let ((r (find-restart 'continue)))
                    (when r (invoke-restart r))))))
      (take item)))
  ```

  Check:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar) (key . kitchen)))
  (setf *current-room* (find-room 'kitchen))

  (list (take 'lamp)
        (cheat-take 'lamp)
        (item-location 'lamp))
  ```

  Expected: `("There is no lamp here." ... KITCHEN)` on a fresh save — wait, precisely: the first `take 'lamp` signals `cerror` because the lamp is in the cellar, and no handler is bound, so the debugger opens. Running the whole list in one block therefore stops at the first element. Two separate checks are the honest way:

  ```lisp
  (defparameter *item-locations*
    '((lamp . cellar) (key . kitchen)))
  (setf *current-room* (find-room 'kitchen))

  (cheat-take 'lamp)
  ;; => "You take the LAMP from nowhere."

  (item-location 'lamp)
  ;; => PLAYER
  ```

  The comment the exercise asks for:

  A restart is chosen by the caller at run time — the debugger offers "Take it anyway" to a human, and cheat-take offers the same choice programmatically — with no change to take's signature. A :force keyword would hard-code the decision into every call site that might want it, and every intermediate function (run-command, call-command, the command table's dispatch) would have to accept :force and pass it along — the threading-arguments problem that dynamic variables (Chapter 17) and restarts both solve, in their different ways. The restart also documents itself in the debugger's menu, where a keyword is invisible until you read the source. When the choice belongs to the moment, not the code path, a restart is the right shape.

  The `handler-bind` in `cheat-take` is deliberately broader than "catch the take error specifically". It catches any error and checks whether a `CONTINUE` restart is active. That works because `cerror` is the only place in `take` that establishes a `CONTINUE` restart — but if `take`'s implementation later grew a different `cerror` (say, prompting about an ambiguous name), the handler would continue through it too. In a real program, catch the specific condition type; here, catching `error` and gating on `find-restart` keeps the exercise's focus on the restart mechanism.

]

== Chapter 20

#soln("20.1")[
  a) Compiled: `defparameter` is #emph[compiled] (its `compute-x` call is not run — the compiler only records that the value expression runs at load); `defconstant`: its value `10` is evaluated at compile time (the compiler must know constants); `defun`: compiled, body not run; the `eval-when (:compile-toplevel)` `format`: run #emph[during compilation] — "hi" appears in the compiler output; the second `eval-when`: not evaluated at compile time (its situations don't include `:compile-toplevel`).

  b) Loaded: all five run at load time — `defparameter` computes `compute-x`, `defconstant` re-evaluates `10`, `defun` installs `f`, the `eval-when` (compile-toplevel only) does #emph[nothing] at load, and the second `eval-when` installs `g`.

  c) REPL: everything evaluates in place except the `(:compile-toplevel)-only` form, which does nothing — `:execute` is absent, and direct evaluation is the execute situation. Direct evaluation of the `defparameter` computes `compute-x` and binds `*x*`; `defconstant` binds `+limit+`; `defun` installs `f`; the first `eval-when` is skipped; the second installs `g`.

  The pattern worth carrying: the `(:compile-toplevel)-only` form is invisible outside compilation — a form that runs "when the compiler goes by", which is why it's the tool for compile-time side effects like declaring a feature, or for `(eval-when (:compile-toplevel) (declaim (special *foo*)))` to affect downstream compile-time behaviour without affecting run time.

  The `defconstant` case deserves a note. At compile time the value `10` is recorded for the compiler's constant-folding machinery; at load time it's re-evaluated and re-checked against the compiled-in value. If the value #emph[differs] between compile and load — say because `compute-x` depends on the current directory — the load signals a `defconstant` violation. That is why the earlier chapter's advice, "constants only for values that truly never change," is really about #emph[this] failure mode.

]

#soln("20.2")[
  Compiling the file, the compiler reaches `(twice a)` inside `f` #emph[first]. Macro use means: call the macro function at compile time. But `defmacro` installs the macro function at #emph[load] time, which hasn't happened — so the compiler either errors ("TWICE is undefined function") or — worse — treats `twice` as an undefined function call and compiles `f` wrong, reporting a warning that's easy to dismiss. The compiled `f`, once loaded, is broken or missing its expansion.

  Fix one — `eval-when` makes the macro available at compile time:

  ```lisp
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (defmacro twice (x) `(list ,x ,x)))

  (defun f (a) (twice a))
  ```

  Fix two — split files, order them, and let the system load them serially:

  ```lisp
  ;; macros.lisp
  (defmacro twice (x) `(list ,x ,x))

  ;; game.lisp
  (defun f (a) (twice a))

  ;; the .asd, from Chapter 16
  (asdf:defsystem "game"
    :serial t
    :components ((:file "macros") (:file "game")))
  ```

  When compiling `game.lisp`, `macros.lisp` has already been loaded (its fasl), so `twice` exists. Both fixes build the expansion-time world before the first use — the difference is whether you say it in the file (`eval-when`) or in the build order (`:serial`).

  A third fix, worth knowing by name: `defsystem` with `:depends-on` on the macro's own system, if the macro lives in a separate project. The principle is the same — establish the expander before its first use — but the file (or system) that defines the macro must be a load-time (and compile-time) dependency of the file that uses it.

]

#soln("20.3")[
  #strong[Wrong:] `*home*` is not constant across images and platforms — different users, different hosts, differently defaulted pathnames. Compiling the file evaluates it once (Chapter 20's rule for constants), and loading elsewhere can signal "the value of #strong[HOME] is not constant". Fix:

  ```lisp
  (defparameter *home* (user-homedir-pathname))
  ```

  Environment facts are parameters, recomputed per image.

  #strong[Wrong:] `*default-pathname-defaults*` is the process's current working directory merged into pathnames — it changes as the program `chdir`s and differs per invocation. `(self-path)` answers "where am I running from", not "where was my file loaded from". Fix:

  ```lisp
  (defun self-path ()
    (or *load-truename* *compile-file-truename*))
  ```

  — the file's actual home, bound only while it's being loaded or compiled, hence the `or`. At load time `*load-truename*` is bound and `*compile-file-truename*` is `nil`; while the compiler processes the file the opposite is true; after both, neither is bound and `(self-path)` returns `nil`, which is the honest answer.

  #strong[Wrong:] `(:execute)` only means the `defmacro` runs at the REPL. Compiling the file: the macro is #emph[not] defined at compile time, so `always`'s later use in the same file fails to expand — same bug as Exercise 20.2. Loading the compiled file: the `defmacro` runs (installing the macro for #emph[future] interactive use, too late for this file), and the recorded use of `always` was compiled as a plain function call. Fix:

  ```lisp
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (defmacro always (val) val))
  ```

  All three cases are the same shape of mistake: a form that needs to be available at compile time was only guaranteed at execute time, or vice versa — a value meant for run time was baked in at compile time.

]

#soln("20.4")[
  ```lisp
  (defun compile-and-report (filenames)
    "Compile each file in one unit; return (src . fasl-or-nil) pairs."
    (with-compilation-unit ()
      (loop for src in filenames
            collect (cons src (compile-file src)))))
  ```

  Check (with two files from Chapter 16's Exercise 16.7 in the current directory):

  ```lisp
  (compile-and-report '("packages.lisp" "classes.lisp"))
  ;; => (("packages.lisp" . #P"packages.fasl")
  ;;     ("classes.lisp"  . #P"classes.fasl"))
  ```

  Grouping collects every warning from every file and prints them once, at the end, as one unit — so a cascade of warnings caused by one early error reads as a group, with the root cause visible among its echoes instead of scattered across five separate reports. Per-file compilation buries the relationship: you see "undefined function FOO" six times and have to notice that FOO's definition was the thing in the #emph[first] file that failed.

  The limit of grouping is that it only helps #emph[reporting]. A genuinely fatal compile error still aborts the unit at that file, and later files aren't processed at all. Fixing that requires `:force` or resuming from the last successful file, which is ASDF's job (Exercise 20.6's punchline, again).

]

#soln("20.5")[
  ```lisp
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (defun count-forms (file)
      "Top-level forms in FILE, counted by reading."
      (with-open-file (in file)
        (loop for form = (read in nil nil)
              while form
              count form))))

  (defmacro file-form-count ()
    "Expands to a constant: forms in the file being compiled."
    (count-forms *compile-file-truename*))
  ```

  Use:

  ```lisp
  ;; in game.lisp, alongside the other top-level forms
  (defparameter *form-count* (file-form-count))
  ;; => loads as, e.g., 14 — a literal integer
  ```

  Compile time, because the #emph[answer must be in the compiled file]: a fasl contains no source to re-read, so the count has to be computed while the source is present — at `compile-file` time — and emitted as a constant. At load time the macro has already expanded: `*compile-file-truename*` is `nil` (it's only bound during compilation), and the expansion is a literal integer. What expands at load time is the integer; the whole reading step happened before the fasl existed.

  The `eval-when` trio on the helper is Exercise 20.2's rule applied: `count-forms` is called at expansion time (compile time), so it must exist then — and the macro must also work evaluated directly (REPL) and after load (its expansion must be usable), hence all three situations.

  One gotcha: `*compile-file-truename*` is `nil` when the macro is used in the REPL rather than in a file. `(count-forms nil)` signals a type error. A robust version either tests for the nil and returns a sentinel, or guards with `(when *compile-file-truename* ...)` in the expansion. The exercise's version is correct #emph[for a file] — which is the point of a compile-time macro — and the REPL usage is a bug the reader should expect to see if they try it interactively.

]

#soln("20.6")[
  ```lisp
  (defun load-compile-if-stale ()
    "Recompile stale files and everything after them, then load all."
    (let ((seen-stale nil))
      (with-compilation-unit ()
        (dolist (src *game-files*)
          (when (or seen-stale (stale-p src))
            (setf seen-stale t)
            (compile-file src))
          (load (fasl-for src))))))
  ```

  The rule: once any file is stale, every later file gets recompiled too — because later files might depend on the changed one, and we don't know which. It's conservative and correct for a serial chain.

  The comment the exercise asks for:

  This still gets several things wrong that ASDF gets right. First, a change to the #emph[last] file in #strong[game-files] forces a recompile of just that file, not the files before it — so a later-in-the-list file that game-files\* doesn't list (a helper, a test) won't be rebuilt even though it depends on the changed thing. Second, `file-write-date` has one-second resolution on some filesystems, so two edits in the same second look identical. Third, files that #emph[depend on each other out of order] (a macro in the last file, used by the first) break the "stale from here on" rule entirely — the recompile cascade has to go both directions, or the dependency graph has to be known. Fourth, fasl extensions are implementation-specific, and mixing two Lisps in one directory corrupts the cache; ASDF versions fasls per implementation. Fifth — and this is the big one — ASDF tracks #emph[which files changed], so a change to one file recompiles only its dependents, not "the file and everything after it in a list order that was chosen by the author, not the dependencies." The toy is honest about its lesson: a system definition is a dependency-aware make, and anything short of one will lie eventually. Chapter 16's `defsystem` was already the right shape; the exercise is worth doing to see #emph[why] the shape is right, not to build a replacement.

]

== Chapter 21

#soln("21.1")[
  ```lisp
  (list (typep 3 '(integer 0 2))     ; => NIL — 3 is outside the bound
        (typep 3 '(or null integer)) ; => T — union types
        (typep :red '(member :red :green :blue)) ; => T
        (typep "abc" '(simple-array character (3))) ; => T
        (typep '(1 2) '(cons integer (cons integer null))) ; => T
        (subtypep 'null 'list)       ; => T, T — NIL is a list
        (subtypep 'null 'symbol))    ; => T, T — and a symbol too
  ```

  The last two are the same door from two frames: `null` (the type of `NIL`) is a subtype of both `list` and `symbol`, which don't overlap with each other in any interesting way. Types in Lisp aren't a tree of disjoint boxes — they're sets, and a value sits in every set it belongs to. `(cons integer (cons integer null))` shows the recursive spine of list types: a cons whose `cdr` is another such cons or `nil` — exactly the two-element proper list `(1 2)`.

  The `"abc"` check works because a string literal in source is a `simple-array character` of its length; a string built by `concatenate` or `make-string` may or may not have the same type, depending on the implementation. That's the difference between `typep` and "is the value a string": `typep "abc" 'string` is always true, but `(simple-array character (3))` is the specific type SBCL happens to give the literal.

]

#soln("21.2")[
  #strong[Wrong:] `declare` must precede all executable forms in the body — the `format` makes it a declaration after a form, and the compiler signals an error. Fix: move the `declare` to the top:

  ```lisp
  (defun f (x)
    (declare (type fixnum x))
    (format t "x is ~A~%" x)
    (* x 2))
  ```

  #strong[Wrong:] `declaim` declares, but `defparameter` #emph[rebinds] unconstrained — the declaration applies to the variable named `*player-name*`, and the `defparameter` assigns a symbol to a declared-string variable: a type conflict SBCL warns about at the `defparameter`. The symbol `anon` is not a string. Fix by making the initial value match:

  ```lisp
  (declaim (type string *player-name*))
  (defparameter *player-name* "anon")
  ```

  The general lesson: a global declaration is a promise about #emph[every] future assignment — including the ones your tests and REPL experiments make.

  #strong[Wrong:] at `(safety 0)` the compiler trusts `fixnum` and `1+ "oops"` runs unchecked — garbage, a memory fault, or silently wrong data, depending on the machine. With the default `(safety 1)` the same call signals a `type-error` before any arithmetic. The snippet is the chapter's warning in one line: safety 0 plus a wrong declaration is undefined behaviour; keep safety 1 until declarations are proven right, and this example never is.

]

#soln("21.3")[
  ```lisp
  (defun safe-elt (seq index)
    "Element of SEQ at INDEX, checked."
    (check-type index (integer 0 #.most-positive-fixnum))
    (elt seq index))

  (defun fast-elt (seq index)
    "Unchecked: caller guarantees a valid fixnum index."
    (declare (optimize (speed 3) (safety 0))
             (type fixnum index))
    (elt seq index))
  ```

  The comment:

  safe-elt belongs in the game, because a bad index there is a bug to surface, not a cost to shave — the interactive type-error restart even lets you fix the variable in place. fast-elt is for measured hot paths only, and its docstring states the contract it no longer checks. "Almost everywhere" means everywhere you haven't profiled. The deeper point the pair teaches: check-type and declare are two ways to say the same thing — "this will be of this type" — one verified at run time as a service to the user, one trusted at compile time as a service to the compiler.

  Check:

  ```lisp
  (list (safe-elt "abc" 1)
        (safe-elt '(a b c) 2)
        (fast-elt (vector 10 20 30) 1))
  ;; => (#\b C 20)
  ```

  And the divergence, when both are given a bad index:

  ```lisp
  (ignore-errors (safe-elt "abc" -1))   ; => NIL — signal caught
  (ignore-errors (fast-elt "abc" -1))   ; => implementation-dependent
  ```

  At `safety 0`, `fast-elt`'s `(elt "abc" -1)` may return garbage, segfault, or (on some builds) still signal — the standard doesn't say. That's what "undefined behaviour" means concretely.

]

#soln("21.4")[
  ```lisp
  (defun type-chain-p (value types)
    "Is VALUE's type a subtype of every type in TYPES?"
    (let ((vtype (type-of value)))
      (every (lambda (tt) (subtypep vtype tt)) types)))

  (type-chain-p 5 '(integer fixnum number))  ; => T on most machines
  ```

  The return is `T`, given `type-of` returned a fixnum subtype — SBCL's `(integer 0 4611686018427387903)` is a subtype of `fixnum`, `integer` and `number`. What it tells you: types overlap — the one value `5` sits in all three sets simultaneously, because Lisp types are sets, not a disjoint class hierarchy. The caveat worth a comment:

  type-of returns some type the value belongs to, not necessarily the most specific one that matters to you. The function answers about the implementation's chosen representation, not about the value's abstract type. For intent, test the value against the types directly with typep: (type-chain-p 5 '(integer fixnum number)) is true, but (type-chain-p 5 '(unsigned-byte 3)) might or might not be, depending on whether type-of on this SBCL returned (integer 0 4611686018427387903) — which is not a subtype of (unsigned-byte 3), even though 5 is. The function is testing the implementation's answer, not 5's.

  That's the sharp version of the lesson: `subtypep` on types is not the same question as `typep` on values, and `type-of` bridges them in a way that can hide what you meant.

]

#soln("21.5")[
  A typical run (yours will differ — that's why the exercise demands reporting your own):

  ```text
  ;; (a) no declarations:  ~8.0 ms
  ;; (b) (the double-float ...) + declared accumulator: ~5.0 ms
  ;; (c) + declared (simple-array double-float (*)) + speed 3: ~1.2 ms
  ```

  With the code:

  ```lisp
  (defparameter *v*
    (make-array 1000000 :element-type 'twice-float
                         :initial-element 1.0d0))

  ;; (a)
  (defun sum-a (v)
    (loop for x across v sum x))

  ;; (b)
  (defun sum-b (v)
    (let ((total 0.0d0))
      (declare (type double-float total))
      (loop for x across v
            do (incf total (the double-float x)))
      total))

  ;; (c)
  (defun sum-c (v)
    (declare (optimize (speed 3) (safety 1))
             (type (simple-array double-float (*)) v))
    (let ((total 0.0d0))
      (declare (type double-float total))
      (loop for x across v
            do (incf total (the double-float x)))
      total))

  (time (sum-a *v*))
  (time (sum-b *v*))
  (time (sum-c *v*))
  ```

  Which declaration bought the most: the array type — (b)→(c). Declaring the accumulator removed float boxing of the sum, but declaring the array removed the per-element type dispatch, the dominant cost. The order is the chapter's order in miniature: accumulate `the` declarations cheaply, but the data-structure declaration is where the compiler stops guessing.

  One honest caveat: even sum-c is not what an optimising C compiler would produce for the same loop, because SBCL doesn't vectorise. To go faster you'd reach for `sb-simd` or a C library via CFFI (Chapter 29). The chapter's point is that declarations bring you a factor of five or ten, not that they turn Lisp into Fortran.

]

#soln("21.6")[
  The `declaim` and its requirement:

  ```lisp
  (declaim (type fixnum *moves*))
  (defparameter *moves* 0)   ; a fixnum — the declaration demands it
  ```

  The `play` check runs reliably because every assignment site (`incf *moves*` in the command loop) preserves fixnum-ness — and at `(safety 1)`, the moment some future edit assigns a string, the error surfaces loudly instead of corrupting.

  ```lisp
  (defun drift-check ()
    "Type-check the game's global state; return failing names."
    (let ((expected
            (list (cons '*moves* 'fixnum)
                  (cons '*current-room* '(or null room))
                  (cons '*item-locations* 'list)
                  (cons '*room-list* 'list)
                  (cons '*visits* '(simple-vector)))))
      (loop for (name . type) in expected
            unless (typep (symbol-value name) type)
              collect name)))
  ```

  Check:

  ```lisp
  (setf *moves* "oops")     ; a drift
  (drift-check)             ; => (*MOVES*)
  (setf *moves* 3)          ; back to normal
  (drift-check)             ; => NIL
  ```

  Two notes on the type list. `(or null room)` for `*current-room*` permits the initial `nil` as well as a real room; the game's `play` sets `*current-room*` immediately, so the `nil` case never survives long, but the type spec is honest about the declared default. `(simple-vector)` for `*visits*` is the general vector type — `(vector fixnum)` would also work, but SBCL's actual type for a `fixnum`-filled array is `(simple-array fixnum (*))`, and `simple-vector` is the closest abstract name that covers it. When in doubt, `(typep x (type-of example))` confirms.

  The kind of bug `drift-check` catches: a #emph[latent] wrong-typed assignment — one that's been sitting in the image for an hour, poisoning state quietly, and will bite somewhere far from its cause. At `(safety 0)` a wrong `declaim` turns that same assignment into corruption with no error at all — the value lands, memory gets reinterpreted, and the symptom appears anywhere but there. `drift-check` is the safety-net counterpart: same type knowledge, checked #emph[now], on demand, reporting #emph[which] variable drifted. Between them — checked types in development, declared types in profiled hot spots — lies the whole practice.

]

== Chapter 22

#soln("22.1")[
  Without the interposed `nil`:

  ```lisp
  (+ 2 3)          ; => 5      — * is now 5
  (* * 4)          ; => 20     — * is 20, ** is 5
  (list * ** ***)  ; => (20 5 <prior>)
  ```

  The three elements of the last line: `20` (the value from `(* * 4)`), `5` (the value from `(+ 2 3)`), and whatever was `*` #emph[before] `(+ 2 3)` — usually the return value of the previous REPL command, or a fresh-session error if there wasn't one.

  With the interposed `nil`:

  ```lisp
  (+ 2 3)          ; => 5
  (* * 4)          ; => 20
  nil              ; => NIL    — * is NIL, ** is 20, *** is 5
  (list * ** ***)  ; => (NIL 20 5)
  ```

  The interposed form shifted everything back by one slot. This is the exercise's whole point: `*` doesn't mean "the answer I care about" — it means "the last value the REPL happened to print", and every evaluation silently redefines it. Any evaluation between two usages changes what the next usage sees. For anything you actually want to reason about, bind it with `defparameter`.

]

#soln("22.2")[
  `CSS (describe #'append)` prints the signature — `append` takes any number of arguments, all of which must be lists except possibly the last — and its docstring. The point the exercise makes: you can answer "what arguments does this take" without reading any source.

  `CSS (describe *commands*)` prints the alist's type and the list of `(name . function)` pairs currently in it. Read from that output alone: `*commands*` is a `LIST`, and each entry is a cons whose car is a symbol and whose cdr is a function or symbol. Even without knowing Lisp's alist convention, the shape is visible: each pair names a thing and points at a thing.

  That's why `describe` is the first tool in unfamiliar code: both "what does this function want" and "what shape is this data" are one command away, and no source is needed for either.

]

#soln("22.3")[
  The inspector shows a `type-error` has exactly two interesting slots: `datum`, holding `5`, and `expected-type`, holding `LIST`.

  ```lisp
  (defun datum-or-message (fn)
    (handler-case (funcall fn)
      (type-error (c)
        (format nil "Wanted ~A, got ~S."
                (type-error-expected-type c)
                (type-error-datum c)))))

  (datum-or-message (lambda () (length 5)))
  ;; => "Wanted LIST, got 5."
  ```

  Handlers read slots, never the printed message — Chapter 15's rule, now with the inspector as the way to #emph[discover] what slots exist. The `~S` on `datum` is what keeps `5` (a number) distinct from `"5"` (a string) in the output; that's exactly the case where \~A would lie.

]

#soln("22.4")[
  a) `trace` — it shows each call's arguments and result; when the shape is right, the inputs and outputs of the inner calls tell you which step corrupts. `step` also works but is slower for a function with many calls.

  b) `apropos` — substring search over all symbol names; `(apropos "price")` finds it or proves it doesn't exist.

  c) `time` — it reports milliseconds and allocation directly. `trace` would show calls but not cost; reasoning about "feels slow" without measuring is guessing.

  d) `inspect` — one buffer, all slots and structure, navigable. `describe` prints a summary and stops; `print` shows a one-line view.

  e) `step` — it walks subform by subform, which is exactly "watch each expression". `trace` only fires on function boundaries; a loop body isn't one.

  f) `break` — it stops with the data in scope and resumes cleanly. `error` unwinds and loses the spot; `inspect` from outside needs you to reconstruct the situation first.

]

#soln("22.5")[
  ```lisp
  (defun safe-run (fn)
    "Run FN; return (:OK value) or (:ERROR message)."
    (handler-case (list :ok (funcall fn))
      (error (c) (list :error (princ-to-string c)))))
  ```

  Check:

  ```lisp
  (list (safe-run #'+)
        (safe-run (lambda () (/ 1 0))))
  ```

  Expected: `((:OK 0) (:ERROR "..."))` — the first result is `(:OK 0)` because `(+ )` with no arguments is 0, which is a reminder that `#'+` is a function taking any number of arguments, and `funcall` calls it with zero. The second result's message is implementation-flavoured — something like `"arithmetic error DIVISION-BY-ZERO signalled"` — which is exactly why the exercise had to say "message" and not "error type": a program that #emph[acts] on the error reads the condition's type and slots; a program that #emph[reports] the error uses `princ-to-string`, and the exact text doesn't matter.

]

#soln("22.6")[
  ```lisp
  (defun whereis (command)
    "Handle (WHEREIS ITEM): list rooms ITEM has appeared in."
    (let* ((name (second command))
           (present (assoc name *item-locations*))
           (seen nil))
      (dolist (snapshot *history*)
        (let ((loc (cdr (assoc name snapshot))))
          (when loc (pushnew loc seen))))
      (let ((current (and present (cdr present))))
        (when (and current (not (eq current 'player)))
          (pushnew current seen)))
      (cond ((null present)
             (format nil "No ~(~A~) here or in the log." name))
            ((null seen)
             (format nil "The ~(~A~) hasn't moved yet." name))
            (t
             (format nil "The ~(~A~) has been in: ~{~(~A~)~^, ~}."
                     name (reverse seen))))))
  ```

  Add the command:

  ```lisp
  (push '(whereis . whereis) *commands*)
  ```

  Check:

  ```lisp
  (setf *item-locations* '((key . kitchen) (lamp . cellar)))
  (setf *history* nil)
  (setf *current-room* (find-room 'kitchen))

  (run-command '(take key))
  (run-command '(go hallway))
  (run-command '(drop key))
  (run-command '(whereis key))
  ```

  Expected: `"The key has been in: kitchen, hallway."` — the kitchen from the snapshot before `take`, the hallway from the snapshot before `drop`, and the current state (hallway) already in the list from the drop.

  The condition question the exercise asks about: an unknown item is a `nil` lookup, not an error, so no `handler-case` is needed. The handling belongs in the command function, not in `run-command`, because `run-command` cannot know what "unknown" means for each command — for `whereis` it's a friendly message, for a future `examine` it might be a "you see no such thing" and for a `teleport-to-item` it might be a genuine error. Only the command function has the semantics.

  The distinction is Chapter 15's flags-vs-conditions rule, at a finer grain: within a single command, some failures are flags (the player typed a non-item) and some are conditions (the item registry is corrupt). run-command's handler catches the second kind; whereis's own logic handles the first. The exercise's "where should this go" is really "which layer knows what 'unknown' means" — and the answer is always "the layer that has the domain knowledge".

]

#soln("22.7")[
  Three bugs, three symptoms, one message per bug:

  #strong[Bug 1 — break `item-names`.]

  ```lisp
  (defun item-names (items)
    (declare (ignore items))
    nil)
  ```

  Symptom: `inventory` prints `"You are carrying: ."` — the item list is empty in the format string, but there's no error. `(doctor)` reports "All clear", because the game's #strong[data] is consistent — `*item-locations*` still has the right associations. A #strong[function] is wrong. The lesson: `doctor` checks data, not behaviour.

  #strong[Bug 2 — break \*current-room].\*

  ```lisp
  (setf *current-room* 'ballroom)
  ```

  Symptom: `look` fails with a type error on (room-name #strong[current-room]) — a symbol isn't a room structure. But `inventory` still works, because it doesn't read `*current-room*`. And `doctor` reports "Current room is not in #strong[rooms]" — the check you added in the project step catches the drift. `doctor` checks #strong[data structure integrity], not just data consistency.

  #strong[Bug 3 — remove a room from \*rooms] while items are in it.\*

  ```lisp
  (setf *rooms*
        (remove (find-room 'kitchen) *rooms*))
  ```

  Symptom: `go-to 'kitchen` from the hallway says "You can't go there from here" — the hallway's exit list still names kitchen, but `find-room` returns nil. And `items-here` on kitchen errors; `doctor` reports `"key is in unknown room KITCHEN"` (and any item that was in the kitchen), because the `find-room` check catches it.

  The catalogue's pattern: data drift is loud (conditions, `doctor` catches it), function damage is silent (wrong values, no signal). `doctor` is how you give the silent kind a voice — and the redefinition loop is how you fix it, one `C-c C-c` per definition, no restart.

]

== Chapter 23

#soln("23.1")[
  ```lisp
  (list (symbol-name 'kitchen)    ; => "KITCHEN"
        (symbol-package :kitchen) ; => #<PACKAGE "KEYWORD">
        (symbol-name :kitchen)    ; => "KITCHEN" — keywords' names, too
        (eq 'kitchen 'KITCHEN)    ; => T — the reader upcased both
        (eq (intern "KITCHEN") 'kitchen) ; => T — same table, same symbol
        (symbol-package (gensym))) ; => NIL — uninterned
  ```

  The `intern` line is the reader's own machinery, used by hand: `intern` looks the string up in a package's table (default current package), creating the symbol if absent. Reading `kitchen` `/is` interning `"KITCHEN"` — which is why the `eq` holds: there is only one symbol named `KITCHEN` home in a package, and both expressions reach it.

  The last line's `NIL` is the tell for an uninterned symbol: no package holds it, so `symbol-package` has nothing to return. Every interned symbol has a non-`nil` package; every uninterned one has `nil`. There is no third case.

]

#soln("23.2")[
  #strong[Wrong:] `(get "kitchen" 'description)` signals an error — `get`'s first argument must be a symbol, because the property lives #emph[on] it. Fix: use the symbol `(get 'kitchen 'description)`, or if the key arrives as a string, `(get (intern (string-upcase key)) 'description)`.

  #strong[Surprising:] the `remprop` line removes the property for the #emph[whole image]. The later `(get 'kitchen 'exits)` returns `nil` — not because state was lost in a crash, but because something else deleted it. Property lists are global mutable state attached to shared symbols; the fix is not a different call but a different structure for anything that has versions, owners or a save file (an alist or hash table, as the chapter argued).

  #strong[Surprising:] `props` was captured #emph[before] the `remprop`, but it still #emph[changes]: `symbol-plist` returned the actual list the symbol points at, and `remprop` mutates that same list in place. The captured variable doesn't hold a copy — it holds a live reference to the shared plist. If a snapshot was wanted, copy element-wise #emph[after] the mutation you care about: `(copy-list (symbol-plist 'kitchen))`. Even then, the plist has no honest snapshot in general — properties come and go independently of any single structure.

  #strong[Surprising:] `(getf '(name "hall" name "cellar") :name)` returns `nil` — the plist's keys are the symbols `name` (not keywords `:name`), and `eq` never matches `name` against `:name`. A plist's keys must be compared with the same interned symbols you search with — the commonest plist bug, and the reason keyword keys are the convention: `:name` typed anywhere is the same object, so lookups never fail on case or internship accidents.

]

#soln("23.3")[
  ```lisp
  (defun plist-p (list)
    "Does LIST have an even number of elements?"
    (evenp (length list)))

  (defun plist->alist (plist)
    "Convert (a 1 b 2) to ((A . 1) (B . 2))."
    (loop for (k v) on plist by #'cddr
          collect (cons k v)))

  (defun alist->plist (alist)
    "Convert ((A . 1) (B . 2)) to (a 1 b 2)."
    (loop for (k . v) in alist
          append (list k v)))
  ```

  Check:

  ```lisp
  (plist-p '(a 1 b 2))                     ; => T
  (plist-p '(a 1 b))                       ; => NIL
  (plist->alist '(a 1 b 2))                ; => ((A . 1) (B . 2))
  (alist->plist (plist->alist '(a 1 b 2))) ; => (A 1 B 2)
  ```

  The honest answer to "which direction loses information": for well-formed inputs, #emph[neither]. Both structures hold the same objects, in the same order, paired the same way. The difference is representation, not information: an alist is a list of conses (each pair is one compound object); a plist is a flat list where keys and values are siblings.

  What #emph[changes] is the lookup contract. On either structure, a key whose value is `nil` is indistinguishable from an absent key when the lookup returns just the value:

  ```lisp
  (cdr (assoc 'b '((a . 1) (b . nil))))   ; => NIL — present with nil
  (cdr (assoc 'c '((a . 1) (b . nil))))   ; => NIL — absent
  (getf '(a 1 b nil) 'b)                  ; => NIL — present with nil
  (getf '(a 1 b nil) 'c)                  ; => NIL — absent
  ```

  Both structures need the found-flag protocol to disambiguate — `assoc`'s `nil` result is the flag (nil means absent); `getf` returns just the value, and `get-properties`'s first return is the flag. The "loss" isn't in conversion; it's that neither structure's plain lookup tells you the difference, and the converter can't fix that for you.

  A second, smaller point: converting a plist with duplicate keys to an alist preserves both entries, and vice versa. Duplicates are a separate bug, not a loss.

]

#soln("23.4")[
  ```lisp
  (defun plist-keys (plist)
    "Distinct keys of a plist, in first-occurrence order."
    (let ((seen nil))
      (loop for (k v) on plist by #'cddr
            do (pushnew k seen)
            finally (return (nreverse seen)))))
  ```

  `pushnew` keeps the accumulation distinct, using `eql` by default — the right equality for keyword\/symbol keys. On a plist with a duplicated key, `plist-keys` returns that key once; the duplication itself is silently hidden, which is why `plist-well-formed-p` is a separate (and useful) check.

  ```lisp
  (defun plist-well-formed-p (plist)
    "Even length, no duplicate keys."
    (and (plist-p plist)
         (let ((keys (loop for (k v) on plist by #'cddr collect k)))
           (null (remove-duplicates keys :test #'eq :from-end t)))))
  ```

  `remove-duplicates` returning a shorter list is the duplicate detector.

  ```lisp
  (defun plist-subset-p (sub super)
    "Does SUPER contain every key/value pair of SUB?"
    (loop for (k v) on sub by #'cddr
          always (multiple-value-bind (found-key found-value tail)
                     (get-properties super (list k))
                   (declare (ignore tail))
                   (and found-key (equal found-value v)))))
  ```

  Check:

  ```lisp
  (plist-subset-p '(:a 1) '(:a 1 :b 2))    ; => T
  (plist-subset-p '(:a 1 :c 3) '(:a 1))    ; => NIL
  (plist-subset-p '(:a nil) '(:a nil))     ; => T — present with nil
  ```

  The `get-properties` return is three values: the found key (nil if absent), its value, and the tail of the plist from that key onward. The first value is what `getf` alone can't give you — `getf` returns `nil` both for absent and for present-with-nil. `get-properties`'s found-key is the flag.

  `equal` on the values (rather than `eq`) is what makes the function work for strings and lists, not just symbols.

]

#soln("23.5")[
  ```lisp
  (defmacro swap (a b)
    (let ((tmp (gensym "SWAP-")))
      `(let ((,tmp ,a))
         (setf ,a ,b
               ,b ,tmp))))

  (macroexpand-1 '(swap x y))
  ;; => (LET ((#:SWAP-427 x)) (SETF X Y Y #:SWAP-427))
  ```

  Check:

  ```lisp
  (let ((x 1) (y 2))
    (swap x y)
    (list x y))   ; => (2 1)
  ```

  Now the naive version and its bug:

  ```lisp
  (defmacro swap-broken (a b)
    `(let ((tmp ,a))
       (setf ,a ,b ,b tmp)))

  (macroexpand-1 '(swap-broken x tmp))
  ;; => (LET ((TMP X)) (SETF X TMP TMP TMP))
  ```

  The expansion is the whole story. When the caller's second argument is literally the variable `tmp`, the macro's `(let ((tmp ...)) ...)` shadows it. `(setf tmp tmp)` writes the #emph[macro's] `tmp` with the #emph[macro's] `tmp` — a no-op — and the caller's `tmp` is never touched. Swap fails silently, and only for that one caller.

  `gensym` manufactures a symbol no caller can have written — it's uninterned, so it can't appear in source text — closing the capture hole. This is the "variable capture" trap from Chapter 14 in its most classic form.

]

#soln("23.6")[
  ```lisp
  (defun describe-flavour (item)
    "Return the flavour text of ITEM, or a default."
    (or (get item 'flavour)
        (format nil "Just a plain ~(~A~)." item)))

  (setf (get 'key 'flavour) "Brass, and warmer than it should be.")
  (setf (get 'lamp 'flavour) "Its light doesn't quite reach the floor.")

  (list (describe-flavour 'key)
        (describe-flavour 'lamp)
        (describe-flavour 'sword))
  ```

  Expected:

  ```text
  ("Brass, and warmer than it should be."
   "Its light doesn't quite reach the floor."
   "Just a plain sword.")
  ```

  The comment the exercise asks for:

  Flavour text is (a) an attribute of a named thing, consulted by name alone — the plist's natural shape; (b) fixed at definition time, so it never needs snapshotting, versioning, or save-game; (c) global by nature — the flavour of the key is the same every session, which is exactly the intent. Item #strong[locations] are the opposite on all three: they change during play, get saved and restored, and would be spread unownably across symbols on a plist. Chapter 7 gave them an alist for exactly that reason. The dividing line, in one sentence: plists for constants about names, owned structures for state about things.

]

== Chapter 24

#soln("24.1")[
  ```lisp
  (list (multiple-value-list (values))      ; => NIL — zero values
        (multiple-value-list (values 1))    ; => (1)
        (multiple-value-list (values 1 2 3))  ; => (1 2 3)
        (+ (values 1 2) (values 3 4))       ; => 4 — primaries only: 1 + 3
        (list (values 1 2) (values 3 4))    ; => (1 3)
        (values (values 1 2) (values 3 4))) ; => two values: 1 and 3
  ```

  Expected: `(NIL (1) (1 2 3) 4 (1 3) 1)`.

  ```text
  (NIL (1) (1 2 3) 4 (1 3) 1)
  ```

  Where each element came from:

  - `(multiple-value-list (values))` → `NIL` (empty, because zero values)
  - `(multiple-value-list (values 1))` → `(1)` (one value)
  - `(multiple-value-list (values 1 2 3))` → `(1 2 3)`
  - `(+ (values 1 2) (values 3 4))` → `4` (the primaries 1 and 3, summed)
  - `(list (values 1 2) (values 3 4))` → `(1 3)` (the list's two argument positions each kept one value)
  - The final `(values (values 1 2) (values 3 4))` → two values, `1` and `3` — but it sits in an argument position of `list`, which is a single-value context. `list` keeps only the primary, `1`. That is the last element of the result, and the `3` is discarded.

  Two surprises worth naming. First, `(values)` produces #emph[zero] values — and `multiple-value-list` faithfully gives the empty list `nil`, which is "no values collected". The distinction matters only in a multiple-value context; anywhere else, zero values and one nil value both read as nil. Second, `values` doesn't nest: each argument to a `values` call is evaluated in single-value context, so the outer `values` sees only the primaries of its arguments. Values are flat.

]

#soln("24.2")[
  #strong[Surprising:] `x` binds the primary value only — `:a` — and `:b` is gone. `(let ((x (two-things))) x)` prints `A`. Fix: `multiple-value-bind` or `multiple-value-list` at the call:

  ```lisp
  (multiple-value-bind (x y)
      (two-things)
    (list x y))   ; => (:A :B)
  ```

  #strong[Surprising:] `(:DONE 3)`, not `(:DONE 2)`. The snippet works — and the element that surprises people is the `3`, not the multi-value part. `loop` puts an implicit block named `nil` around its body, so `(return (values :done i))` is `(return-from nil (values :done i))`. `return-from` passes #emph[every] value of its form to the block, and the loop's `finally` clause runs after the last iteration — with `i` already stepped to `3` — so the loop returns `:done` and `3`, and the outer `multiple-value-bind` catches both:

  ```text
  (:DONE 3)
  ```

  The point the exercise makes is that `loop`'s return values are governed by `return`, which preserves them — same as `return-from`. What truncates in this snippet is not the loop but a `let` if you introduce one:

  ```lisp
  (let ((pair (loop for i below 3
                    finally (return (values :done i)))))
    pair)   ; => :DONE — pair binds one value
  ```

  `let` truncates, `multiple-value-bind` doesn't. The trap is which binding form you use to catch the loop's result.

  #strong[Surprising:] `gethash` returns `nil` and `t`: the key #emph[is] present, holding `nil`. The naive reading "nil means absent" is exactly what the second value refutes. This is the correct-behaviour example, not a bug — the fix is for code that ignored the flag:

  ```lisp
  (multiple-value-bind (val found-p) (gethash :k table)
    (if found-p val :absent))   ; => NIL (the stored one)
  ```

  #strong[Surprising:] (1), not\~`(1 2)`. The function's body is the variable reference `form-values` — but the #emph[caller's] argument position `(pass-through (values 1 2))` is a single-value context, so `pass-through` received 1 before any body ran. No function body can recover values its caller truncated. Fix: take a `/thunk` and call it in a multiple-value context:

  ```lisp
  (defun pass-through (thunk)
    (funcall thunk))              ; body end: values preserved
  (multiple-value-list (pass-through (lambda () (values 1 2))))
  ;; => (1 2)
  ```

  The thunk receives no argument, so its result's values reach `multiple-value-list` intact. `(funcall thunk)` is the function body's last form, which is a multiple-value context — the values pass through unchanged. That's the entire difference between "function that takes a value" and "function that takes a computation".

]

#soln("24.3")[
  ```lisp
  (defun safe-divide (a b)
    "Two values: quotient, and :DIVISION-BY-ZERO or NIL."
    (if (zerop b)
        (values nil :division-by-zero)
        (values (/ a b) nil)))

  (defun safe-sum (pairs)
    "Sum of quotients; two values: total, failed-p."
    (let ((total 0)
          (failed nil))
      (dolist (pair pairs (values total failed))
        (multiple-value-bind (q err)
            (safe-divide (first pair) (second pair))
          (if err
              (setf failed t)
              (incf total q))))))
  ```

  Check:

  ```lisp
  (list (multiple-value-list (safe-sum '((7 2) (9 3))))
        (multiple-value-list (safe-sum '((7 0) (9 3))))
        (multiple-value-list (safe-sum nil)))
  ```

  Expected: `((13/2 NIL) (3 T) (0 NIL))`.

  The first case: (safe-divide 7 2) gives `7/2`, (safe-divide 9 3) gives `3`, sum `13/2`, no failure — (13\/2 NIL).

  The second: `(safe-divide 7 0)` gives `(nil :division-by-zero)` — failed, so the sum skips it and adds only the `9/3`'s `3`. `(3 T)`.

  The third: empty input, `total` starts at `0`, `failed` stays `nil`. `(0 NIL)`.

  The shape to notice: `safe-sum` propagates failure as a flag, not a condition, and callers who don't care about failure just use the total. It's `gethash`'s contract, rebuilt by hand. Compare:

  - `gethash` returns value + found-flag. Callers ignoring the flag get the value or `nil`. Callers binding both get the distinction.
  - `safe-sum` returns total + failed-flag. Same shape.
  - `(handler-case ...)` is for `/bugs` — errors the caller couldn't have anticipated. Flags are for predicted `failures` — errors the caller routinely branches on.

  The rule of thumb: if the caller's natural response is "check the second value and maybe react", use a flag. If the caller's natural response is "let someone higher up deal with it", signal a condition.

]

#soln("24.4")[
  ```lisp
  (defun compose-values (f g)
    "Return a function that applies G to all of F's values."
    (lambda (&rest args)
      (multiple-value-call g (apply f args))))
  ```

  Check:

  ```lisp
  (funcall (compose-values #'floor #'list) 7 2)
  ;; => (3 1)
  ```

  `(apply f args)` calls `floor` with two arguments, returning two values. `multiple-value-call` then calls `g` with those two values as separate arguments — so `list` receives `3` and `1`, producing `(3 1)`. If the body had been the naive `(funcall g (apply f args))`, the intermediate `apply` would truncate to `3` before `g` was called, and the answer would be `(3)`.

  The primitive that `compose-values` is a specialisation of: `multiple-value-call`. In fact:

  ```text
  (funcall (compose-values f g) args...)
  = (multiple-value-call g (apply f args))
  ```

  Every `multiple-value-call` expresses one composition — a call to `g` with all the values produced by the argument forms. `compose-values` packages that into a reusable function; the underlying primitive is the one you'd reach for directly in a one-off composition, without building the wrapper.

]

#soln("24.5")[
  ```lisp
  (defun first-or-default (thunk default)
    "THUNK's primary value, or DEFAULT if it returned none."
    (let ((vals (multiple-value-list (funcall thunk))))
      (if vals (first vals) default)))
  ```

  Check:

  ```lisp
  (list (first-or-default (lambda () (values)) :none)
    (first-or-default (lambda () (values 1 2)) :none)
    (first-or-default (lambda () nil) :none))
  ```

  Expected: `(:NONE 1 NIL)`.

  The three cases:

  `(values)` — zero values — `vals` is `nil`, so `default` is returned.

  `(values 1 2)` — two values — `vals` is `(1 2)`, so `(first vals)` gives `1`.

  `nil` — #emph[one] value, which happens to be nil — `vals` is `(nil)`, so `(first vals)` gives `nil` (the value, not the default).

  The `default`'s value is `:none` (a keyword) rather than `nil`, because `nil` is itself a legitimate #emph[value], and using `nil` as the default would conflate it with "the thunk returned nil". `:none` is unambiguous.

]

#soln("24.6")[
  ```lisp
  (defun save-game ()
    "Write the game state. Two values: success-p, path-or-message."
    (handler-case
      (progn
        (with-open-file (out save-file
            :direction :output
            :if-exists :supersede)
          (with-standard-io-syntax
            (format out "cave-of-noise v~D~%" save-format)
            (print (game-state) out)))
        (values t save-file))
      (file-error (c)
        (values nil (princ-to-string c)))))

  (defun load-game ()
    "Restore the game state. Two values: state-or-nil, loaded-p."
    (handler-case
      (with-open-file (in save-file)
        (let ((header (read-line in)))
          (unless (search "cave-of-noise" header)
            (error "Not a Cave of Noise save file: ~S" header))
          (let ((state (with-standard-io-syntax (read in))))
            (values state t))))
      (file-error () (values nil nil))
      (end-of-file () (values nil nil))
      (error () (values nil nil))))
  ```

  Note that `load-game` now returns the `/state` rather than applying it — the caller decides whether to `restore-state` it. That's the flag pattern applied cleanly: the function's job is "get the data from disk"; whether the game adopts it is the game's decision.

  Update the save and load commands:

  ```lisp
  (defun cmd-save ()
    "The SAVE command: report success or failure."
    (multiple-value-bind (ok path-or-err)
      (save-game)
      (if ok
        (format nil "Saved to ~A." path-or-err)
        (format nil "Could not save: ~A" path-or-err))))

  (defun cmd-load ()
    "The LOAD command: load and adopt, or report failure."
    (multiple-value-bind (state loaded-p)
      (load-game)
      (if loaded-p
        (progn
          (restore-state state)
          (look))
        "No saved game found.")))
  ```

  Register them:

  ```lisp
  (push '(save . cmd-save) commands)
  (push '(load . cmd-load) commands)
  ```

  Check:

  ```lisp
  (setf save-file "/tmp/test-roundtrip.lisp")
  (setf current-room (find-room 'kitchen))
  (setf item-locations '((key . kitchen)))
  (setf history nil)

  (run-command '(save))
  (setf item-locations nil)
  (run-command '(load))
  item-locations ; => ((KEY . KITCHEN))
  ```

  The comment the exercise asks for:

  The string-matching approach has three problems that the two-value approach fixes. First, it's brittle: change the error message text, and the caller's match stops working. Second, it's not the information the caller wants — "there was no file" and "the file was corrupt" are both "no load happened", but a caller might want to distinguish them for logging or for a different player message. Two values (state, loaded-p) say what happened; if the caller needs the `/reason`, the function can return three values (state, loaded-p, reason), and callers who don't care ignore the third. Third, string matching is slow and requires allocation of a temp string; comparing against nil or t costs nothing.

  The reason #emph[this] function returns two values instead of signaling a condition: a missing save file is expected (first run of a fresh game), not a bug. Conditions are for bugs and emergencies. Flags are for expected outcomes the caller branches on. save-game and load-game are on the flag side of the line; the game's data structures on disk are on the condition side (see Exercise 18.6's convert-save-v0 and the reader's handling of corrupt files).

  The game's state at the end of this chapter: `run-command`, `play`, `save-game`, and `load-game` all use multiple values as their interface, `save` and `load` commands wrap the two plist-replacing commands from Chapter 16 with the two-value versions above, and the rest of the game is unchanged. The trickle-down effect of Chapter 24's mechanism has been everywhere; the trickle-up effect, on the game's own code, has been to replace one string-match hack (`count-unknown`) and one string-return convention (save-game\/load-game) with values.

]

== Chapter 25

#soln("25.1")[
  ```lisp
  (let ((fns (loop for i from 1 to 3
                   collect (lambda () i))))
    (mapcar #'funcall fns))
  ;; => (1 2 3)
  ```

  `loop`'s `for i` binds a fresh `i` per iteration, so each closure owns its own. (In languages where a loop shares one variable, this prints `3 3 3`; Lisp's per-iteration binding is the reason the `make-bumpers` example works.) The standard guarantees it for `loop`; for `dotimes`, it's implementation-defined — SBCL does the right thing, most modern implementations do, but `loop` is the guaranteed form.

  ```lisp
  (multiple-value-bind (up down) (make-two)
    (list (funcall up) (funcall up) (funcall down) (funcall up)))
  ;; => (1 2 1 2)
  ```

  Both closures share one `n`. Trace it: `up` takes n 0→1, returns 1; `up` takes n 1→2, returns 2; `down` takes n 2→1, returns 1; `up` takes n 1→2, returns 2. The list is `(1 2 1 2)`.

  If your answer was `(1 2 -1 1)` — a guess that `down` returns the negative of something — re-read the closure: `down` is `(lambda () (decf n))`, and `decf` returns n's new value, not the amount decremented. Closure sharing of a single binding means increments and decrements on the same number, in order.

  ```lisp
  (let ((x 10))
    (let ((f (lambda () x)))
      (setf x 99)
      (funcall f)))
  ;; => 99
  ```

  The closure captured the #emph[binding], not the value `10` at creation time; the later `setf` changed that binding, and `f` sees the change. Value-snapshot thinking predicts 10; binding thinking predicts 99; Lisp does 99.

]

#soln("25.2")[
  #strong[Wrong:] `total` has no binding — the `lambda`'s free variable names nothing, and calling the closure signals `UNBOUND-VARIABLE` (or, under some compilers, captures a dynamic `total` if one happens to exist — worse). Fix: the `let` was the whole design:

  ```lisp
  (defun make-accumulator ()
    (let ((total 0))
      (lambda (n) (setf total (+ total n)))))
  ```

  #strong[Surprising, but it works — the surprise is the #emph[shape] of the data.] `(first *counters*)` is the pair `(a #<closure>)`, and `(second ...)` extracts the closure. `(funcall (second (first *counters*)))` correctly returns 1. The exercise's real trap is a different spelling that fails: `(funcall *counters*)`, which is `funcall` on the whole list, not on any closure. Use the pair's `.cdr` to extract the closure cleanly, which is also how you'd normally write it:

  ```lisp
  (defparameter *counters*
    (loop for name in '(a b c)
          collect (cons name (let ((count 0))
                               (lambda () (incf count))))))
  (funcall (cdr (assoc 'a *counters*)))   ; => 1
  ```

  — an alist of name to closure. The `funcall` form is the same as above; the extraction is `cdr (assoc ...)` instead of `second (first ...)`.

  #strong[Surprising, but it works in SBCL and most modern implementations.] `dotimes` binds `i` per iteration, so the closures capture 0, 1, and 2 respectively, and `(3 2 1)` comes out because `push` reverses. This is implementation-defined in the standard — the standards text is ambiguous. If you want the guarantee, use `loop for i below 3` instead; if you only care about SBCL, `dotimes` is fine.

  The real trap the exercise warns about: when the closure captures an #emph[outer function parameter] rather than the loop's own binding. That case always fails, in every implementation:

  ```text
  (defun make-wrong-fns (limit)
    (let ((fns nil))
      (dotimes (i limit (nreverse fns))
        (push (lambda () limit) fns))))  ; captures LIMIT not I
  ;; every closure returns the same LIMIT
  ```

  The `lambda`'s free variable is `limit` — one binding, one value. Not `i`, which is per-iteration.

]

#soln("25.3")[
  ```lisp
  (defun make-average ()
    "Return a closure: running average, two values (average, count)."
    (let ((total 0)
          (count 0))
      (lambda (n)
        (incf count)
        (incf total n)
        (values (/ total count) count))))
  ```

  Check:

  ```lisp
  (defparameter *avg* (make-average))
  (multiple-value-list (funcall *avg* 4))   ; => (4 1)
  (multiple-value-list (funcall *avg* 2))   ; => (3 2)
  (multiple-value-list (funcall *avg* 9))   ; => (5 3)
  ```

  Averages: 4\/1, (4+2)\/2=3, (4+2+9)\/3=5. The two values (average, count) let callers check both the current result and how much data went into it, without a separate "how many samples?" function.

  The `:count` extension to `make-registry`:

  ```lisp
  (defun make-registry ()
    (let ((table (make-hash-table)))
      (lambda (message &optional key value)
        (ecase message
          (:put  (setf (gethash key table) value))
          (:get  (gethash key table))
          (:keys (loop for k being the hash-keys of table
                       collect k))
          (:count (hash-table-count table))))))
  ```

  Existing callers using `:put`, `:get`, `:keys` don't change; the closure gains a message. That's the payoff of the message-dispatch shape: #emph[extension by addition], no caller touched. Chapter 26's generic functions generalise exactly this to types.

]

#soln("25.4")[
  ```lisp
  (defun make-stack ()
    "Four closures over one list: push!, pop!, empty-p, contents."
    (let ((items nil))
      (values
       (lambda (x) (push x items))
       (lambda ()
         (if (null items)
             (error "Stack underflow.")
             (pop items)))
       (lambda () (null items))
       (lambda () (copy-list items)))))
  ```

  Check:

  ```lisp
  (multiple-value-bind (push! pop! empty-p contents)
      (make-stack)
    (funcall push! 1)
    (funcall push! 2)
    (let ((snapshot (funcall contents)))
      (funcall pop!)
      (list snapshot (funcall contents) (funcall empty-p))))
  ```

  Expected: `((2 1) (1) NIL)` — the snapshot taken before the pop still shows both elements; the second contents shows one; the stack isn't empty.

  The comment the exercise asks for:

  contents returns a copy, not the internal list. This is the difference between encapsulation and leaking. If contents returned items directly, a caller could do (setf (car (funcall contents)) :garbage) and corrupt the stack's internal state without using push!\/pop! — bypassing the underflow check, the size discipline, everything the stack exists for. Returning a copy means: "here is the state as it currently stands," but the state itself is still private. This is a general principle of closure-based (and class-based) objects: accessors return values, not references to mutable internal state, unless the whole point is to share that state. The same choice appears in Chapter 7's item-name (returns a fresh string) vs an accessor that returned the symbol-name directly (would be fine, since strings from symbol-name are fresh, but the habit matters). The trade-off: copying costs time and memory, so hot accessors sometimes cheat — as long as the caller's contract forbids mutation. The game's #strong[item-locations] is a counter-example: it's returned directly because callers are expected to mutate it via set-location. Which is right depends on what the interface promises.

]

#soln("25.5")[
  ```lisp
  (defun make-key-matcher (key target)
    "A predicate: does (funcall KEY item) equal TARGET?"
    (lambda (item) (equal (funcall key item) target)))
  ```

  Use with `find-if`:

  ```lisp
  (find-if (make-key-matcher #'room-name 'kitchen) *rooms*)
  ;; => #<ROOM kitchen>
  (remove-if-not (make-key-matcher #'room-name 'kitchen) *rooms*)
  ;; => (#<ROOM kitchen>)
  ```

  The comparison with `name-matcher`:

  - `name-matcher` is `remove-if`'s predicate: "is this room the target?" — one argument, answers yes or no.
  - `make-key-matcher` is the #emph[generalised] version: the key function can be anything, and the target comparison uses `equal` so strings work too.

  Which generalises, and why: `make-key-matcher`, because it makes the attribute-lookup part a parameter. `name-matcher` is the special case `(make-key-matcher #'room-name target)` with `eq` for the comparison — valid when the key returns symbols. The general version is what you'd use in library code; the specialised one is fine for a single use-site.

]

#soln("25.6")[
  ```lisp
  (defun make-cooldown (&optional (window 2))
    "Block commands seen in the last WINDOW calls."
    (let ((history nil))
      (lambda (message &optional cmd)
        (ecase message
          (:block
           (let ((blocked (member cmd history :test #'equal)))
             (push cmd history)
             (when (> (length history) window)
               (setf history (subseq history 0 window)))
             (not (null blocked))))
          (:reset
           (setf history nil)
           t)))))
  ```

  Wire it into the game:

  ```lisp
  (defparameter *cooldown* (make-cooldown))

  (defun run-command (command)
    "Execute COMMAND.  Two values: reply, known-p."
    (if (funcall *cooldown* :block command)
        (values "Not again." t)
        (restart-case
            (handler-case (call-command command)
              (program-error ()
                (values "Wrong number of arguments for that command." t)))
          (retry-with (fixed)
            :report "Run a corrected command instead."
            (run-command fixed)))))
  ```

  Check:

  ```lisp
  (setf *current-room* (find-room 'kitchen))
  (setf *item-locations* '((key . kitchen)))
  (funcall *cooldown* :reset)

  (list (run-command '(look))
        (run-command '(look))
        (run-command '(take key))
        (run-command '(look)))
  ```

  Expected: the look description, `("Not again." T)`, the take message, then the look description again — because `look`, `take`, `look` doesn't repeat `look` within the last two commands; only consecutive-in-window repeats are blocked.

  The comment the exercise asks for:

  Cooldown is (a) session state, like history. It's about this play-through's interaction rhythm, not the world's state. If the player quits and reloads, a fresh cooldown is correct — punishing them for reconnecting would be bad UX. The rule: ask "would a loaded game have this state back where it was?" If yes, it's world state (structures, alists, saved). If no, it's session state (closures, not saved). Item locations are world state — the player expects the key to be where they left it. Cooldown is session state — the player expects a fresh start. The subtlety the exercise probes: could a designer argue the other way? Yes — "you have to wait 2 commands between looks" could be world state, surviving saves. That would be a game design choice, and it would require promoting the cooldown closure to a save-relevant structure (an alist or class). The default is session state because it serves the player; the alternative is available if the design needs it. The decision isn't mechanical — it's about #emph[whose needs the state serves].

]

== Chapter 26

#soln("26.1")[
  ```lisp
  (defclass lamp (thing)
    ((lit :initarg :lit
          :accessor lit-p
          :initform nil)))

  (defparameter *my-lamp* (make-instance 'lamp :name 'lamp))
  (lit-p *my-lamp*)            ; => NIL
  (setf (lit-p *my-lamp*) t)
  (lit-p *my-lamp*)            ; => T
  ```

  The `:accessor` gives both directions; `:reader` would have made the `setf` a "no setf-expander" error. The `:initform nil` is redundant (all slots default to `nil` unless told otherwise), but writing it makes the intent explicit, which is worth the line.

]

#soln("26.2")[
  ```lisp
  (defclass a () ((x :reader x-of :initform 1)))
  (defclass b (a) ((x :reader x-of :initform 2)))

  (x-of (make-instance 'b))   ; => 2
  ```

  The answer is 2 because `b` redefines the `x` slot: it does not add a second one. `make-instance` of `b` initialises `x` from `b`'s `:initform`, the most specific class in the precedence list, and `x-of` reads that slot. One slot per name, nearest definition wins — the precedence rule at work on slots rather than methods.

  Contrast with a case where `b` #emph[didn't] redefine `x`:

  ```lisp
  (defclass a () ((x :reader x-of :initform 1)))
  (defclass b (a) ())
  (x-of (make-instance 'b))   ; => 1 — inherited, unchanged
  ```

  The `x` slot lives in `a`; `b` has no opinion about it; the inheritance chain supplies the value. Redefining a slot in a subclass doesn't extend it, it replaces it — a common source of confusion when refactoring a class hierarchy.

]

#soln("26.3")[
  ```lisp
  (defgeneric empty-thing-p (thing)
    (:documentation "Is THING empty?"))

  (defmethod empty-thing-p ((t2 thing))
    nil)   ; the default: things are not empty

  (defmethod empty-thing-p ((c container))
    (null (contents c)))
  ```

  Check:

  ```lisp
  (list (empty-thing-p *key-thing*)   ; => NIL
        (empty-thing-p *chest*)       ; => NIL (it holds crown, gem)
        (empty-thing-p (make-instance 'container :name 'empty-box)))
  ;; => (NIL NIL T)
  ```

  The comment the exercise asks for:

  :before and :after compose — they all run — so they can't choose between answers; only primary methods select, and the question "is it empty" wants exactly one answer, the most specific one's. Whenever a method computes a #emph[value] rather than performing a #emph[side effect], it belongs as a primary method. `:before` would run the primary anyway; `:after` would run after; either would give two answers for the same question, and callers wouldn't know which to trust. Primary methods answer; before\/after methods prepare and clean up.

]

#soln("26.4")[
  #strong[Wrong:] `potion` never declares `:reader` or `:accessor` for `colour`, so `thing-colour` doesn't exist — and neither does `colour`, since no slot named `colour` is readable. And the name `thing-colour` is the wrong guess: it would be `potion-colour` or just `colour`, depending on how the slot was declared. Fix: declare `:reader colour`:

  ```lisp
  (defclass potion (thing)
    ((colour :initarg :colour :reader colour)))
  ```

  Now `(colour *potion*)` works. `(thing-description *potion*)` also works — `potion` inherits `thing-description` — but only if the potion instance has a `:description`; the class inherits the `:initarg`, and the default `:initform` from `thing` covers it.

  #strong[Wrong:] the method names the class `thing` before `defclass` has run. Loading the file top to bottom, `defmethod` fails with "The class THING is not defined" — or worse, treats `thing` as an undefined variable in the specialiser. Order the file: classes, then methods — or let ASDF's `:serial` do it (Chapter 20's lesson, in a CLOS context).

  #strong[Wrong:] `(typep 'thing 'thing)` is `nil`: the first argument is the #emph[symbol] `thing`, not an instance. (typep #strong[key-thing] 'thing) is the question with an object in it, and gives `t`. The quote in `typep`'s second argument is type syntax, not object reference; the quote in `'thing` as the #emph[first] argument is exactly what makes it a symbol rather than an instance.

]

#soln("26.5")[
  ```lisp
  (defmethod combine ((a symbol) (b symbol))
    (list a b))

  (defmethod combine ((a string) (b number))
    (format nil "~A~D" a b))

  (defmethod combine (a b)
    (error "Can't combine ~S and ~S." a b))
  ```

  Check:

  ```lisp
  (list (combine 'a 'b)
        (combine "x" 5)
        (ignore-errors (combine 1 "x")))
  ```

  Expected: `((A B) "x5" NIL)` — the third call signals, so `ignore-errors` returns nil; without it, the debugger opens.

  Three more methods on top of the chapter's four. That's the point of the exercise: with dispatch on two arguments and several types each, the number of methods is the #emph[product] of the cases you want — specific pairs — not the sum, and the catch-all on `t` keeps the generic function total. A `typecase` version would have one ever-growing body; here each case is independent and can be added from a different file by a different author.

  The catch-all method is the discipline: without it, calling `combine` on a pair with no matching method signals `no-applicable-method`, which is less helpful than a specific error. With it, the error names the arguments. That's the trade — a catch-all method gives you control over the error's shape, at the cost of one extra method.

]

#soln("26.6")[
  ```lisp
  (defmethod initialize-instance :after ((c container) &key)
    (when (contents c)
      (setf (contents c)
            (sort (copy-list (contents c)) #'string<
                  :key #'symbol-name))))
  ```

  Check:

  ```lisp
  (defparameter *box*
    (make-instance 'container
                   :name 'box
                   :contents '(zebra apple)))
  (contents *box*)   ; => (APPLE ZEBRA)
  ```

  The `:after` method runs after the slot is filled from `:initarg`, so it sees the given contents and repairs them. `copy-list` before `sort` is Chapter 10's rule about not sorting things you don't own — the list in the slot may be the caller's. The :key `#'symbol-name` makes `string<` compare the names of the symbols, alphabetically.

  Sorting content is a `/repair`, not a semantic transformation: the same set of things, put in a canonical order. That's the right shape for `initialize-instance :after` — it enforces an invariant without changing meaning. A `:after` that filtered duplicates would be more aggressive; it would be visible transformation, and better signalled by a separate method called by the caller, not by `make-instance`.

]

#soln("26.7")[
  ```lisp
  (defgeneric weight (thing)
    (:documentation "How much does THING weigh?"))

  (defmethod weight ((t2 thing)) 1)

  (defmethod weight ((c container))
    (+ 1 (length (contents c))))

  (defun total-weight (symbols)
    "Sum the weights of the registered things named in SYMBOLS."
    (reduce #'+ (mapcar (lambda (s)
                          (weight (lookup-thing s)))
                        symbols)))
  ```

  Check:

  ```lisp
  (total-weight '(key chest))
  ;; => 1 + 3 = 4
  ```

  — with the chest holding `(crown gem)`, `(weight #strong[chest])` is `1 + 2 = 3`, and the key is `1`. Sum `4`.

  What happens with an unregistered symbol: `(lookup-thing 'unregistered)` returns `nil`, and `(weight nil)` signals — `weight`'s methods both specialise on classes (`thing` and `container`) and `nil` is an instance of neither. So the chain of failures runs mapcar → weight → no-applicable-method → `debugger`. That suggests where a `handler-case` belongs — in `total-weight`, at the level that knows what "missing item" means for its own contract:

  ```lisp
  (defun total-weight (symbols)
    "Sum the weights of the registered things in SYMBOLS."
    (handler-case
        (reduce #'+ (mapcar (lambda (s) (weight (lookup-thing s)))
                            symbols))
      (error () nil)))   ; or signal a specific condition
  ```

  The generic version of the exercise's question — "where does condition handling belong" — is Chapter 19's flags-vs- conditions rule, one more time. `total-weight`'s caller wants a total or a signal of "some symbols don't resolve", not a raw `no-applicable-method` error about `nil`. The handler is the translation layer.

]

#soln("26.8")[
  ```lisp
  (defun list-things (command)
    "Handle (LIST-THINGS): list every registered thing, alphabetically."
    (declare (ignore command))
    (let ((lines nil))
      (maphash (lambda (sym instance)
                 (push (format nil "~(~A~): ~A"
                               sym (thing-description instance))
                       lines))
               *thing-registry*)
      (format t "~{~A~%~}" (sort lines #'string<))))
  ```

  Register it:

  ```lisp
  (push '(list-things . list-things) *commands*)
  ```

  Check:

  ```lisp
  (list-things '(list-things))
  ```

  Expected output (sorted by the string, so the symbol's name sort matters — `chest`, `crown`, `key`, `lamp`, `vase`):

  ```text
  chest: a wooden chest.
  crown: a tarnished crown.
  key: a small brass key.
  lamp: an oil lamp, dusty but intact.
  vase: a thin porcelain vase.
  ```

  The comment the exercise asks about — what does the class hierarchy buy over a plist:

  Storing the description on the symbol's plist would work for the description itself: (setf (get 'key 'description) "...") puts it where get can find it. Three things the class hierarchy buys beyond that:

  + Structured data. A thing can have several slots — name, description, weight, value, contents — that belong together as one thing, distinguishable by which instance carries which. A plist on a symbol mixes the description, the weight, and everything else into one flat list; keeping the fields associated per-instance is a discipline the plist doesn't enforce.

  + Behaviour that varies by kind. describe-thing dispatches on class; there is no way to make (get 'key 'description) vary by kind without writing if-typecase logic. Adding a new kind (fragile, say) means one new class and one new method; adding it to the plist world means editing every function that reads the plist.

  + State safety. A plist is global mutable state attached to a symbol — remprop, setf get, any code anywhere can corrupt it (Chapter 23's warnings). An instance's slot is protected by the class's accessor contract, and two instances of the same class never share state accidentally.

  The plist's one advantage: symbolic stability. A symbol's plist is the same wherever the symbol appears; a class instance must be passed. For constants attached to a name, plists are fine. For a #emph[thing], with several slots and behaviour, classes are the right shape.

]

== Chapter 27

#soln("27.1")[
  ```lisp
  (defclass a () ())
  (defclass b (a) ())
  (defclass c (a) ())
  (defclass d (b c) ())

  (mapcar #'class-name
          (sb-mop:class-precedence-list (find-class 'd)))
  ```

  Expected: `(D B C A STANDARD-OBJECT T)`.

  The rule: the class itself first, then its direct superclasses #emph[left to right], then their superclasses, deduplicated. `b` and `c` share `a`, so `a` comes once (after both its children — it's the superclass of both). Then `standard-object` (the default CLOS parent), then `t` (everything).

  `b`'s methods win over `c`'s: `b` is leftmost in `d`'s superclass list, so it appears first in the precedence list, so a method specialised on `b` is more specific than one specialised on `c` for a `d` instance. If `d`'s superclass list were `(c b)` instead, `c`'s methods would win.

  That leftmost-wins rule is why the order in the superclass list is meaningful, and why "put the primary nature first" is the advice. If you reorder the superclass list as a "refactor", you may change method dispatch throughout the hierarchy.

]

#soln("27.2")[
  #strong[Wrong:] the `:after` method computes a string that is then #emph[discarded] — auxiliary method results don't contribute to a generic function's return value, only side effects matter. The description never appears anywhere. Fix: store the result or make it a primary method:

  ```lisp
  (defmethod describe-widget ((w widget))
    (format nil "x is ~A" (widget-x w)))
  ```

  A primary method's value #emph[is] the generic function's result when it's the only one or the most-specific one. That's the shape you want for "return a string describing this thing".

  #strong[Surprising:] the `:after` on `sub` runs after `sub`'s primary method for the accessor `n`. That means every read of `n` on a `sub` instance increments the slot by 10 — a read that mutates. Ten reads in a row, the slot has grown by 100. That's not "add 10 to the result"; that's "the act of reading changes the state". It looks like a bug in the accessor, and it is. Fix: don't mutate in an accessor-adjacent method. If `sub` needs a derived value, give it its own accessor and compute on demand:

  ```lisp
  (defclass sub (base)
    ((bonus :initform 10 :accessor bonus)))

  (defun n-total (s) (+ (n s) (bonus s)))
  ```

  Then `n` stays pure (reads the slot, returns the value); `n-total` is the derived value, computed fresh each call.

  #strong[Wrong:] `(defmethod area ((s shape)) 0)` specialises on `shape`, which is not defined — the `defmethod` signals "The class SHAPE is undefined" unless a `shape` class exists. The fix is to define the class first (or specialise on `t` for the catch-all):

  ```lisp
  (defclass shape () ())
  (defgeneric area (shape))
  (defmethod area ((s shape)) 0)
  ```

  Also note the `defgeneric` placement: declaring the generic function #emph[before] its methods is the readable order, and catch-all `t` specialisers read poorly — prefer a real base class.

]

#soln("27.3")[
  ```lisp
  (defparameter *method-notes* nil)
  ;; entries: (class-name kind function-or-description)

  (defun note-method (class-name kind what)
    (push (list class-name kind what) *method-notes*))

  (defun describe-chain (instance)
    "Print the precedence list with known methods per class."
    (dolist (class (sb-mop:class-precedence-list (class-of instance)))
      (let ((name (class-name class))
            (notes (remove-if-not
                    (lambda (n) (eq (first n) name))
                    *method-notes*)))
        (format t "~&~(~A~):~%" name)
        (dolist (n notes)
          (format t "  ~A — ~A~%" (second n) (third n))))))

  ;; demo data:
  (note-method 'thing :primary "price: base 1")
  (note-method 'treasure :primary "price: (value tr)")
  (note-method 'antique :primary "price: 50")
  (note-method 'container :primary "price: 2")
  (describe-chain (make-instance 'antique
                    :name 'mirror
                    :value 200))
  ```

  Expected output:

  ```text
  ANTIQUE:
    PRIMARY — price: 50
  TREASURE:
    PRIMARY — price: (value tr)
  THING:
    PRIMARY — price: base 1
  STANDARD-OBJECT:
  T:
  ```

  The output teaches the chapter's central fact: method order surprises are #emph[precedence surprises] — the methods aren't mysterious; they're listed class by class, and what felt like random dispatch is the precedence list being walked in order. When dispatch surprises you, print the chain before guessing.

  The real MOP versions of this — `compute-applicable-methods` returning the actual applicable methods for a given call, `find-method` looking up a method by specialisers — exist and are worth knowing by name. But `compute-applicable-methods` is on `standard-generic-function`, and its results are implementation-defined in some respects. The manual registry above is honest: it says "here's what I know about my own code's methods", which for application code is what you can actually rely on.

]

#soln("27.4")[
  ```lisp
  (defgeneric participants ()
    (:method-combination list))

  (defclass round-table () ())
  (defclass round-table-plus (round-table) ())

  (defmethod participants list ((r round-table)) 'alice)
  (defmethod participants list ((r round-table-plus)) 'bob)

  (participants (make-instance 'round-table-plus))
  ;; => (BOB ALICE) — most specific first
  ```

  The timing around-method:

  ```lisp
  (defmethod participants :around ((r round-table))
    (let ((start (get-internal-run-time))
          (result (call-next-method)))
      (format *trace-output* "participants: ~D ticks~%"
              (- (get-internal-run-time) start))
      result))

  (participants (make-instance 'round-table-plus))
  ;; => (BOB ALICE), and a trace line
  ```

  The `:around` must specialise on the most general class the generic function `serves` — `round-table` here, or `t`, but never on `round-table-plus` — so it wraps every call. If it specialised on `round-table-plus`, timing would record only calls on plus instances, and a caller timing `(make-instance 'round-table)` would see no trace. The `:around`'s specialiser controls #emph[which calls it sees], and you want it to see all of them.

  One more subtlety: `call-next-method` in an `:around` invokes the #emph[rest of the combination] — all remaining methods, combined — not merely "the next primary". For a `list` combination, that means all remaining primary methods contribute to the returned list. The `:around` sees them as a single combined result.

]

#soln("27.5")[
  ```lisp
  (define-condition class-change-drops-slots (error)
    ((slots :initarg :slots :reader dropped-slots))
    (:report (lambda (c s)
               (format s "change-class would drop: ~{~A~^, ~}"
                       (dropped-slots c)))))

  (defun slot-names (class)
    "Names of CLASS's slots, including inherited."
    (let ((names nil))
      (labels ((walk (c)
                 (dolist (s (sb-mop:class-direct-slots c))
                   (pushnew (sb-mop:slot-definition-name s) names))
                 (dolist (super (sb-mop:class-direct-superclasses c))
                   (walk super))))
        (walk class)
        names)))

  (defun safe-change-class (instance new-class-name)
    "Change INSTANCE's class, refusing to drop slots."
    (let* ((old-class (class-of instance))
           (new-class (find-class new-class-name))
           (old-slots (slot-names old-class))
           (new-slots (slot-names new-class))
           (dropped (set-difference old-slots new-slots)))
      (when dropped
        (error 'class-change-drops-slots :slots dropped))
      (change-class instance new-class)))
  ```

  Check:

  ```lisp
  (defclass small-thing (thing) ())
  (defclass large-thing (thing) ())
  (defparameter *item* (make-instance 'small-thing :name 'coin))
  (safe-change-class *item* 'large-thing)   ; works; no slot dropped

  (defclass bigger-thing (thing)
    ((mass :initform 1)))
  (safe-change-class *item* 'bigger-thing)  ; works too
  ;; (round-trip to a smaller class would refuse if slots dropped)
  ```

  What the refusal teaches: `change-class`'s slot policy is #emph[name-based] — slots with the same name carry over, new slots are added with their `:initforms`, and slots the new class #emph[lacks] are simply #emph[gone], silently, no condition, no warning. That's generous for interactive work (a quick experiment doesn't get blocked by slot mismatches) and dangerous for state you care about (the game's inventory could lose an item's worth slot by an accidental class change).

  The MOP functions `slot-definition-name`, `class-direct-slots` and `class-direct-superclasses` are technically beyond the ANSI standard — they're the Metaobject Protocol, and SBCL ships them (mostly via `closer-mop` for the portable name). The `slot-names` above is portable-ish but not guaranteed; a hand-maintained slot table for the classes you care about would work too. The check is the point; the mechanism is a detail.

]

#soln("27.6")[
  ```lisp
  (defclass room ()
    ((name :initarg :name :reader room-name)
     (description :initarg :description :reader room-description)
     (exits :initarg :exits :initform nil :accessor room-exits)))

  (defclass dark-room (room) ())
  (defclass visited-room (room) ())

  (defgeneric weight (room)
    (:method-combination +))

  (defmethod weight + ((r room))
    (max 1 (length (room-exits r))))

  (defmethod weight + ((r dark-room))
    5)

  (defmethod weight + ((r visited-room))
    -2)

  (defparameter *dungeon*
    (list (make-instance 'room :name 'hall :exits '(a b c))
          (make-instance 'dark-room :name 'crypt :exits '(a))
          (make-instance 'visited-room :name 'foyer :exits '(b))))

  (defun find-room-by-name (name)
    (find name *dungeon* :key #'room-name))

  (defun safest-exit (here)
    "The exit destination with the lowest weight."
    (first
     (sort (copy-list (room-exits here))
           #'<
           :key (lambda (dest-name)
                  (weight (find-room-by-name dest-name))))))

  (safest-exit (find-room-by-name 'hall))
  ;; => error: no applicable method for NIL
  ```

  The demo data is wrong, and the error is worth reading: exits are room #emph[names] (symbols), but `hall`'s exits are `(a b c)` and none of those rooms exist in `*dungeon*`. Then `find-room-by-name 'a` is `nil`, and `(weight nil)` has no applicable method. Fix the data:

  ```lisp
  (defparameter *dungeon*
    (list (make-instance 'room :name 'hall :exits '(crypt foyer))
          (make-instance 'dark-room :name 'crypt :exits '(hall))
          (make-instance 'visited-room :name 'foyer :exits '(hall))))

  (safest-exit (find-room-by-name 'hall))
  ;; => FOYER
  ```

  Now `crypt` is a `dark-room` (weight 5 from dark + 1 from room = 6); `foyer` is a `visited-room` (weight 1 from room + -2 from visited = -1). Safest exit is the one with the lowest weight, `foyer` at -1.

  The comment the exercise asks for:

  `+` is right because room difficulty #emph[adds up] — base cost from exit count, plus darkness penalty, minus visit discount is an arithmetic sum of independent contributions, and each class owns exactly its contribution. `max` would be wrong because it picks #emph[one] contribution and discards the others: a dark, visited room would weigh 5 (the darkness penalty) instead of 1+5-2=4, and the whole point of the visit discount would be lost. Adding a new factor (say, a `flooded-room` penalty class) with `max` means rewriting the combination logic, where `+` just gains another method. The rule: `+` when contributions are independent quantities that sum; `max` when the answer is "the single worst (or best) factor" — and mixing the two readings in one generic function is the design smell to fix by splitting it in two.

  There's a subtlety worth stating: negative contributions. -2 from `visited-room` means a visited room is #emph[safer] than an unvisited one. With `max` combination, negative contributions would vanish; with `+`, they accumulate. If your game design wanted "visited rooms always score at least as safe as unvisited ones, never less than 0", you'd need a floor: max 0 `(weight ...)` applied after the sum. The combination type controls what "score" means; the game design controls where the floor is.

]

== Chapter 28

#soln("28.1")[
  ```lisp
  (list (find-symbol "LIST" :cl)   ; => LIST, :EXTERNAL
        (find-symbol "list" :cl)   ; => NIL, NIL — tables are case-sensitive
        (eq 'cl:car (intern "CAR" :cl))  ; => T — same symbol
        (symbol-package 'cl:car)   ; => #<PACKAGE "COMMON-LISP">
        (symbol-package 'car)      ; => #<PACKAGE "COMMON-LISP">
        (multiple-value-list (find-symbol "RUN-COMMAND" :con)))
  ;; => (RUN-COMMAND :EXTERNAL) if exported, (RUN-COMMAND :INTERNAL)
  ;;    if it's interned but not exported
  ```

  The `symbol-package 'car` line is the inheritance lesson: `symbol-package` answers "where is this symbol #emph[home]", not "how did I reach it". In `cl-user`, `car` resolves to the `CL:CAR` symbol by inheritance — the `cl-user` table doesn't hold a `CAR` of its own — and so `symbol-package` correctly reports `:common-lisp`. Inheritance is a lookup fact, not a property of the symbol.

  The last line is about the game's own package: `:con` is the nickname for `:cave-of-noise`, and `run-command` should be exported (it's in the API surface from Chapter 28's project step), so its status is `:external`. If you get `:internal`, the export list is missing it; if `NIL NIL`, the package isn't loaded.

]

#soln("28.2")[
  #strong[Surprising, but it works:] `(use-package :p1)` after `:cl` means `cl-user` now sees both `CL`'s exports and `P1`'s exports. `run` resolves to `p1:run` by inheritance, and evaluating `run` calls `p1:run` (returns `:p1s`). No conflict, because `cl-user` didn't have its own `run` before the `use-package`.

  The trap that #emph[would] fail:

  ```text
  (defpackage :p1 (:use :cl) (:export :run))
  (defun run () :cl-users-own)  ; interns RUN in cl-user
  (use-package :p1)              ; conflict! cl-user's RUN vs p1's RUN
  ```

  The conflict fires at `use-package` time, because `run` is now findable two ways in `cl-user`. The resolution restarts offer "keep the local one" (shadowing-import) or "keep the imported one" (unintern the local). In the exercise's original snippet, the order (`p1`'s `run` interned first, `cl-user`'s `run` never interned) means no conflict — but that's a fragile situation where the code's correctness depends on what's been evaluated before.

  #strong[Surprising:] `(defpackage :p2 (:use :cl :p1))` is fine at definition time; the conflict fires at `(defun run () :p2s)`, because `p2` now inherits `run` from `p1` and tries to intern its own `run`. SBCL signals a correctable error: which `run` does `p2` mean? The fix — as the answer above shows — is to explicitly shadow the name:

  ```lisp
  (defpackage :p2
    (:use :cl)
    (:import-from :p1 :other-name)   ; only what's needed
    (:shadow :run))
  ```

  Better still, don't `:use` a package you're going to redefine names from — that's what `:import-from` is for. Only import the specific names you want; the ones you redefine stay local, with no conflict.

  #strong[Surprising:] `(unintern 'temp :p1)` doesn't do what it looks like. `'temp` reads as `cl-user::temp` — the symbol named `TEMP` home in `CL-USER`, not the one interned in `:p1` by `(intern "TEMP" :p1)` above. `unintern` asks: is #emph[this symbol] (the `cl-user` one) present in `:p1`'s table? It isn't — different symbol, same name. So `unintern` does nothing, and the `p1:temp` symbol from the first line stays interned.

  #strong[Surprising:] `p1::temp` reads as "look up `TEMP` in `:p1`, creating a new symbol if absent". The old one is still there (the `unintern` above missed), so `p1::temp` returns it. The symbol is unbound (never used as a variable), so evaluating `p1::temp` as a variable signals `UNBOUND-VARIABLE`.

  The fix, if the intent was to actually unintern:

  ```lisp
  (unintern (find-symbol "TEMP" :p1) :p1)
  ;; or more directly:
  (unintern (intern "TEMP" :p1) :p1)   ; two intern calls, same symbol
  ```

  `find-symbol` is safer — it doesn't accidentally intern if the symbol is missing. `(unintern (find-symbol "TEMP" :p1) :p1)` returns non-nil if the unintern succeeded, nil if `find-symbol` returned nil (symbol wasn't there to begin with).

]

#soln("28.3")[
  ```lisp
  (defun where-does-name-live (name &optional (package *package*))
    "Where NAME is findable in PACKAGE, as a keyword or :absent."
    (multiple-value-bind (sym status)
        (find-symbol (string name) package)
      (declare (ignore sym))
      (or status :absent)))

  (defun find-anywhere (name package)
    "The first package, in precedence order, where NAME is findable."
    (let ((status (where-does-name-live name package)))
      (cond ((eq status :external) package)
            ((eq status :internal) package)
            (t
             (some (lambda (used)
                     (when (member (where-does-name-live name used)
                                   '(:external :internal))
                       used))
                   (package-use-list package))))))
  ```

  Check:

  ```lisp
  (where-does-name-live "CAR" :cl-user)     ; => :INHERITED
  (where-does-name-live "PLAY" :con)        ; => :EXTERNAL
  (where-does-name-live "NONEXISTENT" :cl)  ; => :ABSENT
  (find-anywhere "CAR" :cl-user)            ; => #<PACKAGE "COMMON-LISP">
  ```

  The precedence lesson: the reader resolves an unqualified name first in the current package's own table (internal and external alike), then walks the use-list in #emph[order]. Local beats inherited — which is what `shadow` exploits, and what makes definition order in your own package irrelevant to whether your names beat `cl`'s.

  The `:INHERITED` status is what `where-does-name-live` gives when `:cl-user` doesn't hold the symbol itself but can find it via a used package. `:EXTERNAL` and `:INTERNAL` are the package's #emph[own] symbols. `:ABSENT` means neither the package nor any of its used packages has it.

  The reader's algorithm, stated precisely:

  + Look up the name in the current package's own table. If found, use that symbol (regardless of whether it's exported).
  + Otherwise, walk the use-list, in the order the packages appear in it. The first package with the name (external only — internal names aren't inherited) supplies the symbol.
  + Otherwise, intern a fresh symbol in the current package.

  Step 3 is why evaluating `nonexistent` at the REPL creates a new symbol in `cl-user` rather than erroring. The reader's job is to produce #emph[a symbol], and if it can't find one, it makes one.

]

#soln("28.4")[
  ```lisp
  (defun package-externals (package)
    "The external symbols of PACKAGE, as a list."
    (let ((names nil))
      (do-external-symbols (s package names)
        (push s names))))

  (defun package-diff (p1 p2)
    "Three values: shared externals, only-p1, only-p2."
    (let ((e1 (package-externals p1))
          (e2 (package-externals p2)))
      (values (intersection e1 e2)
              (set-difference e1 e2)
              (set-difference e2 e1))))
  ```

  Check (on SBCL — other implementations differ):

  ```lisp
  (multiple-value-bind (both only-cl only-sb)
      (package-diff :cl :sb-ext)
    (list (length both) (length only-cl) (length only-sb)))
  ;; => (0 978 42) — typical SBCL
  ```

  The near-zero intersection is the point: implementation packages are #emph[additions], never redefinitions of `:cl`. `:sb-ext` exports things like `save-lisp-and-die`, `exit`, `*posix-argv*` — extension symbols not present in the standard. `:cl` exports the language. They don't overlap because the implementation isn't allowed to redefine standard symbols; it can only add.

  `package-diff` is the audit that proves it for any pair of packages you're about to `:use` together. If the intersection is non-empty, you'll get conflicts at `use-package` time; if it's empty, the two packages compose cleanly. That's why `:use :cl` is safe and `:use` of two foreign libraries is risky.

  One caveat the exercise's counts hide: `set-difference` on `e1` and `e2` returns symbols, not names. Two packages can export symbols with the same #emph[name] that are distinct #emph[symbols] — `(set-difference e1 e2)` won't find those as intersections. For a real conflict-audit, compare `(symbol-name s)` across the sets, not `s` itself.

]

#soln("28.5")[
  ```lisp
  (defmacro with-temp-package (&body body)
    "Evaluate BODY with *PACKAGE* bound to a fresh package."
    (let ((pkg-var (gensym "PKG-"))
          (name-var (gensym "NAME-")))
      `(let* ((,name-var (symbol-name (gensym "TEMP-PKG-")))
              (,pkg-var (make-package ,name-var :use '(:cl)))
              (*package* ,pkg-var))
         (unwind-protect
              (progn ,@body)
           (when (find-package ,name-var)
             (delete-package ,name-var))))))
  ```

  Check:

  ```lisp
  (with-temp-package
    (intern "FRESH")
    (find-symbol "FRESH"))
  ;; => FRESH, :INTERNAL — created in the temp package

  (with-temp-package
    (defun probe () :inside)
    (probe))
  ;; => :INSIDE, but note where PROBE was interned
  ```

  Two things to notice in that second check:

  First, `(defun probe ...)` #emph[was read] before the macro ran — the reader read `probe` as a symbol in whatever package was current #emph[at the call site], which is `cl-user`. The `defun` form evaluates (installing the function), but the symbol `probe` was already interned in `cl-user`. The `*package*` binding inside the temp package doesn't change where already- read symbols are homed.

  Second, `(probe)` inside the body is a symbol reference `probe` — read in `cl-user` — that the reader resolved before the temp package existed. So it calls the `cl-user::probe` function.

  The macro's `*package*` binding affects what #emph[runtime interning] does, not what the reader does during source reading. That matters for `(intern "X")` and `(read ...)` calls inside the body, not for `defun`\/`defparameter`\/etc., whose symbols were read as tokens before the macro ran.

  What the exercise assumes about `delete-package`'s requirements: `delete-package` requires no other package to #emph[use] the package. Since the temp package is freshly created with no consumers, this holds — the deletion succeeds. If some body form did `(use-package temp-name ...)` from another package (hard to arrange in practice, since the temp package has no exports and no code could reference it by name — `find-package` on the gensym's name string works, but the name is computed at macro-expansion time and not accessible to the body), deletion would fail with a condition, and the `when (find-package ...)` guard wouldn't help.

  The exercise's honest limit: the macro is a demonstration of `*package*` binding and `delete-package`, not a general tool for package isolation. A real "temp package" macro in production would need to also handle `use-package` by others, and would need to expose the package name for testing if anything outside wanted to reach in. For a session-local experiment, the version above is enough.

]

#soln("28.6")[
  The split, at file level:

  ```lisp
  ;; data-package.lisp
  (defpackage :cave-of-noise.data
    (:use :cl)
    (:export
     ;; state
     :*rooms* :*current-room* :*item-locations*
     :*thing-registry* :*history*
     ;; data accessors
     :find-room :lookup-thing :register-thing
     :room-name :room-description :room-exits :room-locked
     :items-here :item-location :set-location
     ;; persistence
     :save-game :load-game :*save-file* :*save-format*))
  ```

  ```lisp
  ;; main-package.lisp
  (defpackage :cave-of-noise
    (:use :cl)
    (:import-from :cave-of-noise.data
                  :*current-room*
                  :*item-locations*
                  :*rooms*
                  :*history*
                  :find-room
                  :items-here
                  :item-location
                  :set-location
                  :lookup-thing
                  :save-game :load-game)
    (:export :play :run-command :look :take :drop :inventory
             :examine :help))
  ```

  The names the main package actually needed — from counting actual uses in the game's source:

  - `*current-room*` — read by `look`, `go-to`, `take`, `drop`, `describe-room-text`, `doctor`.
  - `*item-locations*` — read\/written by `take`, `drop`, `inventory`, `loot`, `snapshot`, `undo`, `doctor`.
  - `*rooms*` — read by `find-room`, `describe-all`, `locked-rooms`, `doctor`.
  - `*history*` — read by `snapshot` and `undo`.
  - `find-room` — used by `go-to`, `doctor`, `play-to-string`.
  - `items-here` — used by `look`, `inventory`, `loot`, `describe-room-text`, `describe-all`.
  - `item-location` — used by `take`, `drop`.
  - `set-location` — used by `take`, `drop`.
  - `lookup-thing` — used by `describe-thing`, `examine`, `inventory-score`.
  - `save-game`\/`load-game` — used by `cmd-save` and `cmd-load`.

  That's ten imports, for a game whose total API surface is about nine exports. The main package leans almost entirely on the data package — nearly every command reads or writes state.

  What the import list tells you: #emph[the split is premature for this game]. A clean split would put most commands in the data package too, leaving the main package almost empty. Or the split would be by a different axis — UI (command loop, message formatting) vs model (state, accessors) — with `play`, `transcript`, `help-command` in the UI package and everything else in the model package.

  The honest conclusion the exercise points at: packages are for #emph[coupling at boundaries], not for #emph[tidiness]. If two halves of a program pass state back and forth constantly, splitting them into separate packages adds `:import-from` lines without adding isolation. The game's natural seam is between the session loop (`play`, `transcript`) and the model (everything else); that's a smaller, cleaner split than the one the exercise sketched. That's the audit the exercise wanted.

]

== Chapter 29

#soln("29.1")[
  ```lisp
  (list (uiop:run-program '("echo" "hello world") :output :string)
        (uiop:run-program '("echo" "a;b|c") :output :string))
  ```

  Expected: `("hello world\n" "a;b|c\n")` — with the trailing newline that `echo` emitted, and with the semicolon and pipe arriving #emph[verbatim]. The second line is the security argument in one example: those characters are shell metacharacters, and they came through untouched because `uiop:run-program` handed the list to `execve` directly. No shell parsed them, no injection was possible.

  ```lisp
  (list (cl-json:decode-json-from-string "[1, 2, [3]]")
        (cl-json:decode-json-from-string "{\"a\": null, \"b\": 0}"))
  ```

  Expected: `((1 2 (3)) ((:A) (:B . 0)))`.

  The first result is straightforward — a JSON array decodes to a Lisp list, nested arrays to nested lists.

  The second is the one to look at. `(:B . 0)` is a cons whose car is the keyword `:B` and whose cdr is the integer `0` — the normal alist pair. `(:A)` is a cons whose car is `:A` and whose cdr is `nil` — a JSON `null` decoded as a pair with nil value. It prints as `(:A)` (no dot) because nil is the empty list, but it's still a cons: `(consp (first result))` is `t`.

  The ambiguity is already here, in the output shape: `(cdr (assoc :a result))` is `nil` — indistinguishable from a missing key. The chapter's warning about `null`-vs-absence is visible in the raw decode. Callers that care about the distinction need to test `(assoc :a result)`, not\~`(cdr (assoc :a result))`.

]

#soln("29.2")[
  #strong[Wrong:] the `format nil` string goes through a shell — injection (a `dir` of `"; rm -rf ~"` executes), quoting bugs, platform differences. Fix: the list form:

  ```lisp
  (uiop:run-program (list "ls" dir) :output :string)
  ```

  #strong[Surprising:] `(assoc "key" decoded)` returns `nil` — the decoded alist's keys are `/keywords` `:key`, and `assoc` defaults to `eql`, which never matches a string against a keyword. Fix: `(assoc :key decoded)`, or pass :test `#'equal` if the keys were strings by design (some JSON libraries decode with string keys, and this test separates the cases).

  #strong[Wrong:] `gzip` on a missing file exits non-zero, and `run-program` signals a `subprocess-error` — uncaught, it interrupts the caller. Fix depends on intent:

  - `:ignore-error-status t` — return the exit code as the third value; caller checks.
  - `handler-case` around the call — translate to a condition the caller understands.

  The choice is Chapter 24's flags-vs-conditions rule: if the caller routinely branches on "did the command succeed?", take the flag. If the command should always succeed and a failure is a bug, let the condition fly.

  #strong[Wrong:] the decode delivers `:room` as a string `"kitchen"`, and `find-room` needs a `/symbol`. `(find-room "kitchen")` — find-room calls `(find name #strong[rooms] :key #'room-name)`, which uses `eql` by default, and no symbol is `eql` to a string. It returns `nil`, the state gets set to `nil`, and the game is quietly broken. Fix:

  ```lisp
  (defun json->state (json)
    (let ((room-str (cdr (assoc :room json))))
      (unless (stringp room-str)
        (error "Bad import: no :room field"))
      (setf *current-room*
            (find-room (intern (string-upcase room-str))))))
  ```

  The intern `(string-upcase ...)` pair is the boundary's string-to-symbol conversion. It works because the room names are interned in the current package by the game's own source, and `intern` finds the existing symbol rather than creating a new one. If the game moved its packages (Chapter 28's split), this would need the explicit package argument — `(intern (string-upcase room-str) :cave-of-noise)` — which is exactly the "the seam knows the package" discipline the chapter's project step keeps.

]

#soln("29.3")[
  ```lisp
  (defun csv->json (path)
    "CSV with headers to a JSON array of objects."
    (let* ((rows (read-csv path))
           (headers (mapcar (lambda (h) (intern (string-upcase h)
                                                :keyword))
                            (first rows)))
           (data (rest rows)))
      (cl-json:encode-json-to-string
       (mapcar (lambda (row)
                 (mapcar (lambda (h val)
                           (cons h (maybe-number val)))
                         headers row))
               data))))

  (defun maybe-number (s)
    "S as an integer, if it looks like one; otherwise the string."
    (or (ignore-errors (parse-integer s)) s))
  ```

  Check against the file from the chapter's project step:

  ```lisp
  (csv->json "/tmp/visits.csv")
  ;; => "[{\"ROOM\":\"kitchen\",\"VISITS\":3},...]"
  ```

  — a JSON array with one object per data row, keys matching the headers, numeric fields as numbers.

  The comment the exercise asks for:

  The naive number test is `ignore-errors parse-integer` — it accepts "42", "-7", and "+3" (parse-integer handles the sign); it rejects "3.5" (which JSON would call a number, so this version keeps it a string — a deliberate under-parsing). Three things it misses that a real schema would care about:

  + It interns a `/keyword` from header text. A hostile or mistaken header row floods the keyword table (Chapter 23's warning). Production code should validate against a known header set, not trust the file.

  + `parse-integer=` on " 3 " returns 3 (it skips leading whitespace), but on "3.0" returns 3 with a second value of 2 (where it stopped). The naive `or=` keeps only the integer, silently dropping the ".0" — a value mismatch an upstream consumer might not notice.

  + Empty fields parse as nil from parse-integer's error, so `maybe-number ""` returns "", not nil — inconsistent with how JSON treats missing fields. The seam's schema should decide: is "" the empty string, a null, or absent?

  When cl-csv becomes necessary: as soon as any field contains a quoted comma, an embedded newline, or a double-quote. `uiop:split-string` on commas silently breaks those cases (producing extra fields), and the breakage is invisible until downstream arithmetic fails. For data you produce, the naive reader is fine. For data you consume, always cl-csv.

]

#soln("29.4")[
  ```lisp
  (cffi:defcfun ("abs" c-abs) :int (n :int))
  (cffi:defcfun ("getenv" c-getenv) :string (name :string))

  (c-abs -7)                 ; => 7
  (c-getenv "HOME")          ; => "/home/you", or NIL below
  (cffi:null-pointer-p
   (cffi:foreign-funcall "getenv" :string "NOPE" :pointer))
  ;; => T — signals the missing variable
  ```

  The `:string` return type on `getenv` is the trap. When the variable is absent, `getenv` returns a C `NULL` pointer, and converting `NULL` to a Lisp string is implementation- dependent — SBCL gives `nil`, most implementations give `nil`, but the standard doesn't say. The portable version declares `:pointer` return, checks `null-pointer-p`, and converts only when non-NULL:

  ```lisp
  (cffi:defcfun ("getenv" c-getenv-ptr) :pointer (name :string))

  (let ((p (c-getenv-ptr "NOPE")))
    (if (cffi:null-pointer-p p)
        nil
        (cffi:foreign-string-to-lisp p)))
  ;; => NIL, reliably
  ```

  Why `abs` needs no memory management: it takes and returns integers by `value`. The number `-7` is copied from Lisp's integer representation to a C `int` (in a CPU register, on typical ABIs), the function computes `7`, and the result is copied back. Nothing is allocated across the boundary that anyone needs to free.

  A hypothetical `malloc` binding is the opposite:

  ```lisp
  (cffi:defcfun ("malloc" c-malloc) :pointer (size :size))
  (cffi:defcfun ("free" c-free) :void (ptr :pointer))
  ```

  `malloc` returns a pointer to memory #emph[C owns until freed]. The Lisp side receives the pointer, uses it (probably by copying through `cffi:mem-ref` or similar), and then must call `c-free` to release it. `with-foreign-object` is the automatic version of this discipline (allocate, use, free on exit); `foreign-alloc` \/ `foreign-free` is the manual version (allocate, use, free explicitly). Every C resource follows the same pattern: Lisp-side lifetime management, because C doesn't know Lisp's GC exists and Lisp doesn't know C's allocations exist. Getting this wrong leaks memory through a boundary the GC can't see.

  The exercise's deeper lesson: #emph[the by-value \/ by-pointer distinction determines the interop discipline]. `abs` (by value) is a one-line call. `malloc` (by pointer) requires lifetime management on both sides. `getenv` (returning a pointer to #emph[C-owned, read-only] memory) is the awkward middle case — no free needed, but the pointer is only valid until the environment changes, and copying to a Lisp string is the right thing to do at the seam.

]

#soln("29.5")[
  ```lisp
  (defun run-and-parse (cmd)
    "Run CMD; decode each output line as a JSON object."
    (let ((out (uiop:run-program cmd :output :string)))
      (loop for line in (uiop:split-string out :separator
          (string #\Newline))
        for decoded = (ignore-errors
          (cl-json:decode-json-from-string line))
        when decoded collect decoded)))
  ```

  Simulate a producer:

  ```lisp
  (with-open-file (o "/tmp/events.jsonl"
      :direction :output
      :if-exists :supersede)
    (format o "{"event":"look"}~%")
    (format o "{"event":"take"}~%"))

  (run-and-parse '("cat" "/tmp/events.jsonl"))
  ;; => ((:EVENT . "look")) and ((:EVENT . "take"))
  ```

  The `ignore-errors` skips any line that fails to decode as JSON — a defensive choice, since a producer's output might include headers, blank lines, or log messages mixed in.

  What line-at-a-time buys: constant memory per line (the giant array case allocates all decoded objects at once before returning), incremental processing (the pipeline from Chapter 30 can consume while the producer is still writing), and resilience (one bad line doesn't lose the rest).

  When it lies: a "JSON object per line" contract (JSONL) is exactly what the format promises, but JSON itself permits objects to span lines. A producer that emits one pretty-printed object over several lines breaks this design — the parser sees partial objects, fails on each, and returns nothing. The contract is JSONL's, not JSON's, and the chapter's warning is about trusting JSONL output from a producer that doesn't actually follow JSONL.

  A second caveat: `uiop:run-program` with :output `:string` collects the #emph[entire output before this code sees it — so the "constant memory" property is only per-line during processing], not during the program's execution. For truly streaming use, `run-program` needs the streaming-output form (the one whose exact keyword has drifted across uiop versions — the chapter's pointer to `M-.` on `uiop:run-program` is the actual guidance here).

]

#soln("29.6")[
  ```lisp
  (define-condition bad-import (error)
    ((field :initarg :field :reader bad-import-field))
    (:report (lambda (c s)
        (format s "Bad import: invalid or missing ~A"
          (bad-import-field c)))))

  (defun import-state-json (json-string)
    "Restore state from a JSON exchange. Signals BAD-IMPORT."
    (let* ((alist (cl-json:decode-json-from-string json-string))
        (room-name (cdr (assoc :room alist)))
        (items (cdr (assoc :items alist)))
        (carrying (cdr (assoc :carrying alist))))
      ;; validation phase — no state touched
      (unless (and room-name (stringp room-name))
        (error 'bad-import :field :room))
      (let ((room (find-room (intern (string-upcase room-name)))))
        (unless room
          (error 'bad-import :field :room))
        (dolist (name items)
          (unless (and (stringp name)
              (lookup-thing (intern (string-upcase name))))
            (error 'bad-import :field :items))
          (dolist (name carrying)
            (unless (and (stringp name)
                (lookup-thing (intern (string-upcase name))))
              (error 'bad-import :field :carrying))
            ;; mutation phase — validation complete
            (setf current-room room)
            (dolist (name items)
              (setf item-locations
                (set-location item-locations
                  (intern (string-upcase name))
                  (room-name room))))
            (dolist (name carrying)
              (setf item-locations
                (set-location item-locations
                  (intern (string-upcase name))
                  'player)))
            t)))
  ```

  The comment the exercise asks for:

  Validate-then-apply is the only safe order because the game's state changes are not transactional. A partially-applied import — room set, items partially moved, then a validation error — leaves the game in a state no handler-case can recover from cleanly. The handler can catch the error and report "import failed", but the game is now half-imported. Validate-then- apply makes the mutation phase atomic in practice: every error fires before the first setf, so catching the condition leaves state exactly as it was.

  This is a form of the general principle "make invalid states unrepresentable" — here, "make half-applied states unreachable". True atomicity (rollback on failure) would need a transaction log or shadow copy; for single-threaded REPL use, ordering suffices.

  The bad-import condition is not a return value; it's a condition. Chapter 24's flags-vs-conditions rule applies: a corrupt import is a bug-shaped event the caller isn't expected to branch on routinely. Contrast with save-game's two-value return — "no save file" is a normal outcome (first run), so it's a flag. "Save file has the wrong shape" is a bug, so it's a condition.

  The exercise asks about "first invalid field" — the condition carries it as a slot (bad-import-field), not as a return value. The caller reads (bad-import-field c) from the caught condition. That's the same "carry the facts in slots" pattern Chapter 15's `room-not-found` showed. A return value couldn't do this — by the time the caller sees it, the error has been abstracted to "failed", and the which `field` detail is lost unless it's in the condition object.

  Check the round trip:

  ```lisp
  (setf current-room (find-room 'kitchen))
  (setf item-locations '((lamp . cellar)
      (key . kitchen)
      (letter . bedroom)))
  (register-thing 'key (make-instance 'thing :name 'key))
  (register-thing 'lamp (make-instance 'thing :name 'lamp))
  (register-thing 'letter (make-instance 'thing :name 'letter))

  (let ((json (game-state-json)))
    (setf current-room (find-room 'bedroom))
    (setf item-locations nil)
    (import-state-json json)
    (list (room-name current-room)
      (item-location 'key)))
  ```

  Expected: `(KITCHEN KITCHEN)` — the room and the item location back where the JSON said they were.

  And a validation failure:

  ```lisp
  (handler-case (import-state-json "{"room": "nowhere"}")
    (bad-import (c) (format nil "caught: ~A" c)))
  ;; => "caught: Bad import: invalid or missing ROOM"
  ```

  The room was "nowhere"`, find-room` returned nil, the condition fired #emph[before] any `setf` on the game's state. The game is untouched.

]

== Chapter 30

#soln("30.1")[
  ```lisp
  (defparameter *g* (make-list-gen '(a b)))

  (multiple-value-list (funcall *g*))   ; => (A T)
  (multiple-value-list (funcall *g*))   ; => (B T)
  (multiple-value-list (funcall *g*))   ; => (NIL NIL) — exhausted
  (multiple-value-list (funcall *g*))   ; => (NIL NIL) — stays
  ```

  The last two lines are the protocol's stickiness: a generator that has produced all its items keeps reporting exhausted. That matters for the consumers — `for-each` exits the loop on the first `(nil nil)`, and calling it again returns immediately, which is what you want if a consumer is called twice.

  ```lisp
  (collect-gen (take-gen 3 (map-gen #'* (make-counter-gen 1))))
  ;; => (2 3 4)
  ```

  Trace it. `make-counter-gen 1` produces 2, 3, 4, ... (its `incf` runs before the first return), and `map-gen #'*` applies `#'*` to each value. With #emph[one] argument, `*` returns that argument, so the mapping is the identity:

  ```lisp
  (list (funcall #'* 2) (funcall #'* 5))   ; => (2 5)
  ```

  So the result is the first three counter values, `(2 3 4)`, not the `(2 6 12)` a quick reading suggests. If the intent was "double each counter value", the function argument has to be `(lambda (n) (* 2 n))`; if it was "square each", then `(lambda (n) (* n n))`. That is the trap the exercise is built on: `#'*` alone is not "multiply by something".

  ```lisp
  (collect-gen (filter-gen (lambda (x) (> x 3))
      (take-gen 2 (make-counter-gen 0))))
  ;; => NIL
  ```

  Surprising until you read the composition inside-out: take-gen `2` yields 1 and 2 (the counter starts at 0, and `incf` makes the first value 1), neither exceeds 3, so the filter yields nothing and reports exhausted. Lazy pipelines are read inside-out — source first — the same discipline as Chapter 10's nested sequence calls, with the order of execution added: left to right per item, not stage by stage.

]

#soln("30.2")[
  Fix: two generators.

  ```lisp
  (list (collect-gen (make-list-gen '(1 2 3 4)))
    (collect-gen (make-list-gen '(1 2 3 4))))
  ;; => ((1 2 3 4) (1 2 3 4))
  ```

  If the intent really was "two independent views of the #emph[same] data", each consumer gets its own generator. If the intent was "share one traversal between two consumers", that's a different design — a `tee` that buffers — and it's a real design task, not a freebie.

  Surprising: `lazy-all-p` #emph[consumes] the generator as it checks — even when it returns `t`, the source is drained, and the caller's "keep checking afterwards" expectation fails. Every later read on that generator reports exhausted.

  The fix is context-dependent. If the caller needs to check other things on the same data, pass a `/list` and let the function rebuild a generator internally:

  ```lisp
  (defun lazy-all-p (pred items)
    (let ((g (if (functionp items) items (make-list-gen items))))
      (loop
        (multiple-value-bind (item ok) (funcall g)
          (if (not ok) (return t)
            (unless (funcall pred item) (return nil)))))))
  ```

  If the caller really does want to share one traversal, the "peek without consuming" operation has to be part of the generator protocol — a one-item buffer inside the generator — and that's a protocol extension, not a free feature.

  The general statement the exercise teaches: any consumer that walks a generator consumes it. There's no `peek` in the two-value protocol; if you need one, either the generator provides it or the caller keeps a separate source.

  ```lisp
  (let ((g (make-line-gen "/tmp/big.txt")))
    (unwind-protect
      (multiple-value-list (funcall g :next))
      (funcall g :close)))
  ```

  Or, simpler, use `with-open-file` around the whole consumption and don't use a generator at all — the generator pattern is for cases where the consumption spans multiple functions, and the resource discipline should match.

]

#soln("30.3")[
  ```lisp
  (defun gen-take-while (pred gen)
    "Items of GEN while PRED holds; exhausted at first failure."
    (lambda ()
      (multiple-value-bind (item ok)
        (funcall gen)
        (if (and ok (funcall pred item))
          (values item t)
          (values nil nil)))))
  ```

  ```lisp
  (defun gen-append (gen1 gen2)
    "All of GEN1, then all of GEN2."
    (let ((current gen1))
      (lambda ()
        (multiple-value-bind (item ok)
          (funcall current)
          (if ok
            (values item t)
            (progn (setf current gen2)
              (funcall current)))))))
  ```

  Check:

  ```lisp
  (collect-gen (gen-take-while #'plusp
      (make-list-gen '(1 3 -1 2))))
  ;; => (1 3) — stops at -1, never yields 2

  (collect-gen (gen-append (make-list-gen '(a b))
      (make-list-gen '(c d))))
  ;; => (A B C D)
  ```

  The `gen-take-while` is the lazy cousin of Chapter 10's `take-while` — the same "stop at the first failure" contract, delivered as a generator instead of a list. The difference is that the source could be infinite; a take-while over an infinite source produces a finite prefix of it.

]

#soln("30.4")[
  ```lisp
  (defun zip-gens (g1 g2)
    "Two values per step: next item of each, plus ok flag."
    (lambda ()
      (multiple-value-bind (i1 ok1) (funcall g1)
        (if (not ok1)
          (values nil nil nil)
          (multiple-value-bind (i2 ok2) (funcall g2)
            (if (not ok2)
              (values nil nil nil)
              (values i1 i2 t)))))))
  ```

  The protocol stretch: one extra value. `zip-gens` yields three — the item from `g1`, the item from `g2`, and the ok flag. When either source is exhausted, it yields `(nil nil nil)` and both consumer-side pipelines terminate.

  The critical sequencing detail: the `g2` call happens #emph[after] `g1` has produced a value, and only then. If `g1` is exhausted first, `g2` is #emph[not] called — no item is consumed from `g2` that won't be delivered. That's the correct behaviour, and the mirror case (checking `ok1` before calling `g2`) is what makes it correct. Get the order wrong and you lose an item from `g2` every time `g1` runs out early.

  Use it to generate the multiplication table's diagonal — the squares:

  ```lisp
  (defparameter squares
    (zip-gens (make-counter-gen 0) (make-counter-gen 0)))

  (loop repeat 5
    collect (multiple-value-bind (i j ok) (funcall squares)
      (if ok (* i j) nil)))
  ;; => (1 4 9 16 25)
  ```

  Why the first value is 1, not 0: make-counter-gen `0` starts its `incf` at 0, so the first call returns 1. The counter generator is "successive integers starting with one more than start" — its name is a little off, but its behaviour is consistent.

  The result `(1 4 9 16 25)` is the diagonal of the multiplication table: 1×1, 2×2, 3×3, 4×4, 5×5. The zip is the diagonal; the multiplication is the "square" that falls out of it. That's the exercise's quiet joke — the multiplication table's diagonal #emph[is] the squares.

]

#soln("30.5")[
  ```lisp
  (defun make-fib-gen ()
    "Infinite Fibonacci generator: 1 1 2 3 5 8 #| ... |#"
    (let ((a 1) (b 1))
      (lambda ()
        (let ((result a))
          (setf a b
            b (+ result b))
          (values result t)))))
  ```

  Two bindings, one shift per call. Trace it:

  call 1: result = 1, a = 1 (old b), b = 1+1 = 2. returns 1.

  call 2: result = 1 (old a), a = 2 (old b), b = 1+2 = 3. returns 1.

  call 3: result = 2 (old a), a = 3 (old b), b = 2+3 = 5. returns 2.

  call 4: result = 3, a = 5, b = 3+5 = 8. returns 3.

  The first two results are 1 and 1 — the exercise's expected sequence.

  The sum-below consumer needs #emph[early stop] — `for-each` runs to exhaustion, which never comes for an infinite source. The stopping belongs to the consumer side of the protocol:

  ```lisp
  (defun fib-sum-below (limit)
    (let ((g (make-fib-gen))
        (total 0))
      (loop
        (multiple-value-bind (n ok) (funcall g)
          (if (or (not ok) (>= n limit))
            (return total)
            (incf total n))))))

  (fib-sum-below 100)
  ;; => 232
  ```

  The expected value: 1 + 1 + 2 + 3 + 5 + 8 + 13 + 21 + 34 + 55

  89 = 232. (89 + 55 = 144, which is `>` 100, so the sum stops before adding it. The check \< n `limit` returns before `incf`, so 144 never enters the total.)

  The answer to the exercise's question — "which side of the protocol does the stopping belong to?" — is #emph[the consumer]. The generator is passive; it produces only when called, and calling is the consumer's act. An infinite source is safe #emph[because] the consumer can stop calling. If the generator tried to be "the thing that decides when to stop", it would need to know things it can't know (what limit is the current consumer using?), and the two-value protocol is designed to keep that decision on the consumer side.

]

#soln("30.6")[
  ```lisp
  (defun make-room-viz-gen (&optional (start current-room))
    "Depth-first generator of reachable rooms, no repeats."
    (let ((visited (list (room-name start)))
        (queue (list start)))
      (lambda ()
        (if (null queue)
          (values nil nil)
          (let ((room (pop queue)))
            (dolist (dest (room-exits room))
              (unless (member dest visited)
                (push dest visited)
                (let ((r (find-room dest)))
                  (when r (push r queue)))))
            (values room t))))))
  ```

  For BFS, the discoveries need to be appended, not pushed:

  ```lisp
  (defun make-room-viz-gen-bfs (&optional (start current-room))
    "Breadth-first generator of reachable rooms, no repeats."
    (let ((visited (list (room-name start)))
        (queue (list start)))
      (lambda ()
        (if (null queue)
          (values nil nil)
          (let ((room (pop queue)))
            (dolist (dest (room-exits room))
              (unless (member dest visited)
                (push dest visited)
                (let ((r (find-room dest)))
                  (when r (setf queue (append queue (list r)))))))
            (values room t))))))
  ```

  Use it:

  ```lisp
  (defun print-map (&optional (limit 5))
    "Print a partial map of reachable rooms."
    (for-each (lambda (room)
        (format t "~&~(~A~) — exits: ~{~(~A~)~^, ~}~%"
          (room-name room)
          (room-exits room)))
      (take-gen limit (make-room-viz-gen))))
  ```

  Check (with the game's five rooms, kitchen as current):

  ```lisp
  (setf current-room (find-room 'kitchen))
  (print-map 5)
  ```

  Expected (DFS order, which may vary depending on exit list order):

  ```text
  kitchen — exits: hallway, garden, cellar
  cellar — exits: kitchen
  garden — exits: kitchen
  hallway — exits: bedroom, kitchen
  bedroom — exits: hallway
  ```

  The comment the exercise asks for:

  Over the recursive traversal of Chapter 8 (items-in, walking a flat alist), the generator version buys #emph[stoppability] — a map of five rooms costs exactly five room visits, and an abort mid-walk wastes nothing. Chapter 8's recursive walk had to complete before its result could be used; the generator produces incrementally. For a small map that doesn't matter; for a real exploration of a graph where each room visit might do work, it matters.

  What closure-private visited makes hard: the caller can't ask "how many rooms did you reach?" or "did you reach the cellar?" — the walk's knowledge dies with the generator's exhaustion, or with the generator itself if abandoned. The fix is the familiar one: the constructor returns #emph[two] closures (Chapter 25's multiple doors on one state) — the stepper, and a :visited reporter. Or the state graduates to a defclass. When callers start wanting to interrogate the walk rather than only drain it, the generator has outgrown one lambda.

]

== Chapter 31

#soln("31.1")[
  The answers vary by library; the `/shape` of a full-credit answer, using split-sequence as the worked specimen:

  ```text
  ;; Files: 2 source files (package.lisp, split-sequence.lisp).
  ;; Order: the .asd's :components list — package first, then
  ;; split-sequence, which is Chapter 25's rule expressed as
  ;; build order: the package must exist before code that
  ;; uses in-package.
  ;; Promise: "Given a delimiter and a sequence, split into a
  ;; list of subsequences, with :start/:end/:test/:key
  ;; options, plus -if/-if-not predicate variants."
  ```

  The three sentences are the API contract, written from `package.lisp` (the export list) and `README.md` (the example) alone. If three sentences won't cover the export list, the surface is bigger than the documentation — the checklist's caution sign.

  The `:components` order is worth a second look. It isn't "alphabetical" or "by size"; it's "what must exist before what". That's the file structure of a Lisp system, and it's readable at a glance once you know to look for it.

]

#soln("31.2")[
]

#soln("31.3")[
  ```lisp
  (defun system-report (name)
    "An audit alist for an ASDF system."
    (let* ((system (asdf:find-system name))
        (dir (asdf:system-source-directory system)))
      (list (cons :directory dir)
        (cons :files
          (mapcar (lambda (component)
              (if (typep component 'asdf:source-file)
                (pathname-name
                  (asdf:component-pathname component))
                component))
            (asdf:component-children system)))
        (cons :depends-on (asdf:system-depends-on system))
        (cons :license (ignore-errors
            (asdf:system-license system))))))
  ```

  Check on a real system:

  ```lisp
  (system-report :split-sequence)
  ;; => ((:DIRECTORY #P"/home/you/quicklisp/.../split-sequence/")
  ;; (:FILES ("package" "split-sequence"))
  ;; (:DEPENDS-ON NIL)
  ;; (:LICENSE ...))
  ```

  The distinctions the question probes:

  `asdf:find-system` searches, loads the `.asd` file if needed, and `/is` the step that registers. So `system-source-directory` on an unregistered system errors, but `find-system` registers then returns it.

  `:license` is present only if the `defsystem` declared it — an audit point in itself: a system with no `:license` line sends you to the LICENSE file, checklist step 1.

  The `component-children` accessor is ASDF's way of getting the components of a system (newer than the older `components` name); `M-.` on it opens the ASDF source, which is another application of this chapter's reading skill.

]

#soln("31.4")[
  The rating rubric, applied to split-sequence's `split-sequence` as the worked line:

  ```text
  ;; split-sequence: example in README — yes; argument roles
  ;; named in docstring — yes ("delimiter", "seq"); failure
  ;; mode stated — partially (doesn't say what happens with
  ;; an empty seq, or how adjacent delimiters behave: read
  ;; the source, checklist step 7).
  ```

  And the self-comparison `run-command` deserves:

  ```text
  ;; "Execute CMD (a list whose first element names a command
  ;; and whose rest are its arguments). Returns two values:
  ;; the reply string, and a boolean, T when the command was
  ;; known. Unknown commands produce a reply and NIL."
  ```

  — two values stated (Chapter 24's contract), argument shape stated, failure mode stated. If your actual docstring lacks any of the three, that's the exercise's finding.

  The meta-lesson: the docstring a function `/should` have is a question the docstring itself can't answer — you discover it by `/using` the function, finding the places where its behaviour surprises you, and adding sentences to the docstring for each. Every `run-command` caller who's had to check "did the command succeed?" is a sentence the docstring needs.

]

#soln("31.5")[
  The shape of the exercise, worked with a plausible unknown: a library's `(with-collected (items) ...)`.

  ```text
  (macroexpand-1
  '(with-collected (out) (push 1 out) (push 2 out)))
  ;; => (LET ((OUT (MAKE-ARRAY 0 :ADJUSTABLE T :FILL-POINTER 0)))
  ;; (PUSH 1 OUT) (PUSH 2 OUT) OUT)
  ```

  The expansion is the whole story: a `let` binding `out` to an adjustable vector with a fill pointer, the body spliced into the `let`, and the vector returned as the result. The "collected" value is the vector, not a list. That's the interesting choice — the macro's contract, if the docstring doesn't say, is revealed by the expansion.

  Three sentences: "Binds `out` to an adjustable vector. Body forms run with `out` in scope. Returns the vector." Whether the caller wanted a list and got a vector is a design choice to check.

  ```lisp
  (macroexpand-1
    '(with-collected (out) (vector-push-extend 1 out)))
  ;; => (LET ((OUT (MAKE-ARRAY 0 :ADJUSTABLE T :FILL-POINTER 0)))
  ;; (VECTOR-PUSH-EXTEND 1 OUT) OUT)
  ```

  If the library really does override `push`, that's a warning sign: it's nonstandard, and any code reading `push` in that library needs to know the redefinition is in effect.

  The gensym question: no `gensym` needed, because the binding name `out` is provided by the `macro` (the caller names it in the macro call (with-collected (out) ...)). The caller chose the name; the macro binds it in the caller's scope. Capture risk only exists where caller code and macro temporaries share a namespace — here, `out` is exactly the name the caller asked for.

]

#soln("31.6")[
  ```lisp
  (defun undocumented-exports (&optional (package :cave-of-noise))
    "Two values: exported non-function symbols with no docs,
  and exported function names with no function docstring."
    (let ((no-docs nil)
        (fns-missing-docs nil))
      (do-external-symbols (s package)
        (cond ((fboundp s)
            (unless (documentation s 'function)
              (push s fns-missing-docs)))
          ((boundp s)
            (unless (documentation s 'variable)
              (push s fns-missing-docs)))
          (t
            (push s no-docs))))
      (values (nreverse no-docs)
        (nreverse fns-missing-docs))))
  ```

  Check:

  ```lisp
  (undocumented-exports :cave-of-noise)
  ;; => two lists of symbols — rename or document each
  ```

  The audit distinguishes two failures:

  A third, rarer failure the version above doesn't catch: exported, documented, but the docstring is empty `(=="")` rather than nil. `(documentation s 'function)` returns "", which is truthy, so the symbol passes. The `string` check:

  ```lisp
  (let ((s (find-symbol "LOOK" :cave-of-noise)))
    (unless (and (stringp (documentation s 'function))
                 (plusp (length (documentation s 'function))))
      #| ... |#))
  ```

  The chapter closes the loop it opened: the query tools from Chapter 28 (`do-external-symbols`), the documentation accessor from Chapter 22, the package contract from Chapter 16 — the audit of a stranger's system and of your own are the same two queries, run from different chairs. Eight months from now, the stranger will be you.

]

== Chapter 32

#soln("32.1")[
  ```lisp
  ;; The smallest possible executable:
  (defun hello-main ()
    (format t "hello from a saved image~%")
    (sb-ext:exit :code 0))

  (sb-ext:save-lisp-and-die "hello"
                            :executable t
                            :toplevel #'hello-main)
  ```

  From a shell: `./hello` prints the line and exits 0. Its size on a typical SBCL — around 45 MB uncompressed, around 25 MB with `:compression t`. That's the floor: the runtime dominates, and your code is a rounding error.

  Now the payload check:

  ```lisp
  (defparameter *payload* (make-array 1000000 :initial-element 0))

  (defun hello-main ()
    (format t "hello from a saved image (payload: ~D)~%"
            (length *payload*))
    (sb-ext:exit :code 0))

  (sb-ext:save-lisp-and-die "hello-with-payload"
                            :executable t
                            :toplevel #'hello-main)
  ```

  The size barely changes: a million 64-bit integers is 8 MB in memory, but a zero-initialised array compresses to a few hundred KB in the image, and SBCL's `save-lisp-and-die` already compresses constant structures by default. The exact difference varies — check yours with `ls -l` — but the lesson holds: the runtime is the cost. Your data matters only when it's very large or very incompressible.

  The meta-point: an SBCL executable is #emph[not] a thin wrapper around your code. It's your code plus a complete Lisp system plus Quicklisp if you loaded it. That's why Lisp executables are 40 MB when a Go equivalent is 5 MB. The trade is what you get: an interactive image that's still a live REPL if you save it as a core rather than an executable, a program you can inspect, redefine, and debug while it runs.

]

#soln("32.2")[
  ```lisp
  (defun main ()
    "Entry point with argument handling."
    (let ((args (rest sb-ext:*posix-argv*)))
      (cond
        ((member "--help" args :test #'string=)
         (format t "Usage: game [--help] [--version] [--room NAME]~%")
         (sb-ext:exit :code 0))
        ((member "--version" args :test #'string=)
         (format t "The Cave of Noise, version ~A~%" *version*)
         (sb-ext:exit :code 0))
        ((member "--room" args :test #'string=)
         (let* ((room-str (second (member "--room" args
                                          :test #'string=)))
                (room-sym (and room-str
                               (intern (string-upcase room-str)))))
           (if (find-room room-sym)
               (setf *current-room* (find-room room-sym))
               (progn
                 (format *error-output*
                         "No such room: ~A~%" room-str)
                 (sb-ext:exit :code 2)))))
        ((member "--save-file" args :test #'string=)
         (let ((path (second (member "--save-file" args
                                     :test #'string=))))
           (when path (setf *save-file* path)))))
      ;; fall through to the game:
      (run-game)))
  ```

  Where `run-game` is the play\/save\/exit wrapper:

  ```lisp
  (defun run-game ()
    "Play the game, save on exit, return the exit code."
    (handler-case
        (progn
          (multiple-value-bind (state loaded-p)
              (load-game)
            (if loaded-p
                (restore-state state)
                (progn
                  (setf *current-room* (find-room 'kitchen))
                  (setf *item-locations* nil)
                  (setf *history* (make-history)))))
          (play)
          (save-game)
          (sb-ext:exit :code 0))
      (error (c)
        (format *error-output* "cave: ~A~%" c)
        (sb-ext:exit :code 1))))
  ```

  Test all three from a shell:

  ```text
  ./game --help
  # => Usage: game [--help] [--version] [--room NAME]
  # exit code 0

  ./game --version
  # => The Cave of Noise, version 1.0
  # exit code 0

  ./game --room cellar
  # starts in the cellar instead of the kitchen
  # exit code 0 (on quit)
  ```

  Now the question the exercise asks: what does `--room attic` do when `attic` doesn't exist?

  The version above answers: it checks `(find-room room-sym)` and, when that's nil, prints an error to stderr and exits with code 2. That's a deliberate choice — a caller who asked for a specific room and didn't get it should know the command failed, and exit 2 distinguishes "bad argument" from exit 1's "unexpected failure". Many Unix tools use 2 for usage errors; it's a convention worth following.

  Which chapter's tool handles it: Chapter 24's `loaded-p` style flag pattern for the check, and Chapter 19's conditions for anything more elaborate. The `(find-room room-sym)` here is simple enough — one lookup, one branch — that a flag is the right weight. If the game grew a dozen room-related flags and room lookups could fail for several reasons (missing, locked, destroyed), a `bad-room-argument` condition would be cleaner.

]

#soln("32.3")[
  #strong[Wrong:] `:executable t` is missing. Without it, `save-lisp-and-die` writes a core `file` — loadable with sbcl --core `game`, but not a standalone executable. The user has to have SBCL installed and know the flag. Fix:

  ```lisp
  (sb-ext:save-lisp-and-die "game"
                            :executable t
                            :toplevel #'main)
  ```

  #strong[Wrong:] the `main` prints usage and returns, without `sb-ext:exit`. After `main` returns, SBCL falls through into its default REPL. The user sees the usage message, then a bare `*` prompt from a Lisp they didn't know was running, waiting for input that will never come. Fix:

  ```lisp
  (defun main ()
    "Entry point; --help prints usage and exits."
    (let ((args (rest sb-ext:*posix-argv*)))
      (cond ((member "--help" args :test #'string=)
             (format t "Usage: game [--help]~%")
             (sb-ext:exit :code 0))
            (t (run-game)))))
  ```

  #strong[Wrong:] `(quit)` — in modern SBCL, `quit` is deprecated in favour of `sb-ext:exit`, and the exact behaviour across versions varies (older `quit` had no portable way to specify the exit code). More importantly: placed #emph[after] `save-lisp-and-die`, it never runs — `save-lisp-and-die` terminates the process. The `:toplevel` function is the after-save continuation. Remove the `(quit)` line entirely.

  The general pattern: `save-lisp-and-die` is the #emph[last thing a build script runs], and the executable it produces has `:toplevel` as its own `/first` thing. Two different processes, two different "beginnings".

]

#soln("32.4")[
  The build script with tests:

  ```text
  #!/bin/sh
  # build.sh — test, then build
  set -e                          # stop on first error

  SKIP_TESTS=no
  for arg in "$@"; do
    if [ "$arg" = "--skip-tests" ]; then
      SKIP_TESTS=yes
    fi
  done

  if [ "$SKIP_TESTS" = "no" ]; then
    echo "Running tests..."
    sbcl --noinform --non-interactive \
         --eval "(asdf:load-system \"cave-of-noise\")" \
         --eval "(asdf:load-system \"cave-of-noise/tests\")" \
         --eval "(let ((results (cave-of-noise/tests::run-tests))) \
                  (when (some (lambda (pair) (not (cdr pair))) results) \
                    (format t \"FAILED: ~S~%\" results) \
                    (sb-ext:exit :code 1)))"
  fi

  echo "Building executable..."
  sbcl --noinform --non-interactive \
       --eval "(asdf:load-system \"cave-of-noise\")" \
       --eval "(sb-ext:save-lisp-and-die \"game\" \
                :executable t :compression t :toplevel #'cave-of-noise:main)"

  echo "Built: ./game"
  ```

  No `main` changes are needed — the flag handling is in the shell script, not in Lisp. That's the right division of labour: shell arguments (`$@`) and file checks are shell work; loading systems and running tests are Lisp work.

  Test it:

  ```text
  sh build.sh
  # tests run, then build

  sh build.sh --skip-tests
  # build only
  ```

  The `some` in the test check is worth understanding: `run-tests` returns a list of `(name . ok)` pairs; the `(lambda (pair) (not (cdr pair)))` is "is any pair's ok nil". If so, print the failing results and exit 1. If not, the `sb-ext:exit` inside is never reached, and SBCL continues to the build step. That's the shell-level test-gate: the script's `set -e` plus the `sb-ext:exit :code 1` inside the `--eval` makes a failing test stop the build.

  A small refinement: when the test step exits 1, the shell prints nothing about why — that's why the `(format t "FAILED: ~S~%" results)` is there. The user needs to know which test failed; a generic exit code isn't enough.

]

#soln("32.5")[
  ```lisp
  (defun main ()
    "Entry point with --replay handling."
    (let ((args (rest sb-ext:*posix-argv*)))
      (cond
        ((member "--help" args :test #'string=)
         (format t "Usage: game [--help] [--version] \
  [--room NAME] [--replay FILE]~%")
         (sb-ext:exit :code 0))
        ((member "--version" args :test #'string=)
         (format t "The Cave of Noise, version ~A~%" *version*)
         (sb-ext:exit :code 0))
        ((member "--replay" args :test #'string=)
         (let ((path (second (member "--replay" args
                                     :test #'string=))))
           (if path
               (handler-case
                   (progn
                     (replay-streamed path)
                     (sb-ext:exit :code 0))
                 (error (c)
                   (format *error-output* "replay failed: ~A~%" c)
                   (sb-ext:exit :code 1)))
               (progn
                 (format *error-output* "--replay needs a FILE~%")
                 (sb-ext:exit :code 2)))))
        (t (run-game)))))
  ```

  The flag belongs in `main`, not `play`, because it changes #emph[what play does] — whether to enter interactive mode at all. `play` is "the game loop"; a `--replay` run doesn't want a loop, it wants to execute a transcript and exit. Putting the flag in `play` would mean `play` had a non-loop mode, which dilutes its single purpose. `main` is the dispatch layer: given arguments, decide what to do. `play` and `replay-streamed` are both things `main` can call; `main` picks.

  The general principle: #emph[argument parsing belongs at the top of the program, and its consequences belong at the bottom]. The top knows the world the program was invoked in (flags, environment); the bottom knows the program's own logic. The middle should be reachable both ways (interactive, replay) without knowing which way it's being reached.

  The exercise also tests a shell idiom the game will grow into: `--replay FILE` is one of the two non-interactive modes a Lisp program commonly grows (the other is `--batch`-style script execution). Both exist because programs get used in scripts.

]

#soln("32.6")[
  ```lisp
  (defun build-executable (path toplevel &key (compress t))
    "Save the current image as an executable at PATH."
    #+sbcl (sb-ext:save-lisp-and-die
            path
            :executable t
            :compression compress
            :toplevel toplevel)
    #+ccl  (ccl:save-application
            path
            :toplevel-function toplevel
            :prepend-kernel t)
    #-(or sbcl ccl)
    (error "build-executable: no implementation branch for ~A"
           (lisp-implementation-type)))
  ```

  Called from a fresh SBCL:

  ```text
  sbcl --noinform --non-interactive \
       --eval "(asdf:load-system \"cave-of-noise\")" \
       --eval "(cave-of-noise::build-executable \
                \"game\" #'cave-of-noise:main)"
  ```

  The `::` is the one place it's defensible: the function is the build script's tool, not part of the game's public API. Exporting `build-executable` would be export-creep; the `cave-of-noise/tests` package's use of `::` is the same shape — build-time access to internals.

  Now build.sh becomes:

  ```text
  #!/bin/sh
  set -e
  sbcl --noinform --non-interactive \
       --eval "(asdf:load-system \"cave-of-noise\")" \
       --eval "(cave-of-noise::build-executable \
                \"game\" #'cave-of-noise:main)"
  ```

  What the wrapper buys:

  - #emph[Portability.] A single call site for the implementation-specific code. Chapter 32's later section showed the `#+` branches; wrapping them means the build script doesn't grow when you add CCL support, and the branching logic is in one tested function, not scattered through every build invocation.

  - #emph[Parameter control.] `:compress` can be flipped from the command line (`--skip-compress` in build.sh reads it, passes it to `--eval`), without editing the script. Adding options later — `:strip`, `:output-name` — is one keyword each.

  - #emph[Testability.] `build-executable` is a function; you can call it from the REPL, from a test, from a future make `install` target, without shelling out.

  What it costs:

  - #emph[One more layer to read.] The direct `save-lisp-and-die` call in the script is self-explanatory; the wrapper requires knowing what `build-executable` does. For a single-implementation project, the wrapper is over-engineering.

  - #emph[A function that terminates the process.] `build-executable` calls `sb-ext:save-lisp-and-die`, which exits. That's not a function you can usefully compose with — you can't, say, build two executables in one SBCL session. (SBCL supports it, in principle — but the first call exits.) The wrapper hides this; the direct call makes it obvious.

  The trade-off is the standard one: wrap when the branches matter, call directly when they don't. For the game's single-implementation state, direct is honest; the wrapper is the shape it grows into.

]

== Chapters 33 and 34

The exercises in the last two chapters don't take a single answer. They ask you to add checks to your own suite, to break your own code on purpose, to read a library you have never seen, and to write the README a stranger needs. Each one states its own success condition, and in most cases that condition is something that runs. Where an exercise names a shape — the `run-tests` of Chapter 33, the `fiveam` conversion, the `--version` flag — the shape is the answer.

