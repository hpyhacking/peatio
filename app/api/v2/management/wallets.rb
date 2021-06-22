# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Wallets < Grape::API
        helpers ::API::V2::ParamHelpers
        helpers do
          # Collection of shared params, used to
          # generate required/optional Grape params.
          OPTIONAL_WALLET_PARAMS ||= {
            max_balance: {
              type: { value: BigDecimal, message: 'management.blockchain.non_decimal_max_balance' },
              values: { value: -> (p){ p >= 0 }, message: 'management.wallet.invalid_max_balance' },
              default: 0.0,
              desc: -> { API::V2::Management::Entities::Wallet.documentation[:max_balance][:desc] }
            },
            status: {
              values: { value: %w(active disabled), message: 'management.wallet.invalid_status' },
              default: 'active',
              desc: -> { API::V2::Management::Entities::Wallet.documentation[:status][:desc] }
            },
          }

          params :create_wallet_params do
            OPTIONAL_WALLET_PARAMS.each do |key, params|
              optional key, params
            end
          end

          params :update_wallet_params do
            OPTIONAL_WALLET_PARAMS.each do |key, params|
              optional key, params.except(:default)
            end
          end
        end

        desc 'Creates new wallet.' do
          @settings[:scope] = :write_wallets
          success API::V2::Management::Entities::Wallet
        end
        params do
          use :create_wallet_params
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'management.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:blockchain_key][:desc] }
          requires :name,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:address][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'management.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   as: :currency_ids,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:currencies][:desc] }
          # @deprecated Please use `currencies` field
          optional :currency,
                   values: { value: -> { ::Currency.codes }, message: 'management.wallet.currency_doesnt_exist' },
                   as: :currency_ids,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:currencies][:desc] }
          requires :kind,
                   values: { value: ::Wallet.kind.values, message: 'management.wallet.invalid_kind' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:kind][:desc] }
          requires :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'management.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:gateway][:desc] }
          optional :settings, type: JSON,
                              default: {},
                              desc: -> { 'Wallet settings (uri, secret)' } do
            optional :uri,
                     values: { value: ->(v) { URI.parse(v).is_a?(URI::HTTP) || URI.parse(v).is_a?(URI::HTTPS) }, message: 'management.wallet.invalid_uri_setting' },
                     desc: -> { 'Wallet uri setting' }
            optional :secret,
                     desc: -> { 'Wallet secret setting' }
          end
          exactly_one_of :currencies, :currency, message: 'management.wallet.currencies_field_is_missing'
        end
        post '/wallets/new' do
          wallet = ::Wallet.new(declared(params))
          if wallet.save
            present wallet, with: API::V2::Admin::Entities::Wallet
            status 201
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end

        desc 'Update wallet.' do
          @settings[:scope] = :write_wallets
          success API::V2::Management::Entities::Wallet
        end
        params do
          use :update_wallet_params
          requires :id,
                   type: { value: Integer, message: 'management.wallet.non_integer_id' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:id][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'management.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :name,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:address][:desc] }
          optional :kind,
                   values: { value: ::Wallet.kind.values, message: 'management.wallet.invalid_kind' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:kind][:desc] }
          optional :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'management.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:gateway][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'management.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   as: :currency_ids,
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:currencies][:desc] }
          optional :settings, type: JSON,
                              desc: -> { 'Wallet settings' } do
            optional :uri,
                     values: { value: ->(v) { URI.parse(v).is_a?(URI::HTTP) || URI.parse(v).is_a?(URI::HTTPS) }, message: 'management.wallet.invalid_uri_setting' },
                     desc: -> { 'Wallet uri setting' }
            optional :secret,
                     desc: -> { 'Wallet secret setting' }
          end
        end
        post '/wallets/update' do
          wallet = ::Wallet.find(params[:id])

          declared_params = declared(params, include_missing: false)
          declared_params.merge!(settings: params[:settings]) if params[:settings].present?
          if wallet.update(declared_params)
            present wallet, with: API::V2::Management::Entities::Wallet
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end

        desc 'Get all wallets, result is paginated.' do
          @settings[:scope] = :read_wallets
          success API::V2::Management::Entities::Wallet
        end
        params do
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'management.currency.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :kind,
                   values: { value: -> { Wallet.kind.values }, message: 'management.wallet.invalid_kind' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:kind][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'management.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:currencies][:desc] }
          use :pagination
          use :ordering
        end
        post '/wallets' do
          ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                             .eq(:blockchain_key)
                             .translate_in(currencies: :currencies_id)
                             .merge(kind_eq: params[:kind].present? ? Wallet.kinds[params[:kind].to_sym] : nil)
                             .build

          search = ::Wallet.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(::Wallet.uniq(search.result.includes(:currencies))), with: API::V2::Admin::Entities::Wallet
        end

        desc 'Get a wallet.' do
          @settings[:scope] = :read_wallets
          success API::V2::Management::Entities::Wallet
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'management.wallet.non_integer_id' },
                   desc: -> { API::V2::Management::Entities::Wallet.documentation[:id][:desc] }
        end
        post '/wallets/:id' do
          present ::Wallet.find(params[:id]), with: API::V2::Management::Entities::Wallet
        end
      end
    end
  end
end
