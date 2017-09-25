require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

  describe ".configure" do
    it "initializes a new Scraypa::Configuration instance updating" +
           " properties from the configure block" do
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

    it_behaves_like "a web agent, user agent, tor, throttle setter-upper-er"
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

    it_behaves_like "a web agent, user agent, tor, throttle setter-upper-er"
  end

  describe ".visit" do
    context "when the web agent is not yet setup" do
      it "sets up scraypa" do
        Scraypa.agent = nil
        expect(Scraypa).to receive(:setup_agent)
        expect(Scraypa.agent)
            .to receive(:execute)
                    .with(method: :get, url: "http://example.com")
        Scraypa.visit method: :get, url: "http://example.com"
      end
    end

    context "when the web agent is already setup" do
      it "doesn't setup scraypa again" do
        Scraypa.reset #reset sets up the agent
        expect(Scraypa).to_not receive(:setup_agent)
        expect(Scraypa.agent)
            .to receive(:execute)
                    .with(method: :get, url: "http://example.com")
        Scraypa.visit method: :get, url: "http://example.com"
      end
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

      context "with user agent specified" do
        it "utlises the user agent in the web request" do
          Scraypa.reset
          Scraypa.configure do |c|
            c.user_agent = {
                list: 'my user agent'
            }
          end
          expect(RestClient::Request)
              .to receive(:execute)
                      .with(method: :get,
                            url: "http://example.com",
                            headers: {user_agent: 'my user agent'})
          Scraypa.visit method: :get,
                        url: "http://example.com"
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
            c.headless_chromium = {
                browser: :chrome,
                chromeOptions: {
                    'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                    'args' => ["no-sandbox", "disable-gpu", "headless",
                               "window-size=1092,1080"]
                }
            }
            c.tor = nil
            c.user_agent = nil
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
            c.user_agent = nil
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

        context "with user agent specified" do
          it "utilises the user agent in the web request" do
            Scraypa.reset
            Scraypa.configure do |c|
              c.use_capybara = true
              c.driver = :poltergeist
              c.tor = nil
              c.user_agent = {
                  list: 'my user agent'
              }
            end
            expect(Capybara)
                .to receive(:visit)
                        .with("http://example.com")
            expect(Capybara)
                .to receive_message_chain("page.driver.add_headers")
                        .with("User-Agent" => "my user agent")
            expect(Capybara).to receive(:page)
            Scraypa.visit method: :get, url: "http://example.com"
          end
        end
      end
    end

    context "when :throttle_seconds is configured with a single value" do
      it "throttles between requests" do
        Scraypa.reset
        Scraypa.configure {|c| c.throttle_seconds = 0.5}
        expect(RestClient::Request)
            .to receive(:execute)
                    .with(method: :get,
                          url: "http://example.com").twice
        expect(Scraypa.throttle).to receive(:sleep).with(value_between(0.1, 0.5)).once
        Scraypa.visit method: :get, url: "http://example.com"
        Scraypa.visit method: :get, url: "http://example.com"
      end
    end

    context "when :throttle_seconds is configured with a hash range" do
      it "throttles between requests randomly between the range" do
        Scraypa.reset
        Scraypa.configure {|c| c.throttle_seconds = {from: 0.5, to: 2.5}}
        expect(RestClient::Request)
            .to receive(:execute)
                    .with(method: :get,
                          url: "http://example.com").twice
        expect(Scraypa.throttle).to receive(:sleep).with(value_between(0.5, 2.5)).once
        Scraypa.visit method: :get, url: "http://example.com"
        Scraypa.visit method: :get, url: "http://example.com"
      end
    end

    context "when :throttle_seconds configuration is changed" do
      it "changes the throttle accordingly" do
        Scraypa.reset
        Scraypa.configure {|c| c.throttle_seconds = 0.5}
        expect(Scraypa.throttle.seconds).to eq 0.5
        throttle_range = {from: 0.5, to: 2.5}
        Scraypa.configure {|c| c.throttle_seconds = throttle_range}
        expect(Scraypa.throttle.seconds).to eq throttle_range
      end
    end
  end
end