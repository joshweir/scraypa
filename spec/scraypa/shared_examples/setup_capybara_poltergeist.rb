module Scraypa
  RSpec.shared_examples "a capybara poltergeist driver setter-upper-er" do |params|
    let(:config) {
      config = Configuration.new
      config.driver = params[:driver]
      config.driver_options = params[:driver_options] || {}
      config.tor = params[:tor] if params[:tor]
      config.tor_options = params[:tor_options] if params[:tor_options]
      config
    }

    it "sets up the capybara driver on initialization" do
      app = double("app")
      if config.driver == :poltergeist
        expect(Capybara).to receive(:register_driver)
                              .with(params[:expected_driver_name])
                              .and_yield(app)
        expect(Capybara::Poltergeist::Driver)
            .to receive(:new).with(app, config.driver_options)
      else
        expect(Capybara).to_not receive(:register_driver)
        expect(Capybara::Poltergeist::Driver).to_not receive(:new)
      end

      subject = VisitCapybaraPoltergeist.new(config)
      expect(subject).to be_an_instance_of VisitCapybaraPoltergeist
      expect(subject.kind_of?(VisitInterface)).to be_truthy
      if config.driver == :poltergeist
        expect(Capybara.default_driver).to eq params[:expected_driver_name]
      else
        expect(Capybara.javascript_driver).to eq params[:expected_driver_name]
      end
    end
  end
end