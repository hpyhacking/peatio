require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

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
