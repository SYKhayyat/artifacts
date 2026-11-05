#import "../lib.typ": *

= Working with Sequences

Chapter 8 wrote every list walk by hand. Chapter 9 showed that `mapcar` is one of those walks, written once for any function. Common Lisp has a whole family of these: functions that keep elements, remove them, find one, count them, combine them or sort them. Once you know the family, most of the recursive functions from Chapter 8 shrink to one line.

These functions work on #emph[sequences]. A sequence is an ordered collection that you can walk from start to end. Lists are sequences, and so are strings, which are sequences of characters. The same function works on both:

```lisp
(length '(a b c))     ; => 3
(length "abc")        ; => 3
(reverse "abc")       ; => "cba"
```

`mapcar` is the exception: it works on lists only. This chapter shows `map`, its sequence version.

== Keeping and removing: `remove-if` and `remove-if-not`

`remove-if` takes a predicate and a sequence, and returns a new sequence without the elements the predicate says yes to:

```lisp
(remove-if #'evenp '(1 2 3 4 5))                ; => (1 3 5)
(remove-if (lambda (n) (> n 10)) '(5 12 8 20))  ; => (5 8)
```

`remove-if-not` does the opposite: it keeps only the elements the predicate says yes to.

```lisp
(remove-if-not #'evenp '(1 2 3 4 5))            ; => (2 4)
```

The name says what gets removed: `remove-if` removes the matches, `remove-if-not` removes the rest. Other languages call the second one "filter".

On a string, the result is a string. `digit-char-p` returns a true value for a digit character such as `#\7`, and `nil` otherwise:

```lisp
(remove-if #'digit-char-p "a1b2c3")             ; => "abc"
```

When you only want to remove one particular value, `remove` is shorter:

```lisp
(remove 'b '(a b c b))      ; => (A C)
(remove #\space "a b c")    ; => "abc"
```

None of these change the sequence you give them. They return a new one:

```lisp
(defparameter *numbers* (list 1 2 3 4))
(list (remove-if #'evenp *numbers*) *numbers*)
;; => ((1 3) (1 2 3 4))
```

=== `complement`

The Common Lisp standard marks the `-if-not` functions as deprecated, meaning "may be removed one day". Every implementation still has them and you'll see them everywhere, so use them freely. The alternative is `complement`, which takes a predicate and returns a new predicate that answers the opposite:

```lisp
(funcall (complement #'evenp) 3)              ; => T
(remove-if (complement #'evenp) '(1 2 3 4))   ; => (2 4)
```

`complement` is a function that returns a function, like `make-adder` in Chapter 9.

== Finding: `find`, `find-if`, `position`, `member-if`

`find` returns the first element equal to the one you ask for, and `find-if` returns the first one the predicate says yes to. Both return `nil` when nothing matches:

```lisp
(find 3 '(1 2 3 4))              ; => 3
(find-if #'evenp '(1 3 4 5 6))   ; => 4
(find-if #'evenp '(1 3))         ; => NIL
```

`position` and `position-if` return #emph[where] the match is, counting from zero like `nth`:

```lisp
(position 'c '(a b c))             ; => 2
(position-if #'digit-char-p "abc7") ; => 3
(position 'z '(a b c))             ; => NIL
```

`find` has one blind spot. If the element you're looking for is `nil`, you can't tell "found `nil`" from "found nothing":

```lisp
(find nil '(a nil b))     ; => NIL, but it was there
(position nil '(a nil b)) ; => 1, no doubt
```

`member` from Chapter 6 has an `-if` version too. It returns the rest of the list from the first match:

```lisp
(member-if #'evenp '(1 3 4 5))   ; => (4 5)
```

== Counting: `count` and `count-if`

```lisp
(count 'a '(a b a c))            ; => 2
(count-if #'evenp '(1 2 3 4))    ; => 2
(count #\s "mississippi")        ; => 4
```

== Asking about every element: `every` and `some`

`every` is true when the predicate says yes to every element. `some` is true when it says yes to at least one. `plusp` is true for numbers above zero:

