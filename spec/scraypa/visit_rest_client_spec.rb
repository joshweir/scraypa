require "spec_helper"

module Scraypa
  describe VisitRestClient do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitRestClient
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

    describe "#execute" do
      context "when instantiated with config.tor and config.tor_proxy" do

      end

      context "when instantiated without config.tor" do

      end
    end
  end
end