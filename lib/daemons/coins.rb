#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= 'development'

root = File.dirname(__dir__) until File.exist?(File.join(__dir__, 'config'))
Dir.chdir(root)

require File.join(root, 'config', 'environment')

@running = true

Signal.trap('TERM') do
  @running = false
end

while @running
  Currency.all.each do |currency|
    `rake coin:sync_deposit code=#{currency.code} reprocess=1`
  end

  sleep 10
end