```lisp
(every #'plusp '(1 2 3))     ; => T
(every #'plusp '(1 -2 3))    ; => NIL
(some #'evenp '(1 3 4))      ; => T
(some #'evenp '(1 3 5))      ; => NIL
```

Compare the first line with `all-positive-p` from Chapter 8. That whole function is `(every #'plusp lst)`.

`every` on an empty list is `T`: no element says no. `some` on an empty list is `NIL`: no element says yes.

`some` returns the first true value the predicate gave, the same way `or` returns the first true value (Chapter 6). `digit-char-p` returns the digit's value, so:

```lisp
(some #'digit-char-p "ab7c")   ; => 7
```

Like `mapcar`, both accept several sequences and pass one element from each. They stop at the end of the shortest:

```lisp
(every #'< '(1 2 3) '(2 3 4))  ; => T, because 1<2, 2<3 and 3<4
```

`notany` and `notevery` are the negated versions: `(notany #'evenp lst)` means "no element is even".

== The keyword arguments they share

Most of these functions accept the same keyword arguments (`&key`, Chapter 5). Learn them once and they work everywhere.

=== `:key`: look at part of each element

`:key` takes a function. Each element goes through that function before it is compared or tested:

```lisp
(find 'b '((a 1) (b 2) (c 3)) :key #'first)      ; => (B 2)
(remove-if #'evenp '((a 1) (b 2)) :key #'second)  ; => ((A 1))
(count 'kitchen '((key . kitchen) (lamp . cellar) (box . kitchen))
       :key #'cdr)                                ; => 2
```

The result is still the whole element, `(B 2)`, not just the part that was compared. `(find 'b alist :key #'car)` does the same job as `(assoc 'b alist)`.

=== `:test`: which equality to use

By default these functions compare with `eql`, which (like `eq`) says two strings are different unless they are the very same object. That's the string-key problem from Chapter 7 again:

```lisp
(find "b" '("a" "b"))                  ; => NIL
(find "b" '("a" "b") :test #'string=)  ; => "b"
```

`:test` takes the function that decides whether two things count as equal. The next section lists the choices.

=== `:start`, `:end`, `:from-end` and `:count`

`:start` and `:end` limit the work to part of the sequence. `:from-end t` searches from the end. `:count` limits how many elements are removed:

```lisp
(position #\a "banana" :start 2)      ; => 3
(position #\a "banana" :from-end t)   ; => 5
(remove 'a '(a b a c a) :count 2)     ; => (B C A)
```

Positions are always counted from the start of the whole sequence, even with `:start` or `:from-end`.

== Four kinds of equality

You've used `eq` for symbols and `string=` for strings. Common Lisp has four general equality functions. Each one is looser than the one above it:

#table(
  columns: (0.6fr, 7.5fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Function], [True when]),
  [`eq`], [Both are the very same object. Use it for symbols.],
  [`eql`], [Like `eq`, and also equal numbers of the same type, and equal characters. The default for `find`, `member`, `assoc` and the rest.],
  [`equal`], [Like `eql`, and also lists and strings with the same contents. Case matters.],
  [`equalp`], [Like `equal`, ignoring case in strings, and comparing numbers by value.],
)

```lisp
(list (eql #\a #\a)               ; T
      (eql 1 1.0)                 ; NIL, an integer and a float
      (equalp 1 1.0)              ; T
      (eql (list 1 2) (list 1 2)) ; NIL, two separate lists
      (equal (list 1 2) (list 1 2)) ; T, same contents
      (equal "abc" "ABC")         ; NIL
      (equalp "abc" "ABC"))       ; T
```

Don't use `eq` on numbers or characters. Whether two equal numbers are the same object is up to the implementation, so `eq` may give either answer. `eql` is always safe for them.

For lists of lists or strings, `:test #'equal` is usually what you want:

```lisp
(member '(b 2) '((a 1) (b 2)) :test #'equal)   ; => ((B 2))
```

== `map`: `mapcar` for any sequence

`map` works like `mapcar` on strings as well as lists. Its first argument says what kind of sequence to build, the same way `concatenate` does (Chapter 3). `char-upcase` turns one character into upper case, and `char-code` gives a character's number:

