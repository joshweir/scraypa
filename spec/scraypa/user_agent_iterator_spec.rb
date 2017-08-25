require "spec_helper"

module Scraypa
  describe UserAgentIterator do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of UserAgentIterator
      expect(subject.kind_of?(UserAgentAbstract)).to be_truthy
    end
  end
end
