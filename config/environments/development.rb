Peatio::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Use a different cache store in production.
  # config.cache_store = :file_store, "tmp"
  config.cache_store = :redis_store, { expires_in: 90.minutes }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { location: 'tmp/mails' }

  config.action_mailer.default_url_options = { :host => ENV["URL_HOST"] }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_controller.perform_caching = true
  config.active_record.default_timezone = :local
end
