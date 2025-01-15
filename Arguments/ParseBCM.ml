open Arg


type configuration =
  { verbose: bool
  ; working_dir: string
  ; include_paths: string list
  ; files: string list
  }

(* TODO: do not use mutable state for argument parsing.
 *       unfortunatley this would require writing my own argument parser...
 *)

let usage_msg = "Usage: bcm [options] <file1> [<file2>] ..."
let verbose = ref false
let include_paths = ref  []
let files = ref []
  
let speclist = [
  ("-v", Set verbose, "Verbose mode");
  ("-I", String (fun s -> include_paths := s :: !include_paths), "Add a directory to the include path");
]


let parse () =
  Arg.parse speclist (fun s -> files := s :: !files) usage_msg;
  let working_dir = Sys.getcwd ()
  in
  { verbose = !verbose; working_dir; include_paths = !include_paths; files = !files }
