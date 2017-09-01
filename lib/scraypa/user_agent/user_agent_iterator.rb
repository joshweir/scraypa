module Scraypa
  class UserAgentIterator < UserAgentAbstract
    attr_reader :current_user_agent

    def initialize *args
      super(*args)
      @config = args[0] || {}
      @change_after_n_requests = @config.fetch(:change_after_n_requests, 0)
      @list_limit = @config.fetch(:list_limit, 0).to_i
      @strategy = @config.fetch(:strategy, :roundrobin)
      @list = limit_list to_array@config.fetch(:list, USER_AGENT_LIST)
      @reducing_list = @list.clone
      @current_user_agent = nil
      @current_user_agent_requests = 0
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

    def limit_list list
      @list_limit <= 0 || @list_limit >= list.length ?
          list :
          @strategy == :randomize ?
              limit_list_randomly(list) :
              list[0..@list_limit-1]
    end

    def limit_list_randomly list
      random_list = []
      loop do
        sample = list.sample
        if list.include? sample
          random_list << sample
          list.delete(sample)
        end
        break if random_list.length >= @list_limit
      end
      random_list
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
      return @list.first if @list.length == 1
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
