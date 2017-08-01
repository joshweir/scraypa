require "spec_helper"

module Scraypa
  describe EyeManager do
=begin
TODO:
eye load config_file
eye start param

eye stop param

eye i -j
returns something like this:
{"subtree":[{"name":"test","type":"application","subtree":[{"name":"__default__","type":"group","subtree":[{"name":"sample","state":"unmonitored","type":"process","resources":{"memory":null,"cpu":null,"start_time":null,"pid":null},"state_changed_at":1501570056,"state_reason":"stop by user"}]}],"debug":null},{"name":"test2","type":"application","subtree":[{"name":"__default__","type":"group","subtree":[{"name":"sample","state":"up","type":"process","resources":{"memory":19062784,"cpu":0.0,"start_time":1501570046,"pid":11731},"state_changed_at":1501570049,"state_reason":"monitor by user"}]}],"debug":null}]}

destroy:
eye q -s

TODO: need a test that starts another app without config
then after stopping one of these, query each verify status on each

=end
    before :all do
      EyeManager.destroy
    end

    after :all do
      EyeManager.destroy
    end

    describe "#start" do
      it "should require the :config param" do
        expect{EyeManager.start process: 'sample'}
          .to raise_error /config is required/
      end

      it "should require the :application param" do
        expect{EyeManager.start config: 'spec/eye.test.rb'}
            .to raise_error /application is required/
      end

      it "should load an eye config and start eye" do
        EyeManager.start config: 'spec/eye.test.rb', application: 'test'
        sleep 0.5
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to match /up|starting/
      end
    end

    describe "#status" do
      it "should require the :process param" do
        expect{EyeManager.status application: 'test'}
            .to raise_error /process is required/
      end

      it "should return unknown if eye does not know about the " +
             "application, group and/or process" do
        expect(EyeManager.status(application: 'testunknown', process: 'sample'))
            .to eq 'unknown'
        expect(EyeManager.status(application: 'test', process: 'sampleunknown'))
            .to eq 'unknown'
      end

      it "should return the status" do
        EyeManager.destroy
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to eq 'unknown'
        EyeManager.start config: 'spec/eye.test.rb', application: 'test'
        sleep 0.5
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to match /up|starting/
      end
    end

    describe "#stop" do

    end

    describe "#destroy" do
      it "should stop eye" do
        EyeManager.start config: 'spec/eye.test.rb', application: 'test'
        sleep 0.5
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to match /up|starting/
        EyeManager.destroy
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to eq 'unknown'
      end
    end
  end
end
