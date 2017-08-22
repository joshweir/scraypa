RSpec.shared_examples "a web agent setter-upper-er" do |params|
  context "when using default config" do
    it "returns a RestClient instance" do
      allow(Scraypa).to receive(:destruct_tor)
      #expect(Scraypa::VisitRestClient).to receive(:new)
      Scraypa.reset
      expect(Scraypa.agent.class).to eq Scraypa::VisitRestClient
    end
  end

  context "when config :use_capybara is true" do
    it "validates that only supported capybara drivers are used" do
      expect{
        Scraypa.configure { |c|
          c.use_capybara = true
          c.driver = :dummydriver
        }
      }.to raise_error Scraypa::CapybaraDriverUnsupported,
                       /Currently no support for capybara driver: dummydriver/
    end

    it "returns a Capybara instance" do
      allow(Scraypa).to receive(:destruct_tor)
      Scraypa.configure { |c|
        c.use_capybara = true
        c.driver = :poltergeist
      }
      expect(Scraypa.agent.class).to eq Scraypa::VisitCapybara
    end
  end

  context "when config :tor is true" do
    context "when using default tor settings" do
      it "will use default configuration.tor_options for :tor_port and :control_port" do
        allow(Scraypa).to receive(:destruct_tor)
        allow(Scraypa).to receive(:reset_tor)
        Scraypa.configure { |c|
          c.tor = true
        }
        expected_tor_options = {tor_port: 9050, control_port: 50500}
        expect(Scraypa.configuration.tor_options)
            .to eq expected_tor_options
      end

      it "will reset the tor process if tor is not running " +
             "associated to the current settings" do
        expect(TorManager::TorProcess)
            .to receive(:tor_running_on?)
                    .with(port: 9050,
                          parent_pid: Process.pid)
                    .and_return(false)
        expect_setup_agent_to_destruct_tor
        expected_tor_options = {tor_port: 9050, control_port: 50500}
        expect_setup_agent_to_initialize_tor_with expected_tor_options
        Scraypa.configure { |c|
          c.tor = true
        }

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

      it "will not reset the tor process if it is already running " +
             "associated to the current settings" do
        expect(TorManager::TorProcess)
            .to receive(:tor_running_on?)
                    .with(port: 9050,
                          parent_pid: Process.pid)
                    .and_return(true)
        expect(Scraypa).to_not receive(:destruct_tor)
        expect(Scraypa).to_not receive(:reset_tor)
        Scraypa.configure { |c|
          c.tor = true
        }
      end
    end

    context "when using custom tor settings" do
      it "will reset the tor process if tor is not running " +
             "associated to the current settings" do
        expect(TorManager::TorProcess)
            .to receive(:tor_running_on?)
                    .with(port: 9051,
                          parent_pid: Process.pid)
                    .and_return(false)
        expect_setup_agent_to_destruct_tor
        expected_tor_options = {tor_port: 9051, control_port: 50501}
        expect_setup_agent_to_initialize_tor_with expected_tor_options
        Scraypa.configure { |c|
          c.tor = true
          c.tor_options = {
              tor_port: 9051,
              control_port: 50501
          }
        }
      end
    end
  end

  context "when config :tor is not true" do
    it "will destruct tor if tor process is running" +
           " and is associated to the current process" do
      expect(TorManager::TorProcess)
          .to receive(:tor_running_on?)
                  .with(parent_pid: Process.pid)
                  .and_return(true)
      expect_setup_agent_to_destruct_tor
      Scraypa.configure { |c|
        c.tor = nil
      }
    end
  end

  def expect_setup_agent_to_destruct_tor
    #Scraypa.tor_process = double("tor_process")
    #Scraypa.tor_ip_control = double("tor_ip_control")
    #Scraypa.tor_proxy = double("tor_proxy")
    expect(Scraypa.tor_process).to receive(:stop)
    expect(TorManager::TorProcess).to receive(:stop_obsolete_processes)
  end

  def expect_setup_agent_to_initialize_tor_with expected_tor_options={}
    new_tor_process = double("new_tor_process")
    new_tor_proxy = double("new_tor_proxy")
    new_tor_ip_control = double("new_tor_ip_control")
    expected_tor_options = {tor_port: 9050, control_port: 50500}
    expect(TorManager::TorProcess)
        .to receive(:new)
                .with(expected_tor_options)
                .and_return(new_tor_process)
    expect(TorManager::Proxy)
        .to receive(:new)
                .with(tor_process: new_tor_process)
                .and_return(new_tor_proxy)
    expect(TorManager::IpAddressControl)
        .to receive(:new)
                .with(tor_process: new_tor_process,
                      tor_proxy: new_tor_proxy)
                .and_return(new_tor_ip_control)
    expect(new_tor_process).to receive(:start)
  end
end