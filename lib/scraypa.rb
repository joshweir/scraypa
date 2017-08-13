require "scraypa/version"
require "scraypa/configuration"
require "scraypa/visit_interface"
require "scraypa/visit_rest_client"
require "scraypa/visit_capabara"
require "scraypa/visit_factory"
require "scraypa/tor_process_manager"
require "scraypa/process_helper"
require "scraypa/tor_controller"

module Scraypa
  class << self
    attr_accessor :agent, :tor_process_manager, :tor_controller

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
      @tor_controller.get_new_ip if using_tor?
    end

    private

    def validate_configuration
      headless_chromium_with_tor_is_invalid
    end

    def headless_chromium_with_tor_is_invalid
      raise "Capybara :headless_chromium does not support Tor" if
          using_tor? && @configuration.driver == :headless_chromium
    end

    def setup_agent
      @agent = Scraypa::VisitFactory.build(@configuration)
      using_tor? && !tor_running_in_current_process? ?
          reset_tor : destruct_tor
    end

    def using_tor?
      @configuration.tor && @configuration.tor_options
    end

    def tor_running_in_current_process?
      TorProcessManager.tor_running_on?(port: @configuration.tor_options[:tor_port],
                                             parent_pid: Process.pid)
    end

    def reset_tor
      destruct_tor
      initialize_tor(@configuration.tor_options) if @configuration.tor
    end

    def initialize_tor params={}
      @tor_process_manager = TorProcessManager.new params
      @tor_controller = TorController.new(
                tor_process_manager: @tor_process_manager)
      @tor_process_manager.start
    end

    def destruct_tor
      @tor_process_manager.stop if @tor_process_manager
      TorProcessManager.stop_obsolete_processes
      @tor_controller = nil
      @tor_process_manager = nil
    end
  end
end
