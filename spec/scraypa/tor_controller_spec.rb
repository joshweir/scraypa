require "spec_helper"

WebMock.allow_net_connect!(allow_localhost: true)

module Scraypa
  describe TorController do
    let(:tor_process_manager) { TorProcessManager.new tor_port: 9350, control_port: 53500 }
    let(:tor_controller) { TorController.new tor_process_manager: tor_process_manager }

    before :all do
      EyeManager.destroy
    end

    after :all do
      EyeManager.destroy
    end

    describe "#get_ip" do
      it "raises exception if Tor is not available on specified port" do
        expect{tor_controller.get_ip}.to raise_error /Tor is not running on port 9350/
      end

      it "gets the current ip" do
        tor_process_manager.start
        expect(tor_controller.get_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end
    end

    describe "#get_new_ip" do
      it "raises exception if Tor is not available on specified port" do
        tor_process_manager.stop
        expect{tor_controller.get_new_ip}.to raise_error /Tor is not running on port 9350/
      end

      it "gets a new ip" do
        tor_process_manager.start
        previous_ip = tor_controller.get_ip
        expect(previous_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        new_ip = tor_controller.get_new_ip
        expect(new_ip).not_to eq previous_ip
        expect(new_ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      end
    end
  end
end
