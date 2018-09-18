# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Currencies < Grape::API
        helpers API::V2::NamedParams

        desc 'Get a currency', tags: %w[currencies], success: Entities::Currency
        params do
          requires :id, type: String,
                        values: -> { Currency.enabled.codes(bothcase: true) },
                        desc: -> { API::V2::Entities::Currency.documentation[:id][:desc] }
        end
        get '/currencies/:id' do
          present Currency.find(params[:id]), with: API::V2::Entities::Currency
        end

        desc 'Get list of currencies', is_array: true,
                                      success: Entities::Currency,
                                      tags: %w[currencies],
                                      security: []
        params do
          optional :type, type: String,
                          values: %w[fiat coin],
                          desc: -> { API::V2::Entities::Currency.documentation[:type][:desc] }
        end
        get '/currencies' do
          currencies = Currency.enabled
          currencies = currencies.where(type: params[:type]).includes(:blockchain) if params[:type] == 'coin'
          currencies = currencies.where(type: params[:type]) if params[:type] == 'fiat'
          present currencies, with: API::V2::Entities::Currency
        end
      end
    end
  end
end