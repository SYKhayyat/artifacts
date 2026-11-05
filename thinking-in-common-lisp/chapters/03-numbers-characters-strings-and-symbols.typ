#import "../lib.typ": *

= Numbers, Characters, Strings and Symbols

This chapter covers the atoms you'll use every day. Each section is a small tour. Run everything, and come back to this chapter as a reference.

== Integers

Integers in Lisp have no size limit. Java's `int` overflows past about two billion. Lisp just keeps going:

```lisp
(expt 2 10)     ; => 1024
(expt 2 100)    ; => 1267650600228229401496703205376
```

`expt` raises its first argument to the power of the second. You never need to think about `int` versus `long` versus `BigInteger`. Lisp switches to big numbers by itself when needed.

== Ratios: exact fractions

Here is the first real surprise:

```lisp
(/ 6 3)     ; => 2
(/ 7 2)     ; => 7/2
(/ 1 3)     ; => 1/3
```

Dividing two integers gives an exact answer. If it isn't a whole number, Lisp gives a #emph[ratio]. Java would give `3` for `7 / 2` and throw away the remainder. Lisp keeps the exact value.

You can write ratios yourself, and they reduce automatically:

```lisp
(+ 1/3 1/6)    ; => 1/2
(* 2/3 3)      ; => 2
(/ 4 6)        ; => 2/3
```

== Floats

A number with a decimal point is a #emph[float]:

```lisp
(/ 7 2.0)        ; => 3.5
(+ 1.5 2)        ; => 3.5
(float 7/2)      ; => 3.5
(float 1/3)      ; => 0.33333334
```

If any argument is a float, the result is a float. `float` converts a number to a float.

By default, `1.5` is a #emph[single-float], with about 7 digits of precision, like Java's `float`. For more precision, like Java's `double`, write `d0` at the end:

```lisp
(float 1/3 1d0)  ; => 0.3333333333333333d0
(* 1.5d0 2)      ; => 3.0d0
```

The second argument to `float` is an example of the precision you want. The `d0` means "times ten to the power zero, in double precision". For most work in this guide, integers and ratios are enough.

== Arithmetic you'll use

#[
  #set par(justify: false)
  #table(
    columns: (2.0fr, 1.1fr, 4.9fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Expression], [Result], [Meaning]),
    [`(+ 1 2 3)`], [`6`], [add],
    [`(- 10 3)`], [`7`], [subtract],
    [`(- 5)`], [`-5`], [negate],
    [`(* 2 3 4)`], [`24`], [multiply],
    [`(/ 12 4)`], [`3`], [divide],
    [`(1+ 5)`], [`6`], [add one],
    [`(1- 5)`], [`4`], [subtract one],
    [`(mod 17 5)`], [`2`], [remainder (like Java's `%`)],
    [`(expt 2 8)`], [`256`], [power],
    [`(sqrt 16)`], [`4.0`], [square root (gives a float)],
    [`(isqrt 17)`], [`4`], [whole-number square root],
    [`(abs -7)`], [`7`], [absolute value],
    [`(max 3 9 2)`], [`9`], [largest],
    [`(min 3 9 2)`], [`2`], [smallest],
  )
]

`1+` is a single name, not "one plus". It's a function called `1+`. Lisp names can contain characters like `+`, `-` and `*`.

== Comparing numbers

```lisp
(= 3 3)          ; => T
(= 3 3.0)        ; => T
(/= 3 4)         ; => T    "not equal"
(< 1 2)          ; => T
(< 1 2 3 4)      ; => T    each one smaller than the next
(< 1 3 2)        ; => NIL
(>= 5 5)         ; => T
```

`(< 1 2 3 4)` checks a whole chain at once. In Java you'd write `1 < 2 && 2 < 3 && 3 < 4`.

`/=` is "not equal". There is no `!=` in Lisp.

`=` compares numbers only. Using it on anything else is an error.

== Number predicates

