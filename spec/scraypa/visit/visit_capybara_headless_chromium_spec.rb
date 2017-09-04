require "spec_helper"

module Scraypa
  describe VisitCapybaraHeadlessChromium do
    let(:nodriver) { VisitCapybaraHeadlessChromium.new(Configuration.new) }

    it "raises exception when valid headless_chromium driver is not specified" do
      expect{nodriver}.to raise_error Scraypa::CapybaraDriverUnsupported
    end

    context "with config.driver = :headless_chromium" do
      it_behaves_like "a capybara headless_chromium driver setter-upper-er",
                      driver: :headless_chromium,
                      headless_chromium: {
                          browser: :chrome,
                          chromeOptions: {
                              'args' => ["no-sandbox", "disable-gpu", "headless",
                                         "window-size=1092,1080"]
                          },
                          args: ['arg1']
                      },
                      expected_driver_name: :headless_chromium

      context "with config.user_agent specified" do
        it_behaves_like "a capybara headless_chromium driver setter-upper-er",
                        driver: :headless_chromium,
                        headless_chromium: {
                            browser: :chrome,
                            chromeOptions: {
                                'args' => ["no-sandbox", "disable-gpu", "headless",
                                           "window-size=1092,1080"]
                            },
                            args: ['arg1']
                        },
                        user_agent: "custom user agent",
                        expected_driver_name: :headless_chromiumua0
      end
    end

    context "with config.driver = :selenium_chrome_billy" do
      it_behaves_like "a capybara headless_chromium driver setter-upper-er",
                      driver: :selenium_chrome_billy,
                      expected_driver_name: :selenium_chrome_billy
    end

    describe "#execute" do
      it "it executes a Capybara visit and retrieves the Capybara.page" do
        config = Configuration.new
        config.driver = :headless_chromium
        config.headless_chromium = {
            browser: :chrome,
            :chromeOptions => {
                'args' => ["no-sandbox", "disable-gpu", "headless",
                           "window-size=1092,1080"]
            },
            args: ['arg1']
        }
        params = {method: :get, url: "http://example.com"}
        expect_headless_chromium_reset
        expect_headless_chromium_ua_retrieved config
        expect_headless_chromium_setup_driver config, :headless_chromium
        expect(Capybara).to receive(:visit).with(params[:url])
        expect(Capybara).to receive(:page)
        VisitCapybaraHeadlessChromium.new(config).execute params
      end

      context "when config.user_agent_retriever is specified" do
        it "will register a new driver if user agent has changed since last visit" do
          config = Configuration.new
          config.driver = :headless_chromium
          config.headless_chromium = {
              browser: :chrome,
              :chromeOptions => {
                  'args' => ["no-sandbox", "disable-gpu", "headless",
                             "window-size=1092,1080"]
              },
              args: ['arg1']
          }
          config.user_agent = {
              list: ['agent a', 'agent b']
          }
          params = {
              method: :get, url: "http://example.com",
          }
          expect_headless_chromium_reset
          expect_headless_chromium_ua_retrieved config, 'agent a'
          expect_headless_chromium_setup_driver config, :headless_chromiumua0, 'agent a'
          expect(Capybara).to receive(:visit).with(params[:url]).twice
          expect(Capybara).to receive(:page).twice
          hc = VisitCapybaraHeadlessChromium.new(config)
          hc.execute params
          expect_headless_chromium_ua_retrieved config, 'agent b'
          expect_headless_chromium_setup_driver config, :headless_chromiumua1, 'agent b'
          hc.execute params
        end
      end
    end

    def expect_headless_chromium_reset
      expect(Capybara).to receive(:reset_sessions!)
      session_name = double("session_name")
      session = double("session")
      k = double("k")
      v = double("v")
      #had to allow instead of expect here because this occurs twice and receive_message_chain
      #cannot be chained with exactly(2).times
      allow(Capybara).to receive_message_chain("session_pool.each").and_yield(session_name, session)
      allow(session_name).to receive(:include?).with('headless_chromium').and_return(false)
      expect(Capybara).to receive_message_chain("session_pool.delete_if").and_yield
      allow(Capybara).to receive_message_chain("drivers.delete_if").and_yield(k,v)
    end

    def expect_headless_chromium_ua_retrieved config, user_agent_retrieved=nil
      if config.user_agent
        config.user_agent_retriever = double("user_agent_retriever")
        expect(config.user_agent_retriever)
            .to receive(:user_agent)
                    .and_return(user_agent_retrieved)
      end
    end

    def expect_headless_chromium_setup_driver config, expected_driver_name, user_agent_retrieved=nil
      if config.driver == :headless_chromium
        app = double("app")
        allow(Capybara).to receive_message_chain("drivers.keys.include?")
        expect(Capybara).to receive(:register_driver)
                                .with(expected_driver_name)
                                .and_yield(app).at_least(:once)
        config.headless_chromium[:chromeOptions]['args']
            .delete_if {|d| d.include?("user-agent=")}
        expect(Capybara::Selenium::Driver)
            .to receive(:new).with(app, {
                browser: config.headless_chromium[:browser],
                desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                    :chromeOptions => {
                        'args' => config.headless_chromium[:chromeOptions]['args'] +
                            (user_agent_retrieved ?
                                ["--user-agent=#{user_agent_retrieved}"] : [])
                    }
                ),
                args: config.headless_chromium[:args]
            }).at_least(:once)
      else
        expect(Capybara).to_not receive(:register_driver)
        expect(Capybara::Selenium::Driver).to_not receive(:new)
      end
    end
  end
end