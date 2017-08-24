require 'rest-client'

module Scraypa
  class Throttle
    attr_accessor :last_request_time
    attr_reader :seconds

    def initialize params={}
      @seconds = params.fetch(:seconds, nil)
    end

    def throttle
      @seconds && @last_request_time ? (@seconds.is_a?(Hash) ?
          sleep_from_last_request_time_for(
              Random.new.rand(@seconds[:from]..@seconds[:to])) :
          sleep_from_last_request_time_for(@seconds)) : nil
    end

    private

    def sleep_from_last_request_time_for seconds
      sleep_time = @last_request_time ?
          seconds - (Time.now - @last_request_time) : seconds
      sleep(sleep_time) if sleep_time > 0
    end
  end
end