# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Orderbook < Grape::API
        desc 'Get depth or specified market'
        params do
          requires :market_pair,
                   type: String,
                   desc: 'A pair such as "LTC_BTC"',
                   coerce_with: ->(name) { name.strip.split('_').join.downcase }
          optional :depth,
                   type: { value: Integer, message: 'coinmarketcap.market_depth.non_integer_depth' },
                   values: { value: 0..500, message: 'coinmarketcap.market_depth.invalid_depth' },
                   desc: 'Orders depth quantity: [0,5,10,20,50,100,500]'
        end
        get "/orderbook/:market_pair" do
          market = ::Market.find(params[:market_pair])
          asks = OrderAsk.get_depth(market.id)
          bids = OrderBid.get_depth(market.id)

          # Depth = 100 means 50 for each bid/ask side
          # Not defined or 0 = full order book
          unless params[:depth].to_d.zero?
            asks = asks[0, params[:depth]/2]
            bids = bids[0, params[:depth]/2]
          end

          format_orderbook(asks, bids)
        end
      end
    end
  end
end
