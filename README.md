# Scraypa

A Ruby gem to scrape web content with some of the features including: 
 
1. [Using Capybara (for Javscript support)](#using-capybara-for-javascript-support)
2. [The Onion Router (Tor)](#tor)

Scraypa is a wrapper for the light-weight 
[Rest Client](https://github.com/rest-client/rest-client) (if you dont require javascript support)
 or [Capybara](https://github.com/teamcapybara/capybara) (for Javascript support). 

## Why? 

A web scraper that can be configured to support javascript and/or Tor. If javascript is not required, 
 it will use the lighter Rest Client. Scraypa is an attempt to remove the complexities associated to web agent setup. In its simplest form a request would look like this:
 
 ```ruby
require 'scraypa'
response = Scraypa.visit(method: :get, url: "http://example.com")

#the response contains the RestClient response object
response.code
#-> 200
response.to_str
#-> http://example.com content
```

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

```ruby
response = Scraypa.visit(method: :get,
                         url: "http://example.com")

#the response contains the RestClient response object
response.code
#-> 200
response.to_str
#-> http://example.com content
```    
    
By default Scraypa uses the rest-client gem which does
not support Javascript. The `#visit` method wraps the  
[`RestClient#execute` method](https://github.com/rest-client/rest-client#passing-advanced-options)
so you can pass in whatever `RestClient#execute` will accept, 
for example:

```ruby
Scraypa.visit(method: :get, 
              url: 'http://example.com/resource',
              timeout: 10, 
              headers: {params: {foo: 'bar'}})

➔ GET http://example.com/resource?foo=bar
```

### Using Capybara (for Javascript support)

Capybara is used for Javascript support. Use the `Scraypa.configure` block to setup the `:poltergeist` or `:headless_chromium` driver:

```ruby
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
  #to reset the capybara driver every 7 requests (defaults to 5):
  #config.reset_driver_every_n_requests = 7
      
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

#the response contains the capybara page object
response.status_code
#-> 200
response.text
#-> http://example.com content 

#execute some javascript:
response.execute_script(
  "document.getElementsByTagName('body')[0].innerHTML = 'changed content';")
response.text
#-> "changed content"
```

The above shows the `reset_driver_every_n_requests` config parameter which defaults to 5. This will ensure that every n requests the Capybara driver is reset. This prevents the Capybara drivers from going crazy with memory usage. 

### Tor

If configured to use Tor (`config.tor = true`), Scraypa will spawn and manage a Tor process the proxy through with tor settings optionally specified in `config.tor_options`. Scraypa uses [TorManager](https://github.com/joshweir/tormanager) which in turn uses [Eye](https://github.com/kostya/eye) to spawn, monitor and stop the Tor process. 

If `config.tor_options` are not specified, the following defaults are used: 

| `tor_options` | Default Value | Description |
| --- | --- | --- |
| `:tor_port` | `9050` | The listening port of the Tor process. |
| `:control_port` | `50500` | The control port of the Tor process. |
| `:pid_dir` | `/tmp` | Eye will create a pid file in this location which stores the pid of the Tor process. The name of the pid file is of format: `tormanager-tor-<tor_port>-<parent_pid>.pid` **_†_**. |
| `:log_dir` | `/tmp` | If `:eye_logging` is `true`, Eye will create a log (`tormanager.eye.log`) in this location. If `:tor_logging` is `true`, Tor `stdall` is redirected to log (`tormanager-tor-<tor_port>-<parent_pid>.log` **_†_**) in this location. |
| `:tor_data_dir` | `nil` | If specified, Tor will use this directory location as the `--DataDirectory`. |
| `:tor_new_circuit_period` | `60` | In seconds, specifies the `--NewCircuitPeriod` that Tor should use. |
| `:max_tor_memory_usage_mb` | `200` | In megabytes, Eye will restart the Tor process if its memory exceeds this value for 3 consecutive readings (checked every 60 seconds). |
| `:max_tor_cpu_percentage` | `10` | Percentage value, Eye will restart the Tor process if it's cpu percentage exceeds this value for 3 consecutive readings (checked every 30 seconds). |
| `:eye_tor_config_template` | `tormanager/eye/tor.template.eye.rb` | Specify your own eye config template, it is recommended to use the default [template](https://github.com/joshweir/tormanager/blob/master/lib/tormanager/eye/tor.template.eye.rb) as your starting point.  |
| `:control_password` | Randomly generated by default. | By default, will do minimal logging and will create a random `:control_password` which is used to generate the `HashedControlPassword` used to change the Tor password on request. |
| `:tor_log_switch` | `nil` | If specified, sets the Tor `--Log` switch, for example a value of `notice syslog` will add `--Log "notice syslog"` to the Tor command. |
| `:eye_logging` | `nil` | If set to `true` will enable Eye logging in the `:log_dir` location, eye log: `tormanager.eye.log`  |
| `:tor_logging` | `nil` | If set to `true`, Tor `stdall` is redirected to log (`tormanager-tor-<tor_port>-<parent_pid>.log` **_†_**) in this location. |
| `:dont_remove_tor_config` | `nil` | By default, an eye configuration file is generated for the current Tor instance based on the `:eye_tor_config_template` stored in the `:log_dir` with name `tormanager.tor.<tor_port>.<parent_pid>.eye.rb` **_†_**. This generated file is removed when the Tor process is stopped by default. Setting `:dont_remove_tor_config` to `true` will not remove this file. |

**_†_** where `<tor_port>` is the `:tor_port` of the Tor process and `<parent_pid>` is the pid of the ruby process spawning the Tor process.

An example of using `config.tor_options` is included in the example `Scraypa.configure` blocks below.

Instruct Scraypa to use Tor with the default Rest Client: 

```ruby
Scraypa.configure do |config|
  config.tor = true
  #optionally specify the tor_options, any tor_options not included 
  #will use the defaults specified in the table above
  #config.tor_options = {
  #  tor_port: 9051, 
  #  control_port: 50501, 
  #  pid_dir: '/my/pid/dir',
  #  log_dir: '/my/log/dir',
  #  tor_data_dir: '/my/tor/datadir',
  #  tor_new_circuit_period: 120,
  #  max_tor_memory_usage_mb: 400,
  #  max_tor_cpu_percentage: 15,
  #  control_password: 'mycontrolpass',
  #  eye_logging: true,
  #  tor_logging: true
  #}
end

response = Scraypa.visit(method: :get, url: "http://example.com")
```

Instruct Scraypa to use Tor with Capybara Poltergeist:

```ruby
Scraypa.configure do |config|
  config.tor = true
  #optionally specify the tor_options, any tor_options not included 
  #will use the defaults specified in the table above
  #config.tor_options = {
  #  tor_port: 9052, 
  #  control_port: 50502
  #}

  #include the capybara configuration
  config.use_capybara = true
  config.driver = :poltergeist
  config.driver_options = {
    :phantomjs => Phantomjs.path,
    :js_errors => false,
    :phantomjs_options => ["--web-security=true"]
  }
end

response = Scraypa.visit(url: "http://example.com")
```

Scraypa does not support the use of Tor with Capybara Headless Chromium (couldn't get it to work).

### User Agents

Scraypa has a number of options for using user agents: 

1. Don't specify a user agent (default option).
2. A list of 17 common user agents.
3. Provide your own list of user agents.
3. User Agent Randomizer (selects a random user agent from a pool of hundreds).

#### A list of 17 common user agents

Using the same common alias list that [Mechanize uses](https://github.com/sparklemotion/mechanize/blob/master/lib/mechanize.rb#L115), the user agent list can be rotated every n requests `:change_after_n_requests` and can be iterated using a `:strategy` of `:roundrobin` or `:randomize`:

```ruby
Scraypa.configure do |config|
  config.user_agent = {
    list: :common_aliases,
    #will default to changing every request
    change_after_n_requests: 3,
    #you can limit the list to n user agents in the rotation:
    #list_limit: 10,
    #strategy :roundrobin (default) or :randomize
    strategy: :randomize
  }
end

response = Scraypa.visit(url: "http://example.com")
```

#### Provide your own list of user agents

```ruby
Scraypa.configure do |config|
  config.user_agent = {
    list: ['Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0',
    	   'Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
           'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:43.0) Gecko/20100101 Firefox/43.0'],
    #will default to changing every request
    change_after_n_requests: 3,
    #strategy :roundrobin (default) or :randomize
    strategy: :randomize
  }
end

response = Scraypa.visit(url: "http://example.com")
```

You could use specify a single user agent of your choosing like this:

```ruby
Scraypa.configure do |config|
  config.user_agent = {
    list: ['Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0']
  }
end

response = Scraypa.visit(url: "http://example.com")
```

#### User Agent Randomizer (selects a random user agent from a pool of hundreds)

```ruby
Scraypa.configure do |config|
  config.user_agent = {
    method: :randomizer,
    #will default to changing every request
    change_after_n_requests: 3,
    #you can limit the list to n user agents in the rotation:
    list_limit: 30
  }
end

response = Scraypa.visit(url: "http://example.com")
```          

### Throttle

Using the `config.throttle_seconds` will throttle Scraypa requests: 

```ruby
Scraypa.configure do |config|
  #throttle every request by 0.4 seconds
  config.throttle_seconds = 0.4
  #a throttle_seconds range can be provided in which each request 
  #will be throttled by a random float seconds between :from and :to
  #config.throttle_seconds = {from: 0.4, to: 3.5}
end

response = Scraypa.visit(method: :get, url: "http://example.com")

```
As shown in the above code, a single value `throttle_seconds` can be specified which is the number of seconds to throttle requests by, or a hash range (eg: `{from: 0.4, to: 3.5}`) in which a random number of seconds between the `:from` and `:to` values will be used to throttle each request. 

By default, Scraypa uses no throttling (ie. `config.throttle_seconds = 0`).

### All Configuration Parameters

Using `Scraypa.reset` will reset the Scraypa configuration parameters back to their defaults (see the defaults in the table below).

The following table presents the complete list of configuration parameters available within the `Scraypa.configure` block.

| Parameter | Default Value | Description |
| --- | --- | --- |
| `use_capybara` | `nil` | Set to `true` to use Capybara, by default will not use Capybara (will use Rest Client). If set to `true`, `driver` is required. For more info, see the [Using Capybara (for Javscript support)](#using-Capybara-for-javascript-support) section. |
| `driver` | `nil` | If `use_capybara` is set, then set `driver` to `:poltergeist` or `:headless_cromium` - the desired Capybara driver. |
| `driver_options` | `nil` | If `use_capybara` is set, then set `driver_options` to the `driver` options to use with Capybara. See the [Using Capybara (for Javscript support)](#using-Capybara-for-javascript-support) section for examples. |
| `reset_driver_every_n_requests` | `5` | Will reset the driver every n requests based on this parameter. Only used with Capybara, this will ensure that every n requests the Capybara driver is reset. This prevents the Capybara drivers from going crazy with memory usage. |
| `tor` | `nil` | If set to `true`, Scraypa will spawn and manage a Tor process the proxy through with tor settings optionally specified in `tor_options`. Scraypa uses [TorManager](https://github.com/joshweir/tormanager) which in turn uses [Eye](https://github.com/kostya/eye) to spawn, monitor and stop the Tor process. See the [Tor)](#tor) section for more info.  |
| `tor_options` | `nil` | If `tor` is set to `true`, optionally set this parameter to control Tor settings such as `tor_port`, `tor_control_port` etc. See the [Tor)](#tor) section for more info. |
| `user_agent` | `nil` | Specify your own user agent, a list of user agents to iterate over, or a random user agent from a pool of hundreds. Configure how often the user agent rotates etc. See the [User Agents)](#user-agents) section for more info. |
| `throttle_seconds` | `nil` | A single value `throttle_seconds` can be specified which is the number of seconds to throttle requests by, or a hash range (eg: `{from: 0.4, to: 3.5}`) in which a random number of seconds between the `:from` and `:to` values will be used to throttle each request. |

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshweir/scraypa.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
