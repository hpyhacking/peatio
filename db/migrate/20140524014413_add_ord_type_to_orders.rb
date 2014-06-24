class AddOrdTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ord_type, :string, limit: 10
  end
end
