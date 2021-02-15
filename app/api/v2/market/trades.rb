# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Trades < Grape::API
        helpers API::V2::Market::NamedParams

        helpers do
          def opposite_type_param
            params[:type] == 'buy' ? 'sell' : 'buy'
          end
        end

        desc 'Get your executed trades. Trades are sorted in reverse creation order.',
             is_array: true,
             success: API::V2::Entities::Trade
        params do
          optional :market,
                   values: { value: ->(v) { (Array.wrap(v) - ::Market.active.ids).blank? }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          use :trade_filters
        end
        get '/trades' do
          user_authorize! :read, ::Trade

          current_user
            .trades
            .order(order_param)
            .tap { |q| q.where!('(taker_id = ? AND taker_type = ?) OR (maker_id = ? AND taker_type = ?)', current_user.id, params[:type], current_user.id, opposite_type_param) if params[:type] }
            .tap { |q| q.where!(market: params[:market]) if params[:market] }
            .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from] }
            .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to] }
            .tap { |q| present paginate(q, false), with: API::V2::Entities::Trade, current_user: current_user }
        end
      end
    end
  end
end
