# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Trades < Grape::API
        helpers API::V2::NamedParams

        desc 'Get your executed trades. Trades are sorted in reverse creation order.', scopes: %w(history)
        params do
          use :market, :trade_filters
        end
        get '/trades' do
          authenticate!
          trading_must_be_permitted!

          trades = Trade.for_member(
            params[:market], current_user,
            limit: params[:limit], time_to: time_to,
            from: params[:from], to: params[:to],
            order: order_param
          )

          present trades, with: API::V2::Entities::Trade, current_user: current_user
        end

      end
    end
  end
end
