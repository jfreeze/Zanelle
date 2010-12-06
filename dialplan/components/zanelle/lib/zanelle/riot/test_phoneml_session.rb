require 'rubygems'
require 'uri'
require 'open-uri'
require 'net/http'
require 'json'
require 'riot'

$LOAD_PATH.unshift(File.dirname(File.dirname(File.expand_path(__FILE__))))

require 'loader'
require 'phoneml_data'
require 'phoneml_command'
require 'phoneml_session'

$verbose = false

URL_SRC  = "http://localhost:4567/calls/create.json"
URL_BASE = 'http://localhost:4567'

class PhoneMLSession
  attr_accessor :form_vars
  def update_form_vars
    @form_vars = {}
  end
end

context "When instantiating" do
  setup {
    PhoneMLSession.run(URL_SRC)
  }
  asserts("PhoneMLSession.data.data count") { topic.data.data.size }.equals(3)
  asserts("PhoneMLSession.commands.size") { topic.commands.size }.equals(3)
  asserts("PhoneMLSession.commands.class") { topic.commands.first }.kind_of(PhoneMLSession::PhoneMLCommand)
  context "/call/create commands" do
    setup { topic.commands.collect }
    asserts("command 0") { topic[0].command }.equals('speak')
    asserts("argument for command 0") { topic[0].argument }.equals('Welcome')
    asserts("command 1") { topic[1].command }.equals('transfer')
    asserts("argument for command 1") { topic[1].argument }.equals('Sip/590')
    asserts("command 2") { topic[2].command }.equals('hangup')
  end
end

=begin
context 'When testing SPEAK' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_SPEAK_01)
    pml.commands 
  }
  context "commands" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('say')
    asserts("argument") { topic.argument }.equals("This is a test of Phone M L.")
    asserts("option") { topic.options }.equals({})
  end
end
=end

# context 'When testing PLAY' do
#   setup { pml = PhoneMLSession.new
#     pml.__send__(:run,PML_PLAY_01)
#     pml.commands 
#   }
#   context "commands" do
#     setup { topic.first }
#     asserts("command") { topic.command }.equals('say')
#     asserts("argument") { topic.argument }.equals("http://acme.com/jingle.mp3")
#     asserts("option") { topic.options }.equals({})
#   end
# end

=begin
context 'When testing INPUT' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_INPUT_01)
    pml.commands 
  }
  context "commands" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('ask')
    asserts("argument") { topic.argument }.equals("http://acme.com/jingle.mp3")
    asserts("option") { topic.options }.equals({})
  end
end

context 'When testing RECORD' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_RECORD_01)
    pml.commands 
  }
  context "commands" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('record')
    asserts("argument") { topic.argument }.equals("http://acme.com/jingle.mp3")
    asserts("option") { topic.options }.equals({})
  end
end

context 'When testing TRANSFER' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_TRANSFER_01)
    pml.commands 
  }
  context "commands" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('transfer')
    asserts("argument") { topic.argument }.equals("http://acme.com/jingle.mp3")
    asserts("option") { topic.options }.equals({})
  end
end

context 'When testing GOTO' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_GOTO_01)
    pml.commands 
  }
  context "commands" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('goto')
    asserts("argument") { topic.argument }.equals("http://localhost/goto01.json")
    asserts("option") { topic.options }.equals({})
  end

  context "commands" do
    setup { pml = PhoneMLSession.new
      pml.__send__(:run,PML_GOTO_02)
      pml.commands.first
    }
    asserts("command") { topic.command }.equals('goto')
    asserts("argument") { topic.argument }.equals("http://localhost/goto01.json")
    asserts("option") { topic.options }.equals({"@method"=>"post"})
  end
end

context 'When testing HANGUP' do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_HANGUP_01)
    pml.commands 
  }
  context "hangup" do
    setup { topic.first }
    asserts("command") { topic.command }.equals('hangup')
    asserts("argument") { topic.argument }.equals(nil)
    asserts("option") { topic.options }.equals({})
  end

  context "hangup with URL" do
    setup { pml = PhoneMLSession.new
      pml.__send__(:run,PML_HANGUP_02)
      pml.commands.first
    }
    asserts("command") { topic.command }.equals('hangup')
    asserts("argument") { topic.argument }.equals("http://localhost/h3")
    asserts("option") { topic.options }.equals({})
  end

  context "hangup with post URL" do
    setup { pml = PhoneMLSession.new
      pml.__send__(:run,PML_HANGUP_03)
      pml.commands.first
    }
    asserts("command") { topic.command }.equals('hangup')
    asserts("argument") { topic.argument }.equals("http://localhost/h4")
    asserts("option") { topic.options }.equals({"@method"=>"post"})
  end
end

context "Testing collect" do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_SPEAK_01)
    pml.commands 
  }
  asserts("PhoneMLSession object") { topic }.respond_to(:collect)
  asserts("PhoneMLSession object") { topic }.respond_to(:map)
  asserts("PhoneMLSession object") { topic }.respond_to(:to_a)
  asserts("to_a.first") { topic.to_a[0] }.kind_of(PhoneMLSession::PhoneMLCommand)
  asserts("array size") { topic.to_a.size }.equals(1)
  context "" do
    setup { topic.to_a.first }
    asserts("phoneml command") { topic.command }.equals('say')
    asserts("phoneml argument") { topic.argument }.equals("This is a test of Phone M L.")
    asserts("phoneml options") { topic.options }.equals({})
  end
end

context "When testing steps" do
  setup { pml = PhoneMLSession.new
    pml.__send__(:run,PML_2STEPS)
    pml.commands 
  }
  asserts("number of steps") { topic.to_a.size }.equals(2)
  asserts("steps") { topic.collect { |t| t.command } }.equals(['say','hangup'])
end


=end