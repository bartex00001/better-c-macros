open ArgumentsParser
open RunUtilities.Runner

let () =
  let config = ParseBCM.parse () in
  let file_name = config.file_name in
  let result = process_file config.include_paths file_name in
  match config.output_method with
  | Stdout -> print_endline result
  | File out_file_name -> print_to_file out_file_name result
;;
