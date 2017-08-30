require "spec_helper"

module Scraypa
  describe VisitRestClient do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitRestClient
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

  end
end