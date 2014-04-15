#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

def get_exchange(channel, id)
  name = AMQP_CONFIG[:exchange][id][:name]
  type = AMQP_CONFIG[:exchange][id][:type]
  channel.send type, name
end

worker = Worker::Pusher.new
queue  = AMQP_CONFIG[:queue][:pusher]

EM.run do
  puts "Daemon started at #{Time.now}"

  Signal.trap("INT")  { EM.stop_event_loop }
  Signal.trap("TERM") { EM.stop_event_loop }

  AMQP.connect(AMQP_CONFIG[:connect]) do |conn|
    puts "Connected to AMQP broker."

    channel = AMQP::Channel.new conn

    queue = channel.queue(queue)
      .bind(get_exchange(channel, :trade_after_strike))
    queue.subscribe do |payload|
      puts "Received: #{payload}"
      begin
        worker.publish_trade JSON.parse(payload)
      rescue Exception => e
        puts "Fatal: #{e}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
