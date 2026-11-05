#import "../lib.typ": *

= Cons Cells and List Structure

== `cons`: adding to the front

```lisp
(cons 1 '(2 3))        ; => (1 2 3)
(cons 'a '(b c))       ; => (A B C)
(cons 'a nil)          ; => (A)
```

`cons` takes a value and a list, and returns a new list with the value added at the front. The original list is not changed.

That sounds like a small convenience. It's actually the whole story. Every list is built from `cons`, and only from `cons`.

== The cons cell

`cons` makes one small object called a #emph[cons cell], or just a #emph[cons]. A cons has exactly two parts:

- the #strong[car], its first part,
- the #strong[cdr] (say "could-er"), its second part.

Draw a cons as a box with two halves:

```text
(cons 'a 'b)

+---+---+
| A | B |
+---+---+
 car cdr
```

```lisp
(car (cons 'a 'b))     ; => A
(cdr (cons 'a 'b))     ; => B
```

The names come from the IBM 704 computer that the first Lisp ran on, in 1958: "Contents of the Address part of the Register" and "Contents of the Decrement part of the Register". They mean nothing today, but you'll see them everywhere in Lisp code, so learn to read them.

== A list is a chain of conses

Here is how `(1 2 3)` is really stored:

```text
+---+---+   +---+---+   +---+---+
| 1 | *-+-->| 2 | *-+-->| 3 |NIL|
+---+---+   +---+---+   +---+---+
```

Three conses. Each car holds an element. Each cdr points to the next cons. The last cdr is `nil`, which marks the end.

You can build it yourself:

```lisp
(cons 1 (cons 2 (cons 3 nil)))   ; => (1 2 3)
```

Read it from the inside out: `(cons 3 nil)` is `(3)`, consing `2` on the front gives `(2 3)`, and consing `1` gives `(1 2 3)`.

If you know Java's `LinkedList`: a cons is a node, the car is the value, and the cdr is the `next` pointer. Lisp just shows you the nodes directly.

This explains several things from Part I:

- #strong[`first` is `car` and `rest` is `cdr`.] `first` takes the car of the first cons. `rest` takes its cdr, which is the rest of the chain. The two pairs of names do exactly the same thing. `first` and `rest` read better when you think of a list. `car` and `cdr` read better when you think of a single cons.
- #strong[`nil` is both an atom and a list.] `nil` isn't a cons, so it's an atom. It's what every chain ends with, so it's the empty list.
- #strong[`last` returns a list.] `last` gives you the last #emph[cons] of the chain. A cons whose cdr is `nil` prints as a one-element list, so `(last '(1 2 3))` shows `(3)`.

== Lists inside lists

A car can point to another list:

```text
((A B) C)

+---+---+   +---+---+
| * | *-+-->| C |NIL|
+-+-+---+   +---+---+
  |
  v
+---+---+   +---+---+
| A | *-+-->| B |NIL|
+---+---+   +---+---+
```

The top row is the outer list, with two elements. The first element is itself a chain of two conses.

```lisp
(cons (list 'a 'b) '(c))   ; => ((A B) C)
```

== Dotted pairs

What if the cdr of a cons isn't a list?

```lisp
(cons 1 2)             ; => (1 . 2)
```

Lisp prints a dot between the car and the cdr. This is called a #emph[dotted pair]. It's just one cons with two values in it.

Compare these carefully:

```lisp
(list (cons 1 2)       ; one cons: car 1, cdr 2
      (list 1 2)       ; two conses: car 1, then car 2, then NIL
      (cons 1 '(2)))   ; same as (list 1 2)
;; => ((1 . 2) (1 2) (1 2))
```

A chain that ends in something other than `nil` is called an #emph[improper list]:

```lisp
(cons 1 (cons 2 3))    ; => (1 2 . 3)
```

A chain that ends in `nil` is a #emph[proper list]. Every list you've used so far was proper. Most list functions expect proper lists. `(length '(1 2 . 3))` is an error.

Dotted pairs are useful on their own, as a cheap way to keep two values together. You'll use them later in this chapter.

You can also #emph[type] a dotted pair. Put spaces around the dot:

```lisp
'(key . bedroom)       ; => (KEY . BEDROOM)
(cdr '(key . bedroom)) ; => BEDROOM
```

== Testing for conses

```lisp
(consp '(1 2))         ; => T
(consp '(1 . 2))       ; => T
(consp nil)            ; => NIL
(listp nil)            ; => T
```

`consp` asks "is it a cons?". `listp` asks "is it a cons or `nil`?". The only difference is `nil`: the empty list is a list, but it isn't a cons. Chapter 8 depends on this difference.

