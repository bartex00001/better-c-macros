open Alcotest
open CProcessing
open CProcessing.Cast
open CProcessing.PPCast


let parse_channel channel =
  let lexbuf = Lexing.from_channel channel in
  try CParser.file CLexer.read lexbuf with
  | CParser.Error ->
    Printf.eprintf "Syntax error: %s\n" (Lexing.lexeme lexbuf);
    let p1 = Lexing.lexeme_start_p lexbuf in
    let p2 = Lexing.lexeme_end_p lexbuf in
    Printf.eprintf "%s:%d:%d-%d: Syntax error: unexpected token '%s'\n"
      p1.pos_fname
      p1.pos_lnum
      (p1.pos_cnum - p1.pos_bol + 1)
      (p2.pos_cnum - p2.pos_bol)
      (Lexing.lexeme lexbuf);
    raise CParser.Error


let parse_file_c file =
  parse_channel (open_in file)


let c_elem = testable pp_c_elem comp_c_elem



let root_dir = "../../../../test_bcm/ParseMacroDef/"
let empty_macro_def = (root_dir ^ "emptyDef.c", [
  MacroDef({
    name = "myMacro";
    matches = [];
  })
])


let minimal_macro_def = (root_dir ^ "minimal.c", [
  MacroDef({
    name = "mySwap";
    matches = [
      { matcher = [BasicMatch(DirectMatch(Ident("a")))]
      ; result = [BasicRes(DirectRes(Ident("b")))]};
      { matcher = [BasicMatch(DirectMatch(Ident("b")))]
      ; result = [BasicRes(DirectRes(Ident("a")))]};
    ]
  })
])


let minimal_named_matches = (root_dir ^ "minimal_named.c", [
  MacroDef({
    name = "named_test";
    matches = [
      { matcher = [BasicMatch(NamedMatch("num", TInt))]
      ; result = [BasicRes(DirectRes(Int(123)))]};
      { matcher = [
          BasicMatch(NamedMatch("a", TFloat));
          BasicMatch(DirectMatch(Direct("+")));
          BasicMatch(NamedMatch("b", TInt));
        ]
      ; result = [
          BasicRes(DirectRes(Direct("(")));
          BasicRes(DirectRes(Ident("float")));
          BasicRes(DirectRes(Direct(")")));
          BasicRes(NamedRes("b"));
          BasicRes(DirectRes(Direct("+")));
          BasicRes(NamedRes("a"));
      ]}
    ]
  })
])


let paren_madness = (root_dir ^ "paren_madness.c", [
  MacroDef({
    name = "madness";
    matches = [
      { matcher = [
        BasicMatch(DirectMatch(Direct("(")));
        BasicMatch(DirectMatch(Ident("a")));
        BasicMatch(DirectMatch(Ident("a")));
        BasicMatch(DirectMatch(Direct(")")));
        BasicMatch(DirectMatch(Direct("+")));
        BasicMatch(DirectMatch(Direct("(")));
        BasicMatch(DirectMatch(Ident("b")));
        BasicMatch(DirectMatch(Direct(")")));
      ]
      ; result = [
        BasicRes(DirectRes(Direct("{")));
        BasicRes(DirectRes(Ident("a")));
        BasicRes(DirectRes(Direct("}")));
        BasicRes(DirectRes(Direct("-")));
        BasicRes(DirectRes(Direct("{")));
        BasicRes(DirectRes(Ident("b")));
        BasicRes(DirectRes(Ident("b")));
        BasicRes(DirectRes(Direct("}")));
      ]};
      { matcher = [
        BasicMatch(DirectMatch(Direct("{")));
        BasicMatch(DirectMatch(Direct("(")));
        BasicMatch(DirectMatch(Int(1)));
        BasicMatch(DirectMatch(Direct("%")));
        BasicMatch(DirectMatch(Int(2)));
        BasicMatch(DirectMatch(Direct(")")));
        BasicMatch(DirectMatch(Direct("}")));
        BasicMatch(DirectMatch(Direct("+")));
        BasicMatch(DirectMatch(Direct("[")));
        BasicMatch(DirectMatch(Ident("c")));
        BasicMatch(DirectMatch(Direct("]")));
      ]
      ; result = [
        BasicRes(DirectRes(Direct("{")));
        BasicRes(DirectRes(Int(1)));
        BasicRes(DirectRes(Direct("}")));
        BasicRes(DirectRes(Direct("^^")));
        BasicRes(DirectRes(Direct("{")));
        BasicRes(DirectRes(Direct("(")));
        BasicRes(DirectRes(Ident("c")));
        BasicRes(DirectRes(Direct(")")));
        BasicRes(DirectRes(Ident("c")));
        BasicRes(DirectRes(Direct("}")));
      ]}
    ]
  })
])


