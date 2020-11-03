# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class HistoricalTrades < Grape::API
        desc 'Get recent trades on market'
        params do
          requires :ticker_id,
                   type: String,
                   desc: 'A pair such as "LTC_BTC"',
                   coerce_with: ->(name) { name.strip.split('_').join.downcase }
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'coingecko.historical_trades.invalid_type' },
                   desc: 'To indicate nature of trade - buy/sell'
          optional :limit,
                   type: Integer,
                   values: { value: 0..1000, message: 'coingecko.historical_trades.invalid_limit' },
                   desc: 'Number of historical trades to retrieve from time of query. [0, 200, 500...]. 0 returns full history'
          optional :start_time,
                   type: Integer,
                   desc: '',
                   coerce_with: ->(start_time) { Time.parse(start_time).to_i }
          optional :end_time,
                   type: Integer,
                   desc: '',
                   coerce_with: ->(end_time) { Time.parse(end_time).to_i }
        end
        get '/historical_trades' do
          market = ::Market.find(params[:ticker_id])

          filters = declared(params, include_missing: false)
                    .except(:ticker_id, :limit)

          Trade.public_from_influx(market.id, params[:limit], filters).each_with_object({'buy' => [], 'sell' => []}) do |trade, hash|
            hash[trade[:taker_type]] << format_trade(trade)
          end
        end
      end
    end
  end
end