== Shortcuts: `cadr`, `cddr` and friends

Taking the car of the cdr is so common that it has its own name:

```lisp
(car (cdr '(a b c)))   ; => B
(cadr '(a b c))        ; => B
```

The letters between `c` and `r` say what to do, read from #strong[right to left]. `cadr` is "cdr, then car". Some more:

#table(
  columns: (1.1fr, 3.2fr, 2.3fr, 1.3fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Name], [Means], [On `(a b c d)`], [Same as]),
  [`cadr`], [car of cdr], [`B`], [`second`],
  [`cddr`], [cdr of cdr], [`(C D)`], [],
  [`caddr`], [car of cdr of cdr], [`C`], [`third`],
  [`caar`], [car of car], [(error here)], [],
  [`cdar`], [cdr of car], [(error here)], [],
)

`caar` and `cdar` need a list whose first element is itself a cons, such as `((a . 1) (b . 2))`: `caar` gives `A`, `cdar` gives `1`.

Use `second` and `third` when you mean list positions. Use the `c...r` names when you're working with conses, or when reading older code. Combinations go up to four letters, such as `cadddr`, but anything beyond three is hard to read.

`nthcdr` skips a number of conses:

```lisp
(nthcdr 2 '(a b c d))  ; => (C D)
```

== Sharing structure

```lisp
(defparameter *tail* '(2 3))
(defparameter *whole* (cons 1 *tail*))
*whole*                ; => (1 2 3)
```

`cons` didn't copy `*tail*`. The new cons points straight at it:

```text
*whole*      *tail*
   |            |
   v            v
+---+---+   +---+---+   +---+---+
| 1 | *-+-->| 2 | *-+-->| 3 |NIL|
+---+---+   +---+---+   +---+---+
```

That's why adding to the front of a list is fast, no matter how long the list is. It takes one new cons.

Adding to the #strong[end] is different. `append` has to copy every cons of the lists before the last one, because their final cdrs must change to point onward. On a long list that's slow. Lisp programmers build lists from the front and, when they need the other order, call `reverse` once at the end.

Sharing is safe as long as nothing changes the shared conses. Everything in this guide so far makes new conses instead of changing old ones, so you can share freely.

== `push` and `pop`: a list in a variable

`push` conses a value onto the front of the list stored in a variable, and stores the new list back in the variable:

```lisp
(defparameter *stack* nil)
(push 'a *stack*)      ; => (A)
(push 'b *stack*)      ; => (B A)
(push 'c *stack*)      ; => (C B A)
*stack*                ; => (C B A)
```

`(push 'a *stack*)` does the same as `(setf *stack* (cons 'a *stack*))`. It's shorter and says what you mean.

`pop` does the opposite. It returns the first element and stores the rest back in the variable:

```lisp
(pop *stack*)          ; => C
*stack*                ; => (B A)
```

Popping an empty list returns `nil` and leaves the variable as `nil`.

The names come from a #emph[stack] of plates: you add to the top and take from the top. Java's `Deque` has `push` and `pop` methods that work the same way.

=== Building a list in order

`push` adds to the front, so the list comes out backwards. Build it with `push`, then `reverse` it once at the end:

```lisp
(let ((result nil))
  (push 1 result)
  (push 2 result)
  (push 3 result)
  (reverse result))    ; => (1 2 3)
```

`push` works on local variables too. This "push, then reverse" pattern is one you'll use often from Chapter 8 onwards.

=== `push` changes the variable, not the list

`push` never changes an existing cons. It makes a new one and points the variable at it. Other variables that held the old list still hold the old list:

```lisp
(defparameter *original* '(1 2))
(defparameter *copy* *original*)
(push 0 *original*)
(list *original* *copy*)   ; => ((0 1 2) (1 2))
```

`*copy*` didn't change, because nothing touched the conses it points to.

== Association lists

A list of dotted pairs makes a simple lookup table. Each pair holds a #emph[key] in its car and a #emph[value] in its cdr:

```lisp
(defparameter *colours*
  '((apple . red)
    (banana . yellow)
    (grape . purple)))
```

This is called an #emph[association list], or #emph[alist]. `assoc` finds the pair for a key:

```lisp
(assoc 'banana *colours*)        ; => (BANANA . YELLOW)
(cdr (assoc 'banana *colours*))  ; => YELLOW
(assoc 'kiwi *colours*)          ; => NIL
```

`assoc` returns the whole pair, not the value. Take its `cdr` to get the value.

