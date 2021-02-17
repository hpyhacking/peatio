# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Ticker < Grape::API
        desc 'Get 24-hour pricing and volume summary for each market pair'
        get '/ticker' do
          Rails.cache.fetch(:markets_tickers_cmc, expires_in: 60) do
            format_tickers(::Market.enabled.ordered)
          end
        end
      end
    end
  end
end
