#import "../lib.typ": *

= Functions as Values

Until now, a function was something you called. In Lisp a function is also a value, like a number or a list. You can store it in a variable, put it in a list, pass it to another function, and return it from a function. This chapter shows how, and why it's one of the most useful ideas in the language.

== Getting hold of a function: `#'`

```lisp
(defun twice (n)
  "Return N multiplied by two."
  (* n 2))

#'twice
```

The result looks like this:

```text
#<FUNCTION TWICE>
```

`#'twice` means "the function named `twice`", the function itself, not a call to it. The `#<...>` notation is how Lisp prints objects that can't be typed back in as text.

`#'` is short for the special operator `function`, the same way `'` is short for `quote`:

```lisp
(function twice)         ; => #<FUNCTION TWICE>
(functionp #'twice)      ; => T
(functionp 'twice)       ; => NIL
```

The last line matters. `'twice` is a symbol, the #emph[name] of the function. `#'twice` is the function. Two different things, which the end of this chapter puts to use.

== Two kinds of names

Why not just write `twice`, the way Python does? Because in Common Lisp, a symbol can name a function and a variable #emph[at the same time], and the two never collide:

```lisp
(defparameter twice 100)

(list twice (twice 5))  ; => (100 10)
```

The first `twice` is in a normal argument position, so Lisp looks up the #emph[variable]. The second is first in a list, so Lisp looks up the #emph[function]. Each name has two separate slots: one for its value as a variable, one for its function.

