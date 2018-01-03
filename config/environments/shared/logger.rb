Rails.application.configure do

  # We are always logging to STDOUT since this is the most appropriate way to get logs in Docker environment.
  config.logger = ActiveSupport::Logger.new STDOUT, \
    level:     :debug,
    formatter: Logger::Formatter.new

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # The following lines don't affect configuration, however they are needed to suppress warnings.
  config.log_level = :debug
end
