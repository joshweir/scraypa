require "spec_helper"

module Scraypa
  describe TorProcessManager do
    after :all do
      EyeManager.destroy
    end

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
          .to eq File.join(File.expand_path('../../..', __FILE__),
                           'lib/scraypa/eye/tor.template.eye.rb')
      expect(tpm.settings[:control_password].length).to eq 12
      expect(tpm.settings[:hashed_control_password][0..2])
          .to eq '16:'
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
          .to eq File.join(File.expand_path('../../..', __FILE__),
                           'lib/scraypa/eye/tor.template.eye.rb')
    end

    it "should generate a random control_password (between 8 and 16 chars) " +
        "and a hash_control_password when none specified" do
      tpm = TorProcessManager.new
      expect(tpm.settings[:control_password].length).to eq 12
      expect(tpm.settings[:hashed_control_password][0..2])
          .to eq '16:'
    end

    it "should generate a hashed_control_password based on user specified control_password" do
      test_password = 'testpassword'
      tpm = TorProcessManager.new control_password: test_password
      expect(tpm.settings[:control_password]).to eq test_password
      expect(tpm.settings[:hashed_control_password][0..2])
          .to eq '16:'
    end

    describe "#start" do
      before :all do
        EyeManager.destroy
        @in_use_control_port = 50700
        @in_use_tor_port = 9250
        @tcp_server_50700 = TCPServer.new('127.0.0.1', 50700)
        @tcp_server_9250 = TCPServer.new('127.0.0.1',9250)
      end

      after :all do
        @tcp_server_50700.close
        @tcp_server_9250.close
        EyeManager.destroy
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

      describe "spawn the tor process" do
        after :all do
          EyeManager.destroy
        end

        it "should create a tor eye config file for the current Tor instance settings" do
          Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
            File.delete(file)}
          tpm = TorProcessManager.new(tor_port: 9350,
                                      control_port: 53700)
          tpm.start
          contents = ''
          Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
            contents = File.read(file); break;}
          expect(contents).to match(/tor --SocksPort 9350/)
          tpm.stop
        end

        it "should start tor using the hashed_control_password" do
          Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
            File.delete(file)}
          tpm = TorProcessManager.new(tor_port: 9350,
                                      control_port: 53700)
          tpm.start
          expect(EyeManager.status(application: "scraypa-tor-9350-#{tpm.settings[:parent_pid]}",
                                   process: "tor")).to eq "up"
          expect(`ps -ef | grep tor | grep 9350 | grep 53700`)
              .to match /HashedControlPassword 16:/
          tpm.stop
        end
      end
    end

    describe "#stop" do
      it "should check if any Tor eye process is running spawned by the current " +
             "process, then issue eye stop orders and kill it" do
        Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
          File.delete(file)}
        @tpm = TorProcessManager.new(tor_port: 9350,
                                     control_port: 53700)
        @tpm.start
        expect(EyeManager.status(application: "scraypa-tor-9350-#{@tpm.settings[:parent_pid]}",
                                 process: "tor")).to eq "up"
        @tpm.stop
        expect(EyeManager.status(application: "scraypa-tor-9350-#{@tpm.settings[:parent_pid]}",
                                 process: "tor")).to_not match /up|starting/
        EyeManager.destroy
      end
    end

    describe ".stop_obsolete_processes" do
      it "should check if any Tor eye processes " +
             "are running associated to Scraypa instances that no longer exist " +
             "then issue eye stop orders and kill the eye process as it is stale" do
        #add dummy process to act as obsolete
        EyeManager.start config: 'spec/scraypa/eye.test.rb', application: 'scraypa-tor-9450-12345'
        Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
          File.delete(file)}
        @tpm = TorProcessManager.new(tor_port: 9350,
                                     control_port: 53700)
        @tpm.start
        expect(EyeManager.status(application: "scraypa-tor-9350-#{@tpm.settings[:parent_pid]}",
                                 process: "tor")).to eq "up"
        expect(EyeManager.status(application: "scraypa-tor-9450-12345",
                                 process: "tor")).to eq "up"
        TorProcessManager.stop_obsolete_processes
        expect(EyeManager.status(application: "scraypa-tor-9350-#{@tpm.settings[:parent_pid]}",
                                 process: "tor")).to eq "up"
        expect(EyeManager.status(application: "scraypa-tor-9450-12345",
                                 process: "tor")).to_not match /up|starting/
        EyeManager.destroy
      end
    end

    describe ".tor_running_on_port?" do
      it "should be true if Tor is running on port" do
        Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
          File.delete(file)}
        tpm = TorProcessManager.new(tor_port: 9350,
                                     control_port: 53700)
        tpm.start
        expect(EyeManager.status(application: "scraypa-tor-9350-#{tpm.settings[:parent_pid]}",
                                 process: "tor")).to eq "up"
        expect(TorProcessManager.tor_running_on_port?(9350)).to be_truthy
        tpm.stop
      end

      it "should not be true if Tor is not running on port" do
        expect(TorProcessManager.tor_running_on_port?(9350)).to be_falsey
      end
    end
  end
end
