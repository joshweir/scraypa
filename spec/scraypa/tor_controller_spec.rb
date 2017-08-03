require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

module Scraypa
  describe TorController do
    before :all do
      EyeManager.destroy
    end

    after :all do
      EyeManager.destroy
    end

    it "should initialize with default parameters" do
      tc = TorController.new
      expect(tc.settings[:tor_port]).to eq 9050
      expect(tc.settings[:control_port]).to eq 50500
    end

    it "should initialize with default parameters that can be overwritten" do
      tc = TorController.new tor_port: 9150, control_port: 51500
      expect(tc.settings[:tor_port]).to eq 9150
      expect(tc.settings[:control_port]).to eq 51500
    end

    describe "#get_ip" do
      it "should raise exception if Tor is not available on specified port" do
        tc = TorController.new tor_port: 9350, control_port: 53500
        expect{tc.get_ip}.to raise_error /Tor is not running on port 9350/
      end

      it "should get the current ip" do
        start_tor tor_port: 9350, control_port: 53500
        tc = TorController.new tor_port: 9350, control_port: 53500
        expect(tc.get_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        stop_tor
      end
    end

    describe "#get_new_ip" do
      it "should raise exception if Tor is not available on specified port" do
        tc = TorController.new tor_port: 9350, control_port: 53500
        expect{tc.get_new_ip}.to raise_error /Tor is not running on port 9350/
      end

      it "should get a new ip" do
        start_tor tor_port: 9350, control_port: 53500
        tc = TorController.new tor_port: 9350, control_port: 53500
        previous_ip = tc.get_ip
        expect(previous_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        new_ip = tc.get_new_ip
        expect(new_ip).not_to eq previous_ip
        expect(new_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        stop_tor
      end
    end

    def start_tor params={}
      @tpm && @tpm.stop
      Dir.glob("/tmp/scraypa.tor.9350.*.eye.rb").each{|file|
        File.delete(file)}
      @tpm = TorProcessManager.new(tor_port: params[:tor_port],
                            control_port: params[:control_port])
      @tpm.start
    end

    def stop_tor
      @tpm && @tpm.stop
    end
  end
end
