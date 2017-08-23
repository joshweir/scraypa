RSpec.shared_examples "a user agent customizer" do |params|
  context "verify that the agent can customize the user agent" do
    it "can customize the user agent"
  end

  context "when using the :common_aliases :user_agents option" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list" do
        configure_scraypa(
            params.merge({
                             user_agent: {
                                 user_agents: :common_aliases,
                                 strategy: :randomize
                             }
                         }))
      end
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list"
    end
  end

  context "when using the :randomizer :user_agents option" do
    it "uses a user agent from the :common_aliases list"
  end

  context "when passing a list of user defined :user_agents" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list"
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list"
    end
  end


  context "when customizing the user agent", type: :feature,
          driver: :poltergeist_billy do
    before :all do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end

    it 'stubs google.com' do
      page.driver.add_headers("User-Agent" => "the user agent string you want")
      visit "http://www.google.com/"
      expect(page).to have_content('test response')
      page.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(page).to have_content('the user agent string you want')
    end
  end

  context "puffing billy chrome exploratory test", type: :feature,
          driver: :selenium_chrome_billy do
    before :all do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end

    it 'stubs google.com' do
      page.driver.header("User-Agent" => "the user agent string you want")
      visit "http://www.google.com/"
      expect(page).to have_content('test response')
      page.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(page).to have_content('the user agent string you want')
    end
  end

  def configure_scraypa params
    Scraypa.reset
    Scraypa.configure do |config|
      config.user_agent = params[:user_agent] if params[:user_agent]
      config.use_capybara = true if params[:use_capybara]
      config.driver = params[:driver] if params[:driver]
      if params[:driver] == :poltergeist
        config.driver_options = {
            :phantomjs => Phantomjs.path,
            :js_errors => false,
            :phantomjs_options => ["--web-security=true"]
        }
      elsif params[:driver] == :headless_chromium
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