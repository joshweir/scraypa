require 'socksify'
#require 'net/telnet'
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
      TCPSocket::socks_server = "127.0.0.1"
      TCPSocket::socks_port = @settings[:tor_port]
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

    private

    def ensure_tor_is_available
      raise "Cannot proceed, Tor is not running on port " +
                "#{@settings[:tor_port]}" unless
          TorProcessManager.tor_running_on_port? @settings[:tor_port]
    end

    def tor_endpoint_ip
      RestClient::Request
          .execute(method: :get,
                   url: 'http://bot.whatismyipaddress.com')
          .to_str
    rescue Exception => ex
      puts "Error getting ip: #{ex.to_s}"
      return nil
    end

    def get_new_tor_endpoint_ip
      @endpoint_change_attempts.times do |i|
        tor_switch_endpoint
        sleep 10
        new_ip = tor_endpoint_ip
        if (new_ip.to_s.length > 0 && new_ip != @ip)
          @ip = new_ip
          break
        end
      end
      @ip
    end

    def tor_switch_endpoint
      #Tor::Controller.connect(:port => @settings[:control_port]) do |tor|
      #  tor.authenticate("password")
      #  tor.signal("newnym")
      #  sleep 10
      #end
      telnet_pid = nil
      begin
        Terminator.terminate :seconds => 20 do
          #cmd = "bundle exec ruby -e \"require 'net/telnet'\" " +
          #      " -e \"@tor_telnet = Net::Telnet::new('Host' => '127.0.0.1', 'Port' => '#{@settings[:control_port]}',
          #        'Timeout' => 10, 'Prompt' => /250 OK\n/)\" " +
          #      " -e \"@tor_telnet.cmd('AUTHENTICATE """"') { |c| print c; throw 'Cannot authenticate to Tor' if c != '250 OK\n' }\"" +
          #      " -e \"@tor_telnet.cmd('signal NEWNYM') { |c| print c; throw 'Cannot switch Tor to new route' if c != '250 OK\n' }\"" +
          #      " -e \"@tor_telnet.close\""
          #puts "running: #{cmd}"
          cmd = "bundle exec ruby -e \"require 'tor'\" -e " +
              "\"Tor::Controller.connect(:port => #{@settings[:control_port]})" +
              "{|tor| tor.authenticate(''); tor.signal('newnym')}\""
          telnet_pid = Process.spawn(cmd)
          Process.wait telnet_pid
        end
      rescue Terminator.error
        puts 'Telnet process to switch Tor endpoint timed out!'
        ProcessHelper.kill_process(telnet_pid) if telnet_pid
      end
    end
  end
end