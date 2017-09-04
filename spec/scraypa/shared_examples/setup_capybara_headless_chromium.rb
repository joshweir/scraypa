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
      if config.driver == :headless_chromium
        expect_headless_chromium_reset
        expect_headless_chromium_ua_retrieved config, params[:user_agent]
        expect_headless_chromium_setup_driver config,
                                              params[:expected_driver_name],
                                              params[:user_agent]
      end
      subject = VisitCapybaraHeadlessChromium.new(config)
      expect(subject).to be_an_instance_of VisitCapybaraHeadlessChromium
      expect(subject.kind_of?(VisitInterface)).to be_truthy
      if config.driver == :headless_chromium
        expect(Capybara.default_driver).to eq params[:expected_driver_name]
      else
        expect(Capybara.javascript_driver).to eq params[:expected_driver_name]
      end
    end
  end
end