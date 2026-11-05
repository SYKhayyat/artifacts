#import "../lib.typ": *

= The Bigger Picture

The game is built, tested, and shippable. This chapter is the map of what comes next — the ecosystem you can draw from, the references you'll consult, the community you'll join, and the final honest assessment of what "thinking in Lisp" actually means.

== Quicklisp, properly

You've loaded libraries throughout — `fiveam`, `cl-json`, `cl-csv`, `cffi`. Quicklisp's job is larger than "download libraries": it's the curated distribution, updated monthly, with a stability guarantee that makes the ecosystem work. The commands:

```lisp
(ql:system-apropos "json")   ; find systems by substring
(ql:quickload :cl-json)      ; load (and download) one
(ql:who-depends-on :cl-json) ; who uses it?
(ql:update-dist "quicklisp")  ; update the distro index
(ql:update-all-dists)        ; update installed libraries
```

Two habits worth adopting early:

- #emph[Pin your dependencies.] `quickload` fetches the current distro; months later, the same call fetches newer versions. When a project matters, record which distro version it used — Quicklisp's `ql-dist` can lock to a specific distro, and for shared work the heavy-duty tool is `Qlot`, which pins per-project versions in a file. Start by simply noting the distro version in your project's README.
- #emph[Prefer many small libraries over one framework.] Lisp culture composes focused libraries rather than adopting large all-embracing ones — the same instinct as the Unix tools, and the reason Quicklisp has a dozen JSON libraries instead of one.

== The ecosystem, by category

A short field guide, by task. All load with `ql:quickload`. The list isn't exhaustive — it's the "first choice" by category, the libraries you'd find in most modern Lisp projects.

#table(
  columns: (2.0fr, 2.5fr, 3.5fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Task], [Library], [Note]),
  [Files and paths], [uiop], [ships with ASDF; portable path & OS ops],
  [Command-line args], [unix-opts, clingon], [typed options, subcommands, help],
  [JSON], [jonathan, cl-json], [read and write JSON],
  [CSV], [cl-csv], [quoted fields, embedded newlines],
  [Regular expressions], [cl-ppcre], [compiled to Lisp code; fast],
  [Web servers], [hunchentoot, clack], [the veteran \/ the server abstraction],
  [Web framework], [caveman2], [routing, templates, sessions on clack],
  [HTTP client], [dexador, drakma], [requests with headers, forms, SSL],
  [HTML templating], [djula, cl-who], [Django-style \/ s-expressions],
  [Databases (Postgres)], [postmodern, mito], [native protocol \/ ORM],
  [Databases (SQLite)], [cl-sqlite], [embedded, file-based],
  [Threads], [bordeaux-threads, lparallel], [thin portable \/ parallel map-car],
  [Dates and times], [local-time], [timestamps, formatting, arithmetic],
  [Iteration], [iterate, series], [loop alternative \/ fused pipelines],
  [Pattern matching], [trivia, optima], [destructuring `match`],
  [Common data structures], [fset, cl-containers], [immutable sets \/ heaps, queues],
  [Utility belt], [alexandria], [small correct helpers, everywhere],
)

The pattern across all categories: small, composable, standard-loving libraries rather than frameworks that own your program. You assemble; nothing assembles you.

Two of these deserve a longer look, because they show the culture's shape.

`alexandria` is the foundation of the modern Lisp ecosystem — not because it's powerful, but because it's the opposite. A couple of hundred small functions, each correcting some tiny corner of the standard that the standard doesn't reach. `read-file-into-string`, `ensure-list`, `plist-alist`, `hash-table-keys` — none of these is a big idea; each is a small, correct tool that saves you a line. Every project starts with `(ql:quickload :alexandria)` because the cost of depending on it is zero and the savings are steady.

`cl-ppcre` is the opposite: a substantial, ambitious library that compiles regular expressions to Lisp code. You'll meet it in any Lisp program that touches text, and its API shows what the "compile to Lisp" idiom looks like in practice:

