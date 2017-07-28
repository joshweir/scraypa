require "spec_helper"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
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
        #Capybara.current_driver = :poltergeist_billy
        #Capybara.javascript_driver = :poltergeist_billy
        #proxy.stub('http://www.google.com/')
        #    .and_return(:text => "test response")
        #visit "http://www.google.com/"
        #expect(page.text).to eq('test response')

        expect(@response.class).to eq(Scraypa::Response)
        expect(@response.native_response.class).to eq(Capybara::Session)
        expect(@response.native_response.text).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        expect(@response.native_response.status_code).to eq(200)
      end

      it "should be able to execute javascript" do
        @response.native_response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
        expect(@response.native_response.text).to eq('changed')
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
        expect(@response.native_response.text).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end

      it "should be able to execute javascript" do
        @response.native_response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
        expect(@response.native_response.text).to eq('changed')
      end
    end
  end
end
