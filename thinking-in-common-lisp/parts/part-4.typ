#import "../lib.typ": *

#part("IV", "The Lisp Way")

#part-intro[
  Part I gave you the language. Part II gave you lists and recursion. Part III gave you the tools a working program uses: loops, formatted output, records and lookups, macros, conditions, packages, files.
  
  Part IV goes #emph[under] those tools. It explains the mechanisms whose behaviour you've been trusting:
  
  - where names live and how binding actually works (lexical and dynamic scope, closures, special variables);
  - how Lisp reads text into data, and how that single mechanism underlies the reader macros, the save-file round trip, and `format`'s printing direction;
  - the condition system's other half — non-unwinding handlers, the restart toolkit, the condition hierarchy;
  - what compilation and loading actually do to your code, and why `eval-when` exists;
  - what types mean in a dynamically typed language, and why declarations matter anyway;
  - what a symbol is as a data structure, including the plist slot you haven't touched yet;
  - what multiple values are, and how they differ from lists;
  - closures as objects, including the constructor idiom that makes them cheap state;
  - the parts of CLOS beyond `defclass` and `defmethod`;
  - packages as data structures you can query and manipulate;
  - generators, built from closures and values;
  - the habits of reading other people's Lisp;
  - the practical interoperability layer — JSON, CSV, shelling out, C via CFFI.
  
  None of this is new #emph[language]. All of it is new #emph[understanding]. At the end of Part IV, when something in Lisp surprises you, you'll have a model to reason from, not just a set of behaviours to memorise.
  
  The project continues to grow as the chapters demand — undo histories in Chapter 17's exercise, the game's public interface in Chapter 24's project step, and the executable in Part VI.
  
]
