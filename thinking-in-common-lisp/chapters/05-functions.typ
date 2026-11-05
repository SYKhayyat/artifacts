#import "../lib.typ": *

= Functions

In Chapter 4 you still had to copy the description code each time you wanted it. A #emph[function] gives a piece of code a name, so you can run it again with different inputs.

== Defining a function with `defun`

```lisp
(defun twice (n)
  (* n 2))
```

The result is `TWICE`, the function's name. Now call it like any built-in function:

```lisp
(twice 21)            ; => 42
(twice (twice 5))    ; => 20
(+ (twice 3) 1)       ; => 7
```

The shape of a `defun`:

```text
(defun name (parameter1 parameter2)   ← name, then the parameter list
  expression1                         ← the body
  expression2)                        ← its last value is returned
```

When you call `(twice 21)`:

+ Lisp evaluates the argument, `21`.
+ It binds the parameter `n` to `21`, just like a `let`.
+ It runs the body, `(* n 2)`.
+ The value of the last expression, `42`, is the result.

There is no `return` statement. A function returns the value of the last expression in its body. In Java you write `return n * 2;`. In Lisp, the last expression #emph[is] the return value.

== Parameters are local variables

A parameter works exactly like a variable made by `let`. It exists only inside the function body:

```lisp
(defun area (width height)
  (* width height))

(area 7 3)             ; => 21
```

Outside the function, `width` and `height` are unbound. Each call gets its own fresh bindings, so calls never interfere with each other.

You can use `let` and `let*` inside a body, as you would anywhere else:

```lisp
(defun rectangle-info (width height)
  (let ((area (* width height))
        (perimeter (* 2 (+ width height))))
    (list area perimeter)))

(rectangle-info 8 5)   ; => (40 26)
```

== Functions with no parameters

The parameter list can be empty, but it must be there:

```lisp
(defun dice-faces ()
  6)

(dice-faces)           ; => 6
```

To call it, put the name in parentheses with nothing after it. Writing just `dice-faces` without parentheses asks for a #emph[variable] called `dice-faces`, which doesn't exist.

== A body with several expressions

```lisp
(defun shout (text)
  (princ (string-upcase text))
  (princ "!"))

(shout "hello")
```

The body runs top to bottom. The value of the last expression is returned. Here that's the value of the second `princ`, which is `"!"`; the printed text `HELLO!` comes out first, on its own line.

Ask for the value alone and you see just that:

```lisp
(shout "hello")        ; => "!"
```

The text is still printed — that is what the output is for — and the value is what comes back at the end.

Keep two ideas apart:

- #strong[Printing] shows text to a human.
- #strong[Returning] gives a value back to the code that called the function.

Most functions should return values and not print. A returned value can be used by other code. Printed text can only be read. Print only in the few functions whose job is to talk to the user.

== Documentation strings

If the first thing in the body is a string, and more expressions follow it, that string is the function's #emph[documentation string], or #emph[docstring]:

```lisp
(defun twice (n)
  "Return N multiplied by two."
  (* n 2))
```

Lisp keeps it, and you can ask for it:

```lisp
(documentation 'twice 'function)   ; => "Return N multiplied by two."
```

In Emacs, put the cursor on a function name and press `C-c C-d d` to see its documentation. It works on built-in functions too. Try it on `concatenate`.

By convention, parameter names in a docstring are written in capitals, like `N` above.

== Redefining a function

You just defined `twice` a second time. Lisp replaced the old definition with the new one. SBCL may print a note like:

```text
WARNING: redefining COMMON-LISP-USER::TWICE in DEFUN
```

That's harmless. It's telling you what you already know.

This is how you work in Lisp. You don't restart the program to fix a function. You change the `defun`, run it again with #box[`C-c C-c`], and the running program uses the new version immediately.

== Functions calling functions

Functions you define can call each other, and the built-in ones:

