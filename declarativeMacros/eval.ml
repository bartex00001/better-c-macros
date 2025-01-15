open DeclAst

let parse (s : string) : macro =
  DeclParser.start DeclLexer.read (Lexing.from_string s)
