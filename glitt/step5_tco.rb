require 'byebug'

require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "core"

REPL_ENV = Env.new(outer: nil)
NS.each do |symbol, value|
  REPL_ENV.set(symbol, value)
end

def truthy?(boolean)
  boolean != nil && boolean != false
end

class UndefinedSymbolError < StandardError; end
class UndefinedFunctionError < StandardError; end

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
  print "." * caller.size
  print caller.size
  print "\n"

  # This is an infinite loop to support tail recursion.
  # Many of the clauses below return to escape the infinite loop.
  loop do
    # puts "EVAL(#{ast},#{env})"
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
          return env.set(ast[1], EVAL(ast[2], env))
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

          # Finally, evaluate the last argument in the new env
          ast = ast[2]
          env = new_env
        when :do
          # evaluate all the elements of the list in order, returning the last one
          ast[1..-2].each { |element| EVAL(element, env) }
          ast = ast[-1]
        when :if
          if truthy?(EVAL(ast[1], env))
            ast = ast[2]
          else
            ast = ast[3] if ast.length >= 4
          end
        when :or
          if truthy?(EVAL(ast[1], env)) || truthy?(EVAL(ast[2], env))
            return true
          else
            return false
          end
        when :and
          if truthy?(EVAL(ast[1], env)) && truthy?(EVAL(ast[2], env))
            return true
          else
            return false
          end
        when :"fn*"
          # Function definition.
          # Example usage:
          # ( (fn* [a b] (+ a b)) 2 3 ) ;=> 5

          # We take advantage of Ruby closures here;
          # we get access to variables like env and ast inside the function
          # we return here.

          # return {
          #   ast: ast[2],
          #   params: ast[1],
          #   env: env,
          #   fn:  -> (*exprs) do
          #     # Create a new environment with variables bound to the function args
          #     new_env = Env.new(outer: env, binds: ast[1], exprs: exprs)

          #     # Evaluate the function body in the context of that new environment
          #     EVAL(ast[2], new_env)
          #   end
          # }

          return -> (*exprs) do
            # Create a new environment with variables bound to the function args
            new_env = Env.new(outer: env, binds: ast[1], exprs: exprs)

            # Evaluate the function body in the context of that new environment
            EVAL(ast[2], new_env)
          end
        else
          # Finally, handle generic function application
          evaluated = eval_ast(ast, env)
          function, *args = evaluated

          if function.is_a? Proc
            return function.call(*args)
          # Handle user-defined functions in a tail-recursion-friendly way.
          elsif function.is_a? Hash
            # Set ast to the function body, to prepare to evaluate it
            # on our next loop iteration.
            ast = function[:ast]

            # Replace the env with a new one with variables bound,
            # we'll use it on our next loop iteration
            env = Env.new(
              outer: function[:env],
              binds: function[:params],
              exprs: args
            )
          else
            raise UndefinedFunctionError, "#{function} is not a function."
          end
        end
      end
    else
      # Atoms simply get resolved in the environment
      return eval_ast(ast, env)
    end
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
  rep("(def! sum2 (fn* (n acc) (if (= n 0) acc (sum2 (- n 1) (+ n acc)))))")
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
