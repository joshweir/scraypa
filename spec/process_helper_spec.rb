require "spec_helper"

module Scraypa
  describe ProcessHelper do
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
    
    describe "::kill_processes" do 
    
    end 
    
    describe "::process_pid_running?" do 
    
    end 
    
    describe "::port_is_open?" do 
    
    end 
  end
end
