require 'loader'

##
# PhoneMLData is one or more PhoneML Commands
#
class PhoneMLData
  attr_reader :input, :source, :src_type, :uri, :data
  attr_accessor :method

  # Source can be
  #   URI [String,URI]- http://, https://, file://,
  #   FILE [String]
  #   JSON [String]
  #   Hash
  def initialize(parent, input, options={})
    @parent    = parent
    @input     = input
    @options   = options || {}

#    form_vars  = @options.has_key?(:form_vars) ? @options[:form_vars] : {}
    method     = @options.has_key?(:method) ? options[:method] : :post
    @options.merge!({:method => method})
    
    @loader    = Zanelle::Loader.new(@parent, @input, @options)
    @data      = @loader.data
    validate_data
  end
  
  def each(&block)
    @data['phoneml'].each(&block)
  end
    
  def data
    @data['phoneml']
  end

  private

  def validate_data
    unless @data.kind_of?(Hash)
      raise(InvalidSourceData,
        "Expected data to be of type Hash. Instead, received #{@data.class} => #{@data.inspect}")
    end
    unless @data.has_key?('phoneml')
      raise(InvalidSourceData, "Data does not contain 'phoneml' key: #{@data.keys.inspect}")
    end
  end
  
end#class PhoneMLData

