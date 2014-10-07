class PaymentTransaction::Dns < PaymentTransaction

  validates_uniqueness_of :txid

end
