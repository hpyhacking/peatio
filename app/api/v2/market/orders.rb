# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Orders < Grape::API
        helpers ::API::V2::Market::NamedParams

        desc 'Get your orders, result is paginated.',
          is_array: true,
          success: API::V2::Entities::Order
        params do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          optional :state,
                   values: { value: ->(v) { [*v].all? { |value| value.in? Order.state.values } }, message: 'market.order.invalid_state' },
                   desc: 'Filter order by state.'
          optional :limit,
                   type: { value: Integer, message: 'market.order.non_integer_limit' },
                   values: { value: 0..1000, message: 'market.order.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned orders, default to 100.'
          optional :page,
                   type: { value: Integer, message: 'market.order.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'market.order.invalid_order_by' },
                   default: 'desc',
                   desc: 'If set, returned orders will be sorted in specific order, default to "desc".'
          optional :ord_type,
                   type: String,
                   values: { value: Order::TYPES, message: 'market.order.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'market.order.invalid_type' },
                   desc: 'Filter order by type.'
        end
        get '/orders' do
          current_user.orders.order(updated_at: params[:order_by])
                      .tap { |q| q.where!(market: params[:market]) if params[:market] }
                      .tap { |q| q.where!(state: params[:state]) if params[:state] }
                      .tap { |q| q.where!(ord_type: params[:ord_type]) if params[:ord_type] }
                      .tap { |q| q.where!(type: (params[:type] == 'buy' ? 'OrderBid' : 'OrderAsk')) if params[:type] }
                      .tap { |q| present paginate(q, false), with: API::V2::Entities::Order }
        end

        desc 'Get information of specified order.',
          success: API::V2::Entities::Order
        params do
          use :order_id
        end
        get '/orders/:id' do
          order = current_user.orders.find_by!(id: params[:id])
          present order, with: API::V2::Entities::Order, type: :full
        end

        desc 'Create a Sell/Buy order.',
          success: API::V2::Entities::Order
        params do
          use :enabled_markets, :order
        end
        post '/orders' do
          if params[:ord_type] == 'market' && params.key?(:price)
            error!({ errors: ['market.order.market_order_price'] }, 422)
          end
          order = create_order(params)
          present order, with: API::V2::Entities::Order
        end

        desc 'Cancel an order.'
        params do
          use :order_id
        end
        post '/orders/:id/cancel' do
          begin
            order = current_user.orders.find(params[:id])
            cancel_order(order)
            present order, with: API::V2::Entities::Order
          rescue ActiveRecord::RecordNotFound => e
            # RecordNotFound in rescued by ExceptionsHandler.
            raise(e)
          rescue
            error!({ errors: ['market.order.cancel_error'] }, 422)
          end
        end

        desc 'Cancel all my orders.',
          success: API::V2::Entities::Order
        params do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          optional :side,
                   type: String,
                   values: %w(sell buy),
                   desc: 'If present, only sell orders (asks) or buy orders (bids) will be canncelled.'
        end
        post '/orders/cancel' do
          begin
            orders = current_user.orders
                                 .with_state(:wait)
                                 .tap { |q| q.where!(market: params[:market]) if params[:market] }
            if params[:side].present?
              type = params[:side] == 'sell' ? 'OrderAsk' : 'OrderBid'
              orders = orders.where(type: type)
            end
            orders.each { |o| cancel_order(o) }
            present orders, with: API::V2::Entities::Order
          rescue
            error!({ errors: ['market.order.cancel_error'] }, 422)
          end
        end
      end
    end
  end
end
