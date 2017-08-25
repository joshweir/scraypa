module Scraypa
  class UserAgentIterator < UserAgentAbstract
    def initialize *args
      super(*args)
      @config = args[0]
    end
  end
end
