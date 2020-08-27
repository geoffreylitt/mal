(*
  To try things at the ocaml repl:
  rlwrap ocaml

  To see type signatures of all functions:
  ocamlc -i step0_repl.ml

  To run the program:
  ocaml step0_repl.ml
*)

let read str = Reader.read_str str

let eval ast _any = ast

let print exp : string = Printer.pr_str exp

let rep str = print (eval (read str) "")

let main =
  try
    while true do
      print_string "user> ";
      try print_endline (rep (read_line ())) with End_of_file -> ()
    done
  with End_of_file -> ()
