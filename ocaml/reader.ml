(* todo: we'll make this type real later *)
type mal_type = String of string | Number of int

type reader = { form : mal_type; tokens : string list }

let token_re =
  Str.regexp
    "~@\\|[][{}()'`~^@]\\|\"\\(\\\\.\\|[^\"]\\)*\"\\|;.*\\|[^][  \n{}('\"`,;)]*"

let tokenizer str =
  List.filter_map
    (function Str.Delim d -> Some d | Str.Text _ -> None)
    (Str.full_split token_re str)

let read_form (reader : reader) : mal_type = String "hi"

let read_str str = read_form { form = String ""; tokens = tokenizer str }
