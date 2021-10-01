# frozen_string_literal: true

module API
  module V2
    module Management
      class BlockchainCurrencies < Grape::API
				helpers ::API::V2::Admin::Helpers
        helpers do
          # Collection of shared params, used to
          # generate required/optional Grape params.
          OPTIONAL_CURRENCY_PARAMS ||= {
            deposit_fee: {
              type: { value: BigDecimal, message: 'management.blockchain_currency.non_decimal_deposit_fee' },
              values: { value: -> (p){ p >= 0 }, message: 'management.blockchain_currency.invalid_deposit_fee' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:deposit_fee][:desc] }
            },
            min_deposit_amount: {
              type: { value: BigDecimal, message: 'management.blockchain_currency.min_deposit_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.blockchain_currency.min_deposit_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:min_deposit_amount][:desc] }
            },
            min_collection_amount: {
              type: { value: BigDecimal, message: 'management.blockchain_currency.non_decimal_min_collection_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.blockchain_currency.invalid_min_collection_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:min_collection_amount][:desc] }
            },
            withdraw_fee: {
              type: { value: BigDecimal, message: 'management.blockchain_currency.non_decimal_withdraw_fee' },
              values: { value: -> (p){ p >= 0  }, message: 'management.blockchain_currency.ivalid_withdraw_fee' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:withdraw_fee][:desc] }
            },
            min_withdraw_amount: {
              type: { value: BigDecimal, message: 'management.blockchain_currency.non_decimal_min_withdraw_amount' },
              values: { value: -> (p){ p >= 0 }, message: 'management.blockchain_currency.invalid_min_withdraw_amount' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:min_withdraw_amount][:desc] }
            },
            options: {
              type: { value: JSON, message: 'management.blockchain_currency.non_json_options' },
              default: {},
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:options][:desc] }
            },
            status: {
              values: { value: -> { ::BlockchainCurrency::STATES }, message: 'management.blockchain_currency.invalid_status'},
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:status][:desc] }
            },
            auto_update_fees_enabled: {
              type: { value: Boolean, message: 'management.blockchain_currency.non_boolean_auto_update_fees_enabled' },
              default: true,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:auto_update_fees_enabled][:desc] }
            },
            deposit_enabled: {
              type: { value: Boolean, message: 'management.blockchain_currency.non_boolean_deposit_enabled' },
              default: true,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:deposit_enabled][:desc] }
            },
            withdrawal_enabled: {
              type: { value: Boolean, message: 'management.blockchain_currency.non_boolean_withdrawal_enabled' },
              default: true,
              desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:withdrawal_enabled][:desc] }
            },
          }

          params :create_blockchain_currency_params do
            OPTIONAL_CURRENCY_PARAMS.each do |key, params|
              optional key, params
            end
          end

          params :update_blockchain_currency_params do
            OPTIONAL_CURRENCY_PARAMS.each do |key, params|
              optional key, params.except(:default)
            end
          end
        end

        namespace :blockchain_currencies do
          desc 'Get all blockchain currencies, result is paginated.' do
					  @settings[:scope] = :read_blockchain_currencies
            success API::V2::Management::Entities::BlockchainCurrency
					end
          params do
            use :pagination
            use :ordering
            optional :status,
                     values: { value: -> { ::BlockchainCurrency::STATES }, message: 'management.blockchain_currency.invalid_status'},
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:status][:desc] }
            optional :deposit_enabled,
                     type: { value: Boolean, message: 'management.blockchain_currency.non_boolean_deposit_enabled' },
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:deposit_enabled][:desc] }
            optional :withdrawal_enabled,
                     type: { value: Boolean, message: 'management.blockchain_currency.non_boolean_withdrawal_enabled' },
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:withdrawal_enabled][:desc] }
          end
          post '/list' do
            ransack_params = ::API::V2::Admin::Helpers::RansackBuilder.new(params)
                               .eq(:status, :withdrawal_enabled, :deposit_enabled)
                               .build

            search = ::BlockchainCurrency.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"
            present paginate(search.result), with: API::V2::Management::Entities::BlockchainCurrency
          end

          desc 'Create new blockchain currency.' do
						@settings[:scope] = :write_blockchain_currencies
            success API::V2::Management::Entities::BlockchainCurrency
          end
          params do
            use :create_blockchain_currency_params
            requires :currency_id,
                     allow_blank: false,
                     values: { value: -> { Currency.codes(bothcase: true) }, message: 'management.blockchain_currency.currency_doesnt_exist'},
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:currency_id][:desc] }
            requires :blockchain_key,
                     allow_blank: false,
                     values: { value: -> { ::Blockchain.pluck(:key) }, message: 'management.blockchain_currency.blockchain_key_doesnt_exist' },
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:blockchain_key][:desc] }
            optional :base_factor,
                     type: { value: Integer, message: 'management.blockchain_currency.non_integer_base_factor' },
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:base_factor][:desc] }
            optional :subunits,
                     type: { value: Integer, message: 'management.blockchain_currency.non_integer_subunits' },
                     values: { value: (0..18), message: 'management.blockchain_currency.invalid_subunits' },
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:subunits][:desc] }
            given currency_id: ->(currency_id) { currency_id.present? && Currency.find_by(id: currency_id).coin? } do
              optional :parent_id,
                       values: { value: -> { Currency.coins_without_tokens.pluck(:id).map(&:to_s) }, message: 'management.blockchain_currency.parent_id_doesnt_exist' },
                       desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:parent_id][:desc] }
            end
            mutually_exclusive :base_factor, :subunits, message: 'management.blockchain_currency.one_of_base_factor_subunits_fields'
          end
          post '/new' do
            blockchain_currency = ::BlockchainCurrency.new(declared(params, include_missing: false))

            if blockchain_currency.save
              present blockchain_currency, with: API::V2::Management::Entities::BlockchainCurrency
              status 201
            else
              body errors: blockchain_currency.errors.full_messages
              status 422
            end
          end

					desc 'Update blockchain currency.' do
						@settings[:scope] = :write_blockchain_currencies
            success API::V2::Management::Entities::BlockchainCurrency
          end
          params do
            use :update_blockchain_currency_params
            requires :id,
                     type: Integer,
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:id][:desc] }
          end
          post '/update' do
            blockchain_currency = ::BlockchainCurrency.find(params[:id])
            if blockchain_currency.update(declared(params, include_missing: false))
              present blockchain_currency, with: API::V2::Management::Entities::BlockchainCurrency
            else
              body errors: blockchain_currency.errors.full_messages
              status 422
            end
          end

          desc 'Get a blockchain currency.' do
						@settings[:scope] = :read_blockchain_currencies
            success API::V2::Management::Entities::BlockchainCurrency
          end
          params do
            requires :id,
                     type: Integer,
                     desc: -> { API::V2::Management::Entities::BlockchainCurrency.documentation[:id][:desc] }
          end
          post '/:id' do
            present ::BlockchainCurrency.find(params[:id]), with: API::V2::Management::Entities::BlockchainCurrency
          end
        end
      end
    end
  end
end
