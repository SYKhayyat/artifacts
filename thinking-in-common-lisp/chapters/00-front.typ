#import "../lib.typ": *

= How to Use This Guide

== What this guide is

This guide takes you from zero to reading, writing and thinking in Common Lisp. It is long on purpose. Read it in order the first time. Afterwards, use it as a reference.

Two promises:

+ #strong[No forward references.] You will never see "don't worry about this yet". Every piece of code uses only what has already been explained.
+ #strong[You run everything.] Every example is a live code block. You run it inside this file and see the result right below it.

You know Python and Java. Now and then a short note will say "this is roughly like X in Java". Treat those as landmarks, not translations. Lisp works best when you meet it on its own terms.

== First: set up your machine

Before anything else, do these in order:

+ Appendix A: install SBCL (the Lisp itself).
+ Appendix B: make Emacs talk to SBCL and run code blocks.
+ Skim Appendix C: the Emacs keys you need.

Come back here when the test block in Appendix B prints `3`.

== How each chapter is built

Every chapter has the same parts:

- #strong[Explanation] with code blocks you run as you read.
- #strong[Common mistakes:] the errors beginners actually make, what the error message looks like, and how to fix it.
- #strong[Project step:] one new piece of the running project (see below).
- #strong[Exercises:] answers are in Appendix D.

== Running code blocks (Org Babel)

A code block looks like this:

```lisp
(+ 1 2)
```

To run it:

+ Make sure Lisp is running. Type `M-x slime` and press Enter once per Emacs session. A REPL window opens. You can leave it alone.
+ Put the cursor anywhere inside the block.
+ Press `C-c C-c`.

The result appears right under the block:

```text
#+RESULTS:
: 3
```

Run the block again and the result is replaced, not duplicated.

=== Two kinds of results

By default you get the #strong[value] of the last expression in the block, which is the thing the code "returns".

If the code #strong[prints] text, add `:results output` to the first line to capture what was printed:

```lisp
(print "hello")
(print "world")
```

Without `:results output`, the printed text goes to the REPL window and the block shows only the final value. When a block's result looks "wrong", this is usually why.

=== Blocks share one Lisp

Every block runs in the same Lisp session. If you define something in one block, later blocks can use it. This means:

- Run blocks in order, from top to bottom.
- If you restart Emacs or Lisp, re-run the earlier blocks that define things before running later ones.

=== Editing a block comfortably

Press `C-c '` (Control-c, then apostrophe) inside a block. It opens in its own window with full Lisp editing support. Press `C-c '` again to go back.

== Writing and checking your exercise answers

Under each exercise, make your own block and type your answer:

```text
*** Exercise 1.1
Write a function =twice= that returns twice its argument.

#+begin_src lisp
;; my answer
(defun twice (n)
  (* n 2))
#+end_src
```

Then check it. Each answer in Appendix D comes with #strong[test lines]. Paste them into a second block under yours and run both:

```text
#+begin_src lisp
(list (twice 4) (twice 0) (twice -3))
#+end_src

#+RESULTS:
: (8 0 -6)
```

If your result matches the one in Appendix D, you're done. Your version doesn't need to look like the answer. There are many correct ways to write most things.

Habits that help:

- #strong[Type the examples, don't paste them.] Your fingers learn the shape of Lisp.
- #strong[Break things on purpose.] Delete a parenthesis, misspell a name, and read the error. Every chapter's "Common mistakes" section shows how.
- #strong[If an error window (the debugger) pops up,] press `q` to close it. A later chapter teaches you how to use it properly.

== The running project

Across the chapters you will build a small #strong[text adventure]. You'll walk between rooms, pick up items and type commands. It starts as a few lines of data and grows a little with each chapter. Each project step uses only that chapter's ideas and the ones before it.

