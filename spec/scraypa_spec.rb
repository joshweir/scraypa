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
    context "when using default config: Rest-Client (not using javascript)" do
      it "utilises rest client to download web content"
    end

    context "when using Capybara (using javascript)" do
      context "with headless_chromium driver" do
        it "utilises capybara to download web content"
      end

      context "with poltergeist driver" do
        it "utilises capybara to download web content"
      end
    end
  end

=begin
  describe "puffing billy poltergeist exploratory test", type: :feature,
           driver: :poltergeist_billy do
    before :all do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end
    it 'stubs google.com' do
      visit "http://www.google.com/"
      expect(page).to have_content('test response')
    end
  end
=end

=begin
  describe "#visit" do
    context "when using Rest-Client (not using javascript)" do
      before :all do
        Scraypa.reset
        stub_request(:get, "http://my.mock.site/page.html").
            with(headers: {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip, deflate',
                           'Host'=>'my.mock.site',
                           'User-Agent'=>'rest-client/2.0.2 (linux-gnu x86_64) ruby/2.3.1p112'}).
            to_return(status: 200, body: "test response", headers: {})
        @response = Scraypa.visit(:method => :get,
                                  :url => "http://my.mock.site/page.html",
                                  :timeout => 3, :open_timeout => 3)
      end
      it "utilises rest client to download web content" do
        expect(@response.class).to eq(RestClient::Response)
        expect(@response.to_str).to eq('test response')
      end
      it_behaves_like 'a Tor-able web agent'
    end
    context "when using Capybara (using javascript)" do
      describe "with headless_chromium driver" do
        it_behaves_like 'a javascript-enabled web agent (using Capybara)',
                        driver: :headless_chromium
        #it_behaves_like 'a Tor-able web agent',
        #                use_capybara: true,
        #                driver: :headless_chromium
        it "does not support Tor" do
          expect {
            Scraypa.configure do |config|
              config.tor = true
              config.tor_options = {
                  tor_port: 9055,
                  control_port: 50500
              }
              config.use_capybara = true
              config.driver = :headless_chromium
              config.driver_options = {
                  browser: :chrome,
                  desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                      "chromeOptions" => {
                          'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                          'args' => ["no-sandbox", "disable-gpu", "headless"]
                      }
                  )
              }
            end
          }.to raise_error /headless_chromium does not support Tor/
        end
      end
      describe "with poltergeist driver" do
        it_behaves_like 'a javascript-enabled web agent (using Capybara)',
                        driver: :poltergeist
        it_behaves_like 'a Tor-able web agent',
                        use_capybara: true,
                        driver: :poltergeist
      end
    end
  end
=end
end