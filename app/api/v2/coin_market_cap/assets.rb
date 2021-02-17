# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Assets < Grape::API
        desc 'Details on crypto currencies available on the exchange'
        get '/assets' do
          Rails.cache.fetch(:currencies_cmc, expires_in: 600) do
            format_currencies(Currency.visible.coins.ordered.map)
          end
        end
      end
    end
  end
end
