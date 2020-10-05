# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Tickers < Grape::API
        desc 'Get list of all available trading pairs'
        get "/tickers" do
          tickers = Rails.cache.fetch(:markets_tickers_coingecko, expires_in: 60) do
            ::Market.enabled.ordered.inject([]) do |hash, market|
              hash << TickersService[market].ticker.merge(market: market)
            end
          end

          present tickers, with: API::V2::CoinGecko::Entities::Ticker
        end
      end
    end
  end
end
