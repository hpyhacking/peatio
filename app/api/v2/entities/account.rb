# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Account < Base
        expose(
          :currency_id,
          as: :currency,
          documentation: {
            desc: 'Currency code.',
            type: String
          }
        )

        expose(
          :balance,
          format_with: :decimal,
          documentation: {
            desc: 'Account balance.',
            type: BigDecimal
          }
        )

        expose(
          :locked,
          format_with: :decimal,
          documentation: {
            desc: 'Account locked funds.',
            type: BigDecimal
          }
        )

        expose(
          :deposit_addresses,
          if: ->(account, _options) { account.currency.coin? },
          using: API::V2::Entities::PaymentAddress,
          documentation: {
            desc: 'User deposit addresses',
            is_array: true,
            type: String
          }
        ) do |account, options|
          deposit_wallets = Wallet.active_deposit_wallets(account.currency_id)
          ::PaymentAddress.where(wallet: deposit_wallets, member: options[:current_user], remote: false)
        end
      end
    end
  end
end
