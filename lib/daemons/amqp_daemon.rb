# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

raise "bindings must be provided." if ARGV.size == 0

logger = Rails.logger

conn = Bunny.new AMQP::Config.connect
conn.start

ch = conn.create_channel
id = $0.split(':')[2]
prefetch = AMQP::Config.channel(id)[:prefetch] || 0
ch.prefetch(prefetch) if prefetch > 0
logger.info { "Connected to AMQP broker (prefetch: #{prefetch > 0 ? prefetch : 'default'})" }

terminate = proc do
  # logger is forbidden in signal handling, just use puts here
  puts "Terminating threads .."
  ch.work_pool.kill
  puts "Stopped."
end

at_exit { conn.close }

Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

workers = []
ARGV.each do |id|
  worker = AMQP::Config.binding_worker(id)
  queue  = ch.queue *AMQP::Config.binding_queue(id)

  if args = AMQP::Config.binding_exchange(id)
    x = ch.send *args

    case args.first
    when 'direct'
      queue.bind x, routing_key: AMQP::Config.routing_key(id)
    when 'topic'
      AMQP::Config.topics(id).each do |topic|
        queue.bind x, routing_key: topic
      end
    else
      queue.bind x
    end
  end

  clean_start = AMQP::Config.data[:binding][id][:clean_start]
  queue.purge if clean_start

  # Enable manual acknowledge mode by setting manual_ack: true.
  queue.subscribe manual_ack: true do |delivery_info, metadata, payload|
    logger.info { "Received: #{payload}" }
    begin

      # Invoke Worker#process with floating number of arguments.
      args          = [JSON.parse(payload), metadata, delivery_info]
      arity         = worker.method(:process).arity
      resized_args  = arity < 0 ? args : args[0...arity]
      worker.process(*resized_args)

      # Send confirmation to RabbitMQ that message has been successfully processed.
      # See http://rubybunny.info/articles/queues.html
      ch.ack(delivery_info.delivery_tag)

    rescue StandardError => e

      # Ask RabbitMQ to deliver message once again later.
      # See http://rubybunny.info/articles/queues.html
      ch.nack(delivery_info.delivery_tag, false, true)

      if worker.is_db_connection_error?(e)
        logger.error(db: :unhealthy, message: e.message)
        exit(1)
      end

      report_exception(e)
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
