require "spec_helper"

module Scraypa
  describe TorProcessManager do
    it "should initialize with default parameters" do
      tpm = TorProcessManager.new
      expect(tpm.settings[:tor_port]).to eq 9050
      expect(tpm.settings[:control_port]).to eq 50500
      expect(tpm.settings[:pid_dir]).to eq '/tmp'
      expect(tpm.settings[:log_dir]).to eq '/tmp'
      expect(tpm.settings[:tor_data_dir]).to eq '/tmp/tor_data/'
      expect(tpm.settings[:tor_new_circuit_period]).to eq 60
      expect(tpm.settings[:max_tor_memory_usage_mb]).to eq 200
      expect(tpm.settings[:max_tor_cpu_percentage]).to eq 10
      expect(tpm.settings[:eye_tor_config_template])
          .to eq File.join(File.dirname(__dir__),'lib/scraypa/eye/tor.template.eye.rb')
    end

    it "should initialize with default parameters that can be overwritten" do
      tpm = TorProcessManager.new tor_port: 9150, tor_data_dir: '/my/dir/'
      expect(tpm.settings[:tor_port]).to eq 9150
      expect(tpm.settings[:control_port]).to eq 50500
      expect(tpm.settings[:pid_dir]).to eq '/tmp'
      expect(tpm.settings[:log_dir]).to eq '/tmp'
      expect(tpm.settings[:tor_data_dir]).to eq '/my/dir/'
      expect(tpm.settings[:tor_new_circuit_period]).to eq 60
      expect(tpm.settings[:max_tor_memory_usage_mb]).to eq 200
      expect(tpm.settings[:max_tor_cpu_percentage]).to eq 10
      expect(tpm.settings[:eye_tor_config_template])
          .to eq File.join(File.dirname(__dir__),'lib/scraypa/eye/tor.template.eye.rb')
    end

    describe "#start" do
      before :all do
        @in_use_control_port = 50700
        @in_use_tor_port = 9250
        @tcp_server_50700 = TCPServer.new('127.0.0.1', 50700)
        @tcp_server_9250 = TCPServer.new('127.0.0.1',9250)
      end

      after :all do
        @tcp_server_50700.close
        @tcp_server_9250.close
        cleanup_eye_processes
      end

      def cleanup_eye_processes
        puts 'running cleanup processes!!!!!!!!!!!!'
      end

      it "should validate that the tor control port is open" do
        expect(@in_use_control_port).to eq 50700
        expect(@tcp_server_50700.class).to eq TCPServer
        expect{TorProcessManager.new(tor_port: 52700,
                                     control_port: @in_use_control_port).start}
            .to raise_error(/Cannot spawn Tor process as control port 50700 is in use/)
      end

      it "should validate that the tor port is open" do
        expect{TorProcessManager.new(tor_port: @in_use_tor_port,
                                     control_port: 53700).start}
            .to raise_error(/Cannot spawn Tor process as port 9250 is in use/)
      end

      it "should create a tor eye config file for the current Tor instance settings" do
        contents = ''
        Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
          File.delete(file)}
        TorProcessManager.new(tor_port: 9350,
                              control_port: 53700).start
        Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
          contents = File.read(file); break;}
        expect(contents).to match(/tor --SocksPort 9350/)
      end

      it "should spawn a Tor process for the current " +
             "Tor instance settings" do
        TorProcessManager.new(tor_port: 9350,
                              control_port: 53700).start
      end
    end

    #TODO: stop should issue the eye stop orders
    describe "#stop" do
      it "should check if any Tor eye process is running spawned by the current " +
             "process, then issue eye stop orders and kill it" do

      end
    end

    describe "#stop_obsolete_processes" do
      it "should check if any Tor eye processes " +
             "are running associated to Scraypa instances that no longer exist " +
             "then issue eye stop orders and kill the eye process as it is stale" do

      end
    end
  end
end
