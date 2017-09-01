require "spec_helper"

module Scraypa
  describe UserAgentAbstract do
    describe "#user_agent" do
      it "raises NotImplementedError" do
        expect{UserAgentAbstract.new.user_agent}
            .to raise_error NotImplementedError
      end
    end

    describe "#list" do
      it "raises NotImplementedError" do
        expect{UserAgentAbstract.new.list}
            .to raise_error NotImplementedError
      end
    end
  end
end