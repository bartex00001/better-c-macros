
type file_name = string

type configuration = 
  { files: file_name list
  ; include_paths: file_name list
  ; verbose: bool
  ; cmd: file_name
  ; args: string array
  }

val get_file_name : file_name -> file_name

val parse : unit -> configuration
