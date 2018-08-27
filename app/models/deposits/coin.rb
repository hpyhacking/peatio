# encoding: UTF-8
# frozen_string_literal: true

module Deposits
  class Coin < Deposit
    validate { errors.add(:currency, :invalid) if currency && !currency.coin? }
    validates :address, :txid, :txout, presence: true
    validates :txid, uniqueness: { scope: %i[currency_id txout] }

    before_validation do
      next unless currency&.supports_cash_addr_format? && address?
      self.address = CashAddr::Converter.to_legacy_address(address)
    end

    before_validation do
      next if blockchain_api&.case_sensitive?
      self.txid = txid.try(:downcase)
      self.address = address.try(:downcase)
    end

    def transaction_url
      if txid? && currency.blockchain.explorer_transaction?
        currency.blockchain.explorer_transaction.gsub('#{txid}', txid)
      end
    end

    def latest_block_number
      currency.blockchain_api.latest_block_number
    end

    def confirmations
      return 0 if block_number.blank?
      return latest_block_number - block_number if (latest_block_number - block_number) >= 0
      'N/A'
    rescue Faraday::ConnectionFailed => e
      report_exception(e)
      'N/A'
    end

    def as_json(*)
      super.merge!(transaction_url: transaction_url,
                   confirmations:   confirmations)
    end

    def as_json_for_event_api
      super.merge blockchain_confirmations: confirmations
    end
  end
end

# == Schema Information
# Schema version: 20180719172203
#
# Table name: deposits
#
#  id           :integer          not null, primary key
#  member_id    :integer          not null
#  currency_id  :string(10)       not null
#  amount       :decimal(32, 16)  not null
#  fee          :decimal(32, 16)  not null
#  address      :string(64)
#  txid         :string(128)
#  txout        :integer
#  aasm_state   :string(30)       not null
#  block_number :integer
#  type         :string(30)       not null
#  tid          :string(64)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_at :datetime
#
# Indexes
#
#  index_deposits_on_aasm_state_and_member_id_and_currency_id  (aasm_state,member_id,currency_id)
#  index_deposits_on_currency_id                               (currency_id)
#  index_deposits_on_currency_id_and_txid_and_txout            (currency_id,txid,txout) UNIQUE
#  index_deposits_on_member_id_and_txid                        (member_id,txid)
#  index_deposits_on_tid                                       (tid)
#  index_deposits_on_type                                      (type)
#
