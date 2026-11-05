#import "../lib.typ": *

= Structures, Hash Tables and Arrays

Lists are flexible, but they have costs. Finding an item in an alist takes a walk through the whole list. Reaching the third field of a room means `third` or `caddr`, and reading `(caddr room)` later tells you nothing about what that slot means. This chapter adds three new data shapes that fix those problems:

- #strong[Structures]: named records with named fields, for data with a fixed shape, such as a room.
- #strong[Hash tables]: look up by key in one step, however many entries.
- #strong[Arrays]: fixed-length indexed collections, faster than lists.

== Structures: `defstruct`

`defstruct` defines a new kind of record:

```lisp
(shadow "ROOM")   ; ROOM is also a CL function name; take our own symbol
(defstruct room
  name
  description
  exits)
```

That one form does a lot:

- It defines a new type, `room`.
- It defines a constructor, `make-room`.
- It defines an accessor for each field: `room-name`, `room-description`, `room-exits`.
- It defines a predicate, `room-p`.

Each of these exists before you write a line for them. The names are derived from the structure name: `make-room`, `room-name`, `room-p`.

Creating a record uses keyword arguments, one per field:

```lisp
(defparameter *bedroom*
  (make-room :name 'bedroom
             :description "A quiet room with a bed."
             :exits '(south)))
```

Fields you leave out get `nil`.

Reading a field calls the accessor:

```lisp
(room-name *bedroom*)          ; => BEDROOM
(room-description *bedroom*)   ; => "A quiet room with a bed."
```

Changing a field uses `setf` on the accessor:

```lisp
(setf (room-exits *bedroom*) '(north south))
(room-exits *bedroom*)         ; => (NORTH SOUTH)
```

This is the same `setf` expansion as `(setf (car ...))` from Chapter 7: `setf` knows how to assign to any accessor.

`room-p` tells you whether a value is a room:

```lisp
(list (room-p *bedroom*) (room-p 'bedroom))   ; => (T NIL)
```

=== Printing and comparing

`defstruct` has options. The two most useful go right after the name:

```lisp
(defstruct (room (:print-function print-room))
  name
  description
  exits)
```

By default a structure prints unreadably, like `#S(ROOM :NAME BEDROOM :DESCRIPTION ...)`, which is fine. A `:print-function` makes it print your way:

```lisp
(defun print-room (room stream depth)
  (declare (ignore depth))
  (format stream "<room ~(~A~)>" (room-name room)))

(print *bedroom*)   ; => <room bedroom>
```

The print function receives the value, the stream to print on, and the current print depth, which you can usually ignore — hence the `declare` line, which tells the compiler the third parameter is deliberately unused. The body calls `format` with a stream as destination — the third destination from Chapter 12, put to work.

Because `print-room` mentions `room-name`, and `room-name` is only created by the `defstruct`, SBCL warns "undefined function ROOM-NAME" when it compiles `print-room` before the structure exists. The warning is harmless: `print-room` is only #strong[called] when a room is printed, which happens after `defstruct` has run. If you find the warning noisy, put the `defstruct` first and the `print-room` second — then re-run the `defstruct` with `:print-function` to install the printer.

The `:type` option is a bigger change; skip it. But `:named` and the comparison options matter less than a simpler rule: to compare two structures field by field, use `equalp`, which (Chapter 10) compares structures by their contents:

```lisp
(equalp (make-room :name 'a) (make-room :name 'a))   ; => T
(eq (make-room :name 'a) (make-room :name 'a))       ; => NIL
```

`eq` asks whether they are the same object, and each `make-room` call builds a new one.

=== Default values

A field can have a default, given as a slot option:

```lisp
(defstruct (item (:print-function print-item))
  (name 'thing)
  (weight 1))
```

```lisp
(item-name (make-item))   ; => THING
```

=== Why structures instead of lists

The rooms of the game are alists of fields, or lists reached with `third` and `caddr`. Structures replace both with names:

#[
  #set par(justify: false)
  #table(
    columns: (4.4fr, 3.6fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([List version], [Structure version]),
    [`(third room)`], [`(room-description room)`],
    [Comments to remember the order], [The field names say it],
    [One wrong `cadr` and data is misread], [The accessor checks the type],
  )
]

