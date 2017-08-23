require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

  describe ".configure" do
    it "initializes a new Scraypa::Configuration instance updating" +
           " properties from the configure block" do
      #allow(TorManager::TorProcess)
      #    .to receive(:tor_running_on?)
      #            .with(port: 9050,
      #                  parent_pid: Process.pid)
      #            .and_return(false)
      scraypa_reset_mock_shell
      Scraypa.reset
      expect(Scraypa).to receive(:setup_agent)
      Scraypa.configure { |c|
        c.use_capybara = true
        c.driver = :poltergeist
      }
      config = Scraypa.configuration
      expect(config.use_capybara).to be_truthy
      expect(config.driver).to eq :poltergeist
      expect(config.tor).to be_nil
    end

    it "updates properties on an existing Scraypa::Configuration instance" do
      scraypa_reset_mock_shell
      Scraypa.reset
      expect(Scraypa).to receive(:setup_agent)
      Scraypa.configure { |c|
        c.use_capybara = true
        c.driver = :poltergeist
      }
      config = Scraypa.configuration
      expect(config.use_capybara).to be_truthy
      expect(Scraypa).to receive(:setup_agent)
      Scraypa.configure { |c|
        c.use_capybara = nil
        c.driver = nil
      }
      config = Scraypa.configuration
      expect(config.use_capybara).to be_nil
    end

    it "validates that :headless_chromium will not work with Tor" do
      scraypa_reset_mock_shell
      Scraypa.reset
      expect{Scraypa.configure {|c|
        c.tor = true
        c.use_capybara = true
        c.driver = :headless_chromium
      }}.to raise_error Scraypa::TorNotSupportedByAgent,
                        /Capybara :headless_chromium does not support Tor/
    end

    it_behaves_like "a web agent setter-upper-er"
  end

  describe ".configuration" do
    before do
      scraypa_reset_mock_shell
      Scraypa.reset
    end

    it "returns a new Scraypa::Configuration instance when initially called" do
      config = Scraypa.configuration
      expect(config.class).to eq Scraypa::Configuration
      expect(config.use_capybara).to be_nil
    end

    it "returns the configuration instance that has already been configured" do
      expect(Scraypa).to receive(:setup_agent)
      Scraypa.configure do |config|
        config.use_capybara = true
        config.driver = :poltergeist
      end
      expect(Scraypa.configuration.use_capybara).to be_truthy
    end
  end

  describe ".reset" do
    it "resets the configuration instance" do
      scraypa_reset_mock_shell
      Scraypa.reset
      expect(Scraypa.configuration.use_capybara).to be_nil
    end

    it_behaves_like "a web agent setter-upper-er"
  end

  describe ".visit" do
    it "sets up the web agent if it is not yet" do
      Scraypa.agent = nil
      expect(Scraypa).to receive(:setup_agent)
      expect(Scraypa.agent)
          .to receive(:execute)
                  .with(method: :get, url: "http://example.com")
      Scraypa.visit method: :get, url: "http://example.com"
    end

    it "doesn't setup the web agent if it is already" do
      Scraypa.reset #reset sets up the agent
      expect(Scraypa).to_not receive(:setup_agent)
      expect(Scraypa.agent)
          .to receive(:execute)
                  .with(method: :get, url: "http://example.com")
      Scraypa.visit method: :get, url: "http://example.com"
    end

    context "when using default config: Rest-Client (not using javascript)" do
      it "utilises rest client to download web content" do
        Scraypa.reset
        expect(RestClient::Request)
            .to receive(:execute)
                    .with(method: :get,
                          url: "http://example.com")
        Scraypa.visit method: :get, url: "http://example.com"
      end

      context "with Tor" do
        it "utilises rest client via tor proxy to download web content" do
          tor_process, tor_proxy, tor_ip_control = mock_tor_setup
          Scraypa.configure do |c|
            c.use_capybara = nil
            c.tor = true
          end
          expect(tor_proxy).to receive(:proxy).and_yield
          expect(RestClient::Request)
              .to receive(:execute)
                      .with(method: :get,
                            url: "http://example.com")
          Scraypa.visit method: :get, url: "http://example.com"
        end
      end
    end

    context "when using Capybara (using javascript)" do
      context "with headless_chromium driver" do
        it "utilises capybara to download web content" do
          allow(Scraypa).to receive(:destruct_tor)
          Scraypa.configure do |c|
            c.use_capybara = true
            c.driver = :headless_chromium
            c.tor = nil
          end
          expect(Capybara)
              .to receive(:visit).with("http://example.com")
          Scraypa.visit method: :get, url: "http://example.com"
        end
      end

      context "with poltergeist driver" do
        it "utilises capybara to download web content" do
          allow(Scraypa).to receive(:destruct_tor)
          Scraypa.configure do |c|
            c.use_capybara = true
            c.driver = :poltergeist
            c.tor = nil
          end
          expect(Capybara)
              .to receive(:visit).with("http://example.com")
          Scraypa.visit method: :get, url: "http://example.com"
        end

        context "with Tor" do
          it "utilises capybara via tor proxy to download web content" do
            allow(Scraypa).to receive(:destruct_tor)
            tor_process, tor_proxy, tor_ip_control = mock_tor_setup
            Scraypa.configure do |c|
              c.use_capybara = true
              c.driver = :poltergeist
              c.tor = true
            end
            expect(tor_proxy).to receive(:proxy).and_yield
            expect(Capybara)
                .to receive(:visit).with("http://example.com")
            Scraypa.visit method: :get, url: "http://example.com"
          end
        end
      end
    end
  end
end