require 'rest-client'

module Scraypa
  class Throttle
    def initialize params={}
      @seconds = params.fetch(:seconds, nil)
    end

    def throttle
      @seconds ? (@seconds.is_a?(Hash) ?
          sleep(Random.new.rand(@seconds[:from]..@seconds[:to])) :
          sleep(@seconds)) : nil
    end
  end
end