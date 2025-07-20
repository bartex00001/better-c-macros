open BCMMacros
open CProcessing.Cast

(** Transforms macro definition into a callable token transformator. *)
val token_transformer_of_macro_def : macro_def -> token_transformer
