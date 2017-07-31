module Scraypa
  class ProcessHelper
    def self.query_process query
      return nil unless query
      if query.kind_of?(Array)
        query.each_with_index do |a, i|
          s = "grep #{a.to_s}" if i == 0
          s += " | grep #{a.to_s}" if i > 0
        end
        fullcmd = "ps -ef | #{s} | grep -v grep | grep -v #{Process.pid.to_s}"
      else

      end
    end

    def self.kill_process pids
      
    end 
    
    def self.process_pid_running? pid
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
    
    def self.port_is_open? port 
    
    end

    private


  end
end


def self.kill_rogue_process search_terms_array
    s = ''
    pids_to_kill = []
    validpids = RgScrapeRest::valid_pids
    return true unless search_terms_array && search_terms_array.kind_of?(Array)
    search_terms_array.each_with_index do |a, i|
      s = "grep #{a.to_s}" if i == 0
      s += " | grep #{a.to_s}" if i > 0
    end
    fullcmd = "ps -ef | #{s} | grep -v grep | grep -v #{Process.pid.to_s}"
    puts fullcmd
    `ps -ef | #{s} | grep -v grep | grep -v #{Process.pid.to_s}`.split("\n").each do |p|
      #if trimmed and remove excess white space is length > 0
      #split by ' ' and get the pid and the ppid (index 1 and 2)
      p_parts = removeExtractWhitespaceWithin(p).strip.split
      if p_parts.size >= 3
        pid = p_parts[1].to_i
        ppid = p_parts[2].to_i
        if pid > 0
          unless validpids.include? pid.to_i
            pids_to_kill.push pid
          else
            puts "#{pid} is valid, therefore wont kill #{pid}"
            validpids.push ppid
          end
        else
          puts 'couldnt get pid as an integer! '.freeze + p_parts[1].to_s
        end
      else
        puts "the ps -ef output was not formatted as expected couldnt get pid and ppid " +
                 fullcmd
      end
    end
    pids_to_kill -= validpids
    pids_to_kill.each do |pid|
      puts "killing pid: #{pid}"
      5.times do |k|
        `kill #{pid}` if k < 3
        `kill -9 #{pid}` if k >= 3
        sleep 1
        break unless process_pid_running? pid
        raise "Couldnt kill -9 #{s}" if k >= 4
      end
      msg = "just killed a rogue process: #{pid.to_s} found by searching #{fullcmd}"
      #ScraperMailer.generic_email(msg).deliver_now
    end
  end

