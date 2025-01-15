open Alcotest
open CProcessing
open CProcessing.Cast
open CProcessing.PPCast


let parse_channel channel =
  CParser.file CLexer.read (Lexing.from_channel channel)

let parse_file_c file =
  parse_channel (open_in file)


let c_elem = testable pp_c_elem comp_c_elem



let root_dir = "../../../../test_bcm/ParseMacroUse/"
let minimal_file = (root_dir ^ "minimal_general.c", [
  MacroUse("myMacro", [ Ident("abc") ]);
  MacroUse("comples_name1", [ Ident("arr"); Direct("["); Int(0); Direct("]"); ]);
])


let parentheses_file = (root_dir ^ "parentheses.c", [
  MacroUse("math_macro", [
    Direct("("); Int(2); Direct("+"); Int(2); Direct(")"); Direct("/"); Int(3);
  ]);
  MacroUse("very_nested", [
    Direct("("); Direct("("); Direct("("); Direct(")"); Direct(")"); Direct(")");
    Direct("("); Direct("("); Direct("("); Direct(")"); Direct(")"); Direct(")")
  ]);
  MacroUse("strings_skipped", [ String(") well, maybe now! \\\") :(") ]);
  MacroUse("multiline", [ Int(1); Int(2); Int(3) ]);
])

let large_file = (root_dir ^ "large.c", [
  CPreprocesor("#include <stdio.h>");
  ProcUse("libName");
  CPreprocesor("#include \"fjadfihpqo/ FDGQfqfqwef\"");
  ProcUse("json1_2_3_4");
  ProcUse("ArgParser");
  CCode("int main ( ) {");
  ProcUse("huh");
  CCode("foo (");
  MacroUse("mySqrt", [ Int(4); Direct("+"); Ident("num") ]);
  CCode(") ; char * str =");
  MacroUse("concat", [ String("Hello"); Direct(","); String("World") ]);
  CCode("; }");
])


let check_file_parsing test_name (file_name, expected) () = check (list c_elem) test_name expected (parse_file_c file_name)



let () =
  run "MacroUse parsing" [
    "Minimal-general Example",
      [ test_case "check if equal" `Quick (check_file_parsing "Minimal-general Example" minimal_file); ];
    "Large Example",
      [ test_case "check if equal" `Quick (check_file_parsing "Larg Example" large_file); ];
    "Parentheses Example",
      [ test_case "check if equal" `Quick (check_file_parsing "Parentheses Example" parentheses_file); ];
  ]
