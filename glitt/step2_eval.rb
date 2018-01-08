require 'byebug'

require_relative "reader"
require_relative "printer"
require_relative "types"

REPL_ENV = {
  '+' => lambda { |a, b| a + b },
  '-' => lambda { |a, b| a - b },
  '*' => lambda { |a, b| a * b },
  '/' => lambda { |a, b| (a / b).to_i },
}

class UndefinedSymbolError < StandardError; end

# Resolve symbols in the environment, and handle list evaluation
def eval_ast(ast, env)
  case ast
  when MalSymbol
    result = env[ast.symbol.to_s]
    raise UndefinedSymbolError if result.nil?
    result
  when Array
    ast.map { |element| EVAL(element, env) }
  else
    ast
  end
end

def READ(str)
  read_str(str)
end

# Given an AST, return the evaluated result
def EVAL(ast, env)
  if ast.is_a? Array
    if ast.empty?
      # Nothing to do to evaluate an empty list
      ast
    else
      # non-empty lists get interpreted as a function call
      evaluated = eval_ast(ast, env)
      function, *args = evaluated
      byebug
      function.call(*args)
    end
  else
    # Atoms simply get resolved in the environment
    eval_ast(ast, env)
  end
end

# Given an AST, print it to the user
def PRINT(ast)
  pr_str(ast)
end

def rep(str)
  parsed = READ(str)
  evaluated = EVAL(parsed, REPL_ENV)
  PRINT(evaluated)
end

# Our main loop;
# simply handles user input and output on the REPL
PROMPT = "user> "
def main
  while true
    begin
      print PROMPT
      input = gets.chomp
      # todo: quit on CTRL+D
      output = rep(input)
    rescue UnmatchedParensError
      output = "Expected ')', got EOF"
    end

    puts output
  end
end

main
