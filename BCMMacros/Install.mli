open Tokens


(** [register_decl_macro (name, transformer)] registers [transformer]
  * with [name] identifier. *)
val register_decl_macro : (string * token_transformer) -> unit

(** Get registered transformers in list of pairs [name, transformer] *)
val get_decl_macros : unit -> (string * token_transformer) list

(** Clears the iner macro buffer *)
val clear_values : unit -> unit
