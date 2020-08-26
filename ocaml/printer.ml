open Mal_types

let rec pr_str exp : string =
  match exp with
  | MalSymbol sym -> sym
  | MalNumber num -> string_of_int num
  | MalList exps ->
      String.concat ""
        [ "("; String.concat " " (List.map (fun e -> pr_str e) exps); ")" ]
