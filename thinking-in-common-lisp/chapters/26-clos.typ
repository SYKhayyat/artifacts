#import "../lib.typ": *

= CLOS

You've built the game with lists, alists, structures and closures. That works at small size, but it has two strains you may have felt: `room-name`, `room-exits` and friends are named by convention (Chapter 13), and every new kind of thing means more parallel functions. The Common Lisp Object System, CLOS, offers a different arrangement: #emph[classes] give data named parts, and #emph[generic functions] give behaviour a way to vary by the data it works on.

CLOS is not a bolted-on layer. It is part of the language standard, written in Lisp, and powerful enough that people have built other object systems on top of it. Two ideas set it apart from Java's model from the start, and the chapter keeps returning to them:

- #emph[Methods belong to generic functions, not to classes.] A class never "owns" a method; a generic function collects methods from wherever they're defined.
- #emph[Methods specialise on all their arguments], not just the first. Java's `this` picks one distinguished argument; CLOS picks among all of them.

The chapter also positions CLOS against the two alternatives you already have: structures (Chapter 13) for internal records, closures (Chapter 25) for small stateful objects. CLOS is the tool for types at the #emph[edges] of your program, where other code adds behaviour and other people extend.

== Classes: `defclass`

A class is defined with `defclass`, and reads like a `defstruct` with ambitions:

```lisp
(defclass thing ()
  ((name :initarg :name
         :reader thing-name)
   (description :initarg :description
                :reader thing-description
                :initform "an ordinary thing"))
  (:documentation "Something the player can carry or examine."))
```

The parts:

- The second slot of `defclass` — here `()` — lists #emph[superclasses]. `thing` has none beyond the default.
- Each slot has a name and #emph[slot options]: `:initarg` names the keyword `make-instance` accepts, `:reader` generates an accessor function, `:initform` gives a default.
- Unlike `defstruct`, nothing is exported or auto-generated beyond what you ask for. `thing-name` exists because you asked.

The class is named `thing`, not `item`, to avoid two collisions with earlier chapters: `item` is a value the game passes around (the symbol `'item` in command arguments), and `item-name` is Chapter 7's function that lowercases a symbol for messages. `thing` has neither conflict.

Instances are made with `make-instance`, and slots are read with the readers:

```lisp
(defparameter *key-thing*
  (make-instance 'thing
                 :name 'key
                 :description "a small brass key"))

(thing-name *key-thing*)          ; => KEY
(thing-description *key-thing*)   ; => "a small brass key"
(thing-description (make-instance 'thing :name 'rock))
;; => "an ordinary thing"
```

`:initform` runs each time an instance is made, so defaults like `:initform (list)` would give each instance its #emph[own] fresh list — the problem `defstruct`'s shared defaults dodge by luck. If you want a default evaluated once for all instances, say so deliberately.

Slots are writable with `:accessor` instead of `:reader`, which generates both the reader and a `setf` place:

```lisp
(defclass door ()
  ((locked :initarg :locked
           :accessor door-locked-p
           :initform t)))

(defparameter *cellar-door* (make-instance 'door))
(door-locked-p *cellar-door*)          ; => T
(setf (door-locked-p *cellar-door*) nil)
(door-locked-p *cellar-door*)          ; => NIL
```

`setf` works on slot accessors with no special form — another place Chapter 4's "setf knows about places" pays off.

`:reader`, `:accessor`, `:initarg` are a lot of typing compared to `defstruct`'s automatic everything. The trade is deliberate: `defstruct` is for internal, implementation-flavoured records, and `defclass` for types with an interface you'd defend. As a rule of thumb: structures for the game's scratch data, classes for the kinds of thing other code will touch.

== Inheritance

The superclass list is where classes build on each other:

```lisp
(defclass container (thing)
  ((contents :initarg :contents
             :accessor contents
             :initform nil)))

(defclass treasure (thing)
  ((value :initarg :value
          :reader value
          :initform 1)))

(defparameter *chest*
  (make-instance 'container
                 :name 'chest
                 :description "a wooden chest."
                 :contents '(gold ring)))

(thing-name *chest*)     ; => CHEST
(contents *chest*)       ; => (GOLD RING)
(typep *chest* 'thing)   ; => T
```

`container` #emph[is a] `thing`: it has `thing`'s slots and readers, plus its own. `typep` asks the class question, and it works for any type you've met — `(typep 3 'integer)` is the same operation.

Multiple inheritance is ordinary in CLOS — a class may list several superclasses — and slot conflicts are resolved by a #emph[class precedence list]: the class itself, then its superclasses left to right, depth-first, deduplicated. You rarely need to compute one by hand, but when two superclasses both define a slot or a method, the precedence list decides whose wins, leftmost first. `class-precedence-list`, called on an instance's class, shows it:

