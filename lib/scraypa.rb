require "scraypa/version"
require "scraypa/configuration"
require "scraypa/visit_interface"
require "scraypa/visit_rest_client"
require "scraypa/visit_capabara"
require "scraypa/visit_factory"
require 'tormanager'

module Scraypa
  TorNotSupportedByAgent = Class.new(StandardError)

  class << self
    attr_reader :agent, :tor_process, :tor_ip_control, :tor_proxy

    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(config)
      @configuration = config
    end

    def reset
      @configuration = Configuration.new
      setup_agent
      @configuration
    end

    def configure
      yield(configuration).tap{
        validate_configuration
        setup_agent
      }
    end

    def visit params={}
      setup_agent unless @agent
      @agent.execute(params)
    end

    def change_tor_ip_address
      @tor_ip_control.get_new_ip if using_tor?
    end

    private

    def validate_configuration
      headless_chromium_with_tor_is_invalid
    end

    def headless_chromium_with_tor_is_invalid
      raise TorNotSupportedByAgent,
            "Capybara :headless_chromium does not support Tor" if
          using_tor? && @configuration.driver == :headless_chromium
    end

    def setup_agent
      ensure_tor_options_are_configured if using_tor?
      @agent = Scraypa::VisitFactory.build(@configuration)
      using_tor? && !tor_running_in_current_process? ?
          reset_tor :
          (!using_tor? &&
              tor_running_in_current_process? ?
              destruct_tor : nil)
    end

    def ensure_tor_options_are_configured
      @configuration.tor_options ||= {}
      @configuration.tor_options[:tor_port] ||= 9050
      @configuration.tor_options[:control_port] ||= 50500
    end

    def using_tor?
      @configuration.tor
    end

    def tor_running_in_current_process?
      TorManager::TorProcess
            .tor_running_on?(port: @configuration.tor_options &&
                                   @configuration.tor_options[:tor_port] || 9050,
                             parent_pid: Process.pid)
    end

    def reset_tor
      destruct_tor
      initialize_tor(@configuration.tor_options) if @configuration.tor
    end

    def initialize_tor params={}
      @tor_process = TorManager::TorProcess.new params || {}
      @tor_proxy = TorManager::Proxy.new tor_process: @tor_process
      @tor_ip_control = TorManager::IpAddressControl.new(
                tor_process: @tor_process, tor_proxy: @tor_proxy)
      @tor_process.start
    end

    def destruct_tor
      @tor_process.stop if @tor_process
      TorManager::TorProcess.stop_obsolete_processes
      @tor_ip_control = nil
      @tor_proxy = nil
      @tor_process = nil
    end
  end
end
