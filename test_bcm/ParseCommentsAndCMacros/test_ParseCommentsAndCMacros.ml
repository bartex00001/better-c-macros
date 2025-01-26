open Alcotest
open CProcessing
open CProcessing.Cast
open CProcessing.PPCast


let parse_channel channel =
  CParser.file CLexer.read (Lexing.from_channel channel)

let parse_file_c file =
  parse_channel (open_in file)


let c_elem = testable pp_c_elem comp_c_elem



let root_dir = "../../../../test_bcm/ParseCommentsAndCMacros/"

let parse_hello_world = (root_dir ^ "main.c", [
  CPreprocesor("#include <stdio.h>");
  CCode("int main ( ) { printf ( \"\\tHello World!\\n\" ) ; }");
])

let small_file = (root_dir ^ "small.c", [
  CPreprocesor("#include <stdio.h>");
  CPreprocesor("#include <stdlib.h>");
  CCode("int main ( ) { }");
])

let multiline_macro = (root_dir ^ "multiline_macro.c", [
  CCode("int some_var ;");
  CPreprocesor("#define MAX(a, b)     ((a) > (b) ? (a) : (b))");
  CCode("int other_var ;")
])

let weird_comments = (root_dir ^ "weird_comments.c", [
  CCode("void * abc ; int main ( void ) { } char * a = \"I can write here!\" ;");
])

let macro_in_text = (root_dir ^ "macro_in_text.c", [
  CCode("int main ( int argc , char * argv [ ] ) {"
    ^ " char * str = \"#include <iostream>\" ;"
    ^ " char * other = \"#[some args]\" ;"
    ^ " char * tricky = \"\\\"#define abc 123\\\"\" ;"
    ^ " char * yet_another = \"##macro definition(...)\" ; }"
)])


let check_file_parsing test_name (file_name, expected) () = check (list c_elem) test_name expected (parse_file_c file_name)



let () =
  run "C preprocesor and comments removal" [
    "Hello World",
      [ test_case "check if equal" `Quick (check_file_parsing "Hello World" parse_hello_world); ];
    "Smallest Example",
      [ test_case "check if equal" `Quick (check_file_parsing "Smallest Example" small_file); ];
    "Multiline Macro",
      [ test_case "check if equal" `Quick (check_file_parsing "Multiline Macro" multiline_macro); ];
    "Weird Comments",
      [ test_case "check if equal" `Quick (check_file_parsing "Weird Comments" weird_comments); ];
    "Macro in Text",
      [ test_case "check if equal" `Quick (check_file_parsing "Macro in Text" macro_in_text); ];
  ]
