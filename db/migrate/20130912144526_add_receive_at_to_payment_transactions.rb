class AddReceiveAtToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :receive_at, :datetime
  end
end
