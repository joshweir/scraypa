require "spec_helper"

module Scraypa
  describe TorProcessManager do
    it "should initialize with default overwritable parameters" do
      tpm = TorProcessManager.new
      expect(tpm.tor_port).to eq 9050
      expect(tpm.control_port).to eq 50500

    end

    describe "#start" do
      it "should validate that the tor port and control ports are open" do

      end

      it "should check if a valid Tor god process is not running for the current " +
             "Tor instance settings, then spawn it" do

      end
    end

    describe "#stop" do
      it "should check if any Tor god process is running spawned by the current " +
             "process, then issue god stop orders and kill it" do

      end
    end

    describe "#stop_obsolete_processes" do
      it "should check if any Tor god processes " +
             "are running associated to Scraypa instances that no longer exist " +
             "then issue god stop orders and kill the god process as it is stale" do

      end
    end
  end
end
