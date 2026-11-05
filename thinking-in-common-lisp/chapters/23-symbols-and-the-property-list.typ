#import "../lib.typ": *

= Symbols and the Property List

You've been using symbols since Chapter 2 — `'kitchen`, `:name`, `*moves*` — and Chapter 9 added the two-slots picture: every symbol has a value slot and a function slot. That picture was incomplete on purpose. A symbol is a small record with five parts, and one of them — the property list — is a data structure you haven't used yet. This chapter completes the picture, and with it a fair amount of "why is Lisp like this" falls into place.

== The five parts of a symbol

Every symbol has:

- a #strong[name] — the string it was read from: `"KITCHEN"`.
- a #strong[package] — which package's symbol table holds it (Chapter 16): the `CL-USER` package for `kitchen`, `KEYWORD` for `:name`.
- a #strong[value slot] — what `*moves*` evaluates to.
- a #strong[function slot] — what `#'look` names.
- a #strong[property list] — a hidden list of key\/value pairs, empty by default.

`symbol-name`, `symbol-package` and `symbol-value` read the first three; `symbol-function` is the function slot accessor from Chapter 9's discussion of `#'`. All are setf-able, which is what `setf` has been doing all along:

```lisp
(symbol-name 'kitchen)          ; => "KITCHEN"
(symbol-package 'car)           ; => #<PACKAGE "COMMON-LISP">
(symbol-package :look)          ; => #<PACKAGE "KEYWORD">
(symbol-value '*moves*)         ; => nil (if *moves* is undefined)
(symbol-function 'car)          ; the function object for CAR
```

The last line's oddity: `symbol-function` takes a #emph[symbol], so `(symbol-function 'car)`, not `(symbol-function #'car)`. Writing `#'car` there would evaluate the function object first, and `symbol-function` wants the name, not the value. The five parts make concrete what Chapter 9 said abstractly: one name, several slots.

== The property list

A symbol's plist is a list of alternating keys and values, stored #emph[on the symbol itself]:

```lisp
(setf (get 'kitchen 'description) "Where the noise begins")
(get 'kitchen 'description)     ; => "Where the noise begins"
(get 'hall 'description)        ; => NIL — never set
(setf (get 'hall 'visited) t)
(remprop 'kitchen 'description) ; removes the pair, returns non-nil
```

`get` reads; `(setf get)` writes; `remprop` removes. The default for a missing property is `nil`, changeable with a third argument:

```lisp
(get 'hall 'description 'unknown)  ; => UNKNOWN when absent
```

The keys are symbols — usually keywords, by convention — and the plist is what `get` walks: a list like `(description "..." visited t)`. You can see it directly:

```lisp
(symbol-plist 'hall)  ; => (VISITED T) — with KITCHEN's removed above
```

`symbol-plist` exposes the raw list. You'll rarely use it directly — `get`, `remprop` and `get-properties` are the interface.

== `get` vs `getf`

These two functions are confused often, and the difference is worth stating precisely:

- `get` takes a #emph[symbol] and a property indicator, and looks up the property #emph[on that symbol's plist].
- `getf` takes an #emph[arbitrary plist] as its first argument, and a key as its second, and looks up the key in that plist.

`get` is for per-symbol attributes. `getf` is for plist-shaped data anywhere — a keyword-argument plist, a configuration structure, anything that happens to be an alternating key\/value list:

```lisp
(getf '(:name "kex" :exits nil) :name)   ; => "kex"
(getf '(:speed 3 :depth 2) :depth)       ; => 2
```

The signature tells you which you want: `(get symbol indicator)` when the symbol #emph[is] the thing; `(getf plist key)` when the plist #emph[is] the thing.

== Plists vs alists vs hash tables

You now hold all three dictionary shapes Lisp offers natively: the alist (Chapter 7), the hash table (Chapter 13), and the plist. The differences are about #emph[where the pairs live] and what operations are natural:

#[
  #set par(justify: false)
  #table(
    columns: (1.2fr, 2.2fr, 2.5fr, 2.0fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Structure], [Pairs live on], [Natural operations], [Costs]),
    [plist], [the symbols themselves], [`get`, `remprop`], [linear scan per lookup],
    [alist], [one list you own], [`assoc`, `acons`, `push`], [linear scan],
    [hash table], [a table object you own], [`gethash`, `remhash`, `maphash`], [O(1) average],
  )
]

The real distinction: a plist #emph[smears] the association across all symbols that carry the property — `(get name 'location)` across every room symbol is the data, and no single object owns it. An alist is #emph[one list] that can be passed, rebound, saved and rebuilt. That's why the game used alists for `*item-locations*` — state you save and restore — and why plists fit #emph[attributes that belong to named things]:

- Symbols as #emph[names of things] (rooms, commands, items): a plist is the thing's attributes, reachable by name alone.
- One shared table of #emph[mappings]: alist or hash table.
- Data to #emph[save, pass, or have several versions of]: never a plist — you can't snapshot a symbol's plist short of copying it pair by pair, and there's one plist per symbol, not one per context.

`get-properties` is the plist utility worth knowing beyond `get`:

```lisp
(get-properties '(description "#| ... |#" visited t) '(visited description))
;; => (VISITED T) — first property present, with its value
```

The distinction from `getf`: `get-properties` reports which properties are #emph[present], and its first return value is the suffix of the plist starting at the first match — different from `getf`'s value-only answer. Rare in application code; worth recognising in libraries.

== Plists and keyword arguments

`format` isn't the only place a plist-shaped value appears in disguise. Many libraries document "accepts a plist of options"; modern code uses real `&key` parameters (Chapter 5), but the plist style survives in older APIs:

```lisp
(defun draw-window (title &rest options)
  (let ((width  (getf options :width 80))
        (height (getf options :height 24)))
    (list title width height)))
```

When you read `(:name "kitchen" :exits ...)` in old code, you're seeing a plist-shaped option list — a flat list of alternating keywords and values, handled with `getf`. Chapter 5's `&key` parameters are the modern spelling of the same idea; the plist is the data shape underneath.

== gensym revisited

Chapter 14's gensym created "fresh symbols" — now you can say what that meant precisely. A gensym's product is a symbol with a generated name — `"G123"`, say — and no home package: `symbol-package` returns `nil`, which is the tell that it is not an interned symbol.

Its read syntax `#:g123` exists so the printer can print it back; reading `#:g123` produces a #emph[different] uninterned symbol with the same name — which is why uninterned symbols can't round-trip (Chapter 16's print\/read round trip for save files needed interned names).

```lisp
(symbol-package (gensym)) ; => NIL
(symbol-name (gensym)) ; => "G456" — no colon, just the name
```

== Common mistakes

=== Plists as primary state

Putting game state on plists and then trying to `save-game`: there's no object to hand to print — you'd have to walk every symbol and collect properties first, and restored state is spread across the package. State you save belongs in lists, structures and hash tables you own; plists for per-symbol attributes, if at all.

=== remprop on shared symbols

remprop and (setf get) mutate #emph[the symbol], which is shared by everyone using that name. Removing description from 'kitchen removes it for the whole image — including other code that set it. Property lists are global by nature; treat them as such.

=== get on non-symbol keys

(get 5 'x) signals an error — get requires symbol keys, because the plist lives #emph[on symbols]. For string or number keys, use an alist with :test, or a hash table with the right test, or — nothing Lisp-standard, because plist keys are symbols by design.

=== Believing type declarations protect plists

== Project step: per-command metadata

The #strong[commands] table (Chapter 9) maps command names to functions. This step adds per-command metadata — help text and usage — where the plist genuinely fits: attributes belonging to named things, consulted by name alone.

```lisp
(defun define-command (name fn help usage)
  "Register a command with its metadata for a help system."
  (push (cons name fn) commands)
  (setf (get name 'help) help)
  (setf (get name 'usage) usage))

(defun command-doc (name)
  "Help text and usage for NAME, or a fallback."
  (format nil "~(~A~): ~A~% usage: ~A"
    name
    (or (get name 'help) "No help available.")
    (or (get name 'usage) "unknown")))

(defun help-command ()
  "List commands with one-line help, alphabetically."
  (format t "~:{~&~(~A~)~12T~A~}~%"
    (sort (loop for pair in commands
        for name = (car pair)
        collect (list name (or (get name 'help) "")))
      #'string< :key #'first)))
```

The `:{`} directive walks a list of lists (Chapter 12); the sort with :key is Chapter 10's `sort` doing book-listing duty. Check:

```lisp
(setf commands nil) ; start clean, for the demo
(define-command 'look #'look "Describe your surroundings." "(look)")
(define-command 'take #'take "Pick something up." "(take ITEM)")
(define-command 'go #'go-to "Move in a direction." "(go NAME)")

(help-command)
;; go Move in a direction.
;; look Describe your surroundings.
;; take Pick something up.

(command-doc 'take)
;; => "take: Pick something up.
;; usage: (take ITEM)"
```

== Exercises

#exercise("23.1")[
  Predict, then check:

  ```text
  (symbol-name 'kitchen)
  (symbol-package :kitchen)
  (symbol-name :kitchen)
  (eq 'kitchen 'KITCHEN)
  (eq (intern "KITCHEN") 'kitchen)
  (symbol-package (gensym))
  ```

]

