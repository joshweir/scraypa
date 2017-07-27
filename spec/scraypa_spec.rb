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
        proxy.stub('http://www.google.com.au/')
            .and_return(:text => "test response")
        Scraypa.configure do |config|
          config.use_capybara = true
          config.driver = :poltergeist_billy
          config.driver_options = {
              :phantomjs => Phantomjs.path,
              :js_errors => false,
              :phantomjs_options => ["--web-security=true"]
          }
        end
        #@response = Scraypa.visit(:url => "http://www.google.com.au/")
        @response = nil
      end

      it "should utilise capybara to download web content" do
        Capybara.current_driver = :poltergeist_billy
        Capybara.javascript_driver = :poltergeist_billy
        visit "http://www.google.com.au/"
        expect(page.text).to eq('test response')

        expect(@response.class).to eq(Scraypa::Response)
        expect(@response.native_response.class).to eq(Capybara::Session)
        expect(@response.native_response.text).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end
    end
  end
end
