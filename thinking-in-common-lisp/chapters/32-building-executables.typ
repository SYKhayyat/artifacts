#import "../lib.typ": *

= Building Executables

Everything so far lived inside a Lisp session. For sharing — or just for the satisfaction of double-clicking — the game can become a standalone program: a file that runs with no REPL, no Emacs, no Lisp installed on the other machine (well, almost — read on).

== Images: what a Lisp session actually is

A running SBCL session is called an #emph[image]: the whole heap of definitions, packages, data and state, alive in memory. Everything the game has been since Chapter 1 is in that image: the functions, the structures, the closure-captured state, the package layout, the loaded libraries, the current value of every earmuffed variable. That's what makes Lisp development feel like editing a living thing — you change a function and the running program uses the new version — and it's what makes deployment an interesting question. What do you #emph[ship]?

Two answers, both from the same function: `save-lisp-and-die`.

== Saving an image to disk

`sb-ext:save-lisp-and-die` writes the image to disk and exits the current process. Two forms of the result:

```lisp
(sb-ext:save-lisp-and-die "/tmp/game.core"
:toplevel #'main)
```

This writes a #emph[core file] — a raw dump of the image, to be loaded by an SBCL that's already installed:

```text
sbcl --core /tmp/game.core
```

The core file is small-ish (a few megabytes for a stripped image, tens for one with all Quicklisp loaded) but useless without `SBCL`. Whoever runs it needs to have SBCL installed.

The other form:

```lisp
(sb-ext:save-lisp-and-die "game"
:executable t
:toplevel #'main)
```

This writes an executable — an image with SBCL's runtime bundled in, self-contained:

```text
./game # on Linux
game.exe # on Windows — SBCL writes the right kind
```

The executable is large — typically 40 to 80 megabytes — because the runtime is included. But it runs on any machine of the same architecture with no Lisp installed. That's the deployment story: #emph[a Lisp program deployed to a user is an executable, and the executable is the whole language runtime plus your code.]

Two more `save-lisp-and-die` options worth knowing:

:compression `t` — compresses the image with zstd. The executable halves in size, at the cost of slightly slower startup. On SBCL builds with `sb-core-compression` (most modern ones), this is worth it.

:save-runtime-options `t` — remembers the runtime options SBCL was started with. Useful for tuning the executable's runtime (stack size, GC behaviour). Skip it unless you know you need it.

== The entry point: `main`

The `:toplevel` function is the executable's first mover. Its job, in order:

Handle `--help`, `--version`, and any other early exits.

For the game, that's:

```lisp
(defun main ()
  "Entry point for the deployed executable."
  (handler-case
    (progn
      (multiple-value-bind (state loaded-p)
        (load-game)
        (if loaded-p
          (restore-state state)
          (progn
            ;; no save yet — start fresh
            (setf current-room (find-room 'kitchen))
            (setf item-locations nil)
            (setf history (make-history)))))
      (play)
      (save-game) ; best-effort save on clean exit
      (sb-ext:exit :code 0))
    (error (c)
      (format error-output "cave: ~A~%" c)
      (sb-ext:exit :code 1))))
```

Read it carefully; each piece is doing something.

The `multiple-value-bind` on `load-game` is Chapter 24's two-value contract, put to work: `loaded-p` tells us whether there was a save to adopt. When there isn't (first run), we set up fresh state.

The sb-ext:exit :code `0` at the end is essential. Without it, SBCL would fall through into its default REPL after `main` returns, and the executable would hang waiting for input. `sb-ext:exit` closes the process immediately.

The two exit codes matter for scripting and CI: 0 means "ran to completion", non-zero means "something went wrong". A shell script that launches `./game` can test `$?` and know whether the run succeeded.

== Building from a script

`save-lisp-and-die` is a single Lisp call, but it shouldn't be typed at the REPL each release. It lives in a build script that the shell runs. A file `build.sh` next to the `.asd`:

```text
#!/bin/sh
sbcl --noinform --non-interactive \
  --eval '(asdf:load-system "cave-of-noise")' \
  --eval '(sb-ext:save-lisp-and-die "game"
           :executable t :compression t
           :toplevel (function cave-of-noise:main))'
```

Reading the flags:

`--noinform` — skip SBCL's startup banner.

`--non-interactive` — exit after the `--eval` forms rather than dropping into a REPL.

The script's structure is a template: load the system, then save. Every release of every SBCL program looks like this in its build script. The variations are in what the `load` does (test suite before build? version bump? cleanup?) and in what options the `save` takes (`:compression`, `:toplevel`, `:executable`).

