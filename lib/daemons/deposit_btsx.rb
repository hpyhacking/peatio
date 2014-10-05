#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do
  $running = false
end

Rails.logger = Logger.new STDOUT

currency       = Currency.find_by_code 'btsx'
channel        = DepositChannel.find_by_key 'bitsharesx'
last_block_num = ENV['BLOCK_NUM'].to_i
duration       = 5 # half of block produce duration
worker         = Worker::DepositBitshares.new currency, channel, last_block_num

while($running) do
  begin
    worker.process
  rescue
    Rails.logger.error "Worker failure: #{$!}"
    Rails.logger.error $!.backtrace.join("\n")
  end

  sleep duration
end
