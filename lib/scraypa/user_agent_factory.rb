module Scraypa
  UnrecognisedUserAgentsMethod = Class.new(StandardError)

  class UserAgentFactory
    def self.build(*args)
      #{
      #    user_agents: :common_aliases,
      #    strategy: :randomize,
      #    change_after_n_requests: 2
      #}

      case args[0] && args[0][:user_agents]
      when :common_aliases, String, Array
        UserAgentIterator.new(*args)
      when :randomizer
        UserAgentRandom.new(*args)
      else
        raise UnrecognisedUserAgentsMethod,
              "User agent not recognized"
      end
    end
  end
end