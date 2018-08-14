class ChangeLimitOfCurrencyIdAndMarketId < ActiveRecord::Migration
  def self.up
    change_column :markets, :ask_unit, :string, limit: 10
    change_column :markets, :bid_unit, :string, limit: 10
    change_column :wallets, :currency_id, :string, limit: 10
    change_column :markets, :id, :string, limit: 20
    change_column :orders, :market_id, :string, limit: 20
    change_column :trades, :market_id, :string, limit: 20
  end

  def self.down
    change_column :markets, :ask_unit, :string, limit: 5
    change_column :markets, :bid_unit, :string, limit: 5
    change_column :wallets, :currency_id, :string, limit: 5
    change_column :markets, :id, :string, limit: 10
    change_column :orders, :market_id, :string, limit: 10
    change_column :trades, :market_id, :string, limit: 10
  end
end
