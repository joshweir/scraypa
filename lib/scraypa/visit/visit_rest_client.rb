require 'rest-client'

module Scraypa
  class VisitRestClient < VisitInterface
    def initialize params={}
      super(params)
      @config = params[:config]
      @tor_proxy = params[:tor_proxy]
      @user_agent_retriever = params[:user_agent_retriever]
    end

    def execute params={}
      @config.tor && @tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      @tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      RestClient::Request.execute add_user_agent_to(params)
    end

    def add_user_agent_to params
      @user_agent_retriever ?
          params.merge({
            headers: {
                user_agent: @user_agent_retriever.user_agent
            }
          }) : params
    end
  end
end