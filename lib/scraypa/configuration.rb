module Scraypa
  class Configuration
    attr_accessor :use_capybara, :tor, :driver, :driver_options, :tor_options,
                  :eye_tor_config_template

    def initialize
      @use_capybara = nil
      @tor = nil
      @tor_options = nil
      @driver = nil
      @driver_options = nil
      @eye_tor_config_template = nil
      initialize_tor @tor_options if @tor
    end

    private

    def initialize_tor params={}

    end
  end
end