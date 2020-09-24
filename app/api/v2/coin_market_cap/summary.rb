# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Summary < Grape::API
        desc 'Overview of market data for all tickers and all market pairs on the exchange'
        get '/summary' do
          Rails.cache.fetch(:markets_summary_cmc, expires_in: 60) do
            ::Market.enabled.ordered.map do |market|
              format_summary(TickersService[market].ticker, market)
            end
          end
        end
      end
    end
  end
end
