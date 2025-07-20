open Alcotest

let sanity_check () = check int "This must work right?" 1 1

let () =
  run "Sanity" [ "Sanity check", [ test_case "just making sure..." `Quick sanity_check ] ]
;;
