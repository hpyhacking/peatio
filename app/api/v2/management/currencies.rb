# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Currencies < Grape::API
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
      end
    end
  end
end
