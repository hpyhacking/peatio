class AddSourceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :source, :string, null: false
    Order.update_all(source: 'Web')
  end
end
