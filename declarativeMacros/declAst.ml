type ident = string

type match_type = Ident | Expr | Int | Float | String | Block

let match_type_of_string = function
  | "ident" -> Ident
  | "expr" -> Expr
  | "int" -> Int
  | "float" -> Float
  | "string" -> String
  | "block" -> Block
  | _ -> failwith "Invalid match type"


type matcher =
  | DirectMatch of ident
  | NamedMatch of ident * match_type
  | SequenceMatch of matcher list

type result =
  | DirectRes of ident
  | NamedRes of ident
  | MacroRes of ident * result list

type macro =
  { name: ident
  ; matches: (matcher * result list ) list
  }
