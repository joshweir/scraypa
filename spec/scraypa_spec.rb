require "spec_helper"
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe Scraypa do
  it "has a version number" do
    expect(Scraypa::VERSION).not_to be nil
  end

=begin
  describe "#configure" do
    before do
      Scraypa.configure do |config|
        config.use_javascript = true
      end
    end

    it "returns an array with 10 elements" do
      draw = MegaLotto::Drawing.new.draw

      expect(draw).to be_a(Array)
      expect(draw.size).to eq(10)
    end
  end
=end
  describe "#visit" do
    describe "not using javascript (using Rest-Client gem)" do
      before do
        stub_request(:get, /my.mock.site\/page.html/).
            with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
            to_return(status: 200,
                      body: "stubbed response",
                      headers: {})
        @response = Scraypa.visit(:method => :get,
                                  :url => "http://my.mock.site/page.html",
                                  :timeout => 3, :open_timeout => 3)
      end

      it "should utilise rest client to download web content" do
        expect(@response).to eq(nil)
      end
    end
  end
end
