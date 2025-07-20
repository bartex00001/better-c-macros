open BCMMacros
open CProcessing.Cast

(** Used to implement Mealy's automaton *)
module StateMachine = Map.Make (Int)

(** Each named match can either match a single value or list of values. *)
type token_var =
  | Single of macro_token
  | List of macro_tokens

module StrMap = Map.Make (String)

(** Environment mapping names to their tokens *)
type env = token_var StrMap.t

(** State of the state-machine consists of: * - [position] current state id * -
    [env] environment of variable names mapped to their token matches * -
    [buffer] buffered tokens – not yet confirmed sequence of match tokens *)
type sm_state =
  { position : int
  ; env : env
  ; buffer : (macro_token * ident option) list
  }

(** - [SMGoto state, tokens_left] represents action of transitioning * to
      [state] with [tokens_left] yet to be processed * -[SMFinish state]
      represents the state of automaton when end block was found * -[SMFail]
      invalid state reached (would be reached if not stopped) *)
type sm_action =
  | SMGoto of sm_state * macro_tokens
  | SMFinish of sm_state
  | SMFail

(* TODO: make this type used *)
(* type state_transition = sm_state * macro_token * macro_tokens -> sm_action *)
(* TODO: use this as well... *)
(* type state_machine = state_transition StateMachine.t *)

(** Runst the state machine [sm] with [token_list] * returns [Some sm_state] if
    automaton reaches accepting state, [None] otherwise *)
let run_state_machine sm token_list =
  let reverse_named_env_lists { position; env; buffer } =
    let new_env =
      StrMap.map
        (function
          | Single t -> Single t
          | List l -> List (List.rev l))
        env
    in
    { position; env = new_env; buffer }
  in
  let rec run sm_state token_list =
    let state = sm_state.position in
    match StateMachine.find_opt state sm with
    | Some transition ->
      (* TODO: Check if there are tokens left *)
      (match transition (sm_state, List.hd token_list, List.tl token_list) with
       | SMGoto (sm_state, token_list) -> run sm_state token_list
       | SMFinish sm_state -> Some (reverse_named_env_lists sm_state)
       | SMFail -> None)
    | None -> failwith "Invalid state machine!"
  in
  run { position = 0; env = StrMap.empty; buffer = [] } token_list
;;

(** Helper types for constructing state transitions. * - [Goto id] go to [id] *
    \- [SequenceNext id] matching in a sequence, if ok go to [id] * -
    [SequenceConfirm id] apply changes from buffer and go to [id] * -
    [SequenceFail id] drop buffer and exit sequence processing, go to [id] * -
    [Fail] set state to failed *)
type transition_helper =
  | Goto of int
  | SequenceNext of int
  | SequenceConfirm of int
  | SequenceFail of int
  | Fail

(** Adds changes saved in sm buffer to environment **)
let apply_buffer =
  List.fold_left (fun env -> function
    | t, Some name ->
      StrMap.update
        name
        (function
          | Some (List li) -> Some (List (t :: li))
          | None -> Some (List [ t ])
          (* TODO: replace with an exceptuion *)
          | _ -> failwith "Invalid state machine!")
        env
    | _, None -> env)
;;

let state_transition_of_transition_helper_direct = function
  | Goto next_state ->
    fun (sm_state, _, token_list) ->
      SMGoto
        ( { position = next_state; env = sm_state.env; buffer = sm_state.buffer }
        , token_list )
  | SequenceNext next_state ->
    fun (sm_state, t, token_list) ->
      SMGoto
        ( { position = next_state
          ; env = sm_state.env
          ; buffer = sm_state.buffer @ [ t, None ]
          }
        , token_list )
  | SequenceConfirm next_state ->
    fun (sm_state, _, token_list) ->
      let new_env = apply_buffer sm_state.env sm_state.buffer in
      SMGoto ({ position = next_state; env = new_env; buffer = [] }, token_list)
  | SequenceFail next_state ->
    fun (sm_state, t, token_list) ->
      let clean_buffer = List.map (fun (t, _) -> t) sm_state.buffer in
      SMGoto
        ( { position = next_state; env = sm_state.env; buffer = [] }
        , clean_buffer @ (t :: token_list) )
  | Fail -> fun _ -> SMFail
;;

let state_transition_of_transition_helper_named name = function
  | Goto next_state ->
    fun (sm_state, t, token_list) ->
      (* TODO: Replace with update and check if this is the only assignment *)
      let new_env = StrMap.add name (Single t) sm_state.env in
      SMGoto
        ({ position = next_state; env = new_env; buffer = sm_state.buffer }, token_list)
  | SequenceNext next_state ->
    fun (sm_state, t, token_list) ->
      SMGoto
        ( { position = next_state
          ; env = sm_state.env
          ; buffer = sm_state.buffer @ [ t, Some name ]
          }
        , token_list )
  | SequenceConfirm next_state ->
    fun (sm_state, t, token_list) ->
      let new_env = apply_buffer sm_state.env ((t, Some name) :: sm_state.buffer) in
      SMGoto ({ position = next_state; env = new_env; buffer = [] }, token_list)
  | SequenceFail next_state ->
    fun (sm_state, t, token_list) ->
      let clean_buffer = List.map (fun (t, _) -> t) sm_state.buffer in
      SMGoto
        ( { position = next_state; env = sm_state.env; buffer = [] }
        , clean_buffer @ (t :: token_list) )
  | Fail -> fun _ -> SMFail
;;

(* Generates a transition for a given macro_matcher_element *)
let get_basic_match_transition (next : transition_helper) (fail : transition_helper)
  = function
  | DirectMatch token ->
    fun (sm_state, t, token_rest) ->
      let next = state_transition_of_transition_helper_direct next
      and fail = state_transition_of_transition_helper_direct fail in
      (if t = token then next else fail) (sm_state, t, token_rest)
  | NamedMatch (name, toekn_type) ->
    fun (sm_state, t, token_rest) ->
      let next = state_transition_of_transition_helper_named name next
      and fail = state_transition_of_transition_helper_named name fail in
      (match toekn_type with
       | TIdent ->
         (function
           | Ident _ -> next
           | _ -> fail)
           t
       | TInt ->
         (function
           | Int _ -> next
           | _ -> fail)
           t
       | TFloat ->
         (function
           | Float _ -> next
           | _ -> fail)
           t
       | TString ->
         (function
           | String _ -> next
           | _ -> fail)
           t
       | TChar ->
         (function
           | Char _ -> next
           | _ -> fail)
           t
       | TExpr ->
         (function
           | Ident _ | Int _ | Float _ -> next
           | Direct "+" | Direct "-" | Direct "*" | Direct "/" -> next
           | Direct "%" | Direct "&" | Direct "|" | Direct "^" -> next
           | Direct "<<" | Direct ">>" | Direct "&&" | Direct "||" | Direct "^^" -> next
           | Direct "(" | Direct ")" -> next
           | _ -> fail)
           t
       | TToken ->
         (function
           | EndToken -> fail
           | _ -> next)
           t)
        (sm_state, t, token_rest)
;;

(** State transitions for given sequence starting with 'start_id'. Altered state
    machine will be returned alongside last `sm_state` used. **)
let add_sequence_match_transition
      sm
      start_state
      after_sequence
      mme_list (* TODO: type annotate and reduce *)
  =
  let fail = SequenceFail after_sequence
  and start = SequenceConfirm start_state in
  let rec get_transition sm curr_state = function
    | [] -> sm
    | [ mme ] ->
      let transition = get_basic_match_transition start fail mme in
      StateMachine.add curr_state transition sm
    | mme :: tl ->
      let next_state = curr_state + 1 in
      let transition = get_basic_match_transition (SequenceNext next_state) fail mme in
      let sm = StateMachine.add curr_state transition sm in
      get_transition sm next_state tl
  in
  get_transition sm start_state mme_list
;;

(** Generates a state machine for given macro_matcher_element list **)
let sm_of_macro_matcher_list mm_li =
  let rec acc_transitions sm curr_state = function
    | [] ->
      let transition = function
        | sm_state, EndToken, [] -> SMFinish sm_state
        | _ -> SMFail
      in
      StateMachine.add curr_state transition sm
    | BasicMatch mme :: tl ->
      let next_state = curr_state + 1 in
      let next = Goto next_state in
      let transition = get_basic_match_transition next Fail mme in
      let sm = StateMachine.add curr_state transition sm in
      acc_transitions sm next_state tl
    | SequenceMatch mme_list :: tl ->
      let after_sequence = curr_state + List.length mme_list in
      let transition =
        add_sequence_match_transition sm curr_state after_sequence mme_list
      in
      acc_transitions transition after_sequence tl
  in
  acc_transitions StateMachine.empty 0 mm_li
;;

(** Finds first element of the list for which application to `f` returns `Some
    _`. If no such no such element exists in a list `None` will be returned. **)
let rec find_first f = function
  (* Option-monad :D *)
  | [] -> None
  | x :: xs ->
    (match f x with
     | Some _ as res -> res
     | None -> find_first f xs)
;;

let rec expand env = function
  | [] -> []
  | DirectRes t :: mre_l -> Tok t :: expand env mre_l
  | NamedRes name :: mre_l ->
    let token =
      match StrMap.find_opt name env with
      | Some (List (l :: _)) -> l
      (* TODO: Make this into an exception... *)
      | Some (List []) -> failwith "Empty list cannot be expanded!"
      | Some (Single t) -> t
      | None -> failwith "No such variable in environment!"
    in
    Tok token :: expand env mre_l
  | MacroResUse (name, mre_list) :: mre_l ->
    Use (name, expand env mre_list) :: expand env mre_l
;;

(** Expands sequence of macro_result_element *)
let expandSequence env mre_list =
  let expansion_count =
    let rec count_expr count = function
      | DirectRes _ -> count
      | NamedRes name ->
        (match StrMap.find_opt name env, count with
         | Some (List l), None -> Some (List.length l)
         | Some (List l), Some count -> Some (min count (List.length l))
         | Some (Single _), _ -> failwith "Single value cannot be expanded!"
         | None, count -> count)
      | MacroResUse (_, mre_list) -> List.fold_left count_expr count mre_list
    in
    List.fold_left count_expr None mre_list
  in
  let shorten_env =
    StrMap.map (function
      | Single t -> Single t
      | List (_ :: tl) -> List tl
      | List [] -> List [] (* Allow as it may be unused here *))
  in
  match expansion_count with
  | None -> []
  | Some 0 -> []
  | Some count ->
    let rec expand_n env = function
      | 0 -> []
      | n ->
        let new_env = shorten_env env in
        expand env mre_list @ expand_n new_env (n - 1)
    in
    expand_n env count
;;

let[@tail_mod_cons] rec print_result_tokens env = function
  | [] -> []
  | BasicRes (DirectRes t) :: tl -> Tok t :: print_result_tokens env tl
  | BasicRes (NamedRes name) :: tl ->
    (match StrMap.find_opt name env with
     | Some (Single t) -> Tok t :: print_result_tokens env tl
     (* TODO: rethink this, maybe just exapand the list in place? *)
     | Some (List _) -> failwith "List cannot be printed without expansion!"
     | None -> failwith "No such variable in environment!")
  | BasicRes (MacroResUse (name, mre_list)) :: tl ->
    Use (name, expand env mre_list) :: (print_result_tokens [@tailcall]) env tl
  | SequenceRes mre_list :: tl -> expandSequence env mre_list @ print_result_tokens env tl
  | MacroRes (name, mre_list) :: tl ->
    Use (name, print_result_tokens env mre_list)
    :: (print_result_tokens [@tailcall]) env tl
;;

let token_transformer_of_macro_def macro_def =
  let matches = macro_def.matches in
  let state_machines =
    List.map (fun { matcher; result } -> sm_of_macro_matcher_list matcher, result) matches
  in
  fun macro_tokens ->
    let macro_tokens = macro_tokens @ [ EndToken ] in
    let result =
      find_first
        (fun (sm, res) ->
           match run_state_machine sm macro_tokens with
           | Some st_state -> Some (st_state, res)
           | None -> None)
        state_machines
    in
    match result with
    (* TODO: Convert failwith to exception *)
    | None -> failwith "No matching pattern found!"
    | Some (sm_state, result) -> print_result_tokens sm_state.env result
;;
