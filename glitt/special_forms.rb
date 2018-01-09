module SpecialForms
  class << self
    # Define a new value in the environment
    # Example usage of def!:
    # (def! a 6) ;=> 6
    def def!(ast, env)
      env.set(ast[1], EVAL(ast[2], env))
    end

    # Define a new environment and evaluate an expression in that env.
    # Example usage of let*:
    # (let* (a 1 b 2) a) ;=> 1
    def let_star(ast, env)
      new_env = Env.new(outer: env)

      # Take pairs from the let* binding list and use them to set
      # values in our newly created environment.
      ast[1].each_slice(2) do |pair|
        new_env.set(pair[0], EVAL(pair[1], new_env))
      end

      # Finally, evaluate the last argument in the new env and return result
      EVAL(ast[2], new_env)
    end

    # evaluate all the elements of the list in order, returning the last one
    def do(ast, env)
      ast[1..-2].each { |element| EVAL(element, env) }
      EVAL(ast[-1], env)
    end

    def if(ast, env)
      cond_result = EVAL(ast[1], env)
      # Fuzzy truthiness is born!
      if cond_result != nil && cond_result != false
        EVAL(ast[2], env)
      else
        ast.length >= 3 ? EVAL(ast[3], env) : nil
      end
    end

    # Function definition.
    # Example usage:
    # ( (fn* [a b] (+ a b)) 2 3 ) ;=> 5
    def fn_star(ast, env)
      # We take advantage of Ruby closures here;
      # we get access to variables like env and ast inside the function
      # we return here.
      -> (*exprs) do
        # Create a new environment with variables bound to the function args
        new_env = Env.new(outer: env, binds: ast[1], exprs: exprs)

        # Evaluate the function body in the context of that new environment
        EVAL(ast[2], new_env)
      end
    end
  end
end
