open Tokens

type basic_type =
  | CVoid
  | CInt
  | CUInt
  | CLong
  | CULong
  | CLLong
  | CULLong
  | CShort
  | CUShort
  | CFloat
  | CDouble
  | CLongDouble
  | CChar
  | CUChar
  | CBool

type ctype =
  | Basic of basic_type
  | Tdef of ident
  | Pointer of ctype
  (* TODO: Parse arrays of length determined by a macro. *)
  | Array of ctype * int list
  | Function of ctype * ctype list
  | Struct of ident option * (ctype * ident) list
  | Union of ident option * (ctype * ident) list
  | Enum of ident option * ident list

type cstruct =
  { name : ident
  (* TODO: Add support for anonymous structs and unions *)
  ; fields : (ctype * ident) list
  ; typedef: ident option
  }


(** Define function definitions as strings. Why?  
  * It's convenient. *)
type function_definition = string

type derive_generator = cstruct -> function_definition list
