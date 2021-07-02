class AddTriggersToOrders < ActiveRecord::Migration[5.2]
  def up
    drop_table :triggers
    add_column :orders, :trigger_price, :decimal, precision: 32, scale: 16, after: :market_type
    add_column :orders, :triggered_at, :datetime, after: :trigger_price
  end

  def down
    remove_column :orders, :trigger_price
    remove_column :orders, :triggered_at
  end
end