When the key is missing, `assoc` returns `nil`, and `(cdr nil)` is also `nil`. So `(cdr (assoc 'kiwi *colours*))` is `nil`, not an error. Combine it with `or` for a default:

```lisp
(or (cdr (assoc 'kiwi *colours*)) 'unknown)   ; => UNKNOWN
```

In Java you'd use a `HashMap` for this. For a few dozen entries an alist is simpler, and you can read it at a glance. Part III covers hash tables, for when you have many entries.

=== Newer entries hide older ones

`assoc` returns the #strong[first] pair whose key matches. So pushing a new pair onto the front changes the answer, without removing the old pair:

```lisp
(push '(apple . green) *colours*)
(cdr (assoc 'apple *colours*))   ; => GREEN
*colours*
;; => ((APPLE . GREEN) (APPLE . RED) (BANANA . YELLOW) (GRAPE . PURPLE))
```

The old `(APPLE . RED)` is still there, hidden behind the new one. This is a cheap way to update an alist, and the project uses it below.

=== The value can be anything

The cdr of a pair can be a list. Look at what happens then:

```lisp
(cons 'kitchen '("A warm kitchen." (hallway garden)))
;; => (KITCHEN "A warm kitchen." (HALLWAY GARDEN))
```

A pair whose cdr is a list prints as an ordinary list. The other way round: any list is a pair whose car is its first element. So a list of lists is also an alist, with each list's first element as its key:

```lisp
(assoc 'garden
       '((kitchen "A warm kitchen." (hallway garden))
         (garden "An overgrown garden." (kitchen))))
;; => (GARDEN "An overgrown garden." (KITCHEN))
```

Your rooms already have this shape. The project step uses it.

=== What `assoc` can compare

`assoc` compares keys the same way `member` does. It works for symbols, numbers and characters, but not for strings. Use symbols as keys. Part IV shows how to make it work with strings.

== Common mistakes

- #strong[Using `cons` to join two lists:] `(cons '(1 2) '(3 4))` gives `((1 2) 3 4)`. `cons` adds #emph[one] element to the front, and here the element is the list `(1 2)`. To join lists, use `append`.
- #strong[Putting the list first:] `(cons '(2 3) 1)` gives `((2 3) . 1)`. The element comes first, the list second: `(cons 1 '(2 3))`.
- #strong[Making a dotted pair by accident:] `(cons 1 2)` is `(1 . 2)`, not `(1 2)`. For a two-element list, write `(list 1 2)`.
- #strong[Expecting `cons` or `push` to add at the end:] both add at the front. Build from the front and `reverse` at the end.
- #strong[Using `push` without a variable:] `(push 'x '(a b))` is an error, because `push` needs somewhere to store the new list. Use `cons`, or put the list in a variable first.
- #strong[Reading `cadr` left to right:] the letters run right to left. `cadr` is "cdr first, then car", which is `second`.
- #strong[Expecting `assoc` to return the value:] it returns the pair. Use `(cdr (assoc key alist))`.
- #strong[String keys in an alist:] `(assoc "b" '(("a" . 1) ("b" . 2)))` returns `nil`. Use symbols as keys.
- #strong[Calling `length` on an improper list:] `(length '(1 2 . 3))` gives an error saying a value is not of type `LIST`. Check how the list was built: somewhere a `cons` got a non-list as its second argument.

== Project step: all rooms in one list

Your rooms are lists whose first element is the room name. Put them all in one list and you have an alist of rooms. This also adds a new room, the cellar, below the kitchen:

```lisp
(defparameter *rooms*
  '((bedroom "A small bedroom with an unmade bed." (hallway))
    (hallway "A narrow hallway with creaky floorboards." (bedroom kitchen))
    (kitchen "A warm kitchen that smells of bread." (hallway garden cellar))
    (garden "An overgrown garden." (kitchen))
    (cellar "A damp cellar. Something drips in the dark." (kitchen))))
```

Now `find-room` becomes one line. Run this to replace the Chapter 6 version:

```lisp
(defun find-room (name)
  "Return the room whose name is NAME, or NIL if there is none."
  (assoc name *rooms*))
```

Your `go-to` from Chapter 6 calls `find-room`, so it now uses the new list without any change. This is what the accessors and small functions from Chapter 5 were for: you changed how rooms are stored, and only one function had to change.

There's one catch. `*current-room*` still holds the list from the old `*bedroom*` variable, whose exits don't know about the cellar. Point it at the room from the new list:

```lisp
(setf *current-room* (find-room 'bedroom))
(list (go-to 'hallway)
      (go-to 'kitchen)
      (go-to 'cellar))
```

