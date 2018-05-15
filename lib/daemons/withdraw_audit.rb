# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  Withdraw.submitted.each do |withdraw|
    begin
      withdraw.audit!
    rescue
      puts "Error on withdraw audit: #{$!}"
      puts $!.backtrace.join("\n")
    end
  end

  sleep 5
end
