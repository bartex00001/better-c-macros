open Arguments


let () =
  let args = ParseBCM.parse ()
  in
  Printf.printf "Verbose: %b\n" args.verbose;
  Printf.printf "Include paths: %s\n" (String.concat ", " args.include_paths);
