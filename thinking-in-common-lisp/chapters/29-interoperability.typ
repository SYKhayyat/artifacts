#import "../lib.typ": *

= Interoperability

Lisp has run your whole game so far without leaving the image — but real programs talk to the world: config files in JSON, data in CSV, command-line tools, C libraries. This chapter is the passport control: shelling out, reading and writing the two data formats you'll meet most, and calling C — with an honest account of where the walls are.

The chapter's guiding principle: #emph[the seam is thin on purpose]. Your Lisp code stays Lisp; the boundary converts between the outside world's shapes and yours in as few places as possible. Every interop layer, if it's large, is a sign the boundary wasn't thought through. Done right, the interop is one file with a handful of functions; done wrong, it's sprinkled through the codebase.

== Shelling out: uiop:run-program

`uiop` (bundled with ASDF, loaded everywhere) is the portable shell:

```lisp
(uiop:run-program '("ls" "-l") :output :string)
;; => the ls output, as one string

(uiop:run-program '("date") :output :string)
```

The argument list is #emph[not] passed through a shell — no quoting games, no injection: each string is one argument, word for word. That's safer than the shell and it's the first thing to know. Options that matter:

```lisp
(uiop:run-program '("grep" "noise" "log.txt")
                  :output :string
                  :error-output :string
                  :ignore-error-status t)

(multiple-value-bind (out err code)
    (uiop:run-program '("false") :output :string
                                 :ignore-error-status t)
  (list out err code))   ; exit status code is the third value
```

Without :ignore-error-status `t`, a non-zero exit signals an error — Chapter 15's `subprocess-error`, catchable like any other. For streaming output line by line instead of collecting it all, the :output `:string` version collects; for large output, stream to a file or use the callback form:

```lisp
(uiop:run-program '("tail" "-n" "100" "cave.log")
                  :output :string)
;; just the last 100 lines, collected
```

The exact keyword for line-by-line processing has drifted across `uiop` versions — `M-.` on `uiop:run-program` and read its docstring; this is the reading skill of Chapter 31 applied within the hour. For input, :input "string" pipes it to the process's stdin.

== Reading and writing CSV

CSV looks trivial and has exactly one trap: quoted fields containing commas. A quick-and-dirty split on commas breaks on real data; the library exists for the general case. For #emph[well-behaved] CSV you produce yourself, Chapter 27's tools suffice:

```lisp
(defun write-csv (rows path)
  "Write ROWS (lists of strings) as naive CSV."
  (with-open-file (out path :direction :output
                            :if-exists :supersede)
    (dolist (row rows)
      (format out "~{~A~^,~}~%" row))))

(write-csv '(("room" "visits")
             ("kitchen" "3")
             ("cellar" "1"))
           "/tmp/visits.csv")
```

`~{~A~^,~}` is Chapter 12's iteration with `~^` cutting the final comma. Reading well-behaved CSV back:

```lisp
(defun read-csv (path)
  "Read naive CSV — no quoted commas — as a list of lists."
  (with-open-file (in path)
    (loop for line = (read-line in nil nil)
          while line
          collect (uiop:split-string line :separator ","))))
```

For CSV from the outside world, use the library: `(ql:quickload :cl-csv)`, whose `(cl-csv:read-csv file)` handles quoting, embedded newlines, and the rest. The lesson generalises: #emph[parse formats you produce; library-parse formats you consume.]

The one shared concern worth noting: both naive CSV and cl-csv write strings, not Lisp objects. If a field can be a number or a symbol or a list, the writer must decide how to render it (`princ-to-string`? `write-to-string`? something schema- specific?) and the reader must decide how to parse it back. That's the schema problem, and CSV doesn't solve it for you.

== Reading and writing JSON

JSON's shapes map onto Lisp's — objects to alists (or plists, or hash tables, library-configurable), arrays to lists, strings\/numbers\/booleans to their Lisp twins. The main library is `jonathan` or `cl-json`; both degrade JSON's `true`\/`false` into `t`\/`nil` or keywords, and `null` into `nil` — the ambiguity you should expect at the edges:

