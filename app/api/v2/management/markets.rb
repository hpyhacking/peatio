# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Markets < Grape::API
        helpers do
          # Collection of shared params, used to
          # generate required/optional Grape params.
          OPTIONAL_MARKET_PARAMS ||= {
            amount_precision: {
              type: { value: Integer, message: 'management.market.non_integer_amount_precision' },
              values: { value: -> (p){ p && p >= 0 }, message: 'management.market.invalid_amount_precision' },
              default: 4,
              desc: -> { API::V2::Management::Entities::Market.documentation[:amount_precision][:desc] }
            },
            price_precision: {
              type: { value: Integer, message: 'management.market.non_integer_price_precision' },
              values: { value: -> (p){ p && p >= 0 }, message: 'management.market.invalid_price_precision' },
              default: 4,
              desc: -> { API::V2::Management::Entities::Market.documentation[:price_precision][:desc] }
            },
            max_price: {
              type: { value: BigDecimal, message: 'management.market.non_decimal_max_price' },
              values: { value: -> (p){ p >= 0 }, message: 'management.market.invalid_max_price' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Market.documentation[:max_price][:desc] }
            },
            state: {
              values: { value: ::Market::STATES, message: 'management.market.invalid_state' },
              default: 'enabled',
              desc: -> { API::V2::Management::Entities::Market.documentation[:state][:desc] }
            },
          }

          params :create_market_params do
            OPTIONAL_MARKET_PARAMS.each do |key, params|
              optional key, params
            end
          end
        end

        # POST: api/v2/management/markets/new
        desc 'Create market.' do
          @settings[:scope] = :write_markets
          success API::V2::Management::Entities::Market
        end
        params do
          use :create_market_params
          requires :base_currency,
                   values: { value: -> { ::Currency.ids }, message: 'management.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:base_unit][:desc] }
          requires :quote_currency,
                   values: { value: -> { ::Currency.ids }, message: 'management.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:quote_unit][:desc] }
          requires :min_price,
                   type: { value: BigDecimal, message: 'management.market.non_decimal_min_price' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'management.market.invalid_min_price' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_price][:desc] }
          requires :min_amount,
                   type: { value: BigDecimal, message: 'management.market.non_decimal_min_amount' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'management.market.invalid_min_amount' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_amount][:desc] }
          optional :engine_id,
                   type: { value: Integer, message: 'management.market.non_integer_engine_id' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:engine_id][:desc] }
          optional :position,
                   type: { value: Integer, message: 'management.market.non_integer_position' },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:position][:desc] }
          optional :engine_name,
                   values: { value: -> { ::Engine.pluck(:name) }, message: 'management.market.engine_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Engine.documentation[:name][:desc] }
          exactly_one_of :engine_id, :engine_name, message: 'management.market.one_of_engine_id_engine_name_fields'
        end
        post '/markets/new' do
          market = ::Market.new(declared(params, include_missing: false))
          if market.save
            present market, with: API::V2::Management::Entities::Market
            status 201
          else
            body errors: market.errors.full_messages
            status 422
          end
        end

        # PUT: api/v2/management/markets/update
        desc 'Update market.' do
          @settings[:scope] = :write_markets
          success API::V2::Management::Entities::Market
        end
        params do
          # TODO: Id parameter should be deprecated and changed to symbol
          optional :id,
                   type: String,
                   values: { value: -> { ::Market.pluck(:symbol) } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:id][:desc] }
          optional :symbol,
                   type: String,
                   values: { value: -> { ::Market.pluck(:symbol) } },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:symbol][:desc] }
          optional :engine_id,
                   type: Integer,
                   desc: -> { API::V2::Management::Entities::Market.documentation[:engine_id][:desc] }
          optional :type,
                   type: { value: String },
                   values: { value: -> { ::Market::TYPES }},
                   default: -> { ::Market::DEFAULT_TYPE }
          optional :state,
                   type: String,
                   values: { value: ::Market::STATES },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:state][:desc] }
          optional :min_price,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_price][:desc] }
          optional :min_amount,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_amount][:desc] }
          optional :amount_precision,
                   type: { value: Integer },
                   values: { value: ->(p) { p && p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:amount_precision][:desc] }
          optional :price_precision,
                   type: { value: Integer },
                   values: { value: ->(p) { p && p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:price_precision][:desc] }
          optional :max_price,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:max_price][:desc] }
          optional :position,
                   type: { value: Integer },
                   values: { value: -> (p){ p >= ::Market::TOP_POSITION } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:position][:desc] }

          exactly_one_of :id, :symbol
        end
        put '/markets/update' do
          symbol = params[:symbol].present? ? params[:symbol] : params[:id]
          market = ::Market.find_by_symbol_and_type(symbol, params[:type])
          if market.update(declared(params, include_missing: false).except(:id, :symbol))
            present market, with: API::V2::Management::Entities::Market
          else
            body errors: market.errors.full_messages
            status 422
          end
        end

        # POST: api/v2/management/markets/list
        desc 'Return list of the markets.' do
          @settings[:scope] = :read_markets
          success API::V2::Management::Entities::Market
        end

        params do
          optional :type,
                   type: { value: String },
                   values: { value: -> { ::Market::TYPES }},
                   default: -> { ::Market::DEFAULT_TYPE }
        end

        post '/markets/list' do
          present ::Market.where(type: params[:type]).ordered, with: API::V2::Management::Entities::Market
          status 200
        end

        # POST: api/v2/management/markets/:symbol
        desc 'Returns market by symbol.' do
          @settings[:scope] = :read_markets
          success API::V2::Management::Entities::Market
        end
        params do
          requires :symbol,
                   type: String,
                   desc: -> { API::V2::Management::Entities::Market.documentation[:id][:desc] }
          optional :type,
                   type: { value: String },
                   values: { value: -> { ::Market::TYPES }},
                   default: -> { ::Market::DEFAULT_TYPE }
        end
        post '/markets/:symbol' do
          present ::Market.find_by_symbol_and_type(params[:symbol], params[:type]), with: API::V2::Management::Entities::Market
        end
      end
    end
  end
end
