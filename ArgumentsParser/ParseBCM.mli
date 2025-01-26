
type output_method =
  | Stdout
  | File of string

type configuration =
  { working_dir: string
  ; include_paths: string list
  ; file_name: string
  ; output_method: output_method 
  }


(** Uses `Arg` module to parse arguments into structure. *)
val parse : unit -> configuration
