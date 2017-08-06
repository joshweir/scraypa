require 'eye'

if %w(true 1).include?('[[[eye_logging]]]')
  Eye.config do
    logger File.join('[[[log_dir]]]', 'scraypa.eye.log')
  end
end

Eye.application 'scraypa-tor-[[[tor_port]]]-[[[parent_pid]]]' do
  stdall File.join('[[[log_dir]]]', 'scraypa-tor-[[[tor_port]]]-[[[parent_pid]]].log') if %w(true 1).include?('[[[tor_logging]]]')
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 30.seconds, below: [[[max_tor_cpu_percentage]]], times: 3
  check :memory, every: 60.seconds, below: [[[max_tor_memory_usage_mb]]].megabytes, times: 3
  process :tor do
    pid_file File.join('[[[log_dir]]]', 'scraypa-tor-[[[tor_port]]]-[[[parent_pid]]].pid')
    start_command "tor --SocksPort [[[tor_port]]] --ControlPort [[[control_port]]] " +
                      "--CookieAuthentication 0 --HashedControlPassword \"[[[hashed_control_password]]]\" --NewCircuitPeriod " +
                      "[[[tor_new_circuit_period]]] " +
                      ('[[[tor_data_dir]]]'.length > 0 ?
                          "--DataDirectory #{File.join('[[[tor_data_dir]]]',
                                                       '[[[tor_port]]]')} " :
                          "") +
                      ('[[[tor_log_switch]]]'.length > 0 ?
                          "--Log \"[[[tor_log_switch]]]\" " : "")
    daemonize true
  end
end