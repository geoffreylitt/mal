ESCAPE_PAIRS = [
  ["\\\"", "\""],
  ["\\n", "\n"],
  ["\\\\", "\\"]
]

def unescape(str)
  ESCAPE_PAIRS.each do |pair|
    str.gsub!(pair[0], pair[1])
  end

  str
end

def escape(str)
  ESCAPE_PAIRS.each do |pair|
    str.gsub!(pair[1], pair[0])
  end

  str
end

