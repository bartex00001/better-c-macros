
type ident = string

type ctype =
  | Tdef of string
  | Pointer of ctype
  | Array of ctype * int
  | Function of ctype * ctype list
  | Struct of ident option * (ctype * ident) list
  | Union of ident option * (ctype * ident) list
  | Enum of ident option * string list

type cstruct = ident * (ctype * ident) list


type c_code = string

(* TODO: Define in Declarative Macro subproject *)
type macro_def = unit
type tokens = unit

type cfile_element =
  | Syntax of c_code
  | ProcUse of string
  | MacroDef of macro_def
  | MacroUse of ident * tokens
  | Derive of (ident * tokens) list * cstruct


type cfile = cfile_element list
