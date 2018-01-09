class Env
  def initialize(outer:, binds: [], exprs: [])
    @data = {}
    @outer = outer
    binds.zip(exprs).each do |symbol, expr|
      @data[symbol] = expr
    end
  end

  def set(key, value)
    @data[key] = value
  end

  # Recurse upwards through parent environments looking for given key
  def find(key)
    if @data.key?(key)
      return self
    else
      return @outer.find(key) if !@outer.nil?
    end
  end

  # Resolve a key in the environment, including parent environments
  def get(key)
    env = find(key)

    if env.nil?
      raise UndefinedSymbolError, "'#{key.to_s}' not found."
    else
      env.simple_get(key)
    end
  end

  # Just fetch the key from the internal data hash,
  # don't do any parent environment resolution
  def simple_get(key)
    @data[key]
  end
end
