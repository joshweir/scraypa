require "spec_helper"

module Scraypa
  describe UserAgentFactory do
    describe ".build" do
      context "when :method :common_aliases" do
        it "instantiates a UserAgentCommonAliases object passing the params" do
          params = {
              list: :common_aliases,
              change_after_n_requests: 2
          }
          expect(UserAgentIterator).to receive(:new).with(params)
          UserAgentFactory.build(params)
        end
      end

      context "when :method :randomizer" do
        it "instantiates a UserAgentRandom object passing the params"
      end

      context "when :method :list" do
        context "when :list param is an Array" do
          it "instantiates a UserAgentUserDefined object passing the params"
        end

        context "when :list param is a Hash" do
          it "instantiates a UserAgentUserDefined object passing the params"
        end

        context "when :list param is a String" do
          it "instantiates a UserAgentUserDefined object passing the params"
        end
      end

      context "when :method is not recognized" do
        it "raises UnrecognisedUserAgentsMethod exception"
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