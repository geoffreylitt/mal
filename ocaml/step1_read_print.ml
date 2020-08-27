(*
  To try things at the ocaml repl:
  rlwrap ocaml

  To see type signatures of all functions:
  ocamlc -i step0_repl.ml

  To run the program:
  ocaml step0_repl.ml
*)

open Mal_types

let read str = Reader.read_str str

let eval ast _any = ast

let print exp : string = Printer.pr_str exp

let rep str = print (eval (read str) "")

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
