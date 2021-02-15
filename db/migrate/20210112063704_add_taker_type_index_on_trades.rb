class AddTakerTypeIndexOnTrades < ActiveRecord::Migration[5.2]
  def change
    add_index :trades, :taker_type
  end
end
