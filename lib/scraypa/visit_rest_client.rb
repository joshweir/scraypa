require 'rest-client'

module Scraypa
  class VisitRestClient < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
    end

    def execute params={}
      Scraypa.tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      Scraypa.tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      RestClient::Request.execute params
    end
  end
end