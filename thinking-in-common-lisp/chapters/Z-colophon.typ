#import "../lib.typ": *

= Colophon: How the Guide Grew

This book was written as one continuous conversation, part by part, against a running project that never used an idea before the chapter that taught it. The core — Parts I through III and the game's first rooms — came first; the later chapters were added in response to an audit of what a working Lisp programmer meets that the early chapters had left implicit: the reader and the printer's knobs, multiple values, closures as objects, CLOS beyond the basics, package internals, generators, the disciplines of declarations, of reading strangers' code, of interoperating, of shipping.

The running game — the Cave of Noise — carried every idea in turn: alists for rooms, closures for history, conditions for failsafes, CLOS for items, packages for the split, generators for the streamed replay, and finally `save-lisp-and-die` for the shipped executable. If you worked the project steps, you built a program; if you worked the exercises, you built the reflexes. The two together were the promise: not a reference that tells, but a guide that holds your hand until the hand lets go.

The tools that made it: Emacs, Org mode, SBCL. The tools you now know better than the person who configured your init file did.

