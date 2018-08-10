# NOTE: this is temporary until Bundler 2.0 changes how github: references work.
git_source(:github) { |repo| "https://github.com/#{repo['/'] ? repo : "#{repo}/#{repo}"}.git" }

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'pry'
  gem 'pry-byebug', '~> 3.4'
  gem 'rake'
  gem 'rubocop', '~> 0.50.0', require: false
  gem 'simplecov', require: false
  gem 'rspec', '~> 3.7'
  gem 'guard-rspec'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'turn'
  gem 'webmock'
end
