require "spec_helper"

module Scraypa
  RSpec::Matchers.define :value_between do |x, y|
    match { |actual| actual.between?(x, y) }
  end

  describe Throttle do
    it "can be instantiated with no params" do
      expect(Throttle.new.class).to eq Scraypa::Throttle
    end

    describe "#throttle" do
      context "when initialized with no throttle" do
        it "does not sleep" do
          expect(subject).to_not receive(:sleep)
          subject.throttle
        end
      end

      context "when initialized with a single throttle value" do
        let(:subject) { Throttle.new seconds: 0.4 }

        it "sleeps the specified number of seconds" do
          expect(subject).to receive(:sleep).with(0.4)
          subject.throttle
        end
      end

      context "when initialized with a throttle range" do
        let(:subject) { Throttle.new seconds: {from: 0.5, to: 2} }

        it "sleeps a random amount of time between the specified range (in seconds)" do
          expect(subject).to receive(:sleep).with(value_between(0.5, 2))
          subject.throttle
        end
      end
    end
  end
end
