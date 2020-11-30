class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :currency_id, null: false
      t.references :reference, index: true, polymorphic: true
      t.string :txid, index: true
      t.string :from_address
      t.string :to_address
      t.decimal :amount, precision: 32, scale: 16, default: 0, null: false
      t.integer :block_number
      t.integer :txout
      t.string :status
      t.json :options
      t.timestamps
    end
    add_index :transactions, %i[currency_id]
    add_index :transactions, %i[currency_id txid], unique: true
  end
end
