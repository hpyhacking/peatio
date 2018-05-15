# encoding: UTF-8
# frozen_string_literal: true

Rails.application.configure do

  # Available levels (verbosity goes from high to less): debug, info, warn, error, fatal.
  # Default level for production is warn, otherwise – debug.
  log_level = ENV['LOG_LEVEL'].presence || (Rails.env.production? ? :warn : :debug)

  # In non-test environments logging always goes to STDOUT since this is the most appropriate way
  # to get logs in Docker environment.
  unless Rails.env.test?
    config.logger = ActiveSupport::Logger.new STDOUT, \
      level:     log_level,
      formatter: Logger::Formatter.new
  end

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # The configuration variables below will be used in case config.logger hasn't been set yet.

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = log_level

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new
end
