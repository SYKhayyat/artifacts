#import "../lib.typ": *

= Emacs Survival Guide

This is the smallest set of keys that lets you work comfortably. Learn the first section today. The rest will come with use.

== Reading key names

- #box[`C-x`] means: hold #strong[Control], press `x`.
- #box[`M-x`] means: hold #strong[Alt], press `x`. (M stands for "Meta".) If Alt doesn't work, press and release #strong[Esc], then press `x`.
- #box[`C-x C-f`] means: Control-x, then Control-f. You can keep Control held down for both.
- `C-x b` means: Control-x, release, then plain `b`.
- #box[`RET`] is Enter, #box[`SPC`] is the space bar, #box[`TAB`] is Tab.

== The keys you need today

#table(
  columns: (1.0fr, 7.0fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [What it does]),
  [#box[`C-g`]], [Cancel. Use it whenever you're confused or stuck],
  [#box[`C-x C-f`]], [Open a file (or create a new one)],
  [#box[`C-x C-s`]], [Save],
  [#box[`C-/`]], [Undo],
  [#box[`C-x C-c`]], [Quit Emacs],
  [#box[`M-x`]], [Run any command by name],
)

#box[`C-g`] is the most important key in Emacs. If a prompt appears at the bottom of the screen and you don't know what it wants, press #box[`C-g`] until it goes away.

== Buffers and windows

A #strong[buffer] is anything Emacs has open: a file, the Lisp REPL, a help page. A #strong[window] is a section of the screen that shows a buffer.

#table(
  columns: (0.9fr, 7.1fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [What it does]),
  [`C-x b`], [Switch to another buffer (type part of its name)],
  [`C-x o`], [Move the cursor to the other window],
  [`C-x 1`], [Make the current window fill the screen],
  [`C-x 0`], [Close the current window (the buffer stays open)],
  [`C-x 2`], [Split the screen top and bottom],
  [`C-x 3`], [Split the screen left and right],
  [`C-x k`], [Close a buffer],
)

A good layout for this guide: `C-x 3`, your `.lisp` file on the left, the REPL on the right.

== Moving around

Arrow keys, Page Up\/Down, Home and End all work. These are faster once you know them:

#table(
  columns: (0.7fr, 7.3fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [What it does]),
  [#box[`C-a`]], [Start of line],
  [#box[`C-e`]], [End of line],
  [#box[`M-<`]], [Start of file],
  [#box[`M->`]], [End of file],
  [#box[`C-s`]], [Search forward (repeat #box[`C-s`] for the next match, #box[`RET`] to stop)],
  [#box[`C-r`]], [Search backward],
)

== Copy, cut and paste

Emacs uses its own keys for these:

#table(
  columns: (1.1fr, 6.9fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [What it does]),
  [#box[`C-SPC`]], [Start selecting (then move the cursor)],
  [#box[`M-w`]], [Copy the selection],
  [#box[`C-w`]], [Cut the selection],
  [#box[`C-y`]], [Paste],
)

Selecting with the mouse also works, followed by #box[`M-w`] or #box[`C-w`].

If you'd rather use #box[`C-c`], #box[`C-x`] and #box[`C-v`] like other programs, type `M-x cua-mode`. It stays on until you restart Emacs.

== Lisp keys

These work in the REPL and in `.lisp` files.

#table(
  columns: (0.9fr, 7.1fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [What it does]),
  [#box[`RET`]], [In the REPL: run what you typed],
  [#box[`M-p`]], [In the REPL: bring back the previous input],
  [#box[`M-n`]], [In the REPL: the next input],
  [#box[`C-x C-e`]], [Run the expression just before the cursor],
  [#box[`C-c C-c`]], [In a Lisp buffer: compile the definition under the cursor],
  [#box[`C-c C-k`]], [Compile and load the whole `.lisp` file],
  [#box[`C-M-f`]], [Jump forward over one whole expression],
  [#box[`C-M-b`]], [Jump backward over one whole expression],
  [#box[`C-M-k`]], [Delete the next whole expression],
)

When the cursor is on a parenthesis, Emacs highlights its partner. Watch for this. It's how you check that your parentheses match.

== The debugger window

When your code has an error, a window called `*sldb ...*` (SLIME) or `*sly-db ...*` (SLY) opens. It shows the error message and a list of numbered choices called #emph[restarts].

For now:

- Read the first line. It tells you what went wrong.
- Press `q` to close the window and go back to work.

A later chapter teaches you what the other choices do. They're one of the best features of Lisp.

== Debugger keys

When an error opens the SLDB buffer (the debugger of a later chapter), the keys that matter:

#table(
  columns: (1.0fr, 7.0fr),
  inset: (x: 6pt, y: 4pt),
  stroke: 0.3pt + luma(200),
  align: left,
  table.header([Key], [Action]),
  [`v`], [view the current frame's source],
  [`n` \/ `p`], [next \/ previous frame],
  [`t`], [toggle details of the current frame],
  [`1–9`], [invoke the numbered restart from the menu],
  [`a`], [invoke ABORT (the standard escape restart)],
  [`q`], [quit — abort out of the debugger],
  [`i`], [inspect the current frame's condition],
)

The Inspector buffer: #box[`TAB`] moves between parts, #box[`RET`] descends into one, `l` goes back up. And the trace buffer from `trace`: `g` refreshes. Two habits cover 80% of use: `n` down the frames reading the backtrace, `1` on the restart you decided on — everything else is exploration.

== If your keys behave like Vim

Doom, Spacemacs and many AI-written configs turn on #strong[Evil], which makes Emacs work like the Vim editor. Signs: typing letters doesn't insert text, or the cursor is a solid block and the bottom bar shows `<N>` or `NORMAL`.

The basics:

- Press `i` to start typing text (insert mode).
- Press `Esc` to stop typing and go back to moving around (normal mode).
- Press `:w` then #box[`RET`] to save.
- The `C-` and `M-` keys in this guide mostly still work, including #box[`C-c C-c`].
- Doom and Spacemacs also use #box[`SPC`] in normal mode as a menu key. Press it and wait: a menu of choices appears.

If you'd rather not use Vim keys, type `M-x evil-mode` to turn them off until the next restart.

== If Lisp gets stuck

If an expression never finishes (for example, a loop that never ends):

+ Switch to the REPL buffer (`C-x b`, then type `repl`).
+ Press #box[`C-c C-c`] there to interrupt Lisp. The debugger opens.
+ Press `q`.

If that doesn't help, run `M-x slime-restart-inferior-lisp` (SLY: `M-x sly-restart-inferior-lisp`). This starts a fresh Lisp. Everything you defined is gone, so re-run the earlier definitions.

== Common mistakes

- #strong[Pressing #box[`C-z`] by habit (undo in other programs):] it minimises Emacs, or with Evil switches key styles. Undo is #box[`C-/`]. If the keys suddenly feel different, press #box[`C-z`] again.
- #strong[Pressing #box[`C-x`] and then waiting:] Emacs is waiting for the second key. Finish the combination or press #box[`C-g`].
- #strong[Closing the REPL buffer with `C-x k`:] Lisp may still be running in the background. Run `M-x slime` again; if it asks whether to create an additional connection, answer no.
- #strong[Losing your place in a large file:] #box[`M-<`] and #box[`M->`] jump to the ends, #box[`C-s`] searches forward, and #box[`C-M-f`] moves over whole expressions.

