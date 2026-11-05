#import "../lib.typ": *

= format

Every chapter so far has built strings with `concatenate` and `string-downcase`. That works, but the game's messages are turning into nested calls. `format` is Lisp's answer: one function that takes a #emph[control string] with placeholders and produces text. Other languages copied it: Python's `%` formatting and its newer format mini-language both trace back to `format`.

This chapter is a reference as much as a lesson. Learn the first third; the rest you can look up as you need it.

== The shape of `format`

```lisp
(format t "Hello, world.~%")
```

```text
Hello, world.
```

`format` takes a #emph[destination], a control string, and any number of arguments. The destination decides where the text goes:

#table(
  columns: (1.9fr, 6.1fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Destination], [Meaning]),
  [`t`], [Print to standard output, return `nil`],
  [`nil`], [Build a string and return it],
  [A stream], [Write to that stream (Chapter 16)],
)

So `t` is for printing and `nil` is for building. The game's message functions build strings, so they use `nil`:

```lisp
(format nil "You take the ~A." 'key)
;; => "You take the key."
```

== The tilde: directives

Everything in a control string is copied out word for word, except what starts with a tilde. A tilde begins a #emph[directive], a placeholder or an instruction:

```lisp
(format nil "You see ~A and ~A." 'lamp 'key)
;; => "You see LAMP and KEY."
```

`~A` means "put the next argument here, printed for people to read". Arguments are used in order, one per placeholder.

The directive letter is case-insensitive: `~a` and `~A` are the same. Capital letters in the directives that print words choose the case of the output, as you'll see.

== The essential directives

=== `~A` and `~S`

`print` and `princ` from Chapter 1 are two ways to show a value: `princ` for people, `print` for Lisp. `~A` and `~S` are `format`'s versions of the same distinction:

```lisp
(format nil "~A" "hello")   ; => "hello"
(format nil "~S" "hello")   ; => "hello", with the quotes
(format nil "~A" 'key)      ; => KEY
(format nil "~S" 'key)      ; => KEY
```

For strings the difference matters, for symbols it doesn't. Use `~A` for messages people read, `~S` when the text must be read back by Lisp, for example in a saved file.

=== `~D`: decimal integers

```lisp
(format nil "You have ~D coins." 42)          ; => "You have 42 coins."
(format nil "~D" -7)                          ; => -7
```

It fails on anything but an integer, on purpose: `format` doesn't guess.

=== `~F`: floats

`~-F` says how many digits to show after the decimal point:

```lisp
(format nil "Distance: ~,2F km" 123.4567)   ; => "Distance: 123.46 km"
(format nil "~F" 0.5)                       ; => "0.5"
```

=== `~C`: characters

```lisp
(format nil "Press ~C to quit." #\q)   ; => "Press q to quit."
```

=== `~%`: newline, `~&`: fresh line, `~~`: tilde

```lisp
(format t "Line one.~%Line two.~%")
```

```text
Line one.
Line two.
```

`~%` prints exactly `n` newlines, where `n` is a number between the tilde and the letter. `~&` is more forgiving: it prints a newline only if the output isn't already at the start of one. Ending messages with `~&` instead of `~%` is a good habit, because two messages in a row then never leave a blank line between them.

```lisp
(format t "A.~%")
(format t "~3%")
(format t "B.~&")
(format t "C.~&")
```

```text
A.

B.
C.
```

`~~` prints one tilde, since a bare `~` would start a directive.

== Arguments used in other ways

=== \~{}: the next argument is a list

Some directives don't print an argument themselves, but change how the next ones are treated. `~{` says "the next argument is a list, and its elements are the arguments for what follows":

```lisp
(format nil "~{~A~}" '(a b c))       ; => "ABC"
(format nil "~{~A, ~}" '(a b c))     ; => "A, B, C, "
```

`~{~}` walks the list, running the directives between `~{` and `~}` once per element. That's `mapcar` inside a control string.

Because `~A` consumes from the list, you can interleave text and values:

```lisp
(format nil "~{~A: ~A~%~}" '("name" "Ada" "age" "36"))
;; => "name: Ada
;;     age: 36
;;     "
```

=== \~\@{}: the arguments themselves are the list

`~@{` is the same walk, but over `format`'s own arguments instead of a list:

