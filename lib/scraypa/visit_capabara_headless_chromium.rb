require 'capybara'

module Scraypa
  include Capybara::DSL

  CapybaraDriverUnsupported = Class.new(StandardError)
  TooManyUserAgents = Class.new(StandardError)
  HeadlessChromiumMissingConfig = Class.new(StandardError)

  class VisitCapybaraHeadlessChromium < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
      reset_and_setup_driver
      @current_user_agent = nil
      @user_agents = []
      @registered_drivers = []
      @user_agent_list_limit =
          @config.headless_chromium[:user_agent_list_limit] || 30
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
          validate_user_agent_list_limit
          @current_user_agent = new_user_agent
          @user_agents << @current_user_agent
          setup_headless_chromium_driver
        end
      else
        @current_user_agent = nil
      end
    end

    def validate_user_agent_list_limit
      raise TooManyUserAgents,
            "Only #{@user_agent_list_limit} user agents can be " +
                "used with #{@config.driver}" if
          @user_agents.length >= @user_agent_list_limit
    end

    def reset_and_setup_driver
      case @config.driver
        when :headless_chromium
          reset_headless_chromium_drivers
          setup_headless_chromium_driver
        when :selenium_chrome_billy
          setup_billy_driver
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{@config.driver}"
      end
    end

    def reset_headless_chromium_drivers
      puts "reseting!!!!!!!!!!!!!!!!!!!!!!!!"
      Capybara.reset_sessions!
      session_pool_to_delete = []
      @registered_drivers ||= []
      Capybara.send(:session_pool).each do |session_name, session|
        @registered_drivers.map(&:to_s).each do |registered_driver|
          if session_name.include?(registered_driver)
            session.driver.quit
            session_pool_to_delete << session_name
            next
          end
        end
      end
      Capybara.send(:session_pool).delete_if{|session_name,session|
        session_pool_to_delete.include? session_name
      }
      Capybara.drivers.delete_if{|driver_name,driver_proc|
        @registered_drivers.include?(driver_name)
      }
    end

    def setup_billy_driver
      Capybara.javascript_driver = @config.driver
    end

    def setup_headless_chromium_driver
      #needs to do this:

      #not just args, args needs to be inside the capabilities object
      #desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      #    "chromeOptions" => {
      #        'binary' => "#{ENV['HOME']}/chromium/src/out/Default/chrome",
      #        'args' => ["no-sandbox", "disable-gpu", "headless",
      #                   "window-size=1092,1080"]
      #    }
      #)
=begin
  @config.driver_options looked like this:

  {
  browser: :chrome,
  desired_capabilities: Selenium......
    "chromeOptions" => {
      'binary' =>
      'args' =>
    }
  }
  optionally:
  args: ['args']

change for headless chromium config no longer uses driver_options but uses:

@config.headless_chromium[:browser]
@config.headless_chromium[:chromeOptions]
@config.headless_chromium[:args]

=end
      update_user_agent_if_changed
      driver_name = (@config.driver.to_s +
          (@config.tor ? "tor#{@config.tor_options[:tor_port]}" : "") +
          (@current_user_agent ?
              "ua#{@user_agents.index(@current_user_agent)}" : "")).to_sym
      puts driver_name.to_s
      #puts @user_agents.inspect
      puts 'capybara_drivers'
      puts registered_capybara_drivers.inspect
      puts @registered_drivers.inspect
      unless registered_capybara_drivers.include?(driver_name)
        puts "registering driver: #{driver_name}"
        Capybara.register_driver driver_name do |app|
          Capybara::Selenium::Driver.new(app, build_driver_options_from_config)
        end
        @registered_drivers << driver_name
      end
      Capybara.default_driver = driver_name
    end

    def build_driver_options_from_config
      driver_options = {browser: @config.headless_chromium[:browser] || :chrome}
      driver_options[:desired_capabilities] =
          Selenium::WebDriver::Remote::Capabilities.chrome(
              "chromeOptions" =>
                  merge_user_agent_with_chrome_options
          ) if @config.headless_chromium[:chromeOptions]
      driver_options[:args] = @config.headless_chromium[:args] if
          @config.headless_chromium[:args]
      driver_options
    end

    def merge_user_agent_with_chrome_options
      chrome_options = @config.headless_chromium[:chromeOptions]
      if @current_user_agent && chrome_options &&
          (chrome_options[:args] || chrome_options['args'])
        args_key = chrome_options[:args] ? :args : 'args'
        chrome_options[args_key].delete_if {|d| d.include?("user-agent=")}
        chrome_options[args_key] << "--user-agent=#{@current_user_agent}"
      end
      chrome_options
    end

    def registered_capybara_drivers
      Capybara.drivers.keys
    end
  end
end