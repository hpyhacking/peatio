# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Account < Base
      expose :currency_id,
             as: :currency,
             documentation: {
               desc: 'Currency code.',
               type: String,
             }

      expose :balance,
             format_with: :decimal,
             documentation: {
               desc: 'Account balance.',
               type: BigDecimal,
             }

      expose :locked,
             format_with: :decimal,
             documentation: {
               desc: 'Account locked funds.',
               type: BigDecimal,
             }
    end
  end
end
