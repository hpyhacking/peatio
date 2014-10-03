class AddTxOutToPaymentTransactions < ActiveRecord::Migration
  def change
    change_column :payment_transactions, :txid, :string, null: false
    add_column :payment_transactions, :tx_out, :integer
    add_index :payment_transactions, [:txid, :tx_out]
  end
end
