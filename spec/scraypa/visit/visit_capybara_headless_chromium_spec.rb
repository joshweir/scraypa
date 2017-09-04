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
                      }
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
                        }
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
            chromeOptions: {
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
              chromeOptions: {
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
          expect_headless_chromium_ua_retrieved config
          expect_headless_chromium_setup_driver config, :headless_chromiumua0
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
  end
end