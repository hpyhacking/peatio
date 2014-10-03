class PaymentTransaction::Normal < PaymentTransaction
  # Default payment transaction captures all bitcoin-like transactions.

  validates_presence_of :txout
  validates_uniqueness_of :txout, scope: :txid

end
