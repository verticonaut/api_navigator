
require File.expand_path('../lib/api_navigator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Martin Schweizer']
  gem.email         = ['martin@verticonaut.me']
  gem.description   = 'ApiNavigator base on api_navigator from Oriol Gual'
  gem.summary       = ''
  gem.homepage      = 'https://github.com/verticonaut/api_navigator/'
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- rspec/*`.split("\n")
  gem.name          = 'api_navigator'
  gem.require_paths = ['lib']
  gem.version       = ApiNavigator::VERSION

  gem.add_dependency 'faraday', '>= 0.9.0'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'faraday_hal_middleware'
  gem.add_dependency 'uri_template'
  gem.add_dependency 'net-http-digest_auth'
  gem.add_dependency 'faraday-digestauth'
end
