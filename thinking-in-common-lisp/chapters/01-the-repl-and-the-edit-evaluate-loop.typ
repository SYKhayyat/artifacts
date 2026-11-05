#import "../lib.typ": *

= The REPL and the Edit-Evaluate Loop

== What Lisp does with your code

Lisp works in a loop of four steps:

+ #strong[Read] the text you typed and turn it into data.
+ #strong[Evaluate] that data, which means work out its value.
+ #strong[Print] the value.
+ #strong[Loop] back and wait for more.

That is the REPL. Every time you press `C-c C-c` on a block, the same thing happens: the block is read, evaluated, and the value is shown.

In Java you write a whole program, compile it, and run `main`. In Lisp you talk to a running program, one expression at a time, and it answers. The program grows while it runs. This is the single biggest change in how you will work.

== Your first expressions

Run each block.

```lisp
42
```

A number evaluates to itself. You get `42`.

```lisp
(+ 2 3)   ; => 5
```

This is a #emph[call]. The parentheses mean "do something". The first thing inside is the operator (`+`). The rest are the arguments (`2` and `3`). This style, operator first, is called #emph[prefix notation].

```lisp
(+ 1 2 3 4 5)   ; => 15
```

`+` accepts any number of arguments. So do `-`, `*` and many others.

```lisp
(* 2 (+ 3 4))   ; => 14
```

Expressions nest. Lisp works out the inner one first, `(+ 3 4)` is `7`, then the outer one, `(* 2 7)` is `14`.

There is no operator precedence to remember. In Python, `2 + 3 * 4` depends on rules about `*` binding tighter than `+`. In Lisp you write exactly what you mean:

```lisp
(+ 2 (* 3 4))   ; => 14
(* (+ 2 3) 4)   ; => 20
```

When a block contains several expressions, they all run, top to bottom, and the block shows the value of the #strong[last] one. The block above shows `20`.

== Using the REPL directly

Switch to the REPL window (`C-x o`, or `C-x b` and type `repl`). At the `CL-USER>` prompt, type:

```text
CL-USER> (* 6 7)
42
```

Press `RET` after the closing parenthesis. If you press `RET` before the parentheses are balanced, the REPL waits for the rest. That isn't an error. Finish typing and press `RET` again.

Use `M-p` to bring back what you typed before. Use the REPL for quick experiments. Use code blocks for anything you want to keep.

== Printing

`print` writes a value to the output:

```lisp
(print 42)
(print (+ 1 1))
```

Text in double quotes is a #emph[string]. Chapter 3 covers strings fully. For now, you can print one:

```lisp
(print "Hello, Lisp")
```

`print` starts a new line before the value. A string prints with its quotes, because `print` shows values the way Lisp would read them back.

`princ` prints for humans, without quotes and without the new line:

```lisp
(princ "Hello, ")
(princ "Lisp")
```

`print` and `princ` also #emph[return] the value they printed. So in a REPL you see the value twice: once printed, once as the result. That's normal.

Remember the difference between the two kinds of block results:

- Without `:results output`: you see the #strong[value] of the last expression.
- With `:results output`: you see what was #strong[printed].

== Comments

```lisp
;;; Three semicolons: a heading for a section of code.

;; Two semicolons: a comment on its own line,
;; about the code below it.
(+ 1 2)   ; One semicolon: a short note at the end of a line.
```

Lisp treats all three the same. The number of semicolons is a convention that tells human readers what kind of comment it is.

== Your first error

Run this. It has a mistake on purpose:

```lisp
(plus 1 2)
```

A debugger window opens. The first line says something like:

```text
The function COMMON-LISP-USER::PLUS is undefined.
```

Read it carefully:

- `PLUS` is the name you used. Lisp shows names in capitals. Chapter 3 explains why.
- `COMMON-LISP-USER::` is the area where your names live. You can ignore it for now. It's always there for your own code.
- "undefined" means there is no function with that name.

Press `q` to close the window. Nothing is broken. The Lisp is still running and everything you defined is still there.

Errors in Lisp don't crash your program. The program pauses and asks you what to do. Closing the window with `q` means "give up on this expression and go back to the prompt".

== Reading parentheses

New Lispers worry about parentheses. Two facts make them easy:

+ #strong[Emacs counts them for you.] Put the cursor right after a closing parenthesis and Emacs highlights the opening one.
+ #strong[Experienced Lispers read indentation, not parentheses.] The shape of the code on the page shows its structure. Emacs indents it for you: select a region and press `TAB`, or inside a code block press `C-c '` and then `TAB` on each line.

Closing parentheses go together at the end of the last line:

```lisp
;; Good Lisp style
(* 2
   (+ 3
      4))

;; Not Lisp style: closing parentheses on their own lines
(* 2
   (+ 3
      4
   )
)
```

Both work. Only the first looks like Lisp. Use it.

== Common mistakes

- #strong[Putting the operator in the middle:] `(1 + 2)`. The error is "Illegal function call" or "1 is not a function name". The operator always comes first: `(+ 1 2)`.
- #strong[Leaving out spaces:] `(+1 2)` is not "plus, one, two". Lisp reads `+1` as the number positive one, then complains that `+1` is not a function. Always put a space after the operator.
- #strong[Using commas between arguments:] `(+ 1, 2)`. Lisp separates arguments with spaces only. A comma here gives "comma not inside a backquote", which is a feature you will meet in Part IV.
- #strong[Expecting printed text in the block result:] you used `print` but the block shows only the final value. Add `:results output`.
- #strong[Unbalanced parentheses in a block:] the block gives an "end of file" error. One closing parenthesis is missing. Put the cursor after each closing parenthesis to find the one that has no partner.

== Project step: the adventure begins

The project is a text adventure. The player is in a small house and moves between rooms. In this chapter, print the opening line of the game.

```lisp
(princ "You wake up in a small, quiet house.")
```

That's the whole step. In the next chapter, the rooms become data.

== Exercises

#exercise("1.1")[
  Write an expression that calculates the number of minutes in a week (7 days, 24 hours per day, 60 minutes per hour).

]

#exercise("1.2")[
  Write this calculation in Lisp: `(10 - 4) * (3 + 2)`.

]

#exercise("1.3")[
  Write this one: `100 / (2 * 5) - 3`.

]

#exercise("1.4")[
  Print the line `Welcome, traveller.` without quotes. Which block header do you need to see it in the result?

]

#exercise("1.5")[
  Each line below has a mistake. Say what's wrong and write the fixed version.

  ```text
  (5 * 3)
  (+2 3)
  (+ 1 (* 2 3)
  (* 2, 4)
  ```

]

