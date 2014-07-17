require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Peatio
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.enforce_available_locales = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = ['en','zh-TW','zh-CN']

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/extras)

    #config.assets.precompile += ['fund_source.js', 'bootstrap-datetimepicker.css']
    config.assets.initialize_on_precompile = true

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.stylesheets     false
    end

    # Observer configuration
    config.active_record.observers = :transfer_observer
  end
end

Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M:%S"
HandlebarsAssets::Config.template_namespace = 'JST'
