module Scraypa
  class UserAgentAbstract
    def initialize(*args)
      args[0] ? (
        @method = args[0].fetch(:method, :list)
        @list = to_array args[0].fetch(:list,
                            (@method == :list ?
                              USER_AGENT_LIST : []))
      ) : (
        @method = :list
        @list = USER_AGENT_LIST
      )
    end

    def user_agent
      raise NotImplementedError, 'user_agent action not implemented.'
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
  end
end
