module Scraypa
  class VisitFactory
    def self.build(*args)
      if args[0] && args[0].use_capybara
        if args[0].driver == :poltergeist
          VisitCapybaraPoltergeist.new(*args)
        elsif args[0].driver == :headless_chromium
          VisitCapybaraHeadlessChromium.new(*args)
        end
      else
        VisitRestClient.new(*args)
      end

      args[0] && args[0].use_capybara ?
         :

    end
  end
end