type file_name = string

type source_file =
  { source : file_name
  ; result : file_name
  }

type configuration =
  { sources : source_file list
  ; include_paths : file_name list
  ; build_dir : string
  ; verbose : bool
  ; cmd : file_name
  ; args : string array
  }

val parse : unit -> configuration
