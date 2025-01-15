
type configuration =
  { verbose: bool
  ; working_dir: string
  ; include_paths: string list
  ; files: string list
  }


(** Uses `Arg` module to parse arguments into structure. *)
val parse : unit -> configuration
