RSpec.shared_examples "a user agent customizer (using :poltergeist)" do |params|
  context "verify that :poltergeist can customize the user agent", type: :feature,
          driver: :poltergeist_billy do
    before :all do
      proxy.stub('http://www.google.com/')
          .and_return(:text => "test response")
    end

    it 'uses the customized user agent' do
      Capybara.page.driver.add_headers("User-Agent" => "the user agent string you want")
      configure_scraypa params.merge({driver: :poltergeist_billy})
      response = Scraypa.visit url: "http://www.google.com/"
      expect(response).to have_content('test response')
      response.execute_script(
          "document.getElementsByTagName('body')[0].innerHTML = navigator.userAgent;")
      expect(response).to have_content('the user agent string you want')
    end
  end

  context "when using defaults with no :list (no :method specified)", type: :feature,
          driver: :poltergeist_billy do
    before :all do
      proxy.stub('http://example.com/')
          .and_return(:text => "test response")
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