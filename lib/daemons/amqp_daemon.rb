#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

raise "bindings must be provided." if ARGV.size == 0

Rails.logger = logger = Logger.new STDOUT

conn = Bunny.new AMQPConfig.connect
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

ARGV.each do |id|
  worker= AMQPConfig.binding_worker(id)
  queue = ch.queue *AMQPConfig.binding_queue(id)

  if args = AMQPConfig.binding_exchange(id)
    x = ch.send *args
    attrs = { routing_key: AMQPConfig.routing_key(id) }
    queue.bind x, attrs
  end

  manual_ack = AMQPConfig.data[:binding][id][:manual_ack]
  queue.subscribe(manual_ack: manual_ack) do |delivery_info, metadata, payload|
    logger.info "Received: #{payload}"
    begin
      worker.process JSON.parse(payload), metadata, delivery_info
      ch.ack(delivery_info.delivery_tag) if manual_ack
    rescue Exception => e
      logger.fatal e
      logger.fatal e.backtrace.join("\n")
    end
  end
end

ch.work_pool.join
