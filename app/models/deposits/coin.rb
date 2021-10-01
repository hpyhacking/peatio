# encoding: UTF-8
# frozen_string_literal: true

# Deprecated
# TODO: Delete this class and update type column
module Deposits
  class Coin < Deposit
    validate { errors.add(:currency, :invalid) if currency && !currency.coin? }
    validates :address, :txid, presence: true
    validates :txid, uniqueness: { scope: %i[currency_id txout] }

    before_validation do
      if blockchain.blockchain_api.present? && blockchain_api.case_sensitive? == false
        self.txid = txid.try(:downcase)
        self.address = address.try(:downcase)
      end
    end

    before_validation do
      next unless blockchain.blockchain_api&.supports_cash_addr_format? && address?
      self.address = CashAddr::Converter.to_cash_address(address)
    end

    def as_json_for_event_api
      super.merge blockchain_confirmations: confirmations
    end
  end
end

# == Schema Information
# Schema version: 20211001083227
#
# Table name: deposits
#
#  id             :bigint           not null, primary key
#  member_id      :bigint           not null
#  currency_id    :string(10)       not null
#  blockchain_key :string(255)      not null
#  amount         :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  not null
#  address        :string(105)
#  from_addresses :text(65535)
#  txid           :string(128)
#  txout          :integer
#  aasm_state     :string(30)       not null
#  block_number   :integer
#  type           :string(30)       not null
#  transfer_type  :integer
#  tid            :string(64)       not null
#  spread         :string(1000)
#  error          :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  completed_at   :datetime
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
