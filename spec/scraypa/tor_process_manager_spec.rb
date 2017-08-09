require "spec_helper"

module Scraypa
  describe TorProcessManager do
    after :all do
      EyeManager.destroy
    end

    context 'when initialized with default params' do
      before :all do
        @tpm = TorProcessManager.new
      end

      it "initializes with default parameters" do
        expect(@tpm.settings[:tor_port]).to eq 9050
        expect(@tpm.settings[:control_port]).to eq 50500
        expect(@tpm.settings[:pid_dir]).to eq '/tmp'
        expect(@tpm.settings[:log_dir]).to eq '/tmp'
        expect(@tpm.settings[:tor_data_dir]).to be_nil
        expect(@tpm.settings[:tor_new_circuit_period]).to eq 60
        expect(@tpm.settings[:max_tor_memory_usage_mb]).to eq 200
        expect(@tpm.settings[:max_tor_cpu_percentage]).to eq 10
        expect(@tpm.settings[:eye_tor_config_template])
            .to eq File.join(File.expand_path('../../..', __FILE__),
                             'lib/scraypa/eye/tor.template.eye.rb')
        expect(@tpm.settings[:control_password].length).to eq 12
        expect(@tpm.settings[:hashed_control_password][0..2])
            .to eq '16:'
        expect(@tpm.settings[:tor_log_switch]).to be_nil
        expect(@tpm.settings[:tor_logging]).to be_nil
        expect(@tpm.settings[:eye_logging]).to be_nil
        expect(@tpm.settings[:dont_remove_tor_config]).to be_nil
      end

      it "generates a random control_password (between 8 and 16 chars) " +
             "and a hash_control_password when none specified" do
        expect(@tpm.settings[:control_password].length).to eq 12
        expect(@tpm.settings[:hashed_control_password][0..2])
            .to eq '16:'
      end

      describe "#start" do
        before :all do
          EyeManager.destroy
          cleanup_related_files @tpm.settings
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

        it "validates that the tor control port is open" do
          expect(@in_use_control_port).to eq 50700
          expect(@tcp_server_50700.class).to eq TCPServer
          expect{TorProcessManager.new(tor_port: 52700,
                                       control_port: @in_use_control_port).start}
              .to raise_error(/Cannot spawn Tor process as control port 50700 is in use/)
        end

        it "validates that the tor port is open" do
          expect{TorProcessManager.new(tor_port: @in_use_tor_port,
                                       control_port: 53700).start}
              .to raise_error(/Cannot spawn Tor process as port 9250 is in use/)
        end

        context 'when spawning the tor process' do
          before :all do
            EyeManager.destroy
            @tpm.start
          end

          after :all do
            @tpm.stop
          end

          it "creates a tor eye config file for the current Tor instance settings" do
            expect(read_tor_process_manager_config(@tpm.settings))
                .to match(/tor --SocksPort #{@tpm.settings[:tor_port]}/)
          end

          it "starts tor using the hashed_control_password" do
            expect(tor_process_status(@tpm.settings)).to eq "up"
            expect(tor_process_listing(@tpm.settings))
                .to match /HashedControlPassword 16:/
          end

          it "does not do any tor logging or eye logging" do
            expect(File.exists?(
                "/tmp/scraypa-tor-#{@tpm.settings[:tor_port]}-#{@tpm.settings[:parent_pid]}.log"))
                .to be_falsey
            expect(File.exists?("/tmp/scraypa.eye.log"))
                .to be_falsey
          end
        end
      end
    end

    context 'when initialized with user params' do
      before :all do
        @tpm = TorProcessManager.new control_password: 'test_password',
                                     tor_port: 9350,
                                     control_port: 53700,
                                     tor_logging: true,
                                     eye_logging: true,
                                     tor_data_dir: '/tmp/tor_data',
                                     tor_log_switch: 'notice syslog'
      end

      it "should generate a hashed_control_password based on user specified control_password" do
        expect(@tpm.settings[:control_password]).to eq 'test_password'
        expect(@tpm.settings[:hashed_control_password][0..2])
            .to eq '16:'
      end

      describe "#start" do
        after :all do
          EyeManager.destroy
        end

        context 'when spawning the tor process' do
          before :all do
            EyeManager.destroy
            cleanup_related_files @tpm.settings
            @tpm.start
          end

          after :all do
            @tpm.stop
          end

          it "creates a tor eye config file for the current Tor instance settings" do
            expect(read_tor_process_manager_config(@tpm.settings))
                .to match(/tor --SocksPort #{@tpm.settings[:tor_port]}/)
          end

          it "does tor logging when tor_logging is true" do
            expect(tor_process_status(@tpm.settings)).to eq "up"
            expect(File.exists?(
                "/tmp/scraypa-tor-#{@tpm.settings[:tor_port]}-#{@tpm.settings[:parent_pid]}.log"))
                .to be_truthy
          end

          it "does eye logging when eye_logging is true" do
            expect(File.exists?("/tmp/scraypa.eye.log"))
                .to be_truthy
          end

          it "uses the :tor_data_dir if passed as input" do
            expect(tor_process_listing(@tpm.settings))
                .to match /DataDirectory \/tmp\/tor_data\/9350/
          end

          it "uses the :tor_log_switch if passed as input" do
            expect(tor_process_listing(@tpm.settings))
                .to match /Log notice syslog/
          end
        end
      end
    end

    describe "#stop" do
      before :all do
        @tpm = TorProcessManager.new
        @tpm_keep_config = TorProcessManager.new dont_remove_tor_config: true,
                                                 tor_port: 9450,
                                                 control_port: 53500
        cleanup_related_files @tpm.settings
        cleanup_related_files @tpm_keep_config.settings
      end

      after :all do
        EyeManager.destroy
      end

      it "stops the tor process" do
        @tpm.start
        expect(tor_process_status(@tpm.settings)).to eq "up"
        @tpm.stop
        expect(tor_process_status(@tpm.settings)).to_not match /up|starting/
      end

      it "removes the eye tor config" do
        expect(File.exists?("/tmp/scraypa.tor.#{@tpm.settings[:tor_port]}." +
                                "#{@tpm_keep_config.settings[:parent_pid]}.eye.rb"))
            .to be_falsey
      end

      it "leaves the eye tor config if setting :dont_remove_tor_config is true" do
        @tpm_keep_config.start
        @tpm_keep_config.stop
        expect(File.exists?("/tmp/scraypa.tor.#{@tpm_keep_config.settings[:tor_port]}." +
                                "#{@tpm_keep_config.settings[:parent_pid]}.eye.rb"))
            .to be_truthy
      end
    end

    describe ".stop_obsolete_processes" do
      let(:tpm) { TorProcessManager.new }

      before do
        cleanup_related_files tpm.settings
      end

      after do
        EyeManager.destroy
      end

      it "checks if any Tor eye processes " +
             "are running associated to Scraypa instances that no longer exist " +
             "then issue eye stop orders and kill the eye process as it is stale" do
        #add dummy process to act as obsolete
        EyeManager.start config: 'spec/scraypa/eye.test.rb',
                         application: 'scraypa-tor-9450-12345'
        tpm.start
        expect(tor_process_status(tpm.settings)).to eq "up"
        expect(tor_process_status(tor_port: 9450, parent_pid: 12345)).to eq "up"
        TorProcessManager.stop_obsolete_processes
        expect(tor_process_status(tpm.settings)).to eq "up"
        expect(tor_process_status(tor_port: 9450, parent_pid: 12345)).to_not match /up|starting/
      end
    end

    describe ".tor_running_on?" do
      before :all do
        @tpm = TorProcessManager.new
        cleanup_related_files @tpm.settings
      end

      after :all do
        EyeManager.destroy
      end

      it "is true if Tor is running on port" do
        @tpm.start
        expect(tor_process_status(@tpm.settings)).to eq "up"
        expect(TorProcessManager.tor_running_on?(port: @tpm.settings[:tor_port]))
            .to be_truthy
        @tpm.stop
      end

      it "is not true if Tor is not running on port" do
        expect(TorProcessManager.tor_running_on?(port: @tpm.settings[:tor_port]))
            .to be_falsey
      end

      it "is true if Tor is running on port and current pid is tor parent_pid" do
        @tpm.start
        expect(tor_process_status(@tpm.settings)).to eq "up"
        expect(TorProcessManager.tor_running_on?(port: @tpm.settings[:tor_port],
                      parent_pid: @tpm.settings[:parent_pid]))
            .to be_truthy
        expect(TorProcessManager.tor_running_on?(port: @tpm.settings[:tor_port],
                                                 parent_pid: @tpm.settings[:parent_pid] + 1))
            .to be_falsey
        @tpm.stop
      end
    end
  end
end
