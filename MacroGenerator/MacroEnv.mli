open BCMMacros
open CProcessing.Cast

type include_path = string
type macro_env

(** Createas an empty macro environment **)
val empty : macro_env

(** Adds a macro definition to the environment **)
val add_decl_macro : macro_env -> string -> macro_def -> macro_env

(** Attempt to load macro definitions from given shared object file **)
val add_entries_from_file : include_path list -> macro_env -> string -> macro_env

(** Get declarative macro from the environment. * Empty when no macro
    transformer with given name exists. **)
val get_decl_macro : macro_env -> string -> token_transformer option

(** Get derive macro from the environment. * Empty when no macro transformer
    with given name exists. **)
val get_derive_macro : macro_env -> string -> derive_generator option
