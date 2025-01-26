open ArgumentsParser
open RunUtilities.Runner


let process_single_file include_paths verbose file_name =
  let result_file_name = ParseBCMC.get_file_name file_name
  in
  process_file include_paths file_name
  |> print_to_file result_file_name;
  if verbose then
    Printf.printf "Processed %s and saved result to %s\n" file_name result_file_name


let () =
  let config = ParseBCMC.parse ()
  in let include_paths = config.include_paths
  in
  let _ = List.fold_left (fun _ file_name ->
    process_single_file include_paths config.verbose file_name)
    () config.files; flush_all ();
  in
  Unix.execvp config.cmd config.args;
