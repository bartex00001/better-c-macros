open Cast


let pp_macro_token_type fmt = function
  | TIdent -> Format.fprintf fmt "Ident"
  | TInt -> Format.fprintf fmt "Int"
  | TFloat -> Format.fprintf fmt "Float"
  | TString -> Format.fprintf fmt "String"
  | TChar -> Format.fprintf fmt "Char"
  | TExpr -> Format.fprintf fmt "Expr"
  | TToken -> Format.fprintf fmt "Token"


let pp_macro_token fmt = function
  | Ident id -> Format.fprintf fmt "Ident(%a)" Format.pp_print_string id
  | Direct s -> Format.fprintf fmt "Direct(%a)" Format.pp_print_string s
  | Int i -> Format.fprintf fmt "Int(%d)" i
  | Float f -> Format.fprintf fmt "Float(%f)" f
  | String s -> Format.fprintf fmt "String(%a)" Format.pp_print_string s
  | Char c -> Format.fprintf fmt "Char('%c')" c
  | EndToken -> ()


let pp_macro_result_element fmt = function
  | DirectRes token -> Format.fprintf fmt "DirectRes(%a)" pp_macro_token token
  | NamedRes id -> Format.fprintf fmt "NamedRes(%a)" Format.pp_print_string id


let rec pp_macro_result fmt = function
  | BasicRes elem ->
      Format.fprintf fmt "BasicRes(%a)" pp_macro_result_element elem
  | SequenceRes elems ->
      Format.fprintf fmt "SequenceRes(%a)"
      (Format.pp_print_list pp_macro_result_element) elems
  | MacroRes (id, tokens) ->
      Format.fprintf fmt "MacroRes(%a, %a)"
      Format.pp_print_string id
      (Format.pp_print_list pp_macro_result) tokens


let pp_macro_matcher_element fmt = function
  | DirectMatch token ->
      Format.fprintf fmt "DirectMatch(%a)"
      pp_macro_token token
  | NamedMatch (id, mt) ->
      Format.fprintf fmt "NamedMatch(%a, %a)"
      Format.pp_print_string id pp_macro_token_type mt


let pp_macro_matcher fmt = function
  | BasicMatch elem ->
      Format.fprintf fmt "BasicMatch(%a)"
      pp_macro_matcher_element elem
  | SequenceMatch elems ->
      Format.fprintf fmt "SequenceMatch(%a)"
      (Format.pp_print_list pp_macro_matcher_element) elems


let rec pp_macro_use fmt (id, result_tokens) =
  Format.fprintf fmt "%a, %a"
  Format.pp_print_string id
  (Format.pp_print_list pp_macro_token_result) result_tokens
and pp_macro_token_result fmt = function
  | Tok token -> Format.fprintf fmt "Tok(%a)" pp_macro_token token
  | Use use -> pp_macro_use fmt use

let pp_c_elem fmt = function
  | CPreprocesor s -> Format.fprintf fmt "CPreprocesor(%a)" Format.pp_print_string s
  | CCode s -> Format.fprintf fmt "CCode(%a)" Format.pp_print_string s
  | ProcUse s -> Format.fprintf fmt "ProcUse(%a)" Format.pp_print_string s
  | MacroDef { name; matches } ->
    Format.fprintf fmt "MacroDef{\nname = %a;\nmatches = %a"
    Format.pp_print_string name (Format.pp_print_list (fun fmt pattern ->
      Format.fprintf fmt "{ matcher = %a,\n result = %a}"
        (Format.pp_print_list pp_macro_matcher) pattern.matcher
        (Format.pp_print_list pp_macro_result) pattern.result
    )) matches
  | MacroUse muse ->
    Format.fprintf fmt "MacroUse(%a)"
    pp_macro_use muse


let comp_c_elem = (=)
