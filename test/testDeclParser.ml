open Alcotest
open DeclarativeMacros
open DeclarativeMacros.DeclAst
open DeclarativeMacros.Declpp


let parse_macro (s : string) : macro =
  DeclParser.start DeclLexer.read (Lexing.from_string s)

let macro_testable = Alcotest.testable pp_macro equal_macro


let test_simplest () =
  let simplest_text = "##test{(a) => {b}}"
  and simplest_expected = { name = "test"
  ; matches = [
      [ DirectMatch "a"], [ DirectRes "b" ];
    ]
  }
  in
  let actual = parse_macro simplest_text
  in
  check macro_testable "basic parsing" simplest_expected actual



let test_parse_two_cases () =
  let simplest_text = "##test{(a) => {b}\n(b) => {a}}"
  and simplest_expected = { name = "test"
  ; matches = [
      [ DirectMatch "a"], [ DirectRes "b" ];
      [ DirectMatch "b"], [ DirectRes "a" ];
    ]
  }
  in
  let actual = parse_macro simplest_text
  in
  check macro_testable "parsing" simplest_expected actual




let () =
  let open Alcotest in
  run "DeclarativeParser" [
      "Basic Parsing", [
          test_case "Simplest"           `Quick test_simplest;
          test_case "Simplest_two_cases" `Quick test_parse_two_cases;
      ]
  ]

