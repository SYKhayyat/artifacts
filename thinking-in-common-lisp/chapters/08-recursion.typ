#import "../lib.typ": *

= Recursion

Most of the work a program does is walk through a collection of things and do something to each one. In Java you write a `for` loop. In Lisp, the natural first tool is a function that calls itself.

== The idea in one sentence

A recursive function solves a big case by calling itself on a smaller case, until the case is so small that the answer is obvious.

== A list is either empty or it isn't

Look again at how a list is built (Chapter 7). Every list is one of two things:

- the empty list, `nil`, or
- a cons: one element, with a shorter list behind it.

The rule gives you a recipe. A function that walks a list asks one question: is this list empty?

- #strong[If it is,] return the answer for the empty case. This is the #emph[base case], and it stops the recursion.
- #strong[If it isn't,] do something with `(first lst)`, and call yourself on `(rest lst)`, which is one cons shorter.

The recursion always moves toward the empty list, so it always stops.

```lisp
(defun all-positive-p (numbers)
  "Return T if every number in NUMBERS is greater than zero."
  (cond ((null numbers) t)
        ((plusp (first numbers)) (all-positive-p (rest numbers)))
        (t nil)))
```

```lisp
(list (all-positive-p '(1 2 3))
      (all-positive-p '(1 -2 3))
      (all-positive-p '()))
;; => (T NIL T)
```

Read the three clauses with the two questions in mind:

- `(null numbers)`: the list is empty. Every number in an empty list is positive, so the answer is `t`. This is the base case.
- `(plusp (first numbers))`: the first number is fine, so the answer depends on the rest. Call yourself on `(rest numbers)`.
- otherwise: the first number isn't positive, so the answer is `nil`, without looking further.

If you forget the first clause, the function never stops. That's the mistake to watch for, and it's in the "Common mistakes" section below.

== Building an answer as you come back

The previous example returned an answer found somewhere in the list. Often you want to build a #emph[new list]. Use `cons` to put something on the front of the answer for the rest:

```lisp
(defun double-all (numbers)
  "Return a list of each number in NUMBERS, doubled."
  (if (null numbers)
      nil
      (cons (* 2 (first numbers))
            (double-all (rest numbers)))))
```

```lisp
(double-all '(1 2 3))     ; => (2 4 6)
(double-all '())          ; => NIL
```

The shape is worth naming: #strong[handle the first element, then trust the recursive call for the rest.]

