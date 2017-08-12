require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  before :all do
    EyeManager.destroy
  end

  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

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
end