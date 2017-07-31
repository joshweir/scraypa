module Scraypa
  class ProcessHelper
    class << self
      def query_process query
        return [] unless query
        query_process_bash_cmd(query).split("\n").map{ |query_output_line|
          get_pid_from_query_process_output_line(query_output_line)
        }.compact
      end

      def kill_process pids
        to_array(pids).each do |pid|
          try_to_kill pid: pid, attempts: 5
        end
      end

      def process_pid_running? pid
        begin
          return false if pid.to_s == ''.freeze
          ipid = pid.to_i
          return false if ipid <= 0
          Process.kill(0, ipid)
          return true
        rescue
          return false
        end
      end

      def port_is_open? port
        begin
          server = TCPServer.new('127.0.0.1', port)
          server.close
          return true
        rescue Errno::EADDRINUSE;
          return false
        end
      end

      private

      def query_process_bash_cmd query
        `ps -ef | #{query_grep_pipe_chain(query)} | grep -v grep`
      end

      def query_grep_pipe_chain query
        to_array(query)
            .map{|q| "grep '#{q}'"}
            .join(' | ')
      end

      def get_pid_from_query_process_output_line query_output_line
        output_parts = query_output_line.gsub(/\s\s+/, ' ').strip.split
        output_parts.size >= 3 && output_parts[1].to_i > 0 ?
            output_parts[1].to_i : nil
      end

      def to_array v
        (v.kind_of?(Array) ? v : [v])
      end

      def try_to_kill params={}
        pid = params.fetch(:pid, nil)
        return unless pid && process_pid_running?(pid)
        params.fetch(:attempts, 5).times do |k|
          k < 3 ? Process.kill('TERM', pid) :
            Process.kill('KILL', pid)
          sleep 0.5
          break unless process_pid_running? pid
          raise "Couldnt kill pid: #{pid}" if k >= 4
        end
      end
    end
  end
end