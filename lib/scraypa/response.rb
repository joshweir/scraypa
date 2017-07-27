module Scraypa
  class Response
    attr_accessor :native_response
    def initialize params={}
      @native_response = params.fetch(:native_response, nil)
    end
  end
end