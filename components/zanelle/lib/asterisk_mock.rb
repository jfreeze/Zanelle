class Asterisk
  def initialize
    @db = {}
    @db[:office] = {:state => 'closed'}
  end

  def database_get(a, b)
    k = @db[a.to_sym]
    return k if k.nil?
    k[b.to_sym]
  end
  
  def database_put(a,b, value)
    @db[a.to_sym] ||= {}
    @db[a.to_sym][b.to_sym] = value
  end
end