```lisp
(ql:quickload :cl-json)

(cl-json:decode-json-from-string
 "{\"room\": \"kitchen\", \"visits\": 3, \"items\": [\"key\"]}")
;; => ((:ROOM . "kitchen") (:VISITS . 3) (:ITEMS "key"))
```

Note the shape: an #emph[alist with keyword keys] — Chapter 7's `assoc` with Chapter 23's keyword conventions, ready-made:

```lisp
(assoc :visits **)   ; => (:VISITS . 3) — cdr gives 3
```

Encoding:

```lisp
(cl-json:encode-json-to-string
 '((:room . "hall") (:lit . t)))
;; => {"room":"hall","lit":true}
```

Watch two walls. First, `null` vs absence: JSON distinguishes `"k": null` from missing `k`; alist decode makes both `nil` — if your consumer cares, the library has options, or you handle the edge yourself. Second, keyword interning: JSON keys become keywords, so keys from #emph[user data] intern symbols (Chapter 23's keyword warning — fixed vocabularies only). For a save file talking to a web client, define the schema first, decode against it.

`jonathan` is the modern alternative and worth knowing:

```lisp
(ql:quickload :jonathan)
(jonathan:parse "{\"a\": 1, \"b\": [true, null]}")
;; => #<HASH-TABLE :TEST EQUAL ...>
```

Jonathan decodes objects to hash tables by default (which preserves `null` distinctly as `+null+` — a sentinel — rather than collapsing it to `nil`), and has options for alist or plist output. The choice between the two libraries is habit and use-site; both are good.

== Calling C: CFFI

The C foreign-function interface is the one Quicklisp dependency every implementation supports:

```lisp
(ql:quickload :cffi)
```

The pattern, complete for a real (POSIX) function:

```lisp
(cffi:define-foreign-library libc
  (:unix (:or "libc.so.6" "libc.so"))
  (t (:default "libc")))

(cffi:use-foreign-library libc)

(cffi:defcfun ("getpid" c-getpid) :int)

(c-getpid)   ; => the process id, as a Lisp integer
```

