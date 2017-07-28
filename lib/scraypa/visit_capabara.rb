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
      Capybara.visit params[:url]
      wrap_response Capybara.page
    end

    private

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