```lisp
(sb-mop:class-precedence-list (class-of *chest*))
;; => (#<STANDARD-CLASS CONTAINER> #<STANDARD-CLASS THING>
;;     #<STANDARD-CLASS STANDARD-OBJECT>
;;     #<STANDARD-CLASS T>)
```

The order: `container` first (most specific), then `thing` (its superclass), then `standard-object` (the default CLOS parent), then `t` (everything). Any method selection walks this list from left to right, most specific first.

== Generic functions and methods

Here is the part that's genuinely different. A #emph[generic function] is a named thing that dispatches to methods:

```lisp
(defgeneric describe-thing (thing)
  (:documentation "Return a sentence describing THING."))
```

`defgeneric` defines the name, the parameter list and the documentation. It has no body. Bodies come from `defmethod`:

```lisp
(defmethod describe-thing ((t2 thing))
  (format nil "You see ~(~A~): ~A."
          (thing-name t2) (thing-description t2)))

(defmethod describe-thing ((c container))
  (format nil "You see ~(~A~): ~A It holds ~{~(~A~)~^, ~}."
          (thing-name c)
          (thing-description c)
          (contents c)))

(defmethod describe-thing ((tr treasure))
  (format nil "You see ~(~A~): ~A It's worth ~D coins."
          (thing-name tr) (thing-description tr) (value tr)))
```

Each `defmethod` adds a method to the same generic function, and the parenthesised parameter `((t2 thing))` says "this method applies when this argument is a `thing`". Calling it picks the most specific method:

```lisp
(list (describe-thing 'table)
      (describe-thing *key-thing*)
      (describe-thing *chest*))
```

Expected: a generic error (no method for symbols — `table` is not a `thing`), the item's description, and the container's listing. Re-run with only the registered things:

```lisp
(list (describe-thing *key-thing*)
      (describe-thing *chest*)
      (describe-thing (make-instance 'treasure
                        :name 'crown
                        :description "a tarnished crown."
                        :value 100)))
```

Expected:

```text
("You see key: a small brass key."
 "You see chest: a wooden chest. It holds gold, ring."
 "You see crown: a tarnished crown. It's worth 100 coins.")
```

Each of the three kinds of thing gets its own method, and the call selects by the argument's class. `container` inherits from `thing`, so a container is also "described by thing" — but the container method is #emph[more specific], so it wins.

Notice what didn't happen: `thing` doesn't "have" a `describe-thing` method. The methods live on `describe-thing`, and `thing` merely appears in one's parameter specialiser. You can add a method for a class you don't own — for `number`, even — from anywhere, and you can add methods to a generic function from any file, at any time, including in the running REPL. Java's visitor pattern exists to work around this restriction; CLOS doesn't have the restriction.

Methods on several arguments — multiple dispatch — follow the same rule, with the combination of all specialisers deciding:

```lisp
(defgeneric combine (a b))

(defmethod combine ((a number) (b number))
  (+ a b))

(defmethod combine ((a string) (b string))
  (concatenate 'string a b))

(defmethod combine ((a number) (b string))
  (format nil "~D~A" a b))

(list (combine 1 2) (combine "a" "b") (combine 3 "x"))
```

Expected: `(3 "ab" "3x")`. No `if` chains checking types; the dispatch table #emph[is] the type logic, and each case is a method you can read and extend alone.

== `call-next-method`

A method can hand work to the next one down the precedence list:

```lisp
(defmethod describe-thing :around ((t2 thing))
  (format nil "~A (a ~(~A~))"
          (call-next-method)
          (class-name (class-of t2))))
```

Method qualifiers such as `:after`, `:before` and `:around` change when a method runs:

- `:before` methods run before the primary method, for setup.
- `:after` methods run after, and #emph[all matching ones] run — they compose rather than choose.
- `:around` wraps everything and calls `call-next-method` to let the rest proceed.

The `:around` method above doesn't replace the primary — it runs first, calls `call-next-method` (which runs the primary chain), and appends the class name. `:before` and `:after` are the Lisp answer to what Java calls `super` calls in constructors: an `initialize-instance :after` method is the standard way to finish setting up an instance:

```lisp
(defmethod initialize-instance :after ((c container) &key)
  (unless (listp (contents c))
    (setf (contents c) (list (contents c)))))
```

This runs whenever any `container` is made, whether or not the caller remembered a `:contents` argument — validation and repair lived in the constructor, now it lives with the class. (If you'd written `(make-instance 'container :contents '(gold))`, no change — listp is true, no wrapping. If you'd written `(make-instance 'container :contents 'gold)`, the :after fires, wraps `gold` into `(gold)`, and `(contents ...)` returns the list.)

== Structures and classes: when to use which

Both give named slots. The honest comparison:

