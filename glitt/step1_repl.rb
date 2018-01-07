require_relative "reader"
require_relative "printer"
require_relative "types"

def READ(str)
  read_str(str)
end

def EVAL(form)
  form
end

def PRINT(form)
  pr_str(form)
end

def rep(str)
  parsed = READ(str)
  evaluated = EVAL(parsed)
  PRINT(evaluated)
end

PROMPT = "user> "

# Our main loop;
# simply handles user input and output on the REPL
def main
  while true
    print PROMPT
    input = gets.chomp
    # todo: quit on CTRL+D
    puts rep(input)
  end
end

main
