open Cast

let parse (s : string) : expr =
  Cparser.prog Clexer.read (Lexing.from_string s)
