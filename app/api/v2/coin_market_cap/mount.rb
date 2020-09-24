# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Mount < Grape::API
        before { set_ets_context! }

        helpers CoinMarketCap::Helpers

        mount CoinMarketCap::Summary
        mount CoinMarketCap::Assets
        mount CoinMarketCap::Ticker
        mount CoinMarketCap::Trades
        mount CoinMarketCap::Orderbook
      end
    end
  end
end
