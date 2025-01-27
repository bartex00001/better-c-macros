open Alcotest
open CProcessing
open CProcessing.Cast
open MacroGenerator


let parse_channel channel =
  CParser.file CLexer.read (Lexing.from_channel channel)

let parse_file_c file =
  parse_channel (open_in file)

let root_dir = "../../../../test_bcm/TransformFile/"


(* We provide the tokens *directly* via CCode, so the formatting is preserved. *)
let simplest_token_transformation = ([
    CPreprocesor("#include <stdio.h>");
    CCode("int main() {printf(\"Hello World\");}");
  ],
    "#include <stdio.h>\n"
    ^ "int main() {printf(\"Hello World\");}\n"
  )

let use_macro_ommited = ([
    CPreprocesor("#include <stdio.h>");
    (* ProcUse("serialize"); *)
    (* TODO: Mock macro library import *)
    CCode("int main() {printf(\"Hello World\");}");
  ],
    "#include <stdio.h>\n"
    ^ "int main() {printf(\"Hello World\");}\n"
  )

  let macro_def_ommited = ([
    CPreprocesor("#include <stdio.h>");
    MacroDef({
      name = "serialize";
      matches = [{
        matcher = [BasicMatch(DirectMatch(Direct("serialize")))];
        result = [BasicRes(DirectRes(Direct("serialize")))];
      }];
    });
    CCode("int main() {printf(\"Hello World\");}");
    MacroDef({
      name = "deserialize123";
      matches = [{
        matcher = [BasicMatch(DirectMatch(Direct("deserialize")))];
        result = [BasicRes(DirectRes(Direct("deserialize")))];
      }];
    });
  ],
    "#include <stdio.h>\n"
    ^ "int main() {printf(\"Hello World\");}\n"
  )


let minimal_parse_and_transform = (root_dir ^ "minimal.c", " b \n")


let check_as_bytes_example = (root_dir ^ "as_bytes.c",
    "unsigned * n ; (  (  uint8_t  *  )  (  n  )  )  [ 2 ] \n"
  )

let check_as_bytes_complete_example = (root_dir ^ "as_bytes_complete.c",
    "unsigned * n ; (  (  uint8_t  *  )  (  n  )  )  [ 1 +  ( 2 *  x  )  ] \n"
  )

let check_bitwise_example = (root_dir ^ "bitwise.c",
    " n  =  (  n  &  ~  ( 1 <<  ( 5 )  )  )  |  (  (  (  typeof  (  n  )  )  (  true  )  & 1 )  <<  ( 5 )  ) ;"
    ^ " n  |=  (  (  typeof  (  n  )  )  (  a  &&  b  )  & 1 )  <<  ( 1 + 1 ) ;"
    ^ " n  &=  (  (  typeof  (  n  )  )  (  a  ||  (  b  ^^  c  )  )  & 1 )  <<  ( 1 %  (  (  b  )  )  ) ;\n"
  )


let counter_example = (root_dir ^ "counter.c", " + 1-1 + 1-1 + 0\n")


let check_file_transformation test_name (tokens, expected) () = check string test_name expected (Transform.transform_file [] MacroEnv.empty tokens)

let parse_and_check_transformation test_name (file_name, expected) =
  let tokens = parse_file_c file_name in
  check_file_transformation test_name (tokens, expected)


let () =
  run "Macro transformation" [
    "Simplest token transformation",
      [ test_case "check if equal" `Quick (check_file_transformation "Test transformation" simplest_token_transformation); ];
    "Use macro ommited in print",
      [ test_case "check if equal" `Quick (check_file_transformation "Test transformation" use_macro_ommited); ];
    "Macro def ommited in print",
      [ test_case "check if equal" `Quick (check_file_transformation "Test transformation" macro_def_ommited); ];
    "Minimal parse and transform",
      [ test_case "check if equal" `Quick (parse_and_check_transformation "Test transformation" minimal_parse_and_transform); ];
    "Check as_bytes example",
      [ test_case "check if equal" `Quick (parse_and_check_transformation "Test transformation" check_as_bytes_example); ];
    "Check as_bytes complete example",
      [ test_case "check if equal" `Quick (parse_and_check_transformation "Test transformation" check_as_bytes_complete_example); ];
    "Check bitwise example",
      [ test_case "check if equal" `Quick (parse_and_check_transformation "Test transformation" check_bitwise_example); ];
    "Counter example",
      [ test_case "check if equal" `Quick (parse_and_check_transformation "Test transformation" counter_example); ];
  ]
