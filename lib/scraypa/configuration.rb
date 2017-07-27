module Scraypa
  class Configuration
    attr_accessor :use_capybara, :tor, :driver, :driver_options

    def initialize
      @use_capybara = nil
      @tor = nil
      @driver = nil
      @driver_options = nil
    end
  end
end