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
                   values: { value: ->(v) { (Array.wrap(v) - ::Market.active.ids).blank? }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          optional :base_unit,
                   type: String,
                   values: { value: -> { ::Market.active.pluck(:base_unit) }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:base_unit] }
          optional :quote_unit,
                   type: String,
                   values: { value: -> { ::Market.active.pluck(:quote_unit) }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:quote_unit] }
          optional :state,
                   values: { value: ->(v) { (Array.wrap(v) - Order.state.values).blank? }, message: 'market.order.invalid_state' },
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
          optional :time_from,
                   type: { value: Integer, message: 'market.order.non_integer_time_from' },
                   allow_blank: { value: false, message: 'market.order.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders created after the time will be returned."
          optional :time_to,
                   type: { value: Integer, message: 'market.order.non_integer_time_to' },
                   allow_blank: { value: false, message: 'market.order.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders created before the time will be returned."
        end
        get '/orders' do
          user_authorize! :read, ::Order

          current_user.orders.order(updated_at: params[:order_by])
                      .tap { |q| q.where!(market: params[:market]) if params[:market] }
                      .tap { |q| q.where!(ask: params[:base_unit]) if params[:base_unit] }
                      .tap { |q| q.where!(bid: params[:quote_unit]) if params[:quote_unit] }
                      .tap { |q| q.where!(state: params[:state]) if params[:state] }
                      .tap { |q| q.where!(ord_type: params[:ord_type]) if params[:ord_type] }
                      .tap { |q| q.where!(type: (params[:type] == 'buy' ? 'OrderBid' : 'OrderAsk')) if params[:type] }
                      .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from] }
                      .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to] }
                      .tap { |q| present paginate(q, false), with: API::V2::Entities::Order }
        end

        desc 'Get information of specified order.',
          success: API::V2::Entities::Order
        params do
          use :order_id
        end
        get '/orders/:id' do
          user_authorize! :read, ::Order

          if params[:id].match?(/\A[0-9]+\z/)
            order = current_user.orders.find_by!(id: params[:id])
          elsif UUID.validate(params[:id])
            order = current_user.orders.find_by!(uuid: params[:id])
          else
            error!({ errors: ['market.order.invaild_id_or_uuid'] }, 422)
          end
          present order, with: API::V2::Entities::Order, type: :full
        end

        desc 'Create a Sell/Buy order.',
          success: API::V2::Entities::Order
        params do
          use :enabled_markets, :order
        end
        post '/orders' do
          user_authorize! :create, ::Order

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
          user_authorize! :update, ::Order

          begin
            if params[:id].match?(/\A[0-9]+\z/)
              order = current_user.orders.find_by!(id: params[:id])
            elsif UUID.validate(params[:id])
              order = current_user.orders.find_by!(uuid: params[:id])
            else
              error!({ errors: ['market.order.invaild_id_or_uuid'] }, 422)
            end
            order.trigger_cancellation
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
                   values: { value: -> { ::Market.active.ids }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          optional :side,
                   type: String,
                   values: %w(sell buy),
                   desc: 'If present, only sell orders (asks) or buy orders (bids) will be canncelled.'
        end
        post '/orders/cancel' do
          user_authorize! :update, ::Order

          begin
            orders = current_user.orders
                                 .with_state(:wait)
                                 .tap { |q| q.where!(market: params[:market]) if params[:market] }
            if params[:side].present?
              type = params[:side] == 'sell' ? 'OrderAsk' : 'OrderBid'
              orders = orders.where(type: type)
            end
            orders.map(&:trigger_cancellation)
            present orders, with: API::V2::Entities::Order
          rescue
            error!({ errors: ['market.order.cancel_error'] }, 422)
          end
        end
      end
    end
  end
end
