# encoding: UTF-8
# frozen_string_literal: true

# Deprecated
# TODO: Delete this class and update type column
module Deposits
  class Fiat < Deposit
    has_one :blockchain, through: :currency

    validate { errors.add(:currency, :invalid) if currency && !currency.fiat? }

    def charge!
      with_lock { accept! }
    end
  end
end

# == Schema Information
# Schema version: 20200827105929
#
# Table name: deposits
#
#  id             :integer          not null, primary key
#  member_id      :integer          not null
#  currency_id    :string(10)       not null
#  amount         :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  not null
#  address        :string(95)
#  from_addresses :string(1000)
#  txid           :string(128)
#  txout          :integer
#  aasm_state     :string(30)       not null
#  block_number   :integer
#  type           :string(30)       not null
#  transfer_type  :integer
#  tid            :string(64)       not null
#  spread         :string(1000)
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