```lisp
(defun square (n)
  (* n n))

(defun sum-of-squares (a b)
  (+ (square a) (square b)))

(sum-of-squares 3 4)   ; => 25
```

You can define them in any order, as long as each one exists by the time it is #emph[called]. If you define `sum-of-squares` first, SBCL may warn "undefined function: SQUARE". That's only a reminder. Once `square` is defined, the call works.

== Optional parameters: `&optional`

Parameters after `&optional` can be left out when calling:

```lisp
(defun greeting (name &optional (punctuation "."))
  (concatenate 'string "Hello, " name punctuation))

(greeting "Ada")       ; => "Hello, Ada."
(greeting "Ada" "!")   ; => "Hello, Ada!"
```

`(punctuation ".")` means "a parameter called `punctuation`, with the default `"."` if the caller leaves it out". The shape is the same as a `let` binding: a name and a value.

If you write a plain name with no default, it becomes `nil` when left out:

```lisp
(defun show-optional (a &optional b)
  (list a b))

(show-optional 1)      ; => (1 NIL)
(show-optional 1 2)    ; => (1 2)
```

Optional arguments are filled in order. To give the second one, you must also give the first.

== Keyword parameters: `&key`

Keyword parameters are given by name, in any order:

```lisp
(defun make-label (text &key (prefix "[") (suffix "]"))
  (concatenate 'string prefix text suffix))

(make-label "ok")                      ; => "[ok]"
(make-label "ok" :prefix "<")          ; => "<ok]"
(make-label "ok" :suffix ">" :prefix "<")  ; => "<ok>"
```

When calling, you write the keyword (Chapter 3), then its value. The keyword `:prefix` matches the parameter `prefix`.

Use `&key` when a function has several settings that callers will rarely change. Many built-in functions work this way. You'll see keyword arguments throughout the rest of this guide.

Use `&optional` for one or two arguments in a natural order. Use `&key` for anything more. Don't use both in the same function: the combination behaves in confusing ways.

== Any number of arguments: `&rest`

`&rest` collects all remaining arguments into a list:

```lisp
(defun collect (&rest things)
  things)

(collect)              ; => NIL
(collect 1 2 3)        ; => (1 2 3)
```

You can put normal parameters before it:

```lisp
(defun tag (label &rest items)
  (list label (length items) items))

(tag 'fruit 'apple 'pear)   ; => (FRUIT 2 (APPLE PEAR))
```

This is how `+` and `list` accept any number of arguments.

== The parameter list, in full

```text
(defun name (required1 required2
             &optional (opt1 default1)
             &rest more
             &key (key1 default1))
  body)
```

You will rarely need more than one of `&optional`, `&rest` and `&key` at a time. The required parameters always come first.

== Naming functions

- Use lower case with hyphens: `sum-of-squares`, not `sumOfSquares`. Lisp would turn `sumOfSquares` into `SUMOFSQUARES` anyway.
- A function that answers yes or no ends in `p`: `emptyp`, `room-dark-p`. Use `-p` when the name already has a hyphen, and plain `p` when it's a single word.
- Don't reuse the names of built-in functions such as `list`, `first` or `room`. SBCL stops you with "Lock on package COMMON-LISP violated". Pick another name. (If it happens, choose the restart that says to ignore the lock only if you know what it means; otherwise press `q`.)

== Common mistakes

