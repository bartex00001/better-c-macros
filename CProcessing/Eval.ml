(* open Cast *)

(* [ParseException (file_name, line, char_start, char_end, token)] *)
exception ParseException of string * int * int * int * string

let parse_c code =
  let lexbuf = Lexing.from_string code in
  Lexing.set_filename lexbuf code;
  try CParser.file CLexer.read lexbuf with
  | CParser.Error ->
    let p1 = Lexing.lexeme_start_p lexbuf in
    let p2 = Lexing.lexeme_end_p lexbuf in
    raise
    @@ ParseException
         ( p1.pos_fname
         , p1.pos_lnum
         , p1.pos_cnum - p1.pos_bol
         , p2.pos_cnum - p2.pos_bol
         , Lexing.lexeme lexbuf )
;;

let parse_channel channel = CParser.file CLexer.read (Lexing.from_channel channel)
let parse_stdin () = parse_channel stdin
let parse_file_c file = parse_channel (open_in file)
