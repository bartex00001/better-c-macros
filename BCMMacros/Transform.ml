open CProcessing


(** Transform macro use into a list of tokens.
* This function will also handle recursive macro expansion **)
let macro_transform env macro =

  let rec transform (name, tokens) =
    let transformer = MacroEnv.get_decl_macro env name
    in
    match transformer with
    | Some transformer -> transformer tokens
    | None -> failwith "Macro not found"

  (* TODO: Add recursion counter to detect infinite expansion loops *)
  and tokens_of_result_tokens result_tokens =
    let tokens_of_result_token = function
      | Cast.Tok token -> [token]
      | Cast.Use macro -> run_macro_transformer macro
    in
    List.map tokens_of_result_token result_tokens
    |> List.flatten

  and run_macro_transformer (name, result_tokens) =
    let tokens = tokens_of_result_tokens result_tokens
    in
    transform (name, tokens)
    |> tokens_of_result_tokens

in run_macro_transformer macro


let[@tail_mod_cons] rec transform_file env = function
  | Cast.CPreprocesor proc :: rest ->
    (proc ^ "\n") ^ transform_file env rest

  | Cast.CCode code :: rest ->
    code ^ transform_file env rest

  | Cast.ProcUse file_name :: rest ->
    let env = MacroEnv.add_entries_from_file env file_name
    in transform_file env rest

  | MacroDef def :: rest ->
    let env = MacroEnv.add_decl_macro env def.name def
    in transform_file env rest

  | MacroUse use :: rest ->
    let tokens = macro_transform env use
      |> Print.string_of_macro_tokens
    in tokens ^ transform_file env rest

  | [] -> "\n"