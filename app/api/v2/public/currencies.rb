# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Currencies < Grape::API

        helpers ::API::V2::ParamHelpers

        desc 'Get a currency' do
          success API::V2::Public::Entities::Currency
        end
        params do
          requires :id,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'public.currency.doesnt_exist'},
                   desc: -> { API::V2::Public::Entities::Currency.documentation[:id][:desc] }
        end
        get '/currencies/:id', requirements: { id: /[\w\.\-]+/ } do
          present Currency.find(params[:id]), with: API::V2::Public::Entities::Currency
        end

        desc 'Get list of currencies',
          is_array: true,
          success: API::V2::Public::Entities::Currency
        params do
          use :pagination
          optional :type,
                   type: String,
                   values: { value: %w[fiat coin], message: 'public.currency.invalid_type' },
                   desc: -> { API::V2::Public::Entities::Currency.documentation[:type][:desc] }
          optional :search, type: JSON, default: {} do
            optional :code,
                     type: String,
                     desc: 'Search by currency code using SQL LIKE'
            optional :name,
                     type: String,
                     desc: 'Search by currency name using SQL LIKE'
          end
        end
        get '/currencies' do
          search_attrs = { m: 'or',
                           code_cont: params.dig(:search, :code),
                           name_cont: params.dig(:search, :name) }


          present paginate(Rails.cache.fetch("currencies_#{params}", expires_in: 600) do
            currencies = Currency.visible.ordered
            currencies = currencies.where(type: params[:type]) if params[:type] == 'coin'
            currencies = currencies.where(type: params[:type]) if params[:type] == 'fiat'

            search = currencies.ransack(search_attrs)
            search.result.load.to_a
          end), with: API::V2::Public::Entities::Currency
        end
      end
    end
  end
end
