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
        :explorer_transaction,
        documentation: {
          desc: 'Currency transaction exprorer url template',
          example: 'https://testnet.blockchain.info/tx/'
        },
        if: -> (currency){ currency.coin? }
      )

      expose(
        :explorer_address,
        documentation: {
          desc: 'Currency address exprorer url template',
          example: 'https://testnet.blockchain.info/address/'
        },
        if: -> (currency){ currency.coin? }
      )

      expose(
        :type,
        documentation: {
          type: String,
          values: -> { ::Currency.types },
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
      expose(
        :icon_url,
        documentation: {
          desc: 'Currency icon',
          example: 'https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg'
        },
        if: -> (currency){ currency.icon_url.present? }
      )
    end
  end
end
