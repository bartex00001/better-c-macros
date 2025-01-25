open CProcessing.Cast


type macro_env


(** Createas an empty macro environment **)
val empty : macro_env


(** Adds a macro definition to the environment **)
val add_decl_macro 
  : macro_env -> string -> macro_def -> macro_env

(** Adds a macro definition to the environment **)
val add_derive_macro
  : macro_env -> string -> unit -> macro_env

(** Attempt to load macro definitions from given shared object file **)
val add_entries_from_file
  : macro_env -> string -> macro_env

  
(** Get declarative macro from the environment.
  * Empty when no macro transformer with given name exists. **)
val get_decl_macro
  : macro_env -> string -> Interpret.token_transformer option
  
(** Get derive macro from the environment.
  * Empty when no macro transformer with given name exists. **)
val get_derive_macro
  : macro_env -> string -> unit option
