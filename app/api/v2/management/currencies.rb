# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Currencies < Grape::API
        helpers do
          OPTIONAL_CURRENCY_PARAMS ||= {
            name: { desc: -> { API::V2::Management::Entities::Currency.documentation[:name][:desc] } },
            deposit_fee: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_deposit_fee' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_deposit_fee' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:deposit_fee][:desc] }
            },
            min_deposit_amount: {
              type: { value: BigDecimal, message: 'management.currency.min_deposit_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.min_deposit_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:min_deposit_amount][:desc] }
            },
            min_collection_amount: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_min_collection_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_min_collection_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:min_collection_amount][:desc] }
            },
            withdraw_fee: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_fee' },
              values: { value: -> (p){ p >= 0  }, message: 'management.currency.ivalid_withdraw_fee' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_fee][:desc] }
            },
            min_withdraw_amount: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_min_withdraw_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_min_withdraw_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:min_withdraw_amount][:desc] }
            },
            withdraw_limit_24h: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_limit_24h' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_withdraw_limit_24h' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_limit_24h][:desc] }
            },
            withdraw_limit_72h: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_limit_72h' },
              values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_withdraw_limit_72h' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_limit_72h][:desc] }
            },
            options: {
              type: { value: JSON, message: 'management.currency.non_json_options' },
              default: {},
              desc: -> { API::V2::Management::Entities::Currency.documentation[:options][:desc] }
            },
            visible: {
              type: { value: Boolean, message: 'management.currency.non_boolean_visible' },
              default: true,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:visible][:desc] }
            },
            deposit_enabled: {
              type: { value: Boolean, message: 'management.currency.non_boolean_deposit_enabled' },
              default: true,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:deposit_enabled][:desc] }
            },
            withdrawal_enabled: {
              type: { value: Boolean, message: 'management.currency.non_boolean_withdrawal_enabled' },
              default: true,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:withdrawal_enabled][:desc] }
            },
            precision: {
              type: { value: Integer, message: 'management.currency.non_integer_base_precision' },
              default: 8,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:precision][:desc] }
            },
            price: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_price' },
              desc: -> { API::V2::Management::Entities::Currency.documentation[:price][:desc] }
            },
            icon_url: { desc: -> { API::V2::Management::Entities::Currency.documentation[:icon_url][:desc] } },
            description: { desc: -> { API::V2::Management::Entities::Currency.documentation[:description][:desc] } },
            homepage: { desc: -> { API::V2::Management::Entities::Currency.documentation[:homepage][:desc] } },
          }

          params :create_currency_params do
            OPTIONAL_CURRENCY_PARAMS.each do |key, params|
              optional key, params
            end
          end
        end

        # POST: api/v2/management/currencies/list
        desc 'Return currencies list.' do
          @settings[:scope] = :read_currencies
          success API::V2::Management::Entities::Currency
        end
        params do
          optional :type,
                   type: String,
                   values: { value: %w[fiat coin], message: 'management.currency.invalid_type' },
                   desc: -> { API::V2::Entities::Currency.documentation[:type][:desc] }
        end
        post '/currencies/list' do
          currencies = Currency.all
          currencies = currencies.where(type: params[:type]).includes(:blockchain) if params[:type] == 'coin'
          currencies = currencies.where(type: params[:type]) if params[:type] == 'fiat'
          present currencies.ordered, with: API::V2::Entities::Currency

          status 200
        end

        # POST: api/v2/management/currencies/new
        desc 'Create currency.' do
          @settings[:scope] = :read_currencies
          success API::V2::Management::Entities::Currency
        end
        params do
          use :create_currency_params
          requires :code,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:code][:desc] }
          optional :type,
                   values: { value: ::Currency.types.map(&:to_s), message: 'management.currency.invalid_type' },
                   default: 'coin',
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:type][:desc] }
          optional :base_factor,
                   type: { value: Integer, message: 'management.currency.non_integer_base_factor' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:base_factor][:desc] }
          optional :position,
                   type: { value: Integer, message: 'management.currency.non_integer_position' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:position][:desc] }
          optional :subunits,
                   type: { value: Integer, message: 'management.currency.non_integer_subunits' },
                   values: { value: (0..18), message: 'management.currency.invalid_subunits' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:subunits][:desc] }
          given type: ->(val) { val == 'coin' } do
            optional :blockchain_key,
                     values: { value: -> { ::Blockchain.pluck(:key) }, message: 'management.currency.blockchain_key_doesnt_exist' },
                     desc: -> { 'Associated blockchain key which will perform transactions synchronization for currency.' }
            optional :parent_id,
                     values: { value: -> { Currency.coins_without_tokens.pluck(:id).map(&:to_s) }, message: 'management.currency.parent_id_doesnt_exist' },
                     desc: -> { API::V2::Management::Entities::Currency.documentation[:parent_id][:desc] }
          end
          mutually_exclusive :base_factor, :subunits, message: 'management.currency.one_of_base_factor_subunits_fields'
        end
        post '/currencies/create' do
          currency = Currency.new(declared(params, include_missing: false))
          if currency.save
            present currency, with: API::V2::Management::Entities::Currency
            status 201
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end

        # POST: api/v2/management/currencies
        desc 'Returns currency by code.' do
          @settings[:scope] = :read_currencies
          success API::V2::Management::Entities::Currency
        end

        params do
          requires :code, type: String, desc: 'The currency code.'
        end
        post '/currencies/:code', requirements: { code: /[\w\.\-]+/ } do
          present Currency.find_by!(params.slice(:code)), with: API::V2::Management::Entities::Currency
        end

        desc 'Update currency.' do
          @settings[:scope] = :write_currencies
          success API::V2::Management::Entities::Currency
        end
        params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:id][:desc] }
          optional :name, desc: -> { API::V2::Management::Entities::Currency.documentation[:name][:desc] }
          optional :deposit_fee,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_deposit_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_deposit_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:deposit_fee][:desc] }
          optional :min_deposit_amount,
                   type: { value: BigDecimal, message: 'management.currency.min_deposit_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_min_deposit_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:min_deposit_amount][:desc] }
          optional :min_collection_amount,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_min_collection_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_min_collection_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:min_collection_amount][:desc] }
          optional :withdraw_fee,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_fee' },
                   values: { value: -> (p){ p >= 0  }, message: 'management.currency.invalid_withdraw_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_fee][:desc] }
          optional :min_withdraw_amount,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_min_withdraw_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_min_withdraw_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:min_withdraw_amount][:desc] }
          optional :withdraw_limit_24h,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_limit_24h' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_withdraw_limit_24h' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_limit_24h][:desc] }
          optional :withdraw_limit_72h,
                   type: { value: BigDecimal, message: 'management.currency.non_decimal_withdraw_limit_72h' },
                   values: { value: -> (p){ p >= 0 }, message: 'management.currency.invalid_withdraw_limit_72h' },
                   default: 0.0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:withdraw_limit_72h][:desc] }
          optional :position,
                   type: { value: Integer, message: 'management.currency.non_integer_position' },
                   values: { value: -> (p){ p >= ::Currency::TOP_POSITION }, message: 'management.currency.invalid_position' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:position][:desc] }
          optional :options,
                   type: { value: JSON, message: 'management.currency.non_json_options' },
                   default: {},
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:options][:desc] }
          optional :visible,
                   type: { value: Boolean, message: 'management.currency.non_boolean_visible' },
                   default: true,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:visible][:desc] }
          optional :deposit_enabled,
                   type: { value: Boolean, message: 'management.currency.non_boolean_deposit_enabled' },
                   default: true,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:deposit_enabled][:desc] }
          optional :withdrawal_enabled,
                   type: { value: Boolean, message: 'management.currency.non_boolean_withdrawal_enabled' },
                   default: true,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:withdrawal_enabled][:desc] }
          optional :precision,
                   type: { value: Integer, message: 'management.currency.non_integer_base_precision' },
                   default: 8,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:precision][:desc] }
          optional :icon_url, desc: -> { API::V2::Management::Entities::Currency.documentation[:icon_url][:desc] }
        end
        put '/currencies/update' do
          currency = ::Currency.find_by!(params.slice(:id))
          if currency.update(declared(params, include_missing: false))
            present currency, with: API::V2::Management::Entities::Currency
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
