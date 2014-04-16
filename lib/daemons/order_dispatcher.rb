#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

dispatcher = Worker::OrderDispatcher.new

EM.run do
  puts "Daemon started at #{Time.now}"

  Signal.trap("INT")  { EM.stop_event_loop }
  Signal.trap("TERM") { EM.stop_event_loop }

  AMQP.connect(AMQP_CONFIG[:connect]) do |conn|
    puts "Connected to AMQP broker."

    channel = AMQP::Channel.new conn

    [:new_order, :cancel_order].each do |qid|
      channel.queue(AMQP_CONFIG[:queue][qid]).subscribe do |payload|
        puts "Received: #{payload}"
        begin
          dispatcher.send qid, JSON.parse(payload)
        rescue Exception => e
          puts "Fatal: #{e}"
          puts e.backtrace.join("\n")
        end
      end
    end
  end
end
