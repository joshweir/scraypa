require 'eye'

# Adding application
Eye.application 'test2' do
  # All options inherits down to the config leafs.
  # except `env`, which merging down

  # uid "user_name" # run app as a user_name (optional) - available only on ruby >= 2.0
  # gid "group_name" # run app as a group_name (optional) - available only on ruby >= 2.0

  #working_dir File.expand_path(File.join(File.dirname(__FILE__), %w[ processes ]))
  stdall '/tmp/trash2.log' # stdout,err logs for processes by default
  #env 'APP_ENV' => 'production' # global env for each processes
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 30.seconds, below: 10, times: 3 # global check for all processes
  check :memory, every: 60.seconds, below: 200.megabytes, times: 3
  process :sample do
    pid_file '/tmp/2.pid' # pid_path will be expanded with the working_dir
    start_command "ruby -e \"loop{sleep 5}\""

    daemonize true
    #stdall 'sample1.log'
  end

=begin
  group 'samples' do
    chain grace: 5.seconds # chained start-restart with 5s interval, one by one.

  end
=end
end