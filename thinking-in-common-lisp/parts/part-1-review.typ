#import "../lib.typ": *

#heading(level: 1, numbering: none)[Part I review]

You now know the core of Lisp:

- Code is made of atoms and lists. A list is evaluated by calling its first element with the values of the rest. `quote` stops evaluation.
- The everyday atoms are numbers (with exact ratios), characters, strings and symbols.
- `defparameter` and `defvar` make global variables. `let` and `let*` make local ones. `setf`, `incf` and `decf` change them.
- `defun` makes functions. The last expression is the return value. `&optional`, `&key` and `&rest` make parameter lists flexible.
- `if`, `when`, `unless`, `cond` and `case` make choices. Only `nil` is false.

The adventure has rooms, descriptions, a `look` command and moves that follow the exits. Before moving on, scroll back through the project steps from Chapter 1 to Chapter 6 and read the code without running it. If you can say what each line does, you're ready for Part II.

