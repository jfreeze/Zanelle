class AdhearsionPhoneMLSession < PhoneMLSession
  attr_reader :form_vars
  
  SAY      = 'playback'
  ASK      = 'background'
  
  # Map from PhoneML to Asterisk
  MAP_COMMAND = {
    'speak' => SAY,
    'play'  => SAY,
    'input' => ASK,
  }

  def initialize(call)
    @call      = call
    @responses = []
  end
  
  class << self
    attr_accessor :answered
    # def new(arg)
    #   @answered = nil
    #   super
    # end
  end

  def run(source, method='post')
    super(source)  # reads @data and sets up @commands
    answer
    
    @commands.each { |cmd| break if do_command(cmd) == :abort_sequence }

    load_next_source
  end

  def load_next_source
    return if @next_source.nil?
    ns = @next_source
    @next_source = nil
    run(ns.url, ns.method)
  end
  
  def answer
    @call.answer if !AdhearsionPhoneMLSession.answered
    AdhearsionPhoneMLSession.answered = true
  end
  
  def update_form_vars
    @form_vars ||= {}
    @form_vars.merge! form_vars_hash 
  end
  
  def form_vars_hash
    {
      :caller         => @call.caller_num,   # the caller's phone number (Callerid/ANI)
      :called         => @call.dnid,         # the phone number of the call (DNIS)
      :callguid       => @call.uniqueid,     # unique 37 character identifier of the call
      :channeltype    => @call.channel,      # type of call (voice or sms)
#      :callerinput => @result,                   # the digit(s) or spoken word(s) from the caller's input
#      :callerinputhistory => @responses.inspect, # the digit(s) and spoken word(s) from the callers input throughout the duration of the call separated by commas
      :callername     => @call.calleridname, # reverse phone number lookup returning the name of the caller
      :callerlocation => ""                  # reverse phone number lookup returning the location (city and state) of the caller
    }
  end

   # log_data "Extension:     #{@call.extension}"
   # log_data "CallerID:      #{@call.callerid}"
   # log_data "Priority:      #{@call.priority}"
   # log_data "Account Code:  #{@call.accountcode}"
   # log_data "Language:      #{@call.language}"


  private

  def play(cmd)
    @call.playback(cmd.argument)
  end
  def playback(cmd)
    puts '@'*50
    puts "in playback"
    @call.play(cmd.argument)
  end
  
  def say(cmd)
    @call.say cmd.argument, :voice => @voice
  end

  def ask(cmd)
    result = @call.ask cmd.argument, {
      :voice    => @voice,
      :choices  => cmd.options['@options'],
      :onChoice => lambda { |event|
#        @call.say("You said " + event.choice.interpretation + ", which is a " + event.value, :voice => @voice)
        @next_source = TargetURL.new(cmd.other, cmd.options['@method'] || 'post') unless cmd.other.empty?
        @result      = event.value
        @responses << @result
        update_form_vars
      }
    }
    :abort_sequence if @next_source
  end

  def goto(cmd)
    @next_source = TargetURL.new(cmd.argument, cmd.options['@method'])
    :abort_sequence
  end
  
  def record(cmd)
    @call.record cmd.argument, {
      :beep => true,
      :timeout => 10,
      :silenceTimeout => 7,
      :maxTime => 60,
      :onRecord => lambda { |event|
        log "Recording result = " + event.recordURI
        say "You said " + event.recordURI
      }
    }
  end
  
  def transfer(cmd)
    @call.transfer cmd.argument, {
      :playvalue => cmd.options['@playvalue']
    }
  end
  
  def hangup(cmd)
    @call.hangup
    :abort_sequence
  end
  def do_command(cmd)
    command = MAP_COMMAND[cmd.command] || cmd.command
    if COMMANDS.has_key?(command)
      self.__send__(command.to_sym, cmd)
    else
      raise "Unknown command '#{command}'"
    end
  end
  
end#class AdhearsionPhoneML