class AddTradesCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :trades_count, :integer, default: 0
  end
end
