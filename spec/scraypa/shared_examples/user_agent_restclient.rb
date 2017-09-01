RSpec.shared_examples "a user agent customizer (using RestClient)" do |params|
  context "verify that RestClient can customize the user agent" do
    before :all do
      Scraypa.reset
      stub_request(:get, "http://my.mock.site/page2.html").
          with(headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip, deflate',
                         'Host'=>'my.mock.site',
                         'User-Agent'=>'my other user agent'}).
          to_return(status: 200, body: "test response", headers: {})
    end

    it "uses the customized user agent" do
      response = Scraypa.visit(:method => :get,
                               :url => "http://my.mock.site/page2.html",
                               :timeout => 3, :open_timeout => 3,
                               :headers => {:user_agent => 'my other user agent'})
      expect(response.class).to eq(RestClient::Response)
      expect(response.to_str).to eq('test response')
    end
  end

  context "when using defaults with no :list (no :method specified)" do
    before :all do
      stub_request(:get, "http://bot.whatismyipaddress.com/").
          to_return(status: 200, body: "test response", headers: {})
    end

    it "uses a common user agent list changes user agent " +
           "every :change_after_n_requests requests" do
      expect_common_aliases_and_changes_after_n_requests params
    end

    context "with the :randomize :strategy" do
      before :all do
        stub_request(:get, "http://bot.whatismyipaddress.com/").
            to_return(status: 200, body: "test response", headers: {})
      end

      it "uses a user agent from the common_aliases list in order that isn't linear" do
        expect_common_aliases_random params
      end
    end

    context "with the :round_robin :strategy" do
      before :all do
        stub_request(:get, "http://bot.whatismyipaddress.com/").
            to_return(status: 200, body: "test response", headers: {})
      end

      it "uses a user agent from the common_aliases list in order that is linear" do
        expect_common_aliases_round_robin params
      end
    end
  end

  context "when using the :randomizer :method option" do
    before :all do
      stub_request(:get, "http://bot.whatismyipaddress.com/").
          to_return(status: 200, body: "test response", headers: {})
    end

    it "uses a user agent from the user agents randomizer list" do
      expect_ua_randomizer params
    end

    context "when :list_limit is defined" do
      before :all do
        stub_request(:get, "http://bot.whatismyipaddress.com/").
            to_return(status: 200, body: "test response", headers: {})
      end

      it "will loop over limited list of length :list_limit" do
        expect_ua_randomizer_list_limit params
      end
    end
  end

  context "when passing a list of user defined :user_agents" do
    before :all do
      stub_request(:get, "http://bot.whatismyipaddress.com/").
          to_return(status: 200, body: "test response", headers: {})
    end

    context "with the :randomize :strategy" do
      before :all do
        stub_request(:get, "http://bot.whatismyipaddress.com/").
            to_return(status: 200, body: "test response", headers: {})
      end

      it "uses a user agent from the specified list in order that isn't linear" do
        expect_ua_list_random params
      end

      context "when :list_limit is defined" do
        before :all do
          stub_request(:get, "http://bot.whatismyipaddress.com/").
              to_return(status: 200, body: "test response", headers: {})
        end

        it "will loop over limited list of length :list_limit" do
          expect_ua_list_random_list_limit params
        end
      end
    end

    context "with the :round_robin :strategy" do
      before :all do
        stub_request(:get, "http://bot.whatismyipaddress.com/").
            to_return(status: 200, body: "test response", headers: {})
      end

      it "uses a user agent from the specified list in order that is linear" do
        expect_ua_list_round_robin params
      end

      context "when :list_limit is defined" do
        before :all do
          stub_request(:get, "http://bot.whatismyipaddress.com/").
              to_return(status: 200, body: "test response", headers: {})
        end

        it "will loop over limited list of length :list_limit" do
          expect_ua_list_round_robin_list_limit params
        end
      end
    end
  end
end