```lisp
(map 'string #'char-upcase "abc")   ; => "ABC"
(map 'list #'char-code "AB")        ; => (65 66)
(map 'list #'+ '(1 2) '(10 20))     ; => (11 22)
```

== `reduce`: combine everything into one value

`reduce` takes a function of two arguments and uses it to combine the elements, from left to right:

```lisp
(reduce #'+ '(1 2 3 4))     ; => 10
(reduce #'max '(3 9 2))     ; => 9
```

The steps for the first line:

```text
(+ 1 2)   => 3
(+ 3 3)   => 6
(+ 6 4)   => 10
```

The first argument of each call is the result so far, the second is the next element. That's the accumulator from Chapter 8, with `reduce` doing the walk.

=== Starting value: `:initial-value`

`:initial-value` gives `reduce` a starting point. The first call combines it with the first element:

```lisp
(reduce #'+ '(1 2 3) :initial-value 100)   ; => 106
```

It matters most for short lists. With one element, `reduce` returns that element without calling the function. With no elements, it calls the function with #emph[no arguments]:

```lisp
(reduce #'+ '(7))     ; => 7
(reduce #'+ '())      ; => 0, because (+) is 0
(reduce #'max '())    ; error: invalid number of arguments: 0
```

`(+)` with no arguments is `0` and `(*)` is `1`, so those two are safe. `max` needs at least one number. When the list may be empty, give a starting value, and `reduce` returns it unchanged:

```lisp
(reduce #'max '() :initial-value 0)        ; => 0
```

With a starting value of `nil` and a `lambda`, `reduce` can build a list. This is `my-reverse` from Exercise 8.4:

```lisp
(reduce (lambda (acc x) (cons x acc))
        '(1 2 3)
        :initial-value nil)
;; => (3 2 1)
```

=== Other keywords: `:from-end` and `:key`

`:from-end t` combines from right to left. With `#'list` as the function you can see the grouping:

```lisp
(reduce #'list '(1 2 3))               ; => ((1 2) 3)
(reduce #'list '(1 2 3) :from-end t)   ; => (1 (2 3))
```

With `:from-end t`, the element comes first and the result so far second, the reverse of the normal order.

`:key` works as everywhere else:

```lisp
(reduce #'+ '((a . 1) (b . 2) (c . 3)) :key #'cdr)   ; => 6
```

== `sort`

`sort` takes a sequence and a predicate of two arguments. The predicate answers "should the first one come before the second?":

```lisp
(sort (list 3 1 2) #'<)                 ; => (1 2 3)
(sort (list 3 1 2) #'>)                 ; => (3 2 1)
(sort (list "pear" "apple") #'string<)  ; => ("apple" "pear")
```

`:key` sorts by part of each element:

```lisp
(sort (list '(b . 2) '(a . 1) '(c . 3)) #'< :key #'cdr)
;; => ((A . 1) (B . 2) (C . 3))
```

Strings are sequences too. `char<` compares two characters:

```lisp
(sort (copy-seq "hello") #'char<)       ; => "ehllo"
```

=== `sort` destroys its argument

Every function so far in this chapter left its input alone. `sort` is different: it reuses the conses of the list you give it and rearranges them. Afterwards the original variable points at one cons somewhere in the middle of the result:

```lisp
(defparameter *nums* (list 3 1 2))
(list (sort *nums* #'<) *nums*)
;; => ((1 2 3) (3)) in SBCL
```

`*nums*` still points at the cons holding `3`, which is now the last cons of the sorted list. Other implementations may leave something else behind. The rules that follow from this:

- #strong[Always use the value `sort` returns.] To sort a variable, write `(setf *nums* (sort *nums* #'<))`.
- #strong[To keep the original, sort a copy.] `copy-list` makes a new list with the same elements: `(sort (copy-list *nums*) #'<)`. `copy-seq` does the same for any sequence, strings included.
- #strong[Never sort a quoted list.] `'(3 1 2)` written in your code is a constant, and changing a constant has undefined results. That's why the examples above use `(list 3 1 2)`.

A list fresh from `mapcar`, `remove-if` or `list` belongs to nobody else, so sorting it directly is safe.

=== `stable-sort`

