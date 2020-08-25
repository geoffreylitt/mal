(* todo: we'll make this type real later *)
type mal_type =
  | MalString of string
  | MalNumber of int
  | MalList of mal_type list

type reader = { tokens : string list; position : int }

let token_re =
  Str.regexp
    "~@\\|[][{}()'`~^@]\\|\"\\(\\\\.\\|[^\"]\\)*\"\\|;.*\\|[^][  \n{}('\"`,;)]*"

let tokenizer str =
  List.filter_map
    (function Str.Delim d -> Some d | Str.Text _ -> None)
    (Str.full_split token_re str)

let rec read_list reader =
  MalList (List.map (fun _t -> read_form reader) reader.tokens)

and read_atom reader = MalString "hi"

and read_form (reader : reader) : mal_type =
  match reader.tokens with
  | [] -> raise End_of_file
  | token :: tokens -> (
      match token with "(" -> read_list reader | _ -> read_atom reader )

let read_str str =
  let tokens = tokenizer str in
  let reader = { tokens = tokenizer str; position = 0 } in
  read_form reader