#[
  #set par(justify: false)
  #table(
    columns: (1.9fr, 2.7fr, 3.4fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([], [`defstruct`], [`defclass`]),
    [Accessors], [automatic], [only what you declare],
    [Inheritance], [single superclass], [multiple, with precedence list],
    [Methods that vary], [by `typecase` or `etypecase`], [by `defmethod`],
    [Speed], [usually faster, simpler], [more machinery underneath],
    [Intended for], [internal records], [types with a public interface],
  )
]

The game has used `defstruct` rooms so far, and that's fine — rooms are internal. The `thing` hierarchy above is the kind of thing that benefits from CLOS, because `describe-thing` wants to vary by type.

== CLOS vs closures

Chapter 25 built account and registry objects out of closures. CLOS gives the same patterns a different shape, and choosing between them is a real design question:

#[
  #set par(justify: false)
  #table(
    columns: (2.1fr, 2.6fr, 3.4fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([], [Closures], [CLOS]),
    [State lives in], [`let` bindings], [slots],
    [Behaviour is], [one function, message-dispatched], [one method per generic function],
    [Adding behaviour], [edit the `ecase`], [define a new `defmethod`],
    [Multiple objects], [return more closures], [`make-instance`, many instances],
    [Redefinition while running], [re-define the closure], [re-define the class; instances auto-update],
    [Printing], [wrap the closure], [`print-object`],
    [Inheritance], [compose by hand], [`defclass` superclasses],
  )
]

For a small stateful object with three or four messages, closures are lighter — no class to define, no dispatch overhead. For a type hierarchy, multiple implementations of the same interface, or behaviour that varies by more than one argument, CLOS is the right tool.

The two also compose: a closure can be a slot value, a method can return a closure, an `initialize-instance :after` can capture a closure to use as a default method. The choice isn't exclusive; it's which shape to #emph[lean on] for a given piece.

== Common mistakes

=== Forgetting `(:use :cl)` brings CLOS in, but nothing else does

`defclass`, `defmethod`, `make-instance` are all ordinary `cl` symbols. The mistake is elsewhere: in a file with `(in-package :game)`, a method on `describe-thing` defined in `cl-user` and one defined in `game` are #emph[two different generic functions], because the symbols differ. When methods seem to vanish, check `(symbol-package 'describe-thing)` in both places.

=== Writing methods before the generic function

You can skip `defgeneric` — the first `defmethod` creates the generic function implicitly. But then the parameter list and documentation come from wherever the first method happened to be, and a later `defgeneric` with a different shape is an error. Define `defgeneric` first: it is the interface statement.

=== Expecting slot readers you didn't declare

`make-instance` accepted the `:initarg`, but reading the slot without a `:reader` or `:accessor` fails. CLOS generates nothing you didn't ask for.

=== Specialising on a class that isn't loaded

```text
(defmethod describe-thing ((c container)) ...)
;; "The class CONTAINER is not defined"
```

The class must exist before the method that names it. Load order matters; ASDF's `:serial` from Chapter 16 exists for exactly this.

=== Confusing `typep` on classes with `eq` on symbols

`(typep *chest* 'thing)` asks about the object. `(eq *chest* 'thing)` compares the object to the symbol `thing`, which is `nil`. The quote in `typep` is part of the type notation, not a quoted object comparison.

=== Forgetting `call-next-method` in an `:around`

An `:around` method that doesn't call `call-next-method` suppresses every primary method beneath it — the description comes back as whatever the `:around` alone produced, with no item-specific information. That's occasionally intended; it's almost never what the code's author meant.

== Project step: things in the game

The game's items are just symbols in `*item-locations*` — where each symbol lives. That's enough to move a key from the kitchen to the player's pocket, but not enough to #emph[describe] the key: its weight, its flavour, whether it's fragile. The game has held that information in code, inline in `describe-room-text` and the like. This step gives it a home.

The approach: register each item symbol with a `thing` instance that carries the metadata. The two representations coexist:

- `*item-locations*` — mutable state: which room holds each item.
- `*thing-registry*` — static metadata: what each item #emph[is].

The link between them is the symbol (`'key`, `'chest`, etc.), which appears in both.

```lisp
(defparameter *thing-registry*
  (make-hash-table :test #'eq)
  "Maps item symbols to their THING instances.")

(defun register-thing (sym instance)
  "Associate SYM with INSTANCE in the registry."
  (setf (gethash sym *thing-registry*) instance))

(defun lookup-thing (sym)
  "The THING instance for SYM, or NIL if unregistered."
  (gethash sym *thing-registry*))
```

Now register the game's items:

```lisp
(register-thing 'key
  (make-instance 'thing
                 :name 'key
                 :description "a small brass key"))

(register-thing 'lamp
  (make-instance 'thing
                 :name 'lamp
                 :description "an oil lamp, dusty but intact"))

(register-thing 'chest
  (make-instance 'container
                 :name 'chest
                 :description "a wooden chest."
                 :contents '(crown gem)))

(register-thing 'crown
  (make-instance 'treasure
                 :name 'crown
                 :description "a tarnished crown."
                 :value 100))
```

