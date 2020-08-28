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
      | _ -> raise InvalidArgumentTypes)

(* Fold over a list of built-in functions to create a repl env *)
let repl_env : Env.env =
  List.fold_left
    (fun env (sym, value) -> Env.set sym value env)
    (Env.empty None)
    [
      ("+", wrap_fn ( + ));
      ("-", wrap_fn ( - ));
      ("*", wrap_fn ( * ));
      ("/", wrap_fn ( / ));
    ]

let print exp : string = Printer.pr_str exp

let read str = Reader.read_str str

(* Top-level eval, including function application *)
let rec eval ast (env : Env.env) : mal_type * Env.env =
  match ast with
  | MalList [] -> (ast, env)
  (* handle special forms *)
  | MalList (MalSymbol "def!" :: rest) -> (MalSymbol "hi", env)
  | MalList (MalSymbol "let*" :: rest) -> (MalSymbol "hi", env)
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
  let exp, _env = eval (read str) repl_env in
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
    done
  with End_of_file -> ()
