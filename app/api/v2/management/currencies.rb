# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Currencies < Grape::API
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

        # POST: api/v2/management/currencies
        desc 'Returns currency by code.' do
          @settings[:scope] = :read_currencies
          success API::V2::Management::Entities::Currency
        end

        params do
          requires :code, type: String, desc: 'The currency code.'
        end
        post '/currencies/:code' do
          present Currency.find_by!(params.slice(:code)), with: API::V2::Management::Entities::Currency
        end

        desc 'Update  currency.' do
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
                   default: 0,
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:position][:desc] }
          optional :options,
                   type: { value: JSON, message: 'management.currency.non_json_options' },
                   default: 0.0,
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
