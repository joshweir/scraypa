require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs'

module Scraypa
  include Capybara::DSL

  class VisitCapybaraPoltergeist < VisitInterface
    def initialize params={}
      super(params)
      @config = params[:config]
      @tor_proxy = params[:tor_proxy]
      @driver_resetter = params[:driver_resetter]
      @user_agent_retriever = params[:user_agent_retriever]
      setup_driver
      @current_user_agent = nil
    end

    def execute params={}
      @config.tor && @tor_proxy ?
        visit_get_response_through_tor(params) :
        visit_get_response(params)
    end

    private

    def visit_get_response_through_tor params={}
      @tor_proxy.proxy do
        return visit_get_response params
      end
    end

    def visit_get_response params={}
      update_user_agent_if_changed
      Capybara.visit params[:url]
      @driver_resetter.reset_if_nth_request if @driver_resetter
      Capybara.page
    end

    def update_user_agent_if_changed
      if @user_agent_retriever
        new_user_agent = @user_agent_retriever.user_agent
        if @current_user_agent != new_user_agent
          @current_user_agent = new_user_agent
          Capybara.page.driver.add_headers(
              "User-Agent" => @current_user_agent)
        end
      end
    end

    def setup_driver
      case @config.driver
        when :poltergeist
          setup_poltergeist_driver
        when :poltergeist_billy
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
  end
end