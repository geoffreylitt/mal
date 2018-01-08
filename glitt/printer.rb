require_relative "types"

def pr_str(ast)
  case ast
  when Integer
    return ast.to_s
  when Symbol
    return ast.to_s
  when Array
    substrings = form.map { |obj| pr_str(obj) }
    return "(#{substrings.join(' ')})"
  end
end
