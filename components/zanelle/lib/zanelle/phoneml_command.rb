class PhoneMLCommand
  attr_reader :parent
  attr_accessor :command, :argument, :options, :other

  SAY      = 'say'
  ASK      = 'ask'
  
  class InvalidPhoneMLCommand < StandardError; end
  
  def initialize(line, parent)
    @line     = line
    @parent   = parent
    raise(InvalidPhoneMLCommand, "PhoneMLCommand only parses commands from Hash: #{@line.class}") unless @line.is_a?(Hash)
    parse
  end

  private
  
  def parse
    raise(InvalidPhoneMLCommand, "Only one keyword allowed. Found: #{@line.keys}") if @line.keys.size != 1
    key       = @line.keys.first
    @command  = map_command(key)
    data      = @line[key]
    @argument = data['$']
    @options  = data.reject { |k,v| k[0] != ?@ }
  end
  
  def map_command(cmd)
    str_cmd = cmd.to_s
    # => MAP_HASH[str_cmd] || str_cmd
  end
end

