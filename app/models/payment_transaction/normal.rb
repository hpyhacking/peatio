class PaymentTransaction::Normal < PaymentTransaction
  # Default payment transaction captures all bitcoin-like transactions.

  validates_presence_of :txout
  validates_uniqueness_of :txout, scope: :txid

end

# == Schema Information
# Schema version: 20180227163417
#
# Table name: payment_transactions
#
#  id            :integer          not null, primary key
#  txid          :string(255)
#  amount        :decimal(32, 16)
#  confirmations :integer
#  address       :string(255)
#  state         :integer
#  aasm_state    :string
#  created_at    :datetime
#  updated_at    :datetime
#  receive_at    :datetime
#  dont_at       :datetime
#  currency_id   :integer
#  type          :string(60)
#  txout         :integer
#
# Indexes
#
#  index_payment_transactions_on_currency_id     (currency_id)
#  index_payment_transactions_on_txid_and_txout  (txid,txout)
#  index_payment_transactions_on_type            (type)
#
