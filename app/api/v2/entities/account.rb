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
          :type,
          as: :account_type,
          documentation: {
            desc: 'Account type.',
            type: String
          }
        )

        expose(
          :deposit_address,
          if: ->(account, _options) { account.currency.coin? && account.currency.default_network.present? },
          using: API::V2::Entities::PaymentAddress,
          documentation: {
            desc: 'User deposit address',
            type: String
          }
        ) do |account, options|
          network = account.currency.default_network
          deposit_wallet = Wallet.active_deposit_wallet(account.currency_id, network.blockchain_key)
          ::PaymentAddress.find_by(wallet: deposit_wallet, member: options[:current_user], remote: false)
        end

        expose(
          :deposit_addresses,
          if: ->(account, _options) { account.currency.coin? && account.type == ::Account::DEFAULT_TYPE },
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
