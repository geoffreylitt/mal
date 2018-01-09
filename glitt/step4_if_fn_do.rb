require 'byebug'

require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "core"
require_relative "special_forms"

REPL_ENV = Env.new(outer: nil)
NS.each do |symbol, value|
  REPL_ENV.set(symbol, value)
end

class UndefinedSymbolError < StandardError; end

# Resolve symbols in the environment, including handling lists.
# This is a pre-stage to the actual "apply" stage; we're just
# resolving pre-defined symbols.
def eval_ast(ast, env)
  case ast
  when Symbol
    env.get(ast)
  when Array
    ast.map { |element| EVAL(element, env) }
  else
    ast
  end
end

def READ(str)
  read_str(str)
end

# Given an AST, return the evaluated result.
# This is the heart of the language!
def EVAL(ast, env)
  if ast.is_a? Array
    if ast.empty?
      # Nothing to do to evaluate an empty list
      ast
    else
      # This is our "apply" section -- where we interpret a list as
      # a function applied to a list of arguments

      # First, handle the *Special Forms* --

      case ast.first
      when :def!
        # Define a new value in the environment
        # Example usage of def!:
        # (def! a 6) ;=> 6
        env.set(ast[1], EVAL(ast[2], env))
      when :"let*"
        # Define a new environment and evaluate an expression in that env.
        # Example usage of let*:
        # (let* (a 1 b 2) a) ;=> 1

        new_env = Env.new(outer: env)

        # Take pairs from the let* binding list and use them to set
        # values in our newly created environment.
        ast[1].each_slice(2) do |pair|
          new_env.set(pair[0], EVAL(pair[1], new_env))
        end

        # Finally, evaluate the last argument in the new env and return result
        EVAL(ast[2], new_env)
      when :do
        # evaluate all the elements of the list in order, returning the last one
        ast[1..-2].each { |element| EVAL(element, env) }
        EVAL(ast[-1], env)
      when :if
        if truthy?(EVAL(ast[1], env))
          EVAL(ast[2], env)
        else
          ast.length >= 3 ? EVAL(ast[3], env) : nil
        end
      when :or
        if truthy?(EVAL(ast[1], env)) || truthy?(EVAL(ast[2], env))
          true
        else
          false
        end
      when :and
        if truthy?(EVAL(ast[1], env)) && truthy?(EVAL(ast[2], env))
          true
        else
          false
        end
      when :"fn*"
        # Function definition.
        # Example usage:
        # ( (fn* [a b] (+ a b)) 2 3 ) ;=> 5

        # We take advantage of Ruby closures here;
        # we get access to variables like env and ast inside the function
        # we return here.
        -> (*exprs) do
          # Create a new environment with variables bound to the function args
          new_env = Env.new(outer: env, binds: ast[1], exprs: exprs)

          # Evaluate the function body in the context of that new environment
          EVAL(ast[2], new_env)
        end
      else
        # Finally, handle generic function application
        evaluated = eval_ast(ast, env)
        function, *args = evaluated
        function.call(*args)
      end
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

# Defining non-built-in functions is just a matter of executing MAL code when
# we start our REPL.
def define_stdlib
  rep("(def! not (fn* (a) (if a false true)))")
end

# Our main loop;
# simply handles user input and output on the REPL
PROMPT = "user> "
def main
  define_stdlib

  while true
    begin
      print PROMPT
      input = gets
      exit if input.nil?
      output = rep(input)
    rescue UnmatchedParensError, UndefinedSymbolError => e
      output = "Error: #{e.message}"
    rescue => e
      puts "FATAL ERROR!"
      puts e.message
      e.backtrace.each { |line| puts "\t#{line}" }
    end

    puts output
  end
end

main
