open Alcotest
open CProcessing
open CProcessing.Cast
open CProcessing.PPCast


let parse_channel channel =
  CParser.file CLexer.read (Lexing.from_channel channel)

let parse_file_c file =
  parse_channel (open_in file)


let c_elem = testable pp_c_elem comp_c_elem


let root_dir = "../../../../test_bcm/ParseDeriveMacro/"

let empty_struct = (root_dir ^ "empty_struct.c", [
  Derive (["debug"], {
    name = "Test";
    fields = [];
    typedef = None;
  });
  CCode ";"
])

let multiple_derives = (root_dir ^ "multiple_derives.c", [
  Derive (["abc"; "cde"; "a123"], {
    name = "abc";
    fields = [];
    typedef = None;
  });
  CCode ";"
])

let basic_fields = (root_dir ^ "basic_fields.c", [
  Derive (["ser1al1ze"], {
    name = "test_1ng";
    fields = [
      (Basic CInt, "a");
      (Basic CFloat, "b");
      (Basic CChar, "c");
      (Basic CDouble, "d");
      (Tdef "uint8_t", "e");
    ];
    typedef = Some "test_1ng";
  });
  CCode ";"
])

let awful_field_types = (root_dir ^ "awful_field_types.c", [
  Derive (["ser1al1ze"], {
    name = "test_1ng";
    fields = [
      (Basic CUInt, "a");
      (Basic CUChar, "c");
      (Basic CLongDouble, "d");
      (Basic CULLong, "e");
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_pointers = (root_dir ^ "pointers.c", [
  Derive (["deser"], {
    name = "This";
    fields = [
      (Pointer (Basic CChar), "str");
      (Pointer (Basic CInt), "a");
      (Pointer (Basic CULLong), "e");
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_multi_pointer = (root_dir ^ "multi_pointer.c", [
  Derive (["deser"], {
    name = "This";
    fields = [
      (Pointer (Pointer (Basic CInt)), "num");
      (Pointer (Pointer (Pointer (Pointer (Basic CUShort)))), "horror");
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_array = (root_dir ^ "array.c", [
  Derive (["stuff"], {
    name = "stuff";
    fields = [
      (Array (Basic CUInt, [10]), "a");
      (Array (Pointer (Basic CChar), [0]), "b");
      (Array (Basic CChar, [1; 2; 3]), "c");
    ];
    typedef = Some "ABC";
  });
  CCode ";"
])

let parse_functions = (root_dir ^ "functions.c", [
  Derive (["stuff"], {
    name = "stuff";
    fields = [
      (Function (Pointer (Basic CVoid), [Basic CInt; Pointer (Basic CUInt)]), "abc");
      (Function (Basic CLLong, [Basic CVoid]), "side_effect")
    ];
    typedef = Some "ABC";
  });
  CCode ";"
])

let check_file_parsing test_name (file_name, expected) () = check (list c_elem) test_name expected (parse_file_c file_name)



let () =
  run "Derive Macro Parsing" [
    "Empty struct",
      [ test_case "check if equal" `Quick (check_file_parsing "Empty struct" empty_struct); ];
    "Multiple derives",
      [ test_case "check if equal" `Quick (check_file_parsing "Multiple derives" multiple_derives); ];
    "Basic fields",
      [ test_case "check if equal" `Quick (check_file_parsing "Basic fields" basic_fields); ];
    "Awful field types",
      [ test_case "check if equal" `Quick (check_file_parsing "Awful field types" awful_field_types); ];
    "Parse pointers",
      [ test_case "check if equal" `Quick (check_file_parsing "Parse pointers" parse_pointers); ];
    "Parse multi pointer",
      [ test_case "check if equal" `Quick (check_file_parsing "Parse multi pointer" parse_multi_pointer); ];
    "Parse array",
      [ test_case "check if equal" `Quick (check_file_parsing "Parse array" parse_array); ];
    "Parse functions",
      [ test_case "check if equal" `Quick (check_file_parsing "Parse functions" parse_functions); ];
  ]
