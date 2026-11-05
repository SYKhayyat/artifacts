#import "../lib.typ": *

= Expressions, Atoms and Lists

== Everything is an expression

In Java, there are #emph[statements] (like `if` or `for`) and #emph[expressions] (like `a + b`). Statements do things. Expressions have values.

In Lisp, everything is an expression. Everything has a value. You will see in Chapter 6 that even `if` gives back a value.

Lisp code is built from just two kinds of thing.

== Atoms

An #emph[atom] is anything that isn't a list. Some atoms:

```lisp
42          ; a number
3.14        ; another number
"hello"     ; a string
```

Numbers and strings evaluate to themselves.

There is a third important kind of atom: the #emph[symbol]. A symbol is a name, like `x`, `total`, `+` or `print`. When Lisp evaluates a symbol, it looks up the value that name stands for. Chapter 3 covers symbols in depth. Chapter 4 shows how to give them values.

== Lists

A #emph[list] is some things inside parentheses, separated by spaces:

```text
(1 2 3)
(+ 1 2)
(a b c)
(1 (2 3) 4)
()
```

The last one is the empty list. A list can hold other lists.

Here is the key idea of Lisp: #strong[code is written as lists.] `(+ 1 2)` is a list of three things: the symbol `+`, the number `1` and the number `2`. When Lisp evaluates a list, it treats the first element as the name of something to do, and the rest as the arguments.

== The evaluation rule

When Lisp evaluates `(f a b)`, it does this:

+ Look at the first element, `f`. It names an operator.
+ Evaluate each argument in order, left to right.
+ Call the operator with those values.

Trace it on a nested example:

```text
(+ (* 2 3) (- 10 4))
1. The operator is +.
2. Evaluate (* 2 3)  → 6
   Evaluate (- 10 4) → 6
3. Call + with 6 and 6 → 12
```

Each argument is itself evaluated by the same rule. That's why nesting works to any depth.

This is the #emph[normal] rule, for #emph[function calls]. A few special operators follow different rules. You'll meet them one at a time, and each time the guide will say exactly how it differs. `quote`, below, is the first.

== Quote: "don't evaluate this"

Try to make a list of three numbers:

```lisp
(1 2 3)
```

Error: "illegal function call". Lisp tried to #emph[call] `1` as an operator. You want the list as data, not as code.

`quote` stops evaluation. It gives back its argument untouched:

```lisp
(quote (1 2 3))   ; => (1 2 3)
```

You will write `quote` so often that it has a short form, the apostrophe:

```lisp
'(1 2 3)          ; => (1 2 3)
'(+ 1 2)          ; => (+ 1 2)
```

The second one is the #emph[list] `(+ 1 2)`, not the number `3`. Quote keeps code from running and gives it to you as data.

`quote` breaks the normal evaluation rule on purpose: it does #strong[not] evaluate its argument. That is what makes it special.

== Building lists with `list`

`list` is an ordinary function. It evaluates its arguments and makes a list of the results:

```lisp
(list 1 2 3)           ; => (1 2 3)
(list 1 (+ 1 1) 3)     ; => (1 2 3)
'(1 (+ 1 1) 3)         ; => (1 (+ 1 1) 3)
```

Compare the last two. `list` computed `(+ 1 1)`. The quote didn't.

Use quote when you know the exact contents ahead of time. Use `list` when some parts must be computed.

== Taking lists apart

```lisp
(first '(a b c))    ; => A
(second '(a b c))   ; => B
(third '(a b c))    ; => C
(rest '(a b c))     ; => (B C)
```

- `first` gives the first element.
- `rest` gives a list of everything after the first element.
- `second` through `tenth` also exist.

Lisp shows `a` as `A`. Chapter 3 explains why.

You'll also see `car` and `cdr` in older code. They mean the same as `first` and `rest`. Part II explains where those names come from.

```lisp
(first (rest '(a b c)))   ; => B
```

Read nested calls from the inside out: "the rest of `(a b c)` is `(b c)`, and the first of that is `b`".

== How results are printed

Results are shown the way the REPL prints them, not the way a typesetter would. A list stays a list — `(1 2 3)`, not a table — and a string keeps its quotes, because that is the form Lisp would read back.

So when you compare your answer with ours, expect the readable form. The human form — no quotes, no escaping — is what `princ` and `format` are for.

== Counting and indexing

```lisp
(length '(a b c d))    ; => 4
(nth 0 '(a b c d))     ; => A
(nth 2 '(a b c d))     ; => C
```

`nth` counts from zero, like array indexes in Java. `(nth 0 ...)` is the same as `first`. The argument order is index first, then the list.

