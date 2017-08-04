require 'eye'
require 'eyemanager'
require 'fileutils'
require 'securerandom'

module Scraypa
  class TorProcessManager
    attr_accessor :settings

    def initialize params={}
      @settings = {}
      @settings[:tor_port] = params.fetch(:tor_port, 9050)
      @settings[:control_port] = params.fetch(:control_port, 50500)
      @settings[:pid_dir] = params.fetch(:pid_dir, '/tmp'.freeze)
      @settings[:log_dir] = params.fetch(:log_dir, '/tmp'.freeze)
      @settings[:tor_data_dir] = params.fetch(:tor_data_dir, nil)
      @settings[:tor_new_circuit_period] = params.fetch(:tor_new_circuit_period, 60)
      @settings[:max_tor_memory_usage_mb] = params.fetch(:max_tor_memory_usage, 200)
      @settings[:max_tor_cpu_percentage] = params.fetch(:max_tor_cpu_percentage, 10)
      @settings[:eye_tor_config_template] =
          params.fetch(:eye_tor_config_template,
            File.join(File.dirname(__dir__),'scraypa/eye/tor.template.eye.rb'))
      @settings[:parent_pid] = Process.pid
      @settings[:control_password] = params.fetch(:control_password, random_password)
      @settings[:hashed_control_password] =
          tor_hash_password_from(@settings[:control_password])
    end

    def start
      prepare_tor_start_and_monitor if tor_ports_are_open?
    end

    def stop
      EyeManager.stop application: eye_app_name, process: 'tor'
      ensure_tor_is_down
    end

    class << self
      def stop_obsolete_processes
        (EyeManager.list_apps || []).each do |app|
          EyeManager.stop(application: app, process: 'tor') unless
              ProcessHelper.process_pid_running? pid_of_tor_eye_process(app)
        end
      end

      def tor_running_on_port? port
        is_running = false
        (EyeManager.list_apps || []).each do |app|
          if port_of_tor_eye_process(app) == port &&
             EyeManager.status(application: app,
                               process: 'tor') == 'up'
            is_running = true
            break
          end
        end
        is_running
      end

      private

      def pid_of_tor_eye_process app
        app.to_s.split('-').last
      end

      def port_of_tor_eye_process app
        app_name_split = app.to_s.split('-')
        app_name_split.length >= 3 ?
            app_name_split[2].to_i : nil
      end
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

    def prepare_tor_start_and_monitor
      build_eye_config_from_template
      make_dirs
      start_tor_and_monitor
    end

    def build_eye_config_from_template
      File.open(eye_config_filename, "w") do |file|
        file.puts read_eye_tor_config_template_and_substitute_keywords
      end
    end

    def eye_config_filename
      @eye_config_filename || File.join(@settings[:log_dir],
                "scraypa.tor.#{@settings[:tor_port]}.#{Process.pid}.eye.rb")
    end

    def eye_app_name
      @eye_app_name || "scraypa-tor-#{@settings[:tor_port]}-#{Process.pid}"
    end

    def read_eye_tor_config_template_and_substitute_keywords
      text = File.read(@settings[:eye_tor_config_template])
      eye_tor_config_template_substitution_keywords.each do |keyword|
        text = text.gsub(/\[\[\[#{keyword}\]\]\]/, @settings[keyword.to_sym].to_s)
      end
      text
    end

    def eye_tor_config_template_substitution_keywords
      remove_settings_that_are_not_eye_tor_config_template_keywords(
          @settings.keys.map(&:to_s))
    end

    def remove_settings_that_are_not_eye_tor_config_template_keywords keywords
      keywords - ['eye_tor_config_template', 'control_password']
    end

    def make_dirs
      [@settings[:log_dir], @settings[:pid_dir],
       @settings[:tor_data_dir]].each do |path|
        FileUtils.mkpath(path) if path && !File.exists?(path)
      end
    end

    def start_tor_and_monitor
      EyeManager.start config: eye_config_filename,
                       application: eye_app_name
      ensure_tor_is_up
    end

    def ensure_tor_is_up
      10.times do |i|
        break if
            EyeManager.status(
                application: eye_app_name,
                process: 'tor') == 'up'
        sleep 2
        raise "Tor didnt start up after 20 seconds! See log: " +
                  "#{File.join(@settings[:log_dir],
                               eye_app_name + ".log")}" if i >= 9
      end
    end

    def ensure_tor_is_down
      10.times do |i|
        break if
            EyeManager.status(
                application: eye_app_name,
                process: 'tor') != 'up'
        sleep 2
        raise "Tor didnt start stop after 20 seconds! See log: " +
                  "#{File.join(@settings[:log_dir],
                               eye_app_name + ".log")}" if i >= 9
      end
    end

    def random_password
      SecureRandom.random_number(36**12).to_s(36).rjust(12, "0")
    end

    def tor_hash_password_from password
      `tor --quiet --hash-password '#{password}'`.strip
    end
  end
end