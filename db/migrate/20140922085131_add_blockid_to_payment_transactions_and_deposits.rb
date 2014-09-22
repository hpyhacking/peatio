class AddBlockidToPaymentTransactionsAndDeposits < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :blockid, :string
    add_column :deposits, :blockid, :string
  end
end
