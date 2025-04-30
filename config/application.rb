# config/application.rb
require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "active_storage/railtie"


# Debug Active Storage loading
begin
  # require "active_storage/railtie"
rescue LoadError => e
  puts "Failed to load active_storage/railtie: #{e.message}"
  puts "Gem path: #{Gem.path.join(', ')}"
  puts "ActiveStorage gem loaded: #{Gem.loaded_specs['activestorage']&.version}"
  raise e
end

Bundler.require(*Rails.groups)

module MovieExplorer
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = false # Enable views for ActiveAdmin
    config.active_storage.variant_processor = :vips if defined?(ActiveStorage)
  end
end