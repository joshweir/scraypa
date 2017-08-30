require "spec_helper"

module Scraypa
  describe VisitCapybaraHeadlessChromium do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitCapybaraHeadlessChromium
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

    #ENSURE THIS SCRIPT INCLUDES TESTS for limiting the agents by default
    #to 30
  end
end