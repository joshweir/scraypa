module Scraypa
  class TorProcessManager
    attr_accessor :settings

    def initialize params={}
      @settings = {}
      @settings[:tor_port] = params.fetch(:tor_port, 9050)
      @settings[:control_port] = params.fetch(:control_port, 50500)
      @settings[:pid_dir] = params.fetch(:pid_dir, '/tmp'.freeze)
      @settings[:log_dir] = params.fetch(:log_dir, '/tmp'.freeze)
      @settings[:tor_data_dir] = params.fetch(:tor_data_dir, "/tmp/tor_data/")
      @settings[:tor_new_circuit_period] = params.fetch(:tor_new_circuit_period, 60)
      @settings[:max_tor_memory_usage] = params.fetch(:max_tor_memory_usage, 200.megabytes)
      @settings[:max_tor_memory_usage_times] = params.fetch(
          :max_tor_memory_usage_times, [3, 5])
      @settings[:max_tor_cpu_percentage] = params.fetch(:max_tor_cpu_percentage, 10.percent)
      @settings[:max_tor_cpu_percentage_times] = params.fetch(
          :max_tor_cpu_percentage_times, [3, 5])
      @settings[:god_tor_config_template] =
          params.fetch(:god_tor_config_template,
            File.join(File.dirname(__dir__),'scraypa/god/tor.template.god.rb'))
      @settings[:parent_pid] = Process.pid
    end

    def start
      start_god if tor_ports_are_open?
    end

    private

    def tor_ports_are_open?
      tor_port_is_open? &&
      control_port_is_open?
    end

    def tor_port_is_open?
      raise "Cannot spawn Tor process as port " +
                "#{@settings[:tor_port]} is in use" unless
          ProcessHelper.port_is_open?(@settings[:tor_port])
      true
    end

    def control_port_is_open?
      raise "Cannot spawn Tor process as control port " +
                "#{@settings[:control_port]} is in use" unless
          ProcessHelper.port_is_open?(@settings[:control_port])
      true
    end

    def start_god
      god_tor_command
    end

    def god_config_filename
      "scraypa.tor.#{@settings[:tor_port]}.#{Process.pid}.god.rb"
    end
  end
end