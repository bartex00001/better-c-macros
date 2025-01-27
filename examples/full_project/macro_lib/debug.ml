open BCMMacros


let get_formatter = function
  | Basic CInt -> "%d"
  | Basic CUInt -> "%u"
  | Basic CLong -> "%ld"
  | Basic CULong -> "%lu"
  | Basic CLLong -> "%lld"
  | Basic CChar -> "%c"
  | Basic CUChar -> "%c"
  | Basic CFloat -> "%f"
  | Basic CDouble -> "%lf"
  | _ -> failwith "Unsupported type"


let printf_basic prefix sufix what basic_type =
  "printf(\"" ^ prefix ^ (get_formatter basic_type) ^ sufix ^ "\"," ^ what ^");\n"
  

let print_array_inner ctype name len =
  "for(int i = 0; i < " ^ len ^"; i++){\n"
  ^ printf_basic "" ", " ("self->" ^ name ^ "[i]") ctype
  ^ "}"


let printf_field (ctype, name) =
  match ctype with
  | Basic CInt | Basic CUInt -> "printf(\"\t" ^ name ^" = %d\\n\", self->" ^ name ^ ");\n"
  | Array (ctype, _) -> print_array_inner ctype name "self->n"
  | _ -> failwith "Unsupported field type"

let debug {name; fields; typedef} = 
  let decl = "void " ^ name ^ "_debugPrint(const struct " ^ name ^ " *self) {\n"
  in
  let printf_fields = List.map printf_field fields
  and printf_start = "printf(\"" ^ name ^ " {\\n\");\n"
  and printf_end = "printf(\"}\\n\");\n"
  in
  [decl ^ printf_start ^ (String.concat "\n" printf_fields) ^ printf_end ^ "}\n"]


let () =
  register_derive_macro ("debug", debug)
