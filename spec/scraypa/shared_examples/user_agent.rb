RSpec.shared_examples "a user agent customizer" do |params|
  if params && params[:driver] == :poltergeist
    context "when customizing the user agent with :poltergeist", type: :feature,
            driver: :poltergeist_billy do
      before :all do
        proxy.stub('http://www.google.com/')
            .and_return(:text => "test response")
      end

      it 'uses the customized user agent' do
        Capybara.page.driver.add_headers("User-Agent" => "the user agent string you want")
        configure_scraypa params.merge({driver: :poltergeist_billy})
        response = Scraypa.visit url: "http://www.google.com/"
        expect(response.page).to have_content('test response')
        page.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
        expect(response.page).to have_content('the user agent string you want')
      end
    end
  elsif params && params[:driver] == :headless_chromium
    #unfortunately cannot proxy headless_chromium through puffing billy
    #as need to modify the user agent which is not available with
    #:selenium_chrome_billy
    context "when customizing the user agent with :headless_chromium" do
      it 'uses the customized user agent' do
        configure_scraypa params
        #Capybara.page.driver.header("User-Agent" => "the user agent string you want")
        response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
        expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        response.execute_script(
            "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
        expect(response).to have_content('the user agent string you want')
      end
    end
  else

  end

  context "verify that the agent can customize the user agent" do
    it "can customize the user agent" do

    end
  end

  context "when using the :common_aliases :user_agents option" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list in order that isn't linear" do
=begin
        configure_scraypa(
            params.merge({
                             user_agent: {
                                 user_agents: :common_aliases,
                                 strategy: :randomize,
                                 change_after_n_requests: 2
                             }
                         }))
        Scraypa.visit
=end
      end
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list in order that is linear"
    end
  end

  context "when using the :randomizer :user_agents option" do
    it "uses a user agent from the user agents randomizer list"
  end

  context "when passing a list of user defined :user_agents" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list in order that isn't linear"
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list in order that is linear"
    end
  end

=begin
  context "when customizing the user agent with :poltergeist", type: :feature,
          driver: :poltergeist_billy do
    before :all do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end

    it 'uses the customized user agent' do
      page.driver.add_headers("User-Agent" => "the user agent string you want")
      visit "http://www.google.com/"
      expect(page).to have_content('test response')
      page.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(page).to have_content('the user agent string you want')
    end
  end
=end

  def configure_scraypa params
    Scraypa.reset
    Scraypa.configure do |config|
      config.user_agent = params[:user_agent] if params[:user_agent]
      config.use_capybara = true if params[:use_capybara]
      config.driver = params[:driver] if params[:driver]
      if [:poltergeist, :poltergeist_billy].include? params[:driver]
        config.driver_options = {
            :phantomjs => Phantomjs.path,
            :js_errors => false,
            :phantomjs_options => ["--web-security=true"]
        }
      elsif [:headless_chromium, :selenium_chrome_billy].include? params[:driver]
        config.driver_options = {
            browser: :chrome,
            desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                "chromeOptions" => {
                    'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                    'args' => ["headless", "no-sandbox", "disable-gpu",
                               "window-size=1092,1080"]
                }
            )
        }
      else
        raise "invalid params[:driver]: #{params[:driver]}"
      end
    end
  end
end