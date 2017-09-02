require "spec_helper"

module Scraypa
  describe VisitRestClient do
    let(:subject) { VisitRestClient.new(Configuration.new) }
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitRestClient
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

    describe "#execute" do
      context "when instantiated with config.tor and config.tor_proxy" do
        it "executes through the tor proxy block" do
          config = Configuration.new
          config.tor = true
          config.tor_proxy = double("tor_proxy")
          params = {method: :get, url: "http://example.com"}
          expect(config.tor_proxy).to receive(:proxy).and_yield
          expect(RestClient::Request).to receive(:execute).with(params)
          VisitRestClient.new(config).execute params
        end
      end

      context "when instantiated without config.tor" do

      end
    end
  end
end