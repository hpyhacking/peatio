class ChangeToEnumerizeInOrders < ActiveRecord::Migration
  def up
    change_column :orders, :bid, :integer
    change_column :orders, :ask, :integer
    change_column :orders, :state, :integer
    change_column :orders, :currency, :integer
    change_column :orders, :type, :string, :limit => 8
  end

  def down
    change_column :orders, :bid, :string
    change_column :orders, :ask, :string
    change_column :orders, :state, :string
    change_column :orders, :currency, :string
    change_column :orders, :type, :string, :limit => nil
  end
end
