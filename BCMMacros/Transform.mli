open CProcessing


(* TODO: Modularize printer (also decide if it would really be necesary in this project) *)
val transform_file : MacroEnv.macro_env -> Cast.cfile -> string
