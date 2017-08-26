require "spec_helper"

module Scraypa
  describe UserAgentRandom do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of UserAgentRandom
      expect(subject.kind_of?(UserAgentAbstract)).to be_truthy
    end

    describe "#user_agent" do
      it "uses the UserAgent gem to randomize user agents" do
        attempts = []
        4.times {|i|
          attempts << subject.user_agent
          expect(attempts[i].length).to be > 0
        }
        expect(attempts.uniq.length).to eq attempts.length
      end

      context "when :change_after_n_requests param is populated" do
        let(:subject) { UserAgentRandom.new change_after_n_requests: 2 }
        it "changes the user_agent after n requests" do
          attempts = []
          4.times { attempts << subject.user_agent }
          expect(attempts[0]).to eq attempts[1]
          expect(attempts[1]).to_not eq attempts[2]
          expect(attempts[2]).to eq attempts[3]
        end
      end

      context "when :change_after_n_requests param is empty" do
        it "changes the user_agent every request" do
          attempts = []
          4.times {|i|
            attempts << subject.user_agent
            expect(attempts[i].length).to be > 0
          }
          expect(attempts.uniq.length).to eq attempts.length
        end
      end
    end

    describe "#list" do
      it "returns raises NotImplementedError" do
        expect{subject.list}.to raise_error NotImplementedError
      end
    end
  end
end
