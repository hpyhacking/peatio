class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string  :currency_id,               limit: 5
      t.string  :name,                      limit: 64
      t.string  :address,     null: false
      t.string  :kind,        null: false,  limit: 32
      t.integer :nsig
      t.integer :parent
      t.string  :status,      null: true,   limit: 32

      t.timestamps null: false
    end
  end
end
