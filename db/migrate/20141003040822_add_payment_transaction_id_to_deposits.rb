class AddPaymentTransactionIdToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :payment_transaction_id, :integer
  end
end
