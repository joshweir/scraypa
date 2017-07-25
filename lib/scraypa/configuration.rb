module Scraypa
  class Configuration
    attr_accessor :use_javascript, :tor

    def initialize
      @use_javascript = nil
      @tor = nil
    end
  end
end