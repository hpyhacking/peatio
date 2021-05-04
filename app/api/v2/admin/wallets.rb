# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Wallets < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          # Collection of shared params, used to
          # generate required/optional Grape params.
          OPTIONAL_WALLET_PARAMS ||= {
            max_balance: {
              type: { value: BigDecimal, message: 'admin.blockchain.non_decimal_max_balance' },
              values: { value: -> (p){ p >= 0 }, message: 'admin.wallet.invalid_max_balance' },
              default: 0.0,
              desc: -> { API::V2::Admin::Entities::Wallet.documentation[:max_balance][:desc] }
            },
            status: {
              values: { value: Wallet::STATES, message: 'admin.wallet.invalid_status' },
              default: 'active',
              desc: -> { API::V2::Admin::Entities::Wallet.documentation[:status][:desc] }
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

        desc 'Get wallets overview'
        get '/wallets/overview' do
          admin_authorize! :read, ::Wallet

          Rails.cache.fetch(:wallet_overview, expires_in: 60) do
            Helpers::WalletOverviewBuilder.new(::Currency.coins.active, ::BlockchainCurrency.active).info
          end
        end

        desc 'Get all wallets, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Wallet
        params do
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.currency.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :kind,
                   values: { value: -> { Wallet.kind.values }, message: 'admin.wallet.invalid_kind' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'admin.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
          use :pagination
          use :ordering
        end
        get '/wallets' do
          admin_authorize! :read, ::Wallet

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:blockchain_key)
                             .translate_in(currencies: :currencies_id)
                             .merge(kind_eq: params[:kind].present? ? Wallet.kinds[params[:kind].to_sym] : nil)
                             .build

          search = ::Wallet.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(::Wallet.uniq(search.result.includes(:currencies))), with: API::V2::Admin::Entities::Wallet
        end

        desc 'List wallet kinds.'
        get '/wallets/kinds' do
          ::Wallet.kind.values
        end

        desc 'List wallet gateways.'
        get '/wallets/gateways' do
          ::Wallet.gateways.map(&:to_s)
        end

        desc 'Get a wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
        end
        get '/wallets/:id' do
          admin_authorize! :read, ::Wallet

          present ::Wallet.find(params[:id]), with: API::V2::Admin::Entities::Wallet
        end

        desc 'Creates new wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          use :create_wallet_params
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          requires :name,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'admin.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   as: :currency_ids,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
          # @deprecated Please use `currencies` field
          optional :currency,
                   values: { value: -> { ::Currency.codes }, message: 'admin.wallet.currency_doesnt_exist' },
                   as: :currency_ids,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
          requires :kind,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          requires :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
          optional :settings, type: JSON,
                              default: {},
                              desc: -> { 'Wallet settings (uri, secret)' } do
            optional :uri,
                     values: { value: ->(v) { URI.parse(v).is_a?(URI::HTTP) || URI.parse(v).is_a?(URI::HTTPS) }, message: 'admin.wallet.invalid_uri_setting' },
                     desc: -> { 'Wallet uri setting' }
            optional :secret,
                     desc: -> { 'Wallet secret setting' }
          end
          optional :plain_settings, type: JSON,
                                    default: {},
                                    desc: -> { 'Wallet plain settings (external_wallet_id)' }
          exactly_one_of :currencies, :currency, message: 'admin.wallet.currencies_field_is_missing'
        end
        post '/wallets/new' do
          admin_authorize! :create, ::Wallet

          wallet = ::Wallet.new(params)
          if wallet.save
            present wallet, with: API::V2::Admin::Entities::Wallet
            status 201
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end

        desc 'Update wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          use :update_wallet_params
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :name,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          optional :kind,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          optional :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
          optional :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'admin.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   as: :currency_ids,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
          optional :plain_settings, type: JSON,
                   default: {},
                   desc: -> { 'Wallet plain settings (external_wallet_id)' }
          optional :settings, type: JSON,
                              desc: -> { 'Wallet settings' } do
            optional :uri,
                     values: { value: ->(v) { URI.parse(v).is_a?(URI::HTTP) || URI.parse(v).is_a?(URI::HTTPS) }, message: 'admin.wallet.invalid_uri_setting' },
                     desc: -> { 'Wallet uri setting' }
            optional :secret,
                     desc: -> { 'Wallet secret setting' }
          end
        end
        post '/wallets/update' do
          admin_authorize! :update, ::Wallet
          wallet = ::Wallet.find(params[:id])

          declared_params = declared(params, include_missing: false)
          declared_params.merge!(settings: params[:settings]) if params[:settings].present?
          if wallet.update(declared_params)
            present wallet, with: API::V2::Admin::Entities::Wallet
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end

        desc 'Add currency to the wallet' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
          requires :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'admin.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
        end
        post '/wallets/currencies' do
          wallet = Wallet.find(params[:id])

          wallet.transaction do
            params[:currencies].each do |c_id|
              c_w = CurrencyWallet.new(currency_id: c_id, wallet_id: params[:id])
              error!({ errors: c_w.errors.full_messages }, 422) unless c_w.save
            end
          end

          present wallet, with: API::V2::Admin::Entities::Wallet
          status 201
        end

        desc 'Delete currency from the wallet' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
          requires :currencies,
                   values: { value: ->(v) { (Array.wrap(v) - ::Currency.codes).blank? }, message: 'admin.wallet.currency_doesnt_exist' },
                   types: [String, Array], coerce_with: ->(c) { Array.wrap(c) },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currencies][:desc] }
        end
        delete '/wallets/currencies' do
          wallet = Wallet.find(params[:id])
          wallet.transaction do
            params[:currencies].each do |c_id|
              # Check if exist (will return error)
              CurrencyWallet.find_by!(currency_id: c_id, wallet_id: params[:id])
              # Delete relation
              CurrencyWallet.where(currency_id: c_id, wallet_id: params[:id]).delete_all
            end
          end

          present wallet, with: API::V2::Admin::Entities::Wallet
        end
      end
    end
  end
end
