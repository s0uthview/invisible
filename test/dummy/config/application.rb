require_relative "boot"

# Only require what we need (skip ActiveRecord to avoid sqlite3 issues)
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Include sprockets railtie if available (for asset pipeline compatibility)
begin
  require "sprockets/railtie"
rescue LoadError
  # Sprockets not available, skip it
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
begin
  Bundler.require(*Rails.groups)
rescue LoadError, Bundler::GemRequireError => e
  # Skip sqlite3 if native extension fails (common on Windows)
  if e.message.include?("sqlite3") || e.message.include?("sqlite3_native")
    # Continue without sqlite3 - we don't need a database for this plugin
  else
    raise
  end
end

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    # skip model autoloading since we don't use ActiveRecord
    # remove model paths early before they get frozen
    config.before_initialize do
      if config.paths["app/models"]
        config.paths["app/models"].existent.clear
      end
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
