open CProcessing.Cast

(** Type of declarative macro callable token transformators. *)
type token_transformer = macro_tokens -> macro_token_results

(** Transforms macro definition into a callable token transformator. *)
val token_transformer_of_macro_def : macro_def -> token_transformer
