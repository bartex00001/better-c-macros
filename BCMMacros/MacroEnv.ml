open Interpret

module StringMap = Map.Make(String)


type macro_env =
  { decl_macros: token_transformer StringMap.t
  ; derive_macros: unit StringMap.t
  }

let empty =
  { decl_macros = StringMap.empty
  ; derive_macros = StringMap.empty
  }


let add_decl_macro env name macro =
  (* TODO: error handling of macro transformation *)
  let transformed_macro = token_transformer_of_macro_def macro
  in
  { decl_macros = StringMap.add name transformed_macro env.decl_macros
  ; derive_macros = env.derive_macros
  }


let add_entries_from_file env _ =
  (* TODO: implement symbol extraction from ocaml dynamic libraries *)
  env


let add_derive_macro env name () =
  { env with derive_macros = StringMap.add name () env.derive_macros }


let get_decl_macro env name =
  StringMap.find_opt name env.decl_macros


let get_derive_macro env name =
  StringMap.find_opt name env.derive_macros
