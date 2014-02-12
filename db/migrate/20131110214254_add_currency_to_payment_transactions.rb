class AddCurrencyToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :currency, :integer
  end
end

