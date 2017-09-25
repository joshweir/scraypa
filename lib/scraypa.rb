require "scraypa/version"
require "scraypa/configuration"
require "scraypa/visit/visit_interface"
require "scraypa/visit/visit_rest_client"
require "scraypa/visit/visit_capabara_poltergeist"
require "scraypa/visit/visit_capabara_headless_chromium"
require "scraypa/visit/visit_factory"
require "scraypa/user_agent/user_agent_abstract"
require "scraypa/user_agent/user_agent_common_aliases_lists"
require "scraypa/user_agent/user_agent_iterator"
require "scraypa/user_agent/user_agent_random"
require "scraypa/user_agent/user_agent_factory"
require "scraypa/throttle"
require "scraypa/driver_resetter"
require 'tormanager'

module Scraypa
  class TorNotSupportedByAgent < StandardError; end
  class UnrecognisedUserAgentsMethod < StandardError; end
  class CapybaraDriverUnsupported < StandardError; end
  class HeadlessChromiumMissingConfig < StandardError; end

  class << self
    attr_accessor :agent, :tor_process, :tor_ip_control, :tor_proxy,
                  :throttle, :user_agent_retriever, :driver_resetter

    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(config)
      @configuration = config
    end

    def reset
      @configuration = Configuration.new
      reset_throttle
      setup_scraypa
      @configuration
    end

    def configure
      yield(configuration).tap{
        validate_configuration
        setup_scraypa
      }
    end

    def visit params={}
      setup_scraypa unless @agent
      visit_with_throttle params
    end

    def change_tor_ip_address
      @tor_ip_control.get_new_ip if using_tor?
    end

    def user_agent
      @user_agent_retriever ?
          @user_agent_retriever.current_user_agent : nil
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

    def setup_scraypa
      setup_user_agent
      setup_tor
      setup_driver_resetter
      setup_agent
      setup_throttle
    end

    def setup_user_agent
      @user_agent_retriever =
          @configuration.user_agent ?
              UserAgentFactory.build(
                  merge_user_agent_list_limit_for_chrome(
                      @configuration.user_agent)) : nil
    end

    def merge_user_agent_list_limit_for_chrome config
      @configuration.driver == :headless_chromium &&
          !config[:list_limit] ?
          config.merge({list_limit: 30}) : config
    end

    def setup_tor
      ensure_tor_options_are_configured
      using_tor? && !tor_running_in_current_process? ?
          reset_tor :
          (!using_tor? && tor_running_in_current_process? ?
              destruct_tor : nil)
    end

    def ensure_tor_options_are_configured
      if using_tor?
        @configuration.tor_options ||= {}
        @configuration.tor_options[:tor_port] ||= 9050
        @configuration.tor_options[:control_port] ||= 50500
      else
        @configuration.tor_options = nil
      end
    end

    def using_tor?
      @configuration.tor
    end

    def tor_running_in_current_process?
      @configuration.tor_options &&
          @configuration.tor_options[:tor_port] ?
          TorManager::TorProcess
              .tor_running_on?(port: @configuration.tor_options[:tor_port],
                               parent_pid: Process.pid) :
          TorManager::TorProcess
              .tor_running_on?(parent_pid: Process.pid)
    end

    def reset_tor
      destruct_tor
      initialize_tor(@configuration.tor_options) if @configuration.tor
    end

    def initialize_tor params={}
      @tor_process = TorManager::TorProcess.new params || {}
      @tor_proxy =
          TorManager::Proxy.new tor_process: @tor_process
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

    def setup_driver_resetter
      @driver_resetter =
          DriverResetter.new(
              @configuration.reset_driver_every_n_requests)
    end

    def setup_agent
      @agent = Scraypa::VisitFactory
                   .build(config: @configuration,
                          tor_proxy: @tor_proxy,
                          driver_resetter: @driver_resetter)
    end

    def setup_throttle
      @throttle = Throttle.new seconds: @configuration.throttle_seconds if
          throttle_config_has_changed?
    end

    def throttle_config_has_changed?
      @configuration.throttle_seconds &&
          (@configuration.throttle_seconds.is_a?(Hash) ||
              @configuration.throttle_seconds.to_f > 0) &&
          (!@throttle || @throttle.seconds != @configuration.throttle_seconds)
    end

    def visit_with_throttle params
      @throttle.throttle if @throttle
      response = @agent.execute(params)
      @throttle.last_request_time = Time.now if @throttle
      response
    end

    def reset_throttle
      @throttle.last_request_time = nil if @throttle
      @throttle = nil
    end
  end
end