class AddIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :member_id, using: :btree
    add_index :orders, [:currency, :state], using: :btree
  end
end
