module Scraypa
  class UserAgentIterator < UserAgentAbstract
    def initialize *args
      super(*args)
      @config = args[0] || {}
      @list = to_array(@config.fetch(:list, USER_AGENT_LIST))
      @reducing_list = @list.clone
      @strategy = @config.fetch(:strategy, :roundrobin)
      @change_after_n_requests = @config.fetch(:change_after_n_requests, 0)
      @current_user_agent_requests = 0
      @current_user_agent = nil
    end

    def user_agent
      get_a_new_user_agent? ? (
        @current_user_agent_requests = 0
        select_user_agent_using_strategy
      ) : (
        @current_user_agent_requests += 1
        @current_user_agent
      )
    end

    def list
      @list
    end

    private

    def to_array variable
      case variable
        when Array
          variable
        when Hash
          variable.values
        else
          [variable]
      end
    end

    def get_a_new_user_agent?
      !@current_user_agent ||
          @current_user_agent_requests >= @change_after_n_requests
    end

    def select_user_agent_using_strategy
      @strategy == :randomize ?
          random_user_agent_from_list :
          next_user_agent_from_list
    end

    def random_user_agent_from_list
      @current_user_agent_requests += 1
      @current_user_agent = ensure_a_new_random_user_agent
    end

    def ensure_a_new_random_user_agent
      random_user_agent = nil
      loop do
        random_user_agent = @list.sample
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
