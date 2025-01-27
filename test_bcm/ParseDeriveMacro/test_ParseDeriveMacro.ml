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
      { name = "a"
      ; ctype = Basic CInt
      ; attributes = [] };
      { name = "b"
      ; ctype = Basic CFloat
      ; attributes = [] };
      { name = "c"
      ; ctype = Basic CChar
      ; attributes = [] };
      { name = "d"
      ; ctype = Basic CDouble
      ; attributes = [] };
      { name = "e"
      ; ctype = Tdef "uint8_t"
      ; attributes = [] };
    ];
    typedef = Some "test_1ng";
  });
  CCode ";"
])

let awful_field_types = (root_dir ^ "awful_field_types.c", [
  Derive (["ser1al1ze"], {
    name = "test_1ng";
    fields = [
      { name = "a"
      ; ctype = Basic CUInt
      ; attributes = [] };
      { name = "c"
      ; ctype = Basic CUChar
      ; attributes = [] };
      { name = "d"
      ; ctype = Basic CLongDouble
      ; attributes = [] };
      { name = "e"
      ; ctype = Basic CULLong
      ; attributes = [] };
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_pointers = (root_dir ^ "pointers.c", [
  Derive (["deser"], {
    name = "This";
    fields = [
      { name = "str"
      ; ctype = Pointer (Basic CChar)
      ; attributes = [] };
      { name = "a"
      ; ctype = Pointer (Basic CInt)
      ; attributes = [] };
      { name = "e"
      ; ctype = Pointer (Basic CULLong)
      ; attributes = [] };
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_multi_pointer = (root_dir ^ "multi_pointer.c", [
  Derive (["deser"], {
    name = "This";
    fields = [
      { name = "num"
      ; ctype = Pointer (Pointer (Basic CInt))
      ; attributes = [] };
      { name = "horror"
      ; ctype = Pointer (Pointer (Pointer (Pointer (Basic CUShort))))
      ; attributes = [] };
    ];
    typedef = None;
  });
  CCode ";"
])

let parse_array = (root_dir ^ "array.c", [
  Derive (["stuff"], {
    name = "stuff";
    fields = [
      { name = "a"
      ; ctype = Array (Basic CUInt, [10])
      ; attributes = [] };
      { name = "b"
      ; ctype = Array (Pointer (Basic CChar), [0])
      ; attributes = [] };
      { name = "c"
      ; ctype = Array (Basic CChar, [1; 2; 3])
      ; attributes = [] };
    ];
    typedef = Some "ABC";
  });
  CCode ";"
])

let parse_functions = (root_dir ^ "functions.c", [
  Derive (["stuff"], {
    name = "stuff";
    fields = [
      { name = "abc"
      ; ctype = Function (Pointer (Basic CVoid), [Basic CInt; Pointer (Basic CUInt)])
      ; attributes = [] };
      { name = "side_effect"
      ; ctype = Function (Basic CLLong, [Basic CVoid])
      ; attributes = [] };
    ];
    typedef = Some "ABC";
  });
  CCode ";"
])

let parse_attributes = (root_dir ^ "attributes.c", [
  Derive (["attr"], {
    name = "Art";
    fields = [
      { name = "n"
      ; ctype = Basic CInt
      ; attributes = [] };
      { name = "str"
      ; ctype = Pointer (Basic CChar)
      ; attributes = [("string", None); ("str_len", None)] };
      { name = "array"
      ; ctype = Array (Basic CULLong, [0])
      ; attributes = [
        ("len", Some (Ident "n"));
        ("display_name", Some (String "ArrAy"))]}
    ];
    typedef = None;
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
    "Parse attributes",
      [ test_case "check if equal" `Quick (check_file_parsing "Parse attributes" parse_attributes); ];
  ]
