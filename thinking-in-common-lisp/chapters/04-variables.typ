#import "../lib.typ": *

= Variables

So far, every value had to be typed out in full, sometimes twice. A #emph[variable] gives a value a name, so you can use the name instead.

Lisp has two kinds of variables:

- #strong[Global variables] exist everywhere, for as long as Lisp runs.
- #strong[Local variables] exist only inside one piece of code.

== Global variables with `defparameter`

```lisp
(defparameter *price* 25)
```

The result is `*PRICE*`, the name of the variable you just made. `defparameter` returns the name, not the value.

Now use it:

```lisp
*price*                 ; => 25
(* *price* 4)           ; => 100
```

This is the evaluation rule for symbols from Chapter 2: when Lisp evaluates a symbol, it looks up the value the name stands for. Before this chapter, the only symbols you evaluated were `t` and `nil`, which stand for themselves. Now you can make your own.

Compare with the quoted symbol:

```lisp
'*price*                ; => *PRICE*
```

Quoted, it's just the name. Unquoted, it's the value.

=== The stars

The stars around `*price*` are part of the name. They're called #emph[earmuffs]. Every Lisp programmer writes global variables this way, so that a reader can tell at a glance which names are global. Lisp doesn't force you, but always do it. A later chapter shows a real reason behind the habit, and you'll already have it.

=== Variables live in the running Lisp

The variable now exists in your Lisp session. Every later block can use it. If you restart Lisp (or Emacs), it's gone. Run the `defparameter` block again to bring it back.

== Changing a variable with `setf`

```lisp
(setf *price* 30)       ; => 30
*price*                 ; => 30
```

`setf` ("set field") stores a new value in an existing variable and returns that value. It's Lisp's version of Java's `=`.

`setf` can set several variables at once, in pairs:

```lisp
(defparameter *width* 0)
(defparameter *height* 0)
(setf *width* 7
      *height* 3)
(* *width* *height*)    ; => 21
```

=== Adding and subtracting: `incf` and `decf`

Changing a number by a little is common enough to have its own operators:

```lisp
(defparameter *score* 0)
(incf *score*)          ; => 1
(incf *score*)          ; => 2
(incf *score* 10)       ; => 12
(decf *score* 5)        ; => 7
```

`incf` adds (1 by default), `decf` subtracts. Both change the variable and return its new value. They're like Java's `score++` and `score +` `10`.

Run that block twice and the result is different: the `defparameter` resets `*score*` to `0`, then the rest counts up again to `7`. Keep this in mind for the next section.

== `defvar`: define once, keep the value

`defvar` also makes a global variable, with one difference. If the variable already exists, `defvar` leaves it alone.

Run each block once, in order:

```lisp
(defvar *lives* 3)
*lives*                 ; => 3
```

```lisp
(setf *lives* 1)
```

```lisp
(defvar *lives* 3)
*lives*                 ; => 1
```

The second `defvar` did nothing, because `*lives*` already had a value. With `defparameter`, it would have gone back to `3`.

When to use which:

#table(
  columns: (1.0fr, 7.0fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Use], [When]),
  [`defparameter`], [Settings and data you want reset each time you re-run the code],
  [`defvar`], [State you build up while the program runs, and don't want lost if you re-run the file],
)

When you're not sure, use `defparameter`. Its behaviour is easier to predict.

== Constants with `defconstant`

```lisp
(defconstant +days-per-week+ 7)
(* +days-per-week+ 52)  ; => 364
```

A constant can never be changed. `(setf +days-per-week+ 8)` is an error. The plus signs around the name are the convention for constants, like the stars for global variables.

Use constants only for values that truly never change. For anything else, `defparameter` is more convenient.

== Local variables with `let`

Global variables are handy, but most names in a program are only needed for a moment. `let` makes variables that exist only inside it:

```lisp
(let ((width 7)
      (height 3))
  (* width height))     ; => 21
```

The shape of a `let`:

```text
(let ((name1 value1)        ← a list of bindings
      (name2 value2))         each binding is (name value)
  expression1               ← the body: one or more expressions
  expression2)              ← the value of the last one is the result
```

