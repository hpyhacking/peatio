module Deposits
  class Fiat < Deposit
    include ::AasmAbsolutely

    validates :amount, presence: true
    validate { errors.add(:currency, :invalid) if currency && !currency.fiat? }
    delegate :accounts, to: :channel

    def charge!
      with_lock do
        touch(:done_at)
        accept!
      end
    end

    def sn=(new_sn)
      self.member = Member.find_by_sn(new_sn)
    end

    before_validation { self.account ||= member&.ac(currency) }
  end
end

# == Schema Information
# Schema version: 20180403115050
#
# Table name: deposits
#
#  id                     :integer          not null, primary key
#  account_id             :integer
#  member_id              :integer
#  currency_id            :integer
#  amount                 :decimal(32, 16)
#  fee                    :decimal(32, 16)
#  fund_uid               :string(255)
#  fund_extra             :string(255)
#  txid                   :string(255)
#  state                  :integer
#  aasm_state             :string
#  created_at             :datetime
#  updated_at             :datetime
#  done_at                :datetime
#  confirmations          :string(255)
#  type                   :string(255)
#  payment_transaction_id :integer
#  txout                  :integer
#  tid                    :string(64)       not null
#
# Indexes
#
#  index_deposits_on_currency_id     (currency_id)
#  index_deposits_on_txid_and_txout  (txid,txout)
#
