open Arguments


let () =
  ParseBCM.parse ()
  |> Runner.run
