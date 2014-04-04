class AddCurrencyIndexToTrades < ActiveRecord::Migration
  def change
    add_index :trades, :currency
  end
end
