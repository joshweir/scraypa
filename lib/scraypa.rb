require "scraypa/version"
require "scraypa/configuration"
require "scraypa/visit_interface"
require "scraypa/visit_rest_client"
require "scraypa/visit_capabara"
require "scraypa/visit_factory"
require "scraypa/response"
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
        setup_agent
      }
    end

    def visit params={}
      setup_agent unless @agent
      @agent.execute(params)
    end

    def change_tor_ip_address
      Scraypa.tor_controller.get_new_ip if using_tor?
    end

    private

    def setup_agent
      #puts 'setting up agent!!'
      #puts Scraypa.configuration.inspect
      @agent = Scraypa::VisitFactory.build(Scraypa.configuration)
      using_tor? && !tor_running_in_current_process? ?
          reset_tor : destruct_tor
    end

    def using_tor?
      config = Scraypa.configuration
      config.tor && config.tor_options
    end

    def tor_running_in_current_process?
      config = Scraypa.configuration
      TorProcessManager.tor_running_on?(port: config.tor_options[:tor_port],
                                             parent_pid: Process.pid)
    end

    def reset_tor
      destruct_tor
      config = Scraypa.configuration
      initialize_tor(config.tor_options) if config.tor
    end

    def initialize_tor params={}
      #config = Scraypa.configuration
      #configure do |config|
      #  config.tor_process_manager = TorProcessManager.new params
      #  config.tor_controller = TorController.new(
      #      tor_process_manager: config.tor_process_manager)
      #end
      Scraypa.tor_process_manager = TorProcessManager.new params
      Scraypa.tor_controller = TorController.new(
                tor_process_manager: Scraypa.tor_process_manager)
      Scraypa.tor_process_manager.start
    end

    def destruct_tor
      Scraypa.tor_process_manager.stop if Scraypa.tor_process_manager
      TorProcessManager.stop_obsolete_processes
      #configure do |config|
      #  config.tor_controller = nil
      #  config.tor_process_manager = nil
      #end
      Scraypa.tor_controller = nil
      Scraypa.tor_process_manager = nil
    end
  end
end
