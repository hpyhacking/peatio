# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Currencies < Grape::API

        desc 'Get a currency' do
          success Entities::Currency
        end
        params do
          requires :id,
                   type: String,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'public.currency.doesnt_exist'},
                   desc: -> { API::V2::Entities::Currency.documentation[:id][:desc] }
        end
        get '/currencies/:id' do
          present Currency.find(params[:id]), with: API::V2::Entities::Currency
        end

        desc 'Get list of currencies',
          is_array: true,
          success: Entities::Currency
        params do
          optional :type,
                   type: String,
                   values: { value: %w[fiat coin], message: 'public.currency.invalid_type' },
                   desc: -> { API::V2::Entities::Currency.documentation[:type][:desc] }
        end
        get '/currencies' do
          currencies = Currency.enabled
          currencies = currencies.where(type: params[:type]).includes(:blockchain) if params[:type] == 'coin'
          currencies = currencies.where(type: params[:type]) if params[:type] == 'fiat'
          present currencies.ordered, with: API::V2::Entities::Currency
        end
      end
    end
  end
end
