class AddIndexToTrades < ActiveRecord::Migration
  def change
    add_index :trades, :created_at, using: :btree
  end
end
