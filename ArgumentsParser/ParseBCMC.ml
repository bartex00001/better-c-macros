type file_name = string

type configuration =
  { files : file_name list
  ; include_paths : file_name list
  ; verbose : bool
  ; cmd : file_name
  ; args : string array
  }

let usage_msg =
  "Usage: bcmc [options] -- <command> [args]\n"
  ^ "  -I <path> Adds a path to the include paths\n"
  ^ "  -v        Verbose mode\n"
  ^ "  --        End of options, all further arguments will be interpreted as compile \
     command"
;;

let parse_arguments () =
  (* TODO: do not use mutable state (but it's so convenient...) *)
  let include_paths = ref [ "." ]
  and verbose = ref false in
  let rec match_option = function
    | "--" :: tl -> !verbose, !include_paths, List.rev tl
    | "-v" :: tl ->
      verbose := true;
      match_option tl
    | "-I" :: path :: tl ->
      include_paths := path :: !include_paths;
      match_option tl
    | "--help" :: _ | "-h" :: _ ->
      print_endline usage_msg;
      exit 0
    | _ ->
      print_endline usage_msg;
      failwith "Unexpected argument"
  in
  Sys.argv |> Array.to_list |> List.tl |> match_option
;;

(** Get the name of file where the transformed contents will be written **)
let get_file_name old_file_name = Filename.chop_extension old_file_name ^ ".bcm.c"

let extract_files_from_args args =
  let rec get_c_files files_acc args_acc = function
    | [] -> files_acc, args_acc
    | file :: rest ->
      if Filename.check_suffix file ".c"
      then (
        let new_file_name = get_file_name file in
        get_c_files (file :: files_acc) (new_file_name :: args_acc) rest)
      else get_c_files files_acc (file :: args_acc) rest
  in
  get_c_files [] [] args
;;

let parse () =
  let verbose, include_paths, cmd = parse_arguments () in
  let files, args =
    match cmd with
    | [] -> failwith "No command given"
    | cmd -> extract_files_from_args cmd
  in
  { files; include_paths; verbose; cmd = List.hd args; args = Array.of_list args }
;;