```text
("You are in the Hallway. A narrow hallway with creaky floorboards."
 "You are in the Kitchen. A warm kitchen that smells of bread."
 "You are in the Cellar. A damp cellar. Something drips in the dark.")
```

If you kept the locked-garden `go-to` from Exercise 6.10, moves into the garden still need `*garden-unlocked*` to be `t`. Everything else works the same.

The old variables `*bedroom*`, `*hallway*` and so on still exist, but the game no longer uses them. From now on, rooms live in `*rooms*`.

=== Items

A game needs things to pick up. A second alist says where each item is. The key is the item, the value is the name of the room it's in:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))

(defun item-location (item)
  "Return the name of the room ITEM is in, or PLAYER if it is carried."
  (cdr (assoc item *item-locations*)))

(defun item-name (item)
  "Return ITEM as a lower-case string, for messages."
  (string-downcase (symbol-name item)))
```

```lisp
(item-location 'key)   ; => KITCHEN
(item-name 'key)       ; => "key"
```

When the player takes an item, its location becomes the symbol `player`. Instead of changing the old pair, push a new one on the front. `assoc` finds the newest pair first, so the old one is hidden:

```lisp
(defun take (item)
  "Pick up ITEM if it is in the current room."
  (cond ((eq (item-location item) 'player)
         "You already have that.")
        ((eq (item-location item) (room-name *current-room*))
         (push (cons item 'player) *item-locations*)
         (concatenate 'string "You take the " (item-name item) "."))
        (t
         "You don't see that here.")))
```

Try it in the kitchen:

```lisp
(setf *current-room* (find-room 'kitchen))
(list (take 'lamp)
      (take 'key)
      (take 'key)
      (item-location 'key))
```

```text
("You don't see that here." "You take the key." "You already have that." PLAYER)
```

The lamp is in the cellar, so the first `take` fails. The key is in the kitchen, so the second works. After that, the key is carried.

Run the block a second time and the first `take 'key` says "You already have that.", because the key is still marked as carried. To start over, re-run the `defparameter` for `*item-locations*`.

The game can't yet list the items in a room, because that means looking at every pair in the alist. Chapter 8 teaches you how to walk through a whole list.

== Exercises

#exercise("7.1")[
  Build each list using only `cons` and `nil`:

  + `(1 2 3)`
  + `(A (B C))`

  Then draw the box diagram for `(A (B C))`, in the style of this chapter.

]

#exercise("7.2")[
  Predict the result of each line, then check:

  ```text
  (cons 'a 'b)
  (cons '(a) '(b))
  (cons nil nil)
  (cdr '(a))
  (car '((x y) z))
  ```

]

#exercise("7.3")[
  Write three expressions:

  + Get `C` from `'(a b c d)` with `caddr`.
  + Get `(C D)` from `'(a b c d)` with `cddr`.
  + Get `1` from `'((a . 1) (b . 2))` with `cdar`.

]

#exercise("7.4")[
  Write a function `swap-pair` that takes a dotted pair and returns a new pair with the car and cdr swapped. `(swap-pair '(1 . 2))` gives `(2 . 1)`.

]

#exercise("7.5")[
  Predict the value `pop` returns and the final value of `*s*`:

  ```text
  (defparameter *s* '(x))
  (push 'y *s*)
  (push 'z *s*)
  (pop *s*)
  ```

]

#exercise("7.6")[
  Make an alist `*capitals*` that maps `tunisia` to `tunis`, `france` to `paris` and `japan` to `tokyo`. Write a function `capital-of` that returns the capital of a country, or `unknown` if the country isn't in the list.

]

#exercise("7.7")[
  Each line has a mistake. Say what's wrong and fix it.

  ```text
  (cons '(1 2) '(3 4))                        ; wanted (1 2 3 4)
  (cdr (assoc "b" '(("a" . 1) ("b" . 2))))    ; wanted 2
  (push 'x '(a b))                            ; wanted (X A B)
  ```

]

#exercise("7.8", project: true)[
  Write `drop`, which takes an item. If the player carries it, the item moves to the current room and `drop` returns a message such as `"You drop the key."`. If not, it returns `"You don't have that."`.

]

#exercise("7.9", project: true)[
  Add a shed reached from the garden. Without retyping `*rooms*`, push two new rooms onto it:

  - a new garden, the same as the old one but with exits `(kitchen shed)`,
  - a shed with the description `"A wooden shed full of old tools."` and the exit `(garden)`.

  Then put the player in the garden and walk into the shed. Why does the new garden replace the old one?

]

