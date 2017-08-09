module Scraypa
  class Configuration
    attr_accessor :use_capybara, :driver, :driver_options, :tor, :tor_options,
                  :eye_tor_config_template, :tor_process_manager, :tor_controller

    def initialize
      @use_capybara = nil
      @tor = nil
      @tor_options = nil
      @driver = nil
      @driver_options = nil
      @eye_tor_config_template = nil
      @tor_process_manager = nil
      @tor_controller = nil
    end
  end
end