When data has a fixed shape that you'll never change at runtime, a structure is the natural home for it.

== Hash tables

A hash table stores key-value pairs and finds any pair in roughly one step, by computing where the key lives. The alist walk of `assoc` is linear: twice the pairs, twice the work. A hash table isn't.

```lisp
(defparameter *caps* (make-hash-table))

(setf (gethash 'one *caps*) 1)
(setf (gethash 'two *caps*) 2)

(gethash 'two *caps*)        ; => 2, and T
```

`make-hash-table` makes one, `gethash` reads and (with `setf`) writes. Reading a missing key returns `nil`, but the REPL shows two values:

```text
NIL, T      ← the value, and "was it found?"
NIL, NIL
```

`gethash` returns #emph[two] values: the value, and a flag saying whether the key was there. That flag matters when `nil` is a legitimate stored value:

```lisp
(setf (gethash 'nothing *caps*) nil)

(multiple-value-list (gethash 'nothing *caps*))  ; => (NIL T)
(multiple-value-list (gethash 'absent *caps*))   ; => (NIL NIL)
```

`multiple-value-list` catches all the values a form returns, as a list. Multiple values are the subject of the next section.

`gethash` also takes a default, returned when the key is absent:

```lisp
(gethash 'absent *caps* 0)   ; => 0
```

=== Iterating: `maphash` and `loop`

`maphash` calls a function of two arguments, key and value, on every entry. The order is unspecified:

```lisp
(maphash (lambda (k v) (format t "~A -> ~D~%" k v)) *caps*)
```

`loop` can walk a hash table too:

```lisp
(loop for k being the hash-keys of *caps* collect k)
(loop for v being the hash-values of *caps* sum v)
```

=== Removing: `remhash` and `clrhash`

```lisp
(remhash 'one *caps*)   ; => T, it was there
(clrhash *caps*)        ; empties the whole table
```

=== Keys and tests

`make-hash-table` takes a `:test` argument. The default is `eq`, which suits symbol keys — the game's room and item names. For string keys you must ask for `equal`, or the same string spelled twice counts as two different keys:

```lisp
(defparameter *ages* (make-hash-table :test #'equal))

(setf (gethash "ada" *ages*) 36)

(gethash "ada" *ages*)   ; => 36, T
```

Only `eq`, `eql`, `equal` and `equalp` are valid tests. Numbers as keys need `(make-hash-table :test #'eql)`; `eq` on numbers is unsafe (Chapter 10).

=== Hash table vs alist

#[
  #set par(justify: false)
  #table(
    columns: (3.2fr, 2.4fr, 2.5fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([], [Alist], [Hash table]),
    [Lookup], [Walk, slow on big lists], [One step],
    [Insert at the front], [`push`, fast], [`setf gethash`, fast],
    [Keep an order], [Yes], [No, order is unspecified],
    [Readable in your source], [Yes, quoted], [No, built at runtime],
    [A key with two values (history)], [Yes], [No, one value per key],
  )
]

Use an alist for small tables you want to read in your code, a hash table for lookups that grow, and switch when an alist starts to feel slow. The game's tables stay alists: they are small, and being visible in the source has been worth more than speed.

== Arrays

An array stores elements by index. `make-array` makes one:

```lisp
(defparameter *a* (make-array 3 :initial-element 0))
```

Read and write with `aref`, whose indexes count from zero like `nth`'s:

```lisp
(aref *a* 0)          ; => 0
(setf (aref *a* 1) 42)
*a*                   ; => #(0 42 0)
```

`#(...)` is how an array prints. Like `#'` and `#\`, the `#` signals "not an ordinary list".

`length` works on arrays too. `svref` is a faster `aref` for simple arrays such as this one, and `vector` builds one from elements:

```lisp
(vector 'a 'b 'c)     ; => #(A B C)
```

A one-dimensional array is called a #emph[vector]. Strings are vectors of characters — which is why `(length "abc")` and `(aref "abc" 1)` work:

```lisp
(aref "abc" 1)        ; => #\b
```

Arrays have a fixed size. An array of 3 stays 3; to grow, make a bigger one and copy, or use `adjustable-array-p` territory, which this guide leaves for later reading. Lists and vectors cover different needs:

