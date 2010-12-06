
module Zanelle
  class Loader
    attr_reader :data
    
    class InvalidSource          < StandardError; end
    class UnobtainableSourceData < StandardError; end
  
    def initialize(parent, input, options)
      @parent         = parent
      @input          = input
      @options        = options
      @src_type       = origin
      load_from_source
    end
  
    def uri_parse(input)
      uri = URI.parse(input)
      if uri.scheme.nil?
        raise InvalidSource "Relative path with no base URL" if @parent.base_url.nil?
        uri = URI::Generic.new(*[@parent.base_url, nil, uri.path, nil, nil, nil].flatten)
      else
        # update the base_url
        @parent.base_url = uri.select(:scheme, :userinfo, :host, :port)
      end
      uri
    end
    
    def origin
      raise(InvalidSource, "Input is nil") if @input.nil?
      # Relative URL
      if @input.is_a?(String) && @input[0] == ?/
        @source = uri_parse(@input)
        return :uri
      end
  
      if @input.kind_of?(URI)
        @source = @input
        return :uri
      end
      
      begin
        @source = uri_parse(@input)
        return :uri
      rescue
        raise(UnobtainableSourceData, "Input is of unknown type. #{@input.inspect}")
      end
    end
  
    def load_from_source
      case @src_type
      when :uri
        assign_from_uri
      else
        raise(InvalidSource, "Unknown source type #{@src_type.inspect}")
      end
    end
  
    def assign_from_uri
      _data = read_data
      ext   = extension(@source.to_s)
p _data
p ext
      case ext
      when "yaml", "yml"
        @data = YAML.load(_data)
      else
        @data = JSON.parse(_data)
      end
    rescue => err
      if err.class.is_a? JSON::ParserError
        raise(InvalidSource,
          "Source data is not in JSON format: '#{@source.inspect}")
      else
        raise(UnobtainableSourceData,
          "Source data cannot be read from: '#{@input}, #{ext.inspect}, #{err.class}: #{err}")
      end
    end
  
    def extension(path)
      ext = @source.to_s.downcase.match(/\.?([^.]+)$/)    
      ext.nil? ? "" : ext[1]
    end
  
    def read_data
p @method
      @method == 'get' ? get : post
    end
  
    def get
      @source.open.read
    end

    def post
p @parent.form_vars
      Net::HTTP.post_form(@source, @parent.form_vars).body
    rescue => err
      $stderr.puts err
    end

  end#class Loader
end#module Zanelle
