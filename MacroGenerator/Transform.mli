open CProcessing

(* TODO: Modularize printer (also decide if it would really be necesary in this project) *)
val transform_file
  :  MacroEnv.include_path list
  -> MacroEnv.macro_env
  -> Cast.cfile
  -> string
