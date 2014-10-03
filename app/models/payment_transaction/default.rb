class PaymentTransaction::Default < PaymentTransaction
  # Default payment transaction captures all bitcoin-like transactions.

  validates_presence_of :tx_out
  validates_uniqueness_of :tx_out, scope: :txid

end
