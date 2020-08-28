(*
  To try things at the ocaml repl:
  rlwrap ocaml

  To see type signatures of all functions:
  ocamlc -i step0_repl.ml

  To run the program:
  ocaml step0_repl.ml
*)

open Mal_types

(* todo: will need to add support for >2 args later *)
let wrap_fn fn =
  MalBinaryFn
    (fun args ->
      match args with
      | [ MalNumber n1; MalNumber n2 ] -> MalNumber (fn n1 n2)
      | _ -> raise (InvalidArguments "function expects numbers"))

let builtin_env =
  List.fold_left
    (fun env (sym, value) -> Env.set sym value env)
    (Env.empty None)
    [
      ("+", wrap_fn ( + ));
      ("-", wrap_fn ( - ));
      ("*", wrap_fn ( * ));
      ("/", wrap_fn ( / ));
    ]

(* Fold over a list of built-in functions to create a repl env *)
let repl_env = ref builtin_env

let print exp : string = Printer.pr_str exp

let read str = Reader.read_str str

let rec group_pairs list =
  match list with
  | fst :: snd :: rest -> (fst, snd) :: group_pairs rest
  | [] -> []
  | _ -> raise (InvalidArguments "let* expects even list length")

(* Top-level eval, including function application *)
let rec eval ast (env : Env.env) : mal_type * Env.env =
  match ast with
  | MalList [] -> (ast, env)
  (* def!: evaluate the argument, and register in the environment *)
  | MalList (MalSymbol "def!" :: args) -> (
      match args with
      | [ MalSymbol name; exp ] ->
          let value, env = eval exp env in
          (* todo: instead of returning result here, could return None, and
             explicitly represent side-effecting forms in the repl that way *)
          (value, Env.set name value env)
      | _ -> raise (InvalidArguments "def! expects name and expression") )
  (* let*: create a new environment inside current one, register list of bindings,
           and then evaluate exp inside that environment. *)
  | MalList (MalSymbol "let*" :: args) -> (
      match args with
      | [ MalList bindings; exp ] ->
          let new_env =
            List.fold_left
              (fun env pair ->
                match pair with
                | MalSymbol sym, exp ->
                    let value, env = eval exp env in
                    Env.set sym value env
                | _ ->
                    raise
                      (InvalidArguments "let* expects pairs of symbol, value"))
              (Env.empty (Some env)) (group_pairs bindings)
          in
          let result, _ = eval exp new_env in
          (* IMPORTANT: we don't return the new env, it's local to the let *)
          (result, env)
      | _ ->
          raise
            (InvalidArguments "let* expects list of bindings and expression") )
  (* normal function application *)
  | MalList list -> (
      (* call-by-value: depth-first evaluate, then apply function. shadow env. *)
      let elist, env = eval_ast ast env in
      match elist with
      | MalList (MalBinaryFn fn :: args) -> (fn args, env)
      | _ -> raise InvalidListHead )
  | _ -> eval_ast ast env

(* Lower level eval: doesn't do function application for lists *)
and eval_ast ast env : mal_type * Env.env =
  match ast with
  | MalSymbol sym -> (Env.get sym env, env)
  | MalList list ->
      (MalList (List.map (fun exp -> fst (eval exp env)) list), env)
  | _ -> (ast, env)

let rep str =
  let exp, env = eval (read str) !repl_env in
  (* update our repl_env to point to the new env after eval *)
  repl_env := env;
  print exp

let print_exn exn =
  let msg =
    match exn with
    | SymbolNotFound sym -> sym ^ " not found."
    | MismatchedDelimiter delim -> "expected '" ^ delim ^ "', got EOF"
    | InvalidListHead -> "expected function as first element of list."
    | _ -> "unknown exception occurred."
  in
  output_string stderr (msg ^ "\n");
  flush stderr

let main =
  try
    while true do
      print_string "user> ";
      try print_endline (rep (read_line ())) with
      (* These are our internal exceptions which shouldn't crash the repl *)
      | SymbolNotFound sym -> print_exn (SymbolNotFound sym)
      | MismatchedDelimiter delim -> print_exn (MismatchedDelimiter delim)
      | InvalidListHead -> print_exn InvalidListHead
      (* This case catches unexpected bugs in the interpreter.
         We catch these exceptions to make mal tests run more smoothly --
         this way, failed tests of deferred functionality don't blow things up.
         But later on might want to remove this case and let the interpreter crash? *)
      | e -> print_exn e
    done
  with End_of_file -> ()
