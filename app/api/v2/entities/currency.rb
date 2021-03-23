# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Currency < Base
        expose(
          :id,
          documentation: {
            desc: 'Currency code.',
            type: String,
            values: -> { ::Currency.visible.codes },
            example: -> { ::Currency.visible.first.id }
          }
        )

        expose(
          :name,
          documentation: {
              type: String,
              desc: 'Currency name',
              example: -> { ::Currency.visible.first.name }
          },
          if: -> (currency){ currency.name.present? }
        )

        expose(
          :description,
          documentation: {
            type: String,
            desc: 'Currency description',
            example: -> { ::Currency.visible.first.id }
          }
        )

        expose(
          :homepage,
          documentation: {
            type: String,
            desc: 'Currency homepage',
            example: -> { ::Currency.visible.first.homepage }
          }
        )

        expose(
          :parent_id,
          documentation: {
            type: String,
            desc: 'Currency parent id',
            example: -> { ::Currency.visible.first.parent_id }
          },
          if: -> (currency){ currency.parent_id.present? }
        )

        expose(
          :price,
          documentation: {
            desc: 'Currency current price'
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
            example: -> { ::Currency.visible.first.type }
          }
        )

        expose(
          :deposit_enabled,
          documentation: {
            type: String,
            desc: 'Currency deposit possibility status (true/false).'
          }
        )

        expose(
          :withdrawal_enabled,
          documentation: {
            type: String,
            desc: 'Currency withdrawal possibility status (true/false).'
          }
        )

        expose(
          :deposit_fee,
          documentation: {
            desc: 'Currency deposit fee',
            example: -> { ::Currency.visible.first.deposit_fee }
          }
        )

        expose(
          :min_deposit_amount,
          documentation: {
            desc: 'Minimal deposit amount',
            example: -> { ::Currency.visible.first.min_deposit_amount }
          }
        )

        expose(
          :withdraw_fee,
          documentation: {
            desc: 'Currency withdraw fee',
            example: -> { ::Currency.visible.first.withdraw_fee }
          }
        )

        expose(
          :min_withdraw_amount,
          documentation: {
            desc: 'Minimal withdraw amount',
            example: -> { ::Currency.visible.first.min_withdraw_amount }
          }
        )

        expose(
          :withdraw_limit_24h,
          documentation: {
            desc: 'Currency 24h withdraw limit',
            example: -> { ::Currency.visible.first.withdraw_limit_24h }
          }
        )

        expose(
          :withdraw_limit_72h,
          documentation: {
            desc: 'Currency 72h withdraw limit',
            example: -> { ::Currency.visible.first.withdraw_limit_72h }
          }
        )

        expose(
          :base_factor,
          documentation: {
            desc: 'Currency base factor',
            example: -> { ::Currency.visible.first.base_factor }
          }
        )

        expose(
          :precision,
          documentation: {
            desc: 'Currency precision',
            example: -> { ::Currency.visible.first.precision }
          }
        )

        expose(
          :position,
          documentation: {
            desc: 'Position used for defining currencies order',
            example: -> { ::Currency.visible.first.precision }
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

        expose(
          :min_confirmations,
          if: ->(currency) { currency.coin? },
          documentation: {
            desc: 'Number of confirmations required for confirming deposit or withdrawal'
          }
        ) { |c| c.blockchain.min_confirmations }
      end
    end
  end
end
