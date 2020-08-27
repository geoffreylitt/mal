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
      | _ -> raise (Invalid_argument "Expected numeric arguments"))

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
      | _ -> raise (Invalid_argument "Expected function at beginning of list") )
  | _ -> eval_ast ast env

and eval_ast ast env =
  match ast with
  | MalSymbol sym -> List.assoc sym env
  | MalList list -> MalList (List.map (fun exp -> eval exp env) list)
  | _ -> ast

let rep str = print (eval (read str) repl_env)

let main =
  try
    while true do
      print_string "user> ";
      try print_endline (rep (read_line ())) with
      | End_of_file -> ()
      | Invalid_argument _ -> ()
    done
  with End_of_file -> ()