let basic_sequence_match = (root_dir ^ "basic_sequence_match.c", [
  MacroDef({
    name = "sequence";
    matches = [
      { matcher = [
        SequenceMatch([
          NamedMatch("x", TToken);
        ])
      ]
      ; result = [
        SequenceRes([
          NamedRes("x");
          DirectRes(Direct(","));
        ])
      ]}
    ]
  })
])


let sequence_match = (root_dir ^ "sequence_match.c", [
  MacroDef({
    name = "a1b2";
    matches = [
      { matcher = [
        BasicMatch(NamedMatch("id", TIdent));
        BasicMatch(DirectMatch(Direct("=")));
        SequenceMatch([NamedMatch("val", TFloat)])
      ]
      ; result = [
        BasicRes(DirectRes(Ident("let")));
        BasicRes(NamedRes("id"));
        BasicRes(DirectRes(Direct("=")));
        SequenceRes([
          NamedRes("val");
          DirectRes(Direct("+"));
        ]);
        BasicRes(DirectRes(Direct(";")));
      ]};
      { matcher = [
        SequenceMatch([
          NamedMatch("id2", TChar);
          DirectMatch(Direct("^"));
        ]);
        BasicMatch(NamedMatch("last", TChar));
      ]
      ; result = [
        BasicRes(DirectRes(Ident("char")));
        BasicRes(DirectRes(Ident("arr")));
        BasicRes(DirectRes(Direct("[")));
        BasicRes(DirectRes(Direct("]")));
        BasicRes(DirectRes(Direct("=")));
        BasicRes(DirectRes(Direct("{")));
        SequenceRes([
          NamedRes("id2");
          DirectRes(Direct(","));
        ]);
        BasicRes(NamedRes("last"));
        BasicRes(DirectRes(Direct(",")));
        BasicRes(DirectRes(Char('a')));
        BasicRes(DirectRes(Direct("}")));
        BasicRes(DirectRes(Direct(";")));
      ]}
    ];
  })
])


let macro_expansion_in_res = (root_dir ^ "macro_expansion.c", [
  MacroDef({
    name = "counter";
    matches = [
      { matcher = []
      ; result = [
        BasicRes(DirectRes(Direct("+")));
        BasicRes(DirectRes(Int(0)));
      ]};
      { matcher = [
        BasicMatch(DirectMatch(Ident("a")));
        SequenceMatch([NamedMatch("rest", TIdent)]);
      ]
      ; result = [
        BasicRes(DirectRes(Direct("+")));
        BasicRes(DirectRes(Int(1)));
        MacroRes("counter", [
          SequenceRes([NamedRes("rest")]);
        ]);
      ]};
      { matcher = [
        BasicMatch(DirectMatch(Ident("b")));
        SequenceMatch([NamedMatch("rest", TIdent)]);
      ]
      ; result = [
        BasicRes(DirectRes(Int(-1)));
        MacroRes("counter", [
          SequenceRes([NamedRes("rest")]);
        ]);
      ]};
      { matcher = [
      ]
      ; result = [
        BasicRes(DirectRes(Direct("(")));
        MacroRes("result", [
            BasicRes(DirectRes(Ident("a")));
            BasicRes(DirectRes(Ident("b")));
            BasicRes(DirectRes(Int(1)));
            BasicRes(DirectRes(String("d")));
        ]);
        BasicRes(DirectRes(Direct(")")));
      ]}
    ]
  })
])


let check_file_parsing test_name (file_name, expected) () = check (list c_elem) test_name expected (parse_file_c file_name)



let () =
  run "MacroDef parsing" [
    "Empty macro definition parsing",
      [ test_case "check if equal" `Quick (check_file_parsing "Empty macro definition" empty_macro_def); ];
    "Minimal macro definition parsing (one token)",
      [ test_case "check if equal" `Quick (check_file_parsing "Minimal macro definition" minimal_macro_def); ];
    "Minimal named values in macro",
      [ test_case "check if equal" `Quick (check_file_parsing "Minimal named matches" minimal_named_matches); ];
    "Many nested parenthesis",
      [ test_case "check if equal" `Quick (check_file_parsing "Parenthesis madness" paren_madness); ];
    "Basic sequence match",
      [ test_case "check if equal" `Quick (check_file_parsing "Basic sequence match" basic_sequence_match); ];
    "Sequence match",
      [ test_case "check if equal" `Quick (check_file_parsing "Sequence match" sequence_match); ];
    "Macro expansion in result",
      [ test_case "check if equal" `Quick (check_file_parsing "Macro expansion in result" macro_expansion_in_res); ];
  ]
