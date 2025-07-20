open Tokens
open DeriveMacros

(** [register_decl_macro (name, transformer)] registers [transformer] with
    [name] identifier. *)
val register_decl_macro : string * token_transformer -> unit

(** Get registered transformers in list of pairs [name, transformer] *)
val get_decl_macros : unit -> (string * token_transformer) list

(** [register_derive_macro (name, generator) registers [generator]
    with [name] identifier *)
val register_derive_macro : string * derive_generator -> unit

(** Get registered generators in list of pairs [name, generator] *)
val get_derive_macros : unit -> (string * derive_generator) list

(** Clears the iner macro buffer *)
val clear_values : unit -> unit