Watch the parentheses. There's one pair around the whole list of bindings, and one pair around each binding. That's why a `let` starts with ((.

Linking a name to a value is called #emph[binding] the name. The names `width` and `height` are #emph[bound] only inside the body. Outside, they don't exist:

```lisp
width
```

The debugger opens with "The variable WIDTH is unbound." "Unbound" means "this name has no value here". Press `q`.

Local variables don't get earmuffs. The stars are only for globals.

=== The body can have several expressions

```lisp
(let ((name "Ada")
      (age 36))
  (print name)
  (print age))
```

The body runs top to bottom. Without `:results output`, the block would show only `36`, the value of the last expression.

=== Values can be computed

The value in a binding is evaluated first, like any argument:

```lisp
(let ((total (* 25 4))
      (items (list 'pen 'ink)))
  (list total (length items)))   ; => (100 2)
```

=== Changing a local variable

`setf` and `incf` work on local variables too:

```lisp
(let ((count 0))
  (incf count)
  (incf count)
  count)                ; => 2
```

=== Using globals inside `let`

The body can use global variables as well as its own:

```lisp
(defparameter *tax-rate* 1/5)

(let ((price 50))
  (+ price (* price *tax-rate*)))   ; => 60
```

== `let*`: bindings that use earlier bindings

In a `let`, every value is worked out #emph[before] any name is bound. So a binding can't use a name from the same `let`:

```lisp
(let ((a 2)
      (b (* a 10)))
  b)
```

Error: "The variable A is unbound." When Lisp computed `(* a 10)`, `a` didn't exist yet. Press `q`.

`let*` binds the names one at a time, top to bottom. Each value can use the names above it:

```lisp
(let* ((a 2)
       (b (* a 10)))
  b)                    ; => 20
```

A good habit: use `let` by default and switch to `let*` when one binding needs another. Readers then know that a `let*` has bindings that depend on each other.

== Nesting and shadowing

A `let` can go inside another one:

```lisp
(let ((x 1))
  (let ((y 2))
    (+ x y)))           ; => 3
```

The inner body sees both `x` and `y`.

If the inner `let` uses the same name, the inner one wins while you're inside it. This is called #emph[shadowing]:

```lisp
(let ((x 1))
  (list x
        (let ((x 100))
          x)
        x))             ; => (1 100 1)
```

Read it slowly. The first `x` is `1`. Inside the inner `let`, `x` is `100`. After the inner `let` ends, `x` is `1` again. The inner binding never changed the outer one. It only hid it for a while.

== How to choose

- Need a value in one calculation? Use `let`.
- Need it to stay around between blocks, or for the whole program? Use `defparameter` or `defvar`.
- Never changes? Use `defconstant`.

Most Lisp code uses many local variables and only a few globals.

== Common mistakes

- #strong[`setf` on a name that was never defined:] `(setf *gold* 10)` with no `defparameter` first. SBCL warns "undefined variable: #strong[GOLD]". It may seem to work, but the behaviour isn't reliable. Always create globals with `defparameter` or `defvar` first.
- #strong[Missing parentheses in `let`:] `(let (x 5) x)` is wrong. Lisp reads `(x 5)` as the list of bindings, and complains that the binding `5` is malformed. Write `(let ((x 5)) x)`.
- #strong[Using a name from the same `let`:] `(let ((a 1) (b (+ a 1))) b)` gives "The variable A is unbound". Use `let*`.
- #strong[Using a local name outside its `let`:] the name is unbound there. Move the code inside the body.
- #strong[Expecting `defvar` to reset a value:] re-running `(defvar *x* 0)` keeps the old value. Use `setf` to change it, or use `defparameter`.
- #strong[Quoting a variable:] `(* '*price* 2)` gives "#strong[PRICE] is not a NUMBER". The quote gives you the name, not the value. Leave the quote off.
- #strong[Running blocks out of order:] after restarting Lisp, a block that uses `*price*` fails with "unbound". Run the `defparameter` block first.
- #strong[Forgetting the earmuffs when using a global:] if you defined `*price*`, then `price` is a different name and is unbound.

== Project step: naming the rooms

Give each room a name, so you never type it twice again:

```lisp
(defparameter *bedroom*
  '(bedroom "A small bedroom with an unmade bed." (hallway)))

(defparameter *hallway*
  '(hallway "A narrow hallway with creaky floorboards." (bedroom kitchen)))

(defparameter *kitchen*
  '(kitchen "A warm kitchen that smells of bread." (hallway garden)))

(defparameter *garden*
  '(garden "An overgrown garden." (kitchen)))
```

Now keep track of where the player is. A global variable holds the current room. The player starts in the bedroom:

```lisp
(defparameter *current-room* *bedroom*)
```

`*current-room*` now holds the same list as `*bedroom*`.

Build the description with `let`, so each part has a clear name:

```lisp
(let ((name (first *current-room*))
      (description (second *current-room*)))
  (concatenate 'string
               "You are in the "
               (string-capitalize (symbol-name name))
               ". "
               description))
;; => "You are in the Bedroom. A small bedroom with an unmade bed."
```

Compare this with the Chapter 3 version. The room list appears nowhere in the code. The `let` names its parts, and the last expression puts them together.

Move the player to the hallway, then run the description block again:

```lisp
(setf *current-room* *hallway*)
```

The same description code now says "You are in the Hallway." The code didn't change. Only the data did.

You still have to copy the description block each time you want to use it. Chapter 5 turns it into a function you can call by name.

== Exercises

#exercise("4.1")[
  Make two global variables: `*apples*` with the value 12 and `*pears*` with the value 8. Write an expression for the total number of fruit. Then change `*pears*` to 20 with `setf` and run the total again.

]

#exercise("4.2")[
  Predict the final value of `*mode*`, then check by running the lines in order:

  ```text
  (defvar *mode* 'easy)
  (setf *mode* 'hard)
  (defvar *mode* 'easy)
  (defparameter *mode* 'normal)
  (defvar *mode* 'easy)
  ```

]

#exercise("4.3")[
  Using `let`, bind `width` to 8 and `height` to 5. Return a list of the area and the perimeter.

]

#exercise("4.4")[
  Using `let*`, bind `celsius` to 30, then `fahrenheit` computed from it with the formula F = C × 9\/5 + 32. Return a list of both values.

]

#exercise("4.5")[
  Make a global `*steps*` starting at 0. Write one block that adds 1 three times and then adds 10, and shows the final value.

]

#exercise("4.6")[
  Each line has a mistake. Say what's wrong and fix it.

  ```text
  (let (total 10) total)
  (let ((a 3) (b (* a a))) b)
  (* '*apples* 2)
  ```

]

#exercise("4.7")[
  Predict the result:

  ```text
  (let ((x 5))
    (let ((x (* x 2)))
      (setf x (+ x 1))
      x))
  ```

  Then predict what changes if you replace the last line with `(list x)` placed #emph[after] the inner `let` instead of inside it.

]

#exercise("4.8", project: true)[
  Set `*current-room*` to `*kitchen*`. Using `let`, write an expression that returns a list of two things: the room's name and the number of exits it has.

]

