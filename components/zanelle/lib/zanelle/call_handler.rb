require 'logger'

module Zanelle
  class CallHandler
    def initialize(call, pml)
      @call = call
      @pml  = pml
    end

    def run
      @call.log_action "Dialing to internal"

      sip        = ['590'].flatten.map { |s| "SIP/#{s}" }.join("&")

      duration = 100
      options  = {}
      @call.dial sip, :for => duration, :options => ''

      @call.handle_internal_unsuccessful_call
      @call.end_call
    end
  end#class CallHandler
end#module Zanelle
