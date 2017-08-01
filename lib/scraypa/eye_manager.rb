module Scraypa
  class EyeManager
    class << self
      def start params={}
        validate_start_params params
        load_config_and_verify params[:config]
        start_and_verify params[:application]
      end

      def stop

      end

      def status

      end

      def destroy

      end

      private

      def validate_start_params params={}
        raise ":config is required" unless params[:config]
        raise ":application is required" unless params[:application]
      end

      def load_config_and_verify config
        cmd = "eye load #{config}"
        output = `#{cmd}`
        raise "eye load failed to load config. " +
                  "Command: #{cmd}. Output: #{output}." unless
            /Config loaded/.match(output)
      end

      def start_and_verify application
        cmd = "eye start #{application}"
        output = `#{cmd}`
        raise "eye start failed. " +
                  "Command: #{cmd}. Output: #{output}." unless
            /command :start sent to \[#{Regexp.escape(application)}\]/.match(output)
      end
    end
  end
end