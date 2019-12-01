let read = (x) => x

let eval = (x) => x

let print = (x) => x

let rep = (input) => {
  read(input)
    -> eval
    -> print
}

let rec prompt = () => {
  Js.log("user>");
  Readline.readline((input) => {
    Js.log(input);
    Readline.close();
    prompt();
  });
}

prompt();
