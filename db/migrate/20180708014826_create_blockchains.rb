class CreateBlockchains < ActiveRecord::Migration
  def change
    create_table :blockchains do |t|
      t.string :key
      t.string :name
      t.string :client
      t.string :server
      t.integer :height
      t.string :explorer_address
      t.string :explorer_transaction
      t.string :status

      t.timestamps null: false
    end
    add_index :blockchains, :key, unique: true
  end
end
