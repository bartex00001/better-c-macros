open CProcessing
open MacroGenerator


type file_name = string


let start_env =
  (* TODO: Add standard macro library to environment *)
  MacroEnv.empty


let process_file include_paths filename =
  (* TODO: Add error handling for parser *)
  (* TODO: Make sure the file exists *)
  Eval.parse_file_c filename
  |> Transform.transform_file include_paths start_env


let print_to_file file_name contents =
  let oc = open_out file_name
  in
  Printf.fprintf oc "%s" contents
