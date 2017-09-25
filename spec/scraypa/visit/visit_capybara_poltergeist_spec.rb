require "spec_helper"

module Scraypa
  describe VisitCapybaraPoltergeist do
    let(:nodriver) { VisitCapybaraPoltergeist.new(config: Configuration.new) }

    it "raises exception when valid poltergeist driver is not specified" do
      expect{nodriver}.to raise_error Scraypa::CapybaraDriverUnsupported
    end

    context "with config.driver = :poltergeist" do
      it_behaves_like "a capybara poltergeist driver setter-upper-er",
                      driver: :poltergeist,
                      expected_driver_name: :poltergeist

      context "with config.tor = true" do
        it_behaves_like "a capybara poltergeist driver setter-upper-er",
                        driver: :poltergeist,
                        tor: true,
                        tor_options: {tor_port: 9050},
                        expected_driver_name: :poltergeisttor9050
      end
    end

    context "with config.driver = :poltergeist_billy" do
      it_behaves_like "a capybara poltergeist driver setter-upper-er",
                      driver: :poltergeist_billy,
                      expected_driver_name: :poltergeist_billy
    end

    describe "#execute" do
      context "when instantiated with config.tor and tor_proxy" do
        it "executes through the tor proxy block" do
          config = Configuration.new
          config.driver = :poltergeist
          config.tor = true
          config.tor_options = {tor_port: 9050}
          tor_proxy = double(:tor_proxy)
          params = {method: :get, url: "http://example.com"}
          expect_capybara_driver_setup_with_driver :poltergeisttor9050
          expect(tor_proxy).to receive(:proxy).and_yield
          expect(Capybara).to receive(:visit).with(params[:url])
          expect(Capybara).to receive(:page)
          driver_resetter = double(:driver_resetter, reset_if_nth_request: '')
          VisitCapybaraPoltergeist
              .new(config: config,
                   tor_proxy: tor_proxy,
                   driver_resetter: driver_resetter).execute params
          expect(driver_resetter).to have_received(:reset_if_nth_request)
        end
      end

      context "when instantiated without config.tor" do
        it "doesn't execute through the tor proxy block" do
          config = Configuration.new
          config.driver = :poltergeist
          tor_proxy = double(:tor_proxy)
          params = {method: :get, url: "http://example.com"}
          expect_capybara_driver_setup_with_driver :poltergeist
          expect(tor_proxy).to_not receive(:proxy).and_yield
          expect(Capybara).to receive(:visit).with(params[:url])
          expect(Capybara).to receive(:page)
          driver_resetter = double(:driver_resetter, reset_if_nth_request: '')
          VisitCapybaraPoltergeist.new(config: config,
                                       tor_proxy: tor_proxy,
                                       driver_resetter: driver_resetter).execute params
          expect(driver_resetter).to have_received(:reset_if_nth_request)
        end
      end

      context "when config.user_agent_retriever is specified" do
        it "retrieves a user agent and merges the user agent " +
               "with the request params" do
          config = Configuration.new
          config.driver = :poltergeist
          user_agent_retriever = double(:user_agent_retriever)
          params = {
              method: :get,
              url: "http://example.com",
              headers: {
                  user_agent: "agent1"
              }
          }
          expect_capybara_driver_setup_with_driver :poltergeist
          expect(user_agent_retriever)
              .to receive(:user_agent)
                      .and_return("agent1")
          expect(Capybara)
              .to receive_message_chain("page.driver.add_headers")
                      .with("User-Agent" => "agent1")
          expect(Capybara).to receive(:visit).with(params[:url])
          expect(Capybara).to receive(:page)
          VisitCapybaraPoltergeist
              .new(config: config,
                   user_agent_retriever: user_agent_retriever).execute params
        end
      end
    end

    def expect_capybara_driver_setup_with_driver driver
      app = double(:app)
      expect(Capybara).to receive(:register_driver)
                              .with(driver)
                              .and_yield(app)
      expect(Capybara::Poltergeist::Driver)
          .to receive(:new).with(app, {})
    end
  end
end