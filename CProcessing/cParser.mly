%{
open Cast
open BCMMacros

(* During lexing not all C symbols will be "close" to each other
 * thus they will be parsed as separate entries.
 * This is unnecesary thus we can just 'squash' them together. *)
let rec squash_code = function
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


let get_type_and_name_of_list = function
  | "unsigned" :: "long"   :: "long" :: [name] -> Basic CULLong, name
  | "unsigned" :: "long"   :: [name] -> Basic CULong, name
  | "unsigned" :: "int"    :: [name] -> Basic CUInt, name
  | "unsigned" :: "short"  :: [name] -> Basic CUShort, name
  | "long"     :: "long"   :: [name] -> Basic CLLong, name
  | "long"     :: "double" :: [name] -> Basic CLongDouble, name
  | "unsigned" :: "char"   :: [name] -> Basic CUChar, name
  | "int"    :: [name] -> Basic CInt, name
  | "long"   :: [name] -> Basic CLong, name
  | "short"  :: [name] -> Basic CShort, name
  | "float"  :: [name] -> Basic CFloat, name
  | "double" :: [name] -> Basic CDouble, name
  | "char"   :: [name] -> Basic CChar, name
  | "bool"   :: [name] -> Basic CBool, name
  | "void"   :: [name] -> Basic CVoid, name
  | s :: [name] -> Tdef s, name
  | _ -> failwith "Invalid type and name list"

let get_type_of_list = function
  | "unsigned" :: "long"   :: ["long"] -> Basic CULLong
  | "unsigned" :: ["long"]   -> Basic CULong
  | "unsigned" :: ["int"]    -> Basic CUInt
  | "unsigned" :: ["short"]  -> Basic CUShort
  | "long"     :: ["long"]   -> Basic CLLong
  | "long"     :: ["double"] -> Basic CLongDouble
  | "unsigned" :: ["char"]   -> Basic CUChar
  | ["int"]     -> Basic CInt
  | ["long"]    -> Basic CLong
  | ["short"]   -> Basic CShort
  | ["float"]   -> Basic CFloat
  | ["double"]  -> Basic CDouble
  | ["char"]    -> Basic CChar
  | ["bool"]    -> Basic CBool
  | ["void"]    -> Basic CVoid
  | [s] -> Tdef s
  | _ -> failwith "Invalid type and name list"

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
%token DERIVE

%token STRUCT
%token UNION
%token ENUM
%token TYPEDEF

%token EQ
%token PLUS_ASSIGN
%token MINUS_ASSIGN
%token STAR_ASSIGN
%token SLASH_ASSIGN
%token PERCENT_ASSIGN
%token AMP_ASSIGN
%token PIPE_ASSIGN
%token XOR_ASSIGN
%token NOT_EQ
%token NOT

%token ASSIGN
%token ARROW

%token SH_LEFT_ASSIGN
%token SH_LEFT
%token LE
%token LESS
%token SH_RIGHT_ASSIGN
%token SH_RIGHT
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
  | DERIVE; LPAREN; macros = read_derive_args; RPAREN; cstruct = parse_cstruct; SEMICOLON
    { Derive (macros, cstruct)}
  (* TODO: Remove once made sure all c tokens are parsed correctly.
   * This is a workaround to include all tokens without explicitly
   * parsing them. *)
  | CODE { CCode $1 }
  ;


read_derive_args:
  | IDENTIFIER { [$1] }
  | IDENTIFIER; COMMA; rest = read_derive_args { $1 :: rest }


bcm_use:
  | BCM_USE; include_name = IDENTIFIER { ProcUse include_name }
  | BCM_USE; include_name = CSTRING { ProcUse include_name }
  ;


// ------------------------ Macro Definitions
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
  | macro_typed_token { DirectMatch $1 }
  ;


macro_result:
  | macro_result_element { [ BasicRes $1 ] }

  | DOLLAR; LPAREN; inside = macro_result_sequence* RPAREN; STAR
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
  | macro_result_element { [$1] }
  | LBRACE; elements = macro_result_element*; RBRACE
    {  DirectRes( Direct "{" )
      :: elements
      @ [ DirectRes( Direct "}" ) ] }
  | LPAREN; elements = macro_result_element*; RPAREN
    {  DirectRes( Direct "(" )
      :: elements
      @ [ DirectRes( Direct ")" ) ] }
  | HASH; name = IDENTIFIER; LPAREN; tokens = macro_result_sequence*; RPAREN
    { [ MacroResUse(name, List.flatten tokens) ] }
  ;

macro_result_element:
  | DOLLAR; name = IDENTIFIER { NamedRes name }
  | macro_typed_token { DirectRes $1 }
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
    { Tok(Direct("(")) :: inner @ [Tok(Direct(")"))] }
  | macro_typed_token { [Tok $1] }
  ;


// ------------------------ CStruct parsing
parse_cstruct:
  | TYPEDEF; STRUCT; name = IDENTIFIER; LBRACE; fields = parse_cstruct_field_with_attributes*; RBRACE; tdef = IDENTIFIER
    { {name; fields; typedef = Some tdef} }
  | STRUCT; name = IDENTIFIER; LBRACE; fields = parse_cstruct_field_with_attributes*; RBRACE
    { {name; fields; typedef = None} }
  ;

parse_cstruct_field_with_attributes:
  | parse_attributes; parse_cstruct_field; SEMICOLON {
      let (ctype, name) = $2
      in { ctype; name; attributes = $1 } }
  | parse_cstruct_field; SEMICOLON {
      let (ctype, name) = $1
      in { ctype; name; attributes = [] } }
  ;

parse_cstruct_field:
  | parse_simple_value { $1 }
  | parse_pointer_value { $1 }
  | parse_array_value { $1 }
  | parse_function_value { $1 }
  ;

parse_attributes:
  | HASH; LBRACKET; RBRACKET { [] }
  | HASH; LBRACKET; attr = attributes; RBRACKET { attr }
  ;

attributes:
  | IDENTIFIER { [$1, None] }
  | IDENTIFIER; LPAREN; token = macro_typed_token; RPAREN
    { [$1, Some token] }
  | IDENTIFIER; COMMA; rest = attributes { ($1, None) :: rest }
  | IDENTIFIER; LPAREN; token = macro_typed_token; RPAREN; COMMA; rest = attributes
    { ($1, Some token) :: rest }
  ;

parse_simple_value:
  | ctype = IDENTIFIER* { get_type_and_name_of_list ctype }
  ;

parse_pointer_value:
  | pointer_type = pointer_star_catcher; name = IDENTIFIER
    { pointer_type, name }
  ;

pointer_star_catcher:
  | ctype = IDENTIFIER*; STAR { Pointer (get_type_of_list ctype) }
  | pointer_star_catcher; STAR { Pointer $1 }
  ;

parse_array_value:
  | ctype = IDENTIFIER*; array = array_catcher
    { let (ctype, name) = get_type_and_name_of_list ctype in
      Array (ctype, array), name }
  | pointer_star_catcher; name = IDENTIFIER; array = array_catcher
    { Array ($1, array), name }
  ;

array_catcher:
  | LBRACKET; size = INT; RBRACKET { [size] }
  | LBRACKET; size = INT; RBRACKET; rest = array_catcher;  { size :: rest }
  ;

parse_function_value:
  | pointer = pointer_star_catcher; LPAREN; name = IDENTIFIER; STAR; RPAREN; LPAREN; args = parse_function_args; RPAREN
    { Function (pointer, args), name }
  | ctype = IDENTIFIER*; LPAREN; name = IDENTIFIER; STAR; RPAREN; LPAREN; args = parse_function_args; RPAREN
    { let ctype = get_type_of_list ctype in
      Function (ctype, args), name }
  ;

parse_function_args:
  | ctype = IDENTIFIER*; { [get_type_of_list ctype] }
  | pointer_star_catcher; { [$1] }
  | ctype = IDENTIFIER*; COMMA; rest = parse_function_args; { get_type_of_list ctype :: rest }
  | pointer_star_catcher; COMMA; rest = parse_function_args; { $1 :: rest }
  ;


// ------------------------ TOKENS
macro_typed_token:
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
  | STRUCT { "struct" }
  | UNION { "union" }
  | ENUM { "enum" }
  | TYPEDEF { "typedef" }
  | EQ { "==" }
  | PLUS_ASSIGN { "+=" }
  | MINUS_ASSIGN { "-=" }
  | STAR_ASSIGN { "*=" }
  | SLASH_ASSIGN { "/=" }
  | PERCENT_ASSIGN { "%=" }
  | AMP_ASSIGN { "&=" }
  | PIPE_ASSIGN { "|=" }
  | XOR_ASSIGN { "^=" }
  | NOT_EQ { "!=" }
  | NOT { "!" }
  | ASSIGN { "=" }
  | ARROW { "->" }
  | SH_LEFT_ASSIGN { "<<=" }
  | SH_LEFT { "<<" }
  | LE { "<=" }
  | LESS { "<" }
  | SH_RIGHT_ASSIGN { ">>=" }
  | SH_RIGHT { ">>" }
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
