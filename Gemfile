source 'https://rubygems.org'

# Specify your gem's dependencies in scraypa.gemspec
gemspec

gem 'selenium-webdriver', :require => false
gem 'poltergeist', :require => false
gem 'phantomjs', :require => 'phantomjs/poltergeist'
group :development, :test do
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "guard-rspec"
end