```lisp
(format nil "~{~A or ~}" 'x 'y)      ; wrong, no list argument
```

```lisp
(format nil "~@{~A or ~}" 'x 'y)     ; => "X or Y or "
```

=== Trailing separators: `~^`

Both walk forms have a companion directive that changes the last pass. `~^` means "stop here if the list is exhausted":

```lisp
(format nil "~{~A~^, ~}" '(a b c))       ; => "A, B, C"
(format nil "~@{~A~^, ~}" 'x 'y 'z)      ; => "X, Y, Z"
```

`~^` is how you join a list with commas and no dangling separator — the exact job `item-names` did by hand in Exercise 8.11.

=== `~T`: columns

`~T` moves to a column, like a tab:

```lisp
(format t "~A~10T~A~%" 'room 'items)
(format t "~A~10T~A~%" 'kitchen 'key)
```

```text
ROOM      ITEMS
KITCHEN   KEY
```

`~10T` means "move to column 10". `~@T` means "move right by that many spaces".

== Width, padding and case

A number between `~` and the letter sets the #emph[minimum width]; the value is padded with spaces on the left:

```lisp
(format nil "[~5D]" 42)    ; => "[   42]"
(format nil "[~5A]" "hi")  ; => "[   hi]"
```

The `@` modifier flips the padding to the right:

```lisp
(format nil "[~5@A]" "hi")  ; => "[hi   ]"
```

The `:` modifier on `~D` adds commas:

```lisp
(format nil "~:D" 1000000)   ; => "1,000,000"
```

On `~A` and `~S`, the `:` modifier prints `nil` as `()` instead of `NIL`:

```lisp
(format nil "~A" nil)    ; => "NIL"
(format nil "~:A" nil)   ; => "()"
```

Modifiers combine: `~:@D` signs the number with `+`:

```lisp
(format nil "~:@D" 42)   ; => "+42"
```

== Conditionals inside format

`~[~]` picks one of several texts by the value of an argument. The argument is an integer, counting from zero:

```lisp
(format nil "You have ~[no coins~;one coin~:;~D coins~]." 3 3)
;; => "You have 3 coins."
```

The `:;` clause is the default, used when the number is out of range. This one expression handles zero, one and many — the plural problem, solved in the control string. Pass `0` or `1` to see the other clauses.

`~:[~]` takes a true-or-false argument instead: two clauses, `nil` gets the first, anything else the second:

```lisp
(format nil "The door is ~:[closed~;open~]." t)   ; => "The door is open."
```

`~:[` can also compare against nothing at all: `~:[~A~;nothing~]` takes no integer. When the argument is `nil`, the second clause prints:

```lisp
(format nil "You see ~:[something~;nothing~]." nil)
;; => "You see nothing."
```

== Recursive format: \/ and named functions

There's a directive that spells out numbers in words:

```lisp
(format nil "~R" 42)        ; => "forty-two"
(format nil "~:R" 3)        ; => "third"
```

`~R`'s related trick is more important: you can write your own directive as a Lisp function and call it with `~/name`:

```lisp
(defun format-room (stream argument colonp atp)
  "Print ARGUMENT, a room entry, as a short line."
  (declare (ignore colonp atp))
  (format stream "~A: ~A" (first argument) (second argument)))

(format nil "~/format-room/" '(kitchen "the key is here"))
;; => "KITCHEN: the key is here"
```

A `~/` directive calls a function of four arguments: the stream, the value, and two flags that say whether you wrote `:` and `@`. `declare (ignore ...)` tells the compiler the unused parameters are on purpose, which keeps it quiet. This is rare in day-to-day code, but it explains the shape: the first argument of any `format` helper function is the stream, and that's why `format` can take `nil` or `t` there.

== Building messages for the game

The game's string building so far:

```lisp
(concatenate 'string
             (item-name item)
             " is in the "
             (string-downcase (symbol-name place)))
```

The same message with `format`:

```lisp
(format nil "~A is in the ~(~A~)." 'key 'kitchen)
;; => "key is in the kitchen"
```

`~(~A~)` lower-cases everything it wraps. With `:` it capitalises the first word instead:

