require "spec_helper"

module Scraypa
  describe VisitCapybaraPoltergeist do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitCapybaraPoltergeist
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

  end
end