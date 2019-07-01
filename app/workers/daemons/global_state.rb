# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class GlobalState < Base

      self.sleep_time = 5

      def process
        tickers = {}

        # NOTE: Turn off push notifications for disabled markets.
        Market.enabled.each do |market|
          state = Global[market.id]

          Peatio::MQ::Events.publish("public", market.id, "update", {
            asks: state.asks[0,300],
            bids: state.bids[0,300],
          })

          tickers[market.id] = market.unit_info.merge(state.ticker)
        end

        Peatio::MQ::Events.publish("public", "global", "tickers", tickers)

        tickers.clear
      end
    end
  end
end