```lisp
(ql:quickload :cl-ppcre)

(cl-ppcre:scan-to-strings "\\d+" "abc123def")
;; => "123", #("123")

(cl-ppcre:split "\\s+" "hello world of lisp")
;; => ("hello" "world" "of" "lisp")

(cl-ppcre:regex-replace "noise" "the cave of noise" "silence")
;; => "the cave of silence"
```

The `scan-to-strings` returns the matched substring and a vector of capture groups; `split` takes a regex and a string; `regex-replace` returns a new string with the matched portion replaced. Three functions that cover most text-processing needs, with no framework to learn.

== The Hyperspec habit

The Common Lisp `HyperSpec` is the language standard, hypertext-browsed: every operator's full specification, every detail you've seen hedged as "implementation-defined" or "unspecified" settled in print. The habit to build: when any question survives the REPL's answers, read the Hyperspec entry.

Appendix B installed the lookup: `C-c C-d h` on any symbol opens the right page. Use it for three kinds of question:

+ \/"What does this operator actually do in edge case X?" — the Hyperspec's Description and Examples sections. What `(sort nil #'<)` does, what (parse-integer "12 ") does with trailing whitespace, what `(values)` returns as distinct from `(values nil)` — all specified, all discoverable.
+ \/"Is this standard, or implementation-specific?" — the Definition section says. If you're using something whose spec page you can't find, it isn't standard; you're relying on a specific implementation's extension. Chapter 18's `#+sbcl` conditionals exist for this reason.
+ \/"What conditions can this signal?" — the Exceptional Situations section names them, which connects every Hyperspec entry back to Chapter 19's condition system. Knowing that `parse-integer` signals `parse-error` and not `end-of-file` is what makes a `handler-case` correct.

Reading the Hyperspec is a skill. The entries have a fixed shape — Syntax, Arguments and Values, Description, Examples, Exceptional Situations, Notes — and the "Side Effects" section, when present, is the one that surprises people. "Sort modifies its argument in place" is in the Side Effects of the `sort` page, which is why Chapter 10's rule "always use the return value" exists.

The Glossary section is the standard's own index of ideas: #emph[proper name], #emph[fresh], #emph[literal], #emph[stable], #emph[home package]. Reading those definitions once, at the point when the game has given you the context to understand them, is worth an afternoon. They are the standard's own answer to "what does it mean that Lisp works this way".

== Where the reading goes

Books, in the order this guide leaves you ready for them:

- #emph[Practical Common Lisp] (Seibel) — the classic second book, free online. Real systems (a spam filter, an HTML generator, a streaming MP3 server) built chapter by chapter. Half of it will feel like reviews of what you've just done; the other half will be new. Its introduction to macros and CLOS is gentler than this guide's; its projects are more substantial.
- #emph[Paradigms of Artificial Intelligence Programming] (Norvig) — the classic demonstration of Lisp's style. Norvig writes Lisp the way good Lisp reads: dense, clear, idiomatic. Read the first half (through the pattern matcher), skip the AI chapters if you're not interested, come back to them if you are. The exercises are exceptional.
- #emph[Let Over Lambda] (Hoyte) — macros at full depth. This is a hard book, and deliberately so: it treats macro writing as a discipline with its own idioms and its own pitfalls. Worth reading after you've written a dozen macros of your own and have felt where they hurt.
- #emph[Object-Oriented Programming in Common Lisp] (Keene) — CLOS as a design language. After Chapter 26's and Chapter 27's working knowledge, this is the book that turns CLOS into a design tool rather than a feature.
- #emph[The Art of the Metaobject Protocol] (Kiczales et al.) — how CLOS is built, and how to build like it. The book that changed how a generation of programmers thought about object systems. Readable when CLOS feels like home and you want to know what's underneath.

Online references worth bookmarking:

- The Common Lisp `Cookbook` — task recipes that stay current with the libraries above. When you know what you want to do and not what to call, this is the fastest lookup.
- The `CLiki` — the community wiki, with library listings and how-tos. Older and less reliable than the Cookbook, but sometimes the only place a specific library's quirks are documented.
- The Common Lisp `HyperSpec` — already installed; the habit is worth building before any book, because it's the reference you'll use for years.

