type mal_type =
  | MalSymbol of string
  | MalNumber of int
  | MalList of mal_type list
