module Scraypa
  class Configuration
    attr_accessor :use_capybara, :driver, :driver_options, :tor, :tor_options,
                  :tor_proxy, :user_agent_retriever, :user_agent,
                  :eye_tor_config_template, :throttle_seconds

    def initialize
      @use_capybara = nil
      @tor = nil
      @tor_options = nil
      @tor_proxy = nil
      @user_agent_retriever = nil
      @user_agent = nil
      @driver = nil
      @driver_options = nil
      @eye_tor_config_template = nil
      @throttle_seconds = nil
    end
  end
end