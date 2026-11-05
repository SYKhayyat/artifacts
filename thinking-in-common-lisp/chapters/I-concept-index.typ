#import "../lib.typ": *

= Concept Index

A guided index of the concepts each chapter covered, in chapter order, so it doubles as a table of contents by idea. It is not a name index: it is for looking up #emph[ideas].

== Part I: First Steps

- Ch 1: REPL loop; prefix notation; `C-c C-c` workflow
- Ch 2: evaluation rule; `quote`; atoms vs lists; `nil` truth
- Ch 3: exact numbers (ratios); characters vs strings vs symbols; upper-casing
- Ch 4: `defparameter` vs `defvar`; `let` vs `let*`; earmuffs
- Ch 5: `defun`; `&optional`\/`&key`\/`&rest`; docstrings; the return-value rule
- Ch 6: `if`\/`when`\/`unless`\/`cond`\/`case`; truthiness (only nil is false); `and`\/`or` short-circuit

== Part II: Thinking in Lists

- Ch 7: cons cells; alists; `car`\/`cdr`; sharing
- Ch 8: recursion; base case; accumulator; `trace`
- Ch 9: functions as values; `#'`; closures; higher-order functions
- Ch 10: sequence functions; the four equalities; `sort` is destructive

== Part III: Core Tools

- Ch 11: `dolist`\/`dotimes`\/`loop`; `return` vs `return-from`
- Ch 12: `format` directives; `~{~}` iteration; conditional directives
- Ch 13: structures; hash tables; arrays; multiple values (first contact)
- Ch 14: `defmacro`; backquote; `gensym`; macro hygiene
- Ch 15: signalling; `handler-case`; `restart-case`; interactive restarts
- Ch 16: packages; files; ASDF; the `:serial` rule

== Part IV: The Lisp Way

- Ch 17: lexical vs dynamic scope; earmuffs as discipline; `*game-output*`
- Ch 18: the reader; `*readtable*`; `#=` dispatch; `with-standard-io-syntax`
- Ch 19: `handler-bind`; `muffle-warning`; the condition hierarchy
- Ch 20: `compile-file`\/`load`; three times; `eval-when`
- Ch 21: types as value-properties; `declare`\/`declaim`; `optimize` qualities
- Ch 22: the REPL as workbench; `inspect`\/`describe`\/`break`; reading backtraces
- Ch 23: symbols as five-part records; plists; `get`\/`getf` distinction
- Ch 24: multiple values; `multiple-value-bind`; the single-value context table
- Ch 25: closures as objects; shared environments; closure vs defparameter state
- Ch 26: CLOS; `defclass`\/`defmethod`; `initialize-instance`
- Ch 27: method combination (`+`, `max`); `change-class`; `shared-initialize`
- Ch 28: package internals; `shadow`; the `:use`\/`:import-from` distinction
- Ch 29: JSON\/CSV interop; `uiop:run-program`; CFFI
- Ch 30: generators; the two-value protocol; lazy vs eager
- Ch 31: the reading habit; the library audit checklist
- Ch 32: `save-lisp-and-die`; `:toplevel`; the build script; exit codes
- Ch 33: test discipline; test the behaviour not the internals; one test per bug
- Ch 34: the ecosystem; the Hyperspec habit; "thinking in Lisp"

