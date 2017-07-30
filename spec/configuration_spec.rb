require "spec_helper"

module Scraypa
  describe Configuration do
    describe "#use_capybara" do
      it "should have a default value of nil" do
        expect(Configuration.new.use_capybara).to be_nil
      end
    end

    describe "#use_capybara=" do
      it "can set value" do
        config = Configuration.new
        config.use_capybara = true
        expect(config.use_capybara).to be_truthy
      end
    end

    describe "#driver" do
      it "should have a default value of nil" do
        expect(Configuration.new.driver).to be_nil
      end
    end

    describe "#driver=" do
      it "can set value" do
        config = Configuration.new
        config.driver = :poltergeist
        expect(config.driver).to eq(:poltergeist)
      end
    end

    describe "#driver_options" do
      it "should have a default value of nil" do
        expect(Configuration.new.driver_options).to be_nil
      end
    end

    describe "#driver_options=" do
      it "can set value" do
        config = Configuration.new
        the_options = {
            :js_errors => false
        }
        config.driver_options = the_options
        expect(config.driver_options).to eq(the_options)
      end
    end

    describe "#tor" do
      it "should have a default value of nil" do
        expect(Configuration.new.tor).to be_nil
      end
    end

    describe "#tor=" do
      it "can set value" do
        config = Configuration.new
        config.tor = true
        expect(config.tor).to be_truthy
      end
    end

    describe "#tor_options" do
      it "should have a default value" do
        default_tor_options = {
            tor_port: 9050,
            control_port: 50500,
            pid_dir: '/tmp',
            log_dir: '/tmp',
            tor_data_dir: '/tmp/tor_data/',
            tor_new_circuit_period: 60,
            max_tor_memory_usage: 200.megabytes,
            max_tor_memory_usage_times: [3,5],
            max_tor_cpu_percentage: 10.percent,
            max_tor_cpu_percentage_times: [3,5]
        }
        expect(Configuration.new.tor_options).to eq(default_tor_options)
      end
    end

    describe "#tor_options=" do
      it "validates must be a hash but allows nil (just ignores nil)" do
        expect{Configuration.new.tor_options = "foo"}
            .to raise_error(/tor_options must be a hash/)
        conf = Configuration.new
        conf.tor_options = nil
        expect(conf.tor_options[:tor_port]).to eq(9050)
      end

      it "validates only recognized keys" do
        expect{Configuration.new.tor_options = {foo: "bar"}}
            .to raise_error(/foo is not a valid key to be used with/)
      end

      it "can set value (merges with existing tor_options)" do
        config = Configuration.new
        the_options = {
            tor_port: 9150,
            control_port: 51500
        }
        config.tor_options = the_options
        expected_options = {
            tor_port: 9150,
            control_port: 51500,
            pid_dir: '/tmp',
            log_dir: '/tmp',
            tor_data_dir: '/tmp/tor_data/',
            tor_new_circuit_period: 60,
            max_tor_memory_usage: 200.megabytes,
            max_tor_memory_usage_times: [3,5],
            max_tor_cpu_percentage: 10.percent,
            max_tor_cpu_percentage_times: [3,5]
        }
        expect(config.tor_options).to eq(expected_options)
      end
    end
  end
end