```lisp
(format nil "~:(~A~) is in the ~(~A~)." 'key 'kitchen)
;; => "Key is in the kitchen"
```

The examples above are fragments; the full message is in the project step. The important part is the pair of directive modifiers:

#table(
  columns: (1.6fr, 6.4fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Directive], [Effect]),
  [`~A`], [As is],
  [`~(~A~)`], [Lower-case],
  [`~:(~A~)`], [First letter of each word upper-case],
  [`~@(~A~)`], [First letter upper-case, rest lower],
  [`~:@(~A~)`], [All upper-case],
)

`~@(~A~)` is the one for starting a sentence: it gives `"Key"` from `KEY`, with any capitals inside tamed to lower case.

== Common mistakes

=== Extra or missing arguments

```text
(format nil "~A and ~A" 'x)
;; error: too few arguments
```

Count the placeholders and the arguments. One `~A` per argument.

=== A stray tilde

```text
(format nil "100% sure")
;; error: unknown directive %
```

`%` after a space is a directive too, roughly `~%`. Write `~~` for a literal tilde, and be careful with `%` in text meant for people.

=== `format t` inside a builder

A function whose job is to #emph[return] a string must use `format nil`. Mixing them up either prints nothing or returns `nil`:

```text
(defun describe-room (room)
  (format t "You are in the ~A." room))
;; returns NIL, prints as a side effect
```

=== `~D` on the wrong type

`~D` takes an integer. `(format nil "~D" 'key)` is an error, and `(format nil "~D" 3.5)` is too. Use `~A` when the type varies.

=== Case directives without the closing )

`~(= must be closed with =~)`, just as `~{` must be closed with `~}`. An unclosed case directive reads the rest of the string as text to change.

== Project step: messages in one place

The game's message functions each build strings by hand. This step rewrites them around `format`, and gathers the messages where you can see and change them.

First the helper that names a list of items with commas, no "and":

```lisp
(defun item-list-string (items)
  "Return a readable list of the names of ITEMS, comma-separated."
  (format nil "~{~(~A~)~^, ~}" (mapcar #'symbol-name items)))
```

```lisp
(list (item-list-string nil)
      (item-list-string '(key))
      (item-list-string '(key lamp))
      (item-list-string '(key lamp coin)))
```

Expected:

```text
("" "key" "key, lamp" "key, lamp, coin")
```

The empty list gives an empty string, which the callers guard against. The `"key and lamp"` form needs two passes, which `~{~}` alone can't do, so keep the `item-names` from Exercise 8.11 for the game's player messages, and use `item-list-string` where plain commas are right: the `help` command and `describe-all`.

Now the messages, rebuilt around `format nil`:

```lisp
(defun inventory ()
  "Describe what the player is carrying, in alphabetical order."
  (let ((carried (sort (items-here 'player)
                       #'string< :key #'symbol-name)))
    (if (null carried)
        "You are carrying nothing."
        (format nil "You are carrying: ~A." (item-names carried)))))

(defun take (item)
  "Pick up ITEM if it is in the current room."
  (cond ((eq (item-location item) 'player)
         (format nil "You already have the ~(~A~)." item))
        ((eq (item-location item) (room-name *current-room*))
         (setf *item-locations*
               (set-location *item-locations* item 'player))
         (format nil "You take the ~(~A~)." item))
        (t
         "You don't see that here.")))

(defun drop (item)
  "Put down ITEM in the current room, if the player carries it."
  (if (eq (item-location item) 'player)
      (progn
        (setf *item-locations*
              (set-location *item-locations* item
                            (room-name *current-room*)))
        (format nil "You drop the ~(~A~)." item))
      "You don't have that."))

(defun loot ()
  "Take everything lying in the current room."
  (let ((found (items-here (room-name *current-room*))))
    (if (null found)
        "There is nothing here to take."
        (progn
          (take-all found)
          (format nil "You take ~A." (item-names found))))))

(defun item-report (pairs)
  "Return one string per item in PAIRS, saying where it is."
  (loop for (item . place) in pairs
        collect (if (eq place 'player)
                    (format nil "~@(~A~) is carried" item)
                    (format nil "~@(~A~) is in the ~(~A~)"
                            item place))))
```

