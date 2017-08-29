require "spec_helper"

module Scraypa
  describe VisitCapybaraHeadlessChromium do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitCapybara
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end


  end
end