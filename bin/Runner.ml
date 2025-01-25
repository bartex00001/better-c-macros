open Arguments
open CProcessing
open BCMMacros


let start_env =
  (* TODO: Add standard macro library to environment *)
  MacroEnv.empty


let process_file filename =
  (* TODO: Add error handling for parser *)
  (* TODO: Make sure the file exists *)
  Eval.parse_file_c filename
  |> Transform.transform_file start_env


let print_to_file file_name contents =
  let oc = open_out file_name
  in
  Printf.fprintf oc "%s" contents


(** Get the name of file where the transformed contents will be written **)
let get_file_name old_file_name =
  let file_name = Filename.basename old_file_name
  |> Filename.chop_extension
  in
  file_name ^ ".bcm"


let run (config : ParseBCM.configuration) =
  let files = config.files
  in
  List.fold_right (fun file _ -> 
    process_file file |> print_to_file (get_file_name file)) files () 
