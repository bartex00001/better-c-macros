open BCMMacros


(** Converts a list of c tokens into c code. *)
val string_of_macro_tokens : macro_tokens -> string

(** Converts a c-struct AST into c code. *)
val string_of_struct : cstruct -> string
