require "spec_helper"

module Scraypa
  describe VisitFactory do
    describe ".build" do
      context "when config.use_capybara and config.driver is :poltergiest" do
        let(:config) {
          c = Configuration.new
          c.use_capybara = true
          c.driver = :poltergeist
          c
        }
        let(:subject) { VisitFactory.build(config) }
        it "instantiates a VisitCapybaraPoltergeist object" do
          expect(subject.class).to eq VisitCapybaraPoltergeist
        end

        it "passes the params to the instantiated object" do
          expect(VisitCapybaraPoltergeist).to receive(:new).with(config)
          VisitFactory.build(config)
        end
      end

      context "when config.use_capybara and config.driver is :headless_chromium" do
        let(:config) {
          c = Configuration.new
          c.use_capybara = true
          c.driver = :headless_chromium
          c
        }
        let(:subject) { VisitFactory.build(config) }
        it "instantiates a VisitCapybaraHeadlessChromium object" do
          expect(subject.class).to eq VisitCapybaraHeadlessChromium
        end

        it "passes the params to the instantiated object" do
          expect(VisitCapybaraHeadlessChromium).to receive(:new).with(config)
          VisitFactory.build(config)
        end
      end

      context "when config.use_capybara and config.driver is not recognized" do
        let(:config) {
          c = Configuration.new
          c.use_capybara = true
          c.driver = :dummydriver
          c
        }
        it "raises CapybaraDriverUnsupported exception" do
          expect{
            VisitFactory.build(config)
          }.to raise_error Scraypa::CapybaraDriverUnsupported,
                           /Currently no support for capybara driver: dummydriver/
        end
      end

      context "when not config.use_capybara" do
        let(:config) { c = Configuration.new }
        let(:subject) { VisitFactory.build(config) }
        it "instantiates a VisitRestClient object" do
          expect(subject.class).to eq VisitRestClient
        end

        it "passes the params to the instantiated object" do
          expect(VisitRestClient).to receive(:new).with(config)
          VisitFactory.build(config)
        end
      end
    end
  end
end