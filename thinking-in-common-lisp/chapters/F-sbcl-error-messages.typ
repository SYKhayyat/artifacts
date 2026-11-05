#import "../lib.typ": *

= SBCL Error Messages

The error messages you'll meet in this book, alphabetically, with what they mean and where to look. The list isn't exhaustive; it's the ones whose phrasing is less than self-explanatory, or whose fix isn't where the message points.

#[
  #set par(justify: false)
  #table(
    columns: (2.8fr, 5.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Message], [Meaning \/ Where to look]),
    [`The function COMMON-LISP-USER::FOO is undefined.`], [Calling a function that hasn't been defined. Check the spelling, or whether you're in the right package (Ch 16, Ch 28).],
    [`The variable FOO is unbound.`], [Reading a name with no value. Ch 4's `let`, `defparameter`, `defvar` — which one did you mean?],
    [`The value 5 is not of type LIST.`], [A function that takes a list got something else. Common: `length`, `first`, `cdr` with a non-list. Ch 7, Ch 10.],
    [`The value (A B C) is not of type VECTOR.`], [`aref` got a list. Use `nth` for lists, `aref` for arrays (Ch 13).],
    [`The value 2 is not of type (UNSIGNED-BYTE 62).`], [An array index went out of bounds, or negative. Ch 13's `aref`.],
    [`The value NIL is not of type NUMBER.`], [Arithmetic on `nil`. Usually a base case returning the wrong type (Ch 8).],
    [`Invalid number of arguments: 1.`], [Calling a function with too few (or many) arguments. Check the signature with C-c C-d `d` or `describe` (Ch 22).],
    [`Odd number of &KEY arguments.`], [Calling a `&key` function with a keyword and no value, or a positional arg without its keyword (Ch 5).],
    [`Control stack exhausted (no more space for function call frames).`], [Infinite recursion, or recursion too deep for the frames available. Check the recursive call's argument (Ch 8).],
    [`The value NIL is not of type (OR FUNCTION SYMBOL).`], [`funcall` or `apply` on a non-function. Common: quoting a `lambda` (Ch 9).],
    [`Lock on package COMMON-LISP violated when binding FOO.`], [Trying to redefine or rebind a standard symbol (Ch 5). Pick another name.],
    [`Cannot find the external symbol FOO in #<PACKAGE "BAR">.`], [Referencing `bar:foo` where `foo` isn't exported. Double-colon to reach internals (Ch 28).],
    [`Package BAR not found.`], [Using `bar:...` where `bar` isn't a loaded package (Ch 16).],
    [`Reader error on #<...>`], [Syntax error in source: an unbalanced parenthesis, a stray comma, or something the reader couldn't parse (Ch 18).],
    [`end of file`], [Usually an unbalanced parenthesis — the reader kept reading past the last ).  Ch 1, Ch 18.],
    [`The value (PRINT X) found where a LOOP keyword was expected.`], [A plain Lisp form inside `loop` without `do` (Ch 11).],
    [`COMPILED-FUNCTION is not of type FUNCTION.`], [Trying to call something that isn't callable. Usually a typo in a variable that holds a function.],
    [`QUIT is deprecated.`], [`quit` was replaced by `sb-ext:exit`. Use the latter (Ch 32).],
    [`There is no class named FOO.`], [A `defmethod` or `typep` referencing a class that hasn't been defined, or has the wrong name (Ch 26).],
    [`No applicable method for FOO when called with arguments (...).`], [Dispatch found no matching method. Check the specialisers, or add a catch-all (Ch 26, Ch 27).],
    [`The class FOO is not defined.`], [`defclass` or method specialiser on a class that doesn't exist yet. Load order (Ch 26, Ch 20).],
    [`The assertion (= X Y) failed.`], [A `check-type`, `the`, or `assert` failed (Ch 21).],
    [:test (OR ...) is not a valid hash table test.], [make-hash-table `:test` was given something other than `eq`, `eql`, `equal`, or `equalp` (Ch 13).],
    [`Reader error: comma not inside a backquote.`], [A , outside a    template (Ch 14).],
    [`Unmatched }` (or other reader macro).], [A custom reader macro saw syntax it didn't expect (Ch 18).],
    [`Cannot coerce #<...> to the requested type.`], [`coerce` couldn't produce the target type. Common: `(coerce 'a 'string)`.],
  )
]

