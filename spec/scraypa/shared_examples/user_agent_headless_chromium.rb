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
      expect(response.text).to eq "the user agent string you want"
      expect(response).to have_content('the user agent string you want')
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