class AddUsedFundsToTrades < ActiveRecord::Migration
  def change
    add_column :trades, :funds, :decimal, precision: 32, scale: 16
  end
end
