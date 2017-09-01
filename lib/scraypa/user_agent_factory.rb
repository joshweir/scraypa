module Scraypa
  class UserAgentFactory
    def self.build(*args)
      #{
      #    method: :common_aliases, :randomizer
      #    list: :common_aliases,
      #    strategy: :randomize,
      #    change_after_n_requests: 2
      #}

      case args[0] && args[0][:method]
        when :randomizer
          UserAgentRandom.new(*args)
        else
          UserAgentIterator.new(*args)
      end
    end
  end
end