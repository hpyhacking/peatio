# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Currencies < Grape::API
        helpers do
          OPTIONAL_CURRENCY_PARAMS ||= {
            name: { desc: -> { API::V2::Management::Entities::Currency.documentation[:name][:desc] } },
            precision: {
              type: { value: Integer, message: 'management.currency.non_integer_base_precision' },
              default: 8,
              desc: -> { API::V2::Management::Entities::Currency.documentation[:precision][:desc] }
            },
            price: {
              type: { value: BigDecimal, message: 'management.currency.non_decimal_price' },
              desc: -> { API::V2::Management::Entities::Currency.documentation[:price][:desc] }
            },
            status: {
              values: { value: -> { ::Currency::STATES }, message: 'management.currency.invalid_status'},
              desc: -> { API::V2::Management::Entities::Currency.documentation[:status][:desc] }
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
          currencies = currencies.where(type: params[:type]) if params[:type] == 'coin'
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
          optional :position,
                   type: { value: Integer, message: 'management.currency.non_integer_position' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:position][:desc] }
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
          optional :position,
                   type: { value: Integer, message: 'management.currency.non_integer_position' },
                   values: { value: -> (p){ p >= ::Currency::TOP_POSITION }, message: 'management.currency.invalid_position' },
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:position][:desc] }
          optional :status,
                   values: { value: -> { ::Currency::STATES }, message: 'management.currency.invalid_status'},
                   desc: -> { API::V2::Management::Entities::Currency.documentation[:status][:desc] }
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
