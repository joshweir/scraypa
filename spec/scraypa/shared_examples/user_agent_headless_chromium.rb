RSpec.shared_examples "a user agent customizer (using :headless_chromium)" do |params|
  #unfortunately cannot proxy headless_chromium through puffing billy
  #as need to modify the user agent which is not available with
  #:selenium_chrome_billy
  context "verify that :headless_chromium can customize the user agent" do
    it 'uses the customized user agent' do
      configure_scraypa params
      #Capybara.page.driver.header("User-Agent" => "the user agent string you want")
      response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
      expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('the user agent string you want')
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