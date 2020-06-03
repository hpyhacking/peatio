# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class PaymentAddress < Base
        expose(
          :currency_id,
          as: :currency,
          documentation: {
            desc: 'Currency code.',
            type: String,
            values: -> { ::Currency.visible.codes },
            example: -> { ::Currency.visible.first.id }
          }
        )

        expose(
          :address,
          documentation: {
            desc: 'Payment address.',
            type: String
          }
        ) do |pa, options|
          options[:address_format] ? pa.format_address(options[:address_format]) : pa.address
        end

        expose(
          :state,
          documentation: {
            desc: 'Payment address state.',
            type: String
          }
        ) do |pa|
          pa.address.present? ? 'active' : 'pending'
        end

      end
    end
  end
end
