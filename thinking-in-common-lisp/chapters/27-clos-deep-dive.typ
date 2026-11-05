#import "../lib.typ": *

= CLOS Deep Dive

Chapter 26 gave you working CLOS: `defclass`, slots with `:initarg`, `:reader`, `:accessor`, `:initform`, `defmethod`, `call-next-method`, `:before`\/`:after`\/`:around`, and `initialize-instance :after` as the constructor hook. This chapter goes the rest of the way — the parts of CLOS that distinguish reading other people's code from writing serious code: class precedence lists, `shared-initialize`, changing an object's class, method combination beyond `:around`, and what happens when no method matches.

== Multiple inheritance and the class precedence list

A class can have several direct superclasses:

```lisp
(defclass thing () ())
(defclass container () ())
(defclass portable (thing) ())
(defclass box (thing container) ())
```

When a method specialises on `thing` and another on `container`, and you call it on a `box` — which runs? CLOS's answer is the #emph[class precedence list]: every class has a total order over itself and all its superclasses, with the class itself first, its direct superclasses next (left to right), then their superclasses, and so on. `class-precedence-list` shows it:

```lisp
(sb-mop:class-precedence-list (class-of (make-instance 'box)))
;; => (#<STANDARD-CLASS BOX> #<STANDARD-CLASS THING>
;;     #<STANDARD-CLASS CONTAINER> ... STANDARD-OBJECT ... T)
```

The rule of thumb: #emph[leftmost direct superclass wins ties]. So `(defclass box (thing container) ...)` makes `box` more `thing`-like than `container`-like: a method on `thing` beats a method on `container` for a `box` instance. Order in the superclass list is meaningful — put the "primary nature" first.

Method selection uses this list: the most specific applicable method — the one whose specialiser appears earliest in the instance's precedence list — runs first. `call-next-method` invokes the next one down. This is why Chapter 26's advice — "`:before` and `:after` for side effects, primary methods for the value" — works: the full method combination runs, in order, #emph[all] applicable `:around`, then the most specific primary flanked by all `:before` and (in reverse) all `:after`.

== shared-initialize: the real constructor chain

Chapter 26 used `initialize-instance :after` as the initialisation hook. The full story: `(make-instance 'box :x 1)` runs

```text
make-instance
  → allocate-instance (fresh, empty slots)
    → initialize-instance (with the :initargs)
      → shared-initialize (fills slots from :initargs and :initforms)
        → :after methods on shared-initialize
      → :after methods on initialize-instance
```

`shared-initialize` is the generic function that actually fills slots from `:initargs` and `:initforms` — and it's called both by `initialize-instance` (fresh objects) and by `reinitialize-instance` (existing objects, re-run with new arguments):

```lisp
(reinitialize-instance *my-lamp* :lit t)
(lit-p *my-lamp*)   ; => T — slot updated
```

The practical consequence, and the reason libraries document "`:initarg` means it's reinitialisable too": any slot you expose via `:initarg` is settable both at creation #emph[and] at `reinitialize-instance` time, by the same keyword. If you want an option that only makes sense at birth, don't give the slot an `:initarg` — set it in `initialize-instance :after` from a different slot or argument.

