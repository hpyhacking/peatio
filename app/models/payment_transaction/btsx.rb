class PaymentTransaction::Btsx < PaymentTransaction

  validates_uniqueness_of :txid

end
