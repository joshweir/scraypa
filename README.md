# Scraypa (in development - not ready to be used)

Scrape web content with configuration options including: 
 
1. [Javscript support](#javascript-support)
2. [The Onion Router (Tor)](#tor)
3. [Disguise](#disguise)

Scraypa is essentially a wrapper for the light-weight 
[Rest Client](https://github.com/rest-client/rest-client) (if you dont require javascript support)
 or [Capybara](https://github.com/teamcapybara/capybara) (for Javascript support). 

## Installation

### Install Tor (optional)

If you want to use Tor, install tor:

`sudo apt-get install tor`

### Install Headless Chrome (optional)

If you want to use `:headless_chrome` with capybara, install 
headless chrome by following instructions here: 

http://blog.faraday.io/headless-chromium/

For ubuntu I did this: 

1. Install chromium: 

        git clone https://github.com/scheib/chromium-latest-linux.git
        cd chromium-latest-linux
        ./update-and-run.sh
        
2. Install chromedriver by [following the build instructions](https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions.md).

### Install Scraypa

Add this line to your application's Gemfile:

```ruby
gem 'scraypa'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install scraypa

## Usage

    response = Scraypa.visit(method: :get,
                             url: "http://example.com")
    
    #the response.native_response contains the RestClient response object
    response.native_response.code
    #-> 200
    response.native_response.to_str
    #-> http://example.com content
    
By default Scraypa uses the rest-client gem which does
not support Javascript. The `#visit` method wraps the  
[`RestClient#execute` method](https://github.com/rest-client/rest-client#passing-advanced-options)
so you can pass in whatever `RestClient#execute` will accept, 
for example:

    Scraypa.visit(method: :get, 
                  url: 'http://example.com/resource',
                  timeout: 10, 
                  headers: {params: {foo: 'bar'}})
                  
    ➔ GET http://example.com/resource?foo=bar

### Javascript Support

Capybara is used for Javascript support:

    #configure Scraypa to #use_capybara
    #and choose your capybara driver, here is poltergeist:
    Scraypa.configure do |config|
      config.use_capybara = true
      config.driver = :poltergeist
      config.driver_options = {
          :phantomjs => Phantomjs.path,
          :js_errors => false,
          :phantomjs_options => ["--web-security=true"]
      }
      
      #or you could instead use headless_chrome:
      #config.driver = :headless_chromium
      #config.driver_options = {
      #  browser: :chrome,
      #  desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      #    "chromeOptions" => {
      #      "binary" => "/home/resrev/chromium/src/out/Default/chrome",
      #      "args" => %w{headless no-sandbox disable-gpu}
      #    }
      #  )
      #}
    end
    
    #when using capybara, just the url parameter is required:
    response = Scraypa.visit(url: "http://example.com")
    
    #the response.native_response contains the capybara page object
    response.native_response.status_code
    #-> 200
    response.native_response.text
    #-> http://example.com content 
    
    #execute some javascript:
    response.native_response.execute_script(
      "document.getElementsByTagName('body')[0].innerHTML = 'changed content';")
    response.native_response.text
    #-> "changed content"

### Tor

TODO

### Disguise

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshweir/scraypa.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

