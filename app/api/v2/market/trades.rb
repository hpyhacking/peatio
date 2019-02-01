# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Trades < Grape::API
        helpers API::V2::NamedParams

        desc 'Get your executed trades. Trades are sorted in reverse creation order.',
          is_array: true,
          success: API::V2::Entities::Trade
        params do
          optional :market, type: String, desc: -> { V2::Entities::Market.documentation[:id] }, values: -> { ::Market.enabled.ids }
          use :trade_filters
        end
        get '/trades' do

          current_user.trades.order(order_param)
                      .tap { |q| q.where!(market: params[:market]) if params[:market] }
                      .tap { |q| present paginate(q), with: API::V2::Entities::Trade, current_user: current_user }
        end
      end
    end
  end
end
