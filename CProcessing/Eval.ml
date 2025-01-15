(* open Cast *)

let parse_c code =
  CParser.file CLexer.read (Lexing.from_string code)

let parse_channel channel =
  CParser.file CLexer.read (Lexing.from_channel channel)

let parse_stdin () =
  parse_channel stdin

let parse_file_c file =
  parse_channel (open_in file)
