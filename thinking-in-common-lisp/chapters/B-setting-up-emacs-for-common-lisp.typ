#import "../lib.typ": *

= Setting Up Emacs for Common Lisp

Your Emacs config was written for you, so step 1 finds out what you have. Then you add a small block of settings.

== Step 1: Find your config file

In Emacs, press `C-h v`, type `user-init-file` and press Enter.

A help window shows a file path. Note it down:

- Path contains `doom` → you use #strong[Doom Emacs]. See "If you use Doom" below.
- Path contains `spacemacs` or the file is `.spacemacs` → see "If you use Spacemacs" below.
- Anything else (often `~/.emacs.d/init.el`, `~/.config/emacs/init.el` or `~/.emacs`) → plain Emacs. Follow step 2.

Close the help window with `q`.

== Step 2: Check whether a Lisp mode is already installed

Your config might already include SLIME or SLY. These are the two packages that connect Emacs to Lisp. Only one should be active.

Press #box[`M-x`] and type `sly`. If a command called exactly `sly` shows up, SLY is installed. Press #box[`C-g`] to cancel.

- #strong[SLY is there:] use the SLY version in step 3.
- #strong[SLY isn't there:] use the SLIME version (the guide's default).

== Step 3: Add the settings

Open your config file (#box[`C-x C-f`], then type the path from step 1). Go to the very end (#box[`M->`]) and paste #strong[one] of these settings blocks.

=== SLIME version (default)

```emacs-lisp
;;; ---- Common Lisp setup ----
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(use-package slime
  :ensure t
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (slime-setup '(slime-fancy)))
```

=== SLY version (only if step 2 found SLY)

Same as above, but replace the `use-package slime` part with this:

```emacs-lisp
(use-package sly
  :ensure t
  :init
  (setq inferior-lisp-program "sbcl"))
```

With SLY, wherever this guide says `M-x slime`, type `M-x sly` instead.

=== Windows: if `sbcl` isn't on your PATH

Replace `"sbcl"` with the full path, using forward slashes:

```emacs-lisp
(setq inferior-lisp-program
      "C:/Program Files/Steel Bank Common Lisp/sbcl.exe")
```

== Step 4: Restart and test

+ Save the config file (#box[`C-x C-s`]) and quit Emacs (#box[`C-x C-c`]).
+ Start Emacs again. The first start after this change downloads SLIME (or SLY), so it may take up to a minute. Wait until it finishes.
+ Type `M-x slime` (or `M-x sly`) and press Enter. A window titled `*slime-repl sbcl*` (or `*sly-mrepl*`) opens with a prompt like `CL-USER>`. Lisp is now running.
+ At the `CL-USER>` prompt, type `(+ 1 2)` and press #box[`RET`]. Lisp answers `3`.

== Step 5: Run code from a buffer

Typing at the prompt is one half of the loop. The other half is sending an expression from a file to Lisp.

+ Open a new file ending in `.lisp` (#box[`C-x C-f`], then `hello.lisp`). Type `(+ 1 2)` and save (#box[`C-x C-s`]).
+ Put the cursor after the closing parenthesis and press #box[`C-c C-c`]. The first time, Emacs starts Lisp for that buffer. You should see the value `3` in the echo area at the bottom of the frame — not in the buffer itself.

If both work, you're set. Go back to "How to Use This Guide" and start Part I. If not, read "Common mistakes" at the end of this appendix.

== Hyperspec lookup

The Common Lisp HyperSpec is the standard, browsed like a manual. Install it so `C-c C-d h` works from any symbol:

+ Download the HyperSpec (the Common Lisp HyperSpec mirror of your choice — the landing page offers a tarball) and unpack it somewhere permanent, e.g. `~/docs/HyperSpec/`.
+ Tell Slime where it lives, in your init file:

```emacs-lisp
(setq common-lisp-hyperspec-root
      "file:///home/you/docs/HyperSpec/"
      common-lisp-hyperspec-symbol-table
      "/home/you/docs/HyperSpec/Data/Symbol-Table.text")
```

(Windows users: forward slashes work in these paths even on Windows — `C:/docs/HyperSpec/`.)

Now, with Slime connected: point at any symbol, `C-c C-d h` opens the Hyperspec page; `C-c C-d d` does the same for spec dict entries. A later chapter builds the #strong[habit]#";" this is the #strong[keypress].

== If you use Doom Emacs

Doom keeps your settings in `~/.config/doom/` (or `~/.doom.d/`). If either folder exists, you use Doom, even if step 1 showed a different path. Don't add the settings from step 3. Do this instead:

+ Open `~/.config/doom/init.el`. Find the `:lang` section and remove the `;;` in front of `common-lisp`, so the line reads:

```emacs-lisp
       common-lisp       ; if you've seen one lisp, you've seen them all
```

#enum(start: 2, [In a terminal, run `doom sync` (on Windows it may be `~/.config/emacs/bin/doom sync`), then restart Emacs.])

Doom uses #strong[SLY], so use `M-x sly` wherever this guide says `M-x slime`. Doom also uses Vim-style keys by default. Read "If your keys behave like Vim" in Appendix C.

== If you use Spacemacs

+ Open `~/.spacemacs` (press `SPC f e d` as a shortcut).
+ Find the list called `dotspacemacs-configuration-layers` and add `common-lisp` to it if it's missing:

```emacs-lisp
   dotspacemacs-configuration-layers
   '(
     common-lisp
     ;; ... whatever is already here ...
     )
```

#enum(start: 3, [Restart Emacs (`SPC q R`). Spacemacs uses SLIME, so `M-x slime` works as written.])

== Common mistakes

- #strong["No SLIME connection" or "Not connected" when pressing #box[`C-c C-c`]:] Lisp isn't running yet. Type `M-x slime` (or `M-x sly`) and try again. You need this once per Emacs session.
- #strong["Searching for program: No such file or directory, sbcl":] Emacs can't find SBCL. On Windows, use the full-path setting from step 3. On Linux, check that `sbcl --version` works in a terminal.
- #strong[SLY says SLIME is also loaded and asks to disable it:] your config has both. Answer yes, and keep only one of them in the config.
- #strong[The result is `nil` but you expected printed text:] the printing went to the output; the value at the end is what came back. See "Two kinds of results" in "How to Use This Guide".

