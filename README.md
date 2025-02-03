> The library is still WIP and the interface is subject to change.

Are you tired of the same old, boring C macros?  
Do you ever find yourself implementing trivial interfaces over and over again?

*"There must be a better way!"*  

...and there is!  
Introducing the ***revolutionary*** new macro preprocessor:

# BCM - Better C Macros

ummmm 
what was that about?  
Anyway...

> Installatio instructions can be found [here](#installation).

This library brings a preprocesor inspired by Rust's macro system to C.  
Similarly to Rust, two types of macros are supported:

- [functional](#functional-macros)
- [derive macros](#derive-macros)

Although the library will never be as seamless as a built-in macro system the provided utilities should *make* the proces of incorporating macros into your project possible without breaking **everything**.  
For more information check out the [usage](#usage) section.

Usage of BCM does not break comptibility with other C code.  
Check the [ISO C Compatibility](#iso-c-compatibility) section for more information.

Macros will be preprocessed into C code therefore they do not introduce any runtime overhead.

## Functional Macros

Use a new syntax within a macro definition:

```c
#foreach(i in 0..n)
    printf("%d\n", i);
```

```c
#bitwise(n[31] = sing_bit)
```

Create compile-time checked constructors for common structures:
```c
#json({
    "name": "John",
    "age": 42
})

#sql(SELECT * FROM table WHERE id = 42)
```

### Creating Functional Macros

Functional macros can either be defined inline using ***special*** syntax or in a separate file by writing a macro definition in OCaml.

#### Inline Macro 

Created using the following syntax:
```
##macro name_of_macro{
    (tokens to match) => (result tokens)
    ...
}
```

After the definition `name_of_macro` can be used in the code.

Several examples of inline macros can be found in the [examples](examples/inline_functional_macros) directory.

> TODO: Create a guide on how to write inline macros

#### Module Macro

Module macros are defined in a separate file using OCaml syntax.
Project consists of a `BCMMacros` OCaml library that provides all necesary types and macro-installation functions.

Typical functional macro definition looks like this:
```ocaml
(* BCMMacros.macro_tokens -> BCMMacros.macro_token_results *)
let macro_transformer macro_tokens =
  ...

let () =
  BCMMacros.register_decl_macro
  ("macro-name", macro_transformer)
```

> Note that module macros must be brought into scope using the `#bcm_use` directive.

An example of an *module* macro can be found in the [examples](examples/module_functional_macros) directory.

## Derive Macros

Derive macros allow for creating *trait* implementations for structures.

```c
#bcm_use debug

#derive(debug)
struct Name {
    ...
};
```
Will generate an implementation of the `debug` trait for the `Name` structure.

If `debug` trait consists of `void debugPrint(const self*)` function then an implementation for `Name` will generate a function `void Name_debugPrint(const struct Name*)`.

### Creating Derive Macros

Derive macros are created in a similar way to *modular* functional macros.  
They can only be defined in a separate file using OCaml syntax and must be installed via the `BCMMacros` library.

Typical derive macro definition looks like this:
```ocaml
(* BCMMacros.cstruct -> BCMMacros.function_definition list*)
let debug {name; fields; typedef} =
    ...

let () =
  BCMMacros.register_derive_macro
  ("debug", debug)
```

> Note that module macros must be brought into scope using the `#bcm_use` directive.

An example of a derive macro can be found in the [examples](examples/debugPrint) directory.

## Usage

Library comes with two executables:

- `bcm` – a simple preprocessor, good for debugging
- `bcmc` – preprocessor + compiler runner, recommended for building projects

An example of a `Makefile` for a project using BCM can be found here: [Makefile](examples/full_project/Makefile).

### BCM

```
> bcm --help
Usage: bcm [options] <file_name> 
  -I Add a directory to the include path
  -o Output file name
  -help  Display this list of options
  --help  Display this list of options
```

Without `-o` option the preprocessed code will be printed to the standard output.  
The `-I` option can be used to add directories (other than `.`) that will be searched for BCM macro modules.

### BCMC

```
> bcmc --help
Usage: bcmc [options] -- <command> [args]
  -I <path> Adds a path to the include paths
  -v        Verbose mode
  --        End of options, all further arguments will be interpreted as compile command
```

The `bcmc` executable is a wrapper around the `gcc` compiler.
It will preprocess the code similarly to `bcm`, only the files to preprocess will be scraped from the cimpile command arguments.  
Results of parsing will be placed into `*.bcm.c` files – those files will replace original ones in the compile command.

The `-I` option does the same thing as in `bcm` – it adds a directory to the include path.

## ISO C Compatibility

Usage of BCM only affects the compilation unit in which it is used.  
The library does not use any non-standard C features and should work with any C compiler.

To allow for usage of *traits* implemented by derive macros the header file defining the structure should directly define the trait functions that will be implemented.  
The best way of doing this is by creating a header file for derive macro module that contains a **standard** C macro that defines the trait functions for the structure.

```c
// derive_debug.h

/* Debug trait consists of:
 * 
 * Debug information printer:
 * void <name>_debugPrint(const struct <name>*)
 */

#define impl_debug(name) \
    void name ## _debugPrint(const struct name *);
```

Then in the library header file just use the macro:

```c
// NCCoefficients.h
typedef struct NCCoefficients* NCCoefficients;

impl_debug(NCCoefficients)
```

## Installation

After cloning the repository and entering the project directory run the following commands:
```bash
dune build
dune install
```
