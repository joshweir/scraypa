require 'useragents'

module Scraypa
  class UserAgentRandom < UserAgentAbstract
    attr_reader :current_user_agent

    def initialize *args
      super(*args)
      @config = args[0] || {}
      @change_after_n_requests = @config.fetch(:change_after_n_requests, 0)
      @list_limit = @config.fetch(:list_limit, 0).to_i
      random_limited_list if @list_limit > 0
      @current_user_agent = nil
      @current_user_agent_requests = 0
    end

    def user_agent
      get_a_new_user_agent? ? (
        @current_user_agent_requests = 0
        @list ?
            next_user_agent_from_list :
            select_user_agent_using_randomizer
      ) : (
        @current_user_agent_requests += 1
        @current_user_agent
      )
    end

    private

    def random_limited_list
      @list = []
      loop do
        random_ua = UserAgents.rand()
        @list << random_ua unless @list.include? random_ua
        break if @list.length >= @list_limit
      end
      @reducing_list = @list.clone
    end

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

    def next_user_agent_from_list
      @reducing_list = @list.clone if @reducing_list.empty?
      @current_user_agent_requests += 1
      @current_user_agent = @reducing_list.shift
    end
  end
end
