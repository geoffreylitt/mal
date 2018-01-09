require_relative "string_transforms"

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

  # Useful for debugging, see what's left in our reader
  def remaining_tokens
    @tokens[@position..-1]
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
  matches.map(&:first).reject{ |token| token == "" }
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

  # Move past the open paren that we peeked at to get here
  reader.next

  while reader.peek != CHAR_CLOSE_LIST
    if reader.peek.nil?
      raise UnmatchedParensError, "Expected ')', got EOF."
    end
    list << read_form(reader)
  end

  # Move past the close paren that we peeked at to end our list reading
  reader.next

  list
end

# Given a reader representing an atom, return our
# internal representation of that atom.
# We use regex matches to decide what data type to assign to the token.

# TODO: figure out if there's a better way to do this than a bunch of
# conditionals with regexes -- feels like this could get too complex with
# many types to parse
def read_atom(reader)
  if !/^\-*[0-9]+$/.match(reader.peek).nil?
    Integer(reader.next)
  elsif !/^\"(.*)\"/.match(reader.peek).nil?
    # Quotation marks get removed from the string in our parsing
    # TODO: figure out if this is actually the right thing to do
    string = Regexp.last_match[1]

    # Convert escaped characters into their internal un-escaped representation.
    unescape(string)
  elsif reader.peek == "true"
    true
  elsif reader.peek == "false"
    false
  elsif reader.peek == "nil"
    nil
  else
    reader.next.to_sym
  end
end

class UnmatchedParensError < StandardError; end
