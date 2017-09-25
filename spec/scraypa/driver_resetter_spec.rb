require "spec_helper"

module Scraypa
  describe DriverResetter do
    it "raises exception if instantiated with no params" do
      expect{DriverResetter.new}.to raise_error ArgumentError
    end

    context "with param specified" do
      let(:subject) { DriverResetter.new(5) }

      it "can be instantiated with every_n_requests param" do
        expect(subject.class).to eq Scraypa::DriverResetter
      end

      it { is_expected.to have_attr_accessor(:requests_since_last_reset) }
    end

    describe "#reset_if_nth_request" do
      context "when current_driver is :poltergeist" do
        let(:subject) { DriverResetter.new(3) }

        it "it resets the driver after the nth request" do
          allow(Capybara).to receive(:current_driver).and_return(:poltergeist)
          expect(subject).to receive(:reset_poltergeist_driver).exactly(3).times
          counter = 0
          expect(subject.requests_since_last_reset).to eq counter
          9.times do
            subject.reset_if_nth_request
            counter >= 2 ? counter = 0 : counter += 1
            expect(subject.requests_since_last_reset).to eq counter
          end
        end

        it "calls capybara reset_sessions! and restarts the session driver" do
          allow(Capybara).to receive(:current_driver).and_return(:poltergeist)
          expect(Capybara).to receive(:reset_sessions!)
          session_name = double(:session_name)
          session = double(:session)
          expect(Capybara).to receive_message_chain("session_pool.each")
                                  .and_yield(session_name, session)
          expect(session_name).to receive(:include?).with('poltergeist').and_return(true)
          expect(session).to receive_message_chain("driver.restart")
          3.times do
            subject.reset_if_nth_request
          end
        end
      end

      context "when current_driver is :headless_chromium" do
        let(:subject) { DriverResetter.new(3) }

        it "it resets the driver after the nth request" do
          allow(Capybara).to receive(:current_driver).and_return(:headless_chromium)
          expect(subject).to receive(:reset_headless_chromium_driver).exactly(3).times
          counter = 0
          expect(subject.requests_since_last_reset).to eq counter
          9.times do
            subject.reset_if_nth_request
            counter >= 2 ? counter = 0 : counter += 1
            expect(subject.requests_since_last_reset).to eq counter
          end
        end

        it "calls capybara reset_sessions! and restarts the session driver" do
          allow(Capybara).to receive(:current_driver).and_return(:headless_chromium)
          expect(Capybara).to receive(:reset_sessions!)
          session_name = double(:session_name)
          session = double(:session)
          expect(Capybara).to receive_message_chain("session_pool.each")
                                  .and_yield(session_name, session)
          expect(session_name).to receive(:include?).with('headless_chromium').and_return(true)
          expect(session).to receive_message_chain("driver.quit")
          3.times do
            subject.reset_if_nth_request
          end
        end
      end
    end
  end
end
