# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch("RAILS_ROOT"), "config", "environment")

require "peatio/mq/events"

$running = true
Signal.trap(:TERM) { $running = false }

while $running
  tickers = {}

  # NOTE: Turn off push notifications for disabled markets.
  Market.enabled.each do |market|
    state = Global[market.id]

    Peatio::MQ::Events.publish("public", market.id, "update", {
      asks: state.asks,
      bids: state.bids,
    })

    tickers[market.id] = market.unit_info.merge(state.ticker)
  end

  Peatio::MQ::Events.publish("public", "global", "tickers", tickers)

  tickers.clear

  Kernel.sleep 5
end
