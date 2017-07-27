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
  end
end
