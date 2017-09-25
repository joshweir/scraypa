require "spec_helper"

module Scraypa
  describe VisitRestClient do
    let(:subject) { VisitRestClient.new(config: Configuration.new) }
    it "can be instantiated" do
      expect(subject).to be_an_instance_of VisitRestClient
      expect(subject.kind_of?(VisitInterface)).to be_truthy
    end

    describe "#execute" do
      context "when instantiated with config.tor and tor_proxy" do
        it "executes through the tor proxy block" do
          config = Configuration.new
          config.tor = true
          tor_proxy = double(:tor_proxy)
          params = {method: :get, url: "http://example.com"}
          expect(tor_proxy).to receive(:proxy).and_yield
          expect(RestClient::Request).to receive(:execute).with(params)
          VisitRestClient.new(config: config,
                              tor_proxy: tor_proxy).execute params
        end
      end

      context "when instantiated without config.tor" do
        it "doesn't execute through the tor proxy block" do
          config = Configuration.new
          tor_proxy = double(:tor_proxy)
          params = {method: :get, url: "http://example.com"}
          expect(tor_proxy).to_not receive(:proxy).and_yield
          expect(RestClient::Request).to receive(:execute).with(params)
          VisitRestClient.new(config: config,
                              tor_proxy: tor_proxy).execute params
        end
      end

      context "when @user_agent_retriever is specified" do
        it "retrieves a user agent and merges the user agent " +
               "with the request params" do
          config = Configuration.new
          user_agent_retriever = double(:user_agent_retriever)
          params = {
              method: :get,
              url: "http://example.com",
              headers: {
                  user_agent: "agent1"
              }
          }
          expect(user_agent_retriever)
              .to receive(:user_agent)
                      .and_return("agent1")
          expect(RestClient::Request).to receive(:execute).with(params)
          VisitRestClient.new(config: config,
                              user_agent_retriever: user_agent_retriever).execute params
        end
      end
    end
  end
end