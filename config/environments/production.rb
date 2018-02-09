require File.expand_path('../shared', __FILE__)

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = true

  # Compress JavaScripts.
  # FIXME: Disable mangler due to issues with Angular module definition at «Funds».
  config.assets.js_compressor = Uglifier.new(mangle: false)

  # Compress CSS.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV['FORCE_SECURE_CONNECTION'] == 'true'

  # Use a different cache store in production.
  config.cache_store = :redis_store, ENV['REDIS_URL']

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.default_url_options = {
    host: ENV['URL_HOST'],
    protocol: ENV['URL_SCHEME']
  }

  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_ADDRESS'],
    port:                 ENV['SMTP_PORT'],
    user_name:            ENV['SMTP_USERNAME'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       ENV['SMTP_AUTHENTICATION_TYPE'],
    domain:               ENV['SMTP_DOMAIN'],
    ssl:                  ENV['SMTP_USE_SSL'],
    tls:                  ENV['SMTP_USE_TLS'],
    openssl_verify_mode:  ENV['SMTP_OPENSSL_VERIFY_MODE'],
    enable_starttls:      ENV['SMTP_ENABLE_STARTTLS'],
    enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'],
    open_timeout:         ENV['SMTP_OPEN_TIMEOUT'],
    read_timeout:         ENV['SMTP_READ_TIMEOUT']
  }.compact.tap do |options|

    # Typecast several options to integers.
    %i[ port open_timeout read_timeout ].each do |option|
      options[option] = options[option].to_i if options.key?(option)
    end

    # Typecast several options to booleans.
    %i[ ssl tls enable_starttls enable_starttls_auto ].each do |option|
      if options.key?(option)
        options[option] = options[option] == 'true' ? true : false
      end
    end

    # Enable mailer only if variables are defined in environment.
  end if ENV.key?('SMTP_ADDRESS') && ENV.key?('SMTP_PORT')

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.middleware.insert_before Rack::Runtime, Middleware::Security
end
