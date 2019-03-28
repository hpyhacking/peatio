class ImproveDefaultsForMarket < ActiveRecord::Migration[4.2]
  def change
    change_column_default :markets, :ask_precision, 8
    change_column_default :markets, :bid_precision, 8
  end
end
