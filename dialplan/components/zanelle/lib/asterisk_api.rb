$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'config'

class Asterisk
  def initialize
    #@config      = load_config
  end
  def database_get(a, b)
    `#{@config[:asterisk]} -rx 'database get #{a}} #{b}'`.strip[7..-1].to_s
  end
  
  def database_put(a,b, value)
    `#{@config[:asterisk]} -rx 'database put #{a} #{b} #{value}'`
  end
end
