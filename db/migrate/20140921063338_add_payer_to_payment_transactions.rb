class AddPayerToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :payer, :string
  end
end
