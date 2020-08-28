open Mal_types
module EnvData = Map.Make (String)

type env = { outer : env option; data : mal_type EnvData.t }

let empty outer = { outer; data = EnvData.empty }

(* return a new env with the given key/value pair set *)
let set key value (env : env) =
  { env with data = EnvData.add key value env.data }

(* recursively search upward for an environment containing given key.
   returns None if not found *)
let rec find key (env : env) : env option =
  if EnvData.mem key env.data then Some env
  else match env.outer with Some e -> find key e | None -> None

(* get a key in an environment, including searching outer envs if necessary *)
let get key env =
  match find key env with
  | Some match_env -> EnvData.find key match_env.data
  | None -> raise (SymbolNotFound key)
