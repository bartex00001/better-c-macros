{
open CParser
}

let whitespace = [' ' '\t' '\n' '\r']+

let digit = ['0'-'9']
(* TODO: More comprehensive float parsing (for example exponents) *)
let float = ['-']? digit+ '.' digit* ['f']?
(* TODO: Ability to parse binary/hex and long/unsigned marked integers *)
let integer = ['-']? digit+

let letter = ['a'-'z' 'A'-'Z']
let identifier = letter (letter | digit | '_')*

let preprocessor =
    ("#define" | "#include" | "#pragma" | "#if" | "#ifdef" | "#else" | "#endif")

let not_escaped_newline = [^ '\n' '\\']*
let not_escaped_quote = [^ '"' '\\']*


rule
read = parse
  | whitespace { read lexbuf }

  (* Avoid c-macro shenanigans *)
  | preprocessor { 
      let directive = Lexing.lexeme lexbuf
      and contents = read_till_end_of_line lexbuf
      in
      PREPROCESOR (directive ^ contents)
    }

  | "#bcm_use" { BCM_USE }
  | "##macro" { MACRO_DEF }
  | "#derive" { DERIVE }

  (* Consume and discard comments *)
  | "/*" { read_multiline_comment lexbuf; read lexbuf }
  | "//" {
      let _ = read_till_end_of_line lexbuf
      in read lexbuf
    }
  
  (* Consume c-strings - do not lex them *)
  | "\"" {
      let contents = read_till_end_of_quotes lexbuf
      in CSTRING (contents)
    }
  
  | "'" { CCHAR (read_c_char lexbuf) }

  | "struct" { STRUCT }
  | "union" { UNION }
  | "enum" { ENUM }
  | "typedef" { TYPEDEF }

  | identifier { IDENTIFIER (Lexing.lexeme lexbuf) }

  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | integer { INT (int_of_string (Lexing.lexeme lexbuf)) }

  | "==" { EQ }
  | "+=" { PLUS_ASSIGN }
  | "-=" { MINUS_ASSIGN }
  | "*=" { STAR_ASSIGN }
  | "/=" { SLASH_ASSIGN }
  | "%=" { PERCENT_ASSIGN }
  | "&=" { AMP_ASSIGN }
  | "|=" { PIPE_ASSIGN }
  | "^=" { XOR_ASSIGN }
  | "!=" { NOT_EQ }
  | "!" { NOT }

  | "=" { ASSIGN }
 
  | "<<=" { SH_LEFT_ASSIGN }
  | "<<" { SH_LEFT }
  | "<=" { LE }
  | "<" { LESS }
  | ">>=" { SH_RIGHT_ASSIGN}
  | ">>" { SH_RIGHT }
  | ">=" { GE }
  | ">" { GREATER }

  | "++" { PLUSPLUS }
  | "+" { PLUS }
  | "--" { MINUSMINUS }
  | "-" { MINUS }
  | "*" { STAR }
  | "/" { SLASH }

  | "#" { HASH }
  | "%" { PERCENT }
  | "&&" { AND }
  | "&" { AMP }
  | "||" { OR }
  | "|" { PIPE }
  | "^^" { XOR }
  | "^" { BXOR }
  | "$" { DOLLAR }
  | "~" { TILDE }

  | "(" { LPAREN }
  | ")" { RPAREN }
  | "{" { LBRACE }
  | "}" { RBRACE }
  | "[" { LBRACKET }
  | "]" { RBRACKET }

  | ";" { SEMICOLON }
  | ":" { COLON }
  | "," { COMMA }

  | eof { EOF }

  | _ { CODE (Lexing.lexeme lexbuf) }

and
read_multiline_comment = parse
 | "*/" { () }
 | _ { read_multiline_comment lexbuf }

and
read_till_end_of_line = parse
  | "\n" { "" }
  | "\\\n" { read_till_end_of_line lexbuf }
  | not_escaped_newline {
      let curr = Lexing.lexeme lexbuf
      and next = read_till_end_of_line lexbuf 
      in
      curr ^ next
    }

and
read_till_end_of_quotes = parse
  | "\"" { "" }
  | "\\n" { "\\n" ^ read_till_end_of_quotes lexbuf }
  | "\\t" { "\\t" ^ read_till_end_of_quotes lexbuf }
  | "\\\"" { "\\\"" ^ read_till_end_of_quotes lexbuf }
  | not_escaped_quote {
      let curr = Lexing.lexeme lexbuf
      and next = read_till_end_of_quotes lexbuf
      in
      curr ^ next
    }

and
read_one_identifier = parse
  | [' ' '\t']* { read_one_identifier lexbuf }
  | identifier { Lexing.lexeme lexbuf }

and
read_c_string = parse
  | [' ' '\t']* { read_c_string lexbuf }
  | "\"" { read_till_end_of_quotes lexbuf }

and
read_c_char = parse
  | "\\''" { '\'' }
  (* TODO: fix so that not all chars are parsed as 'a' *)
  | _ "'" { 'a' }
