

## BCM Workflow

- Pars all arguments to find search path and files to preprocess

- For each file:
  - Parse it into a list containing:
    - `##proc_use(<name>)` directive uses
    - `##macro <name>{ matches... }` functional macro definitions
    - Concrete C syntax fragments
    - `#macro(tokens...)` functional macro uses
    - `#[attribute_name(tokens), ...]` derive macro uses
  - Create an output file
  - Iterate over all syntax elements and...
    - Add macros found in files opened by `##proc_use` to the environment
    - Add functional macros defined in the file to the environment
    - Copy concrete syntax to the new file
    - Execute functional macros and write the result to the output file
    - Execute derive macros and write the result to the output file
  - Save the output file


## Processing of  `##proc_use` directive

This will be used to find either compiled ocaml libraries of macros or declarative macro files.

1. Check search paths for `<name>.bcm` (declarative macros) or `<name>.bbcm` (compiled ocaml macros)
2. If found, add all macros inside those files to the current environment, if not found, throw an error

## Processing of `##macro` directive

This will be used to define a new functional macro.

The macro itself will be transformed into a function that takes a list of tokens and returns a list of tokens.
