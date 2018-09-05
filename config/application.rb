# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'rails'

%w( active_record action_controller action_view sprockets ).each { |framework| require "#{framework}/railtie" }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the plugins listed in config/plugins.yml.
require_relative 'plugins'

module Peatio
  class Application < Rails::Application

    # Configure Sentry as early as possible.
    if ENV['SENTRY_DSN_BACKEND'].present?
      require 'sentry-raven'
      Raven.configure { |config| config.dsn = ENV['SENTRY_DSN_BACKEND'] }
    end

    # Require Scout.
    require 'scout_apm' if Rails.env.in?(ENV['SCOUT_ENV'].to_s.split(',').map(&:squish))

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV.fetch('TIMEZONE')

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[root.join('config', 'locales', '*.{yml}')]
    config.i18n.available_locales = ['en']

    # Don't suppress exceptions in before_commit & after_commit callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.initialize_on_precompile = true

    # Automatically load and reload constants from "lib/*":
    #   lib/aasm/locking.rb => AASM::Locking
    # We disable eager load here since lib contains lot of stuff which is not required for typical app functions.
    config.paths.add 'lib', eager_load: false, autoload: true
  end
end
