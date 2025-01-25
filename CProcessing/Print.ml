open Cast


let string_of_macro_token = function
  | Direct s -> " " ^ s ^ " "
  | Ident id -> " " ^ id ^ " "
  | Int i -> string_of_int i
  | Float f -> string_of_float f
  | String s -> " \"" ^ s ^ "\" "
  | Char c -> " '" ^ String.make 1 c ^ "' "
  | EndToken -> ""

let string_of_macro_tokens tokens =
  List.map string_of_macro_token tokens
  |> String.concat ""
