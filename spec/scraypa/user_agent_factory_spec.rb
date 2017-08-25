require "spec_helper"

module Scraypa
  describe UserAgentFactory do
    describe ".build" do
      context "when user_agents: :common_aliases" do
        it "instantiates a UserAgentCommonAliases object passing the params" do
          expect(UserAgentCommonAliases)
              .to receive(:new)
                      .with(user_agents: :common_aliases,
                            change_after_n_requests: 2)
          UserAgentFactory.build(user_agents: :common_aliases,
                                 change_after_n_requests: 2)
        end
      end

      context "when user_agents: :randomizer" do
        it "instantiates a UserAgentRandom object passing the params"
      end

      context "when :user_agents param is a String" do
        it "instantiates a UserAgentUserDefined object passing the params"
      end

      context "when :user_agents param is an Array" do
        it "instantiates a UserAgentUserDefined object passing the params"
      end

      context "when :user_agents is not recognized" do
        it "raises UnrecognisedUserAgents exception"
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