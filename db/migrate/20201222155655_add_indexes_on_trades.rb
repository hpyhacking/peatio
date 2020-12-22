class AddIndexesOnTrades < ActiveRecord::Migration[5.2]
  def change
    remove_index :trades, column: %i[maker_id taker_id]

    add_index :trades, :maker_id
    add_index :trades, :taker_id
  end
end