== The community

Lisp's community is small and old, in the way a language that's been stable for forty years is. That has consequences: documentation is patchier than Python's or Java's (because the language doesn't change, no one's racing to write the new-version tutorial), community discussions move slower (because there's less to discuss), and library maintenance can be idiosyncratic (because the libraries work, and their authors have moved on to other projects).

The consequences the other way are just as real: the libraries are stable. The language is stable. Solutions published in 1995 still work in 2025. A library you adopt today won't be abandoned by a maintainer who's "moved on to Rust" — it'll be here, tested against every Lisp implementation, in another decade.

Where to find the community:

- The `#lisp` and `#commonlisp` channels on Libera.Chat (IRC, still, after all these years — the Lisp community never left).
- `r/lisp` and `r/Common_Lisp` on Reddit, which have different cultures worth visiting both of.
- The `#lisp` Discord server (more active with newcomers).
- Various Planet Lisp-style blog aggregators, still active.
- The monthly Quicklisp release announcement (subscribe to see what's new).

The culture rewards people who read the standard, write docstrings, publish small systems, and don't make noise. You are now equipped to do all three. The first is what this chapter's Hyperspec section is for; the second Chapter 22's rules; the third is a `ql:quickload` and a README away.

== What "thinking in Lisp" means, honestly

The book's title promised that you'd learn to think in Common `Lisp`. That's a phrase that deserves unpacking, because it's easy to teach syntax and hard to teach the thing under the syntax. Here's what this guide means by it.

Thinking in Lisp isn't fluency in writing `Lisp.` A programmer fluent in Java, given a specification and a week, writes Java. A programmer fluent in Lisp, given the same, writes Lisp the way Java is written, with `loop` where Java has for-loops and `defclass` where Java has class declarations. The code compiles; the tests pass; the programmer is fluent. And the code isn't Lisp.

Thinking in Lisp is fluency in the shapes Lisp thinks `in.` When you're stuck on a problem, what you reach for — the first idea that comes to mind about how to structure the solution — that's the test. For a Java programmer it's "what class do I write?". For a Lisp programmer it's one of these:

- "What data structure represents this?" — the alist, the plist, the hash table, the structure, the class, the closure — the choice determines the function that walks it, and Lisp makes all six available.
- "What's the function that produces this from the data?" — Lisp's functional core means most problems are "transform this sequence into that one", and the sequence functions from Chapter 10 handle most cases without a loop.
- "What could go wrong, and what should the caller be able to do about it?" — the condition system's question, and its answer shapes the function's signature, its signalling, and its restarts.
- "What's the macro that would make this read better?" — the notation question, which only Lisp even asks, because only Lisp lets you answer it.
- "What's the REPL experiment that tells me what's actually happening?" — the discovery question, which replaces "reasoning about the code" with "asking the running program".

The chapters in this book taught these questions by demonstrating them: when Chapter 7 chose an alist for `*rooms*`, when Chapter 8's `set-location` copy-and- rebuild beat `push`'s aliasing, when Chapter 17's `*game-output*` dynamic variable replaced an argument-threading problem, when Chapter 26's CLOS hierarchy arrived at the shape where `describe-thing` varied by class without an `if`. Each of those is a choice from the shape-vocabulary, made because the shape was the right one for the problem. That's the thinking the book was after.

You won't know whether it "took" immediately. The test comes in the next program you start, or the next non-Lisp program you read — do you reach for a class when a closure would do? Do you write a for-loop when a `mapcar` reads more clearly? Do you let a bug hide behind a comment when a condition would surface it? If yes, the shapes are becoming yours. If not, the shapes are still Java-shaped, and the language is a dialect of Java that happens to look different.

The book's whole structure was in service of this: Part I gave you the atoms (numbers, symbols, lists); Part II gave you the shapes those atoms build (conses, recursion, functions-as-values); Part III gave you the tools (loops, `format`, structures, macros, conditions, packages); Part IV gave you the why of those tools (binding, reading, compiling, types, symbols-as-data, closures, classes, packages-as-data); Part V gave you the discipline of shipping (interoperability, streaming, reading strangers' code, executables, tests).

You can now read, understand, write, and extend Common Lisp. The "grok" the guide promised in its introduction is the shapes part — the vocabulary that comes to mind when a new problem arrives. That comes with practice, not with the book.

The best thing the book can do now is suggest what to practice on.

== Three suggestions, in order

+ #strong[Extend the game past the book.] The game you've built is small — five rooms, four item types, one player. It's also #emph[`yours`] in a way a book's exercise never is: you chose the room descriptions, you chose which items go where, you chose how `describe-thing` reads. Add a shop where buying and selling happen; add a monster that moves between rooms; add a save format that survives a schema change; add a room that only opens when the player carries the key. Every addition is a chapter's tools re-applied. And every one teaches something the chapters couldn't, because they had to be ordered.

+ #strong[Write something small and new.] A backup tool, a log analyser, a text adventure generator, a budget calculator. Start with `ql:quickproject` (which scaffolds an `.asd`, a `package.lisp`, a `tests/` directory, and a README), one package, one `.asd`, one file — the Chapter 28 shape, fresh. Do the whole discipline: docstrings, tests, a build script, a README. The game taught you how; a new project teaches you why — because the shapes feel natural this time, and the code reads like Lisp instead of like Lisp-looking Java.

+ #strong[Read one good codebase.] Pick a small Quicklisp library you use — `split-sequence`, `iterate`, `cl-ppcre` if you have patience — and read it end to end. Keep the Hyperspec open beside it. Notice how the author solves the problems you've solved, and where the solutions differ. Notice the docstrings, the comment conventions, the test suite. Reading with the standard at hand is how the remaining rough edges — yours and the language's — get polished off. Chapter 31 was a tour; this is the practice.

The three suggestions have a shape: #emph[more game], #emph[new game], #emph[someone else's game]. That's deliberate. The first teaches extension, the second teaches inception, the third teaches continuation. Together they're the full life of a programmer in any language, and they're what the book's whole structure was pointing at.

The running image, the file, and the REPL: they were the whole method. Every chapter ended in one of them — a `C-c C-c` into a live game, a `with-open-file` to a disk, a REPL experiment that answered a question no amount of reading could. That method is Lisp's method, and it is what the book was teaching all along. Enjoy the language — it rewards exactly the curiosity that got you this far.

== Exercises

#exercise("34.1")[
  Explore the distro: run `(ql:system-apropos "test")` and pick one system you've never heard of. Quickload it and skim its README (find it with `(ql:where-is-system "name")`, then look in that directory). Write one sentence on what it does and whether you'd reach for it.

]

