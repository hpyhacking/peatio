# frozen_string_literal: true

module API
  module V2
    module Public
      class Config < Grape::API
        get '/config' do
          present :currencies, Rails.cache.fetch(:public_currencies, expires_in: 600) { ::Currency.active },
                  with: API::V2::Entities::Currency
          present :trading_fees, Rails.cache.fetch(:public_trading_fees, expires_in: 600) { ::TradingFee.all },
                  with: API::V2::Entities::TradingFee
          present :markets, Rails.cache.fetch(:public_markets, expires_in: 600) { ::Market.active },
                  with: API::V2::Entities::Market
          present :withdraw_limits, Rails.cache.fetch(:public_withdraw_limits, expires_in: 600) { ::WithdrawLimit.all },
                  with: API::V2::Entities::WithdrawLimit
        end
      end
    end
  end
end