A minimal Makefile wrapper, for projects that prefer it:

```text
game: build.sh
sh build.sh

clean:
rm -f game
```

That's the whole release process: `make` builds, make `clean` wipes.

One build-script discipline worth stating: build from a fresh `image`, not from the session you've been developing in. The build.sh above starts a new SBCL, which has none of your REPL experiments, redefinitions, or in-progress debugging state. That's exactly what you want — the executable should reflect the files, not the session.

== Command-line arguments

A real program takes arguments: a save file path, a `--version` flag, a command to run without starting the game loop. SBCL exposes the process's arguments in `sb-ext:*posix-argv*`, a list of strings:

```lisp
sb-ext:*posix-argv*
;; => ("/home/you/src/game/game" "--version")
```

The first element is the program's name (as invoked); the rest are the arguments, in order. A typical `main` inspection:

```lisp
(defun main ()
  "Entry point, with argument handling."
  (let ((args (rest sb-ext:*posix-argv*)))
    (cond
      ((member "--help" args :test #'string=)
        (format t "Usage: game [--help] [--version] [--save-file PATH]~%")
        (sb-ext:exit :code 0))
      ((member "--version" args :test #'string=)
        (format t "The Cave of Noise, version 1.0~%")
        (sb-ext:exit :code 0))
      ((member "--save-file" args :test #'string=)
        (let ((path (second (member "--save-file" args
                  :test #'string=))))
          (when path
            (setf save-file path))))
      ;; fall through to game
      (t nil))
    (run-game))) ; the play/save/exit wrapper from before
```

Two things:

:test `#'string` on the `member` calls — arguments are strings, `member` defaults to `eql`, and "help" is not `eql` to "--help".

The dispatch shape (search for the flag, act, exit or fall through) is standard; it doesn't need a library. If the argument set gets complex — dozens of options, subcommands, required\/optional distinctions — reach for `unix-opts` or `clingon` from Quicklisp. For a game with a save-file option and a version flag, the `cond` above is the whole argument parser.

== Cross-platform notes

`sb-ext:save-lisp-and-die` :executable `t` produces a native executable for the platform it runs on. Build on Linux, get a Linux binary; build on Windows, get a Windows executable; to support both, build on both. The build is not cross-platform; the source is.

The Windows-specific concerns:

The generated `.exe` opens a console window by default. That's what you want for a game that reads typed commands; for a GUI application, `sb-ext:*save-lisp-and-die*` has a `:windows-subsystem` option (or you use a different launcher).

Absolute paths in the code should use forward slashes ("C:\/Users\/you\/save.lisp"), not backslashes, because backslash is the escape character in Lisp strings. The filesystem accepts both.

For implementations other than SBCL, `sb-ext:save-lisp-and-die` doesn't exist. CCL has `ccl:save-application` (similar shape), ECL uses `ecl:build-program`, CLISP has `ext:saveinitmem`. If you want portability, isolate the call behind a thin function (Chapter 31's seam discipline):

```lisp
(defun save-executable (path toplevel)
  "Save the current image as an executable at PATH."
  #+sbcl (sb-ext:save-lisp-and-die path
    :executable t
    :compression t
    :toplevel toplevel)
  #+ccl (ccl:save-application path :toplevel-function toplevel)
  ;; etc. — one branch per implementation
)
```

The `#+` conditionals (Chapter 18) select at read time, so only the branch matching your implementation is even a program in the executable. The other branches never exist as code.

== Common mistakes

=== Saving from the wrong image

`save-lisp-and-die` dumps #emph[the current process]. If you call it from your development session — the one you've been debugging in, with experimental functions, half-loaded libraries, and a mutated game state — the executable contains all of that. The build script's fresh SBCL is the antidote: it starts clean, loads the files, saves. The executable reflects the source, not your session.

=== Forgetting `sb-ext:exit`

An executable whose `main` returns falls through to SBCL's default REPL. The program "hangs" (from the user's perspective) because it's waiting for input from a REPL they don't know exists. Every exit path in `main` needs `sb-ext:exit`, and every handler needs it too:

```text
(defun main ()
(play)) ; WRONG — play returns, then REPL
```

versus:

```lisp
(defun main ()
  (play)
  (sb-ext:exit :code 0)) ; right — play returns, program exits
```

=== Exit code 0 for failure

