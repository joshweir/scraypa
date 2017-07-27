require "scraypa/version"
require "scraypa/configuration"
require "scraypa/visit_interface"
require "scraypa/visit_rest_client"
require "scraypa/visit_capabara"
require "scraypa/visit_factory"
require "scraypa/response"

module Scraypa
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.visit params={}
    Scraypa::VisitFactory.build(Scraypa.configuration).execute(params)
  end

  #TODO: configuration includes:
  # javascript_enabled - means capybara will be used and capybara can be used after visit
  # by default will use rest client
  # tor: {torBasePort, torControlPort} - tor will be used for the current process
  # disguise: {disguise options here}
  #TODO: possible to change configuration half way through process?
  #TODO: the response object needs to include the restclient response for rest client
  #for capybara need to ensure that the page object and basic capybara page response
  #and interaction stuff works here

end
