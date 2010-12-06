$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'uri'
require 'open-uri'
require 'net/http'
require 'loader'
require 'phoneml_builder'
require 'phoneml_data'
require 'phoneml_command'
require 'phoneml_session'
require 'adhearsion_phoneml'
require 'call_handler'

module Zanelle
  class Base < Zanelle::Loader
    def initialize(call, options)
      @call         = call
      @options      = options
      @debug        = options[:debug]
#      @next_command = config[:zanelle_config][:base_url]
      @next_command = COMPONENTS.zanelle['base_url']
    end

    def run
      log_call
      handle_call
    end
  
    def handle_call
      log_attention
      @call_handler = AdhearsionPhoneMLSession.new(@call)
      @call_handler.run @next_command
    end
    
    def find_call_handler_args
      {
        :@ext_dialed => @call.extension.to_s,
        #:state => get_state,
        :time  => Time.now
      }
    end




    ### Logging
    def log_attention(char='@',count=50)
      Log.debug char*count
    end
    
    def log_call
      Log.debug "="*50
      Log.debug "\n"+"==> CONTEXT: #{@call.context}" 
      log_dump_status
    end
  
    def log_action action
      Log.debug "    - #{action}"
    end
    def log_data data
      Log.debug "      #{data}"
    end
  
    def log_dump_status
      log_data "Unique ID:     #{@call.uniqueid}"
      log_data "Office State:  #{@call.get_state 'office'}"
      log_data "Extension:     #{@call.extension}"
      log_data "DNID:          #{@call.dnid}"
      log_data "CallerID:      #{@call.callerid}"
      log_data "Caller Number: #{@call.caller_num}"
      log_data "CallerID Name: #{@call.calleridname}"
      log_data "Channel:       #{@call.channel}"
      log_data "Priority:      #{@call.priority}"
      log_data "Account Code:  #{@call.accountcode}"
      log_data "Language:      #{@call.language}"
      if @debug
        log_data "-----------------------------------------"
        log_data "Entry Point:            #{@call.__send__(:entry_point)}"
        log_data "Type of Calling Number: #{@call.type_of_calling_number}"
        log_data "RDNIS:                  #{@call.rdnis}"
      end
    end
  
  end#class Base
end#module Zanelle


