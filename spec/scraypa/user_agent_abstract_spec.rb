require "spec_helper"

module Scraypa
  describe UserAgentAbstract do
    describe "#list" do
      context "when instantiated without a :list param specified" do
        it "defaults the list to the USER_AGENT_LIST constant" do
          the_list = {
              'Linux Firefox' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0',
              'Linux Konqueror' => 'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
              'Linux Mozilla' => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
              'Mac Firefox' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:43.0) Gecko/20100101 Firefox/43.0',
              'Mac Mozilla' => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
              'Mac Safari 4' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
              'Mac Safari' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9',
              'Windows Chrome' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.125 Safari/537.36',
              'Windows IE 6' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
              'Windows IE 7' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
              'Windows IE 8' => 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
              'Windows IE 9' => 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)',
              'Windows IE 10' => 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0)',
              'Windows IE 11' => 'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
              'Windows Edge' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586',
              'Windows Mozilla' => 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
              'Windows Firefox' => 'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0'
          }
          expect(subject.list).to eq the_list
        end
      end

      context "when instantiated with a :list param specified" do
        let(:subject) { UserAgentAbstract.new list: ['user agent 1', 'user agent 2'] }

        it "uses the :list param" do
          expect(subject.list).to eq ['user agent 1', 'user agent 2']
        end

        context "when :list is not an array" do
          let(:string_example) { UserAgentAbstract.new(list: "user agent 1") }
          let(:hash_example) { UserAgentAbstract.new(list: {"u1": "user agent 1",
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

=begin
case args[0] && args[0][:user_agents]
  when :common_aliases
    UserAgentCommonAliases.new(*args)
  when :randomizer
    UserAgentRandom.new(*args)
  when String, Array
    UserAgentUserDefined.new(*args)
  else
    raise UnrecognisedUserAgents
end
=end