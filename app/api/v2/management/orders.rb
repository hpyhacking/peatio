# frozen_string_literal: true

module API
  module V2
    module Management
      class Orders < Grape::API
        helpers ::API::V2::OrderHelpers

        desc 'Returns orders' do
          @settings[:scope] = :read_orders
          success API::V2::Management::Entities::Order
        end
        params do
          optional :uid,
                   values: { value: ->(v) { Member.exists?(uid: v) }, message: 'management.orders.uid_doesnt_exist' },
                   desc: 'Filter order by owner uid'
          optional :market,
                   values: { value: -> { ::Market.ids }, message: 'management.orders.market_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:id][:desc] }
          optional :state,
                   values: { value: -> { ::Order.state.values }, message: 'management.orders.invalid_state' },
                   desc: 'Filter order by state.'
          optional :ord_type,
                   values: { value: ::Order::TYPES, message: 'management.orders.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
        end
        post '/orders' do
          if params[:uid].present?
            member = Member.find_by(uid: params[:uid])
            params.merge!(member_id: member.id) if member.present?
          end

          ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                                  .eq(:ord_type, :state, :member_id)
                                                                  .translate(market: :market_id)
                                                                  .build

          search = Order.ransack(ransack_params)

          present search.result, with: API::V2::Management::Entities::Order
          status 200
        end

        desc 'Cancel specific order' do
          @settings[:scope] = :write_orders
          success API::V2::Management::Entities::Order
        end
        params do
          requires :id,
                   type: String,
                   allow_blank: false,
                   desc: -> { API::V2::Management::Entities::Order.documentation[:id][:desc] }
        end

        post '/orders/:id/cancel' do
          begin
            order = Order.find(params[:id])
            order.trigger_cancellation
            present order, with: API::V2::Management::Entities::Order
            status 200
          rescue ActiveRecord::RecordNotFound => e
            # RecordNotFound in rescued by ExceptionsHandler.
            raise(e)
          rescue
            error!({ errors: ['management.order.cancel_error'] }, 422)
          end
        end

        desc 'Cancel all open orders' do
          @settings[:scope] = :write_orders
          success API::V2::Management::Entities::Order
        end
        params do
          optional :uid,
                   values: { value: ->(v) { Member.exists?(uid: v) }, message: 'management.orders.uid_doesnt_exist' },
                   desc: 'Filter order by owner uid'
          requires :market,
                   values: { value: -> { ::Market.active.ids }, message: 'management.order.market_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:id][:desc] }
        end

        post '/orders/cancel' do
          if params[:uid].present?
            member = Member.find_by(uid: params[:uid])
            params.merge!(member_id: member.id) if member.present?
          end

          market = ::Market.find(params[:market])
          market_engine = market.engine

          if market_engine.peatio_engine?
            ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                                    .eq(:member_id, state: 'wait')
                                                                    .translate(market: :market_id)
                                                                    .build

            orders = Order.ransack(ransack_params).result
            orders.map(&:trigger_internal_cancellation)
          else
            filters = {
              market_id: market.id,
              member_uid: params[:uid]
            }.compact

            Order.trigger_bulk_cancel_third_party(market_engine.driver, filters)
          end
          status 204
        end
      end
    end
  end
end
