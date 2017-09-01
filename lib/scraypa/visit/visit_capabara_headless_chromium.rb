module Scraypa
  include Capybara::DSL

  class VisitCapybaraHeadlessChromium < VisitInterface
    def initialize *args
      super(*args)
      @config = args[0]
      reset_and_setup_driver
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
      update_user_agent_if_changed if @has_visited
      @has_visited = true
      Capybara.visit params[:url]
      Capybara.page
    end

    def update_user_agent_if_changed
      if @config.user_agent_retriever
        new_user_agent = @config.user_agent_retriever.user_agent
        update_user_agent_and_setup_driver new_user_agent if
            @current_user_agent != new_user_agent
      end
    end

    def update_user_agent_and_setup_driver new_user_agent
      @current_user_agent = new_user_agent
      @user_agents << @current_user_agent unless
          @user_agents.include? @current_user_agent
      setup_headless_chromium_driver
    end

    def reset_and_setup_driver
      case @config.driver
        when :headless_chromium
          reset_headless_chromium_drivers
          update_user_agent_if_changed
          setup_headless_chromium_driver
        when :selenium_chrome_billy
          setup_billy_driver
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{@config.driver}"
      end
    end

    def reset_headless_chromium_drivers
      clear_capybara_session_pool
      Capybara.drivers.delete_if{true}
      @current_user_agent = nil
      @user_agents = []
    end

    def clear_capybara_session_pool
      Capybara.reset_sessions!
      Capybara.send(:session_pool).each do |session_name, session|
        session.driver.quit if session_name.include?('headless_chromium')
      end
      Capybara.send(:session_pool).delete_if{true}
    end

    def setup_billy_driver
      Capybara.javascript_driver = @config.driver
    end

    def setup_headless_chromium_driver
      driver_name = driver_name_from_config
      Capybara.register_driver driver_name do |app|
        Capybara::Selenium::Driver.new(app,
                                       build_driver_options_from_config)
      end unless Capybara.drivers.keys.include?(driver_name)
      Capybara.default_driver = driver_name
    end

    def driver_name_from_config
      (@config.driver.to_s +
          (@config.tor ? "tor#{@config.tor_options[:tor_port]}" : "") +
          (@current_user_agent ?
              "ua#{@user_agents.index(@current_user_agent)}" : "")).to_sym
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
  end
end