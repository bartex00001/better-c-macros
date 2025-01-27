
(** Inner state for storing declarative macros *)
let decl_macro_list = ref []
let derive_macro_list = ref []

let register_decl_macro (name, transformer) =
  decl_macro_list := (name, transformer) :: !decl_macro_list

let get_decl_macros () = !decl_macro_list


let register_derive_macro (name, generator) =
  derive_macro_list := (name, generator) :: !derive_macro_list

let get_derive_macros () = !derive_macro_list


let clear_values () =
  decl_macro_list := [];
  derive_macro_list := []
