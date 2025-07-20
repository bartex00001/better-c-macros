open Interpret
open BCMMacros

type include_path = string

module StringMap = Map.Make (String)

type macro_env =
  { decl_macros : token_transformer StringMap.t
  ; derive_macros : derive_generator StringMap.t
  }

let empty = { decl_macros = StringMap.empty; derive_macros = StringMap.empty }

let add_decl_macro env name macro =
  (* TODO: error handling of macro transformation *)
  let transformed_macro = token_transformer_of_macro_def macro in
  { decl_macros = StringMap.add name transformed_macro env.decl_macros
  ; derive_macros = env.derive_macros
  }
;;

let add_entries_from_file include_paths env lib_name =
  let get_lib_name name =
    match Filename.extension name with
    | "" ->
      name ^ ".cmxs"
      (* This is the default extension of 'binary ocaml shared libraries' *)
    | _ -> name
  in
  List.map (fun path -> Filename.concat path (get_lib_name lib_name)) include_paths
  |> List.find_opt Sys.file_exists
  |> function
  (* TODO: Add error handling for library search *)
  | None -> failwith "bcm_use: could not find library"
  | Some lib_path ->
    clear_values ();
    (* TODO: Add error handling for dynlink *)
    let _ = Dynlink.loadfile lib_path in
    let decl_macros = get_decl_macros ()
    and derive_macros = get_derive_macros () in
    let decl_macro_env =
      List.fold_left
        (fun env (name, macro) -> StringMap.add name macro env)
        env.decl_macros
        decl_macros
    and derive_macros_env =
      List.fold_left
        (fun env (name, generator) -> StringMap.add name generator env)
        env.derive_macros
        derive_macros
    in
    { decl_macros = decl_macro_env; derive_macros = derive_macros_env }
;;

let get_decl_macro env name = StringMap.find_opt name env.decl_macros
let get_derive_macro env name = StringMap.find_opt name env.derive_macros
