require "spec_helper"

module Scraypa
  describe Configuration do
    describe "#use_capybara" do
      it "should have a default value of nil" do
        expect(Configuration.new.use_capybara).to be_nil
      end
    end

    describe "#use_capybara=" do
      it "can set value" do
        config = Configuration.new
        config.use_capybara = true
        expect(config.use_capybara).to be_truthy
      end
    end

    describe "#driver" do
      it "should have a default value of nil" do
        expect(Configuration.new.driver).to be_nil
      end
    end

    describe "#driver=" do
      it "can set value" do
        config = Configuration.new
        config.driver = :poltergeist
        expect(config.driver).to eq(:poltergeist)
      end
    end

    describe "#driver_options" do
      it "should have a default value of nil" do
        expect(Configuration.new.driver_options).to be_nil
      end
    end

    describe "#driver_options=" do
      it "can set value" do
        config = Configuration.new
        the_options = {
            :js_errors => false
        }
        config.driver_options = the_options
        expect(config.driver_options).to eq(the_options)
      end
    end

    describe "#tor" do
      it "should have a default value of nil" do
        expect(Configuration.new.tor).to be_nil
      end
    end

    describe "#tor=" do
      it "can set value" do
        config = Configuration.new
        config.tor = true
        expect(config.tor).to be_truthy
      end
    end

    describe "#tor_options" do
      it "should have a default value" do
        expect(Configuration.new.tor_options).to be_nil
      end
    end

    describe "#tor_options=" do
      it "can set value" do
        config = Configuration.new
        the_options = {
            tor_port: 9150,
            control_port: 51500
        }
        config.tor_options = the_options
        expect(config.tor_options).to eq(the_options)
      end
    end

    describe "#eye_tor_config_template" do
      it "should have a default value of nil" do
        expect(Configuration.new.eye_tor_config_template).to be_nil
      end
    end

    describe "#eye_tor_config_template=" do
      it "can set value" do
        config = Configuration.new
        config.eye_tor_config_template = '/my/path/to.eye.config.rb'
        expect(config.eye_tor_config_template).to eq '/my/path/to.eye.config.rb'
      end
    end

    describe "#throttle_seconds" do
      it "should have a default value of nil" do
        expect(Configuration.new.throttle_seconds).to be_nil
      end
    end

    describe "#throttle_seconds=" do
      it "can set value" do
        config = Configuration.new
        config.throttle_seconds = 1.5
        expect(config.throttle_seconds).to eq 1.5
      end
    end

    describe "#user_agent" do
      it "should have a default value of nil" do
        expect(Configuration.new.user_agent).to be_nil
      end
    end

    describe "#user_agent=" do
      it "can set value" do
        config = Configuration.new
        config.user_agent = 'test'
        expect(config.user_agent).to eq 'test'
      end
    end
  end
end
