# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Pairs < Grape::API
        desc 'Get list of all available trading pairs'
        get "/pairs" do
          present Rails.cache.fetch(:markets_coingecko, expires_in: 60) { ::Market.enabled.ordered },
                  with: API::V2::CoinGecko::Entities::Pair
        end
      end
    end
  end
end
