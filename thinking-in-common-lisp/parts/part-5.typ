#import "../lib.typ": *

#part("V", "Building Programs")

#part-intro[
  Part IV gave you the mechanisms. When something in Lisp surprises you now, you have a model to reason from.
  
  Part V puts the pieces together into a real program. It is shorter than Part IV because the concepts are already in place; what's new is the practice of #emph[shipping]: talking to the outside world, processing data streams lazily, reading code you didn't write, wrapping the game into an executable, testing it, and knowing where the culture goes next.
  
  The chapters:
  
  - #strong[Chapter 29: Interoperability] — JSON, CSV, shell commands, C via CFFI. How the game exchanges data with the world outside the image, and why the seam is thin on purpose.
  - #strong[Chapter 30: Iterators and Generators] — the closure pattern from Chapter 25 applied to streams, with the design trade-offs made explicit.
  - #strong[Chapter 31: Reading Other People's Lisp] — the audit habits, applied first to your own game, then to any Quicklisp library.
  - #strong[Chapter 32: Building Executables] — SBCL's `save-lisp-and-die`, the build script, the cross-platform story.
  - #strong[Chapter 33: Testing] — what to test, how to wire it into the build, and why the flag-vs-condition rule from Chapters 24 and 19 shapes what's worth testing.
  - #strong[Chapter 34: The Bigger Picture] — libraries, community, where to go after this book.
  
  Every chapter uses the game as its running example. By the end, the game is a binary that runs on a machine that has no Lisp installed, exports its state to JSON and CSV, and has a test suite that refuses to let a broken build ship.
  
]
