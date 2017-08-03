require 'socksify'
require 'terminator'
require 'tor'

module Scraypa
  class TorController
    #Socksify::debug = true

    attr_accessor :settings, :ip

    def initialize params={}
      @settings = {}
      @settings[:tor_port] = params.fetch(:tor_port, 9050)
      @settings[:control_port] = params.fetch(:control_port, 50500)
      @ip = nil
      @endpoint_change_attempts = 5
    end

    def get_ip
      ensure_tor_is_available
      @ip = tor_endpoint_ip
    end

    def get_new_ip
      ensure_tor_is_available
      get_new_tor_endpoint_ip
    end

    def proxy
      enable_socks_server
      yield.tap { disable_socks_server }
    end

    private

    def ensure_tor_is_available
      raise "Cannot proceed, Tor is not running on port " +
                "#{@settings[:tor_port]}" unless
          TorProcessManager.tor_running_on_port? @settings[:tor_port]
    end

    def tor_endpoint_ip
      ip = nil
      proxy do
        ip = RestClient::Request
            .execute(method: :get,
                     url: 'http://bot.whatismyipaddress.com')
            .to_str
      end
      ip
    rescue Exception => ex
      puts "Error getting ip: #{ex.to_s}"
      return nil
    end

    def get_new_tor_endpoint_ip
      @endpoint_change_attempts.times do |i|
        tor_switch_endpoint
        new_ip = tor_endpoint_ip
        if (new_ip.to_s.length > 0 && new_ip != @ip)
          @ip = new_ip
          break
        end
      end
      @ip
    end

    def tor_switch_endpoint
      disable_socks_server
      Tor::Controller.connect(:port => @settings[:control_port]) do |tor|
        tor.authenticate("")
        tor.signal("newnym")
        sleep 10
      end
    end

    def enable_socks_server
      TCPSocket::socks_server = "127.0.0.1"
      TCPSocket::socks_port = @settings[:tor_port]
    end

    def disable_socks_server
      TCPSocket::socks_server = nil
      TCPSocket::socks_port = nil
    end
  end
end