# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap(:TERM) { $running = false }

while $running do
  tickers = {}

  Market.find_each do |market|
    global = Global[market.id]
    Pusher.trigger("market-#{market.id}-global", :update, asks: global.asks, bids: global.bids)
    tickers[market.id] = market.unit_info.merge(global.ticker)
  end

  Pusher.trigger('market-global', :tickers, tickers)

  tickers.clear

  Kernel.sleep 5
end
