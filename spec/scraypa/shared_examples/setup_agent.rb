RSpec.shared_examples "a web agent setter-upper-er" do |params|
  context "when using default config" do
    it "returns a RestClient instance"
  end

  context "when config :use_capybara is true" do
    it "validates that only supported capybara drivers are used"

    it "returns a Capybara instance"
  end

  context "when config :use_tor is true" do
    context "when using default tor settings" do
      it "will reset the tor process if tor is not running associated to the current settings" do
=begin
        allow(TorManager::TorProcess)
            .to receive(:tor_running_on?)
                    .with(port: 9050,
                          parent_pid: Process.pid)
                    .and_return(false)

        destruct_tor
        initialize_tor(@configuration.tor_options)
        Scraypa.reset
        Scraypa.configure { |c| c.tor = true }
        config = Scraypa.configuration
        expect(config.tor).to be_truthy
        expect(config.tor_options[:tor_port]).to eq 9050
        expect(config.tor_options[:control_port]).to eq 50500
        expect(config.use_capybara).to be_nil
=end
      end
    end

    context "when using custom tor settings" do
      it "will reset the tor process if tor is not running associated to the current settings"
    end

  end

  context "when config :use_tor is not true" do
    it "will destruct tor if tor process is currently running"
  end
end