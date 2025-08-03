type file_name = string

type source_file =
  { source : file_name
  ; result : file_name
  }

type configuration =
  { sources : source_file list
  ; include_paths : file_name list
  ; build_dir : string
  ; verbose : bool
  ; cmd : file_name
  ; args : string array
  }

let usage_msg =
  "Usage: bcmc [options] -- <command> [args]\n"
  ^ "  -I<dir>   Adds a path to the include directories\n"
  ^ "  -v        Verbose mode\n"
  ^ "  -b <dir>  Designate a build directory (other than default .build)\n"
  ^ "  --        End of options, all further arguments will be interpreted as compile \
     command"
;;

let default_build_dir = "./.build"

let parse_arguments () =
  (* TODO: do not use mutable state (but it's so convenient...) *)
  let include_paths = ref [ "." ]
  and verbose = ref false
  and build_dir = ref None in
  let rec match_option = function
    | "--" :: tl -> tl
    | "-v" :: tl ->
      verbose := true;
      match_option tl
    | "-b" :: path :: tl when Option.is_none !build_dir ->
      build_dir := Some path;
      match_option tl
    | "-b" :: _ ->
      print_endline usage_msg;
      failwith "Multiple build build directories specified!"
    | "--help" :: _ | "-h" :: _ ->
      print_endline usage_msg;
      exit 0
    | arg :: tl ->
      if String.starts_with ~prefix:"-I" arg
      then (
        let path = String.sub arg 2 (String.length arg - 2) in
        include_paths := path :: !include_paths;
        match_option tl)
      else (
        print_endline usage_msg;
        failwith "Unexpected argument")
    | [] ->
      print_endline usage_msg;
      failwith "Expected '--' designating compilation command"
  in
  let cmd = Sys.argv |> Array.to_list |> List.tl |> match_option in
  !verbose, !include_paths, Option.value ~default:default_build_dir !build_dir, cmd
;;

let file_to_source file =
  let extension = Filename.extension file in
  let result =
    Filename.concat default_build_dir (Filename.chop_extension file ^ ".bcm" ^ extension)
  in
  { source = file; result }
;;

let parse_compiler_arguments compiler_cmd =
  let cmd, args =
    match compiler_cmd with
    | cmd :: args -> cmd, args
    | _ ->
      print_endline usage_msg;
      failwith "Empty compiler command provided"
  in
  let sources, args =
    List.fold_left_map
      (fun acc arg ->
         if Filename.check_suffix arg ".c"
         then (
           let source_file = file_to_source arg in
           source_file :: acc, source_file.result)
         else acc, arg)
      []
      args
  in
  sources, (cmd, args)
;;

let parse () =
  let verbose, include_paths, build_dir, compiler_cmd = parse_arguments () in
  let sources, (cmd, args) = parse_compiler_arguments compiler_cmd in
  let args = List.map (fun x -> "-I" ^ x) include_paths @ args in
  let args = Array.of_list (cmd :: args) in
  let include_paths =
    List.map (Filename.concat build_dir) include_paths @ include_paths
  in
  { sources; include_paths; build_dir; verbose; cmd; args }
;;
