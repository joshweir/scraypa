require "spec_helper"

module Scraypa
  describe ProcessHelper do
    after :all do
      ProcessHelper::kill_process(
          ProcessHelper::query_process ['test process','ruby'])
    end

    describe "::query_process" do
      before :all do 
        @pid1 = Process.spawn("ruby -e \"loop{puts 'test process 1'; sleep 5}\"")
        Process.detach(@pid1)
        @pid2 = Process.spawn("ruby -e \"loop{puts 'test process 2'; sleep 5}\"")
        Process.detach(@pid2)
        @pids = [@pid1, @pid2].sort
      end

      after :all do 
        Process.kill 'TERM', @pid1
        Process.kill 'TERM', @pid2
      end
      
      context "param is a string (single query string)" do 
        it "should find processes based on a query string" do 
          expect(ProcessHelper::query_process('test process').sort)
            .to eq(@pids)
          expect(ProcessHelper::query_process('test process 2'))
            .to eq([@pid2])  
        end 
        
        it "should find processes based on a query regex" do 
          expect(ProcessHelper::query_process('test process \d').sort)
            .to eq(@pids)
        end
        
        it "should not find processes that do not exist" do 
          expect(ProcessHelper::query_process('test process a'))
            .to be_nil
        end 
      end 
      
      context "param is an array (multiple query strings)" do 
        it "should find processes based on a query strings" do 
          expect(ProcessHelper::query_process(['test process','ruby']).sort)
            .to eq(@pids)
          expect(ProcessHelper::query_process(['test process 2','ruby']))
            .to eq([@pid2])  
        end 
        
        it "should find processes based on a query regexes" do 
          expect(ProcessHelper::query_process(['test process \d','ruby']).sort)
            .to eq(@pids)
        end
        
        it "should not find processes that do not exist" do 
          expect(ProcessHelper::query_process(['test process','ruby -i']))
            .to be_nil
        end 
      end 
    end

    describe "::process_pid_running?" do
      it "should be true if pid is running" do
        pid = Process.spawn("ruby -e \"loop{puts 'test process 1'; sleep 5}\"")
        Process.detach(pid)
        expect(ProcessHelper::process_pid_running?(pid))
            .to be_truthy
        Process.kill 'TERM', pid
      end

      it "should not be true if pid is not running" do
        expect(ProcessHelper::process_pid_running?(
            spawn_and_kill_process_with_intention_that_pid_will_not_be_in_use_after))
            .not_to be_truthy
      end
    end

    describe "::kill_process" do
      context "param is an array (multiple pids)" do
        it "should kill multiple processes" do
          pid1 = Process.spawn("ruby -e \"loop{puts 'test process 1'; sleep 5}\"")
          Process.detach(pid1)
          pid2 = Process.spawn("ruby -e \"loop{puts 'test process 2'; sleep 5}\"")
          Process.detach(pid2)
          pids = [pid1, pid2]
          expect(ProcessHelper::process_pid_running?(pid1))
            .to be_truthy
          expect(ProcessHelper::process_pid_running?(pid2))
              .to be_truthy
          ProcessHelper::kill_process pids
          expect(ProcessHelper::process_pid_running?(pid1))
              .not_to be_truthy
          expect(ProcessHelper::process_pid_running?(pid2))
              .not_to be_truthy
        end
      end

      context "param is not an array (single pid)" do
        it "should kill a process" do
          pid = Process.spawn("ruby -e \"loop{puts 'test process 1'; sleep 5}\"")
          Process.detach(pid)
          expect(ProcessHelper::process_pid_running?(pid))
              .to be_truthy
          ProcessHelper::kill_process pid
          expect(ProcessHelper::process_pid_running?(pid))
              .not_to be_truthy
        end

        it "should be quiet if the process does not exist upon kill orders" do
          expect{ProcessHelper::kill_process(
              spawn_and_kill_process_with_intention_that_pid_will_not_be_in_use_after)}
            .not_to raise_error
        end
      end
    end

    describe "::port_is_open?" do 
    
    end

    def spawn_and_kill_process_with_intention_that_pid_will_not_be_in_use_after
      pid = Process.spawn("ruby -e \"loop{puts 'test process'; sleep 5}\"")
      Process.detach(pid)
      Process.kill 'TERM', pid
      pid
    end
  end
end
