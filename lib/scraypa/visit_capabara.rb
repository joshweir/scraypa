require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs'

module Scraypa
  include Capybara::DSL

  class VisitCapybara < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
      setup_driver
    end

    def execute params={}
      @config.tor_controller ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      @config.tor_controller.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      Capybara.visit params[:url]
      wrap_response Capybara.page
    end

    def setup_driver
      case @config.driver
        when :poltergeist, :poltergeist_billy
          setup_poltergeist_driver
        when :headless_chromium
          setup_headless_chromium_driver
        else
          raise "Currently no support for capybara driver: #{@config.driver}"
      end
    end

    def setup_poltergeist_driver
      Capybara.default_driver = @config.driver
      Capybara.register_driver @config.driver do |app|
        Capybara::Poltergeist::Driver.new(app, @config.driver_options)
      end
    end

    def setup_headless_chromium_driver
      Capybara.default_driver = @config.driver
      Capybara.register_driver @config.driver do |app|
        Capybara::Selenium::Driver.new(app, @config.driver_options)
      end
    end

    def wrap_response native_response
      Scraypa::Response.new native_response: native_response
    end
  end
end