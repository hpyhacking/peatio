# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Orderbook < Grape::API
        class OrderBook < Struct.new(:market, :asks, :bids); end

        desc 'Get depth or specified market'
        params do
          requires :ticker_id,
                   type: String,
                   desc: 'A pair such as "LTC_BTC"',
                   coerce_with: ->(name) { name.strip.split('_').join.downcase }
          optional :depth,
                   type: { value: Integer, message: 'coingecko.market_depth.non_integer_depth' },
                   values: { value: 0..1000, message: 'coingecko.market_depth.invalid_depth' },
                   desc: 'Orders depth quantity: [0, 100, 200, 500...]'
        end

        get '/orderbook' do
          market = ::Market.find(params[:ticker_id])
          asks = OrderAsk.get_depth(market.id)
          bids = OrderBid.get_depth(market.id)

          # Depth = 100 means 50 for each bid/ask side
          # Not defined or 0 = full order book
          unless params[:depth].to_d.zero?
            asks = asks[0, params[:depth]/2]
            bids = bids[0, params[:depth]/2]
          end

          orderbook = OrderBook.new market, asks, bids
          present orderbook, with: API::V2::CoinGecko::Entities::Orderbook
        end
      end
    end
  end
end
