RSpec.shared_examples "a Tor-able web agent" do |params|
  before :all do
    Scraypa.reset
    @my_ip = Scraypa
                 .visit(:method => :get,
                        url: "http://bot.whatismyipaddress.com")
                 .to_str

    Scraypa.configure do |config|
      config.tor = true
      #config.tor_options = {
      #    tor_port: 9055,
      #    control_port: 50500
      #}
      if params && params[:use_capybara]
        config.use_capybara = true
        if params[:driver] == :poltergeist
          config.driver = :poltergeist
          config.driver_options = {
              :phantomjs => Phantomjs.path,
              :js_errors => false,
              :phantomjs_options => ["--web-security=false", "--ignore-ssl-errors=yes",
                                     "--ssl-protocol=any", "--proxy-type=socks5",
                                     "--proxy=127.0.0.1:9050"]
          }
        elsif params[:driver] == :headless_chromium
          config.driver = :headless_chromium
          config.driver_options = {
              browser: :chrome,
              desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                  "chromeOptions" => {
                      'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                      'args' => ["no-sandbox", "disable-gpu", "headless",
                                 "proxy-server=socks5://127.0.0.1:9050"]
                  }#,
                  #:proxy => Selenium::WebDriver::Proxy.new(http: "127.0.0.1:9050")
              )
          }
        else
          raise "invalid params[:driver]: #{params[:driver]}"
        end
      else

      end
    end
    @response = Scraypa.visit(method: :get, url: "http://bot.whatismyipaddress.com")
    @first_tor_ip = params && params[:use_capybara] ? @response.text : @response.to_str
  end

  it "has a different ip address to current public ip address" do
    expect(@my_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
    if params && params[:use_capybara]
      expect(@response).to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response).not_to have_text(@my_ip)
    else
      expect(@response.to_str).to match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response.to_str).not_to eq(@my_ip)
    end
  end

  it "is able to change ip address" do
    Scraypa.change_tor_ip_address
    @response_after_ip_change =
        Scraypa.visit(method: :get, url: "http://bot.whatismyipaddress.com")
    if params && params[:use_capybara]
      expect(@response_after_ip_change)
          .to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response_after_ip_change)
          .not_to have_text(@my_ip)
      expect(@response_after_ip_change)
          .not_to have_text(@first_tor_ip)
    else
      expect(@response_after_ip_change.to_str)
          .to match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      expect(@response_after_ip_change.to_str)
          .not_to eq(@my_ip)
      expect(@response_after_ip_change.to_str)
          .not_to eq(@first_tor_ip)
    end
  end

  context "when tor port is changed" do
    before :all do
      Scraypa.configure do |config|
        config.tor = true
        config.tor_options = {
            tor_port: 9056,
            control_port: 50501
        }
        if params && params[:use_capybara]
          config.use_capybara = true
          if params[:driver] == :poltergeist
            config.driver = :poltergeist
            config.driver_options = {
                :phantomjs => Phantomjs.path,
                :js_errors => false,
                :phantomjs_options => ["--web-security=false", "--ignore-ssl-errors=yes",
                                       "--ssl-protocol=any", "--proxy-type=socks5",
                                       "--proxy=127.0.0.1:9056"]
            }
          else
            raise "invalid params[:driver]: #{params[:driver]}"
          end
        else

        end
      end
      @response = Scraypa.visit(method: :get, url: "http://bot.whatismyipaddress.com")
      @first_tor_ip = params && params[:use_capybara] ? @response.text : @response.to_str
    end

    it "has a different ip address to current public ip address" do
      expect(@my_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      if params && params[:use_capybara]
        expect(@response).to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response).not_to have_text(@my_ip)
      else
        expect(@response.to_str).to match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response.to_str).not_to eq(@my_ip)
      end
    end

    it "is able to change ip address" do
      Scraypa.change_tor_ip_address
      @response_after_ip_change =
          Scraypa.visit(method: :get, url: "http://bot.whatismyipaddress.com")
      if params && params[:use_capybara]
        expect(@response_after_ip_change)
            .to have_content(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response_after_ip_change)
            .not_to have_text(@my_ip)
        expect(@response_after_ip_change)
            .not_to have_text(@first_tor_ip)
      else
        expect(@response_after_ip_change.to_str)
            .to match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
        expect(@response_after_ip_change.to_str)
            .not_to eq(@my_ip)
        expect(@response_after_ip_change.to_str)
            .not_to eq(@first_tor_ip)
      end
    end
  end
end