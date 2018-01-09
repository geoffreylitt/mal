class Env
  def initialize(outer)
    @data = {}
    @outer = outer
  end

  def set(key, value)
    @data[key] = value
  end

  def find(key)
    if @data.key?(key)
      return @data
    else
      return @outer if !@outer.nil?
    end
  end

  def get(key)
    env = find(key)

    if env.nil?
      raise UndefinedSymbolError, "'#{key.to_s}' not found."
    else
      env[key]
    end
  end
end
