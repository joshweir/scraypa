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
      @current_user_agent = nil
    end

    def execute params={}
      @config.tor && @config.tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      @config.tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      update_user_agent_if_changed
      Capybara.visit params[:url]
      Capybara.page
    end

    def update_user_agent_if_changed
      if @config.user_agent_retriever
        new_user_agent = @config.user_agent_retriever.user_agent
        if @current_user_agent != new_user_agent
          @current_user_agent = new_user_agent
          update_user_agent_based_on_driver
        end
      end
    end

    def update_user_agent_based_on_driver
      case @config.driver
        when :poltergeist, :poltergeist_billy
          Capybara.page.driver.add_headers(
              "User-Agent" => @current_user_agent)
        when :headless_chromium
          setup_headless_chromium_driver
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{@config.driver}"
      end
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
        Capybara::Poltergeist::Driver.new(app, @config.driver_options || {})
      end
    end

    def setup_billy_driver
      Capybara.javascript_driver = @config.driver
    end

    def setup_headless_chromium_driver
      driver_name = (@config.driver.to_s +
          (@config.tor ? "tor#{@config.tor_options[:tor_port]}" : '')).to_sym
      driver_options = @config.driver_options || {}
      #driver_options[:args] = [] unless driver_options.include?(:args)
      #if @current_user_agent
      #  driver_options[:args].delete_if {|d| d.include?("user-agent=")}
      #  driver_options[:args] << "--user-agent=#{@current_user_agent}"
      #end
      #puts 'driver options!!!!!!!!!!'
      #puts driver_options.inspect

      needs to do this:

      not just args, args needs to be inside the capabilities object
      #desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      #    "chromeOptions" => {
      #        'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
      #        'args' => ["no-sandbox", "disable-gpu", "headless",
      #                   "window-size=1092,1080"]
      #    }
      #)


      Capybara.default_driver = driver_name
      Capybara.register_driver driver_name do |app|
        Capybara::Selenium::Driver.new(app, driver_options)
      end
    end
  end
end