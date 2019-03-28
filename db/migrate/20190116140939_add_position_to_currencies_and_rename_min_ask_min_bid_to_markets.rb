class AddPositionToCurrenciesAndRenameMinAskMinBidToMarkets < ActiveRecord::Migration[4.2]
  def change
    unless column_exists?(:currencies, :position)
      add_column :currencies, :position, :integer, default: 0, null: false, after: :withdraw_limit_72h
    end

    add_index :currencies, :position unless index_exists?(:currencies, :position)

    rename_column :markets, :min_ask, :min_ask_price if column_exists?(:markets, :min_ask)
    rename_column :markets, :max_bid, :max_bid_price if column_exists?(:markets, :max_bid)

    change_column_null :markets, :max_bid_price, false, 0.0

    change_column :markets, :min_ask_price,  :decimal, precision: 32, scale: 16, after: :bid_fee
    change_column :markets, :max_bid_price,  :decimal, precision: 32, scale: 16, after: :min_ask_price, default: 0.0
    change_column :markets, :min_ask_amount, :decimal, precision: 32, scale: 16, after: :max_bid_price
  end
end
