class AddSnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sn, :string
  end
end
