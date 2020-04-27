# frozen_string_literal: true

module API
  module V2
    module Entities
      class Portfolio < Base
        expose(
          :base_unit,
          documentation: {
            type: String,
            desc: 'Market base unit'
          }
        )

        expose(
          :price,
          documentation: {
            type: BigDecimal,
            desc: 'The average price of acquisition for user buy trades with provided quote unit'
          }
        )

        expose(
          :total,
          documentation: {
            type: BigDecimal,
            desc: 'Sum of the total for user buy trades with provided quote unit'
          }
        )
      end
    end
  end
end
