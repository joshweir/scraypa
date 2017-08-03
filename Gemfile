source 'https://rubygems.org'

# Specify your gem's dependencies in scraypa.gemspec
gemspec

gem 'selenium-webdriver', :require => false
gem 'poltergeist', :require => false
gem 'phantomjs', :require => 'phantomjs/poltergeist'
gem 'tor', :git => 'https://github.com/bendiken/tor-ruby.git', :ref => '08e589d17196a5dc640e7b38cb1acc5b4c5ced05'
#gem 'tor', :git => 'https://github.com/dryruby/tor.rb.git'
group :development, :test do
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "guard-rspec"
end