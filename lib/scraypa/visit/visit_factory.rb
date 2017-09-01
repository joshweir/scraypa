module Scraypa
  class VisitFactory
    def self.build(*args)
      if args[0] && args[0].use_capybara
        if [:poltergeist, :poltergeist_billy].include? args[0].driver
          VisitCapybaraPoltergeist.new(*args)
        elsif args[0].driver == :headless_chromium
          VisitCapybaraHeadlessChromium.new(*args)
        else
          raise CapybaraDriverUnsupported,
                "Currently no support for capybara driver: #{args[0].driver}"
        end
      else
        VisitRestClient.new(*args)
      end
    end
  end
end