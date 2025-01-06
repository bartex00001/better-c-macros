{
open Cparser
}

let white = [' ' '\t' '\n']+
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let number = '-'? digit+
let ident = letter (letter | digit | '_')*

rule read =
  parse
  | white { read lexbuf }
  | "->" { ARROW }
  | "&&" { AND }
  | "||" { OR }
  | "=" { EQ }
  | "<>" { NEQ }
  | "<=" { LEQ }
  | ">=" { GEQ }
  | "<" { LT }
  | ">" { GT }
  | "*" { TIMES }
  | "+" { PLUS }
  | "-" { MINUS }
  | "/" { DIV }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "true" { TRUE }
  | "false" { FALSE }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "fun" { FUN }
  | "let" { LET }
  | "in" { IN }
  | number { INT (int_of_string (Lexing.lexeme lexbuf)) } 
  | ident { IDENT (Lexing.lexeme lexbuf) }
  | eof { EOF }