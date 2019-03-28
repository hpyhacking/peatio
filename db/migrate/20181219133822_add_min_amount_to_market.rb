class AddMinAmountToMarket < ActiveRecord::Migration[4.2]
  def change
    add_column :markets, :min_bid_amount, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :min_ask
    add_column :markets, :min_ask_amount, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :min_bid_amount
  end
end
