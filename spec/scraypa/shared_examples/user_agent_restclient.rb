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

  context "when using the :common_aliases :user_agents option" do
    before :all do

    end

    it "uses a user agent list of :common_aliases and changes user agent " +
           "every :change_after_n_requests requests" do
      Scraypa.reset
      configure_scraypa(
          params.merge({
                           user_agent: {
                               user_agents: :common_aliases,
                               strategy: :randomize,
                               change_after_n_requests: 2
                           }
                       }))
      Scraypa.visit method: :get, url: "http://example.com/"
      agent_before = Scraypa.user_agent
      expect(agent_before).to_not be_nil
      expect(Scraypa.common_user_agents).to include agent_before
      Scraypa.visit method: :get, url: "http://example.com/"
      expect(Scraypa.user_agent).to eq agent_before
      Scraypa.visit method: :get, url: "http://example.com/"
      agent_after = Scraypa.user_agent
      expect(agent_after).to_not eq agent_before
      expect(Scraypa.common_user_agents).to include agent_after
    end

    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list in order that isn't linear"
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list in order that is linear"
    end
  end

  context "when using the :randomizer :user_agents option" do
    it "uses a user agent from the user agents randomizer list"
  end

  context "when passing a list of user defined :user_agents" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the :common_aliases list in order that isn't linear"
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the :common_aliases list in order that is linear"
    end
  end
end