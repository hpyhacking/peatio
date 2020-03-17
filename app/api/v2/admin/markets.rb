# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Markets < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          # Collection of shared params, used to
          # generate required/optional Grape params.
          OPTIONAL_MARKET_PARAMS ||= {
            amount_precision: {
              type: { value: Integer, message: 'admin.market.non_integer_amount_precision' },
              values: { value: -> (p){ p && p >= 0 }, message: 'admin.market.invalid_amount_precision' },
              default: 4,
              desc: -> { API::V2::Admin::Entities::Market.documentation[:amount_precision][:desc] }
            },
            price_precision: {
              type: { value: Integer, message: 'admin.market.non_integer_price_precision' },
              values: { value: -> (p){ p && p >= 0 }, message: 'admin.market.invalid_price_precision' },
              default: 4,
              desc: -> { API::V2::Admin::Entities::Market.documentation[:price_precision][:desc] }
            },
            max_price: {
              type: { value: BigDecimal, message: 'admin.market.non_decimal_max_price' },
              values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_max_price' },
              default: 0.0,
              desc: -> { API::V2::Admin::Entities::Market.documentation[:max_price][:desc] }
            },
            position: {
              type: { value: Integer, message: 'admin.market.non_integer_position' },
              default: 0,
              desc: -> { API::V2::Admin::Entities::Market.documentation[:position][:desc] }
            },
            data: {
              type: { value: JSON, message: 'admin.market.invalid_data' },
              default: {},
              desc: -> { API::V2::Admin::Entities::Market.documentation[:data][:desc] }
            },
            state: {
              values: { value: ::Market::STATES, message: 'admin.market.invalid_state' },
              default: 'enabled',
              desc: -> { API::V2::Admin::Entities::Market.documentation[:state][:desc] }
            },
          }

          params :create_market_params do
            OPTIONAL_MARKET_PARAMS.each do |key, params|
              optional key, params
            end
          end

          params :update_market_params do
            OPTIONAL_MARKET_PARAMS.each do |key, params|
              optional key, params.except(:default)
            end
          end
        end

        desc 'Get all markets, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Market
        params do
          use :pagination
          use :ordering
        end
        get '/markets' do
          authorize! :read, ::Market

          result = ::Market.order(params[:order_by] => params[:ordering])
          present paginate(result), with: API::V2::Admin::Entities::Market
        end

        desc 'Get market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
        end
        get '/markets/:id' do
          authorize! :read, ::Market

          present ::Market.find(params[:id]), with: API::V2::Admin::Entities::Market
        end

        desc 'Create new market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          use :create_market_params
          requires :base_currency,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:base_unit][:desc] }
          requires :quote_currency,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:quote_unit][:desc] }
          requires :min_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_price' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.market.invalid_min_price' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_price][:desc] }
          requires :min_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_amount' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.market.invalid_min_amount' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_amount][:desc] }
        end
        post '/markets/new' do
          authorize! :create, ::Market

          market = ::Market.new(declared(params))
          if market.save
            present market, with: API::V2::Admin::Entities::Market
            status 201
          else
            body errors: market.errors.full_messages
            status 422
          end
        end

        desc 'Update market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          use :update_market_params
          requires :id,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :min_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_price' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_price][:desc] }
          optional :min_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_amount' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_amount][:desc] }

        end
        post '/markets/update' do
          authorize! :write, ::Market

          market = ::Market.find(params[:id])
          if market.update(declared(params, include_missing: false))
            present market, with: API::V2::Admin::Entities::Market
          else
            body errors: market.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
