open BCMMacros

let printf_str str = "printf(\"" ^ str ^ "\");\n"

let get_formatter = function
  | CInt -> "%d"
  | CUInt -> "%u"
  | CLong -> "%ld"
  | CULong -> "%lu"
  | CLLong -> "%lld"
  | CChar -> "%c"
  | CUChar -> "%c"
  | CFloat -> "%f"
  | CDouble -> "%lf"
  | _ -> failwith "Unsupported type"
;;

let printf_basic prefix sufix what bt =
  "printf(\"" ^ prefix ^ get_formatter bt ^ sufix ^ "\"," ^ what ^ ");\n"
;;

let printf_typed prefix sufix what t_name =
  "printf(\""
  ^ prefix
  ^ "\");\n"
  ^ "__"
  ^ t_name
  ^ "_debugPrint("
  ^ what
  ^ ", indent+1);\n"
  ^ "printf(\""
  ^ sufix
  ^ "\");\n"
;;

let rec get_len_of_attributes = function
  | ("length", Some (Int n)) :: rest -> Some (Int n)
  | ("length", Some (Ident n)) :: rest -> Some (Ident n)
  | _ :: rest -> get_len_of_attributes rest
  | [] -> None
;;

let print_array_inner ctype name len =
  "for(int i = 0; i < "
  ^ len
  ^ "; i++){\n"
  ^ (match ctype with
     | Basic bt -> printf_basic "" ", " ("self->" ^ name ^ "[i]") bt
     | _ -> failwith "Unsupported array type")
  ^ "}"
;;

let printf_field { name; ctype; attributes } =
  let res =
    match ctype, attributes with
    | _, [ ("hide", None) ] -> ""
    | Basic bt, [] -> printf_basic (name ^ " = ") ";\\n" ("self->" ^ name) bt
    | Tdef t_name, [] -> printf_typed (name ^ " = ") " " ("&self->" ^ name) t_name
    | Pointer _, [] -> printf_str (name ^ " = <pointer>;\\n")
    | Pointer (Basic CChar), [ ("str", None) ] ->
      "printf(\"" ^ name ^ " = \\\"%s\\\";\\n\", self->" ^ name ^ ");\n"
    | Pointer (Basic bt), [ ("deref", None) ] ->
      "if(self->"
      ^ name
      ^ " != NULL){\n"
      ^ printf_basic ("*" ^ name ^ " = ") ";\\n" ("*self->" ^ name) bt
      ^ "} else {\n"
      ^ printf_str (name ^ " = <null>;\\n")
      ^ "}\n"
    | Pointer ctype, [ ("length", Some (Int n)) ] ->
      printf_str (name ^ " = [")
      ^ print_array_inner ctype name (string_of_int n)
      ^ printf_str "];\\n"
    | Pointer ctype, [ ("length", Some (Ident n)) ] ->
      printf_str (name ^ " = [")
      ^ print_array_inner ctype name ("self->" ^ n)
      ^ printf_str "];\\n"
    | Array (ctype, [ n ]), [] when n > 0 ->
      print_array_inner ctype name (string_of_int n)
    | Array (ctype, [ 0 ]), [ ("length", Some (Int n)) ] ->
      printf_str (name ^ " = [")
      ^ print_array_inner ctype name (string_of_int n)
      ^ printf_str "];\\n"
    | Array (ctype, [ 0 ]), [ ("length", Some (Ident n)) ] ->
      printf_str (name ^ " = [")
      ^ print_array_inner ctype name ("self->" ^ n)
      ^ printf_str "];\\n"
    | _ -> failwith "Unsupported field type"
  in
  if res = "" then res else "_printIndent(indent+1);\n" ^ res
;;

let print_interlude = ref true

let debug { name; fields; typedef } =
  let interlude =
    if !print_interlude
    then (
      print_interlude := false;
      "void _printIndent(int n){while(n--) printf(\"\\t\");}\n")
    else "void _printIndent(int n);"
  in
  let decl =
    interlude
    ^ "void __"
    ^ name
    ^ "_debugPrint(const struct "
    ^ name
    ^ " *self, int indent) {\n"
  in
  let printf_fields = List.map printf_field fields
  and printf_start = "printf(\"" ^ name ^ " {\\n\");\n"
  and printf_end = "_printIndent(indent);\n" ^ "printf(\"};\\n\");\n" in
  let decl_direct =
    "void "
    ^ name
    ^ "_debugPrint(const struct "
    ^ name
    ^ " *self){\n"
    ^ "__"
    ^ name
    ^ "_debugPrint(self, 0);\n"
    ^ "}\n"
  in
  [ decl ^ printf_start ^ String.concat "\n" printf_fields ^ printf_end ^ "}\n"
  ; decl_direct
  ]
;;

let () = register_derive_macro ("debug", debug)
