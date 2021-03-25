# encoding: UTF-8
# frozen_string_literal: true

require 'csv'

module API
  module V2
    module Admin
      class Trades < Grape::API
        helpers ::API::V2::Admin::Helpers

        content_type :csv, 'text/csv'

        desc 'Get all trades, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Trade
        params do
          optional :market,
                   values: { value: -> { ::Market.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :order_id,
                   type: Integer,
                   desc: -> { API::V2::Entities::Order.documentation[:id][:desc] }
          use :uid
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/trades' do
          admin_authorize! :read, ::Trade

          member = Member.find_by(uid: params[:uid]) if params[:uid].present?

          ransack_params = Helpers::RansackBuilder.new(params.except!(:uid))
                             .translate(market: :market_id)
                             .with_daterange
                             .merge(g: [
                               { maker_id_eq: member&.id, taker_id_eq: member&.id, m: 'or' },
                               { maker_order_id_eq: params[:order_id], taker_order_id_eq: params[:order_id], m: 'or' },
                             ]).build

          search = Trade.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          if params[:format] == 'csv'
            search.result
          else
            present paginate(search.result, false), with: API::V2::Admin::Entities::Trade
          end
        end

        desc 'Get a trade with detailed information.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.trade.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Trade.documentation[:id][:desc] }
        end
        get '/trades/:id' do
          admin_authorize! :read, ::Trade

          present Trade.find(params[:id]), with: API::V2::Admin::Entities::Trade, extended: true
        end
      end
    end
  end
end