When two elements are equal for the predicate, `sort` may put them in either order. `stable-sort` keeps their original order:

```lisp
(stable-sort (list '(ada . 2) '(bob . 1) '(cy . 2)) #'< :key #'cdr)
;; => ((BOB . 1) (ADA . 2) (CY . 2))
```

`ada` stays ahead of `cy` because it was ahead before. `stable-sort` destroys its argument just like `sort`.

== `remove-duplicates` and `subseq`

`remove-duplicates` returns a sequence in which each element appears once. By default it keeps the #emph[last] copy of each; `:from-end t` keeps the first:

```lisp
(remove-duplicates '(a b a c))              ; => (B A C)
(remove-duplicates '(a b a c) :from-end t)  ; => (A B C)
(remove-duplicates "mississippi")           ; => "msip"
```

It accepts `:test` and `:key` too. `subseq`, from Chapter 3, works on lists as well as strings:

```lisp
(subseq '(a b c d) 1 3)    ; => (B C)
```

Most of these functions have a destructive twin, such as `delete` for `remove`. They save memory and come with the same rules as `sort`. This guide uses the safe versions.

== Choosing the right function

#table(
  columns: (4.2fr, 3.8fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([You want], [Use]),
  [A result for every element], [`mapcar`, `map`],
  [Only some elements], [`remove-if-not`, `remove-if`],
  [The first matching element], [`find`, `find-if`],
  [Where it is], [`position`, `position-if`],
  [How many match], [`count`, `count-if`],
  [Yes or no for all or any], [`every`, `some`],
  [One value from all elements], [`reduce`],
  [A new order], [`sort`, `stable-sort`],
  [Each element once], [`remove-duplicates`],
)

Write a recursive function when none of these fits, for example when you walk a tree as in `count-atoms`. These functions walk only the top level of a sequence.

== Common mistakes

=== Ignoring what `sort` returns

```text
(sort *nums* #'<)
*nums*    ; => (3), not the sorted list
```

Store the result: `(setf *nums* (sort *nums* #'<))`.

=== Sorting a quoted list

```text
(sort '(3 1 2) #'<)
```

It may seem to work, but it modifies a constant in your code. Write `(sort (list 3 1 2) #'<)`, or sort a `copy-list`.

=== Mixing up `remove-if` and `remove-if-not`

`remove-if` throws away the matches. If you get exactly the elements you wanted to keep, missing, swap to `remove-if-not`.

=== Finding strings without `:test`

```text
(find "key" '("lamp" "key"))   ; => NIL
```

The default test is `eql`. Add `:test #'string=` or `:test #'equal`.

=== Confusing `:key` and `:test`

```text
(find "key" '("lamp" "key") :key #'string=)
;; error: invalid number of arguments: 1
```

`:key` takes a function of one argument that picks a part of each element. `:test` takes a function of two arguments that compares. `string=` needs two, so it belongs in `:test`.

=== `reduce` on an empty list

`(reduce #'max '())` calls `(max)` and fails. Give an `:initial-value` when the list can be empty.

=== Expecting `remove` to change the variable

Like `mapcar`, `remove` and friends return a new sequence. Store it with `setf` when you need to.

== Project step: shorter item functions

Three functions from Chapter 8 walk the item alist by hand. Each one fits one of this chapter's patterns.

`items-in` keeps the pairs whose place matches, then takes the item from each pair. That's `remove-if-not` followed by `mapcar`:

```lisp
(defun items-in (pairs place)
  "Return the items in the alist PAIRS whose location is PLACE."
  (mapcar #'car
          (remove-if-not (lambda (where) (eq where place))
                         pairs
                         :key #'cdr)))
```

```lisp
(items-in '((lamp . cellar) (key . kitchen) (box . kitchen)) 'kitchen)
;; => (KEY BOX)
```

`set-location` copies every pair, replacing one. That's `mapcar` with a `lambda` that decides, pair by pair:

```lisp
(defun set-location (pairs item place)
  "Return a copy of the alist PAIRS with ITEM moved to PLACE."
  (mapcar (lambda (pair)
            (if (eq (car pair) item)
                (cons item place)
                pair))
          pairs))
```