== The empty list and NIL

The empty list has a second name, `nil`:

```lisp
'()              ; => NIL
(rest '(a))      ; => NIL
(length nil)     ; => 0
```

`()` and `nil` are the same thing. Lisp always prints it as `NIL`.

Taking apart an empty list gives back `nil` instead of an error:

```lisp
(first '())      ; => NIL
(rest '())       ; => NIL
```

`nil` also means #emph[false]. The symbol `t` means #emph[true]. Lisp has no separate true\/false type like Java's `boolean`. Any value that isn't `nil` counts as true. Chapter 6 relies on this.

== Asking questions about data

A function that answers yes or no is called a #emph[predicate]. It returns `t` or `nil`. Many predicate names end in `p` (for "predicate"):

```lisp
(listp '(1 2))   ; => T     is it a list?
(listp 5)        ; => NIL
(atom 5)         ; => T     is it an atom?
(atom '(1 2))    ; => NIL
(null '())       ; => T     is it the empty list?
(null '(a))      ; => NIL
```

One surprise: `nil` is both an atom and a list.

```lisp
(atom nil)       ; => T
(listp nil)      ; => T
```

It's an atom because it isn't built from parts. It's a list because it is the empty list. Part II shows how lists are built, and this will then look natural.

== Combining and reversing lists

```lisp
(append '(a b) '(c d))       ; => (A B C D)
(append '(1) '(2 3) '(4))    ; => (1 2 3 4)
(reverse '(1 2 3))           ; => (3 2 1)
(last '(1 2 3))              ; => (3)
```

`append` joins any number of lists into one. `reverse` gives a new list in the opposite order. Neither changes the lists you gave it.

Look closely at `last`. It returns a list holding the last element, not the element itself. To get the element, take its `first`:

```lisp
(first (last '(1 2 3)))      ; => 3
```

Part II explains why `last` works this way.

== Common mistakes

- #strong[Forgetting the quote:] `(first (1 2 3))` gives "illegal function call". Lisp tried to call `1`. Write `(first '(1 2 3))`.
- #strong[Quoting something that should be computed:] `'(1 (+ 1 1))` gives `(1 (+ 1 1))`, not `(1 2)`. If a part must be worked out, use `list`: `(list 1 (+ 1 1))`.
- #strong[Swapping the arguments of `nth`:] `(nth '(a b c) 1)` gives an error saying the list "is not of type UNSIGNED-BYTE". The index comes first: `(nth 1 '(a b c))`.
- #strong[Counting `nth` from one:] `(nth 1 '(a b c))` is `B`, not `A`. Indexes start at zero.
- #strong[Expecting `last` to return the element:] it returns a one-element list. Use `(first (last ...))`.
- #strong[Thinking `()` and `nil` are different:] they're the same object. Both print as `NIL`.

== Project step: rooms as data

The house has four rooms. A quoted list holds their names:

```lisp
'(bedroom hallway kitchen garden)
;; => (BEDROOM HALLWAY KITCHEN GARDEN)
```

The player starts in the first room:

```lisp
(first '(bedroom hallway kitchen garden))   ; => BEDROOM
```

A room also needs to know where you can go from it. Put the room's name first and a list of its neighbours second:

```lisp
'(kitchen (hallway garden))
```

Now take it apart:

```lisp
(first '(kitchen (hallway garden)))    ; => KITCHEN
(second '(kitchen (hallway garden)))   ; => (HALLWAY GARDEN)
```

The first expression returns `KITCHEN`. The second returns the list of exits. You've just designed a data format with nothing but lists. In Java you'd write a `Room` class first. In Lisp you often start with plain lists and add structure later, when you know what you need.

== Exercises

#exercise("2.1")[
  Predict the result of each line, then run them one at a time to check:

  ```text
  '(+ 2 3)
  (list '+ 2 3)
  (+ 2 3)
  ```

]

#exercise("2.2")[
  Get the symbol `C` out of `'(a b c d)` in three different ways.

]

#exercise("2.3")[
  Get the symbol `BLUE` (not the list `(BLUE)`) out of `'(red green blue)`.

]

#exercise("2.4")[
  Using `'(1 2 3)` and `'(4 5 6)`, build `(6 5 4 3 2 1)` in one expression.

]

#exercise("2.5")[
  Predict the result of each line:

  ```text
  (listp nil)
  (null '(nil))
  (length '((a b) (c d e)))
  (rest '(only))
  ```

]

#exercise("2.6")[
  The room data `'(garden (kitchen shed))` says the garden connects to the kitchen and the shed. Write an expression that returns `SHED`.

]

