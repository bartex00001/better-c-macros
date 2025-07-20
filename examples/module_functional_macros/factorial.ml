(* Compile this module with the following command:
ocamlfind ocamlopt -shared -package bcm.BCMMacros factorial.ml -o factorial.cmxs
*)

let rec factorial n = if n = 0 then 1 else n * factorial (n - 1)

let factorial_transformer macro_tokens =
  match macro_tokens with
  | [ BCMMacros.Int n ] -> [ BCMMacros.Tok (BCMMacros.Int (factorial n)) ]
  | _ -> failwith "factorial can only be used with a single integer argument"
;;

let () = BCMMacros.register_decl_macro ("factorial", factorial_transformer)
