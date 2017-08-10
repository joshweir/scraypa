RSpec.shared_examples "a Tor-able web agent" do |params|
  before :all do
    Scraypa.reset
    @my_ip = Scraypa
                 .visit(:method => :get,
                        url: "http://bot.whatismyipaddress.com")
                 .native_response.to_str

    Scraypa.configure do |config|
      config.use_capybara = true
      config.tor = true
      config.tor_options = {
          tor_port: 9055,
          control_port: 50500
      }
      config.driver = :poltergeist
      config.driver_options = {
          :phantomjs => Phantomjs.path,
          :js_errors => false,
          :phantomjs_options => ["--web-security=false", "--ignore-ssl-errors=yes",
                                 "--ssl-protocol=any", "--proxy-type=socks5",
                                 "--proxy=127.0.0.1:9055"]
      }
    end
    @response = Scraypa.visit(url: "http://bot.whatismyipaddress.com")
    @first_tor_ip = @response.native_response.text
  end

  it "has a different ip address to current public ip address" do
    expect(@my_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
    expect(@response.native_response).to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
    expect(@response.native_response).not_to have_text(@my_ip)
  end

  it "is able to change ip address" do
    #expect(Scraypa.configuration).to be_nil
    #expect(Scraypa.configuration.tor_controller).not_to be_nil
    Scraypa.change_tor_ip_address
    @response_after_ip_change =
        Scraypa.visit(url: "http://bot.whatismyipaddress.com")
    expect(@response_after_ip_change.native_response)
        .to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
    expect(@response_after_ip_change.native_response.status_code).to eq(200)
    expect(@response_after_ip_change.native_response)
        .not_to have_text(@my_ip)
    expect(@response_after_ip_change.native_response)
        .not_to have_text(@first_tor_ip)
  end

  it "is able to execute javascript" do
    @response.native_response.execute_script(
        "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
    expect(@response.native_response).to have_text('changed')
  end

  context "when tor port is changed" do
    before :all do
      Scraypa.configure do |config|
        config.use_capybara = true
        config.tor = true
        config.tor_options = {
            tor_port: 9056,
            control_port: 50501
        }
        config.driver = :poltergeist
        config.driver_options = {
            :phantomjs => Phantomjs.path,
            :js_errors => false,
            :phantomjs_options => ["--web-security=false", "--ignore-ssl-errors=yes",
                                   "--ssl-protocol=any", "--proxy-type=socks5",
                                   "--proxy=127.0.0.1:9056"]
        }
      end
      @response = Scraypa.visit(url: "http://bot.whatismyipaddress.com")
      @first_tor_ip = @response.native_response.text
    end

    it "has a different ip address to current public ip address" do
      expect(@my_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      expect(@response.native_response).to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response.native_response).not_to have_text(@my_ip)
    end

    it "is able to change ip address" do
      #expect(Scraypa.configuration).to be_nil
      #expect(Scraypa.configuration.tor_controller).not_to be_nil
      Scraypa.change_tor_ip_address
      @response_after_ip_change =
          Scraypa.visit(url: "http://bot.whatismyipaddress.com")
      expect(@response_after_ip_change.native_response)
          .to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response_after_ip_change.native_response.status_code).to eq(200)
      expect(@response_after_ip_change.native_response)
          .not_to have_text(@my_ip)
      expect(@response_after_ip_change.native_response)
          .not_to have_text(@first_tor_ip)
    end
  end
end