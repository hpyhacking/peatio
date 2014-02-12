class RebuildWithdraws < ActiveRecord::Migration
  def up
    change_table :withdraws do |t|
      t.rename :payment_way, :address_type
      t.rename :payment_to, :address
      t.rename :payment_id, :tx_id
      t.string :address_label, :after => :address
      t.datetime :done_at, :after => :updated_at
    end

    create_table :withdraw_addresses do |t|
      t.string :label
      t.string :address
      t.integer :category
      t.integer :account_id
      t.boolean :is_locked
      t.timestamps
    end
  end

  def down
    change_table :withdraws do |t|
      t.rename :address_type, :payment_way
      t.rename :address, :payment_to
      t.rename :tx_id, :payment_id
      t.remove :address_label
      t.remove :done_at
    end

    drop_table :withdraw_addresses
  end
end
