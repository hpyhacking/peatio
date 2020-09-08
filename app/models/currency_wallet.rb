# frozen_string_literal: true

class CurrencyWallet < ApplicationRecord
  self.table_name = 'currencies_wallets'

  belongs_to :currency
  belongs_to :wallet
  validates :currency_id, uniqueness: { scope: :wallet_id }
end

# == Schema Information
# Schema version: 20200813133518
#
# Table name: currencies_wallets
#
#  id          :bigint           not null, primary key
#  currency_id :string(255)
#  wallet_id   :string(255)
#
# Indexes
#
#  index_currencies_wallets_on_currency_id_and_wallet_id  (currency_id,wallet_id) UNIQUE
#
