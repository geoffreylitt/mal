let read = (x) => x

let eval = (x) => x

let print = (x) => x

let rep = (input) => {
  read(input)
    -> eval
    -> print
}

let print_prompt = () => print_string("user> ");

Readline.readline((input) => {
  rep(input) -> print_endline;
  print_prompt();
});

print_prompt();