An executable that exits 0 after a crash is a script's worst nightmare: the shell thinks everything worked. The `handler-case` in `main` exits 1 on error — that's the distinction scripts rely on. Return 0 for "did what it should", non-zero for "didn't", and let the caller decide what to do.

=== Losing the debugger

The `handler-case` in `main` catches all errors and translates them to stderr + exit 1. That's right for a deployed executable — the user isn't a Lisp programmer, and a full debugger would be noise. But during development, you want the debugger. Two ways to have both:

Build two executables, one with `handler-case`, one without, from two `toplevel` functions. `main-production` wraps, `main-development` doesn't.

Gate on an environment variable or a command-line flag (`--debug`). `main` checks it and chooses.

For the game, `main-production` is what ships; during development, the REPL is more useful than the executable.

=== Forgetting :compression

An uncompressed executable is 60–100 MB; compressed is 30–50. The startup cost of decompression is a fraction of a second. For distribution, compress; the only reason not to is if startup latency really matters (it doesn't, for a game).

== Project step: release the game

The release, end to end. The build script:

```text
#!/bin/sh
build.sh — the whole build

set -e # stop on first error
sbcl --noinform --non-interactive
--eval "(asdf:load-system "cave-of-noise")"
--eval "(sb-ext:save-lisp-and-die "game"
:executable t
:compression t
:toplevel #'cave-of-noise:main)"
```

The `main` from earlier — with the argument handling, the load-game check, the play-save-exit sequence — is what `:toplevel` points at.

The release steps, in order:

sh `build.sh` builds `./game`.

That's a minimal release test: the executable exists, plays, saves, reloads, handles flags. The full test suite (Chapter 33) checks more, but this sequence catches the common deployment failures — wrong toplevel, missing save directory, unhandled error — before the executable ships.

The final polish — a version string and a welcome message:

```lisp
(defparameter version "1.0")

(defun welcome ()
  "Print the game's opening banner."
  (format t "The Cave of Noise, version ~A.~%" version)
  (format t "Type (look) to begin, (help) for commands,~%")
  (format t "(quit) to exit.~%"))
```

And `play` calls `welcome` at its start. Version in one place, bumped per release, visible to players: the small discipline that separates programs from projects. Chapter 33's tests will read `version` too, so the version the game reports and the version the tests exercise are the same string.

== Exercises

#exercise("32.1")[
  Build the smallest possible executable: a toplevel that prints "hello from a saved image" and exits 0. Build it with a script (or the two forms from a running SBCL), run it from a shell, and record its file size in a comment. Compare with `(defparameter #strong[payload] (make-array 1000000 :initial-element 0))` defined before saving: how much did the payload change the size, and why so little?

]

#exercise("32.2")[
  Write a `main` that takes `--help`, `--version` and --room `NAME` arguments: the last sets the starting room instead of the kitchen. Test all three from a shell. What does --room `attic` do when `attic` doesn't exist, and which chapter's tool handles it?

]

#exercise("32.3")[
  Each snippet is wrong. Say what happens, then fix it.

  ```text
  (sb-ext:save-lisp-and-die "game" :toplevel #'play)

  (defun main ()
  (format t "usage: ...")
  ;; and nothing else, invoked with --help
  )

  (sb-ext:save-lisp-and-die "x" :executable t :toplevel #'main)
  (quit)
  ```

]

#exercise("32.4")[
  Write a `build.sh` that also runs the test suite before building. Add a flag to skip tests for a quick build (`--skip-tests` argument). Write the shell script and the `main` changes needed to test it.

]

#exercise("32.5")[
  Add a `--replay FILE` flag to `main` that reads a transcript from FILE and replays it through `replay-streamed` (Chapter

  instead of starting the interactive loop. Exit 0 on success, 1 on the first unknown command. Why does this flag belong in `main` and not in `play`?

]

#exercise("32.6", project: true)[
  Wrap `save-lisp-and-die` in a function `build-executable` that takes the output path, the toplevel function, and a keyword `:compress` (default `t`). Show how the function can be called from a fresh SBCL (`sbcl --eval '(build-executable "game" '"'cave-of-noise:main)`) so `build.sh` can be reduced to one `--eval`. What does this buy over the direct `save-lisp-and-die` call in the script, and what does it cost?

  #strong[version] is "1.0"

  #strong[history] is a closure (Chapter 25)

  #strong[rooms] is a list of `room` structures (Chapter 13)

  #strong[thing-registry] is a hash table (Chapter 26)

]

