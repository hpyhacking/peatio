class AddUUIDIndexForOrders < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :uuid, unique: true
  end
end
