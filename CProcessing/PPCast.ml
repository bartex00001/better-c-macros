open Cast
open BCMMacros


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


let rec pp_macro_result_element fmt = function
  | DirectRes token -> Format.fprintf fmt "DirectRes(%a)" pp_macro_token token
  | NamedRes id -> Format.fprintf fmt "NamedRes(%a)" Format.pp_print_string id
  | MacroResUse (id, tokens) ->
      Format.fprintf fmt "MacroResUse(%a, %a)"
      Format.pp_print_string id
      (Format.pp_print_list pp_macro_result_element) tokens


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


let pp_basic_type fmt = function
  | CInt -> Format.fprintf fmt "CInt"
  | CUInt -> Format.fprintf fmt "CUint"
  | CLong -> Format.fprintf fmt "CLong"
  | CULong -> Format.fprintf fmt "CULong"
  | CLLong -> Format.fprintf fmt "CLLong"
  | CULLong -> Format.fprintf fmt "CULLong"
  | CShort -> Format.fprintf fmt "CShort"
  | CUShort -> Format.fprintf fmt "CUShort"
  | CFloat -> Format.fprintf fmt "CFloat"
  | CDouble -> Format.fprintf fmt "CDouble"
  | CLongDouble -> Format.fprintf fmt "CLongDouble"
  | CChar -> Format.fprintf fmt "CChar"
  | CUChar -> Format.fprintf fmt "CUChar"
  | CBool -> Format.fprintf fmt "CBool"
  | CVoid -> Format.fprintf fmt "CVoid"


let rec pp_cstruct fmt {name; fields; typedef} =
  Format.fprintf fmt "{%a; %a; %a}"
  Format.pp_print_string name
  (Format.pp_print_list (fun fmt {name; ctype; attributes} ->
    Format.fprintf fmt "{%a, %a, %a}"
    pp_ctype ctype
    Format.pp_print_string name
    (Format.pp_print_list (fun fmt (id, tokens) ->
      Format.fprintf fmt "(%a, %a)"
      Format.pp_print_string id
      (Format.pp_print_option pp_macro_token) tokens
    )) attributes
  )) fields
  (Format.pp_print_option Format.pp_print_string) typedef
and pp_ctype fmt = function
  | Basic b -> Format.fprintf fmt "Basic(%a)" pp_basic_type b
  | Tdef s -> Format.fprintf fmt "Tdef(%a)" Format.pp_print_string s
  | Pointer ctype -> Format.fprintf fmt "Pointer(%a)" pp_ctype ctype
  | Array (ctype, i) ->
    Format.fprintf fmt "Array(%a, %a)"
    pp_ctype ctype
    (Format.pp_print_list Format.pp_print_int) i
  | Function (ctype, ctypelist) ->
    Format.fprintf fmt "Function(%a, %a)"
    pp_ctype ctype
    (Format.pp_print_list pp_ctype) ctypelist
  | Struct (id, fields) ->
    Format.fprintf fmt "Struct(%a, %a)"
    (Format.pp_print_option Format.pp_print_string) id
    (Format.pp_print_list (fun fmt (ctype, id) ->
      Format.fprintf fmt "{%a, %a}"
      pp_ctype ctype
      Format.pp_print_string id
    )) fields
  | Union (id, fields) ->
    Format.fprintf fmt "Union(%a, %a)"
    (Format.pp_print_option Format.pp_print_string) id
    (Format.pp_print_list (fun fmt (ctype, id) ->
      Format.fprintf fmt "{%a, %a}"
      pp_ctype ctype
      Format.pp_print_string id
    )) fields
  | Enum (id, strings) ->
    Format.fprintf fmt "Enum(%a, %a)"
    (Format.pp_print_option Format.pp_print_string) id
    (Format.pp_print_list Format.pp_print_string) strings
  

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
  | Derive (macros, cstruct) ->
    Format.fprintf fmt "Derive(%a, %a)"
    (Format.pp_print_list Format.pp_print_string) macros
    pp_cstruct cstruct


let comp_c_elem = (=)
