open CProcessing
open MacroGenerator

type file_name = string

let start_env =
  (* TODO: Add standard macro library to environment *)
  MacroEnv.empty
;;

let process_file include_paths filename =
  (* TODO: Make sure the file exists *)
  (try Eval.parse_file_c filename with
   | Eval.ParseException (file_name, line, char_start, char_end, token) ->
     Printf.printf
       "Error parsing file %s at line %d, characters %d-%d: %s\n"
       file_name
       line
       char_start
       char_end
       token;
     exit 1)
  |> Transform.transform_file include_paths start_env
;;

let rec mkdir_p path =
  let parent = Filename.dirname path in
  if not (Sys.file_exists parent) then mkdir_p parent;
  if not (Sys.file_exists path) then Unix.mkdir path 0o755
;;

let print_to_file file_name contents =
  let path = Filename.dirname file_name in
  if not (Sys.file_exists path) then mkdir_p path;
  let oc = open_out file_name in
  Printf.fprintf oc "%s" contents
;;
