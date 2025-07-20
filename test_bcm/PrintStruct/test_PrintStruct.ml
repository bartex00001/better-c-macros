open Alcotest
open CProcessing.Print
open BCMMacros

let minimal_struct = { name = "test"; fields = []; typedef = None }, "struct test {  };\n"

let basic_fields =
  ( { name = "basic"
    ; fields =
        [ { name = "a"; ctype = Basic CInt; attributes = [] }
        ; { name = "u_l_l"; ctype = Basic CULLong; attributes = [] }
        ; { name = "u64"; ctype = Tdef "uint64_t"; attributes = [] }
        ]
    ; typedef = None
    }
  , "struct basic { int a; unsigned long long u_l_l; uint64_t u64;  };\n" )
;;

let pointers =
  ( { name = "pointers"
    ; fields =
        [ { name = "a"; ctype = Pointer (Basic CInt); attributes = [] }
        ; { name = "u_l_l"; ctype = Pointer (Pointer (Basic CULLong)); attributes = [] }
        ; { name = "u64"; ctype = Pointer (Tdef "uint64_t"); attributes = [] }
        ]
    ; typedef = None
    }
  , "struct pointers { int* a; unsigned long long** u_l_l; uint64_t* u64;  };\n" )
;;

let arrays =
  ( { name = "arrays"
    ; fields =
        [ { name = "a"; ctype = Array (Basic CInt, [ 5 ]); attributes = [] }
        ; { name = "u_l_l"
          ; ctype = Array (Pointer (Basic CULLong), [ 5; 5 ])
          ; attributes = []
          }
        ; { name = "u64"; ctype = Array (Tdef "uint64_t", [ 5 ]); attributes = [] }
        ]
    ; typedef = None
    }
  , "struct arrays { int a[5]; unsigned long long* u_l_l[5][5]; uint64_t u64[5];  };\n" )
;;

let functions =
  ( { name = "functions"
    ; fields =
        [ { name = "a"
          ; ctype = Function (Basic CInt, [ Basic CInt; Basic CInt ])
          ; attributes = []
          }
        ; { name = "u64"
          ; ctype = Function (Pointer (Tdef "uint64_t"), [])
          ; attributes = []
          }
        ]
    ; typedef = None
    }
  , "struct functions { int (*a)(int, int); uint64_t* (*u64)();  };\n" )
;;

let cstruct =
  ( { name = "s"
    ; fields =
        [ { name = "s"; ctype = Struct (Some "a", []); attributes = [] }
        ; { name = "s2"
          ; ctype = Struct (None, [ Basic CInt, "num"; Basic CBool, "b" ])
          ; attributes = []
          }
        ]
    ; typedef = Some "s_t"
    }
  , "typedef struct s { struct a {  } s; struct { int num; bool b;  } s2;  } s_t;\n" )
;;

let union =
  ( { name = "u"
    ; fields =
        [ { name = "u"; ctype = Union (Some "a", []); attributes = [] }
        ; { name = "u2"
          ; ctype = Union (None, [ Basic CInt, "num"; Basic CBool, "b" ])
          ; attributes = []
          }
        ]
    ; typedef = Some "u_t"
    }
  , "typedef struct u { union a {  } u; union { int num; bool b;  } u2;  } u_t;\n" )
;;

let enum =
  ( { name = "e"
    ; fields =
        [ { name = "e"; ctype = Enum (Some "a", [ "A"; "B"; "C" ]); attributes = [] }
        ; { name = "e2"; ctype = Enum (None, [ "A"; "B"; "C" ]); attributes = [] }
        ]
    ; typedef = Some "e_t"
    }
  , "typedef struct e { enum a { A, B, C } e; enum { A, B, C } e2;  } e_t;\n" )
;;

let check_file_print test_name (cstruct, expected) () =
  check string test_name expected (string_of_struct cstruct)
;;

let () =
  run
    "Struct Printing"
    [ ( "Empty Struct"
      , [ test_case
            "check if equal"
            `Quick
            (check_file_print "Empty struct example" minimal_struct)
        ] )
    ; ( "Basic Fields"
      , [ test_case
            "check if equal"
            `Quick
            (check_file_print "Basic fields example" basic_fields)
        ] )
    ; ( "Pointers"
      , [ test_case "check if equal" `Quick (check_file_print "Pointers example" pointers)
        ] )
    ; ( "Arrays"
      , [ test_case "check if equal" `Quick (check_file_print "Arrays example" arrays) ] )
    ; ( "Functions"
      , [ test_case
            "check if equal"
            `Quick
            (check_file_print "Functions example" functions)
        ] )
    ; ( "Struct"
      , [ test_case "check if equal" `Quick (check_file_print "Struct example" cstruct) ]
      )
    ; ( "Union"
      , [ test_case "check if equal" `Quick (check_file_print "Union example" union) ] )
    ; "Enum", [ test_case "check if equal" `Quick (check_file_print "Enum example" enum) ]
    ]
;;
