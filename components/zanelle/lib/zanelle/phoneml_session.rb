class PhoneMLSession
  include Enumerable
  attr_reader :data, :commands
  attr_accessor :base_url

  COMMANDS = { 
    'say'      => true, 
    'ask'      => true, 
    'record'   => true, 
    'transfer' => true, 
    'goto'     => true, 
    'hangup'   => true,
    'playback' => true
    #'dial'
  }

  def self.run(source)
    new.run(source)
  end
  
  def each(&block)
    @commands.each(&block)
  end
    
  def run(source, method='post')
    @base_url ||= []
    update_form_vars
    @data = PhoneMLData.new(self, source)
    import
    self
  end

  private
  
  def import
    @pending  = []
    @commands = []
    @data.each { |line| store PhoneMLCommand.new(line, self) }
    @commands.concat  @pending
    @commands.flatten!
  end

  def store(mpml)
    if mpml.command == PhoneMLCommand::SAY
      @pending << mpml
    elsif mpml.command == PhoneMLCommand::ASK
      if !@pending.empty?
        pending_say   = @pending.collect { |say| say.argument }
        mpml.other    = mpml.argument # target if successful
        mpml.argument = pending_say.flatten.join(' ')
        @pending      = []
      end
      @commands << mpml
    else
      unless @pending.empty?
        @commands.concat @pending
        @pending = []
      end
      @commands << mpml
    end
  end
end#class PhoneMLSession
