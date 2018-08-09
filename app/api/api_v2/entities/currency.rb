# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Currency < Base
      expose(
        :id,
        documentation: {
          desc: 'Currency code.',
          type: String,
          values: -> { ::Currency.enabled.codes },
          example: -> { ::Currency.enabled.first.id }
        }
      )

      expose(
        :symbol,
        documentation: {
          type: String,
          desc: 'Currency symbol',
          example: -> { ::Currency.enabled.first.symbol }
        }
      )

      expose(
        :type,
        documentation: {
          type: String,
          values: %w[coin fiat],
          desc: 'Currency type',
          example: -> { ::Currency.enabled.first.type }
        }
      )

      expose(
        :deposit_fee,
        documentation: {
          desc: 'Currency deposit fee',
          example: -> { ::Currency.enabled.first.deposit_fee }
        }
      )

      expose(
        :withdraw_fee,
        documentation: {
          desc: 'Currency withdraw fee',
          example: -> { ::Currency.enabled.first.withdraw_fee }
        }
      )

      expose(
        :quick_withdraw_limit,
        documentation: {
          desc: 'Currency quick withdraw limit',
          example: -> { ::Currency.enabled.first.quick_withdraw_limit }
        }
      )

      expose(
        :min_confirmations,
        documentation: {
          desc: 'Number of deposit confirmations for currency',
          example: -> { ::Currency.enabled.first.min_confirmations }
        },
        if: ->(currency) { currency.type == 'coin' }
      )

      expose(
        :allow_multiple_deposit_addresses,
        documentation: {
          example: -> { ::Currency.enabled.first.allow_multiple_deposit_addresses }
        },
        if: ->(currency) { currency.type == 'coin' }
      )

      expose(
        :base_factor,
        documentation: {
          desc: 'Currency base factor',
          example: -> { ::Currency.enabled.first.base_factor }
        }
      )

      expose(
        :precision,
        documentation: {
          desc: 'Currency precision',
          example: -> { ::Currency.enabled.first.precision }
        }
      )
      expose :icon_url, if: -> (currency){ currency.icon_url.present? }, documentation: 'Currency icon'
    end
  end
end