#exercise("23.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (get "kitchen" 'description)

  (setf (get 'kitchen 'exits) '(hall cellar))
  (remprop 'kitchen 'exits)
  ;; ...later, elsewhere:
  (get 'kitchen 'exits)

  (let ((props (symbol-plist 'kitchen)))
  (remprop 'kitchen 'description)
  props)

  (getf '(name "hall" name "cellar") :name)
  ```

]

#exercise("23.3")[
  Write `plist-p`, which answers whether a list is a valid plist (an even number of elements). Then write `plist->alist`, which converts `(a 1 b 2)` to `((a . 1) (b . 2))`, and `alist->plist` the other way. Which direction loses information, and why can that be acceptable?

]

#exercise("23.4")[
  Write `plist-keys`, which returns the distinct keys of a plist. Then using `get-properties`, write `plist-subset-p`, which answers whether a plist contains every key\/value pair of another plist.

]

#exercise("23.5")[
  Write `swap`, a macro expanding to code that exchanges two variables' values, using `gensym` for the temporary. Then demonstrate — with `macroexpand-1` and a variable actually named `tmp` — why the naive version (with a plain `let` on `tmp`) is a bug.

]

#exercise("23.6", project: true)[
  Add per-item flavour text as plist properties on the item symbols — `(setf (get 'key 'flavour) ...)` — and write a `describe-flavour` function that returns the flavour or a default. Then answer in a comment: why is flavour text (never saved, fixed at definition) a defensible plist use where item #emph[locations] (Chapter 7) were not?

  Flavour text is (a) an attribute of a named thing, consulted by name alone — the plist's natural shape; (b) fixed at definition time, never needs snapshotting, versioning, or save-game; (c) global by nature — the flavour of the key is the same every session, which is exactly the intent. Item #strong[locations], by contrast, are mutable state with a lifetime: they change during play, get saved, restored, and would be spread unownably across symbols on a plist — which is why Chapter 7 gave them an alist and Chapter 23's common-mistakes list forbade plists for them. The dividing line, in one sentence: plists for constants about names, owned structures for state about things.

]

