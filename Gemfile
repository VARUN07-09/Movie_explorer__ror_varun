# Gemfile
source 'https://rubygems.org'
# git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

gem 'rails', '~> 7.1.5.1'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'jwt', '~> 2.8'
gem 'bcrypt', '~> 3.1.7'
gem 'activeadmin', '~> 3.2'
gem 'kaminari', '~> 1.2'
gem "activestorage", require: "active_storage/engine"
gem 'active_storage_validations', '~> 1.1'
gem 'rswag', '~> 2.13'
gem 'rack-cors', '~> 2.0'
gem 'stripe', '~> 10.0'
gem 'sassc', '~> 2.4' # For ActiveAdmin styles
gem 'sprockets-rails', '~> 3.5' # Single version for asset pipeline
gem 'fcm', '~> 0.0.6'
gem 'bootsnap', require: false # Reduces boot times
gem 'tzinfo-data', platforms: %i[windows jruby] # Windows timezone support
gem 'faraday', '~> 2.9'


group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'spring'
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
end
gem 'inherited_resources'

gem "devise", "~> 4.9"
gem "dotenv"
gem 'active_model_serializers'

group :test do
  gem 'shoulda-matchers', '~> 5.0'
end
