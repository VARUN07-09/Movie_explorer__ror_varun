# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# spec/rails_helper.rb
# require 'spec_helper'
require 'rails/all'
require 'rspec/rails'

# ... other required configurations


# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories.
# Auto-require support files (you can comment this if you want to load manually)
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Use fixtures from this path
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Automatically mix in different behaviours based on file location
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")
end

# Shoulda Matchers config (for model matchers like validate_presence_of, define_enum_for, etc.)
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
