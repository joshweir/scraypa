module Scraypa
  class VisitFactory
    def self.build(*args)
      args[0] && args[0][:use_javascript] ?
        VisitCapybara.new(*args) :
        VisitRestClient.new(*args)
    end
  end
end