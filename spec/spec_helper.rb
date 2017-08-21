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

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def scraypa_reset_mock_shell
    #expect(TorManager::TorProcess)
    #    .to receive(:tor_running_on?)
    #            .with(port: 9050,
    #                  parent_pid: Process.pid)
    #            .and_return(false)
    expect(Scraypa).to receive(:setup_agent)
    expect(Scraypa).to_not receive(:destruct_tor)
    expect(Scraypa).to_not receive(:reset_tor)
  end
end
