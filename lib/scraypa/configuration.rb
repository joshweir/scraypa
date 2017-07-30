module Scraypa
  class Configuration
    attr_accessor :use_capybara, :tor, :driver, :driver_options, :tor_options,
                  :god_tor_config_template

    def initialize
      @use_capybara = nil
      @tor = nil
      @tor_options = nil
      @driver = nil
      @driver_options = nil
      @god_tor_config_template = nil
    end
  end
end