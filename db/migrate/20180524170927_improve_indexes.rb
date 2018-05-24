class ImproveIndexes < ActiveRecord::Migration
  def change
    remove_index :trades, column: [:market_id]
    remove_index :accounts, column: [:currency_id]
    add_index :currencies, [:enabled, :code]
    remove_index :currencies, column: [:enabled]
  end
end