The `:after` method on `initialize-instance` remains the idiomatic constructor hook (Chapter 26's derived-slot pattern); `:after` on `shared-initialize` additionally fires on reinitialisation — use it when derived slots must track re-init too.

== change-class

An object's class isn't fixed for life:

```lisp
(defclass caterpillar (thing) ())
(defclass butterfly (thing)
  ((days-flown :initform 0 :accessor days-flown)))

(defparameter *bug* (make-instance 'caterpillar
                                   :name 'bug))
(change-class *bug* 'butterfly)
(typep *bug* 'butterfly)   ; => T — same object, new class
(days-flown *bug*)         ; => 0 — new slot, :initform
```

`change-class` keeps the object's identity: every reference to it now sees a `butterfly`. Slots shared by name carry over; new slots get their `:initforms`. The `update-instance-for-different-class` generic function is the hook for migration logic (copying, transforming, defaulting).

Used sparingly — the classic fits are state machines (a connection going `connected` → `closed`) and interactive systems where an object's role genuinely changes mid-session. When in doubt, a status slot beats a class change: cheaper to print, save and query.

== Method combination

Chapter 26's `:before`\/`:after`\/`:around` is #emph[standard method combination]. The primary-method-plus-auxiliaries shape generalises: other combination types run #emph[all] applicable primary methods in most-specific-first order and combine the results:

```lisp
(defgeneric price (thing)
  (:method-combination +))

(defclass treasure-with-surcharge (treasure) ())

(defmethod price + ((t2 thing)) 1)         ; base cost

(defmethod price + ((tr treasure)) (value tr))

(defmethod price + ((ts treasure-with-surcharge)) 10)   ; extra fee

(price (make-instance 'treasure :value 100))
;; => 101 — 100 from the treasure method, 1 from thing's
(price (make-instance 'treasure-with-surcharge :value 100))
;; => 111 — both of the above, plus the surcharge
```

```lisp
(defclass base-thing () ((base-value :initarg :base-value
                                     :initform 1
                                     :reader base-value)))

(defclass valuable (base-thing) ())

(defclass taxed (base-thing) ())

(defclass antique (valuable taxed) ())

(defgeneric price (object)
  (:method-combination +))

(defmethod price + ((o base-thing)) (base-value o))

(defmethod price + ((o valuable)) 10)
(defmethod price + ((o taxed)) 15)

(price (make-instance 'base-thing :base-value 20))
;; => 20
(price (make-instance 'valuable :base-value 20))
;; => 30
(price (make-instance 'antique :base-value 20))
;; => 45
```

That's the payoff: no `call-next-method` discipline required, and #emph[every] applicable method contributes. The standard combinations mirror the arithmetic and list operators: `+`, `max`, `min`, `list`, `append`, `and`, `or`, `progn` (`max` is a favourite for "the best answer among all applicable methods"). `:around` methods still work with any combination, wrapping the whole combined call.

For the `antique` case, all three applicable methods run: `base-thing`'s gives 20, `valuable`'s gives 10, `taxed`'s gives 15, and `+` sums to 45. Order doesn't matter for `+` (it's commutative); order #emph[does] matter for `list` (the list comes in most-specific-first order) and `append` (same).

Custom combinations via `define-method-combination` exist and are genuinely rare — know they're there; reach for `:around` plus a helper function first.

== no-applicable-method and friends

What happens when a generic function is called with arguments no method matches? A `no-applicable-method` generic function is invoked — which by default signals an error naming the generic function and the arguments. You can define a method on it:

```lisp
(defmethod no-applicable-method (gf &rest args)
  (format *error-output* "~A has no method for ~S~%"
          (generic-function-name gf) args)
  (invoke-restart (find-restart 'abort)))
```

— though in application code, silence is rarely the answer; the default error is usually right. The related hooks worth knowing by name only: `no-next-method` (a `call-next-method` with nowhere to go) and `compute-applicable-methods` (the dispatcher itself, specialisable for exotic effects you'll read before you write).

Also worth naming: `(defmethod foo :before ...)` on a generic function that doesn't exist yet #emph[defines] it implicitly — CLOS creates the generic function. Chapter 26's `defgeneric` explicit form is preferred in source, as documentation and as the home of `:documentation` and options.

== Common mistakes

=== Superclass order as decoration

`(defclass box (container thing) ...)` vs `(thing container)` differ in behaviour — precedence, method selection. If you don't care, you're likely to care once two `:before` methods both apply and run in the "wrong" order. Order deliberately; comment the choice when it matters.

=== Expecting :before methods to contribute values

`:before` and `:after` results are discarded. A `:before` method that computes something must store it (a slot, a special variable) for the primary to use — or be a primary method with `call-next-method` instead.

=== change-class as an update mechanism

Using `change-class` to "refresh" objects mutates identity semantics readers rely on; it also interacts badly with `save-game`'s `print`\/`read` round trip (a changed class must exist at load time, in the expected shape). Prefer `change-class` for genuine role transitions, slots for status.

=== Method combination confusion: why won't my :after add to the result?

With `+` combination, `:after` methods still contribute nothing; the combination applies to #emph[primary] methods only. The fix is usually: make the secondary behaviour a primary method (possibly on a more general class specialiser).

=== Two primary methods on the same class specialiser

You can't:

```text
(defmethod price + ((tr treasure)) 1)
(defmethod price + ((tr treasure)) 2)   ; redefinition, not addition
```

The second #emph[replaces] the first — same class, same combination type, one method per generic-function-per-class. If you want two contributions, you need two different classes (as in Chapter 27's `valuable` and `taxed` above), or one method that returns the sum of both internally.

== Project step: pricing the inventory

Give the game a scoring economy, via `+` method combination — the natural fit, since an item's worth is the #emph[sum] of contributions from every class it belongs to.

The game's `thing`, `container` and `treasure` hierarchy from Chapter 26 is the base; this chapter adds a scoring layer on top. The classes exist; now give them a price:

```lisp
(defgeneric price (thing)
  (:method-combination +)
  (:documentation "How valuable is THING, summing contributions?"))

(defmethod price + ((t2 thing))
  1)   ; every thing is worth at least 1

(defmethod price + ((c container))
  2)   ; containers are worth a bit more

(defmethod price + ((tr treasure))
  (value tr))   ; treasures are worth their slot
```

Now the game's inventory total uses them:

```lisp
(defun inventory-score ()
  "Total value of everything the player carries."
  (reduce #'+ (mapcar #'price (items-here 'player))))

;; where items-here returns symbols, and we look up each thing:
(defun inventory-score ()
  (reduce #'+ (mapcar (lambda (sym)
                        (price (lookup-thing sym)))
                      (items-here 'player))))
```

The first version is wrong — `items-here` returns symbols, not `thing` instances, so `(price 'key)` would try to dispatch on a symbol and fail (no method for `symbol`). The second version does the lookup.

Check:

```lisp
(setf *item-locations* '((key . player) (crown . player)
                          (lamp . kitchen)))
(inventory-score)
```

Expected: `+ 1 100 = 101` — the key is a plain `thing` (worth 1), the crown is a `treasure` (worth 100), the lamp isn't carried.

Now the payoff: add an `antique` class combining several contributions, without touching any existing method:

```lisp
(defclass antique (treasure) ())

(defmethod price + ((a antique))
  50)   ; antiques command a premium

(register-thing 'mirror
  (make-instance 'antique
                 :name 'mirror
                 :description "a tarnished silver mirror."
                 :value 200))

(setf *item-locations* (acons 'mirror 'player *item-locations*))
(inventory-score)   ; => 101 + 250 = 351
```

The `+` combination earns its keep the moment a new class joins: `defmethod price + ((a antique)) 50` adds its contribution to every antique without touching any other method — the open\/closed behaviour Chapter 26 promised, finally in its purest form. The antique's price is 200 (from treasure) + 50 (from antique) + 1 (from thing) = `251`, not `200 + 50 = 250` — the `thing` method contributes too, because every antique is a thing.

That's the difference between `+` combination and inheritance-of-behaviour: inheritance gives the most `specific` method (200 for the crown's treasure method, say); combination gives the sum of all `applicable`. The two styles are both right; which one depends on whether the contributions are alternatives (`treasure` vs `container` are alternative kinds) or parts (base cost + premium + fee).

== Exercises

#exercise("27.1")[
  Predict the class precedence list of `(defclass d (b c) ...)` given `(defclass a () ...)`, `(defclass b (a) ...)`, `(defclass c (a) ...)`. Check with `class-precedence-list`. Which class's methods win for a `d` instance, `b`'s or `c`'s?

]

#exercise("27.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (defclass widget () ((x :initarg :x :reader widget-x)))
  (defmethod describe-widget :after ((w widget))
    (format nil "x is ~A" (widget-x w)))

  (defclass base () ((n :initform 1 :accessor n)))
  (defclass sub (base) ())
  (defmethod n :after ((s sub))
    (incf (slot-value s 'n) 10))

  (defgeneric area (shape))
  (defmethod area ((s shape)) 0)
  ```

]

#exercise("27.3")[
  Write `describe-chain`, which takes an instance and prints each class in its precedence list with any `:before`, `:after` and primary `price` methods specialising on it. Use `apropos` or `find-method` as needed — or, simpler, keep a manual registry for this exercise. What does the output teach about why method order surprises happen?

]

#exercise("27.4")[
  Define a `list` method combination analogue: a `participants` generic function whose primary methods each return one participant name, combined into a list. Then add an `:around` method that records how long the full combination took (Chapter 22's `get-internal-run-time`). Where must the `:around` method specialise to wrap #emph[every] call?

]

#exercise("27.5")[
  Write `safe-change-class`, which takes an instance and a new class name, verifies with `class-precedence-list` that no slots would be dropped (slots on the old class absent from the new), and refuses with a condition listing the dropped slot names. What does the refusal check teach about `change-class`'s slot policy?

]

#exercise("27.6", project: true)[
  Give the game's rooms a `+` combination `weight` generic function — `room` contributes its exit count, `dark-room` adds a penalty, `visited-room` (a mixin) adds a discount — and a `safest-exit` helper that picks the exit whose destination has the lowest `weight`. In a comment: what makes `+` the right combination here and `max` the wrong one?

]

