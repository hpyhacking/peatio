class AlterTradesCurrency < ActiveRecord::Migration
  def change
    change_column :trades, :currency, :string, limit: 10
    rename_column :trades, :currency, :market_id
  end
end