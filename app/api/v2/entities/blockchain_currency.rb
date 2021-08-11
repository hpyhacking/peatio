# frozen_string_literal: true

module API
  module V2
    module Entities
      class BlockchainCurrency < Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Unique identifier of blockchain currency'
          }
        )

        expose(
          :status,
          documentation: {
            type: String,
            desc: 'Blockchain currency display status (enabled/disabled/hidden).'
          }
        )

        expose(
          :blockchain_key,
          documentation:{
            type: String,
            desc: 'Unique key to identify blockchain.'
          }
        )

        expose(
          :currency_id,
          documentation:{
            type: String,
            desc: 'Unique id to identify currency.'
          }
        )

        expose(
          :parent_id,
          documentation: {
            type: String,
            desc: 'Blockchain currency parent id',
          },
          if: -> (blockchain_currency){ blockchain_currency.parent_id.present? }
        )

        expose(
          :deposit_enabled,
          documentation: {
            type: String,
            desc: 'Blockchain currency deposit possibility status (true/false).'
          }
        )

        expose(
          :withdrawal_enabled,
          documentation: {
            type: String,
            desc: 'Blockchain currency withdrawal possibility status (true/false).'
          }
        )

        expose(
          :deposit_fee,
          documentation: {
            desc: 'Blockchain currency deposit fee',
          }
        )

        expose(
          :min_deposit_amount,
          documentation: {
            desc: 'Minimal deposit amount',
          }
        )

        expose(
          :withdraw_fee,
          documentation: {
            desc: 'Blockchain currency withdraw fee',
          }
        )

        expose(
          :min_withdraw_amount,
          documentation: {
            desc: 'Minimal withdraw amount',
          }
        )

        expose(
          :base_factor,
          documentation: {
            desc: 'Blockchain currency base factor',
          }
        )

        expose(
          :explorer_transaction,
          documentation: {
            desc: 'Blockchain transaction exprorer url template',
            example: 'https://testnet.blockchain.info/tx/'
          },
          if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
        )

        expose(
          :explorer_address,
          documentation: {
            desc: 'Blockchain address exprorer url template',
            example: 'https://testnet.blockchain.info/address/'
          },
          if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
        )

        expose(
          :description,
          documentation: {
            desc: 'Blockchain description',
          },
          if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
        )

        expose(
          :warning,
          documentation: {
            desc: 'Blockchain warning',
          },
          if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
        )

        expose(
          :protocol,
          documentation: {
            desc: 'Blockchain protocol',
          },
          if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
        )

        expose(
          :min_confirmations,
          if: ->(blockchain_currency) { blockchain_currency.currency.coin? },
          documentation: {
            desc: 'Number of confirmations required for confirming deposit or withdrawal'
          }
        ) { |blockchain_currency| blockchain_currency.blockchain.min_confirmations }
      end
    end
  end
end
