class AddTypeToPaymentTransactions < ActiveRecord::Migration
  def up
    add_column :payment_transactions, :type, :string, limit: 60
    PaymentTransaction.update_all type: 'PaymentTransaction::Default'
    add_index :payment_transactions, :type
  end

  def down
    remove_index :payment_transactions, :type
    remove_column :payment_transactions, :type
  end
end
