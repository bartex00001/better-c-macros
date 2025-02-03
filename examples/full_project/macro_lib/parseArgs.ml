open BCMMacros


type arg = 
  { name: string
  ; arg_type: basic_type
  ; short: char
  ; description: string option
}


let print_usage fields =
  "printf(\"Usage: %s [options]\\n\", argv0);\n"
  ^ "printf(\"Options:\\n\");\n"
  ^ String.concat "" (List.map (fun arg -> 
      let desc = match arg.description with
        | Some d -> d
        | None -> ""
      in
      "printf(\"  -" ^ (String.make 1 arg.short) ^ "\t\t\t" ^ desc ^ "\\n\");\n"
    ) fields)
  ^ "printf(\"  -h\t\t\tPrint this help message.\\n\");\n"
  ^ "exit(1);\n"

let initialize_self name args =
  let init_field {name; arg_type; short; description} =
    match arg_type with
    | CBool -> "self." ^ name ^ " = false;\n"
    | _ ->
      "bool " ^ name ^ "_used = false;\n"
      ^ "self." ^ name ^ " = 0;\n"
  in
  name ^ " self;\n"
  ^ (String.concat "" @@ List.map init_field args)


let run_checks struct_name fields =
  let check_field {name; arg_type; _} =
    match arg_type with
    | CBool -> ""
    | _ ->
      "if(!" ^ name ^ "_used) {\n"
      ^ "fprintf(stderr, \"Error: " ^ name ^ " is required.\\n\");\n"
      ^ struct_name ^ "_usage(argv[0]);\n"
      ^ "}\n"
  in
  String.concat "" @@ List.map check_field fields

let args_of_fields (fields : field list) =

  let rec find_in_attr key = function
    | (k, Some a) :: rest when k = key -> Some a
    | _ :: rest -> find_in_attr key rest
    | [] -> None
  in

  fields
  |> List.filter (fun field -> field.attributes <> []) 
  |> List.map (fun {name; ctype; attributes} ->
      { name = name
      ; arg_type = (match ctype with | Basic bt -> bt | _ -> failwith "Unsupported field type")
      ; short = find_in_attr "short" attributes |> (function
          | Some (Char c) -> c
          | _ -> failwith "No short attribute found")
      ; description = find_in_attr "desc" attributes |> (function
          | Some (String s) -> Some s
          | _ -> None)
      })


let create_case {name; arg_type; short; _} =
  let case = "case '"^ String.make 1 short ^ "':\n" in
  let assign = "self." ^ name ^ " = "
  in
  let value = match arg_type with
  | CInt -> "atoi(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CUInt -> "atoi(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CLong -> "atol(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CULong -> "atol(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CLLong -> "atoll(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CULLong -> "atoll(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CShort -> "atoi(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CUShort -> "atoi(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CFloat -> "atof(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CDouble -> "atof(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CLongDouble -> "atof(argv[++i]);\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CChar -> "argv[++i][0];\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CUChar -> "argv[++i][0];\n" ^ name ^ "_used = true;\n" ^ "break;"
  | CBool -> "true;\nbreak;"
  | _ -> failwith "Unsupported argument type"
  in case ^ assign ^ value


let create_parser name args =
  let usage_call = name ^ "_usage(argv[0]);\n"
  in
  "for(int i = 1; i < argc; i++) {\n"
  ^ "if(argv[i][0] != '-') " ^ usage_call ^ " \n\n"
  ^ "switch(argv[i][1]) {\n"
  ^ (String.concat "\n" @@ List.map create_case args)
  ^ "\ndefault:\n"
  ^ usage_call
  ^ "}\n}\n"

let parseArgs {name; fields; typedef} =
  let args = args_of_fields fields in
  let contents = print_usage args in
  let usage = "void " ^ name ^ "_usage(const char* argv0) {\n" ^ contents ^ "}\n"
  in
  let initialize = initialize_self name args in
  let arg_parser = initialize ^ (create_parser name args) in
  let check_args = run_checks name args in
  let arg_parser =
    name ^ " " ^ name ^ "_parseArgs(int argc, char** argv) {\n" 
    ^ arg_parser
    ^ check_args
    ^ "return self;\n"
    ^ "}\n"
  in
  [usage; arg_parser]


let () =
  register_derive_macro ("parseArgs", parseArgs)
