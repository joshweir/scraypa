module Scraypa
  class Configuration
    attr_accessor :use_capybara, :driver, :driver_options, :tor, :tor_options,
                  :eye_tor_config_template

    def initialize
      @use_capybara = nil
      @tor = nil
      @tor_options = nil
      @driver = nil
      @driver_options = nil
      @eye_tor_config_template = nil
    end
  end
end