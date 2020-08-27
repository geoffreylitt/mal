(*
  To try things at the ocaml repl:
  rlwrap ocaml

  To see type signatures of all functions:
  ocamlc -i step0_repl.ml

  To run the program:
  ocaml step0_repl.ml
*)

open Mal_types

type env = (string * mal_type) list

(* todo: will need to add support for >2 args later *)
let wrap_fn fn =
  MalBinaryFn
    (fun args ->
      match args with
      | [ MalNumber n1; MalNumber n2 ] -> MalNumber (fn n1 n2)
      | _ -> raise InvalidArgumentTypes)

(* An assoc list should be plenty efficient for small environments;
   easier to program in OCaml than a map. *)
let repl_env : env =
  [
    ("+", wrap_fn ( + ));
    ("-", wrap_fn ( - ));
    ("*", wrap_fn ( * ));
    ("/", wrap_fn ( / ));
  ]

let print exp : string = Printer.pr_str exp

let read str = Reader.read_str str

let rec eval ast (env : env) =
  match ast with
  | MalList [] -> ast
  | MalList list -> (
      let elist = eval_ast ast env in
      match elist with
      | MalList (MalBinaryFn fn :: args) -> fn args
      | _ -> raise InvalidListHead )
  | _ -> eval_ast ast env

and eval_ast ast env =
  match ast with
  | MalSymbol sym -> (
      try List.assoc sym env with Not_found -> raise (SymbolNotFound sym) )
  | MalList list -> MalList (List.map (fun exp -> eval exp env) list)
  | _ -> ast

let rep str = print (eval (read str) repl_env)

let print_exn exn =
  let msg =
    match exn with
    | SymbolNotFound sym -> sym ^ " not found.\n"
    | MismatchedDelimiter delim -> "expected '" ^ delim ^ "', got EOF\n"
    | _ -> "unknown exception occurred.\n"
  in
  output_string stderr msg;
  flush stderr

let main =
  try
    while true do
      print_string "user> ";
      try print_endline (rep (read_line ())) with
      (* These are our internal exceptions which shouldn't crash the repl *)
      | End_of_file -> ()
      | SymbolNotFound sym -> print_exn (SymbolNotFound sym)
      | MismatchedDelimiter delim -> print_exn (MismatchedDelimiter delim)
    done
  with End_of_file -> ()
