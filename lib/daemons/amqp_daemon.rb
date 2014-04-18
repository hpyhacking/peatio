#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

raise "Worker name must be provided." if ARGV.size != 1

Rails.logger = logger = Logger.new STDOUT

worker   = "Worker::#{ARGV[0].camelize}".constantize.new
bindings = if ARGV.size > 1
             ARGV[1..-1].map {|id| AMQP_CONFIG[:binding][id.to_sym] }
           else
             [ AMQP_CONFIG[:binding][ARGV[0].to_sym] ]
           end


conn = Bunny.new AMQP_CONFIG[:connect]
conn.start

ch = conn.create_channel
ch.prefetch(1)
logger.info "Connected to AMQP broker."

terminate = proc do
  # logger is forbidden in signal handling, just use puts here
  puts "Terminating threads .."
  ch.work_pool.kill
  puts "Stopped."
end
Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

bindings.each do |binding|
  queue = ch.queue binding[:queue]

  if binding[:exchange].present?
    conf = AMQP_CONFIG[:exchange][binding[:exchange]]
    x = ch.send conf[:type], conf[:name]
    queue.bind x
  end

  queue.subscribe do |delivery_info, metadata, payload|
    logger.info "Received: #{payload}"
    begin
      worker.process JSON.parse(payload), metadata, delivery_info
    rescue Exception => e
      logger.fatal e
      logger.fatal e.backtrace.join("\n")
    end
  end
end

ch.work_pool.join
