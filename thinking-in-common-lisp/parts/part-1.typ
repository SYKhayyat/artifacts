#import "../lib.typ": *

#part("I", "First Steps")

#part-intro[
  Part I gives you the core of the language: how Lisp reads and runs code, the basic kinds of data, variables, functions and decisions. By the end you will write small programs and read most beginner Lisp code without trouble.
  
]

== A note on reading results

Most blocks in this guide show their expected result as a comment:

```lisp
(+ 1 2)   ; => 3
```

A semicolon starts a comment. Lisp ignores everything from `;` to the end of the line. The `; =>` comment means "this evaluates to". When you run the block with `C-c C-c`, the `#+RESULTS:` line should match.
