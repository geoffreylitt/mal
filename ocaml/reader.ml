(* todo: we'll make this type real later *)
type mal_type = String of string | Number of int

type reader = { tokens : string list; position : int }

let token_re =
  Str.regexp
    "~@\\|[][{}()'`~^@]\\|\"\\(\\\\.\\|[^\"]\\)*\"\\|;.*\\|[^][  \n{}('\"`,;)]*"

let tokenizer str =
  List.filter_map
    (function Str.Delim d -> Some d | Str.Text _ -> None)
    (Str.full_split token_re str)

let read_form (reader : reader) : mal_type = String "hi"

let read_str str =
  let tokens = tokenizer str in
  let reader = { tokens = tokenizer str; position = 0 } in
  read_form reader
