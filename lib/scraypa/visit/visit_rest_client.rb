require 'rest-client'

module Scraypa
  class VisitRestClient < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
    end

    def execute params={}
      @config.tor && @config.tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      @config.tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      RestClient::Request.execute add_user_agent_to(params)
    end

    def add_user_agent_to params
      @config.user_agent_retriever ?
          params.merge({
            headers: {
                user_agent: @config.user_agent_retriever.user_agent
            }
          }) : params
    end
  end
end