```lisp
(numberp 5)      ; => T     is it a number?
(integerp 5)     ; => T     is it an integer?
(integerp 5.0)   ; => NIL
(zerop 0)        ; => T     is it zero?
(plusp 3)        ; => T     is it positive?
(minusp -3)      ; => T     is it negative?
(evenp 4)        ; => T
(oddp 4)         ; => NIL
```

== Characters

A single character is written with `#\` in front:

```lisp
#\a              ; => #\a
#\Z              ; => #\Z
#\Space          ; => #\Space
#\Newline        ; => #\Newline
```

A character and a one-letter string are different things. `#\a` is a character. `"a"` is a string that holds one character.

```lisp
(characterp #\a)        ; => T
(characterp "a")        ; => NIL
(char-upcase #\a)       ; => #\A
(char-downcase #\Q)     ; => #\q
(char-code #\A)         ; => 65
(code-char 97)          ; => #\a
(char= #\a #\a)         ; => T
(alpha-char-p #\a)      ; => T
(alpha-char-p #\7)      ; => NIL
(digit-char-p #\7)      ; => 7
(upper-case-p #\A)      ; => T
(char< #\a #\b)         ; => T
(char-equal #\a #\A)    ; => T
```

What each one does:

- `char-upcase` and `char-downcase` change the case of a character.
- `char-code` gives the character's number. `code-char` goes back the other way.
- `char=` tests whether two characters are the same. Case matters: `#\a` and `#\A` are different.
- `char-equal` is the same test, but ignores case.
- `alpha-char-p` asks "is it a letter?"
- `digit-char-p` returns the digit's value, or `nil` if the character isn't a digit. A value that isn't `nil` counts as true, so it works as a yes\/no question too.
- `char<` compares characters by alphabetical order.

Use `char=` for characters, not `=`. Remember that `=` is only for numbers.

== Strings

A string is text inside double quotes:

```lisp
"Hello"              ; => "Hello"
(stringp "Hello")    ; => T
(length "Hello")     ; => 5
```

To put a double quote inside a string, write `\"`. To put a backslash in one, write `\\`:

```lisp
(princ "She said \"hi\" and left.")
```

`princ` shows the text the way a human would read it. `print` would show the backslashes, because it shows strings the way you'd type them into Lisp.

A string can span several lines. The line breaks become part of the text:

```lisp
(princ "Line one
Line two")
```

=== Getting characters out of a string

```lisp
(char "lisp" 0)      ; => #\l
(char "lisp" 3)      ; => #\p
```

`char` takes the string first, then the index. Indexes start at zero, like `nth`. Notice the order is the opposite of `nth`, which takes the index first. This is a common source of mistakes.

=== Pieces of strings

```lisp
(subseq "hello world" 0 5)   ; => "hello"
(subseq "hello world" 6)     ; => "world"
```

`subseq` ("sub-sequence") takes a start index and an optional end index. The end index is #emph[not] included, like Java's `substring`. With no end, it goes to the end of the string.

```lisp
(search "lo" "hello")        ; => 3
(search "xyz" "hello")       ; => NIL
```

`search` finds where the first string appears inside the second. It returns the starting index, or `nil` if it isn't there.

=== Joining strings

```lisp
(concatenate 'string "Hello" ", " "world")   ; => "Hello, world"
```

The first argument, `'string`, is a quoted symbol. It tells `concatenate` what kind of result to build. `concatenate` can also join lists:

```lisp
(concatenate 'list '(1 2) '(3 4))   ; => (1 2 3 4)
```

