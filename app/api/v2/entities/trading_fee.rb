module API
  module V2
    module Entities
      class TradingFee < API::V2::Entities::Base
        expose(
          :id,
          documentation:{
            type: Integer,
            desc: 'Unique trading fee table identifier in database.'
          }
        )

        expose(
          :group,
          documentation:{
            type: String,
            desc: 'Member group for define maker/taker fee.'
          }
        )

        expose(
          :market_id,
          documentation:{
            type: String,
            desc: 'Market id for define maker/taker fee.'
          }
        )

        expose(
          :maker,
          documentation:{
            type: BigDecimal,
            desc: 'Market maker fee.'
          }
        )

        expose(
          :taker,
          documentation:{
            type: BigDecimal,
            desc: 'Market taker fee.'
          }
        )

        expose(
          :created_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'Trading fee table created time in iso8601 format.'
          }
        )

        expose(
          :updated_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'Trading fee table updated time in iso8601 format.'
          }
        )
      end
    end
  end
end
