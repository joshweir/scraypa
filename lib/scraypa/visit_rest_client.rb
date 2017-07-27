require 'rest-client'

module Scraypa
  class VisitRestClient < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
    end

    def execute params={}
      wrap_response RestClient::Request.execute params
    end

    private

    def wrap_response native_response
      Scraypa::Response.new native_response: native_response
    end
  end
end