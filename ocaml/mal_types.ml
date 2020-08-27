type mal_type =
  | MalSymbol of string
  | MalNumber of int
  | MalList of mal_type list
  | MalBinaryFn of (mal_type list -> mal_type)
