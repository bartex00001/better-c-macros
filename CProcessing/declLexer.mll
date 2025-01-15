{
open DeclParser
}

let white = [' ' '\t' '\n']+
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let number = '-'? digit+
let float = number '.' (digit)? ('f')?
let ident = letter (letter | digit | '_')*

rule read = parse
  | white { read lexbuf }
  | "(" { L_PAREN }
  | ")" { R_PAREN }
  | "{" { L_CURL }
  | "}" { R_CURL }
  | "[" { L_BRACK }
  | "]" { R_BRACK }
  | "$" { DOLLAR }
  | "#" { HASH }
  | "%" { PERCENT }
  | "," { COMMA }
  | "*" { STAR }
  | "=>" { ARROW }
  | ":" { COLON }
  | ident { IDENT (Lexing.lexeme lexbuf) }
  | eof { EOF }