Three forms, one each for: where the library `is` (`define-foreign-library`, with per-platform alternatives — Chapter 18's `#+` done by the library), #emph[load it] (`use-foreign-library`), and one C function's `signature` (`defcfun`: C name, Lisp name, return type). Types map the languages: `:int`, `:double`, `:string` (converted automatically, copy in each direction), `:pointer` for the rest.

Structs and pointers, one step deeper:

```lisp
(cffi:defcstruct timeval
  (tv-sec :long)
  (tv-usec :long))

(cffi:with-foreign-object (tv '(:struct timeval))
  (setf (cffi:foreign-slot-value tv '(:struct timeval) 'tv-sec) 0)
  (cffi:foreign-slot-value tv '(:struct timeval) 'tv-sec))
;; => 0
```

`with-foreign-object` is `with-open-file`'s shape for raw memory: allocate on the stack for the body's duration, free automatically. Memory you allocate yourself with `cffi:foreign-alloc` you must `foreign-free` — the resource discipline of every `with-` form, minus the automation.

An honest boundary note: CFFI is `/readable` after this chapter but `/serious` C interop (callbacks, memory management across the boundary, threads) is its own book chapter in other books. The realistic division of labour: call a C library for something Lisp lacks (a hardware binding, a fast codec), keep your logic in Lisp, and treat the FFI layer as a thin, tested seam — a dozen `defcfun` lines in one `ffi.lisp` file, never scattered.

== When to leave the image, and when not to

The game's needs so far have been satisfied in-image, and most programs' are. The decision guide:

- #emph[Text and data formats] — Lisp-native for producing; libraries for consuming (CSV, JSON above).
- #emph[Other programs' functionality] — `uiop:run-program` for batch tools, but remember every shell-out is a fork and a parse boundary: fine for `gzip`, wrong for a per-item loop.
- #emph[C libraries] — only for capability Lisp lacks, and via Quicklisp-wrapped bindings first: check Quicklisp for `cl-sqlite`, `cl-postgres`, `cffi` bindings before writing your own.
- #emph[Performance] — Chapter 21 first; the FFI is not the escape hatch beginners hope: crossing the boundary costs conversion, and SBCL compiles Lisp to machine code already.

== The three failure modes of an interop layer

If you take one mental model from this chapter, take this one: interop fails in three distinct ways, and each wants a different defensive shape.

#emph[Format mismatch.] The outside world produces data in a shape your Lisp didn't expect — a CSV row with the wrong number of fields, a JSON object missing a required key, a shell command returning empty stdout. These are `/expected` failures in the sense of Chapter 24: the caller usually knows what to do (fill defaults, skip the record, try the next file). Defend them with validate-then-use — the shape `game-state-json` uses in the project step below.

#emph[Environment failure.] The file doesn't exist, the command isn't installed, the library isn't on the PATH. These are Chapter 15 conditions: catchable, and the right answer is almost always to surface them with a specific condition type so the caller can distinguish "missing save file" from "corrupt save file".

#emph[World inconsistency.] The bytes on disk or on the wire aren't what the format says they should be — a truncated JSON document, a CSV with an unterminated quote, a response that times out mid-stream. These are the hardest, because the format's own parser usually signals a very generic error that doesn't say #emph[where] it gave up. The reader's `reader-error` is the canonical example. Defensive interop catches these at the seam with a translated, informative condition — never lets them escape as a bare `end-of-file` in the middle of some business logic.

The project step's `import-state-json` (Exercise 29.6) shows all three: it checks field presence (format mismatch), catches file absence (environment failure), and if the JSON is corrupt, the `cl-json` parser signals a jonathan.error:- `invalid-json` or cl-json-equivalent condition (world inconsistency) that the caller translates.

== Common mistakes

=== Building shell command strings

```text
(uiop:run-program (format nil "grep ~A log.txt" term)
                  :output :string)     ; WRONG: through the shell,
                                       ; injection, quoting bugs
```

The list form — `'("grep" term "log.txt")` with the term as one `element` — is the safe call: no shell, no re-parsing. If your term contains spaces or special characters, the list form does the right thing; the string form does whatever the shell's parsing decides.

=== Assuming JSON round-trips

Decode then encode does not always return the original: `null` collapses, key order changes, `1.0` may become `1`, whitespace and Unicode escapes may differ. Treat JSON as an interface format with a schema, not as a serialization of Lisp data — Chapter 16's `print`\/`read` round trip is the Lisp-native serialization, and it stays inside the image for a reason.

=== Forgetting exit codes

`run-program` signals on non-zero exit by default, but a tool that prints an error and exits `zero` will pass silently. Check the output, not just the absence of an error, when the tool's failure mode is quiet.

=== CFFI string conversions in loops

Each `:string` conversion copies. Passing a Lisp string into C per iteration of a million-item loop is a million copies — restructure to pass buffers, or do the loop in Lisp.

=== Trusting input from outside the image

Every byte read from `read`, `parse-integer`, or a JSON parser is untrusted until you've validated it. The reader is particularly dangerous — Chapter 18's `#.` executes arbitrary Lisp at read time. Bind #strong[read-eval] to `nil` before reading anything you didn't write yourself.

== Project step: the game exports its data

A real interop seam, small and useful: the visit report from Chapter 21 leaves the image as CSV, and the game's current state exchanges with a hypothetical web front end as JSON.

The CSV export: `visit-report` returns a list of (count room-symbol) lists. That's the data to write.

```lisp
(defun export-visits-csv (path)
  "The visit report as CSV."
  (write-csv
   (cons '("room" "visits")
         (mapcar (lambda (entry)
                   (list (string-downcase
                          (symbol-name (second entry)))
                         (write-to-string (first entry))))
                 (visit-report)))
   path))
```

Note the conversions: the room's `/symbol` is downcased to a string for readability; the count is `write-to-string`'d so the CSV writer receives strings as it expects. CSV is a string-in, string-out format; the conversion lives here, at the seam.

The JSON export — and its first draft that the chapter warns against:

```lisp
;; Wrong: tries to serialise the whole state, including
;; non-JSON-able parts.
(defun game-state-json-WRONG ()
  (cl-json:encode-json-to-string
   (game-state)))    ; game-state includes *history*, which
                     ; is a closure — JSON encoding fails
```

The problem: `game-state` (Chapters 16 and 24) returns a list containing #strong[item-locations], #strong[current-room]'s name, and `*history*` — a #emph[closure object]. JSON can't encode closures, symbols, or hash tables directly. Even before it fails, the shape of `game-state` is Lisp's serialisation format (Chapter 18's `print`\/`read`), not JSON's.

The correct shape — define a schema at the boundary:

```lisp
(defun game-state-json ()
  "The exchangeable slice of state, as a JSON string."
  (cl-json:encode-json-to-string
   `((:room . ,(symbol-name (room-name *current-room*)))
     (:items . ,(mapcar #'symbol-name
                        (items-in *item-locations*
                                  (room-name *current-room*))))
     (:carrying . ,(mapcar #'symbol-name
                           (items-here 'player))))))
```

Check:

```lisp
(setf *current-room* (find-room 'kitchen))
(setf *item-locations* '((lamp . cellar)
                          (key . kitchen)
                          (letter . bedroom)))

(game-state-json)
;; => "{\"room\":\"kitchen\",\"items\":[\"key\"],\"carrying\":[]}"
```

Notice what the schema #emph[includes]: the room's name as a string, the items in that room as strings, the player's carried items as strings. Notice what it #emph[omits]: `*history*` (closure state, not meaningfully exchangeable), the `*thing-registry*` (structured metadata, not player state), `*visits*` (session-local heat map, not relevant to a fresh consumer), and the #emph[internal representation] of anything (symbols become strings; the room's structure is flattened to its name).

The schema is the seam's contract. Every field in it is a promise: "this is what the game exports". Every field not in it is a deliberate omission, not an oversight. When a web front end arrives, it consumes exactly these three fields; when a second version of the game arrives, the schema is what stays compatible.

And the import seam, which the exercises build out:

```lisp
(defun import-state-json (json-string)
  "Restore state from a JSON exchange.  Signals on bad input."
  (let* ((alist (cl-json:decode-json-from-string json-string))
         (room-name (cdr (assoc :room alist)))
         (item-names (cdr (assoc :items alist)))
         (carrying (cdr (assoc :carrying alist))))
    ;; validate before touching state:
    (unless (and room-name (stringp room-name))
      (error "Bad import: :room missing or not a string"))
    (unless (listp item-names)
      (error "Bad import: :items missing or not a list"))
    (unless (listp carrying)
      (error "Bad import: :carrying missing or not a list"))
    (let ((room (find-room (intern (string-upcase room-name)))))
      (unless room
        (error "Bad import: room ~S does not exist." room-name))
      ;; validation complete — only now touch state:
      (setf *current-room* room)
      (setf *item-locations*
            (mapcar (lambda (pair)
                      (cons (intern (string-upcase (first pair)))
                            (intern (string-upcase (second pair)))))
                    *item-locations*))
      (dolist (name item-names)
        (setf *item-locations*
              (set-location *item-locations*
                            (intern (string-upcase name))
                            room-name-sym-of room)))
      (t t))))
```

That draft got tangled in the item-location setting. The honest version separates the schema fields from the storage:

```lisp
(defun import-state-json (json-string)
  "Restore state from a JSON exchange.  Signals on bad input."
  (let* ((alist (cl-json:decode-json-from-string json-string))
         (room-name (cdr (assoc :room alist)))
         (item-names (cdr (assoc :items alist)))
         (carrying (cdr (assoc :carrying alist))))
    ;; validation first — see Exercise 29.6
    (unless (and room-name (stringp room-name))
      (error "Bad import: :room missing or not a string"))
    (unless (and (listp item-names)
                 (every #'stringp item-names))
      (error "Bad import: :items missing or malformed"))
    (unless (and (listp carrying)
                 (every #'stringp carrying))
      (error "Bad import: :carrying missing or malformed"))
    (let ((room (find-room
                 (intern (string-upcase room-name)))))
      (unless room
        (error "Bad import: room ~S does not exist." room-name))
      ;; mutation phase:
      (setf *current-room* room)
      (dolist (name item-names)
        (setf *item-locations*
              (set-location *item-locations*
                            (intern (string-upcase name))
                            (room-name room))))
      (dolist (name carrying)
        (setf *item-locations*
              (set-location *item-locations*
                            (intern (string-upcase name))
                            'player)))
      t)))
```

The shape is what matters: #emph[validate every field before mutating any state]. A partially-applied import (state half-changed, then a validation error) leaves the game in an inconsistent state that no `handler-case` can recover from cleanly. Validation-then-mutation makes the mutation phase atomic in practice: every `error` fires before the first `setf`.

The intern `(string-upcase ...)` pairs are the boundary's case-and-package conversion, stated plainly where they belong: in the seam, once. If a future version of the game changes the symbol names (a rename, a pluralization), this is the one place to update.

Round-trip check:

```lisp
(defun json-roundtrip-test ()
  (let ((json (game-state-json)))
    (setf *current-room* (find-room 'bedroom))
    (setf *item-locations* '((letter . bedroom)))
    (import-state-json json)
    (list (room-name *current-room*)
          (items-in *item-locations* 'kitchen))))
```

Expected: `(KITCHEN (KEY))` — the room and the item back where the JSON said they were.

== Exercises

#exercise("29.1")[
  Predict, then check:

  ```text
  (uiop:run-program '("echo" "hello world") :output :string)
  (uiop:run-program '("echo" "a;b|c") :output :string)

  (cl-json:decode-json-from-string "[1, 2, [3]]")
  (cl-json:decode-json-from-string "{\"a\": null, \"b\": 0}")
  ```

]

#exercise("29.2")[
  Each snippet is wrong or surprising. Say what happens, then fix it.

  ```text
  (uiop:run-program (format nil "ls ~A" dir) :output :string)

  (cl-json:decode-json-from-string
   "{\"key\": \"x\"}")
  (assoc "key" *)

  (uiop:run-program '("gzip" "missing.txt") :output :string)

  (defun json->state (json)
    (setf *current-room*
          (find-room (cdr (assoc :room json)))))
  ```

]

#exercise("29.3")[
  Write `csv->json`, which reads a CSV file (first row headers) and returns its JSON string form: each row an object keyed by the headers, numeric-looking fields as numbers. Say in a comment what your naive number test misses, and when `cl-csv`'s parser becomes necessary.

]

#exercise("29.4")[
  Using `cffi:defcfun` against libc: bind `abs` (one `:int`, returns `:int`) and `getenv` (one `:string`, returns `:string`), call both, and explain what `getenv` returning a `:null-pointer` means and how `cffi:null-pointer-p` guards it. Why does `abs` need no memory management while a hypothetical `malloc` binding would?

]

#exercise("29.5")[
  Write `run-and-parse`, which shells out to a command of your choice that emits one JSON object per line (or simulate one with a helper script), decodes each line, and returns a list of the decoded alists. What does the line-at-a-time design buy over decoding one giant array — and when does it lie?

]

#exercise("29.6", project: true)[
  Add `import-state-json`, the inverse seam to `game-state-json`: decode, validate each field (room exists in `*rooms*`, items exist in the registry), and apply it to the live state — signalling a `bad-import` condition (Chapter 19) naming the first invalid field when validation fails, #emph[before] any state is touched. In a comment: why is validate-then-apply the only safe order here, and which Chapter 24 pattern does the "first invalid field" return value use?

]