For strings you'll always write `'string`. Forgetting it is one of the most common beginner errors.

=== Changing case and trimming

```lisp
(string-upcase "hello")            ; => "HELLO"
(string-downcase "HELLO")          ; => "hello"
(string-capitalize "hello world")  ; => "Hello World"
(string-trim " " "   hi   ")       ; => "hi"
(reverse "abc")                    ; => "cba"
```

`string-trim` removes the characters in its first argument from both ends of the second. All of these return a #emph[new] string. The original is unchanged.

`reverse` and `length` work on strings as well as lists. Lists and strings are both #emph[sequences], and many functions accept either. Part III covers sequences fully.

=== Comparing strings

```lisp
(string= "abc" "abc")       ; => T
(string= "abc" "ABC")       ; => NIL
(string-equal "abc" "ABC")  ; => T
```

`string=` cares about case. `string-equal` ignores it. This matches the `char=` and `char-equal` pair.

Alphabetical order:

```lisp
(string< "apple" "banana")  ; => 0
(string< "banana" "apple")  ; => NIL
```

`string<` does not return `T` when the answer is yes. It returns the index where the two strings first differ. That's `0` here, because `a` and `b` differ at position zero. Since `0` isn't `nil`, it counts as true. If you only need yes or no, you can treat any non-`nil` result as yes.

=== Turning other things into strings

```lisp
(princ-to-string 42)       ; => "42"
(princ-to-string 'kitchen) ; => "KITCHEN"
(string #\a)               ; => "a"
```

`princ-to-string` gives the text that `princ` would have printed, as a string. `string` turns a character into a one-character string.

== Symbols

You've used symbols since Chapter 1: `+`, `first`, `kitchen`. A symbol is a name. It's a real object that Lisp creates the first time it reads that name, and it's the same object every time you write that name again.

=== Two jobs of a symbol

+ #strong[As code], a symbol names something: a function (`+`), or a value (Chapter 4 shows how).
+ #strong[As data], after a quote, a symbol is just itself:

```lisp
'kitchen          ; => KITCHEN
(symbolp 'kitchen)  ; => T
(symbolp "kitchen") ; => NIL
```

Use symbols as data for fixed labels: room names, directions, colours, states. In Java you'd use an `enum`. In Lisp you just write the name.

=== Why everything is in capitals

When Lisp reads your code, it converts symbol names to upper case. `kitchen`, `Kitchen` and `KITCHEN` all become the same symbol, `KITCHEN`:

```lisp
'Kitchen               ; => KITCHEN
(symbol-name 'kitchen) ; => "KITCHEN"
```

`symbol-name` gives the name as a string. You still write code in lower case. Lisp displays symbols in capitals. That's all there is to it.

If you really need lower-case letters in a symbol, put the name between vertical bars: `'|Kitchen|`. You'll rarely need this. When you see vertical bars in a result, it usually means you made a symbol from a lower-case string by mistake.

Strings keep their case. `"Kitchen"` stays `"Kitchen"`. Use strings for text a human reads, and symbols for labels the program uses.

=== Is it the same symbol?

`eq` tells you whether two symbols are the same one:

```lisp
(eq 'north 'north)   ; => T
(eq 'north 'NORTH)   ; => T
(eq 'north 'south)   ; => NIL
```

For symbols, `eq` is the right test. For the other atoms you know:

#[
  #set par(justify: false)
  #table(
    columns: (5.0fr, 3.0fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([To compare], [Use]),
    [numbers], [`=`],
    [characters], [`char=`],
    [strings], [`string=`],
    [symbols], [`eq`],
  )
]

Part IV covers equality fully, including how to compare lists.

=== Keywords

A symbol that starts with a colon is a #emph[keyword]:

```lisp
:north              ; => :NORTH
(keywordp :north)   ; => T
```

A keyword evaluates to itself, so it never needs a quote. You'll use keywords a lot from Chapter 5 onwards, as labels for function arguments.

=== T and NIL are symbols

`t` and `nil` are symbols too, and like keywords they evaluate to themselves:

```lisp
t      ; => T
nil    ; => NIL
(symbolp t)   ; => T
```

== Common mistakes

- #strong[Integer division surprise:] expecting `(/ 7 2)` to give `3` or `3.5`. It gives `7/2`. Use `(float (/ 7 2))` for a decimal, or `(floor 7 2)` for the whole-number part. (`floor` shows a second number in the REPL, the remainder. The first number is the answer.)
- #strong[Using `=` on non-numbers:] `(= "a" "a")` gives an error saying the value "is not a NUMBER". Use `string=` for strings, `char=` for characters, `eq` for symbols.
- #strong[Forgetting `'string` in `concatenate`:] `(concatenate "a" "b")` gives an error about an unknown type or "is not a valid sequence type specifier". Write `(concatenate 'string "a" "b")`.
- #strong[Mixing up `char` and `nth` argument order:] `char` takes the string first, `(char "abc" 0)`. `nth` takes the index first, `(nth 0 '(a b c))`.
- #strong[Confusing `"a"` and `#\a`:] functions for characters won't accept a string. `(char-upcase "a")` is an error. Use `(char-upcase #\a)` or `(string-upcase "a")`.
- #strong[Unescaped quote in a string:] `"He said "hi""` ends the string early and confuses Lisp. Write `"He said \"hi\""`.
- #strong[Expecting `string<` to return `T`:] it returns an index. Any number means yes.
- #strong[Expecting symbols to keep their case:] `'Kitchen` becomes `KITCHEN`. If you need to show it nicely, use `string-capitalize` on its name.

== Project step: room descriptions

A room now has three parts: its name, a description for the player, and its exits.

```lisp
'(kitchen "A warm kitchen that smells of bread." (hallway garden))
```

The name is a symbol, because the program uses it as a label. The description is a string, because the player reads it.

Build the line the game shows when you enter the kitchen:

```lisp
(concatenate 'string
             "You are in the "
             (string-capitalize
              (symbol-name
               (first '(kitchen "A warm kitchen that smells of bread."
                        (hallway garden)))))
             ". "
             (second '(kitchen "A warm kitchen that smells of bread."
                       (hallway garden))))
;; => "You are in the Kitchen. A warm kitchen that smells of bread."
```

Read it from the inside out:

+ `(first '(kitchen ...))` gives the symbol `KITCHEN`.
+ `symbol-name` turns it into the string `"KITCHEN"`.
+ `string-capitalize` turns that into `"Kitchen"`.
+ `(second '(kitchen ...))` gives the description.
+ `concatenate` joins all four strings.

You had to type the room list twice. That's clumsy, and it's exactly the problem Chapter 4 solves: you'll give the list a name and use the name instead.

To show the line to the player, wrap the same expression in `princ`:

```lisp
(princ (concatenate 'string
                    "You are in the "
                    (string-capitalize (symbol-name 'kitchen))
                    ". "
                    "A warm kitchen that smells of bread."))
```

You should see the text without quotes:

```text
You are in the Kitchen. A warm kitchen that smells of bread.
```

== Exercises

#exercise("3.1")[
  Add 2\/3 and 1\/4 and get the exact answer. Then write a second expression that gives the same answer as a decimal.

]

#exercise("3.2")[
  Predict the result of each line, then check:

  ```text
  (/ 10 4)
  (/ 10 4.0)
  (mod 10 4)
  (isqrt 50)
  ```

]

#exercise("3.3")[
  Use `subseq` to get `"Lisp"` out of `"I love Lisp"`.

]

#exercise("3.4")[
  Starting from the strings `"hello"` and `"world"`, build `"HELLO, WORLD!"` in one expression.

]

#exercise("3.5")[
  Write two expressions:

  + One that gives the numeric value of the character `#\7`.
  + One that turns `#\b` into upper case and then gives its character code.

]

#exercise("3.6")[
  Predict the result of each line:

  ```text
  (eq 'Apple 'APPLE)
  (string= "Apple" "APPLE")
  (string-equal "Apple" "APPLE")
  (symbol-name :north)
  ```

]

#exercise("3.7", project: true)[
  Given this room:

  ```text
  '(garden "An overgrown garden." (kitchen shed))
  ```

  Write an expression that returns the string "You are in the Garden. An overgrown garden.". Take the name and the description out of the list. Don't type them in by hand.

]

