require 'rubygems'
require 'uri'
require 'open-uri'
require 'net/http'
require 'json'
require 'riot'

$LOAD_PATH.unshift(File.dirname(File.dirname(File.expand_path(__FILE__))))

require 'phoneml_data'

$verbose = false
$DEBUG = true

# module Mock
#   def open
#     $stderr.puts "running mock::open #{uri}" if $verbose
#     self
#   end
#   def read
#     $stderr.puts "running mock::read" if $verbose
#     %({"phoneml":[{"play":{"$":"http://acme.com/jingle.mp3"}}]})
#   end
# end
# class URI::HTTP
#   include Mock
# end
# class URI::Generic
#   include Mock
# end

URL_SRC  = "http://127.0.0.1:4567/simon.json"
URL_BASE = 'http://127.0.0.1:4567'
URI_SRC  = URI.parse(URL_SRC)

class Parent
  attr_accessor :base_url, :form_vars
  def initialize
    @base_url = URL_BASE
    @form_vars = {}
  end
end


context "Instantiation of a PhoneMLData object" do
  # # URL
  asserts("with a URL") { PhoneMLData.new(Parent.new, URL_SRC) }
  # 
  # URI
  asserts("with a URI") { PhoneMLData.new(Parent.new, URI_SRC) }
  asserts("with an invalid URI") { PhoneMLData.new(Parent.new, URI.parse("fred")) }.raises(Zanelle::Loader::UnobtainableSourceData)
  # 
  # # JSON
  asserts("as JSON") { Zanelle::Loader.new(Parent.new, URL_SRC, 'get').__send__(:origin) }
  # 
  # # NIL
  asserts("with a nil value") { PhoneMLData.new(Parent.new, nil) }.raises(Zanelle::Loader::InvalidSource)
end


context "When instantiating with URL" do
  setup {
    ary = []
    PhoneMLData.new(Parent.new, URL_SRC).each { |cmd| ary << cmd }
    ary
  }
  asserts("each should return only one kind of object") { 
    topic.collect { |cmd| cmd.keys.size }.uniq.size 
  }.equals(1)
  asserts("each should return Hash objects") { topic.first }.kind_of(Hash)
end


