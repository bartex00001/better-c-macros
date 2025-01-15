%{
open DeclAst
%}

%token <int> INT
%token <float> FLOAT
%token <string> IDENT

%token L_CURL
%token R_CURL
%token L_PAREN
%token R_PAREN
%token L_BRACK
%token R_BRACK

%token DOLLAR
%token HASH
%token PERCENT
%token COMMA
%token STAR
%token ARROW
%token COLON

%token EOF

%start <DeclAst.macro> start

%%

start:
  | HASH; HASH; name = IDENT; L_CURL; r = rules; R_CURL { { name; matches = r } }
  ;

rules:
  | rule { [$1] }
  | rules; rule { $1 @ [$2] }
  ;

rule:
  | L_PAREN; m = matcher_root; R_PAREN; ARROW; L_CURL; r = result_root; R_CURL { m, r }
  ;

matcher_root:
  | matcher { [$1] }
  | matcher_root; matcher { $2 :: $1 }
  ;

matcher:
  | IDENT { DirectMatch $1 }
  | DOLLAR; name = IDENT; COLON; tp = IDENT { NamedMatch(name, match_type_of_string tp) }
  | DOLLAR; L_BRACK; m = matcher_root; R_BRACK { SequenceMatch m }
  ;

result_root:
  | result { [$1] }
  | result_root; result { $2 :: $1 }
  ;

result:
  | IDENT { DirectRes $1 }
  | DOLLAR; name = IDENT { NamedRes(name) }
  | HASH; name = IDENT; L_BRACK; args = result_root; R_BRACK { MacroRes(name, args) }
  ;
