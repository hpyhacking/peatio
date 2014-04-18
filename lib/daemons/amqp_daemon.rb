#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

raise "Worker name must be provided." if ARGV.size != 1

worker = "Worker::#{ARGV[0].camelize}".constantize.new
queue  = AMQP_CONFIG[:queue][ARGV[0].to_sym]

conn = Bunny.new AMQP_CONFIG[:connect]
conn.start

ch = conn.create_channel
puts "Connected to AMQP broker."

terminate = proc do
  puts "Terminating threads .."
  ch.work_pool.kill
  puts "Stopped."
end
Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

ch.queue(queue).subscribe(block: true) do |delivery_info, metadata, payload|
  puts "Received: #{payload}"
  begin
    worker.process JSON.parse(payload)
  rescue Exception => e
    puts "Fatal: #{e}"
    puts e.backtrace.join("\n")
  end
end
