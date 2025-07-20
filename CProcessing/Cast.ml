open BCMMacros

type macro_matcher_element =
  | DirectMatch of macro_token
  | NamedMatch of ident * macro_token_type

type macro_matcher =
  | BasicMatch of macro_matcher_element
  | SequenceMatch of macro_matcher_element list

type macro_result_element =
  | DirectRes of macro_token
  | NamedRes of ident
  | MacroResUse of ident * macro_result_element list

type macro_result =
  | BasicRes of macro_result_element
  | SequenceRes of macro_result_element list
  (* TODO: Add non-empty sequence match support *)
  | MacroRes of ident * macro_result list

type macro_pattern_match =
  { matcher : macro_matcher list
  ; result : macro_result list
  }

type macro_def =
  { name : string
  ; matches : macro_pattern_match list
  }

(** [CPreprocesor code] some preprocesor directive – do not touch * [CCode code]
    include raw C code [code] * [ProcUse name] include compiled macro library
    [name] * [MacroDef] Defines new declarative macro * [MacroUse] Usage of a
    declarative macro * [Derive macros, cstruct] What derive macros are applied
    to given struct *)
type c_elem =
  | CPreprocesor of string
  | CCode of string
  | ProcUse of string
  | MacroDef of macro_def
  | MacroUse of macro_use
  | Derive of ident list * cstruct

type cfile = c_elem list
