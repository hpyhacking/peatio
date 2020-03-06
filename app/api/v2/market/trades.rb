# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Trades < Grape::API
        helpers API::V2::Market::NamedParams

        desc 'Get your executed trades. Trades are sorted in reverse creation order.',
          is_array: true,
          success: API::V2::Entities::Trade
        params do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          use :trade_filters
        end
        get '/trades' do
          current_user
            .trades
            .order(order_param)
            .tap { |q| q.where!(market: params[:market]) if params[:market] }
            .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from] }
            .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to] }
            .tap { |q| present paginate(q, false), with: API::V2::Entities::Trade, current_user: current_user }
        end
      end
    end
  end
end
