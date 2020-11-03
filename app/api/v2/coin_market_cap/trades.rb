# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Trades < Grape::API
        desc 'Get recent trades on market'
        params do
          requires :market_pair,
                   type: String,
                   desc: 'A pair such as "LTC_BTC"',
                   coerce_with: ->(name) { name.strip.split('_').join.downcase }
        end
        get "/trades/:market_pair" do
          market = ::Market.find(params[:market_pair])
          Trade.public_from_influx(market.id).map { |trade| format_trade(trade) }
        end
      end
    end
  end
end
