module Scraypa
  class VisitRestClient < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
    end

    def execute params={}

    end
  end
end