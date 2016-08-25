require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dreamsis
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/app/models/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    
    # Opt in to new callback error behavior.
    config.active_record.raise_in_transactional_callbacks = true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Pacific Time (US & Canada)"
    
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :regid, :state, :code]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.2'
   
    # Setup global ActionMailer settings
    config.action_mailer.default_url_options = { host: "dreamsis.com" }
    
    # Prevent app initialization when precompiling assets
    config.assets.initialize_on_precompile = false
    
    # config_file_path = File.join(Rails.root, "config", "api-keys.yml")
    # temp_api_keys = YAML.load_file(config_file_path)
    # redis_endpoint = temp_api_keys["redis"][Rails.env]["endpoint"]
    # redis_password = temp_api_keys["redis"][Rails.env]["password"]
    # config.cache_store = :redis_store, {
    #   url: "redis://#{redis_endpoint}", password: redis_password, namespace: "cache"
    # }
    
    # Turn on json escaping
    config.active_support.escape_html_entities_in_json = true
    
    # Use sidekiq as our ActiveJob backend
    config.active_job.queue_adapter = :sidekiq

  end
end
