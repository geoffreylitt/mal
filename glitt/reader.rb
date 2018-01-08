require_relative "types"

# A simple object handling managing state for a set of tokens
class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0

    # puts "Initialized reader with tokens: #{tokens}"
  end

  def next
    token = @tokens[@position]
    @position += 1
    token
  end

  def peek
    @tokens[@position]
  end
end

# Tokenize input and convert to internal data representation
def read_str(str)
  tokens = tokenizer(str)
  reader = Reader.new(tokens)
  read_form(reader)
end

TOKENS_REGEX = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/

CHAR_OPEN_LIST = "("
CHAR_CLOSE_LIST = ")"

# Take string input and return tokens
def tokenizer(str)
  matches = str.scan /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
  matches.map(&:first)
end

# Return the internal data type representing a given reader
def read_form(reader)
  if reader.peek == CHAR_OPEN_LIST
    read_list(reader)
  else
    read_atom(reader)
  end
end

def read_list(reader)
  list = []

  reader.next # iterate past open paren

  while reader.peek != CHAR_CLOSE_LIST
    if reader.peek.nil?
      raise UnmatchedParensError
    end
    list << read_form(reader)
  end

  list
end

# Given a reader representing an atom, return our
# internal representation of that atom.
def read_atom(reader)
  if !/^[0-9]+$/.match(reader.peek).nil?
    Integer(reader.next)
  else
    reader.next.to_sym
  end
end

class UnmatchedParensError < StandardError; end
