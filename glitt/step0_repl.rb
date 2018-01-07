def READ(str)
  str
end

def EVAL(str)
  str
end

def PRINT(str)
  str
end

def rep(str)
  parsed = READ(str)
  evaluated = EVAL(parsed)
  PRINT(evaluated)
end

PROMPT = "user> "

def main
  while true
    print PROMPT
    input = gets.chomp
    # todo: quit on CTRL+D
    puts rep(input)
  end
end

main
