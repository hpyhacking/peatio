# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Markets < Grape::API
        # POST: api/v2/management/markets/update
        desc 'Update market.' do
          @settings[:scope] = :write_markets
          success API::V2::Management::Entities::Market
        end

        params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Management::Entities::Market.documentation[:id][:desc] }
          optional :state,
                   type: String,
                   values: { value: ::Market::STATES },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:state][:desc] }
          optional :min_price,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_price][:desc] }
          optional :min_amount,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:min_amount][:desc] }
          optional :amount_precision,
                   type: { value: Integer },
                   values: { value: ->(p) { p && p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:amount_precision][:desc] }
          optional :price_precision,
                   type: { value: Integer },
                   values: { value: ->(p) { p && p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:price_precision][:desc] }
          optional :max_price,
                   type: { value: BigDecimal },
                   values: { value: ->(p) { p >= 0 } },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:max_price][:desc] }
          optional :position,
                   type: { value: Integer },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:position][:desc] }
          optional :state,
                   values: { value: ::Market::STATES },
                   desc: -> { API::V2::Management::Entities::Market.documentation[:state][:desc] }
        end
        put '/markets/update' do
          market = ::Market.find_by!(params.slice(:id))
          if market.update(declared(params, include_missing: false))
            present market, with: API::V2::Management::Entities::Market
          else
            body errors: market.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
