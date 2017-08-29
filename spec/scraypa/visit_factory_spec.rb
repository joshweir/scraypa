require "spec_helper"

module Scraypa
  describe VisitFactory do
    describe ".build" do
      context "when :method :randomizer" do
        let(:subject) { UserAgentFactory.build({method: :randomizer,
                                                change_after_n_requests: 2}) }
        it "instantiates a UserAgentRandom object" do
          expect(subject.class).to eq UserAgentRandom
        end

        it "passes the params to the instantiated object" do
          params = {
              method: :randomizer,
              change_after_n_requests: 2
          }
          expect(UserAgentRandom).to receive(:new).with(params)
          UserAgentFactory.build(params)
        end
      end

      context "when :method is not :randomizer" do
        let(:subject) { UserAgentFactory.build({list: :common_aliases,
                                                change_after_n_requests: 2}) }
        it "instantiates a UserAgentIterator object" do
          expect(subject.class).to eq UserAgentIterator
        end

        it "instantiates a UserAgentIterator object passing the params" do
          params = {
              list: :common_aliases,
              change_after_n_requests: 2
          }
          expect(UserAgentIterator).to receive(:new).with(params)
          UserAgentFactory.build(params)
        end
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