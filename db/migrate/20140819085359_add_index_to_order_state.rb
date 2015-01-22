class AddIndexToOrderState < ActiveRecord::Migration
  def change
    add_index :orders, :state
  end
end
