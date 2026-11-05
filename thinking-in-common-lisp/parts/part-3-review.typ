#import "../lib.typ": *

#heading(level: 1, numbering: none)[Part III review]

You can now read any list-shaped data at sight, produce text with `format`, build records and lookup tables, write macros that extend the language, handle errors with conditions and restarts, and organise code into packages, files and systems. If any of these feels shaky, the fix is REPL time, not re-reading: take one chapter's exercises and redo two of them from scratch.

The game, at the end of Part III, has rooms as structures (Chapter 13), items as an alist (Chapter 7), a command table with a failsafe runner (Chapters 9 and 15), an undo history (Chapter 14), and the ability to save and load its state (this chapter). From Part IV on, the guide adds the tools that make the game's #strong[own] code — the helpers, not just the game — better: conditions as objects other code can program against, CLOS, packages designed around interfaces, macros that read like syntax, and the reader and printer mechanisms that let save files round-trip through `print` and `read` on data structures Lisp doesn't know about yet.

