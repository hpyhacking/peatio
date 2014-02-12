class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.string :txid
      t.decimal :amount, :precision => 32, :scale => 16
      t.integer :confirmations
      t.string :address
      t.string :state

      t.timestamps
    end
  end
end
