require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  before :all do
    EyeManager.destroy
  end

  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

  describe ".visit" do
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

      it_behaves_like 'a user agent customizer'
    end

    context "when using Capybara (using javascript)" do
      describe "with headless_chromium driver" do
        it_behaves_like 'a javascript-enabled web agent (using Capybara)',
                        use_capybara: true,
                        driver: :headless_chromium

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
                          'args' => ["no-sandbox", "disable-gpu", "headless",
                                     "window-size=1092,1080"]
                      }
                  )
              }
            end
          }.to raise_error /headless_chromium does not support Tor/
        end

        it_behaves_like 'a user agent customizer',
                        use_capybara: true,
                        driver: :headless_chromium,
                        headless_chromium: {
                            browser: :chrome,
                            chromeOptions: {
                                'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                                'args' => ["no-sandbox", "disable-gpu", "headless",
                                           "window-size=1092,1080", "user-agent=test"]
                            }
                        }
      end

      describe "with poltergeist driver" do
        it_behaves_like 'a javascript-enabled web agent (using Capybara)',
                        driver: :poltergeist

        it_behaves_like 'a Tor-able web agent',
                        use_capybara: true,
                        driver: :poltergeist

        it_behaves_like 'a user agent customizer',
                        use_capybara: true,
                        driver: :poltergeist
      end
    end
  end
end