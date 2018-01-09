require_relative "string_transforms"

def pr_str(ast, print_readably: true)
  case ast
  when Integer  then ast.to_s
  when Symbol   then ast.to_s
  when String   then "\"#{print_readably ? escape(ast) : ast}\""
  when true     then "true"
  when false    then "false"
  when nil      then "nil"
  when Array    then "(#{ast.map { |obj| pr_str(obj) }.join(' ')})"
  end
end
