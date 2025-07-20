open Alcotest
open CProcessing
open CProcessing.Cast
open CProcessing.PPCast

let parse_channel channel = CParser.file CLexer.read (Lexing.from_channel channel)
let parse_file_c file = parse_channel (open_in file)
let c_elem = testable pp_c_elem comp_c_elem
let root_dir = "../../../../test_bcm/ParseProcUse/"

let small_file =
  ( root_dir ^ "small.c"
  , [ CPreprocesor "#include <stdio.h>"; ProcUse "libName"; CCode "int main ( ) { }" ] )
;;

let large_file =
  ( root_dir ^ "large.c"
  , [ CPreprocesor "#include <stdio.h>"
    ; ProcUse "libName"
    ; CPreprocesor "#include \"fjadfihpqo/ FDGQfqfqwef\""
    ; ProcUse "json1_2_3_4"
    ; ProcUse "ArgParser"
    ; CCode "int main ( ) {"
    ; ProcUse "huh"
    ; CCode "}"
    ] )
;;

let check_file_parsing test_name (file_name, expected) () =
  check (list c_elem) test_name expected (parse_file_c file_name)
;;

let () =
  run
    "ProcUse parsing"
    [ ( "Small Example"
      , [ test_case
            "check if equal"
            `Quick
            (check_file_parsing "Small Example" small_file)
        ] )
    ; ( "Large Example"
      , [ test_case "check if equal" `Quick (check_file_parsing "Larg Example" large_file)
        ] )
    ]
;;
