module Scraypa
  class UserAgentAbstract
    def initialize(*args)

    end

    def user_agent
      raise NotImplementedError, 'user_agent action not implemented.'
    end

    def list
      raise NotImplementedError, 'list action not implemented'
    end
  end
end
