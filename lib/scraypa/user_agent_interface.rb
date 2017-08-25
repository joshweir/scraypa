module Scraypa
  class UserAgentInterface
    def initialize(*args)

    end

    def user_agent
      raise NotImplementedError, 'user_agent action not implemented.'
    end
  end
end