- #strong[Wrong number of arguments:] `(area 7)` when `area` needs two. The debugger says "invalid number of arguments: 1". Check the parameter list. Press `C-c C-d d` on the name if you forget it.
- #strong[Forgetting the empty parameter list:] `(defun dice-faces 6)`. Lisp reads `6` as the parameter list and complains. Write `(defun dice-faces () 6)`.
- #strong[Calling without parentheses:] writing `dice-faces` instead of `(dice-faces)`. The error is "The variable DICE-FACES is unbound".
- #strong[Quoting the parameter:] `(defun twice (n) (* 'n 2))` gives "N is not a NUMBER". Inside the body, use `n` without a quote.
- #strong[A typo in the body:] `(defun area (width height) (* widht height))`. SBCL warns "undefined variable: WIDHT" when you define it. Read those warnings: they catch the bug before you call the function.
- #strong[Printing instead of returning:] a function that ends with `princ` returns the printed value, which is usually not what the caller needs. Let the function return the value, and print it at the place that talks to the user.
- #strong[A docstring that is the whole body:] `(defun name () "Ada")` returns `"Ada"`. A string counts as a docstring only when more expressions follow it.
- #strong[Forgetting the keyword when calling:] `(make-label "ok" "<")` gives an error about an "odd number of &KEY arguments". Write `(make-label "ok" :prefix "<")`.

== Project step: room functions

Run the Chapter 4 project code first, so the room variables exist.

Each room is a list of name, description and exits. Instead of remembering which position holds what, give each part a function:

```lisp
(defun room-name (place)
  "Return the name symbol of PLACE."
  (first place))

(defun room-description (place)
  "Return the description string of PLACE."
  (second place))

(defun room-exits (place)
  "Return the list of room names PLACE connects to."
  (third place))
```

The parameter is called `place` because `room` is the name of a built-in function.

```lisp
(room-exits *hallway*)     ; => (BEDROOM KITCHEN)
```

These small functions are called #emph[accessors]. If you later change how a room is stored, you only change these three functions. The rest of the game keeps working.

Now the description, written once:

```lisp
(defun describe-room (place)
  "Return the text shown when the player is in PLACE."
  (concatenate 'string
               "You are in the "
               (string-capitalize (symbol-name (room-name place)))
               ". "
               (room-description place)))
```

```lisp
(describe-room *kitchen*)
;; => "You are in the Kitchen. A warm kitchen that smells of bread."
```

The player mostly wants to know about the room they're standing in. A function with no parameters handles that:

```lisp
(defun look ()
  "Describe the room the player is in."
  (describe-room *current-room*))
```

```lisp
(setf *current-room* *bedroom*)
(look)
;; => "You are in the Bedroom. A small bedroom with an unmade bed."
```

`look` reads the global `*current-room*` each time it runs. Change the variable and `look` follows:

```lisp
(setf *current-room* *garden*)
(look)
;; => "You are in the Garden. An overgrown garden."
```

The player still moves by you typing `setf`, and nothing stops them from walking from the bedroom straight into the garden. Chapter 6 adds the decisions a real `go` command needs.

== Exercises

#exercise("5.1")[
  Write a function `square` that returns its argument multiplied by itself.

]

#exercise("5.2")[
  Write a function `average3` that takes three numbers and returns their average. Give it a docstring.

]

#exercise("5.3")[
  Write a function `greet` that takes a name and returns `"Hello, NAME!"` with the name in capitals. `(greet "ada")` should give `"Hello, ADA!"`.

]

#exercise("5.4")[
  Write a function `power-of` that takes a base and an optional exponent, which defaults to 2. `(power-of 5)` gives `25`, `(power-of 2 10)` gives `1024`.

]

#exercise("5.5")[
  Write a function `make-greeting` that takes a name and two keyword parameters: `greeting` (default `"Hello"`) and `punctuation` (default `"!"`). `(make-greeting "Ada" :greeting "Welcome")` should give `"Welcome, Ada!"`.

]

#exercise("5.6")[
  Write a function `count-args` that accepts any number of arguments and returns how many it got.

]

#exercise("5.7")[
  Each line has a mistake. Say what's wrong and fix it.

  ```text
  (defun add (a b) (+ a b c))
  (defun (twice n) (* 2 n))
  (add 1)
  ```

]

#exercise("5.8", project: true)[
  Write two functions using the room accessors:

  + `exit-count`, which takes a room and returns how many exits it has.
  + `room-title`, which takes a room and returns its name as a capitalised string, such as `"Kitchen"`.

]

