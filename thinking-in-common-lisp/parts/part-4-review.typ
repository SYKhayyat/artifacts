#import "../lib.typ": *

#heading(level: 1, numbering: none)[Part IV review]

Part IV was the part that looked inside. Every chapter took something you had been using on trust and showed you the mechanism underneath:

- Chapter 17 split #strong[where a name lives in the text] from #strong[when it lives at all]: lexical scope, dynamic binding, and the earmuffs that announce which one you are looking at.
- Chapter 18 turned the reader from a black box into a configurable stage — read syntax, case conversion, readtables, and `with-standard-io-syntax` as the rule that makes a save file mean the same thing tomorrow.
- Chapter 19 took the one-shot deal of `handler-case` apart and rebuilt error handling as `handler-bind`, the condition hierarchy, and restarts you choose from rather than catch.
- Chapter 20 named the three times — read, compiled, loaded — and made `eval-when` the ordinary consequence it is.
- Chapter 21 turned declarations into promises: a local `declare`, a global `declaim`, `(optimize ...)` as a dial, and the measurements that show what they buy.
- Chapter 22 made the REPL a workbench: the inspector, deliberate `break`s, backtraces read from the bottom, redefinition of running code, and what to do when the image itself is sick.
- Chapter 23 took a symbol apart into its five parts and drew the line that matters: plists for constants about names, owned structures for state about things.
- Chapter 24 showed that `values` are not lists — `multiple-value-bind` and `multiple-value-call`, the single-value contexts, and the `return` trap that silently eats the second value.
- Chapter 25 gave closures a job: constructors that run once, shared environments as objects, and the habit of asking whether state belongs in a closure or in a `defparameter`.
- Chapters 26 and 27 did CLOS twice — the model, then the corners: `call-next-method`, the class precedence list, `shared-initialize`, `change-class`, and method combination as the alternative to inheriting behaviour.
- Chapter 28 opened the symbol table by hand, so that a package became an interface you design rather than a `defpackage` you copy.

The game, at the end of Part IV, is no longer a handful of rooms and a list of symbols. Items are `thing` instances registered under their symbols in `*thing-registry*`, while `*item-locations*` still says where each one is; `price` is a generic function whose `+` combination adds base value, kind and premium without touching the methods already written; `run-command` returns two values; the command history is a closure; and the package exports an eight-name API — `play`, the five commands, `save-game`, `load-game`, `run-command` — that the rest of the world is allowed to touch. Everything else is private on purpose.

If any of this feels shaky, the fix is REPL time, not re-reading: take one chapter's exercises and redo two of them from scratch. Part V takes this program out of the image — talking to other systems, generating data instead of collecting it, reading code you did not write, an executable you can hand to someone, and the tests that keep it honest.

