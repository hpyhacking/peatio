class AddPositionToCurrenciesAndRenameMinAskMinBidToMarkets < ActiveRecord::Migration
  def change
    add_column    :currencies, :position, :integer, default: 0, null: false, after: :withdraw_limit_72h
    add_index     :currencies, :position, unique: true
    rename_column :markets, :min_ask, :min_ask_price
    rename_column :markets, :max_bid, :max_bid_price
    change_column :markets, :min_ask_price, :decimal, null: false, default: 0, precision: 17, scale: 16, after: :bid_fee
    change_column :markets, :max_bid_price, :decimal, null: false, default: 0, precision: 17, scale: 16, after: :min_ask_price
    change_column :markets, :min_ask_amount, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :max_bid_price
  end
end
