#import "../lib.typ": *

= Installing SBCL

SBCL (Steel Bank Common Lisp) is the program that runs Lisp code. You type Lisp, and SBCL runs it.

== Linux

Use your package manager:

```sh
# Debian / Ubuntu / Mint
sudo apt install sbcl

# Fedora
sudo dnf install sbcl

# Arch
sudo pacman -S sbcl
```

Check it worked:

```sh
sbcl --version
```

You should see something like `SBCL 2.x.x`. Any recent version is fine for this guide.

== macOS

macOS needs Homebrew for the compiler, then is identical to Linux:

```sh
brew install sbcl
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --load quicklisp.lisp
```

At the `(quicklisp-quickstart:install)` prompt, answer as the Linux section says; the `ql:add-to-init-file` step writes to `~/.sbclrc` exactly as on Linux. Two macOS notes: the Homebrew SBCL is current — skip any web page telling you to build from source — and Gatekeeper may warn the #strong[first] time you run a `sb-ext:save-lisp-and-die` executable; right-click → Open once clears it permanently.

== Windows

+ Go to https:\/\/www.sbcl.org\/platform-table.html and download the Windows installer (`.msi`) for x86-64.
+ Run it and accept the defaults.
+ Open a #strong[new] Command Prompt (Win key, type `cmd`, Enter) and run:

```sh
sbcl --version
```

If you get "'sbcl' is not recognized", SBCL isn't on your PATH. You can still use it from Emacs by giving the full path (see Appendix B). Its location is usually something like `C:\Program Files\Steel Bank Common Lisp\sbcl.exe`. Check that folder to confirm.

== Trying SBCL on its own

Type `sbcl` in a terminal. You get a prompt `*`. Type:

```text
* (+ 1 2)
3
* (exit)
```

That's a REPL (Read, Eval, Print, Loop). Like Python's `>>>` prompt, but you'll mostly use it from inside Emacs.

== Quicklisp (the library installer)

You won't need libraries until Part V. Installing now saves you a detour later.

+ Download https:\/\/beta.quicklisp.org\/quicklisp.lisp into your home folder.
  - Linux: `curl -O https://beta.quicklisp.org/quicklisp.lisp`
  - Windows: save it from the browser into `C:\Users\YourName\`
+ In a terminal, from that folder, run `sbcl --load quicklisp.lisp`
+ At the `*` prompt, type these one at a time:

```text
* (quicklisp-quickstart:install)
* (ql:add-to-init-file)
```

When it asks, press Enter. Then type `(exit)`.

From now on, SBCL loads Quicklisp automatically every time it starts.

== Common mistakes

- #strong["sbcl: command not found" right after installing on Windows:] close and reopen the Command Prompt. Old windows don't see the new PATH.
- #strong[Typing `exit` without parentheses:] SBCL thinks you mean a variable called `exit` and opens the debugger. Type `0` or `(abort)` and press Enter to get out, then type `(exit)`.
- #strong[Running the Quicklisp install twice:] it complains that Quicklisp is already installed. That's harmless. It means the first run worked.

