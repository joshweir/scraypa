RSpec.shared_examples "a user agent customizer (using :headless_chromium)" do |params|
  #unfortunately cannot proxy headless_chromium through puffing billy
  #as need to modify the user agent which is not available with
  #:selenium_chrome_billy
  context "verify that :headless_chromium can customize the user agent" do
    it 'uses the customized user agent' do
      configure_scraypa params.merge({user_agent: {list: 'the user agent string you want'}})
      response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
      expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('the user agent string you want')
    end

    it 'can loop through the user agents' do
      configure_scraypa params.merge({user_agent: {list: %w(agent1 agent2)}})
      response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
      expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('agent1')
      expect(Scraypa.user_agent).to eq 'agent1'
      response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
      expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('agent2')
      expect(Scraypa.user_agent).to eq 'agent2'
      response = Scraypa.visit url: "http://bot.whatismyipaddress.com"
      expect(response).to have_content(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('agent1')
      expect(Scraypa.user_agent).to eq 'agent1'
    end
  end

  context "when using defaults with no :list (no :method specified)" do
    before :all do

    end

    it "uses a common user agent list changes user agent " +
           "every :change_after_n_requests requests" do
      expect_common_aliases_and_changes_after_n_requests params
    end

    context "with the :randomize :strategy" do
      it "uses a user agent from the common_aliases list in order that isn't linear" do
        expect_common_aliases_random params
      end
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the common_aliases list in order that is linear" do
        expect_common_aliases_round_robin params
      end
    end
  end

  context "when using the :randomizer :method option" do
    it "uses a user agent from the user agents randomizer list" do
      expect_ua_randomizer params
    end

    context "when :list_limit is defined" do
      it "will loop over limited list of length :list_limit" do
        expect_ua_randomizer_list_limit params
      end
    end
  end

  context "when passing a list of user defined :user_agents" do
    context "with the :randomize :strategy" do
      it "uses a user agent from the specified list in order that isn't linear" do
        expect_ua_list_random params
      end

      context "when :list_limit is defined" do
        it "will loop over limited list of length :list_limit" do
          expect_ua_list_random_list_limit params
        end
      end
    end

    context "with the :round_robin :strategy" do
      it "uses a user agent from the specified list in order that is linear" do
        expect_ua_list_round_robin params
      end

      context "when :list_limit is defined" do
        it "will loop over limited list of length :list_limit" do
          expect_ua_list_round_robin_list_limit params
        end
      end
    end
  end
end