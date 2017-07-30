PID_DIR = "[[[pid_dir]]]"
LOG_DIR = "[[[log_dir]]]"
TOR_DATA_DIR = "[[[tor_data_dir]]]"

God.watch do |w|
  the_name = "scraypa-tor-[[[tor_port]]]-[[[parent_pid]]]"
  w.name = the_name
  w.start = "tor --SocksPort [[[tor_port]]] --ControlPort [[[control_port]]] " +
      "--CookieAuthentication 0 --HashedControlPassword \"16:3E49D6163CCA95F2605B339" +
      "E07F753C8F567DE4200E33FDF4CC6B84E44\" --NewCircuitPeriod " +
      "[[[tor_new_circuit_period]]] --DataDirectory " +
      File.join(TOR_DATA_DIR, "[[[tor_port]]]") + " --Log \"notice syslog\""
  w.pid_file = File.join(PID_DIR, "#{the_name}.pid")
  w.log_file = File.join(LOG_DIR, "#{the_name}.log") if LOG_DIR.length > 0

  # clean pid files before start if necessary
  w.behavior(:clean_pid_file)

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits)
  end

  # restart if memory or cpu is too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 20
      c.above = [[[max_tor_memory_usage]]]
      c.times = [[[max_tor_memory_usage_times]]]
    end

    on.condition(:cpu_usage) do |c|
      c.interval = 10
      c.above = [[[max_tor_cpu_percentage]]]
      c.times = [[[max_tor_cpu_percentage_times]]]
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
end