
type ident = string


type macro_token_type =
  | TIdent
  | TInt
  | TFloat
  | TString
  | TChar
  | TExpr
  | TToken


type macro_token =
  | Direct of string
  | Ident of ident
  | Int of int
  | Float of float
  | String of string
  | Char of char
  | EndToken

  
type macro_tokens = macro_token list


(** Represents usage of macro [ident] with [macro-tokens] that need
    to be checked for other macru uses first. *)
type macro_use = ident * macro_token_results
and macro_token_result =
  | Tok of macro_token
  | Use of macro_use
and macro_token_results = macro_token_result list


(** Type of declarative macro callable token transformators. *)
type token_transformer = macro_tokens -> macro_token_results
