module Scraypa
  class Configuration
    attr_accessor :use_capybara, :tor, :driver, :driver_options
    attr_reader :tor_options

    def initialize
      @use_capybara = nil
      @tor = nil
      @valid_tor_options =
          [:tor_port, :control_port, :pid_dir, :log_dir,
           :tor_data_dir, :tor_new_circuit_period, :max_tor_memory_usage,
           :max_tor_memory_usage_times, :max_tor_cpu_percentage,
           :max_tor_cpu_percentage_times]
      @tor_options = {
          tor_port: 9050,
          control_port: 50500,
          pid_dir: '/tmp',
          log_dir: '/tmp',
          tor_data_dir: '/tmp/tor_data/',
          tor_new_circuit_period: 60,
          max_tor_memory_usage: 200.megabytes,
          max_tor_memory_usage_times: [3,5],
          max_tor_cpu_percentage: 10.percent,
          max_tor_cpu_percentage_times: [3,5]
      }
      @driver = nil
      @driver_options = nil
    end

    def tor_options=(arg={})
      validate_tor_options arg
      @tor_options = @tor_options.merge(arg || {})
    end

    private

    def validate_tor_options arg
      return unless arg
      raise 'tor_options must be a hash' unless arg.is_a?(Hash)
      arg.each do |k,v|
        raise "#{k} is not a valid key to be used with " +
                  "tor_options. Expected: " +
                  "#{@valid_tor_options.join(', ')}" unless
            @valid_tor_options.include?(k)
      end
    end
  end
end