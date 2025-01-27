
type file_name = string

(* TODO: Mark what exceptions can arise from these functions. *)

(** Process the file and return the transformed contents.
  * [process_file include_paths file] will process the file [file]
  * with searches for additional libraries performed in [include_paths] *)
val process_file : file_name list -> file_name -> string


(** Print the contents to a file. *)
val print_to_file : file_name -> string -> unit
