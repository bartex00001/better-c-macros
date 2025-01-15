open DeclAst


let string_of_match_type = function
  | Ident -> "ident"
  | Expr -> "expr"
  | Int -> "int"
  | Float -> "float"
  | String -> "string"
  | Block -> "block"

  
let rec pp_matcher fmt = function
  | DirectMatch id -> Format.fprintf fmt "DirectMatch \"%s\"" id
  | NamedMatch (id, tp) -> Format.fprintf fmt "NamedMatch (\"%s\", %s)" id (string_of_match_type tp)
  | SequenceMatch ms -> Format.fprintf fmt "SequenceMatch [%a]" (Format.pp_print_list pp_matcher) ms

let equal_matcher = (=)


let rec pp_result fmt = function
  | DirectRes id -> Format.fprintf fmt "DirectRes \"%s\"" id
  | NamedRes id -> Format.fprintf fmt "NamedRes \"%s\"" id
  | MacroRes (id, rs) -> Format.fprintf fmt "MacroRes (\"%s\", [%a])" id (Format.pp_print_list pp_result) rs 

let equal_result = (=)


let pp_macro fmt { name; matches } =
  let pp_match_result fmt (m, r) = 
    Format.fprintf fmt "([%a], [%a])" (Format.pp_print_list pp_matcher) m (Format.pp_print_list pp_result) r
  in
  Format.fprintf fmt "{\n\tname: \"%s\";\n\tmatches: [\n%a\n]}" name
  (Format.pp_print_list pp_match_result) matches

let equal_macro = (=)


