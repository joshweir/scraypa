require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs'

module Scraypa
  include Capybara::DSL

  CapybaraDriverUnsupported = Class.new(StandardError)

  class VisitCapybara < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
      setup_driver
    end

    def execute params={}
      @config.tor && Scraypa.tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      Scraypa.tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      Capybara.visit params[:url]
      Capybara.page
    end

    def setup_driver
      case @config.driver
        when :poltergeist
          setup_poltergeist_driver
        when :headless_chromium
          setup_headless_chromium_driver
        when :poltergeist_billy, :selenium_chrome_billy
          setup_billy_driver
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{@config.driver}"
      end
    end

    def setup_poltergeist_driver
      driver_name = (@config.driver.to_s +
          (@config.tor ? "tor#{@config.tor_options[:tor_port]}" : '')).to_sym
      Capybara.default_driver = driver_name
      Capybara.register_driver driver_name do |app|
        Capybara::Poltergeist::Driver.new(app, @config.driver_options)
      end
    end

    def setup_billy_driver
      Capybara.javascript_driver = @config.driver
    end

    def setup_headless_chromium_driver
      driver_name = (@config.driver.to_s +
          (@config.tor ? "tor#{@config.tor_options[:tor_port]}" : '')).to_sym
      Capybara.default_driver = driver_name
      Capybara.register_driver driver_name do |app|
        Capybara::Selenium::Driver.new(app, @config.driver_options)
      end
    end
  end
end