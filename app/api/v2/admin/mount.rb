# frozen_string_literal: true

module API
  module V2
    module Admin
      class Mount < Grape::API
        PREFIX = '/admin'

        before { authenticate! unless request.path == '/api/v2/admin/swagger' }

        formatter :csv, CSVFormatter

        mount Admin::Orders
        mount Admin::Blockchains
        mount Admin::Currencies
        mount Admin::Markets
        mount Admin::Wallets
        mount Admin::Deposits
        mount Admin::Withdraws
        mount Admin::Trades
        mount Admin::Operations
        mount Admin::Members
        mount Admin::TradingFees
        mount Admin::Adjustments
        mount Admin::Engines
        mount Admin::Beneficiaries
        mount Admin::Abilities
        mount Admin::WithdrawLimits
        mount Admin::Airdrops
        mount Admin::InternalTransfers
        mount Admin::WhitelistedSmartContracts
        mount Admin::BlockchainCurrencies
        mount Admin::ImportConfigs

        # The documentation is accessible at http://localhost:3000/swagger?url=/api/v2/admin/swagger
        # Add swagger documentation for Peatio Admin API
        add_swagger_documentation base_path: File.join(API::Mount::PREFIX, API::V2::Mount::API_VERSION, PREFIX, 'peatio'),
                                  add_base_path: true,
                                  mount_path:  '/swagger',
                                  api_version: API::V2::Mount::API_VERSION,
                                  doc_version: Peatio::Application::VERSION,
                                  info: {
                                    title:          "Peatio Admin API #{API::V2::Mount::API_VERSION}",
                                    description:    'Admin API high privileged API with RBAC.',
                                    contact_name:   'openware.com',
                                    contact_email:  'hello@openware.com',
                                    contact_url:    'https://www.openware.com',
                                    licence:        'MIT',
                                    license_url:    'https://github.com/openware/peatio/blob/master/LICENSE.md'
                                  },
                                  models: [
                                    API::V2::Admin::Entities::Blockchain,
                                    API::V2::Admin::Entities::Currency,
                                    API::V2::Admin::Entities::BlockchainCurrency,
                                    API::V2::Admin::Entities::Deposit,
                                    API::V2::Admin::Entities::Market,
                                    API::V2::Admin::Entities::Member,
                                    API::V2::Admin::Entities::Operation,
                                    API::V2::Admin::Entities::Order,
                                    API::V2::Admin::Entities::Trade,
                                    API::V2::Admin::Entities::Wallet,
                                    API::V2::Admin::Entities::Withdraw,
                                    API::V2::Admin::Entities::InternalTransfer,
                                    API::V2::Admin::Entities::WhitelistedSmartContract
                                  ]
      end
    end
  end
end