#exercise("34.2")[
  Read the Hyperspec entry for a function you use but don't fully understand — `loop` or `format` or `decode-json` if you like adventure. Write down one sentence you didn't know before the reading, and say which chapter of this guide it corrects or sharpens.

]

#exercise("34.3")[
  Pick a library from the ecosystem table by category, load it with `ql:quickload`, and write three sentences on what it does and whether you'd reach for it in a real project. Then answer: what does the library's README lack that a project's README should have? (The answer is usually the same thing Chapter 31's audit checklist calls out.)

]

#exercise("34.4")[
  Convert `item-names` from Chapter 8 to a generator that yields one name at a time. Compare with the eager version: when would you prefer each? Then convert the generator back to eager processing — what did the conversion cost in code complexity, and what did it buy?

]

#exercise("34.5")[
  Add a `--version` flag to the game's `main` (Chapter 32) that reports both the game's version and the Quicklisp distro version, so `./game --version` tells a user both. The distro version comes from `ql-dist:`; `M-.` on i`(asdf:system-version= (asdf:find-system :quicklisp))` — find the right accessor and use it.

]

#exercise("34.6", project: true)[
  Write the game's `README.md`. A one-page file that a stranger can open and run the game from. Use Chapter 31's audit checklist as the requirement list: what the game does, a usage example, how to build it, how to run the tests. Then answer — in a comment in the README — which parts you had to re-read a chapter to write. Those are the parts of the game you don't yet understand, and they're your own "next thing to learn" list.

]

