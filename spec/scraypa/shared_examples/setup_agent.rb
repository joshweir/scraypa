RSpec.shared_examples "a web agent setter-upper-er" do |params|
  context "when using default config" do
    it "returns a RestClient instance"
  end

  context "when config :use_capybara is true" do
    it "validates that only supported capybara drivers are used"

    it "returns a Capybara instance"
  end

  context "when config :use_tor is true" do
    it "will reset the tor process if tor is not running associated to the current settings"

  end

  context "when config :use_tor is not true" do
    it "will destruct tor if tor process is currently running"
  end
end