#[
  #set par(justify: false)
  #table(
    columns: (3.3fr, 2.0fr, 2.7fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([], [List], [Vector]),
    [Grow at the front], [`push`, fast], [No],
    [Reach element `n`], [Walk, `nth`], [One step, `aref`],
    [Fixed or growing], [Grows], [Fixed],
    [Printed as], [`(...)`], [`#(...)`],
  )
]

Reach `push` for collections that grow; `aref` for collections you index by number.

== Multiple values

`gethash` returned two values. Any function can: `values` returns several:

```lisp
(defun divide (a b)
  "Return the quotient and remainder of A divided by B."
  (values (floor a b) (mod a b)))

(divide 17 5)        ; REPL shows: 3, 2
```

In ordinary code, a form with multiple values behaves as its first value. `(list (divide 17 5))` gives `(3)`. To catch the rest, `multiple-value-bind` binds them to names:

```lisp
(multiple-value-bind (q r) (divide 17 5)
  (list q r))          ; => (3 2)
```

`floor` itself returns two values — the quotient and the remainder — which is why `divide` above works without naming `mod` twice. Other functions that return extra values: `gethash`, `floor`, `truncate` and `round`.

Common Lisp's `values` is a quiet feature: you can ignore it everywhere and catch it when you need it. Java needed a whole class or an out-parameter to return two things; here it's a `values` form and one binding form.

== Common mistakes

=== Forgetting the `make-` name

`defstruct room` creates `make-room`, not `make-<room>` or `new-room`. The constructor is always `make-` plus the structure name.

=== `:test` on the wrong hash table

```text
(defparameter *t* (make-hash-table))
(setf (gethash "a" *t*) 1)
(gethash "a" *t*)     ; => NIL, NIL
```

The default test is `eq`, and two `"a"` strings are different objects. Declare `:test #'equal` when the keys are strings.

=== Treating a hash table like an alist