For `(double-all '(1 2 3))`, Lisp can't finish the `cons` until it knows `(double-all '(2 3))`. So the calls pile up:

```text
(double-all (1 2 3))  needs (double-all (2 3))
(double-all (2 3))    needs (double-all (3))
(double-all (3))      needs (double-all ())
(double-all ())       → NIL, and now each call can finish
(double-all (3))      → (6)
(double-all (2 3))    → (4 6)
(double-all (1 2 3))  → (2 4 6)
```

The base case answers first, and the answers come back up the chain. The `cons` calls happen on the way #emph[out].

== Watching it happen with `trace`

When recursion is hard to follow, ask Lisp to show you every call:

```lisp
(trace double-all)
(double-all '(1 2 3))
(untrace double-all)
```

The block shows only the final value. The trace lines appear in the #strong[REPL window], so switch to it (`C-x o`) to read them. They look like this:

```text
0: (DOUBLE-ALL (1 2 3))
  1: (DOUBLE-ALL (2 3))
    2: (DOUBLE-ALL (3))
      3: (DOUBLE-ALL NIL)
      3: DOUBLE-ALL returned NIL
    2: DOUBLE-ALL returned (6)
  1: DOUBLE-ALL returned (4 6)
0: DOUBLE-ALL returned (2 4 6)
```

The number at the start of a line is the depth. Every call indents one step further and returns one step earlier. You can see the base case at the bottom, and the answers coming back up.

`untrace` turns tracing off, and so does restarting Lisp. Trace one function at a time; if you trace something that calls another traced function, the output becomes a wall of lines.

This is the single most useful tool for learning recursion. Whenever a recursive function surprises you, trace it.

== The accumulator pattern

Building the answer on the way out is elegant, but the calls pile up, and each one adds a step of work on the way back. There's a second way: carry the answer #emph[with] you as an extra parameter, and add to it on the way in.

```lisp
(defun double-all-into (numbers result)
  "Cons each number in NUMBERS, doubled, onto RESULT."
  (if (null numbers)
      result
      (double-all-into (rest numbers)
                       (cons (* 2 (first numbers)) result))))
```

```lisp
(double-all-into '(1 2 3) nil)   ; => (6 4 2)
```

`(6 4 2)` is backwards. Consing onto the front while walking forwards does that: 1 goes on first, then 2 lands in front of it, then 3. Fix it with one `reverse` at the end:

```lisp
(defun double-all (numbers)
  "Return a list of each number in NUMBERS, doubled."
  (reverse (double-all-into numbers nil)))
```

```lisp
(double-all '(1 2 3))            ; => (2 4 6)
```

The parameter `result` is called an #emph[accumulator]. It holds the answer so far. Each call adds one thing to it and hands it on. The base case doesn't build anything: it just returns what has been accumulated.

Because the `cons` happens on the way in, nothing is left waiting on the way out. Nothing piles up. A call like this, where the recursive call is the very last thing the function does, is in #emph[tail position], and Lisp can turn it into a plain jump. The section "How deep can you go" comes back to this.

Which pattern to use:

#table(
  columns: (2.4fr, 5.6fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Pattern], [Use when]),
  [Build with `cons` on the way out], [The result has the same order as the input, or the order doesn't matter],
  [Accumulator, then `reverse`], [You are walking a long list, or the result is naturally built backwards],
)

When in doubt, use the first. Reach for the accumulator when a list is long or when the recursion would otherwise go deep.

== Recursion on numbers

Lists aren't the only thing that can be smaller. Any number can be one smaller than itself, and the base case is whatever number stops the process.

```lisp
(defun countdown (n)
  "Return a list of the numbers from N down to 1."
  (if (zerop n)
      nil
      (cons n (countdown (1- n)))))
```

```lisp
(countdown 5)      ; => (5 4 3 2 1)
(countdown 0)      ; => NIL
```

```lisp
(defun factorial (n)
  "Return N!, the product of the numbers from 1 to N."
  (if (zerop n)
      1
      (* n (factorial (1- n)))))
```

```lisp
(list (factorial 0) (factorial 5) (factorial 30))
```

```text
(1 120 265252859812191058636308480000000)
```

The last value is exact, because Lisp integers have no size limit (Chapter 3). In Java you'd need `BigInteger` for that.

Notice the base cases: `nil` for building a list, `1` for a product. A sum would use `0`, and a yes\/no question would use `t` or `nil`. #strong[The base case returns the answer for "nothing", and that answer must have the right type.] Writing `nil` where a number is expected is one of the four mistakes at the end of this chapter.

== Recursion on nested lists

A list whose elements are themselves lists is a #emph[tree]. Chapter 7 drew one. Trees are the natural home of recursion, because a tree is either an atom, or a cons with two smaller trees inside it.

Here is a function that counts every atom in a tree:

```lisp
(defun count-atoms (tree)
  "Return the number of atoms in TREE, at any depth."
  (cond ((null tree) 0)
        ((consp tree) (+ (count-atoms (car tree))
                         (count-atoms (cdr tree))))
        (t 1)))
```

```lisp
(list (count-atoms '(a (b (c)) d))
      (count-atoms 5)
      (count-atoms nil))
;; => (4 1 0)
```

Three cases, and this time the recursion appears twice:

- `nil` is empty, so it holds no atoms. (It's a list, so it counts as zero, not one.)
- A cons is a tree of two halves, its car and its cdr, so add the counts of both. This is where a list and a tree differ: for a plain list, you only recurse on the `rest`.
- Anything else is an atom, so it counts as one.

Recursing on both halves ends, because each half contains strictly fewer conses than the whole.

== Mutual recursion

A function can call another, which calls the first one back. Two functions that take turns are #emph[mutually recursive]:

```lisp
(defun my-even-p (n)
  "Return T when N is even, by counting down."
  (if (zerop n)
      t
      (my-odd-p (1- n))))

(defun my-odd-p (n)
  "Return T when N is odd, by counting down."
  (if (zerop n)
      nil
      (my-even-p (1- n))))
```

```lisp
(list (my-even-p 4) (my-odd-p 4) (my-even-p 0))
;; => (T NIL T)
```

SBCL may warn "undefined function: MY-ODD-P" while you run the first `defun`, because `my-odd-p` doesn't exist yet. As Chapter 5 says, that's a note, not a problem. Once both are defined, the calls work.

They take turns right down to zero: `my-even-p 4` calls `my-odd-p 3`, which calls `my-even-p 2`, and so on. Whoever reaches zero decides.

== How deep can you go

When a call is in tail position, Lisp can throw away the current frame and jump. On a stock SBCL:

```lisp
(defun count-down-to-zero (n)
  "Return the symbol DONE after counting from N down to zero."
  (if (zerop n)
      'done
      (count-down-to-zero (1- n))))

(count-down-to-zero 1000000)   ; => DONE
```

A million calls, and no memory used up. The recursive call is the last thing `count-down-to-zero` does, so no frame is kept.

Now the other side. When the call is #strong[not] in tail position, every frame stays alive until the answer comes back. `(countdown 100000)` builds a hundred thousand conses and needs a hundred thousand frames at once. SBCL has a fixed control stack, and when it runs out you get:

```text
Control stack exhausted (no more space for function call frames).
```

The debugger opens. Press `q` to close it, or use the "abort" restart if the REPL asks, and everything else keeps working. Nothing is corrupted.

Two rules of thumb:

- A recursion that builds a result with `cons` (or `+`, or `append`) needs one frame per element. Fine for hundreds and thousands, not for millions.
- A tail recursion with an accumulator needs no frames at all. Use it for the long walks.

SBCL does this tail-call optimisation by default. Other Lisp implementations may not, and compiler settings can switch it off. Treat it as a useful property of your current setup, not as something to design around. When you meet `loop` in Part III, you'll see how Lisp programmers write the long walks without recursion at all.

== How to write a recursive function

A recipe that works almost every time:

+ #strong[Say what the function does in one sentence,] including what it returns for the empty list, or for zero, or for the smallest input. That sentence is your base case.
+ #strong[Write the base case first.] Test it immediately, before writing anything else.
+ #strong[Shrink the input.] For a list, that's `(rest lst)`. For a number, `(1- n)`. For a tree, the car and the cdr.
+ #strong[Decide what to do with the smaller answer:] return it as is, wrap it with `cons`, add something to it, or pick between it and the current element.
+ #strong[Test with an empty input, one element, then two.]
+ #strong[If it surprises you, trace it.]

Step 3 is where the thinking happens. The function is correct when the smaller input is always genuinely smaller, and when the base case is reached for every input the function will ever get.

== Common mistakes

- #strong[No base case:] `(defun first-of (lst) (first-of lst))` never stops. SBCL prints "Control stack exhausted" and opens the debugger. Press `q`. Check that your `cond` or `if` has a clause for the empty list, and that it comes first.
- #strong[A base case that is never reached:] counting down with `(1- n)` and testing `(zerop n)` works for `0` and positive numbers. `(my-even-p -4)` counts down forever. Check the base case against negative arguments, or add a clause that turns them around first.
- #strong[Forgetting to use the recursive result:] `(defun my-length (lst) (if (null lst) 0 (my-length (rest lst))))` always returns `0`. The call was made, its answer was thrown away. It needs `(+ 1 (my-length (rest lst)))`.
- #strong[Recursing on the input instead of the smaller input:] `(sum-list lst)` calling `(sum-list lst)` again. The "Control stack exhausted" message catches it. Look at the argument of the recursive call: it must be `(rest lst)`, `(1- n)`, or another smaller thing.
- #strong[A base case of the wrong type:] `(defun sum-list (lst) (if (null lst) nil (+ (first lst) (sum-list (rest lst)))))` fails with "The value NIL is not a NUMBER" as soon as the recursion reaches the end. The base case for a sum is `0`.
- #strong[Rebuilding a list in the wrong order, over and over:] using an accumulator and forgetting the `reverse`, then adding a second `reverse` inside the loop. Build backwards once, then reverse once.
- #strong[Tracing everything:] `(trace)` on a function that's called in a tight loop floods the REPL. Trace one function, and `untrace` it when you're done.
- #strong[Recursing where a built-in already does the job:] after Part III you'll reach for `loop` or `mapcar` for the common walks. Recursion earns its place on trees, on divide-and-conquer problems, and on anything where the shape of the data is itself recursive.

== Project step: what's lying around

The game can move the player and take items, but the player can't see what's there. Write that now: walk the item alist and collect the items whose location matches.

```lisp
(defun items-in (pairs place)
  "Return the items in the alist PAIRS whose place is PLACE."
  (cond ((null pairs) nil)
        ((eq (cdar pairs) place)
         (cons (caar pairs) (items-in (cdr pairs) place)))
        (t
         (items-in (cdr pairs) place))))
```

With the chapter's idea in mind, read the three clauses:

- empty alist: nothing found, so `nil`.
- the first pair's value is this place: keep its item, and look through the rest.
- otherwise: skip this pair, and look through the rest.

Every call passes `(cdr pairs)`, one pair shorter, so it stops at `nil`.

```lisp
(defun items-here (place)
  "Return the items lying in PLACE."
  (items-in *item-locations* place))
```

Reset the items so this chapter starts from a known state:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
```

```lisp
(setf *current-room* (find-room 'kitchen))
(list (items-here 'kitchen)
      (items-here 'cellar)
      (items-here 'player)
      (items-here 'garden))
;; => ((KEY) (LAMP) NIL NIL)
```

The third one is empty because the player is carrying nothing — and that's the same function doing the work. Carried items are marked with the symbol `player`, so asking for the items in `player` asks for the inventory.

Now turn that list of symbols into words a player can read:

```lisp
(defun item-names (items)
  "Return a string listing ITEMS by name, separated by commas."
  (cond ((null items) "")
        ((null (cdr items)) (item-name (first items)))
        (t
         (concatenate 'string
                      (item-name (first items))
                      ", "
                      (item-names (rest items))))))
```

```lisp
(list (item-names nil)
      (item-names '(key))
      (item-names '(key lamp)))
;; => ("" "key" "key, lamp")
```

The three clauses do three different jobs: nothing, exactly one, or the first one plus the rest. The middle clause exists so you don't get a stray `", "` at the end or a missing one in the middle. Exercise 8.11 makes it read "key and lamp".

Now let `look` mention what's there:

```lisp
(defun look ()
  "Describe the room the player is in, and what is lying there."
  (let ((here (items-here (room-name *current-room*))))
    (if (null here)
        (describe-room *current-room*)
        (concatenate 'string
                     (describe-room *current-room*)
                     " You can see: "
                     (item-names here)
                     "."))))
```

```lisp
(princ (look))
```

```text
You are in the Kitchen. A warm kitchen that smells of bread. You can see: key.
```

And an inventory command, built from the same pieces:

```lisp
(defun inventory ()
  "Describe what the player is carrying."
  (let ((carried (items-here 'player)))
    (if (null carried)
        "You are carrying nothing."
        (concatenate 'string
                     "You are carrying: "
                     (item-names carried)
                     "."))))
```

Check it against `take`:

```lisp
(list (take 'key) (inventory))
;; => ("You take the key." "You are carrying: key.")
```

Both functions work with no extra bookkeeping. `take` marks an item with the symbol `player`, and `items-here` finds everything marked that way. The inventory is just another search through the same alist, using the same recursive walk.

That's the shape of a Lisp program: a few small functions that each walk a list or pick it apart, composed until they do something that looks like a game.

=== A bug: pairs that are hidden but not gone

Reset the items, take the key, and ask what's in the kitchen:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))
(list (take 'key) (items-here 'kitchen))
;; => ("You take the key." (KEY))
```

The key is in the player's hands, yet the kitchen still has it. The alist now holds two pairs for the key:

```text
((KEY . PLAYER) (LAMP . CELLAR) (KEY . KITCHEN) (LETTER . BEDROOM))
```

`assoc` stops at the first pair, so `item-location` gives the right answer. `items-in` walks #emph[every] pair, so it finds the old one too. The trick from Chapter 7 is safe only for code that looks things up with `assoc`. Code that walks the whole list sees everything.

The fix: keep exactly one pair per item. A recursive function builds a new alist in which the item's pair is replaced:

```lisp
(defun set-location (pairs item place)
  "Return a copy of the alist PAIRS with ITEM moved to PLACE."
  (cond ((null pairs) nil)
        ((eq (caar pairs) item)
         (cons (cons item place)
               (set-location (cdr pairs) item place)))
        (t
         (cons (car pairs)
               (set-location (cdr pairs) item place)))))
```

```lisp
(set-location '((lamp . cellar) (key . kitchen)) 'key 'player)
;; => ((LAMP . CELLAR) (KEY . PLAYER))
```

It's the same three-clause walk as `items-in`: stop at the end, replace the matching pair, copy every other pair. The old list is untouched.

Now `take` stores the new list instead of pushing a pair:

```lisp
(defun take (item)
  "Pick up ITEM if it is in the current room."
  (cond ((eq (item-location item) 'player)
         "You already have that.")
        ((eq (item-location item) (room-name *current-room*))
         (setf *item-locations*
               (set-location *item-locations* item 'player))
         (concatenate 'string "You take the " (item-name item) "."))
        (t
         "You don't see that here.")))
```

Run the test again:

```lisp
(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))
(setf *current-room* (find-room 'kitchen))
(list (take 'key) (items-here 'kitchen) (inventory))
;; => ("You take the key." NIL "You are carrying: key.")
```

If you wrote `drop` in Exercise 7.8, redefine it the same way:

```lisp
(defun drop (item)
  "Put down ITEM in the current room, if the player carries it."
  (if (eq (item-location item) 'player)
      (progn
        (setf *item-locations*
              (set-location *item-locations* item
                            (room-name *current-room*)))
        (concatenate 'string "You drop the " (item-name item) "."))
      "You don't have that."))
```

The lesson is worth keeping. A shortcut that relies on how one function behaves, here "`assoc` finds the first pair", breaks as soon as other code reads the same data in a different way.

== Exercises

#exercise("8.1")[
  Write `my-length`, which returns the number of elements in a list, without using `length`.

]

#exercise("8.2")[
  Write `my-sum`, which adds up the numbers in a list, without using `+` on the whole list at once. It should return `0` for an empty list.

]

#exercise("8.3")[
  Predict the result of each line, then check:

  ```text
  (count-atoms '(a (b) c))
  (countdown 3)
  (factorial 4)
  (items-in '((lamp . cellar) (key . kitchen)) 'kitchen)
  (double-all-into '(1 2) nil)
  ```

]

#exercise("8.4")[
  Write `my-reverse` using the accumulator pattern: a helper that takes the list and the answer so far, and a one-line `my-reverse` that calls it.

]

#exercise("8.5")[
  Write `my-find`, which takes an item and a list and returns the item when it is in the list, and `nil` when it isn't. The item can be anywhere in the list.

]

#exercise("8.6")[
  Write `count-symbol`, which takes a symbol and a tree and returns how many times the symbol appears in the tree, at any depth.

]

#exercise("8.7")[
  Write `flatten`, which turns a nested list into a flat one: `(flatten '(a (b (c)) d))` gives `(a b c d)`. It should also handle an empty list, giving `nil`.

]

#exercise("8.8")[
  Each function below is wrong. Say what's wrong without running it, then fix it and check.

  ```text
  (defun bad-length (lst)
    (if (null lst)
        0
        (bad-length (rest lst))))

  (defun bad-sum (lst)
    (if (null lst)
        nil
        (+ (first lst) (bad-sum (rest lst)))))

  (defun bad-countdown (n)
    (if (zerop n)
        nil
        (cons n (bad-countdown (1+ n)))))
  ```

  Careful with the third one: fix it, but don't call the broken version with a large number. It only stops when the control stack runs out.

]

#exercise("8.9")[
  Write `count-conses`, which returns how many cons cells a tree is made of. `(count-conses '(a b))` gives `2`, and an atom gives `0`.

]

#exercise("8.10", project: true)[
  Write `item-report`, which takes the item alist and returns a list of strings, one per item, saying where it is. Items the player carries should read differently from items lying in a room:

  ```text
  ("coin is carried"
   "lamp is in the cellar"
   "key is in the kitchen"
   "letter is in the bedroom")
  ```

]

#exercise("8.11", project: true)[
  Rewrite `item-names` so that two items read `"key and lamp"` and three read `"key, lamp and coin"`.

  ```text
  (item-names nil)              ; => ""
  (item-names '(key))           ; => "key"
  (item-names '(key lamp))      ; => "key and lamp"
  (item-names '(key lamp coin)) ; => "key, lamp and coin"
  ```

]

#exercise("8.12", project: true)[
  Write `loot`, which picks up everything lying in the current room. It returns `"There is nothing here to take."` when the room is empty, and a message naming what was taken otherwise. Write a recursive helper that calls `take` on each item in turn.

]

