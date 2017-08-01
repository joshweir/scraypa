require 'fileutils'

opts = {}
opts[:parent_id] = ARGV[0]
opts[:tor_port] = ARGV[1] || 9050
opts[:control_port] = ARGV[2] || 50500
opts[:pid_dir] = ARGV[3] || "/tmp"
opts[:log_dir] = ARGV[4] || "/tmp"
opts[:tor_data_dir] = ARGV[5] || "/tmp/tor_data/"
opts[:tor_new_circuit_period] = ARGV[6] || 60
opts[:max_tor_memory_usage_mb] = ARGV[7] || 200
opts[:max_tor_cpu_percentage] = ARGV[8] || 10
opts[:max_tor_memory_usage_times] = [3,5]
opts[:max_tor_cpu_percentage_times] = [3,5]

raise 'parent_id is required' unless opts[:parent_id]

module God
  module Behaviors
    class WaitBehavior < Behavior
      attr_accessor :delay

      def after_start
        sleep delay.to_i if delay.to_i > 0
      end
    end
  end
end

God.watch do |w|
  the_name = "scraypa-tor-#{opts[:tor_port]}-#{opts[:parent_id]}"
  w.name = the_name
  w.start = "tor --SocksPort #{opts[:tor_port]} --ControlPort #{opts[:control_port]} " +
      "--CookieAuthentication 0 --HashedControlPassword \"16:3E49D6163CCA95F2605B339" +
      "E07F753C8F567DE4200E33FDF4CC6B84E44\" --NewCircuitPeriod " +
      "#{opts[:tor_new_circuit_period]} --DataDirectory " +
      File.join(opts[:tor_data_dir], opts[:tor_port]) + " --Log \"notice syslog\""
  #w.pid_file = File.join(opts[:pid_dir], "#{the_name}.pid")
  #w.log = File.join(opts[:log_dir], "#{the_name}.log") if opts[:log_dir].length > 0
  w.keepalive

  # clean pid files before start if necessary
  w.behavior(:clean_pid_file)
  w.behavior(:wait_behavior) do |b|
    b.delay = 10
  end

=begin
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    sleep 5
    on.condition(:process_running) do |c|
      c.interval = 5
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.interval = 20
      c.running = true
    end

    # failsafe
    on.condition(:tries) do |c|
      c.interval = 20
      c.times = 5
      c.transition = :start
    end
  end

  # start if process is not running
  #w.transition(:up, :start) do |on|
  #  on.condition(:process_exits) do |c|
  #    c.interval = 20
  #  end
  #end

  # restart if memory or cpu is too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 20
      c.above = opts[:max_tor_memory_usage_mb]
      c.times = opts[:max_tor_memory_usage_times]
    end

    on.condition(:cpu_usage) do |c|
      c.interval = 10
      c.above = opts[:max_tor_cpu_percentage]
      c.times = opts[:max_tor_cpu_percentage_times]
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
    end
  end
=end
end