module Scraypa
  RSpec.shared_examples "a capybara headless_chromium driver setter-upper-er" do |params|
    let(:config) {
      config = Configuration.new
      config.driver = params[:driver]
      config.headless_chromium = params[:headless_chromium]
      config.user_agent = {
          list: params[:user_agent]
      } if params[:user_agent]
      config
    }

    it "sets up the capybara driver on initialization" do
      expect_headless_chromium_reset
      expect_headless_chromium_ua_retrieved config, params[:user_agent]
      expect_headless_chromium_setup_driver config,
                                            params[:expected_driver_name],
                                            params[:user_agent]

      subject = VisitCapybaraHeadlessChromium.new(config)
      expect(subject).to be_an_instance_of VisitCapybaraHeadlessChromium
      expect(subject.kind_of?(VisitInterface)).to be_truthy
      if config.driver == :headless_chromium
        expect(Capybara.default_driver).to eq params[:expected_driver_name]
      else
        expect(Capybara.javascript_driver).to eq params[:expected_driver_name]
      end
    end

    def expect_headless_chromium_reset
      expect(Capybara).to receive(:reset_sessions!)
      expect(Capybara).to receive_message_chain("send.each").and_yield
      expect(Capybara).to receive_message_chain("send.delete_if").and_yield
      expect(Capybara).to receive_message_chain("drivers.delete_if").and_yield
    end

    def expect_headless_chromium_ua_retrieved config, user_agent_retrieved
      if config.user_agent
        config.user_agent_retriever = double("user_agent_retriever")
        expect(config.user_agent_retriever)
            .to receive(:user_agent)
                    .and_return(user_agent_retrieved)
      end
    end

    def expect_headless_chromium_setup_driver config, expected_driver_name, user_agent_retrieved
      if config.driver == :headless_chromium
        app = double("app")
        expect(Capybara).to receive(:register_driver)
                                .with(expected_driver_name)
                                .and_yield(app)
        expect(Capybara::Selenium::Driver)
            .to receive(:new).with(app, {
                browser: config.headless_chromium[:browser],
                desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                    :chromeOptions => {
                        'args' => config.headless_chromium[:chromeOptions]['args'] +
                            (user_agent_retrieved ?
                                ["--user-agent=#{user_agent_retrieved}"] : [])
                    }
                )
        args: config.headless_chromium[:args]
        })
      else
        expect(Capybara).to_not receive(:register_driver)
        expect(Capybara::Selenium::Driver).to_not receive(:new)
      end
    end
  end
end