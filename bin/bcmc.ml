open ArgumentsParser
open RunUtilities.Runner

let process_single_file include_paths verbose (source_file : ParseBCMC.source_file) =
  process_file include_paths source_file.source |> print_to_file source_file.result;
  if verbose
  then
    Printf.printf
      "Processed %s and saved result to %s\n"
      source_file.source
      source_file.result
;;

let () =
  let config = ParseBCMC.parse () in
  let _ =
    List.iter (process_single_file config.include_paths config.verbose) config.sources;
    flush_all ()
  in
  Unix.execvp config.cmd config.args
;;
