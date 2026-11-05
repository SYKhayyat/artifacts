#import "../lib.typ": *

= Glossary

Terms the standard itself defines, plus the ones this guide introduced. Alphabetical.

#[
  #set par(justify: false)
  #table(
    columns: (1.8fr, 6.2fr),
    inset: (x: 6pt, y: 4pt),
    stroke: 0.3pt + luma(200),
    align: left,
    table.header([Term], [Definition]),
    [atom], [Any value that isn't a cons — numbers, symbols, strings, etc.],
    [binding], [The association between a name and a value in a scope],
    [cdr], [The second part of a cons; the tail of a list],
    [car], [The first part of a cons; the first element of a list],
    [class], [A CLOS type; the "template" for its instances],
    [closure], [A function that captures bindings from an enclosing scope],
    [condition], [An object that represents a situation (error, warning, etc.)],
    [cons], [The fundamental pair structure; a cell with two parts],
    [destructive], [A function that modifies its argument; "n"-prefixed by convention],
    [dynamic extent], [The time during which a form's bindings are in force],
    [form], [A Lisp expression; the unit of code],
    [function], [A callable value; the function slot of a symbol],
    [generic function], [A named dispatch target; collects methods],
    [instance], [An object built from a class],
    [keyword], [A self-evaluating symbol whose name begins with `:`],
    [lexical scope], [Scope determined by position in the source text],
    [list], [A chain of conses ending in nil],
    [macro], [A function from forms to forms, run at compile time],
    [method], [One implementation of a generic function's behaviour],
    [multiple values], [Several results returned together, distinguishable by binding],
    [package], [A namespace for symbols],
    [plist], [A flat alternating key\/value list; on symbols, the property list],
    [predicate], [A function returning true\/false (conventionally `-p` suffixed)],
    [proper list], [A list ending in nil],
    [reader], [The parser that turns text into Lisp objects],
    [restart], [A recovery choice offered at a signal site],
    [sequence], [An ordered collection (list, string, vector)],
    [sexp], [A single Lisp form (the reader's output)],
    [shadow], [A package's own symbol for a name it would otherwise inherit],
    [special], [A dynamic variable; its binding follows the call stack],
    [symbol], [A named object with slots for value, function, and plist],
    [tail position], [The last expression a function evaluates before returning],
    [uninterned], [A symbol not in any package's table (e.g., from `gensym`)],
    [value], [What a form evaluates to],
  )
]

