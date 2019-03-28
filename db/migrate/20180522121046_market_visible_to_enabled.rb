class MarketVisibleToEnabled < ActiveRecord::Migration[4.2]
  def change
    rename_column :markets, :visible, :enabled
  end
end