```lisp
(set-location '((lamp . cellar) (key . kitchen)) 'key 'player)
;; => ((LAMP . CELLAR) (KEY . PLAYER))
```

`items-here`, `take`, `drop`, `loot` and `inventory` call these two by name, so they use the new versions without any change.

One improvement while you're here: list the inventory in alphabetical order. `items-here` returns a fresh list built by `mapcar`, so sorting it directly is safe:

```lisp
(defun inventory ()
  "Describe what the player is carrying, in alphabetical order."
  (let ((carried (items-here 'player)))
    (if (null carried)
        "You are carrying nothing."
        (concatenate 'string
                     "You are carrying: "
                     (item-names (sort carried #'string<
                                       :key #'symbol-name))
                     "."))))
```

Check it. The test moves two items straight into the player's hands with `set-location`, so you don't have to walk around:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *item-locations* (set-location *item-locations* 'lamp 'player))
(setf *item-locations* (set-location *item-locations* 'key 'player))
(inventory)
;; => "You are carrying: key and lamp."
```

Without the `sort`, the reply would be `"key and lamp"` the other way round, following the order of the alist. The `defparameter` alist is quoted, but nothing here sorts or changes it: `set-location` builds a new list each time.

== Exercises

#exercise("10.1")[
  Predict the result of each line, then check:

  ```text
  (remove-if-not #'evenp '(5 6 7 8))
  (find-if #'numberp '(a b 3 c 4))
  (count-if #'symbolp '(a 1 b 2 c))
  (position #\n "banana")
  (reduce #'* '(1 2 3 4))
  (every #'symbolp '())
  (remove-duplicates '(1 2 1 3 2))
  ```

]

#exercise("10.2")[
  Rewrite each of these Chapter 8 functions with a one-line body, using this chapter's functions: `my-sum` (8.2), `my-find` (8.5), `all-positive-p` and `my-reverse` (8.4). Name them `sum2`, `find2`, `all-positive2-p` and `reverse2` so they don't replace the originals.

]

#exercise("10.3")[
  Use `remove-if` to drop every string shorter than four characters from `'("a" "lisp" "is" "great")`.

]

#exercise("10.4")[
  Given:

  ```lisp
  (defparameter *scores* '((ada . 90) (alan . 72) (grace . 85)))
  ```

  Write one expression for each:

  + The alist sorted from the highest score to the lowest, leaving `*scores*` untouched.
  + The first pair with a score below 80.
  + The total of all scores.

]

#exercise("10.5")[
  Write `my-remove-if` recursively, using `funcall`. It takes a predicate and a list.

]

#exercise("10.6")[
  Write `count-vowels`, which counts the vowels a, e, i, o and u in a string, upper or lower case. `(count-vowels "Common Lisp")` gives `3`. Hint: `find` can look for a character in the string `"aeiou"`.

]

#exercise("10.7")[
  Predict `T` or `NIL` for each, then check:

  ```text
  (eql 2 2)
  (eql 2 2.0)
  (equal "a" "a")
  (equal '(1 (2)) '(1 (2)))
  (equalp "Lisp" "LISP")
  (eql (list 1) (list 1))
  ```

]

#exercise("10.8")[
  Each line below is wrong. Say what's wrong, then fix it.

  ```text
  (sort '(3 1 2) #'<)

  (reduce #'max '())

  (find "b" '("a" "b"))

  (remove-if #'evenp *numbers*)   ; meant to remove the even numbers
                                  ; from *numbers* for good
  ```

]

#exercise("10.9")[
  Use `reduce` to find the longest string in `'("hi" "hello" "hey")`.

]

#exercise("10.10")[
  Write `my-every`, which takes a predicate and a list and works like `every`, using only `some`, `complement` and `not`.

]

#exercise("10.11", project: true)[
  Write `empty-rooms`, which returns the names of the rooms in `*rooms*` that have no items lying in them. Use `mapcar` and `remove-if`.

]

#exercise("10.12", project: true)[
  Change `help` from Exercise 9.11 so that it lists the commands in alphabetical order, each word once, even if a pair was pushed twice.

]

