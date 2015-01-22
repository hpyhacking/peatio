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
id = $0.split(':')[2]
prefetch = AMQPConfig.channel(id)[:prefetch] || 0
ch.prefetch(prefetch) if prefetch > 0
logger.info "Connected to AMQP broker (prefetch: #{prefetch > 0 ? prefetch : 'default'})"

terminate = proc do
  # logger is forbidden in signal handling, just use puts here
  puts "Terminating threads .."
  ch.work_pool.kill
  puts "Stopped."
end
Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

workers = []
ARGV.each do |id|
  worker = AMQPConfig.binding_worker(id)
  queue  = ch.queue *AMQPConfig.binding_queue(id)

  if args = AMQPConfig.binding_exchange(id)
    x = ch.send *args

    case args.first
    when 'direct'
      queue.bind x, routing_key: AMQPConfig.routing_key(id)
    when 'topic'
      AMQPConfig.topics(id).each do |topic|
        queue.bind x, routing_key: topic
      end
    else
      queue.bind x
    end
  end

  clean_start = AMQPConfig.data[:binding][id][:clean_start]
  queue.purge if clean_start

  manual_ack  = AMQPConfig.data[:binding][id][:manual_ack]
  queue.subscribe(manual_ack: manual_ack) do |delivery_info, metadata, payload|
    logger.info "Received: #{payload}"
    begin
      worker.process JSON.parse(payload), metadata, delivery_info
    rescue Exception => e
      logger.fatal e
      logger.fatal e.backtrace.join("\n")
    ensure
      ch.ack(delivery_info.delivery_tag) if manual_ack
    end
  end

  workers << worker
end

%w(USR1 USR2).each do |signal|
  Signal.trap(signal) do
    puts "#{signal} received."
    handler = "on_#{signal.downcase}"
    workers.each {|w| w.send handler if w.respond_to?(handler) }
  end
end

ch.work_pool.join