`assoc` doesn't work on hash tables: `(assoc 'one *caps*)` fails, because a hash table isn't a list. Its walk is `maphash` or the `loop for ... being` form.

=== `aref` on a list, `nth` on an array

```text
(aref '(a b c) 1)   ; error: The value (A B C) is not of type VECTOR
(nth 1 (vector 'a 'b 'c))   ; error, a vector is not a list
```

Each shape has its own accessor.

=== Expecting hash-table order

`maphash` and the `loop` walk may present entries in any order. If you need an order, collect the keys and sort them.

=== Ignoring the second value of `gethash`

`(gethash key table)` returning `nil` means either "the value is `nil`" or "the key is absent". When `nil` can be stored, bind both values with `multiple-value-bind`.

== Project step: rooms as structures

The rooms of the game become structures. This is the biggest single change to the project so far, and it pays off immediately: every function that reached into a room with `second` or `third` now reads by name.

First the structure, with a print function so rooms read well:

```lisp
(defun print-room (room stream depth)
  (declare (ignore depth))
  (format stream "<room ~(~A~)>" (room-name room)))

(defstruct (room (:print-function print-room))
  name
  description
  exits)
```

If you defined `room` in an earlier experiment, redefine it now with this definition, so the accessors match. SBCL warns "undefined function ROOM-NAME" while compiling `print-room`, because the accessor doesn't exist yet. The warning is harmless: `print-room` is only #strong[called] when a room is printed, which is after `defstruct` has run.

Now the five rooms, with the same topology as before, built with `make-room`:

```lisp
(defparameter *rooms*
  (list
   (make-room :name 'bedroom
              :description "A small bedroom with an unmade bed."
              :exits '(hallway))
   (make-room :name 'hallway
              :description "A narrow hallway with creaky floorboards."
              :exits '(bedroom kitchen))
   (make-room :name 'kitchen
              :description "A warm kitchen that smells of bread."
              :exits '(hallway garden cellar))
   (make-room :name 'garden
              :description "An overgrown garden."
              :exits '(kitchen))
   (make-room :name 'cellar
              :description "A damp cellar. Something drips in the dark."
              :exits '(kitchen))))
```

The old `*rooms*` held lists; this holds structures. Every function that reads a room keeps working, because they all go through `room-name`, `room-description` and `room-exits` — and those are now the structure's accessors, generated by `defstruct`, replacing the Chapter 5 functions of the same names.

`find-room` needs one change: `assoc` walked an alist, and `*rooms*` is now a plain list of structures. Chapter 10's `find` with `:key` fits exactly:

```lisp
(defun find-room (name)
  "Return the room whose name is NAME, or NIL if there is none."
  (find name *rooms* :key #'room-name))
```

`go-to`, `look` and the rest call `find-room`, so they need nothing. Check the whole chain:

```lisp
(list (find-room 'kitchen)
      (room-exits (find-room 'kitchen))
      (setf *current-room* (find-room 'hallway))
      (go-to 'kitchen)
      (look))
```

Expected: the kitchen structure (printed as `<room kitchen>`), the list of exits, then the go-to message and look description for the kitchen.

One new ability that structures make natural: a room can hold more than the old shape allowed. Redefine the structure with a `locked` field defaulting to `nil`, then set it on the garden:

```lisp
(defstruct (room (:print-function print-room))
  name
  description
  exits
  (locked nil))

(setf (room-locked (find-room 'garden)) t)

(room-locked (find-room 'garden))   ; => T
```

SBCL warns about redefining the structure; that's expected. Every existing room still works — the new field defaults to `nil` for the four unlocked rooms, and `setf` on the accessor sets it for the garden. Chapter 6's hard-coded locked-garden logic can now ask the room itself; the exercises do that.

== Exercises

#exercise("13.1")[
  Define `defstruct book` with fields `title`, `author` and `(year nil)`. Create one with `make-book`, read each field, set `year` with `setf`, and show that `book-p` accepts your book and rejects a symbol.

]

#exercise("13.2")[
  Predict the result of each line, then check:

  ```text
  (aref (vector 10 20 30) 2)
  (length (vector 'a 'b))
  (aref "lisp" 0)
  (multiple-value-list (floor 17 5))
  (multiple-value-list (gethash 'x (make-hash-table)))
  ```

]

#exercise("13.3")[
  Build a hash table `*prices*` with `:test #'equal`, keyed by strings, holding three items and prices. Then write `total`, which takes a list of item names and adds up their prices with `maphash` — or, more simply, with `reduce` and `gethash`.

]

#exercise("13.4")[
  Write `hash-keys`, which returns the keys of a hash table as a list, using `loop`. Then sort them, since hash-table order is unspecified.

]

#exercise("13.5")[
  Each line below is wrong. Say what's wrong, then fix it.

  ```text
  (assoc 'one *caps*)

  (aref '(a b c) 1)

  (defparameter *t* (make-hash-table))
  (setf (gethash "a" *t*) 1)
  (gethash "a" *t*)

  (make-room 'kitchen "desc" '(west))   ; wrong call style
  ```

]

#exercise("13.6")[
  Write `oldest`, which takes a hash table mapping name symbols to ages and returns the name of the oldest person, using `loop for key being the hash-keys`, with `maximize` on the values — or a `let` that keeps the best so far.

]

#exercise("13.7")[
  Predict `T` or `NIL`, then check:

  ```text
  (equalp (make-room :name 'a :exits '(n)) (make-room :name 'a :exits '(n)))
  (eq (make-room :name 'a) (make-room :name 'a))
  (room-p (make-room))
  (eql 1.0 1)
  ```

]

#exercise("13.8")[
  Write `invert`, which takes a hash table and returns a new one with keys and values swapped. Assume values are unique and symbols.

]

#exercise("13.9", project: true)[
  Change `go-to` so that it checks `room-locked`: when the destination has `room-locked` true, reply `"The garden is locked."` and stay where you are. The hard-coded `eq` test on the garden's name goes away.

]

#exercise("13.10", project: true)[
  Write `locked-rooms`, which returns the names of all locked rooms, using `remove-if-not` over `*rooms*`.

]

#exercise("13.11", project: true)[
  Give rooms an `items` field, defaulting to `nil`, and write `take-struct` and `drop-struct`, which move item symbols between the current room's `items` field and a list `*carrying*`. Compare the feel of this with the alist version: which functions became simpler, and which became longer? Answer in one paragraph of prose.

]

