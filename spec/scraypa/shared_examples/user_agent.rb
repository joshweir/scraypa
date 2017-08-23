RSpec.shared_examples "a user agent customizer" do |params|
  before :all do
    Scraypa.reset
    Scraypa.configure do |config|
      config.use_capybara = true
      config.driver = params[:driver]
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
    @response = Scraypa.visit(:url => "http://bot.whatismyipaddress.com")
  end

  it "utilises capybara to download web content" do
    expect(@response.class).to eq(Capybara::Session)
    expect(@response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
    expect(@response.status_code).to eq(200) if
        @response.methods.include?('status_code')
  end

  it "is able to execute javascript" do
    @response.execute_script(
        "document.getElementsByTagName('body')[0].innerHTML = 'changed';")
    expect(@response).to have_content('changed')
  end

  it "is able to act like a Capybara session" do
    response = Scraypa.visit(:url => "http://unixpapa.com/js/testmouse.html")
    expect(response.find("textarea").value).to eq ""
    response.click_link "click here to test"
    expect(response.find("textarea").value).to_not eq ""
    response.click_link "click here to clear"
    expect(response.find("textarea").value).to eq ""
    response.click_link("IE attachEvent")
    expect(response.current_path).to eq "/js/testmouse-ie.html"
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
end