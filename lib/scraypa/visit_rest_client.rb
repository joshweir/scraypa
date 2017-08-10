require 'rest-client'

module Scraypa
  class VisitRestClient < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
    end

    def execute params={}
      Scraypa.tor_controller ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      Scraypa.tor_controller.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      wrap_response RestClient::Request.execute params
    end

    def wrap_response native_response
      Scraypa::Response.new native_response: native_response
    end
  end
end