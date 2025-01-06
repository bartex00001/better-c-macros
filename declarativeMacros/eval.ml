open DeclAst

let parse (s : string) : expr =
  DeclParser.prog DeclLexer.read (Lexing.from_string s)
