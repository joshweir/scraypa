require "spec_helper"

module Scraypa
  describe UserAgentAbstract do
    describe "#user_agent" do
      it "raises NotImplementedError" do
        expect{UserAgentAbstract.new.user_agent}
            .to raise_error NotImplementedError
      end
    end

    describe "#list" do
      it "raises NotImplementedError" do
        expect{UserAgentAbstract.new.list}
            .to raise_error NotImplementedError
      end
    end
  end
end

=begin
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
=end