# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scraypa/version'

Gem::Specification.new do |spec|
  spec.name          = "scraypa"
  spec.version       = Scraypa::VERSION
  spec.authors       = ["joshweir"]
  spec.email         = ["joshua.weir@gmail.com"]

  spec.summary       = %q{Web scraper with support for proxy, Tor and javascript.}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/joshweir/scraypa"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.5"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "puffing-billy"
  spec.add_dependency "activesupport"
  spec.add_dependency "rest-client"
  spec.add_dependency "useragents"
  spec.add_dependency "capybara", "~> 2.4.4"
  spec.add_dependency "chromedriver-helper"
end
