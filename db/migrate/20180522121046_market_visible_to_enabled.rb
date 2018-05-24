class MarketVisibleToEnabled < ActiveRecord::Migration
  def change
    rename_column :markets, :visible, :enabled
  end
end
