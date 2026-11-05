#import "../lib.typ": *

= The Game's Redefinitions

The game has evolved across the book. This table is the map of every function, variable, structure, or class that was defined more than once — what changed, in which chapter, and which version is current. A reader working straight through will hit "already defined" moments; this table tells you which definitions to keep.

#table(
  columns: (0.7fr, 0.6fr, 6.8fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Name], [Chapters], [What changed, and current version]),
  [`find-room`], [7 → 13], [Ch 7: alist scan with `assoc`. Ch 13: `find` with `:key #'room-name` after `*rooms*` became a list of structures. #emph[Current:] Ch 13.],
  [`take`], [7 → 8 → 14 → 24], [Ch 7: `push` pair on front (buggy — hid old pairs). Ch 8: `set-location` rebuild. Ch 14: wrapped in `with-undo`. Ch 24: two-value return. #emph[Current:] Ch 24 with `with-undo` and `set-location`.],
  [`drop`], [7 → 8 → 14 → 24], [Ch 7: `push` pair (buggy). Ch 8: `set-location` rebuild. Ch 14: registered in `*commands*`. Ch 24: two-value return. #emph[Current:] Ch 24.],
  [`set-location`], [8 → 10], [Ch 8: recursive three-clause walk. Ch 10: `mapcar` with `lambda`. #emph[Current:] Ch 10.],
  [`items-in`], [8 → 10], [Ch 8: recursive walk. Ch 10: `remove-if-not` + `mapcar`. #emph[Current:] Ch 10.],
  [`item-names`], [8 → 12], [Ch 8: recursive with "and". Ch 12: kept Ch 8's version (item-list-string is a separate, comma-only helper). #emph[Current:] Ch 8's (see item-list-string).],
  [`look`], [5 → 8 → 13], [Ch 5: `describe-room`. Ch 8: added items. Ch 13: uses structure accessors (same names). #emph[Current:] Ch 8's body, working with structures.],
  [`describe-room`], [5 → 13], [Ch 5: on alist. Ch 13: structure accessors replace the alist's `first/second/third`. Same function name, same result. #emph[Current:] Ch 13.],
  [`go-to`], [6 → 7 → 13 → 19 → 24], [Ch 6: `cond` with hard-coded garden lock. Ch 7: `find-room` now uses `*rooms*`. Ch 13: checks `room-locked` slot. Ch 19: adds drift warning on unknown exits. Ch 24: two-value return from `call-command`. #emph[Current:] Ch 19 body; two-valued via `call-command` in Ch 24.],
  [`find-room` (Exercise 6.10)], [6 → 7], [The exercise's version; superseded by Ch 7's `assoc` version.],
  [`*rooms*`], [7 → 13], [Ch 7: alist. Ch 13: list of structures. #emph[Current:] Ch 13's.],
  [`*history*`], [14 → 25], [Ch 14: a plain list of alist snapshots. Ch 25: a closure object from `make-history`. #emph[Current:] Ch 25's closure; `snapshot` and `undo` are the public interface and unchanged.],
  [`*commands*`], [9 → 14 → 23 → 33], [Ch 9: alist of symbol→function. Ch 14: added `undo`. Ch 23: `define-command` registers metadata on plists. Ch 33: test references. #emph[Current:] Ch 23's registry; `run-command` unchanged.],
  [`run-command`], [9 → 15 → 24 → 30], [Ch 9: `apply` via assoc. Ch 15: `restart-case` + `program-error` handler. Ch 24: two-value return (`reply`, `known-p`). Ch 30: cooldown check (Exercise 30.6). #emph[Current:] Ch 24's body; Ch 30's cooldown is optional.],
  [`call-command`], [15 → 24], [Ch 15: returns reply (one value). Ch 24: returns `(values reply known-p)`. #emph[Current:] Ch 24's.],
  [`save-game`], [16 → 18 → 24 → 33], [Ch 16: `with-open-file` + `print`. Ch 18: `with-standard-io-syntax` + header line. Ch 24: two-value return (`success-p`, path-or-error). #emph[Current:] Ch 24's.],
  [`load-game`], [16 → 18 → 24 → 33], [Ch 16: `handler-case` on `file-error`. Ch 18: reads header, converts v0. Ch 24: two-value return (`state`, `loaded-p`). #emph[Current:] Ch 24's.],
  [`play`], [9 → 24], [Ch 9: `mapcar` over commands. Ch 24: two-value return (`replies`, `unknowns`). #emph[Current:] Ch 24's.],
  [`transcript`], [11 → 32], [Ch 11: prints with header\/footer. Ch 32: `play-streamed` and `replay-streamed` add streaming variants. #emph[Current:] Ch 11's for eager, Ch 30's for streaming.],
  [`count-unknown`], [11 → 24], [Ch 11: string-matching against unknown message. Ch 24: uses the two-valued `run-command`. #emph[Current:] Ch 24's.],
  [`item-report`], [8 → 11 → 12], [Ch 8: recursive. Ch 11: `loop` with destructuring. Ch 12: `format` with `~@(~A~)`. #emph[Current:] Ch 12's.],
  [`*item-locations*`], [7 → 33], [Ch 7: initial state. Ch 33: reset in tests. The variable itself is the same; only its tests change.],
  [`*save-file*`], [16 → 18], [Ch 16: default `"/tmp/game-save.lisp"`. Ch 18: same. Bound via `let` in tests.],
  [`price` generic], [27 → 33], [Ch 27: `+` combination with methods on `thing`, `container`, `treasure`. Ch 33's test notes the `thing` method contributes 1 to every price. #emph[Current:] Ch 27's, with that note.],
)

The general rule for "already defined" warnings: in the REPL, they're expected and harmless (Chapter 22's redefinition loop). In a file being loaded via ASDF, they mean two chapters' definitions ended up in the same file — usually a sign that one of them should be removed.

