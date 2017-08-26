require "spec_helper"

module Scraypa
  describe UserAgentIterator do
    it "can be instantiated" do
      expect(subject).to be_an_instance_of UserAgentIterator
      expect(subject.kind_of?(UserAgentAbstract)).to be_truthy
    end

    describe "#user_agent" do
      context "when instantiated without a :list param" do
        it "uses the USER_AGENT_LIST" do
          expect(USER_AGENT_LIST.values).to include subject.user_agent
        end
      end

      context "when instantiated with a :list param" do
        let(:subject) { UserAgentIterator.new list: ['agent1', 'agent2'] }
        it "uses the specified :list" do
          expect(['agent1', 'agent2']).to include subject.user_agent
        end
      end

      context "when :change_after_n_requests param is populated" do
        let(:subject) { UserAgentIterator.new list: ['agent1', 'agent2'],
                                              change_after_n_requests: 2 }
        it "changes the user_agent after n requests" do
          attempts = []
          4.times { attempts << subject.user_agent }
          expect(attempts[0]).to eq attempts[1]
          expect(attempts[1]).to_not eq attempts[2]
          expect(attempts[2]).to eq attempts[3]
        end
      end

      context "when :change_after_n_requests param is empty" do
        it "changes the user_agent every request" do
          attempts = []
          4.times { attempts << subject.user_agent }
          expect(attempts[0]).to_not eq attempts[1]
          expect(attempts[1]).to_not eq attempts[2]
          expect(attempts[2]).to_not eq attempts[3]
        end
      end

      context "when :strategy is empty" do
        let(:subject) { UserAgentIterator.new list: ['agent1', 'agent2', 'agent3'] }

        it "defaults to the :roundrobin strategy and iterates " +
               "through the user agents linearly" do
          attempts = []
          4.times { attempts << subject.user_agent }
          expect(attempts).to eq ['agent1','agent2','agent3','agent1']
        end
      end

      context "when :strategy is :randomize" do
        let(:subject) { UserAgentIterator.new list: ['agent1', 'agent2', 'agent3'],
                                              strategy: :randomize }
        it "it randomly selects a user agent from the list" do
          attempts = []
          4.times { attempts << subject.user_agent }
          expect(attempts).to_not eq ['agent1','agent2','agent3','agent1']
          #only user agents from our list are used
          expect((attempts.uniq - ['agent1', 'agent2', 'agent3']).empty?).to be_truthy
        end

        it "will just select the only user agent if there is just one" do
          attempts = []
          2.times { attempts << UserAgentIterator.new(list: 'agent1',
                                                      strategy: :randomize).user_agent }
          expect(attempts).to eq ['agent1','agent1']
        end
      end
    end

    describe "#list" do
      context "when instantiated without a :list param specified" do
        it "defaults the list to the USER_AGENT_LIST constant" do
          the_list = [
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0',
              'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
              'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:43.0) Gecko/20100101 Firefox/43.0',
              'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.125 Safari/537.36',
              'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
              'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
              'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
              'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)',
              'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0)',
              'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586',
              'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
              'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0'
          ]
          expect(subject.list).to eq the_list
        end
      end

      context "when instantiated with a :list param specified" do
        let(:subject) { UserAgentIterator.new list: ['user agent 1', 'user agent 2'] }

        it "uses the :list param" do
          expect(subject.list).to eq ['user agent 1', 'user agent 2']
        end

        context "when :list is not an array" do
          let(:string_example) { UserAgentIterator.new(list: "user agent 1") }
          let(:hash_example) { UserAgentIterator.new(list: {"u1": "user agent 1",
                                                            "u2": "user agent 2"}) }

          it "coerces it to an array" do
            expect(string_example.list).to eq ['user agent 1']
            expect(hash_example.list).to eq ['user agent 1', 'user agent 2']
          end
        end
      end
    end
  end
end
