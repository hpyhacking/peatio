class CreateBlockchains < ActiveRecord::Migration
  def change
    create_table :blockchains do |t|
      t.string  :key,                 null: false,                index: { unique: true }
      t.string  :name
      t.string  :client,              null: false
      t.string  :server
      t.integer :height,              null: false
      t.string  :explorer_address
      t.string  :explorer_transaction
      t.integer :min_confirmations,   null: false, default: 6
      t.string  :status,              null: false,                index: true

      t.timestamps null: false
    end

    add_column :currencies, :blockchain_key, :string, limit: 32, after: :id
  end
end
