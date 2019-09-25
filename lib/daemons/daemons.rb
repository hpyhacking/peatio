# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

raise "Worker name must be provided." if ARGV.size == 0

name = ARGV[0]
worker = "Workers::Daemons::#{name.camelize}".constantize.new

terminate = proc do
  puts "Terminating worker .."
  worker.stop
  puts "Stopped."
end

Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

begin
  worker.run
rescue StandardError => e
  if worker.is_db_connection_error?(e)
    logger.error(db: :unhealthy, message: e.message)
    raise e
  end

  report_exception(e)
end
