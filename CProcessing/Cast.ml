
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
  (* | L_Paren
  | R_Paren
  | L_Brace
  | R_Brace
  | L_Bracket
  | R_Bracket
  | Semicolon
  | Comma *)

  
type macro_tokens = macro_token list


type macro_matcher_element =
  | DirectMatch of macro_token
  | NamedMatch of ident * macro_token_type

type macro_matcher =
  | BasicMatch of macro_matcher_element
  | SequenceMatch of macro_matcher_element list


type macro_result_element =
  | DirectRes of macro_token
  | NamedRes of ident

type macro_result =
  | BasicRes of macro_result_element
  | SequenceRes of macro_result_element list
  (* TODO: Add non-empty sequence support *)
  | MacroRes of ident * macro_result list


type macro_pattern_match =
  { matcher: macro_matcher list
  ; result: macro_result list
  }

type macro_def =
  { name: string
  ; matches: macro_pattern_match list
  }



type c_elem =
  | CPreprocesor of string
  | CCode of string
  | ProcUse of string
  | MacroDef of macro_def
  | MacroUse of ident * macro_tokens
  (* | Derive of (ident * macro_tokens) list * cstruct *)


type cfile = c_elem list


(* 

type ctype =
  | Tdef of string
  | Pointer of ctype
  | Array of ctype * int
  | Function of ctype * ctype list
  | Struct of ident option * (ctype * ident) list
  | Union of ident option * (ctype * ident) list
  | Enum of ident option * string list

type cstruct = ident * (ctype * ident) list


type c_code = string *)

(* TODO: Define in Declarative Macro subproject *)
(* type macro_def = unit
type tokens = unit
  


type cfile = cfile_element list *)
