%{
open Cast

(* During lexing not all C symbols will be "close" to each other
 * thus they will be parsed as separate entries.
 * This is unnecesary thus we can just 'squash' them together.
 * `[@tail_mod_cons]` makes this function 'tail-recursive' *)
let[@tail_mod_cons] rec squash_code = function
  | CCode s1 :: CCode s2 :: tl -> squash_code (CCode (s1 ^ " " ^ s2) :: tl)
  | x :: li -> x :: squash_code li
  | [] -> []


let match_type_of_string = function
  | "ident" -> TIdent
  | "int" -> TInt
  | "float" -> TFloat
  | "string" -> TString
  | "char" -> TChar
  | "expr" -> TExpr
  | "tt" -> TToken
  | _ -> failwith "Invalid match type"

%}


%token <string> CODE
%token <string> PREPROCESOR

%token <string> IDENTIFIER

%token <string> CSTRING
%token <char> CCHAR
%token <float> FLOAT
(* Ocaml ints are 63 bits long while it "varies" in C.
 * TODO: At least make it 64 bits long *)
%token <int> INT

%token BCM_USE
%token MACRO_DEF

%token EQ
%token PLUS_EQ
%token MINUS_EQ
%token STAR_EQ
%token SLASH_EQ
%token PERCENT_EQ
%token AMP_EQ
%token PIPE_EQ
%token XOR_EQ
%token NOT_EQ
%token NOT

%token ASSIGN

%token LE
%token LESS
%token GE
%token GREATER

%token PLUSPLUS
%token PLUS
%token MINUSMINUS
%token MINUS
%token STAR
%token SLASH

%token HASH
%token PERCENT
%token AND
%token AMP
%token OR
%token PIPE
%token XOR
%token BXOR
%token DOLLAR
%token TILDE

%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token LBRACKET
%token RBRACKET

%token SEMICOLON
%token COLON
%token COMMA

%token EOF


%start <cfile> file

%%

file:
  | start* EOF { squash_code $1 }
  ;

start:
  | bcm_use { $1 }
  | def_macro { $1 }
  | use_macro { $1 }
  | PREPROCESOR { CPreprocesor $1 }
  | code_element { $1 }
  (* TODO: Remove once made sure all c tokens are parsed correctly.
   * This is a workaround to include all tokens without explicitly
   * parsing them. *)
  | CODE { CCode $1 }
  ;



bcm_use:
  | BCM_USE; include_name = IDENTIFIER { ProcUse include_name }
  | BCM_USE; include_name = CSTRING { ProcUse include_name }
  ;



def_macro:
  | MACRO_DEF; name = IDENTIFIER; LBRACE; matches = def_macro_match*; RBRACE
    { MacroDef({ name; matches }) }
  ;

def_macro_match:
  | LPAREN; matches = macro_match*; RPAREN; ASSIGN; GREATER; LBRACE; results = macro_result*; RBRACE
    { { matcher = List.flatten matches; result = List.flatten results } }
  ;

macro_match:
  | macro_matcher_element { [BasicMatch $1] }
  | DOLLAR; LPAREN; insides = macro_matcher_element*; RPAREN; STAR
    { [SequenceMatch insides] }
  | LPAREN; elements = macro_match*; RPAREN
    { BasicMatch( DirectMatch( Direct "(" ) )
      :: (List.flatten elements)
      @ [BasicMatch( DirectMatch( Direct ")" ) )] }
  ;

macro_matcher_element:
  | DOLLAR; name = IDENTIFIER; COLON; type_name = IDENTIFIER
    { NamedMatch (name, match_type_of_string type_name) }
  | LBRACE { DirectMatch( Direct "{") }
  | RBRACE { DirectMatch( Direct "}") }
  | use_macro_typed_token { DirectMatch $1 }
  ;



