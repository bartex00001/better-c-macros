open Alcotest
open CProcessing.Print
open BCMMacros

let minimal_struct = (
    { name = "test"
    ; fields = []
    ; typedef = None
    },
    "struct test {  }"
  )

let basic_fields = (
    { name = "basic"
    ; fields = [
      Basic CInt, "a"; Basic CULLong, "u_l_l"; Tdef "uint64_t", "u64"
    ]
    ; typedef = None
    },
    "struct basic { int a; unsigned long long u_l_l; uint64_t u64;  }"
)

let pointers = (
    { name = "pointers"
    ; fields = [
      Pointer (Basic CInt), "a"; Pointer (Pointer (Basic CULLong)), "u_l_l"; Pointer (Tdef "uint64_t"), "u64"
    ]
    ; typedef = None
    },
    "struct pointers { int* a; unsigned long long** u_l_l; uint64_t* u64;  }"
)

let arrays = (
    { name = "arrays"
    ; fields = [
      Array (Basic CInt, [5]), "a"; Array (Pointer (Basic CULLong), [5; 5]), "u_l_l"; Array (Tdef "uint64_t", [5]), "u64"]
    ; typedef = None
    },
    "struct arrays { int a[5]; unsigned long long* u_l_l[5][5]; uint64_t u64[5];  }"
)


let functions = (
    { name = "functions"
    ; fields = [
      Function (Basic CInt, [Basic CInt; Basic CInt]), "a";
      Function (Pointer (Tdef "uint64_t"), []), "u64"
    ]
    ; typedef = None
    },
    "struct functions { int (*a)(int, int); uint64_t* (*u64)();  }"
)

let cstruct = (
    { name = "s"
    ; fields = [
      Struct (Some "a", []), "s";
      Struct (None, [Basic CInt, "num"; Basic CBool, "b"]), "s2";
    ]
    ; typedef = Some "s_t"
    },
    "typedef struct s { struct a {  } s; struct { int num; bool b;  } s2;  } s_t"
)

let union = (
    { name = "u"
    ; fields = [
      Union (Some "a", []), "u";
      Union (None, [Basic CInt, "num"; Basic CBool, "b"]), "u2";
    ]
    ; typedef = Some "u_t"
    },
    "typedef struct u { union a {  } u; union { int num; bool b;  } u2;  } u_t"
)

let enum = (
    { name = "e"
    ; fields = [
      Enum (Some "a", ["A"; "B"; "C"]), "e";
      Enum (None, ["A"; "B"; "C"]), "e2";
    ]
    ; typedef = Some "e_t"
    },
    "typedef struct e { enum a { A, B, C } e; enum { A, B, C } e2;  } e_t"
)


let check_file_print test_name (cstruct, expected) () = check string test_name expected (string_of_struct cstruct)


let () =
  run "Struct Printing" [
    "Empty Struct",
      [ test_case "check if equal" `Quick (check_file_print "Empty struct example" minimal_struct); ];
    "Basic Fields",
      [ test_case "check if equal" `Quick (check_file_print "Basic fields example" basic_fields); ];
    "Pointers",
      [ test_case "check if equal" `Quick (check_file_print "Pointers example" pointers); ];
    "Arrays",
      [ test_case "check if equal" `Quick (check_file_print "Arrays example" arrays); ];
    "Functions",
      [ test_case "check if equal" `Quick (check_file_print "Functions example" functions); ];
    "Struct",
      [ test_case "check if equal" `Quick (check_file_print "Struct example" cstruct); ];
    "Union",
      [ test_case "check if equal" `Quick (check_file_print "Union example" union); ];
    "Enum",
      [ test_case "check if equal" `Quick (check_file_print "Enum example" enum); ];
  ]
