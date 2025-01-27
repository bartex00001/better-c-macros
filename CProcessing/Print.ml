open BCMMacros


let string_of_macro_token = function
(* TODO: Make it format the output on request. *)
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


let print_basic_type = function
  | CVoid -> "void"
  | CInt -> "int"
  | CUInt -> "unsigned int"
  | CLong -> "long"
  | CULong -> "unsigned long"
  | CLLong -> "long long"
  | CULLong -> "unsigned long long"
  | CShort -> "short"
  | CUShort -> "unsigned short"
  | CFloat -> "float"
  | CDouble -> "double"
  | CLongDouble -> "long double"
  | CChar -> "char"
  | CUChar -> "unsigned char"
  | CBool -> "bool"


let rec print_c_type = function
  | Basic bt -> print_basic_type bt

  | Tdef id -> id

  | Pointer ct -> print_c_type ct ^ "*"

  | Array (ct, dims) ->
    let dims_str = List.map (fun i -> "[" ^ string_of_int i ^ "]") dims |> String.concat "" in
    print_c_type ct ^ dims_str

  | Function (ret, args) -> 
    let args_str = List.map print_c_type args |> String.concat ", " in
    print_c_type ret ^ "(" ^ args_str ^ ")"

  | Struct (Some id, fields) ->
    "struct " ^ id ^ " { " ^ print_fields fields ^ " }"

  | Struct (None, fields) ->
    "struct { " ^ print_fields fields ^ " }"

  | Union (Some id, fields) ->
    "union " ^ id ^ " { " ^ print_fields fields ^ " }"

  | Union (None, fields) ->
    "union { " ^ print_fields fields ^ " }"

  | Enum (Some id, values) ->
    "enum " ^ id ^ " { " ^ String.concat ", " values ^ " }"

  | Enum (None, values) ->
    "enum { " ^ String.concat ", " values ^ " }"


and print_fields = function
  | [] -> ""
  | fields -> List.map (fun (ct, id) -> begin match ct with
    | Array (ct, dims) -> print_c_type ct ^ " " ^ id
      ^ (List.map (fun d -> "[" ^ string_of_int d ^ "]") dims |> String.concat "")
    | Function (ret, args) -> print_c_type ret ^ " (*" ^ id ^ ")("
      ^ (List.map print_c_type args |> String.concat ", ")
      ^ ")"
    | _ ->  print_c_type ct ^ " " ^ id
    end
    ) fields
  |> String.concat "; "
  |> fun s -> s ^ "; "


let string_of_struct cstruct =
  let name = cstruct.name
  in let fields = cstruct.fields |> List.map (fun {name; ctype; _} -> (ctype, name))
  in let (td_pref, td_suf) = match cstruct.typedef with
    | Some id -> "typedef ", " " ^ id
    | None -> "", ""
  in
  td_pref ^ "struct " ^ name ^ " { " ^ print_fields fields ^ " }" ^ td_suf
  (* Semicolon not needed as it is parsed as c token *)
