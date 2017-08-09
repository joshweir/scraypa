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
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def visit params={}
      reset_tor if using_tor? && !tor_running_in_current_process?
      Scraypa::VisitFactory.build(Scraypa.configuration).execute(params)
    end

    def change_tor_ip_address
      Scraypa.configuration.tor_controller.get_new_ip if using_tor?
    end

    private

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
      config = Scraypa.configuration
      puts 'init!!!!!!!!!!'
      puts config.inspect
      Scraypa.configuration.tor_process_manager = TorProcessManager.new params
      Scraypa.configuration.tor_controller = TorController.new(
          tor_process_manager: Scraypa.configuration.tor_process_manager)
      Scraypa.configuration.tor_process_manager.start
    end

    def destruct_tor
      puts 'destruct!!!!!!!!!!'
      puts Scraypa.configuration.inspect
      TorProcessManager.stop_obsolete_processes
      Scraypa.configuration.tor_process_manager.stop if Scraypa.configuration.tor_process_manager
      Scraypa.configuration.tor_controller = nil
      Scraypa.configuration.tor_process_manager = nil
    end
  end
end
