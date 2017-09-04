module Scraypa
  include Capybara::DSL

  class DriverResetter
    attr_accessor :requests_since_last_reset

    def initialize every_n_requests
      @every_n_requests = every_n_requests
      @requests_since_last_reset = 0
    end

    def reset_if_nth_request
      @requests_since_last_reset += 1
      if @requests_since_last_reset >= @every_n_requests
        Capybara.current_driver == :poltergeist ?
          reset_poltergeist_driver : reset_headless_chromium_driver
        @requests_since_last_reset = 0
      end
    end

    private

    def reset_poltergeist_driver
      Capybara.reset_sessions!
      Capybara.send(:session_pool).each do |session_name, session|
        session.driver.restart if session_name.include?('poltergeist')
      end
    end

    def reset_headless_chromium_driver
      Capybara.reset_sessions!
      Capybara.send(:session_pool).each do |session_name, session|
        session.driver.quit if session_name.include?('headless_chromium')
      end
    end
  end
end