`take`, `drop` and `item-report` now pass symbols straight to `format`, and the case directives do the lowering. Compare `item-report` with the version from Chapter 11: no `symbol-name`, no `string-downcase`, no `concatenate`. The message reads as a sentence in the code.

Run the whole thing. This resets the items and the current room, so run it as one block:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))

(list (run-command '(take key))
      (run-command '(take key))
      (run-command '(inventory))
      (run-command '(take lamp))
      (run-command '(drop key)))
```

Expected:

```text
("You take the key."
 "You already have the key."
 "You are carrying: key."
 "You don't see that here."
 "You drop the key.")
```

One more: a single function that describes a room the way a player sees it, the way `look` does but with the items in the sentence. The conditional directives handle the empty room and the plurals:

```lisp-s
(defun describe-room-text (room)
  "Return a sentence describing ROOM and what lies there."
  (let ((here (items-here room)))
    (format nil "You are in the ~(~A~). ~:[There is nothing here.~;You see ~{~:(~A~)~^, ~}~]~&"
            room
            here
            (mapcar #'symbol-name here))))
```

Read the control string from the start: the room's name, a period, then `~:[` with two clauses — `nil` gets "There is nothing here.", anything else gets "You see " followed by the item walk with commas. `~&` ends the string so two descriptions never run together.

```lisp
(defparameter *item-locations*
  '((key . kitchen)
    (letter . bedroom)))
(list (describe-room-text 'kitchen)
      (describe-room-text 'garden))
```

Expected:

```text
("You are in the kitchen. You see Key."
 "You are in the garden. There is nothing here.")
```

The capital on `"Key"` comes from `~:(~A~)`. With two items, the walk would print `"Key, Letter"` — right for a list, and the exercises refine the "and".

== Exercises

#exercise("12.1")[
  Predict the result of each line, then check:

  ```text
  (format nil "~A!" 'done)
  (format nil "~S" "hi")
  (format nil "~3D" 7)
  (format nil "~,1F" 2.25)
  (format nil "~A~A" 'a 'b)
  (format nil "a~2%b")
  ```

]

#exercise("12.2")[
  Write `comma-list`, which takes a list of symbols and returns them as a lower-case string separated by `", "`. `(comma-list '(A B C))` gives `"a, b, c"`. One `format` expression.

]

#exercise("12.3")[
  Use one `format` call to produce the string `"1: one, 2: two, 3: three"` from the list `'((1 "one") (2 "two") (3 "three"))`, with no `loop` or `mapcar`.

]

#exercise("12.4")[
  Write `price-line`, which takes a name and a price and returns a padded line, name left-aligned in 12 characters, price right-aligned in 8 with two decimals: `(price-line 'coffee 3.5)` gives `"coffee         3.50"`.

]

#exercise("12.5")[
  Predict the result, then check:

  ```text
  (format nil "You have ~[no keys~;one key~:;~D keys~]." 0)
  (format nil "You have ~[no keys~;one key~:;~D keys~]." 1)
  (format nil "You have ~[no keys~;one key~:;~D keys~]." 5)
  ```

]

#exercise("12.6")[
  Write `pluralise`, which takes a number, a noun as a symbol and returns `"0 coins"`, `"1 coin"` or `"7 coins"`, lower-cased, in one `format` call using `~[`.

]

#exercise("12.7")[
  Each line below is wrong. Say what's wrong, then fix it.

  ```text
  (format nil "~A ~A" 'x)

  (format nil "50% off")

  (format nil "You have ~D apples." "three")

  (format nil "~(HELLO~" 'world)
  ```

]

#exercise("12.8")[
  Write `bar`, which takes a number from 0 to 10 and returns a health bar: that many `"#"` characters, then the rest as `"-"`, in brackets. `(bar 7)` gives `"[#######---]"`. One `format` call with `~10@A` on a prepared string of `#` characters, plus a second prepared string of `-` characters — two pieces, one `format`.

]

#exercise("12.9", project: true)[
  Rewrite `help` from Exercise 10.12 to use `item-list-string`, keeping the alphabetical order. The reply should end with a period.

]

#exercise("12.10", project: true)[
  Improve `describe-room-text` so two items read `"You see Key and Letter"` and three read `"You see Key, Letter and Coin"`. You may write a helper function; the `format` call stays the same.

]

