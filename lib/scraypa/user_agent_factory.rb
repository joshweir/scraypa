module Scraypa
  UnrecognisedUserAgents = Class.new(StandardError)

  class UserAgentFactory
    def self.build(*args)
      #{
      #    user_agents: :common_aliases,
      #    strategy: :randomize,
      #    change_after_n_requests: 2
      #}

      case args[0] && args[0][:user_agents]
      when :common_aliases
        UserAgentCommonAliases.new(*args)
      when :randomizer
        UserAgentRandom.new(*args)
      when String, Array
        UserAgentUserDefined.new(*args)
      else
        raise UnrecognisedUserAgents
      end
    end
  end
end