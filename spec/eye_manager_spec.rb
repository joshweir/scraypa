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
{"subtree":[{"name":"test","type":"application",
"subtree":[{"name":"__default__","type":"group",
"subtree":[{"name":"sample","state":"unmonitored","type":"process","resources":{"memory":null,"cpu":null,"start_time":null,"pid":null},"state_changed_at":1501570056,"state_reason":"stop by user"}]}],"debug":null},{"name":"test2","type":"application","subtree":[{"name":"__default__","type":"group","subtree":[{"name":"sample","state":"up","type":"process","resources":{"memory":19062784,"cpu":0.0,"start_time":1501570046,"pid":11731},"state_changed_at":1501570049,"state_reason":"monitor by user"}]}],"debug":null}]}

destroy:
eye q -s

=end
    describe "#start" do
      it "should load an eye config (if provided) and start eye" do
        expect(EyeManager.status(application: 'test', process: 'sample'))
          .to eq 'unknown'
        EyeManager.start config: File.join(File.dirname(__dir__),
                                           'lib/scraypa/eye/eye.test.rb'),
                         application: 'test'
        sleep 1
        expect(EyeManager.status(application: 'test', process: 'sample'))
            .to eq 'up'
        EyeManager.destroy
      end
    end

    describe "#stop" do

    end

    describe "#status" do
      it "should require the :process param" do

      end

      it "should return unknown if eye does not know about the " +
             "application, group and/or process" do

      end

      it "should return the status" do

      end
    end

    describe "#destroy" do

    end
  end
end
