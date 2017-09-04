require "bundler/setup"
require "scraypa"
require 'rspec'
require 'capybara/rspec'
require 'webmock/rspec'
require 'billy/capybara/rspec'
require 'socket'
Dir.glob(File.join(File.expand_path('../..', __FILE__),
                   "spec/scraypa/shared_examples/**/*.rb"))
    .each {|f| require f}
Dir.glob(File.join(File.expand_path('../..', __FILE__),
                   "spec/custom/**/*.rb"))
    .each {|f| require f}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def scraypa_reset_mock_shell
    expect(Scraypa).to receive(:setup_agent)
    expect(Scraypa).to_not receive(:destruct_tor)
    expect(Scraypa).to_not receive(:reset_tor)
  end

  def mock_tor_setup
    allow(Scraypa).to receive(:destruct_tor)
    expected_tor_options = {tor_port: 9050, control_port: 50500}
    expect_setup_agent_to_initialize_tor_with expected_tor_options
  end

  def expect_setup_agent_to_destruct_tor
    Scraypa.tor_process = double("tor_process")
    #Scraypa.tor_ip_control = double("tor_ip_control")
    #Scraypa.tor_proxy = double("tor_proxy")
    expect(Scraypa.tor_process).to receive(:stop)
    expect(TorManager::TorProcess).to receive(:stop_obsolete_processes)
  end

  def expect_setup_agent_to_initialize_tor_with expected_tor_options={}
    new_tor_process = double("new_tor_process")
    new_tor_proxy = double("new_tor_proxy")
    new_tor_ip_control = double("new_tor_ip_control")
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
    [new_tor_process, new_tor_proxy, new_tor_ip_control]
  end

  def configure_scraypa params
    Scraypa.reset
    Scraypa.configure do |config|
      config.throttle_seconds = 0.5
      config.user_agent = params[:user_agent] if params[:user_agent]
      config.use_capybara = true if params[:use_capybara]
      config.driver = params[:driver] if params[:driver]
      if params[:driver_options]
        config.driver_options = params[:driver_options]
      elsif params[:headless_chromium]
        config.headless_chromium = params[:headless_chromium]
      else
        if [:poltergeist, :poltergeist_billy].include? params[:driver]
          config.driver_options = {
              :phantomjs => Phantomjs.path,
              :js_errors => false,
              :phantomjs_options => ["--web-security=true"]
          }
        elsif [:headless_chromium, :selenium_chrome_billy].include? params[:driver]
          config.headless_chromium = {
              browser: :chrome,
              chromeOptions: {
                  'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
                  'args' => ["no-sandbox", "disable-gpu", "headless",
                             "window-size=1092,1080"]
              }
          }
        elsif params[:driver]
          raise "invalid params[:driver]: #{params[:driver]}"
        end
      end
    end
  end
end
