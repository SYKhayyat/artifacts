#import "../lib.typ": *

#heading(level: 1, numbering: none)[Part V review]

Part V put the game into the world. The chapters:

- Chapter 29 built the interop seam: JSON and CSV for exchanging data, `uiop:run-program` for shelling out, CFFI for calling C — and the discipline of keeping the seam thin on `purpose`, with three failure modes (format mismatch, environment failure, world inconsistency) each defended differently.
- Chapter 30 built generators from closures and multiple values: the two-value protocol, the source\/transform\/consume vocabulary, the resource discipline of `:close`, and the honest boundary where laziness ends (append of two infinite sources, the value of eager lists).
- Chapter 31 taught reading as a skill: the shape of a system, the comment conventions, the prologue idioms, and the audit checklist for evaluating unfamiliar code.
- Chapter 32 shipped the executable: `save-lisp-and-die`, the build script, the entry point, the argument handling, the release test.
- Chapter 33 made the discipline concrete: test the behaviour not the internals, one test per bug, green tests gate the build.
- Chapter 34 (this chapter) is the map of what comes next: the ecosystem, the references, the community, and the closing statement about what "thinking in Lisp" means.

The game, at the end of Part V, is a standalone binary that runs on a machine with no Lisp installed, exports its state to JSON and CSV, has a test suite that refuses to ship a broken build, and is built by a script that tests before it builds. That's a program, not a collection of functions.

The appendices that follow are the reference apparatus: the installation and Emacs setup guides, the answers to the exercises, a consolidated table of the project's redefinitions across chapters, the SBCL error messages you will meet, the full source of the finished game, a glossary of the standard's own terms, and a concept index in chapter order.

