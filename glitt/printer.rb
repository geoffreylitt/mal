require_relative "types"

def pr_str(form)
  case form
  when MalInteger
    return form.value.to_s
  when MalSymbol
    return form.symbol.to_s
  when Array
    substrings = form.map { |obj| pr_str(obj) }
    return "(#{substrings.join(' ')})"
  end
end
