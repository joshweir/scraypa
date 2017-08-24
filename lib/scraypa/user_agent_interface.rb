=begin
module Scraypa
  class VisitInterface
    def initialize(*args)
      raise "Scraypa::Configuration object required by Visit interface. " +
                "Got: #{args[0].class}" unless
          args[0].is_a?(Scraypa::Configuration)
    end

    def execute
      raise NotImplementedError, 'execute action not implemented.'
    end
  end
end
=end