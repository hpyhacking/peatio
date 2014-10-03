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

while($running) do
  PaymentTransaction::Normal.with_aasm_state(:unconfirm, :confirming).each do |tx|
    begin
      tx.with_lock do
        tx.check!
      end
    rescue
      puts "Error on PaymentTransaction::Normal: #{$!}"
      puts $!.backtrace.join("\n")
      next
    end
  end

  sleep 5
end
