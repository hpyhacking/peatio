# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class PublicTrade < Base
        expose(
          :id,
          documentation: {
            type: String,
            desc: 'Trade ID.'
          }
        )

        expose(
          :price,
          documentation: {
            type: BigDecimal,
            desc: 'Trade price.'
          }
        )

        expose(
          :amount,
          documentation: {
            type: BigDecimal,
            desc: 'Trade amount.'
          }
        )

        expose(
          :total,
          documentation: {
            type: BigDecimal,
            desc: 'Trade total (Amount * Price).'
          }
        )

        expose(
          :market,
          documentation: {
            type: String,
            desc: 'Trade market id.'
          }
        )

        expose(
          :created_at,
          documentation: {
            type: String,
            desc: 'Trade create time in iso8601 format.'
          }
        )

        expose(
          :taker_type,
          documentation: {
            type: String,
            desc: 'Trade taker order type (sell or buy).'
          }
        )
      end
    end
  end
end
