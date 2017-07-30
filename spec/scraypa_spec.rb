require "spec_helper"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

  describe "verify puffing billy poltergeist is working", type: :feature,
           driver: :poltergeist_billy do
    before do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end

    it 'test scenario' do
      visit "http://www.google.com/"
      expect(page).to have_content('test response')
    end
  end

  describe "#visit" do
    describe "using Rest-Client (not using javascript)" do
      before do
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

      it "should utilise rest client to download web content" do
        expect(@response.class).to eq(Scraypa::Response)
        expect(@response.native_response.class).to eq(RestClient::Response)
        expect(@response.native_response.html).to eq('test response')
      end
    end

    describe "using Capybara with poltergeist driver (using javascript)" do
      before do
        Scraypa.configure do |config|
          config.use_capybara = true
          config.driver = :poltergeist
          config.driver_options = {
              :phantomjs => Phantomjs.path,
              :js_errors => false,
              :phantomjs_options => ["--web-security=true"]
          }
        end
        @response = Scraypa.visit(:url => "http://canihazip.com/s")
      end

      it "should utilise capybara to download web content" do
        expect(@response.class).to eq(Scraypa::Response)
        expect(@response.native_response.class).to eq(Capybara::Session)
        expect(@response.native_response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        expect(@response.native_response.status_code).to eq(200)
      end

      it "should be able to execute javascript" do
        @response.native_response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
        expect(@response.native_response).to have_content('changed')
      end
    end

    describe "using Capybara with headless_chromium driver (using javascript)" do
      before do
        Scraypa.configure do |config|
          config.use_capybara = true
          config.driver = :headless_chromium
          config.driver_options = {
              browser: :chrome,
              desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                  "chromeOptions" => {
                      'binary' => "/home/resrev/chromium/src/out/Default/chrome",
                      'args' => %w{headless no-sandbox disable-gpu}
                  }
              )
          }
        end
        @response = Scraypa.visit(:url => "http://canihazip.com/s")
      end

      it "should utilise capybara to download web content" do
        #Capybara.current_driver = :poltergeist_billy
        #Capybara.javascript_driver = :poltergeist_billy
        #proxy.stub('http://www.google.com/')
        #    .and_return(:text => "test response")
        #visit "http://www.google.com/"
        #expect(page.text).to eq('test response')

        expect(@response.class).to eq(Scraypa::Response)
        expect(@response.native_response.class).to eq(Capybara::Session)
        expect(@response.native_response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end

      it "should be able to execute javascript" do
        @response.native_response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
        expect(@response.native_response).to have_content('changed')
      end
    end

    describe "Tor Process Management" do
      it "should, on configuration change, check if any Tor god processes " +
             "are running associated to Scraypa instances that no longer exist " +
             "then issue god stop orders and kill the god process as it is stale" do

      end

      it "should, on configuration change if use_tor is flagged, " +
             "check if a valid Tor god process is not running for the current " +
             "Tor instance settings, then spawn it" do

      end

      it "should, on configuration change if use_tor is not flagged, " +
             "check if any Tor god process is running spawned by the current " +
             "process, then issue god stop orders and kill it" do

      end

      it "should be able to stop the tor process and god process " +
             "that spawned tor (otherwise it will keep running)" do

      end
    end

    describe "using Capybara with poltergeist driver through Tor" do
      before do
        @my_ip = Scraypa.reset
                     .visit("http://bot.whatismyipaddress.com")
                     .native_reponse.html
        @another_ip_check =
            Scraypa.reset
             .visit("http://canihazip.com")
             .native_reponse.html

        Scraypa.configure do |config|
          config.use_capybara = true
          config.use_tor = true
          config.tor_options = {
              port: 9055,
              control_port: 50500
          }
          config.driver = :poltergeist
          config.driver_options = {
              :phantomjs => Phantomjs.path,
              :js_errors => false,
              :phantomjs_options => ["--web-security=true"]
          }
        end
        @response = Scraypa.visit("http://canihazip.com/s")
      end

      it "verify public ip address has been retrieved before" do
        expect(@my_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end

      it "verify successful match with current ip address using canihazip.com" do
        expect(@another_ip_check).to eq(@my_ip)
      end

      it "should have a different ip address to current public ip address" do
        expect(@response.native_response.class).to eq(Capybara::Session)
        expect(@response.native_response).to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response.native_response.status_code).to eq(200)
        expect(@response.native_response).not_to have_text(@my_ip)
      end

      it "should be able to change ip address" do
        Scraypa.change_tor_ip_address
        @response_after_ip_change =
            Scraypa.visit("http://canihazip.com/s")
        expect(@response_after_ip_change.native_response)
            .to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response_after_ip_change.native_response.status_code).to eq(200)
        expect(@response_after_ip_change.native_response)
            .not_to have_text(@my_ip)
        expect(@response_after_ip_change.native_response)
            .not_to have_text(@response.native_response.text)
      end

      it "should be able to execute javascript" do
        @response.native_response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
        expect(@response.native_response).to have_text('changed')
      end
    end
  end
end
