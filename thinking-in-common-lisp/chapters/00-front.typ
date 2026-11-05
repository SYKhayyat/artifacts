#import "../lib.typ": *

= How to Use This Guide

== What this guide is

This guide takes you from zero to reading, writing and thinking in Common Lisp. It is long on purpose. Read it in order the first time. Afterwards, use it as a reference.

Two promises:

+ #strong[No forward references.] You will never see "don't worry about this yet". Every piece of code uses only what has already been explained.
+ #strong[You run everything.] Every example is code you type and run yourself, with its result printed underneath so you can check yourself as you go.

You know Python and Java. Now and then a short note will say "this is roughly like X in Java". Treat those as landmarks, not translations. Lisp works best when you meet it on its own terms.

== First: set up your machine

Before anything else, do these in order:

+ Appendix A: install SBCL (the Lisp itself).
+ Appendix B: make Emacs talk to SBCL and run your first expression.
+ Skim Appendix C: the Emacs keys you need.

Come back here when the test expression in Appendix B prints `3`.

== How each chapter is built

Every chapter has the same parts:

- #strong[Explanation], with code you run as you read.
- #strong[Common mistakes:] the errors beginners actually make, what the error message looks like, and how to fix it.
- #strong[Project step:] one new piece of the running project (see below).
- #strong[Exercises:] answers are in Appendix D.

== Running the code

A listing looks like this:

```lisp
(+ 1 2)
```

You run it by typing it at the REPL and pressing #box[`RET`]:

```text
CL-USER> (+ 1 2)
3
```

Most listings in this guide carry that answer as a comment, so you can check yourself without waiting for us:

```lisp
(+ 1 2)   ; => 3
```

There are two ways to run a listing, and the book works with either:

- #strong[At the REPL.] Type it, press #box[`RET`], read the answer. Best for experiments and one-liners.
- #strong[In a `.lisp` buffer.] Type it in a file, put the cursor after the closing parenthesis, and press #box[`C-c C-c`]. Emacs sends the expression to Lisp and shows the value in the echo area at the bottom of the frame. Best for code you want to keep. Chapter 1 calls this the edit-evaluate loop, and Appendix B sets it up.

=== Two kinds of results

A listing either #strong[returns] a value or #strong[prints] text, and the two are shown differently.

The value is what Lisp hands back — what the REPL shows after you press #box[`RET`]. Listings that return a value show it as a `; =>` comment:

```lisp
(* 6 7)   ; => 42
```

Printed text is output written along the way, by `print`, `princ`, `format` or the debugger. It comes out above the value:

```lisp
(print "hello")
(print "world")
```

The two printed lines appear first, then the value of the last `print` — the string `"world"` — comes back on its own line.

When a listing's result looks "wrong", it is usually this: you expected the printed text, and what you are looking at is the value that came back at the end.

=== One Lisp, running

Everything you run goes into the same Lisp process. If you define something once, later listings can use it. This means:

- Run the code in order, from top to bottom.
- If you restart Emacs or Lisp, re-run the definitions the later examples depend on.

=== Editing comfortably

Emacs indents Lisp for you: select a region and press #box[`TAB`], or put the cursor inside a definition and press #box[`C-M-q`] to re-indent it. Indented code is how Lispers read structure, so let Emacs do it.

== Writing and checking your exercise answers

Write your answer where you can run it — a scratch `.lisp` buffer, or straight at the REPL. Exercise 1.1 asks for a function `twice`, so the answer is:

```lisp
(defun twice (n)
  (* n 2))
```

Then check it. Each answer in Appendix D comes with #strong[test lines]. Run them after your definition:

```lisp
(list (twice 4) (twice 0) (twice -3))   ; => (8 0 -6)
```

If your result matches the one in Appendix D, you're done. Your version doesn't need to look like the answer. There are many correct ways to write most things.

Habits that help:

- #strong[Type the examples, don't paste them.] Your fingers learn the shape of Lisp.
- #strong[Break things on purpose.] Delete a parenthesis, misspell a name, and read the error. Every chapter's "Common mistakes" section shows how.
- #strong[If an error window (the debugger) pops up,] press `q` to close it. A later chapter teaches you how to use it properly.

== The running project

Across the chapters you will build a small #strong[text adventure]. You'll walk between rooms, pick up items and type commands. It starts as a few lines of data and grows a little with each chapter. Each project step uses only that chapter's ideas and the ones before it.

