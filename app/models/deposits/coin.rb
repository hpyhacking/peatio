module Deposits
  class Coin < Deposit
    include ::AasmAbsolutely

    validates_presence_of :payment_transaction_id
    validates_uniqueness_of :payment_transaction_id
    validates_uniqueness_of :txout, scope: :txid
    belongs_to :payment_transaction

    def channel
      @channel ||= DepositChannel.find_by!(currency: currency.code)
    end

    def min_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.min_confirm && confirmations < channel.max_confirm
    end

    def max_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.max_confirm
    end

    def update_confirmations(confirmations)
      if !self.new_record? && self.confirmations.to_s != confirmations.to_s
        self.update!(confirmations: confirmations.to_s)
      end
    end

    def transaction_url
      if currency.transaction_url_template?
        currency.transaction_url_template.gsub('#{txid}', txid)
      end
    end

    def as_json(*)
      super.merge! \
        txid:            txid.to_s,
        confirmations:   payment_transaction.nil? ? 0 : payment_transaction.confirmations,
        transaction_url: transaction_url
    end
  end
end

# == Schema Information
# Schema version: 20180407082641
#
# Table name: deposits
#
#  id                     :integer          not null, primary key
#  account_id             :integer
#  member_id              :integer
#  currency_id            :integer
#  amount                 :decimal(32, 16)
#  fee                    :decimal(32, 16)
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
