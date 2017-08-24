require "spec_helper"

module Scraypa
  describe Throttle do
    it "can be instantiated with no params" do
      expect(Throttle.new.class).to eq Scraypa::Throttle
    end

    it { is_expected.to have_attr_accessor(:last_request_time) }

    describe "#throttle" do
      context "when initialized with no throttle" do
        it "does not sleep" do
          expect(subject).to_not receive(:sleep)
          subject.throttle
        end
      end

      context "when initialized with a single throttle value" do
        context "when #last_request_time is empty" do
          let(:subject) { Throttle.new seconds: 0.4 }

          it "does not sleep" do
            expect(subject).to_not receive(:sleep)
            subject.throttle
          end
        end

        context "when #last_request_time in the past such that sleep time has elapsed" do
          let(:subject) { Throttle.new seconds: 0.4 }

          it "does not sleep" do
            subject.last_request_time = Time.now - 0.5
            expect(subject).to_not receive(:sleep)
            subject.throttle
          end
        end

        context "when #last_request_time in the past such that sleep time " +
                "has partly elapsed" do
          let(:subject) { Throttle.new seconds: 0.4 }

          it "does not sleep" do
            subject.last_request_time = Time.now - 0.1
            expect(subject).to receive(:sleep).with(value_between(0.01,0.39))
            subject.throttle
          end
        end
      end

      context "when initialized with a throttle range" do
        let(:subject) { Throttle.new seconds: {from: 0.5, to: 2} }

        it "sleeps a random amount of time between the specified range (in seconds)" do
          expect(subject).to receive(:sleep).with(value_between(0.5, 2))
          subject.last_request_time = Time.now
          subject.throttle
        end
      end
    end
  end
end
