open Arg


type output_method =
  | Stdout
  | File of string

type configuration =
  {  working_dir: string
  ; include_paths: string list
  ; file_name: string
  ; output_method: output_method 
  }


(* TODO: do not use mutable state for argument parsing.
 *       unfortunatley this would require writing my own argument parser...
 *       ...but one might use a state monad for this purpose.
 *)

let usage_msg = "Usage: bcm [options] <file_name> "
let include_paths = ref ["."]
let file_name = ref None
let output_method = ref Stdout

let accept_file_name name =
  match !file_name with
  | None -> file_name := Some name
  | Some _ -> failwith "Only one file name is allowed"
  

let speclist = [
  ("-I", String (fun s -> include_paths := s :: !include_paths), "Add a directory to the include path");
  ("-o", String (fun s -> output_method := File s), "Output file name")
]

let parse () =
  Arg.parse speclist accept_file_name usage_msg;
  let working_dir = Sys.getcwd ()
  and file_name = match !file_name with
    | Some name -> name
    | None ->
      Printf.printf "%s\n" usage_msg;
      failwith "No file name given"
  in
  { working_dir
  ; include_paths = !include_paths
  ; file_name
  ; output_method = !output_method
  }
