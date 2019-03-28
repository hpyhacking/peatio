class AddMissingIndexesToOrderAndTrade < ActiveRecord::Migration[4.2]
  def change
    # index_trade_on_created_at is used in Trade #h24
    add_index :trades, :created_at unless index_exists?(:trades, :created_at)

    # index_orders_on_updated_at is used in API::V2::Market::Orders
    add_index :orders, :updated_at unless index_exists?(:orders, :updated_at)
  end
end
