# encoding: UTF-8
# frozen_string_literal: true

module Withdraws
  class Coin < Withdraw
    include HasOneBlockchainThroughCurrency

    before_validation do
      next unless blockchain_api&.supports_cash_addr_format? && rid?
      self.rid = CashAddr::Converter.to_cash_address(rid) if CashAddr::Converter.is_valid?(rid)
    end

    before_validation do
      next if blockchain_api&.case_sensitive?
      self.rid  = rid.try(:downcase)
      self.txid = txid.try(:downcase)
    end

    validate do
      if blockchain_api&.supports_cash_addr_format? && rid?
        errors.add(:rid, :invalid) unless CashAddr::Converter.is_valid?(rid)
      end
    end

    def audit!
      wallet = Wallet.active.deposit.find_by(currency_id: currency_id)
      inspection = WalletClient[wallet].inspect_address!(rid)

      if inspection[:is_valid] == false
        Rails.logger.info { "#{self.class.name}##{id} uses invalid address: #{rid.inspect}" }
        reject!
      else
        super
      end
    end

    def as_json(*)
      super.merge \
        wallet_url:       wallet_url,
        transaction_url:  transaction_url,
        confirmations:    confirmations
    end

    def as_json_for_event_api
      super.merge blockchain_confirmations: confirmations
    end
  end
end

# == Schema Information
# Schema version: 20180925123806
#
# Table name: withdraws
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  member_id    :integer          not null
#  currency_id  :string(10)       not null
#  amount       :decimal(32, 16)  not null
#  fee          :decimal(32, 16)  not null
#  txid         :string(128)
#  aasm_state   :string(30)       not null
#  block_number :integer
#  sum          :decimal(32, 16)  not null
#  type         :string(30)       not null
#  tid          :string(64)       not null
#  rid          :string(95)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_at :datetime
#
# Indexes
#
#  index_withdraws_on_aasm_state            (aasm_state)
#  index_withdraws_on_account_id            (account_id)
#  index_withdraws_on_currency_id           (currency_id)
#  index_withdraws_on_currency_id_and_txid  (currency_id,txid) UNIQUE
#  index_withdraws_on_member_id             (member_id)
#  index_withdraws_on_tid                   (tid)
#  index_withdraws_on_type                  (type)
#
