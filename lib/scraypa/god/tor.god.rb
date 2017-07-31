require 'slop'

opts = Slop.parse do |o|
  o.separator 'eg usage:'
  o.separator 'god -c ./tor.god.rb --tor_port 9150 --control_port 51500'
  o.integer '-t', '--tor_port', 'The tor port', default: 9050
  o.integer '-r', '--control_port', 'The tor control port', default: 50500
  o.string '-p', '--pid_dir', 'The directory to store god pid files', default: '/tmp'
  o.string '-l', '--log_dir', 'The directory to store god log files', default: '/tmp'
  o.string '-d', '--tor_data_dir', 'The directory to store tor data files',
           default: '/tmp/tor_data/'
  o.integer '-i', '--tor_new_circuit_period',
            'The tor new circuit period (seconds)', default: 60
  o.integer '-m', '--max_tor_memory_usage',
            'The max tor memory usage before god will restart it', default: 200.megabytes
  o.array '-n', '--max_tor_memory_usage_times',
          'The times max_tor_memory_usage threshold must be triggered for god to restart tor',
          default: [3,5], delimiter: ','
  o.integer '-u', '--max_tor_cpu_percentage',
            'The max tor cpu percentage before god will restart it', default: 10.percent
  o.array '-w', '--max_tor_cpu_percentage_times',
          'The times max_tor_cpu_percentage threshold must be triggered for god to restart tor',
          default: [3,5], delimiter: ','
  o.integer '-x', '--parent_pid', 'The calling process pid'
  o.on '-v', '--version' do
    puts Scraypa::VERSION.to_s
    exit
  end
  o.on '--help' do
    puts o
    exit
  end
end

raise '--parent_pid is required' unless opts[:parent_pid]

God.watch do |w|
  the_name = "scraypa-tor-#{opts[:tor_port]}-#{opts[:parent_pid]}"
  w.name = the_name
  w.start = "tor --SocksPort #{opts[:tor_port]} --ControlPort #{opts[:control_port]} " +
      "--CookieAuthentication 0 --HashedControlPassword \"16:3E49D6163CCA95F2605B339" +
      "E07F753C8F567DE4200E33FDF4CC6B84E44\" --NewCircuitPeriod " +
      "#{opts[:tor_new_circuit_period]} --DataDirectory " +
      File.join(opts[:tor_data_dir], opts[:tor_port]) + " --Log \"notice syslog\""
  w.pid_file = File.join(opts[:pid_dir], "#{the_name}.pid")
  w.log_file = File.join(opts[:log_dir], "#{the_name}.log") if opts[:log_dir].length > 0

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
      c.above = opts[:max_tor_memory_usage]
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
end