macro_result:
  | macro_result_element { [ BasicRes $1 ] }

  | DOLLAR; LPAREN; inside = macro_result_sequence* RPAREN; start
    { [ SequenceRes (List.flatten inside) ] }

  | LBRACE; elements = macro_result*; RBRACE
    { BasicRes( DirectRes( Direct "{" ) )
      :: (List.flatten elements)
      @ [BasicRes( DirectRes( Direct "}" ) )] }

  | LPAREN; elements = macro_result*; RPAREN
    { BasicRes( DirectRes( Direct "(" ) )
      :: (List.flatten elements)
      @ [BasicRes( DirectRes( Direct ")" ) )] }

  | HASH; name = IDENTIFIER; LPAREN; tokens = macro_result*; RPAREN
    { [ MacroRes(name, List.flatten tokens) ] }
  ;

macro_result_sequence:
  | LPAREN; elements = macro_result_element*; RPAREN
    {  DirectRes( Direct "(" )
      :: elements
      @ [ DirectRes( Direct ")" ) ] }
  | LBRACE; elements = macro_result_element*; RBRACE
    {  DirectRes( Direct "{" )
      :: elements
      @ [ DirectRes( Direct "}" ) ] }
  | macro_result_element { [$1] }
  ;

macro_result_element:
  | DOLLAR; name = IDENTIFIER { NamedRes name }
  | use_macro_typed_token { DirectRes $1 }
  ;



use_macro:
  | HASH; name = IDENTIFIER; LPAREN; tokens = use_macro_tokens; RPAREN
    { MacroUse (name, tokens) }
  ;

use_macro_tokens:
  | use_macro_token_segment* { List.flatten $1 }
  ;

use_macro_token_segment:
  | LPAREN; inner = use_macro_tokens; RPAREN
    { Direct("(") :: inner @ [Direct(")")] }
  | use_macro_typed_token { [$1] }
  ;

use_macro_typed_token:
  | IDENTIFIER { Ident $1 }
  | INT { Int $1 }
  | FLOAT { Float $1 }
  | CSTRING { String $1 }
  | CCHAR { Char $1 }
  | token_as_string { Direct $1 }
  ;



(* We are not interested in the structure of c code *)
code_element:
  | IDENTIFIER { CCode $1 }
  | CSTRING { CCode ("\"" ^ $1 ^ "\"") }
  | CCHAR { CCode ("'" ^ (String.make 1 $1) ^ "'") }
  | FLOAT { CCode (string_of_float $1) }
  | INT { CCode (string_of_int $1) }
  | LPAREN { CCode "(" }
  | RPAREN { CCode ")" }
  | LBRACE { CCode "{" }
  | RBRACE { CCode "}" }
  | token_as_string { CCode $1 }
  ;



token_as_string:
  | EQ { "==" }
  | PLUS_EQ { "+=" }
  | MINUS_EQ { "-=" }
  | STAR_EQ { "*=" }
  | SLASH_EQ { "/=" }
  | PERCENT_EQ { "%=" }
  | AMP_EQ { "&=" }
  | PIPE_EQ { "|=" }
  | XOR_EQ { "^=" }
  | NOT_EQ { "!=" }
  | NOT { "!" }
  | ASSIGN { "=" }
  | LE { "<=" }
  | LESS { "<" }
  | GE { ">=" }
  | GREATER { ">" }
  | PLUSPLUS { "++" }
  | PLUS { "+" }
  | MINUSMINUS { "--" }
  | MINUS { "-" }
  | STAR { "*" }
  | SLASH { "/" }
  | PERCENT { "%" }
  | AND { "&&" }
  | AMP { "&" }
  | OR { "||" }
  | PIPE { "|" }
  | XOR { "^^" }
  | BXOR { "^" }
  | TILDE { "~" }
  | LBRACKET { "[" }
  | RBRACKET { "]" }
  | SEMICOLON { ";" }
  | COLON { ":" }
  | COMMA { "," }
  ;
