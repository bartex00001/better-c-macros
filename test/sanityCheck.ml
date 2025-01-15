open Alcotest

let sanity_check () =
  check int "This must work right?" 1 1




let () =
  run "Sanity Testers" [
      "Am I insane", [ test_case "just checking..." `Quick sanity_check; ]
  ]
