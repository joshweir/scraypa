RSpec.shared_examples "a web agent, user agent, tor, throttle setter-upper-er" do |params|
  context "when using default config" do
    it "returns a RestClient instance" do
      allow(Scraypa).to receive(:destruct_tor)
      #expect(Scraypa::VisitRestClient).to receive(:new)
      Scraypa.reset
      expect(Scraypa.agent.class).to eq Scraypa::VisitRestClient
      expect(Scraypa.user_agent_retriever).to be_nil
      expect(Scraypa.throttle).to be_nil
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
      expect(Scraypa.agent.class).to eq Scraypa::VisitCapybaraPoltergeist
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

  context "when config :user_agent is specified" do
    it "builds a user agent with :user_agent params" do
      allow(Scraypa).to receive(:destruct_tor)
      expect(Scraypa::UserAgentFactory)
          .to receive(:build).with(list: 'agent1')
      Scraypa.configure { |c|
        c.user_agent = {list: 'agent1'}
      }
    end

    it "assigns the user agent retriever instance to Scraypa.user_agent_retriever" do
      allow(Scraypa).to receive(:destruct_tor)
      Scraypa.configure { |c|
        c.user_agent = {list: 'agent1'}
      }
      expect(Scraypa.user_agent_retriever.class).to eq Scraypa::UserAgentIterator
    end
  end

  context "when config :user_agent is specified with " +
              "use_capybara driver: :headless_chromium" do
    it "builds a user agent with :user_agent params including a :list_limit default" do
      allow(Scraypa).to receive(:destruct_tor)
      expect(Scraypa::UserAgentFactory)
          .to receive(:build).with(list: 'agent1',
                                   list_limit: 30)
      Scraypa.configure { |c|
        c.use_capybara = true
        c.driver = :headless_chromium
        c.headless_chromium = {
            browser: :chrome,
            chromeOptions: {
                'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                'args' => ["no-sandbox", "disable-gpu", "headless",
                           "window-size=1092,1080"]
            }
        }
        c.user_agent = {list: 'agent1'}
      }
    end

    it "builds a user agent with :user_agent params and doesnt " +
           "overwrite :list_limit if specified" do
      allow(Scraypa).to receive(:destruct_tor)
      expect(Scraypa::UserAgentFactory)
          .to receive(:build).with(list: 'agent1',
                                   list_limit: 5)
      Scraypa.configure { |c|
        c.use_capybara = true
        c.driver = :headless_chromium
        c.headless_chromium = {
            browser: :chrome,
            chromeOptions: {
                'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                'args' => ["no-sandbox", "disable-gpu", "headless",
                           "window-size=1092,1080"]
            }
        }
        c.user_agent = {list: 'agent1', list_limit: 5}
      }
    end
  end

  context "when config :throttle_seconds is specified" do
    context "when :throttle_seconds is > 0" do
      it "creates a throttle instance based on :throttle_seconds" do
        expect_throttle_instance_from_throttle_seconds 0.1
      end
    end
    context "when :throttle_seconds is == 0" do
      it "does not create a throttle instance" do
        expect_no_throttle_instance_from_throttle_seconds 0
      end
    end
    context "when :throttle_seconds is not a hash or number" do
      it "does not create a throttle instance" do
        expect_no_throttle_instance_from_throttle_seconds "foo"
      end
    end
    context "when :throttle_seconds is a hash range" do
      it "creates a throttle instance based on :throttle_seconds" do
        range = {from: 0.1, to: 2.5}
        expect_throttle_instance_from_throttle_seconds range
      end
    end
    context "when :throttle_seconds is different to current config" do
      it "creates a new throttle instance based on changed :throttle_seconds" do
        allow(Scraypa).to receive(:destruct_tor)
        Scraypa.reset
        Scraypa.configure { |c|
          c.throttle_seconds = 0.1
        }
        expect(Scraypa.throttle.seconds).to eq 0.1
        Scraypa.configure { |c|
          c.throttle_seconds = 0.2
        }
        expect(Scraypa.throttle.seconds).to eq 0.2
      end
    end
  end

  def expect_throttle_instance_from_throttle_seconds throttle_seconds
    allow(Scraypa).to receive(:destruct_tor)
    Scraypa.reset
    Scraypa.configure { |c|
      c.throttle_seconds = throttle_seconds
    }
    expect(Scraypa.throttle.seconds).to eq throttle_seconds
  end

  def expect_no_throttle_instance_from_throttle_seconds throttle_seconds
    allow(Scraypa).to receive(:destruct_tor)
    Scraypa.reset
    Scraypa.configure { |c|
      c.throttle_seconds = throttle_seconds
    }
    expect(Scraypa.throttle).to be_nil
  end
end