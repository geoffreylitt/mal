class MalType
end

class MalInteger < MalType
  def initialize(str)
    begin
      @value = Integer(str)
    rescue ArgumentError
      raise InvalidInputError
    end
  end

  attr_accessor :value
end

class MalSymbol < MalType
  def initialize(str)
    @symbol = str.to_sym
  end

  attr_accessor :symbol
end

class InvalidInputError < StandardError
end
