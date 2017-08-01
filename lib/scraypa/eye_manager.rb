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

      def status params={}
        validate_status_params params
        eye_status_filtered_by params
      end

      def destroy
        cmd = "eye q -s"
        output = `#{cmd}`
        raise "Eye destroy failed. " +
                  "Command: #{cmd}. Output: #{output}." unless
            /^Eye quit|socket\(.+\) not found/.match(output)
      end

      private

      def validate_start_params params={}
        raise ":config is required" unless params[:config]
        raise ":application is required" unless params[:application]
      end

      def validate_status_params params={}
        raise ":process is required" unless params[:process]
      end

      def load_config_and_verify config
        cmd = "eye load #{config}"
        output = `#{cmd}`
        raise "Eye load failed to load config. " +
                  "Command: #{cmd}. Output: #{output}." unless
            /Config loaded/.match(output)
      end

      def start_and_verify application
        cmd = "eye start #{application}"
        output = `#{cmd}`
        raise "Eye start failed. " +
                  "Command: #{cmd}. Output: #{output}." unless
            /command :start sent to \[#{Regexp.escape(application)}\]/.match(output)
      end

      def eye_status_filtered_by params={}
        process_status = 'unknown'
        eye_status_apps_filtered_by(params[:application]).each do |app|
          eye_status_groups_filtered_by(params[:group], app["subtree"])
              .each do |group|
            process_status = eye_status_process_status_filtered_by(
                                params[:process], group["subtree"])
            break unless process_status == 'unknown'
          end
        end
        process_status
      rescue JSON::ParserError => e
        'unknown'
      end

      def eye_status_apps_filtered_by app
        status_apps = JSON.parse(`eye i -j`)['subtree']
        app.to_s.length > 0 ?
            status_apps
                .select{|a| a["name"] == "#{app}" &&
                              a["type"] == "application"} :
            status_apps
      end

      def eye_status_groups_filtered_by group, app_groups
        the_group = group.to_s.length > 0 ? group : '__default__'
        app_groups.select{|grp| grp["name"] == "#{the_group}" &&
                                grp["type"] == "group"}
      end

      def eye_status_process_status_filtered_by process, group_processes
        the_process =
            group_processes.select{|prc| prc["name"] == "#{process}" &&
                                         prc["type"] == "process"}
        the_process[0] && the_process[0]["state"] ?
            the_process[0]["state"] : 'unknown'
      end
    end
  end
end