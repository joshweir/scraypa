require "spec_helper"

module Scraypa
  describe Configuration do
    describe "#use_javascript" do
      it "should have a default value of nil" do
        expect(Configuration.new.use_javascript).to be_nil
      end
    end

    describe "#use_javascript=" do
      it "can set value" do
        config = Configuration.new
        config.use_javascript = true
        expect(config.use_javascript).to be_truthy
      end
    end
  end
end
