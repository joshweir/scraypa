module Scraypa
  class VisitInterface
    def initialize(params)
      raise "Scraypa::Configuration object required by Visit interface. " +
                "Got: #{args[0].class}" unless
          params && params[:config].is_a?(Scraypa::Configuration)
    end

    def execute
      raise NotImplementedError, 'execute action not implemented.'
    end
  end
end