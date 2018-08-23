# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch("RAILS_ROOT"), "config", "environment")

require "peatio/mq/events"

$running = true
Signal.trap(:TERM) { $running = false }

while $running
  # NOTE: Turn off push notifications for disabled markets.
  Market.enabled.each do |market|
    state = Global[market.id]

    Peatio::MQ::Events.publish("public", market.id, "update", {
      asks: state.asks,
      bids: state.bids,
    })
  end

  Kernel.sleep 5
end