That's why you need `#'`: it says "the function slot, please" in a place where Lisp would otherwise read the variable slot.

The same rule lets you use `list` as a variable name without losing the `list` function:

```lisp
(let ((list '(1 2 3)))
  (list list (length list)))   ; => ((1 2 3) 3)
```

You'll see parameters called `list` in other people's code. It works, but it's confusing to read, so this guide uses `lst`.

Clean up the variable before going on, so it doesn't surprise you later. `makunbound` removes a variable's value:

```lisp
(makunbound 'twice)
```

== Calling a function you're given: `funcall`

A function stored in a variable can't be called by putting the variable first in a list. That would look in the function slot, which is empty. `funcall` calls whatever function you hand it:

```lisp
(defparameter *operation* #'twice)

(funcall *operation* 21)    ; => 42
(funcall #'+ 1 2 3)         ; => 6
```

`funcall` takes the function first, then the arguments, exactly as you would write them in a normal call.

`funcall` also accepts a symbol. It looks up the function the symbol names at the moment of the call:

```lisp
(funcall 'twice 4)         ; => 8
```

== Arguments from a list: `apply`

Sometimes the arguments are already in a list. `apply` spreads the list out into separate arguments:

```lisp
(apply #'+ '(1 2 3 4))      ; => 10
(apply #'max '(3 9 2))      ; => 9
```

`(apply #'+ '(1 2 3 4))` is the same as `(+ 1 2 3 4)`.

You can give some arguments directly before the list. The last argument must always be a list:

```lisp
(apply #'+ 1 2 '(3 4))      ; => 10
(apply #'list 'a '(b c))    ; => (A B C)
```

How to choose:

#table(
  columns: (1.5fr, 6.5fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Use], [When]),
  [A normal call], [You know the function when you write the code],
  [`funcall`], [The function is in a variable, the arguments are separate],
  [`apply`], [The function is in a variable, the arguments are in a list],
)

== Writing functions that take functions

Here is a function whose first parameter is itself a function:

```lisp
(defun apply-twice (f x)
  "Call F on X, then call F on the result."
  (funcall f (funcall f x)))
```

```lisp
(apply-twice #'twice 5)    ; => 20
(apply-twice #'reverse '(1 2 3))   ; => (1 2 3)
(apply-twice #'rest '(a b c d))    ; => (C D)
```

Inside `apply-twice`, `f` is an ordinary variable holding a function, so the body calls it with `funcall`. The caller decides #emph[what] happens. `apply-twice` decides #emph[how often].

A function that takes or returns functions is called a #emph[higher-order function]. Java has these too, through interfaces like `Function` and method references like `Math::abs`. In Lisp they need no special machinery.

== `mapcar`: do it to every element

The most common higher-order function walks a list, calls a function on each element, and collects the results:

```lisp
(mapcar #'twice '(1 2 3))         ; => (2 4 6)
(mapcar #'string-upcase '("a" "b")) ; => ("A" "B")
(mapcar #'first '((a 1) (b 2) (c 3))) ; => (A B C)
```

Compare the first line with `double-all` from Chapter 8. That recursive function, with its base case and its `cons`, did exactly what `mapcar` does with `#'twice`. `mapcar` is that pattern, written once, for any function.

With several lists, `mapcar` takes one element from each and passes them together:

```lisp
(mapcar #'+ '(1 2 3) '(10 20 30))  ; => (11 22 33)
(mapcar #'list '(a b) '(1 2))      ; => ((A 1) (B 2))
```

The function must accept as many arguments as there are lists. If the lists have different lengths, `mapcar` stops at the end of the shortest:

```lisp
(mapcar #'+ '(1 2 3) '(10 20))     ; => (11 22)
```

Chapter 10 covers the rest of this family: functions that keep or remove elements, find one, or combine them all into one value.

== `lambda`: functions without names

Often the function you want to pass is tiny and used only once. Giving it a name with `defun` would be clutter. `lambda` makes a function on the spot:

```lisp
(mapcar (lambda (n) (* n n)) '(1 2 3 4))   ; => (1 4 9 16)
```

`(lambda (n) (* n n))` is a function with one parameter `n` that returns `n` squared. It has the same shape as a `defun`, without the name:

```text
(defun square (n) (* n n))   ← a named function
(lambda (n) (* n n))         ← the same function, unnamed
```

A `lambda` evaluates to a function object, so you don't need `#'` in front of it. You'll see `#'(lambda ...)` in older code. It means the same thing.

```lisp
(funcall (lambda (a b) (+ a b)) 3 4)       ; => 7
((lambda (a b) (+ a b)) 3 4)               ; => 7
```

The second line puts the `lambda` itself first in the list. That's allowed, and it's the one case where something other than a name can come first. You'll rarely write it, but you'll recognise it.

Run a `lambda` on its own and you see something like:

```text
#<FUNCTION (LAMBDA (A B)) {5383DB5B}>
```

The number in braces is a memory address. Yours will differ.

Everything from Chapter 5 works in a `lambda`: several body expressions, `&optional`, `&key`, `&rest`.

```lisp
(mapcar (lambda (name &optional (greeting "Hi"))
          (concatenate 'string greeting ", " name))
        '("Ada" "Alan"))
;; => ("Hi, Ada" "Hi, Alan")
```

== A `lambda` can use the variables around it

A `lambda` written inside a `let` or a function body can use the variables visible there:

```lisp
(defun add-to-all (amount numbers)
  "Return NUMBERS with AMOUNT added to each one."
  (mapcar (lambda (n) (+ n amount)) numbers))

(add-to-all 10 '(1 2 3))    ; => (11 12 13)
```

The `lambda` has one parameter, `n`. It also uses `amount`, which isn't its own parameter. It belongs to `add-to-all`. The `lambda` can see it because it was written inside `add-to-all`, where `amount` is in scope.

A function that remembers variables from the place where it was written is called a #emph[closure]. In Lisp every `lambda` is one, so you never have to ask for it.

== Functions that return functions

A function can build a `lambda` and hand it back:

```lisp
(defun make-adder (amount)
  "Return a function that adds AMOUNT to its argument."
  (lambda (n) (+ n amount)))

(defparameter *add-five* (make-adder 5))

(funcall *add-five* 10)             ; => 15
(mapcar (make-adder 100) '(1 2 3))  ; => (101 102 103)
```

`make-adder` has already returned when `*add-five*` is called, yet the function still knows that `amount` is `5`. The closure keeps the variable alive for as long as the function exists. Each call to `make-adder` creates a fresh `amount`, so `(make-adder 5)` and `(make-adder 100)` don't interfere.

== A closure can change its variables

The variable a closure remembers is a real variable, not a frozen copy of its value. The closure can change it with `setf` or `incf`:

```lisp
(defun make-counter ()
  "Return a function that counts up by one each time it is called."
  (let ((count 0))
    (lambda () (incf count))))

(defparameter *counter-a* (make-counter))
(defparameter *counter-b* (make-counter))

(list (funcall *counter-a*)
      (funcall *counter-a*)
      (funcall *counter-a*)
      (funcall *counter-b*))
;; => (1 2 3 1)
```

Each counter has its own `count`, created by its own call to `make-counter`. Nothing outside the closure can read or change that variable. It is private state, the job a private field does in a Java object, with no class around it.

== Symbol or function?

Near the start of this chapter, `'twice` and `#'twice` turned out to be different things. Both work with `funcall`, but they behave differently when you redefine the function.

```lisp
(defparameter *saved* #'twice)   ; the function object itself

(defun twice (n)                 ; a new, wrong definition
  (* n 3))

(list (funcall *saved* 5)         ; the old function, kept in the variable
      (funcall 'twice 5))        ; whatever TWICE means right now
;; => (10 15)
```

SBCL may print a warning that `twice` is being redefined. That's expected.

`#'twice` grabs the function as it is at that moment. Redefining `twice` later creates a new function, and `*saved*` still holds the old one. `'twice` is only a name, so `funcall` looks it up at each call and always finds the current definition.

Put the right definition back:

```lisp
(defun twice (n)
  "Return N multiplied by two."
  (* n 2))
```

In everyday code, write `#'`. It's clearer and slightly faster. When you store functions in a table that should follow your edits while you work at the REPL, store their names. The project step below does exactly that.

== `mapc`: when you only want the effect

`mapcar` collects results into a new list. If you call a function only for what it does, such as printing, the collected list is waste. `mapc` calls the function on each element the same way, and returns the original list instead of building a new one:

```lisp
(mapc #'print '(1 2 3))
```

```text
1
2
3
```

== Common mistakes

=== Forgetting `#'`

```text
(mapcar twice '(1 2 3))
;; error: The variable TWICE is unbound.
```

Without `#'`, `twice` in an argument position is read as a variable. Write `#'twice`.

=== Calling a parameter directly

```text
(defun call-it (f)
  (f 10))
;; warning: undefined function: F
```

`(f 10)` looks for a #emph[function] named `f`, and `f` is a variable. A function held in a variable is called with `(funcall f 10)`.

=== Quoting a `lambda`

```text
(mapcar '(lambda (x) (* x x)) '(1 2))
;; error: The value (LAMBDA (X) (* X X)) is not of type (OR FUNCTION SYMBOL)
```

With a quote, the `lambda` is just a list of three elements, not a function. Write the `lambda` without a quote, or with `#'`.

=== `apply` without a list at the end

```text
(apply #'+ 1 2)
;; error: The value 2 is not of type LIST
```

The last argument of `apply` must be a list. Use `funcall` when the arguments are separate.

=== Expecting `mapcar` to change the list

`mapcar` returns a new list and leaves the original alone. If you want a variable to hold the result, store it: `(setf *numbers* (mapcar #'twice *numbers*))`.

=== The wrong number of arguments

```text
(mapcar #'cons '(a b c))
;; error: invalid number of arguments: 1
```

`mapcar` with one list calls the function with one argument. `cons` needs two, so it needs two lists.

== Project step: a command table

So far you play the game by calling functions: `(take 'key)`, `(inventory)`. A real game reads commands such as `(take key)` and decides which function to run. Functions as values make that a short piece of code.

Start with a table, an alist that maps each command word to the name of the function that handles it:

```lisp
(defparameter *commands*
  '((look . look)
    (inventory . inventory)
    (take . take)
    (go . go-to)
    (loot . loot))
  "Map each command word to the function that handles it.")
```

If you wrote `drop` in Exercise 7.8, add `(drop . drop)` to the list.

The values are symbols, not `#'look` and so on. `run-command` looks up the current definition every time, so when you fix a bug in `take` (as Chapter 8 did), the table uses the fixed version without being rebuilt.

```lisp
(defun run-command (command)
  "Run COMMAND, a list such as (TAKE KEY), and return the reply."
  (let ((entry (assoc (first command) *commands*)))
    (if (null entry)
        "I don't know how to do that."
        (apply (cdr entry) (rest command)))))
```

`(first command)` is the verb, `(rest command)` is the list of its arguments, and `apply` spreads that list into the call. `(take key)` becomes `(take 'key)`, and `(look)` becomes `(look)` with no arguments. Like `funcall`, `apply` accepts a symbol and calls the function it names.

The words in the command don't need quotes inside, because the whole command is quoted once:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))

(list (run-command '(take key))
      (run-command '(inventory))
      (run-command '(dance)))
;; => ("You take the key." "You are carrying: key." "I don't know how to do that.")
```

A whole session is a list of commands, and `mapcar` runs each one:

```lisp
(defun play (commands)
  "Run each command in COMMANDS and return the list of replies."
  (mapcar #'run-command commands))
```

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))

(play '((take key) (take key) (inventory)))
;; => ("You take the key." "You already have that." "You are carrying: key.")
```

`mapcar` calls `run-command` on the commands in order, from first to last, so the second `take` sees the effect of the first.

A command with the wrong number of words, such as `(look kitchen)`, calls `look` with an argument it doesn't accept, and you land in the debugger. Press `q` to leave it (Appendix C). Later chapters show how to catch that kind of error.

Adding a command now means writing a function and adding one pair to `*commands*`. `run-command` never changes.

== Exercises

#exercise("9.1")[
  Predict the result of each line, then check:

  ```text
  (funcall #'list 1 2)
  (apply #'* 2 '(3 4))
  (mapcar #'length '((a) (b c) ()))
  (mapcar (lambda (x) (cons x x)) '(a b))
  (apply-twice (lambda (s) (concatenate 'string s "!")) "hi")
  ```

]

#exercise("9.2")[
  Write `my-mapcar`, which takes a function and one list and does what `mapcar` does, using recursion and `funcall`.

]

#exercise("9.3")[
  Use `mapcar` and a `lambda` to turn `'("ada" "alan" "grace")` into `'("Hello, Ada" "Hello, Alan" "Hello, Grace")`.

]

#exercise("9.4")[
  Write `make-multiplier`, which takes a number and returns a function that multiplies its argument by that number.

]

#exercise("9.5")[
  Write `compose`, which takes two functions `f` and `g` and returns a function of one argument that calls `g` first, then `f` on the result. `(funcall (compose #'twice #'1+) 5)` should give `12`.

]

#exercise("9.6")[
  Each line below is wrong. Say what's wrong, then fix it.

  ```text
  (mapcar twice '(1 2))

  (defun call-with-ten (f)
    (f 10))

  (funcall '(lambda (x) (+ x 1)) 5)

  (apply #'max 3 7)
  ```

]

#exercise("9.7")[
  Write `make-stepper`, which takes a start and a step and returns a function. Its first call returns the start, and each later call returns the previous value plus the step:

  ```text
  (let ((s (make-stepper 10 5)))
    (list (funcall s) (funcall s) (funcall s)))
  ;; => (10 15 20)
  ```

]

#exercise("9.8")[
  Use `mapcar` to build the alist `((A . 1) (B . 2) (C . 3))` from the lists `(a b c)` and `(1 2 3)`, in one short expression.

]

#exercise("9.9")[
  `*table-a*` and `*table-b*` below both point at `shout`. Predict what each call returns after `shout` is redefined, then check:

  ```lisp
  (defun shout (s) (string-upcase s))

  (defparameter *table-a* (list (cons 'shout #'shout)))
  (defparameter *table-b* (list (cons 'shout 'shout)))

  (defun shout (s) (concatenate 'string (string-upcase s) "!"))

  (list (funcall (cdr (assoc 'shout *table-a*)) "hey")
        (funcall (cdr (assoc 'shout *table-b*)) "hey"))
  ```

]

#exercise("9.10", project: true)[
  Add short forms to the command table: `l` for `look` and `i` for `inventory`. Don't write any new functions.

]

#exercise("9.11", project: true)[
  Write a `help` command that lists every command word in the table, and add it to `*commands*`. Reuse `item-names` from Exercise 8.11, which already turns a list of symbols into a readable string. The reply should look like:

  ```text
  "Commands: help, look, inventory, take, go and loot."
  ```

]

