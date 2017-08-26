require 'useragents'

module Scraypa
  class UserAgentRandom < UserAgentAbstract
    attr_reader :current_user_agent

    def initialize *args
      super(*args)
      @config = args[0] || {}
      @change_after_n_requests = @config.fetch(:change_after_n_requests, 0)
      @current_user_agent_requests = 0
      @current_user_agent = nil
    end

    def user_agent
      get_a_new_user_agent? ? (
        @current_user_agent_requests = 0
        select_user_agent_using_randomizer
      ) : (
        @current_user_agent_requests += 1
        @current_user_agent
      )
    end

    private

    def get_a_new_user_agent?
      !@current_user_agent ||
          @current_user_agent_requests >= @change_after_n_requests
    end

    def select_user_agent_using_randomizer
      @current_user_agent_requests += 1
      @current_user_agent = ensure_a_new_random_user_agent
    end

    def ensure_a_new_random_user_agent
      random_user_agent = nil
      loop do
        random_user_agent = UserAgents.rand()
        break unless random_user_agent == @current_user_agent
      end
      random_user_agent
    end
  end
end
