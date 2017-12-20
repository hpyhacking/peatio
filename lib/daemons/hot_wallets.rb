require File.join(ENV.fetch('RAILS_ROOT'), "config", "environment")

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  Currency.all.each do |currency|
    currency.refresh_balance if currency.coin?
  end

  sleep 5
end
