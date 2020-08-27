open Mal_types

type reader = { form : mal_type; tokens : string list }

type list_reader = { list_form : mal_type list; tokens : string list }

let token_re =
  Str.regexp
    "~@\\|[][{}()'`~^@]\\|\"\\(\\\\.\\|[^\"]\\)*\"\\|;.*\\|[^][  \n{}('\"`,;)]*"

let tokenizer str =
  List.filter_map
    (function
      | Str.Delim "" -> None | Str.Delim d -> Some d | Str.Text _ -> None)
    (Str.full_split token_re str)

let rec read_list list_reader =
  match list_reader.tokens with
  | [] -> raise (MismatchedDelimiter ")")
  | ")" :: tokens -> { list_form = list_reader.list_form; tokens }
  | token :: tokens ->
      (* Recursively read the first form, then recursively keep reading the list.
         - Accumulate the parsed form onto our list reader
         - Only use the leftover tokens after reading the first form *)
      let reader = read_form list_reader.tokens in
      let list_form = list_reader.list_form @ [ reader.form ] in
      read_list { list_form; tokens = reader.tokens }

and read_atom token =
  let int_re = Str.regexp "^\-?[0-9]+$" in
  if Str.string_match int_re token 0 then MalNumber (int_of_string token)
  else MalSymbol token

and read_form (tokens : string list) : reader =
  match tokens with
  | [] -> raise End_of_file
  | token :: tokens -> (
      match token with
      | "(" ->
          let list_reader = read_list { list_form = []; tokens } in
          { form = MalList list_reader.list_form; tokens = list_reader.tokens }
      | _ -> { form = read_atom token; tokens } )

let read_str str =
  let tokens = tokenizer str in
  (read_form tokens).form