The `describe-thing` generic now has three methods, one per class, and dispatch is automatic. Add a game command that uses it:

```lisp
(defun examine (sym)
  "Handle (EXAMINE THING): describe THING."
  (let ((instance (lookup-thing sym)))
    (if instance
        (describe-thing instance)
        (format nil "You see nothing special about the ~(~A~)."
                sym))))

(push '(examine . examine) *commands*)
```

Check:

```lisp
(list (run-command '(examine key))
      (run-command '(examine chest))
      (run-command '(examine crown))
      (run-command '(examine sword)))
```

Expected:

```text
("You see key: a small brass key."
 "You see chest: a wooden chest. It holds crown, gem."
 "You see crown: a tarnished crown. It's worth 100 coins."
 "You see nothing special about the sword.")
```

Four commands, four answers, and the middle two came from different methods of the same generic function — `container` and `treasure` dispatch to their own `describe-thing`, while `key` falls back to the `thing` method.

Now the payoff. Add a new kind of thing — a fragile thing, say — with its own method, without touching any existing code:

```lisp
(defclass fragile (thing) ())

(defmethod describe-thing ((f fragile))
  (format nil "~A It looks like it would break if you dropped it."
          (call-next-method)))

(register-thing 'vase
  (make-instance 'fragile
                 :name 'vase
                 :description "a thin porcelain vase."))

(run-command '(examine vase))
```

Expected: "You see vase: a thin porcelain vase. It looks like it would break if you dropped it."

The `fragile` method called `call-next-method` to get the base description and append its own sentence. No existing method was edited, no existing command was told about `fragile`, and the new type works throughout the game's interface immediately. That's what CLOS's open dispatch buys: #emph[extension by addition].

== Exercises

#exercise("26.1")[
  Define a class `lamp` as a subclass of `thing` with a `lit` slot (default `nil`, accessor `lit-p`). Make one instance and check the accessor with `setf`.

]

#exercise("26.2")[
  Predict, then check:

  ```text
  (defclass a () ((x :reader x-of :initform 1)))
  (defclass b (a) ((x :reader x-of :initform 2)))
  (x-of (make-instance 'b))
  ```

  Why is the answer 2? Which rule decides?

]

#exercise("26.3")[
  Write `defgeneric` `empty-thing-p` and two methods: anything returns `nil`; a `container` returns `t` when its `contents` is `nil`. Use `call-next-method` nowhere — explain in a comment why `:before` or `:after` would be wrong tools here.

]

#exercise("26.4")[
  Each snippet below is wrong. Say what's wrong, then fix it.

  ```text
  (defclass potion (thing)
    ((colour :initarg :colour)))

  (defmethod drink ((p potion))
    (thing-colour p))

  (make-instance 'potion :colour 'red)
  ; then:
  (thing-description *potion*)

  (defmethod describe-thing ((i thing)) ...)
  ; defined before (defclass thing ...) in the same file, loaded in order

  (typep 'thing 'thing)
  ```

]

#exercise("26.5")[
  Write `defmethod combine` cases so that `(combine 'a 'b)` gives `(a b)`, `(combine "x" 5)` gives `"x5"`, and any other pair signals an error with a useful message. How many methods did you need, and what does that number tell you about multiple dispatch?

]

#exercise("26.6")[
  Add an `initialize-instance :after` method on `container` that sorts the contents alphabetically when they're given unsorted. Test it by making a `container` with `:contents '(zebra apple)` and reading the slot.

]

#exercise("26.7")[
  Define `defgeneric` `weight`, with `defmethod` on `thing` giving 1 and on `container` giving 1 plus the number of things it holds. Write `total-weight`, which takes a list of item symbols and sums their weights with `lookup-thing` and `reduce`. What happens with an unregistered symbol, and does that suggest where a Chapter 19 `handler-case` belongs?

]

#exercise("26.8", project: true)[
  Write `list-things`, a command that lists every registered thing's name and description, sorted alphabetically. It uses `maphash` or `loop for ... being the hash-keys` to walk the registry. In a comment: what does the class hierarchy buy over storing the description in the symbol's plist (Chapter 23)?

  #strong[item-locations] is an alist (Ch 7)

  #strong[rooms] is a list of room structures (Ch 13)

  #strong[thing-registry] is a hash table mapping symbols to thing instances (Ch 26)

  #strong[commands] is an alist (Ch 9, extended in later chapters)

  #strong[history] is a closure object (Ch 25)

  #strong[save-file] is a parameter

  Chapter 26 exercises 26.1-26.8:

]

