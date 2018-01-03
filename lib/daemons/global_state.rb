require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  all_tickers = {}
  Market.all.each do |market|
    global = Global[market.id]
    global.trigger_orderbook
    all_tickers[market.id] = market.unit_info.merge(global.ticker)
  end
  Global.trigger 'tickers', all_tickers

  sleep 3
end
