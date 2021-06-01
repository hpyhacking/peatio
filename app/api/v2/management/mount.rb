# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Mount < Grape::API
        PREFIX = '/management'

        format         :json
        content_type   :json, 'application/json'
        default_format :json

        do_not_route_options!

        helpers Management::Helpers

        before { set_ets_context! }

        rescue_from Management::Exceptions::Base do |e|
          Management::Mount.logger.error { e.inspect }
          error!(e.message, e.status, e.headers)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          Management::Mount.logger.error { e.inspect }
          Management::Mount.logger.debug { e.full_messages }
          error!(e.message, 422)
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          Management::Mount.logger.error { e.inspect }
          error!('Couldn\'t find record.', 404)
        end

        use Management::JWTAuthenticationMiddleware

        mount Management::Accounts
        mount Management::Deposits
        mount Management::Withdraws
        mount Management::Tools
        mount Management::Operations
        mount Management::Orders
        mount Management::Transfers
        mount Management::Trades
        mount Management::Members
        mount Management::TradingFees
        mount Management::Currencies
        mount Management::Markets
        mount Management::Beneficiaries
        mount Management::PaymentAddress
        mount Management::Engines
        mount Management::Wallets
        mount Management::BlockchainCurrencies

        # The documentation is accessible at http://localhost:3000/swagger?url=/api/v2/management/swagger
        # Add swagger documentation for Peatio Management API
        add_swagger_documentation base_path: File.join(API::Mount::PREFIX, API::V2::Mount::API_VERSION, PREFIX, 'peatio'),
                                  add_base_path: true,
                                  mount_path:  '/swagger',
                                  api_version: API::V2::Mount::API_VERSION,
                                  doc_version: Peatio::Application::VERSION,
                                  info: {
                                    title:          "Peatio Management API #{API::V2::Mount::API_VERSION}",
                                    description:    'Management API is server-to-server API with high privileges.',
                                    contact_name:   'openware.com',
                                    contact_email:  'hello@openware.com',
                                    contact_url:    'https://www.openware.com',
                                    licence:        'MIT',
                                    license_url:    'https://github.com/openware/peatio/blob/master/LICENSE.md'
                                  },
                                  models: [
                                    API::V2::Management::Entities::Balance,
                                    API::V2::Management::Entities::Deposit,
                                    API::V2::Management::Entities::Withdraw,
                                    API::V2::Management::Entities::Operation,
                                    API::V2::Management::Entities::BlockchainCurrency,
                                    API::V2::Management::Entities::Engine
                                  ]
      end
    end
  end
end
