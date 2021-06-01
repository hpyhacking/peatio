# frozen_string_literal: true

class CurrencyWallet < ApplicationRecord
  self.table_name = 'currencies_wallets'

  belongs_to :currency
  belongs_to :wallet
  validates :currency_id, uniqueness: { scope: :wallet_id }
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: currencies_wallets
#
#  currency_id :string(255)
#  wallet_id   :bigint
#
# Indexes
#
#  index_currencies_wallets_on_currency_id                (currency_id)
#  index_currencies_wallets_on_currency_id_and_wallet_id  (currency_id,wallet_id) UNIQUE
#  index_currencies_wallets_on_wallet_id                  (wallet_id)
#
