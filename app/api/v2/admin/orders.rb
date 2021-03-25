# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Orders < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers ::API::V2::OrderHelpers

        content_type :csv, 'text/csv'

        desc 'Get all orders, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Order
        params do
          optional :market,
                   values: { value: -> { ::Market.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :state,
                   values: { value: -> { ::Order.state.values }, message: 'admin.order.invalid_state' },
                   desc: 'Filter order by state.'
          optional :ord_type,
                   values: { value: ::Order::TYPES, message: 'admin.order.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
          optional :price,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_price' },
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:price][:desc] }
          optional :origin_volume,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_origin_volume' },
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:origin_volume][:desc] }
          optional :type,
                   values: { value: %w(sell buy), message: 'admin.order.invalid_type' },
                   desc: 'Filter order by type.'
          optional :email,
                   desc: -> { API::V2::Entities::Member.documentation[:email][:desc] }
          use :uid
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/orders' do
          admin_authorize! :read, ::Order

          if params[:uid].present? || params[:email].present?
            member = Member.find_by('uid = ? OR email = ?', params[:uid], params[:email])
            params.except!(:uid, :email).merge!(member_id: member.id) if member.present?
          end

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:price, :origin_volume, :ord_type, :state, :member_id)
                             .translate(market: :market_id)
                             .with_daterange
                             .merge({
                                type_eq: params[:type].present? ? params[:type] == 'buy' ? 'OrderBid' : 'OrderAsk' : nil
                             }).build

          search = Order.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          if params[:format] == 'csv'
            search.result
          else
            present paginate(search.result, false), with: API::V2::Admin::Entities::Order
          end
        end

        desc 'Cancel an order.'
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.order.non_integer_id' },
                   allow_blank: false,
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:id][:desc] }
        end
        post '/orders/:id/cancel' do
          admin_authorize! :update, ::Order

          begin
            order = Order.find(params[:id])
            order.trigger_cancellation
            present order, with: API::V2::Admin::Entities::Order
          rescue ActiveRecord::RecordNotFound => e
            # RecordNotFound in rescued by ExceptionsHandler.
            raise(e)
          rescue
            error!({ errors: ['admin.order.cancel_error'] }, 422)
          end
        end

        desc 'Cancel all orders.'
        params do
          requires :market,
                   values: { value: -> { ::Market.active.ids }, message: 'admin.order.market_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:id][:desc] }
          optional :side,
                   values: { value: %w(sell buy), message: 'admin.order.invalid_side' },
                   desc: 'If present, only sell orders (asks) or buy orders (bids) will be cancelled.'
        end
        post '/orders/cancel' do
          admin_authorize! :update, ::Order

          begin
            ransack_params = Helpers::RansackBuilder.new(params)
                                    .eq(state: 'wait')
                                    .translate(market: :market_id)
                                    .merge({
                                      type_eq: params[:side].present? ? params[:side] == 'buy' ? 'OrderBid' : 'OrderAsk' : nil,
                                    }).build

            orders = Order.ransack(ransack_params)
            orders.result.map(&:trigger_cancellation)
            present orders.result, with: API::V2::Entities::Order
          rescue
            error!({ errors: ['admin.order.cancel_error'] }, 422)
          end
        end
      end
    end
  end
end
