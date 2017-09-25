module Scraypa
  class VisitFactory
    def self.build(params={})
      if params[:config] && params[:config].use_capybara
        if [:poltergeist, :poltergeist_billy].include? params[:config].driver
          VisitCapybaraPoltergeist.new(params)
        elsif params[:config].driver == :headless_chromium
          VisitCapybaraHeadlessChromium.new(params)
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{params[:config].driver}"
        end
      else
        VisitRestClient.new(params)
      end
    end
  end
end